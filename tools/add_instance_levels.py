#!/usr/bin/env python3
"""Add level metadata to the dungeon/raid data files in data/.

Suggested Content needs to know which instances a character is in range for, but the
instance tables only carry name/instanceID/mapID/loot. This fills in:

    levelRange = { min = 13, max = 18 },
    recommendedLevel = 15,
    faction = "Horde",
    continent = "Kalimdor",

Values live in the INSTANCES table below, keyed by path so that the dungeon and raid
versions of Blackfathom Deeps, Gnomeregan and the Temple of Atal'hakkar stay distinct.

Usage:
    python tools/add_instance_levels.py check     # report, touch nothing
    python tools/add_instance_levels.py apply     # write the fields in
    python tools/add_instance_levels.py apply --force   # overwrite existing values

`apply` is idempotent: a file that already has levelRange is skipped unless --force.

Level ranges are the commonly accepted ones for each instance. The entries marked
UNCERTAIN below are Season of Discovery content whose ranges shift with the season's
phase level cap -- review those before trusting them.
"""

import argparse
import os
import re
import sys

AG_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# key: path relative to the repo root
# name:      expected instance name, verified against the file
# min/max:   the level range the instance is intended for
# rec:       the level at which to recommend it
# faction:   None when both factions realistically run it
# continent: "Eastern Kingdoms" | "Kalimdor" | "Outland"
# uncertain: flagged in output as needing review
INSTANCES = {
    # -- Classic Era dungeons ------------------------------------------------
    "data/Dungeons/era/Ragefire_Chasm.lua": dict(
        name="Ragefire Chasm", min=13, max=18, rec=15,
        faction="Horde", continent="Kalimdor"),
    "data/Dungeons/era/The_Deadmines.lua": dict(
        name="The Deadmines", min=15, max=25, rec=18,
        faction="Alliance", continent="Eastern Kingdoms"),
    "data/Dungeons/era/Wailing_Caverns.lua": dict(
        name="Wailing Caverns", min=15, max=25, rec=19,
        faction="Horde", continent="Kalimdor"),
    "data/Dungeons/era/Shadowfang_Keep.lua": dict(
        name="Shadowfang Keep", min=18, max=25, rec=22,
        faction=None, continent="Eastern Kingdoms"),
    "data/Dungeons/era/Blackfathom_Deeps.lua": dict(
        name="Blackfathom Deeps", min=20, max=30, rec=24,
        faction=None, continent="Kalimdor"),
    "data/Dungeons/era/The_Stockade.lua": dict(
        name="Stormwind Stockade", min=22, max=30, rec=25,
        faction="Alliance", continent="Eastern Kingdoms"),
    "data/Dungeons/era/Gnomeregan.lua": dict(
        name="Gnomeregan", min=24, max=34, rec=29,
        faction=None, continent="Eastern Kingdoms"),
    "data/Dungeons/era/Razorfen_Kraul.lua": dict(
        name="Razorfen Kraul", min=25, max=35, rec=30,
        faction=None, continent="Kalimdor"),
    "data/Dungeons/era/Scarlet_Monastery.lua": dict(
        name="Scarlet Monastery", min=28, max=45, rec=34,
        faction=None, continent="Eastern Kingdoms"),
    "data/Dungeons/era/Maraudon.lua": dict(
        name="Maraudon", min=30, max=40, rec=35,
        faction=None, continent="Kalimdor"),
    "data/Dungeons/era/Razorfen_Downs.lua": dict(
        name="Razorfen Downs", min=33, max=40, rec=37,
        faction=None, continent="Kalimdor"),
    "data/Dungeons/era/Uldaman.lua": dict(
        name="Uldaman", min=37, max=45, rec=41,
        faction=None, continent="Eastern Kingdoms"),
    "data/Dungeons/era/Zul_Farrak.lua": dict(
        name="Zul'Farrak", min=42, max=50, rec=45,
        faction=None, continent="Kalimdor"),
    "data/Dungeons/era/The_Temple_of_Atal_hakkar.lua": dict(
        name="The Temple of Atal'hakkar", min=45, max=55, rec=50,
        faction=None, continent="Eastern Kingdoms"),
    "data/Dungeons/era/Blackrock_Depths.lua": dict(
        name="Blackrock Depths", min=52, max=60, rec=55,
        faction=None, continent="Eastern Kingdoms"),
    "data/Dungeons/era/Dire_Maul.lua": dict(
        name="Dire Maul", min=55, max=60, rec=57,
        faction=None, continent="Kalimdor"),
    "data/Dungeons/era/Scholomance.lua": dict(
        name="Scholomance", min=55, max=60, rec=58,
        faction=None, continent="Eastern Kingdoms"),
    "data/Dungeons/era/Stratholme.lua": dict(
        name="Stratholme", min=55, max=60, rec=58,
        faction=None, continent="Eastern Kingdoms"),
    "data/Dungeons/era/Blackrock_Spire.lua": dict(
        name="Blackrock Spire", min=55, max=60, rec=58,
        faction=None, continent="Eastern Kingdoms"),
    "data/Dungeons/era/Demon_Fall_Canyon.lua": dict(
        name="Demon Fall Canyon", min=55, max=60, rec=60,
        faction=None, continent="Kalimdor", uncertain=True),
    "data/Dungeons/era/Karazhan_Crypts.lua": dict(
        name="Karazhan Crypts", min=60, max=60, rec=60,
        faction=None, continent="Eastern Kingdoms", uncertain=True),

    # -- Burning Crusade dungeons --------------------------------------------
    "data/Dungeons/tbc/Hellfire_Ramparts.lua": dict(
        name="Hellfire Ramparts", min=59, max=62, rec=60,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/The_Blood_Furnace.lua": dict(
        name="The Blood Furnace", min=60, max=63, rec=61,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/The_Slave_Pens.lua": dict(
        name="The Slave Pens", min=61, max=64, rec=62,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/The_Underbog.lua": dict(
        name="The Underbog", min=62, max=65, rec=63,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/Mana_Tombs.lua": dict(
        name="Mana-Tombs", min=63, max=66, rec=64,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/Auchenai_Crypts.lua": dict(
        name="Auchenai Crypts", min=64, max=67, rec=65,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/Sethekk_Halls.lua": dict(
        name="Sethekk Halls", min=65, max=68, rec=67,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/Old_Hillsbrad_Foothills.lua": dict(
        name="Old Hillsbrad Foothills", min=66, max=69, rec=68,
        faction=None, continent="Kalimdor"),
    "data/Dungeons/tbc/The_Black_Morass.lua": dict(
        name="The Black Morass", min=68, max=70, rec=70,
        faction=None, continent="Kalimdor"),
    "data/Dungeons/tbc/The_Steamvault.lua": dict(
        name="The Steamvault", min=69, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/Shadow_Labyrinth.lua": dict(
        name="Shadow Labyrinth", min=69, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/The_Shattered_Halls.lua": dict(
        name="The Shattered Halls", min=69, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/The_Mechanar.lua": dict(
        name="The Mechanar", min=69, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/The_Botanica.lua": dict(
        name="The Botanica", min=70, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/The_Arcatraz.lua": dict(
        name="The Arcatraz", min=70, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Dungeons/tbc/Magisters_Terrace.lua": dict(
        name="Magister's Terrace", min=70, max=70, rec=70,
        faction=None, continent="Eastern Kingdoms"),

    # -- Classic Era raids ---------------------------------------------------
    "data/Raids/era/Blackfathom_Deeps.lua": dict(
        name="Blackfathom Deeps", min=25, max=25, rec=25,
        faction=None, continent="Kalimdor", uncertain=True),
    "data/Raids/era/Gnomeregan.lua": dict(
        name="Gnomeregan", min=40, max=40, rec=40,
        faction=None, continent="Eastern Kingdoms", uncertain=True),
    "data/Raids/era/The_Temple_of_Atal_hakkar.lua": dict(
        name="The Temple of Atal'hakkar", min=50, max=50, rec=50,
        faction=None, continent="Eastern Kingdoms", uncertain=True),
    "data/Raids/era/Molten_Core.lua": dict(
        name="Molten Core", min=60, max=60, rec=60,
        faction=None, continent="Eastern Kingdoms"),
    "data/Raids/era/Onyxias_Lair.lua": dict(
        name="Onyxia's Lair", min=60, max=60, rec=60,
        faction=None, continent="Kalimdor"),
    "data/Raids/era/Blackwing_Lair.lua": dict(
        name="Blackwing Lair", min=60, max=60, rec=60,
        faction=None, continent="Eastern Kingdoms"),
    "data/Raids/era/Zul_Gurub.lua": dict(
        name="Zul'Gurub", min=60, max=60, rec=60,
        faction=None, continent="Eastern Kingdoms"),
    "data/Raids/era/Ruins_of_Ahn_Qiraj.lua": dict(
        name="Ruins of Ahn'Qiraj", min=60, max=60, rec=60,
        faction=None, continent="Kalimdor"),
    "data/Raids/era/Temple_of_Ahn_Qiraj.lua": dict(
        name="Temple of Ahn'Qiraj", min=60, max=60, rec=60,
        faction=None, continent="Kalimdor"),
    "data/Raids/era/Naxxramas.lua": dict(
        name="Naxxramas", min=60, max=60, rec=60,
        faction=None, continent="Eastern Kingdoms"),
    "data/Raids/era/Scarlet_Enclave.lua": dict(
        name="Scarlet Enclave", min=60, max=60, rec=60,
        faction=None, continent="Eastern Kingdoms", uncertain=True),

    # -- Burning Crusade raids -----------------------------------------------
    "data/Raids/tbc/Karazhan.lua": dict(
        name="Karazhan", min=70, max=70, rec=70,
        faction=None, continent="Eastern Kingdoms"),
    "data/Raids/tbc/Gruuls_Lair.lua": dict(
        name="Gruul's Lair", min=70, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Raids/tbc/Magtheridons_Lair.lua": dict(
        name="Magtheridon's Lair", min=70, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Raids/tbc/Serpentshrine_Cavern.lua": dict(
        name="Serpentshrine Cavern", min=70, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Raids/tbc/The_Eye.lua": dict(
        name="The Eye", min=70, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Raids/tbc/Battle_for_Mount_Hyjal.lua": dict(
        name="The Battle for Mount Hyjal", min=70, max=70, rec=70,
        faction=None, continent="Kalimdor"),
    "data/Raids/tbc/Black_Temple.lua": dict(
        name="Black Temple", min=70, max=70, rec=70,
        faction=None, continent="Outland"),
    "data/Raids/tbc/Sunwell_Plateau.lua": dict(
        name="Sunwell Plateau", min=70, max=70, rec=70,
        faction=None, continent="Eastern Kingdoms"),
}

