#!/usr/bin/env python3
"""
CMaNGOS creature_template -> Adventure Guide Classic boss metadata.

Gives the boss portrait tooltip its second line -- "Level 19 Humanoid Elite" --
by writing `level`, `creatureType` and `classification` onto every encounter.

    python tools/gen_npc_meta.py extract <classicmangos.sql> <tbcmangos.sql>
    python tools/gen_npc_meta.py apply [--force]
    python tools/gen_npc_meta.py report

`extract` reads the dumps and writes `tools/npc_meta.tsv`, which is checked in, so
`apply` needs neither the 85MB of SQL nor the network. Run `extract` again only
when encounters are added.

Why this source. A creature's level, type and classification are server-side in
this era: the client learns them from the unit in front of it, the journal has no
API for them, and `Creature.db2` ships empty. CMaNGOS's `creature_template` is the
same 1.12.1 and 2.4.3 data the addon targets, and `tools/npc_models.tsv` already
came from it.

    https://github.com/cmangos/classic-db  (GPL-2.0)
    https://github.com/cmangos/tbc-db      (GPL-2.0)

Join key: `encounter.encounterID == creature_template.Entry`. Our encounterIDs are
npc ids throughout -- Rhahk'Zor is 644 in both, Watchkeeper Gargolmar 17306.

Two guards, because an id alone is not enough:

**Flavour.** A dump is only consulted for the matching folder: `era/` against
classic, `tbc/` against tbc. Forever's instances are skipped entirely.

**The name has to agree.** Forever numbers its own bosses in the vanilla range --
Witherfang in the Ruins of Lordaeron carries encounterID 3353, which in classic-db
is Grezz Ragefist, a level 60 Humanoid in Orgrimmar. Taking that on trust would
have put a confident, wrong line under a boss portrait, and nothing downstream
could tell. So a row is only accepted when its name matches the encounter's, and
every rejection is reported rather than silently dropped.
"""
import argparse
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
AG_ROOT = os.path.join(os.path.dirname(HERE), "data")
OUT = os.path.join(HERE, "npc_meta.tsv")

# CreatureType.dbc, 1.12.1 ordering. Verified against the dump rather than
# recalled: Magmadar reads 1, Onyxia 2, Lord Kazzak 3, Ragnaros 4, Baron
# Rivendare 6, Rhahk'Zor 7, Mekgineer Thermaplugg 9.
CREATURE_TYPES = {
    1: "Beast", 2: "Dragonkin", 3: "Demon", 4: "Elemental", 5: "Giant",
    6: "Undead", 7: "Humanoid", 8: "Critter", 9: "Mechanical",
    10: "", 11: "Totem", 12: "Non-combat Pet", 13: "Gas Cloud",
}

# creature_template.Rank. 10 is "not specified", which the game shows as nothing
# at all, so it maps to an empty string rather than to a word.
RANKS = {0: "", 1: "Elite", 2: "Rare Elite", 3: "Boss", 4: "Rare"}

# Which dump answers for which folder. Forever is absent on purpose -- see above.
FLAVOURS = {"era": "classic", "tbc": "tbc"}

# Encounters the guide models as one fight but the database as several creatures,
# and the creature whose stats stand for the encounter.
#
# Every one of these is a real combatant in the fight. Encounters whose id points
# at an announcer rather than a fighter are deliberately absent -- Blackrock
# Depths' Ring of Law resolves to High Justice Grimstone, who calls the matches
# from the balcony at level 52 while the thing you fight is level 50-ish, and
# Karazhan's Opera Hall resolves to Barnes, who introduces it. A plausible,
# confidently wrong line under a boss portrait is worse than no line.
ALIASES = {
    "Warder Stilgiss & Verek": "Warder Stilgiss",
    "Weaver and Dreamscythe": "Dreamscythe",
    "Dreamscythe and Weaver": "Dreamscythe",
    "Hazzas and Morphaz": "Hazzas",
    "Morphaz and Hazzas": "Hazzas",
    "The Lost Dwarves": "Baelog",
    "Vazruden the Herald": "Vazruden",
    "Silithid Royalty": "Princess Yauj",
    "Twin Emperors": "Emperor Vek'lor",
    "Reliquary of Souls": "Essence of Suffering",
    "The Eredar Twins": "Lady Sacrolash",
    "Edge of Madness": "Hazza'rah",
    "Servant's Quarters": "Hyakiss the Lurker",
    "Curator": "The Curator",
}


