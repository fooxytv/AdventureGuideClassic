#!/usr/bin/env python3
"""Fix `npcs` in the encounter data and generate data/CreatureModels.lua.

Two outputs, both driven by AtlasLoot and joined on encounterID (the one field
in our data that is reliable -- it is what the loot regeneration matched on):

  1. `npcs = { ... }` rewritten in place to AtlasLoot's npcID list for that boss.
     Much of this data was a copy-pasted placeholder repeated across whole files.

  2. data/CreatureModels.lua -- encounterID -> the creature display ids to show.

Displays are keyed by encounter rather than by npc on purpose. AtlasLoot lists
one DisplayIDs entry per *distinct creature*, but npcID often carries extra ids
for the heroic copy of the same creature, so the two lists do not align: e.g.
Watchkeeper Gargolmar has npcID {17306, 18436} and DisplayIDs {{18236}}, and
Nazan & Vazruden has four npcIDs for two creatures. Zipping them by index would
silently attach the wrong model to half the heroic encounters.

Usage:
    python tools/gen_creature_models.py [--skip PATH ...] [--dry-run]
"""
import argparse, os, re, sys, glob

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atlasloot_tool import parse_atlasloot, parse_user, match_brace, SOURCES

AG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(AG_ROOT, "data", "CreatureModels.lua")
HEIGHTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "creature_heights.tsv")

# The npcs value copy-pasted across 156 encounters; not real data for any of them.
PLACEHOLDER = {2135, 12456, 12314}

HEADER = """--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming

GENERATED FILE -- do not edit by hand. Regenerate with:
    python tools/gen_creature_models.py

Creature display ids per encounter, for the model viewer. Keyed by encounterID
rather than npc id: AtlasLoot lists one entry per distinct creature, while npcID
carries extra ids for heroic copies of the same creature, so the two do not line
up one to one.
Source: AtlasLootClassic DungeonsAndRaids data.

The second table is each creature's model height in world units, used to pull the
camera back for the big ones. Creature heights span roughly 0.9 (Pusillin) to 66
(Supremus), so a single camera framing cannot suit all of them.
Source: wago.tools DB2 export, see tools/creature_heights.tsv.
]]
select(2, ...).SetupGlobalFacade()

CreatureModelService.Register({
"""


def build_index():
    """encounterID -> (ordered npcIDs, flat display id list)."""
    index = {}
    for key in ("tbc", "all"):
        for boss in parse_atlasloot(SOURCES[key]):
            displays = [d[0] for d in boss["displayids"] if d]
            for npc in boss["npcorder"]:
                index.setdefault(npc, (boss["npcorder"], displays))
    return index


def data_files():
    return sorted(
        glob.glob(os.path.join(AG_ROOT, "data", "Dungeons", "**", "*.lua"), recursive=True)
        + glob.glob(os.path.join(AG_ROOT, "data", "Raids", "**", "*.lua"), recursive=True)
    )


def rewrite_npcs(path, index, dry_run):
    """Rewrite each encounter's npcs list. Returns (fixed, cleared)."""
    raw = open(path, "rb").read()
    crlf = b"\r\n" in raw
    text = raw.decode("utf-8").replace("\r\n", "\n")
    fixed = cleared = 0

    # Reverse order so the byte offsets of earlier entries stay valid.
    for boss in reversed(parse_user(path)):
        start, end = boss["span"]
        entry = text[start:end]
        match = re.search(r'npcs\s*=\s*\{([^}]*)\}', entry)
        if not match:
            continue
        current = [int(x) for x in re.findall(r'\d+', match.group(1))]
        hit = index.get(boss["encounterID"])

        if hit:
            wanted = hit[0]
            if current == wanted:
                continue
            body = ", ".join(str(n) for n in wanted)
            fixed += 1
        elif set(current) == PLACEHOLDER:
            body = ""       # junk with nothing to replace it -> empty it out
            cleared += 1
        else:
            continue

        replacement = ("npcs = { %s }" % body) if body else "npcs = {}"
        entry = entry[:match.start()] + replacement + entry[match.end():]
        text = text[:start] + entry + text[end:]

    if not dry_run and (fixed or cleared):
        out = text.replace("\n", "\r\n") if crlf else text
        open(path, "wb").write(out.encode("utf-8"))
    return fixed, cleared


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--skip", nargs="*", default=[],
                    help="repo-relative paths to leave alone")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    skip = {s.replace("\\", "/") for s in args.skip}

    index = build_index()
    rows, total_fixed, total_cleared, skipped, no_display = [], 0, 0, 0, []

    for path in data_files():
        rel = os.path.relpath(path, AG_ROOT).replace("\\", "/")
        if rel in skip:
            skipped += 1
            continue
        fixed, cleared = rewrite_npcs(path, index, args.dry_run)
        total_fixed += fixed
        total_cleared += cleared

    # Display table covers every encounter we can resolve, including skipped
    # files -- the data file is generated wholesale and touches nothing in place.
    seen = set()
    for path in data_files():
        for boss in parse_user(path):
            enc = boss["encounterID"]
            if enc in seen:
                continue
            seen.add(enc)
            hit = index.get(enc)
            if not hit:
                continue
            if not hit[1]:
                no_display.append((boss["name"], enc))
                continue
            ids = ", ".join(str(d) for d in hit[1])
            rows.append((enc, f"\t[{enc}] = {{ {ids} }},"))

    rows.sort()

    # Model heights, for the camera. Only the displays we actually reference.
    used = set()
    for _, line in rows:
        used.update(int(x) for x in re.findall(r'\d+', line.split("{", 1)[1]))
    heights = []
    if os.path.exists(HEIGHTS):
        for line in open(HEIGHTS, encoding="utf-8"):
            if line.startswith("#"):
                continue
            parts = line.split()
            if len(parts) == 2 and int(parts[0]) in used:
                heights.append(f"\t[{parts[0]}] = {parts[1]},")
    missing = len(used) - len(heights)

    body = HEADER + "\n".join(r[1] for r in rows) + "\n}, {\n" + "\n".join(sorted(
        heights, key=lambda h: int(re.search(r'\[(\d+)\]', h).group(1)))) + "\n})\n"
    if not args.dry_run:
        with open(OUT, "w", encoding="utf-8", newline="\r\n") as fh:
            fh.write(body)

    print(f"npcs corrected : {total_fixed}")
    print(f"npcs cleared   : {total_cleared} (placeholder with no AtlasLoot match)")
    print(f"files skipped  : {skipped}")
    print(f"{OUT}: {len(rows)} encounters with display ids, {len(heights)} model heights")
    if missing:
        print(f"  [warn] {missing} display id(s) have no height; regenerate "
              f"{os.path.basename(HEIGHTS)} (see tools/README.md)")
    if no_display:
        print(f"  [note] {len(no_display)} matched encounters have no DisplayIDs")


if __name__ == "__main__":
    main()