# The instance name sits at one tab of indentation; boss names are deeper, so this
# anchors on the instance itself.
# The repo is checked out with CRLF endings, so tolerate the trailing \r.
NAME_RE = re.compile(r'^\tname = "(?P<name>[^"]*)",[ \t]*\r?$', re.MULTILINE)
EXISTING_RE = re.compile(r'^\tlevelRange\s*=', re.MULTILINE)


def read_file(path):
    with open(path, "r", encoding="utf-8", newline="") as handle:
        return handle.read()


def write_file(path, text):
    with open(path, "w", encoding="utf-8", newline="") as handle:
        handle.write(text)


def build_block(meta, newline):
    lines = [
        "\tlevelRange = { min = %d, max = %d }," % (meta["min"], meta["max"]),
        "\trecommendedLevel = %d," % meta["rec"],
    ]
    if meta.get("faction"):
        lines.append('\tfaction = "%s",' % meta["faction"])
    lines.append('\tcontinent = "%s",' % meta["continent"])
    return "".join(line + newline for line in lines)


def strip_existing(text):
    """Remove a previously written block so --force rewrites cleanly."""
    pattern = re.compile(
        r'^\tlevelRange = \{[^\n]*\},[ \t]*\r?\n'
        r'(?:\trecommendedLevel = \d+,[ \t]*\r?\n)?'
        r'(?:\tfaction = "[^"]*",[ \t]*\r?\n)?'
        r'(?:\tcontinent = "[^"]*",[ \t]*\r?\n)?',
        re.MULTILINE,
    )
    return pattern.sub("", text, count=1)


