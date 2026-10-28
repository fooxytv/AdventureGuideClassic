#!/usr/bin/env python3
"""
AtlasLoot -> Adventure Guide Classic instance level ranges.

Writes `minLevel` and `levelRange` onto every instance table in `data/`, so the
guide can say who an instance is for and rank a suggestion against the player's
level.

    python tools/gen_instance_levels.py            # report the join, write nothing
    python tools/gen_instance_levels.py --apply    # write it in
    python tools/gen_instance_levels.py --apply --force   # overwrite existing values

AtlasLoot carries `LevelRange = {enter, recMin, recMax}` per instance:

    minLevel   = enter              -- the level the client stops turning you away at
    levelRange = { recMin, recMax } -- who the content is actually for

Join key: the instance **name**, not an id.

The ids cannot be used. `instanceID` and `mapID` mean opposite things in the two
halves of our own data -- Era files are journal-id/map-id, TBC files are the
reverse -- and the Forever files carry `mapID` alone. Joining on `mapID` matches
27 of 67 and, worse, matches three of them to the wrong instance: Demon Fall
Canyon and Karazhan Crypts both land on Blackfathom Deeps, and The Arcatraz on
The Black Morass. A wrong level range is worse than none, because nothing
downstream can tell it is wrong.

Names join cleanly once two things are handled.

**Wings.** AtlasLoot splits Scarlet Monastery into four, Dire Maul into three and
Blackrock Spire into two, while the guide models each as one instance. A merged
range takes the lowest door and the widest recommendation, so Scarlet Monastery
reads 26-45 rather than whichever wing happened to match first.

**Season of Discovery.** There are two Classic sources in the AtlasLoot checkout
and they disagree on exactly three instances:

    blackfathomdeeps        post-SoD (25, 25, 40)   pre-SoD (15, 24, 32)
    gnomeregan              post-SoD (40, 40, 50)   pre-SoD (19, 29, 38)
    thetempleofatalhakkar   post-SoD (50, 50, 60)   pre-SoD (45, 50, 60)

Those are the three SoD turned into raids, and the post-SoD file overwrote the
dungeon's entry with the raid's -- its boss ids are in the 200000 range. The
guide models them as a dungeon *and* a raid, which is the same distinction, so a
file under `Dungeons/` reads the pre-SoD source first and a file under `Raids/`
reads the post-SoD one. Every other key is identical in both.
"""
import argparse
import os
import re
import sys

AL_ROOT = os.path.expanduser("~/workspaces/home-projects/AllAtlasLoot")
AG_ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")

# Tag -> file. "classic" is the current Classic data, which carries SoD; "vanilla"
# is the copy on the TBC branch, which predates it; "tbc" is Burning Crusade.
SOURCES = {
    "classic": os.path.join(AL_ROOT, "AtlasLootClassic_DungeonsAndRaids", "data.lua"),
    "vanilla": os.path.join(AL_ROOT, "TBC", "AtlasLootClassic_DungeonsAndRaids", "data.lua"),
    "tbc": os.path.join(AL_ROOT, "AtlasLootClassic_DungeonsAndRaids", "data-tbc.lua"),
}

# Which source answers first, by the section the file sits in. See the SoD note above.
ORDER = {
    "Dungeons": ("vanilla", "classic", "tbc"),
    "Raids": ("classic", "vanilla", "tbc"),
}

# Our instance name -> the AtlasLoot keys that make it up.
#
# Only two reasons to be here: AtlasLoot splits the instance into wings, or it
# calls the place something a name match cannot reach. Nothing is here to paper
# over a missing range -- an instance AtlasLoot does not cover belongs in
# FALLBACK below, where it is visible.
ALIASES = {
    "scarletmonastery": ["ScarletMonasteryGraveyard", "ScarletMonasteryLibrary",
                         "ScarletMonasteryArmory", "ScarletMonasteryCathedral"],
    "diremaul": ["DireMaulEast", "DireMaulWest", "DireMaulNorth"],
    "blackrockspire": ["LowerBlackrockSpire", "UpperBlackrockSpire"],
    "ragefirechasm": ["Ragefire"],
    "stormwindstockade": ["TheStockade"],
    "onyxiaslair": ["Onyxia"],
}

# Instances AtlasLoot has no LevelRange for at all.
#
# It covers every Classic and TBC *dungeon* and every Classic raid, and then
# stops: not one TBC raid carries a LevelRange. These are the entry requirements,
# and the recommendation is the level cap because that is what a TBC raid is for
# -- the same shape AtlasLoot uses for every level-60 raid it does carry.
#
# Forever's own instances are deliberately absent. AtlasLoot does not know them,
# nothing else in the tree records a level for them, and a guess dressed as data
# is the thing this tool exists to avoid. They ship without a range, and the
# suggestion ranking treats a missing range as unknown rather than as level 1.
FALLBACK = {
    "karazhan": (68, 70, 70),
    "gruulslair": (70, 70, 70),
    "magtheridonslair": (70, 70, 70),
    "serpentshrinecavern": (70, 70, 70),
    "eye": (70, 70, 70),
    "battleformounthyjal": (70, 70, 70),
    "blacktemple": (70, 70, 70),
    "sunwellplateau": (70, 70, 70),
}


def norm(name):
    """
    A comparable name.

    A trailing digit goes because AtlasLoot suffixes a key when a newer table
    supersedes an older one -- `MoltenCore2`, `Onyxia2` -- and the digit is a
    revision marker rather than part of the name. A leading "the" goes because
    the two sides disagree about it freely ("TheRuinsofAhnQiraj" against our
    "Ruins of Ahn'Qiraj"). Neither collides with anything in any source.
    """
    key = re.sub(r"[^a-z0-9]", "", re.sub(r"\d+$", "", name).lower())
    return re.sub(r"^the", "", key)