def split_row(text):
    """
    Split one `(...)` row into its raw fields.

    Written as a character walk rather than a regex because the names carry
    commas, apostrophes and backslash escapes -- 'Kurzen\\'s Agent' -- and any
    regex that splits on commas quietly corrupts exactly those rows.
    """
    fields, field, quoted, escaped = [], [], False, False
    for char in text:
        if escaped:
            field.append(char)
            escaped = False
        elif char == "\\":
            field.append(char)
            escaped = True
        elif quoted:
            field.append(char)
            if char == "'":
                quoted = False
        elif char == "'":
            field.append(char)
            quoted = True
        elif char == ",":
            fields.append("".join(field).strip())
            field = []
        else:
            field.append(char)
    fields.append("".join(field).strip())
    return fields


def split_payload(payload):
    """Yield each top-level `(...)` group from a SQL VALUES payload."""
    depth, start, quoted, escaped = 0, None, False, False
    for i, char in enumerate(payload):
        if escaped:
            escaped = False
        elif char == "\\":
            escaped = True
        elif quoted:
            if char == "'":
                quoted = False
        elif char == "'":
            quoted = True
        elif char == "(":
            if depth == 0:
                start = i + 1
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                yield payload[start:i]


def unquote(value):
    if value.startswith("'") and value.endswith("'"):
        value = value[1:-1]
    return value.replace("\\'", "'").replace("\\\\", "\\")


def read_dump(path):
    """-> {Entry: (minLevel, maxLevel, creatureType, rank, name)}"""
    if not os.path.exists(path):
        sys.exit(f"missing dump: {path}")
    sql = open(path, encoding="utf-8", errors="replace").read()
    create = re.search(r"CREATE TABLE `creature_template` \((.*?)\n\) ENGINE", sql, re.S)
    if not create:
        sys.exit(f"no creature_template in {path}")
    # Column order differs between the two dumps -- TBC inserts IconName and
    # HeroicEntry -- so the indices are read off the schema rather than hardcoded.
    cols = re.findall(r"^  `(\w+)`", create.group(1), re.M)
    ix = {name: i for i, name in enumerate(cols)}
    out = {}
    for insert in re.finditer(r"INSERT INTO `creature_template` VALUES (.*?);\s*\n", sql, re.S):
        for raw in split_payload(insert.group(1)):
            f = split_row(raw)
            if len(f) < len(cols):
                continue
            try:
                entry = int(f[ix["Entry"]])
            except ValueError:
                continue
            out[entry] = (int(f[ix["MinLevel"]]), int(f[ix["MaxLevel"]]),
                          int(f[ix["CreatureType"]]), int(f[ix["Rank"]]),
                          unquote(f[ix["Name"]]))
    return out


# ---------- our data ----------

INSTANCE_NAME_RE = re.compile(r'^\tname = "([^"]+)",', re.M)
# An encounter's fields sit at two tabs; the instance's own sit at one.
ENCOUNTER_NAME_RE = re.compile(r'^\t\tname = "([^"]+)",', re.M)
ENCOUNTER_ID_RE = re.compile(r"^\t\tencounterID = (\d+),[^\r\n]*", re.M)


def instance_files():
    for section in ("Dungeons", "Raids"):
        root = os.path.join(AG_ROOT, section)
        for flavour in sorted(os.listdir(root)):
            d = os.path.join(root, flavour)
            if not os.path.isdir(d):
                continue
            for f in sorted(os.listdir(d)):
                if f.endswith(".lua"):
                    yield flavour, os.path.join(d, f)


def read(path):
    # newline="" keeps CRLF; see tools/gen_instance_levels.py.
    with open(path, encoding="utf-8", newline="") as fh:
        return fh.read()


def encounters(text):
    """Yield (encounterID, name, match) for each encounter, in file order."""
    names = list(ENCOUNTER_NAME_RE.finditer(text))
    for m in ENCOUNTER_ID_RE.finditer(text):
        # The encounter's name is the nearest `name =` above its encounterID.
        above = [n for n in names if n.start() < m.start()]
        yield int(m.group(1)), (above[-1].group(1) if above else None), m


def comparable(name):
    return re.sub(r"[^a-z0-9]", "", name.lower())


# ---------- commands ----------