def process(rel_path, meta, apply_changes, force):
    path = os.path.join(AG_ROOT, rel_path)
    if not os.path.exists(path):
        return "missing", "file not found"

    text = read_file(path)
    newline = "\r\n" if "\r\n" in text else "\n"

    if EXISTING_RE.search(text):
        if not force:
            return "skipped", "already has levelRange"
        text = strip_existing(text)

    match = NAME_RE.search(text)
    if not match:
        return "failed", "no instance name line found"

    found = match.group("name")
    note = ""
    if found != meta["name"]:
        note = 'name mismatch: file says "%s", table says "%s"' % (found, meta["name"])

    # Insert immediately after the name line, terminator included.
    newline_pos = text.find("\n", match.end())
    if newline_pos == -1:
        return "failed", "instance name line has no line ending"
    insert_at = newline_pos + 1

    updated = text[:insert_at] + build_block(meta, newline) + text[insert_at:]

    if apply_changes:
        write_file(path, updated)

    if meta.get("uncertain"):
        note = (note + "; " if note else "") + "UNCERTAIN - seasonal content, review"
    return "ok", note


def find_untracked():
    """Data files that exist on disk but have no entry in INSTANCES."""
    untracked = []
    for folder in ("data/Dungeons/era", "data/Dungeons/tbc",
                   "data/Raids/era", "data/Raids/tbc"):
        full = os.path.join(AG_ROOT, folder)
        if not os.path.isdir(full):
            continue
        for entry in sorted(os.listdir(full)):
            if not entry.endswith(".lua"):
                continue
            rel = "%s/%s" % (folder, entry)
            if rel not in INSTANCES:
                untracked.append(rel)
    return untracked


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("check", "apply"))
    parser.add_argument("--force", action="store_true",
                        help="overwrite level metadata that is already present")
    args = parser.parse_args()

    apply_changes = args.command == "apply"
    counts = {}
    problems = []

    for rel_path in sorted(INSTANCES):
        status, note = process(rel_path, INSTANCES[rel_path], apply_changes, args.force)
        counts[status] = counts.get(status, 0) + 1
        if status != "ok" or note:
            problems.append((status, rel_path, note))

    verb = "Wrote" if apply_changes else "Would write"
    print("%s level metadata for %d instances." % (verb, counts.get("ok", 0)))
    for status in ("skipped", "failed", "missing"):
        if counts.get(status):
            print("  %s: %d" % (status, counts[status]))

    if problems:
        print("\nNotes:")
        for status, rel_path, note in problems:
            print("  [%s] %s%s" % (status, rel_path, " - " + note if note else ""))

    untracked = find_untracked()
    if untracked:
        print("\nData files with no entry in INSTANCES:")
        for rel_path in untracked:
            print("  %s" % rel_path)

    if counts.get("failed") or counts.get("missing"):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