def match_brace(s, i):
    """i points at an opening '{'; return the index just past its matching '}'."""
    depth = 0
    while i < len(s):
        if s[i] == "{":
            depth += 1
        elif s[i] == "}":
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return len(s)


def parse_source(path):
    """-> {normalised key: (enter, recMin, recMax)}"""
    if not os.path.exists(path):
        sys.exit(f"missing AtlasLoot source: {path}\nSet AL_ROOT at the top of this script.")
    s = open(path, encoding="utf-8", errors="replace").read()
    out = {}
    for m in re.finditer(r'\bdata\["([^"]+)"\]', s):
        key = m.group(1)
        start = s.find("{", s.find("=", m.end()))
        head = s[start:match_brace(s, start)]
        # Stop at `items`, so a boss's own Level can never be read as the instance's.
        items = re.search(r"\bitems\s*=\s*\{", head)
        if items:
            head = head[:items.start()]
        lr = re.search(r"LevelRange\s*=\s*(?:GetForVersion\s*\(?\s*)?\{([^}]*)\}", head)
        if not lr:
            continue
        nums = [int(x) for x in re.findall(r"\d+", lr.group(1))]
        if len(nums) >= 3:
            # GetForVersion(classic, bcc, ...) -- the first list is the Classic one,
            # and the Classic numbers are the ones that describe the content. BCC
            # retuned a few vanilla dungeons by a level or two; the only player who
            # meets those is a BCC alt, and being two levels out on a recommendation
            # changes nothing about which instance gets suggested.
            out[norm(key)] = tuple(nums[:3])
    return out


def merge(ranges):
    """Wings into one instance: the lowest door, and the widest recommendation."""
    return (min(r[0] for r in ranges),
            min(r[1] for r in ranges),
            max(r[2] for r in ranges))


def resolve(name, section, sources):
    key = norm(name)
    for tag in ORDER[section]:
        src = sources[tag]
        if key in ALIASES:
            hits = [src[norm(k)] for k in ALIASES[key] if norm(k) in src]
            if hits:
                return merge(hits), tag + "/alias"
        if key in src:
            return src[key], tag
    if key in FALLBACK:
        return FALLBACK[key], "fallback"
    return None, None


def instance_files():
    for section in ("Dungeons", "Raids"):
        root = os.path.join(AG_ROOT, section)
        for flavour in sorted(os.listdir(root)):
            d = os.path.join(root, flavour)
            if not os.path.isdir(d):
                continue
            for f in sorted(os.listdir(d)):
                if f.endswith(".lua"):
                    yield section, os.path.join(d, f)


# The instance table's own fields, at one tab. An encounter's are at two, so
# anchoring on a single tab cannot wander into a boss by accident.
NAME_RE = re.compile(r'^\tname = "([^"]+)",', re.M)
# [^\r\n]* rather than .*$ -- under re.M, `.` matches the \r of a CRLF ending and
# `$` sits between it and the \n, so an insert anchored on .*$ lands inside the
# line ending and leaves a stray \r behind. These files check out as CRLF.
ANCHOR_RE = re.compile(r"^\t(?:mapID|instanceID) = \d+,[^\r\n]*", re.M)
EXISTING_RE = re.compile(r"^\t(?:minLevel|levelRange) = [^\r\n]*\r?\n?", re.M)


def read(path):
    # newline="" keeps the file's own endings. .gitattributes checks these out as
    # CRLF, and rewriting them as LF would turn a two-line change into a
    # whole-file diff.
    with open(path, encoding="utf-8", newline="") as fh:
        return fh.read()


def patch(text, levels):
    eol = "\r\n" if "\r\n" in text else "\n"
    text = EXISTING_RE.sub("", text)
    anchor = ANCHOR_RE.search(text)
    if not anchor:
        return None
    enter, lo, hi = levels
    block = f"{eol}\tminLevel = {enter},{eol}\tlevelRange = {{ {lo}, {hi} }},"
    return text[:anchor.end()] + block + text[anchor.end():]


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--apply", action="store_true", help="write the values into data/")
    ap.add_argument("--force", action="store_true", help="also replace existing values")
    args = ap.parse_args()

    sources = {tag: parse_source(path) for tag, path in SOURCES.items()}
    hits = misses = kept = 0
    for section, path in instance_files():
        text = read(path)
        rel = os.path.relpath(path, AG_ROOT).replace("\\", "/")
        nm = NAME_RE.search(text)
        if not nm:
            print(f"  [!] {rel}: no instance name")
            continue
        name = nm.group(1)
        levels, how = resolve(name, section, sources)
        if not levels:
            misses += 1
            print(f"  MISS {name:32} {rel}")
            continue
        if EXISTING_RE.search(text) and not args.force:
            kept += 1
            print(f"  keep {name:32} already has a range")
            continue
        hits += 1
        enter, lo, hi = levels
        print(f"  OK   {name:32} minLevel {enter:2}  range {lo:2}-{hi:2}  ({how})")
        if args.apply:
            patched = patch(text, levels)
            if patched is None:
                print(f"  [!] {rel}: no mapID or instanceID to anchor on")
                continue
            with open(path, "w", encoding="utf-8", newline="") as fh:
                fh.write(patched)

    print(f"\n{hits} resolved, {kept} kept, {misses} without a level range")
    if not args.apply:
        print("(report only -- pass --apply to write)")


if __name__ == "__main__":
    main()