def cmd_extract(args):
    dumps = {"classic": read_dump(args.classic), "tbc": read_dump(args.tbc)}
    print(f"classic-db {len(dumps['classic'])} creatures, tbc-db {len(dumps['tbc'])}")

    rows, missing, mismatched = {}, [], []
    for flavour, path in instance_files():
        source = FLAVOURS.get(flavour)
        if not source:
            continue
        text = read(path)
        rel = os.path.relpath(path, AG_ROOT).replace("\\", "/")
        for npc, name, _ in encounters(text):
            row = dumps[source].get(npc)
            if not row:
                missing.append((rel, npc, name))
                continue
            expected = ALIASES.get(name, name)
            if name and comparable(expected) != comparable(row[4]):
                mismatched.append((rel, npc, name, row[4]))
                continue
            rows[(npc, source)] = row

    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("# npc id\tsource\tlevel\tcreature type\tclassification\tname\n")
        fh.write("# Generated by tools/gen_npc_meta.py from the CMaNGOS classic-db\n")
        fh.write("# and tbc-db world databases (GPL-2.0). Level is MinLevel, or\n")
        fh.write("# \"min-max\" where the creature spawns across a band.\n")
        for (npc, source), (lo, hi, ctype, rank, name) in sorted(rows.items()):
            level = str(lo) if lo == hi else f"{lo}-{hi}"
            fh.write(f"{npc}\t{source}\t{level}\t{CREATURE_TYPES.get(ctype, '')}"
                     f"\t{RANKS.get(rank, '')}\t{name}\n")

    print(f"\nwrote {len(rows)} rows to {os.path.relpath(OUT, os.path.dirname(HERE))}")
    if mismatched:
        print(f"\n{len(mismatched)} rejected -- the id belongs to a different creature:")
        for rel, npc, ours, theirs in mismatched:
            print(f"  {npc:7} {ours or '?':28} vs {theirs:28} {rel}")
    if missing:
        print(f"\n{len(missing)} encounters with no row in the dump:")
        for rel, npc, name in missing:
            print(f"  {npc:7} {name or '?':28} {rel}")


def load_meta():
    if not os.path.exists(OUT):
        sys.exit(f"missing {OUT} -- run `extract` first")
    meta = {}
    for line in open(OUT, encoding="utf-8"):
        if line.startswith("#") or not line.strip():
            continue
        npc, source, level, ctype, rank, name = line.rstrip("\n").split("\t")
        meta[(int(npc), source)] = (level, ctype, rank, name)
    return meta


EXISTING_RE = re.compile(r"^\t\t(?:level|creatureType|classification) = [^\r\n]*\r?\n?", re.M)


def cmd_apply(args):
    meta = load_meta()
    written = skipped = kept = 0
    for flavour, path in instance_files():
        source = FLAVOURS.get(flavour)
        text = read(path)
        rel = os.path.relpath(path, AG_ROOT).replace("\\", "/")
        if not source:
            skipped += sum(1 for _ in encounters(text))
            continue
        eol = "\r\n" if "\r\n" in text else "\n"
        if args.force:
            text = EXISTING_RE.sub("", text)
        changed = False
        # Rebuild back to front, so each insert leaves the earlier offsets valid.
        for npc, name, match in reversed(list(encounters(text))):
            # Already stamped, and --force stripped it above if it was wanted gone.
            # Without this a second run inserts the block again rather than skipping.
            if EXISTING_RE.match(text, match.end() + len(eol)):
                kept += 1
                continue
            row = meta.get((npc, source))
            if not row:
                skipped += 1
                continue
            level, ctype, rank, _ = row
            block = [f'\t\tlevel = {level},' if level.isdigit() else f'\t\tlevel = "{level}",']
            if ctype:
                block.append(f'\t\tcreatureType = "{ctype}",')
            if rank:
                block.append(f'\t\tclassification = "{rank}",')
            insert = eol + eol.join(block)
            text = text[:match.end()] + insert + text[match.end():]
            written += 1
            changed = True
        if changed and not args.dry_run:
            with open(path, "w", encoding="utf-8", newline="") as fh:
                fh.write(text)
        print(f"  {rel}")
    print(f"\n{written} encounters written, {skipped} without metadata, {kept} kept")
    if args.dry_run:
        print("(dry run -- nothing written)")


def cmd_report(args):
    meta = load_meta()
    total = covered = 0
    by_flavour = {}
    for flavour, path in instance_files():
        source = FLAVOURS.get(flavour)
        text = read(path)
        for npc, name, _ in encounters(text):
            total += 1
            hit = source and (npc, source) in meta
            covered += bool(hit)
            tally = by_flavour.setdefault(flavour, [0, 0])
            tally[0] += 1
            tally[1] += bool(hit)
    for flavour, (n, c) in sorted(by_flavour.items()):
        print(f"  {flavour:8} {c:4}/{n:<4} encounters have level and type")
    print(f"\n{covered}/{total} overall")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    e = sub.add_parser("extract", help="read the SQL dumps, write tools/npc_meta.tsv")
    e.add_argument("classic", help="path to classicmangos.sql")
    e.add_argument("tbc", help="path to tbcmangos.sql")
    e.set_defaults(func=cmd_extract)
    a = sub.add_parser("apply", help="write level/creatureType/classification into data/")
    a.add_argument("--force", action="store_true", help="replace existing values")
    a.add_argument("--dry-run", action="store_true")
    a.set_defaults(func=cmd_apply)
    r = sub.add_parser("report", help="coverage only")
    r.set_defaults(func=cmd_report)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
