#!/usr/bin/env python3
"""
Questie -> Adventure Guide Classic dungeon quest tool.

Generates `data/Quests/<flavour>/<Dungeon>.lua`, one QuestService.Register call per
dungeon, from a local Questie checkout.

Join key: Questie's dungeon AreaTable id == the quest's `zoneOrSort` (field 17).
Our own instance files supply the dungeon names; Questie's Zones/data/dungeons.lua
supplies the area ids.

Rewards are not in Questie's quest table. They are in its *item* table, where field 6
(`questRewards`) lists the quests an item is a reward for, so this inverts that.

Usage:
    python tools/gen_dungeon_quests.py            # write data/Quests/era/*.lua
    python tools/gen_dungeon_quests.py --dry-run  # report coverage, write nothing
"""
import argparse
import io
import os
import re
import sys

Q_ROOT = os.path.expanduser("~/workspaces/home-projects/Questie")
AG_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# npc id -> display id, so the Quests tab can show the giver's model on hover.
NPC_MODELS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "npc_models.tsv")

# Questie names a few dungeons differently from us.
DUNGEON_ALIASES = {
    "Stormwind Stockade": "The Stockade",
}

# Season of Discovery instances, which Questie's Classic dungeon list does not carry.
# Named so a missing match reads as expected rather than as a fault.
NO_QUESTIE_ENTRY = {"Demon Fall Canyon", "Karazhan Crypts"}

RACES_ALLIANCE = 1 | 4 | 8 | 64      # Human, Dwarf, Night Elf, Gnome
RACES_HORDE = 2 | 16 | 32 | 128      # Orc, Undead, Tauren, Troll


def split_top(row):
    """Split a Lua table body on top-level commas only."""
    out, depth, cur = [], 0, ""
    for ch in row:
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        if ch == "," and depth == 0:
            out.append(cur)
            cur = ""
        else:
            cur += ch
    out.append(cur)
    return out


def rows(path):
    """Yield (id, fields) for each `[id] = {...},` line of a Questie database file."""
    full = os.path.join(Q_ROOT, path)
    if not os.path.exists(full):
        sys.exit("Questie file not found: %s" % full)
    text = io.open(full, encoding="utf-8", errors="replace").read()
    for m in re.finditer(r"^\[(\d+)\] = \{(.*)\},\s*$", text, re.M):
        yield int(m.group(1)), split_top(m.group(2))


def field(fields, index):
    """1-based Questie field, or None when absent or nil."""
    if len(fields) < index:
        return None
    value = fields[index - 1].strip()
    return None if value in ("", "nil") else value


def unquote(value):
    """
    A Questie string with its Lua quoting removed.

    Names are single-quoted in the NPC table and double-quoted in the quest table, and
    an apostrophe inside a single-quoted one arrives escaped, as in Zaetar's Spirit.
    Stripping the outer quotes alone leaves that backslash in the name.
    """
    if not value:
        return ""
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "'\"":
        value = value[1:-1]
    return value.replace("\\'", "'").replace('\\"', '"').replace("\\\\", "\\")


def load_dungeon_areas():
    """
    Dungeon name -> [areaID, subAreaID...].

    Ids at 10000 and above are Questie's synthetic sub-area entries, and some names
    appear twice because a later expansion revisited the dungeon, so the real Classic
    id is the lowest one below that line.
    """
    path = os.path.join(Q_ROOT, "Database/Zones/data/dungeons.lua")
    text = io.open(path, encoding="utf-8", errors="replace").read()
    areas = {}
    for m in re.finditer(r'\[(\d+)\]\s*=\s*\{"([^"]+)",(nil|\{[\d,]*\})', text):
        area_id, name = int(m.group(1)), m.group(2)
        if area_id >= 10000:
            continue
        subs = [int(x) for x in re.findall(r"\d+", m.group(3))]
        if name not in areas or area_id < areas[name][0]:
            areas[name] = [area_id] + subs
    return areas


def load_zone_names():
    """Zone id -> readable name, from Questie's zoneIDs enum."""
    path = os.path.join(Q_ROOT, "Database/Zones/data/zoneIds.lua")
    text = io.open(path, encoding="utf-8", errors="replace").read()
    names = {}
    for m in re.finditer(r"^\s*([A-Z][A-Z0-9_]*)\s*=\s*(\d+)", text, re.M):
        zone_id = int(m.group(2))
        if zone_id not in names:
            names[zone_id] = m.group(1).replace("_", " ").title()
    return names


def load_npcs():
    """NPC id -> (name, zone id)."""
    npcs = {}
    for npc_id, f in rows("Database/Classic/classicNpcDB.lua"):
        zone = field(f, 9)
        npcs[npc_id] = (
            unquote(field(f, 1)),
            int(zone) if zone and zone.isdigit() else None,
        )
    return npcs


def load_npc_displays():
    """NPC id -> display id, from tools/npc_models.tsv."""
    displays = {}
    if not os.path.exists(NPC_MODELS):
        return displays
    for line in io.open(NPC_MODELS, encoding="utf-8", errors="replace"):
        if line.startswith("#"):
            continue
        parts = line.rstrip("\r\n").split("\t")
        if len(parts) < 2 or not parts[0].isdigit() or not parts[1].isdigit():
            continue
        display = int(parts[1])
        if display:
            displays[int(parts[0])] = display
    return displays


def load_quest_rewards():
    """Quest id -> [reward item id...], inverted out of the item table."""
    rewards = {}
    for item_id, f in rows("Database/Classic/classicItemDB.lua"):
        quests = field(f, 6)
        if not quests or not quests.startswith("{"):
            continue
        for quest_id in re.findall(r"\d+", quests):
            rewards.setdefault(int(quest_id), []).append(item_id)
    return rewards


def faction_for(races):
    if not races:
        return None
    races = int(races)
    if races and not races & RACES_HORDE:
        return "Alliance"
    if races and not races & RACES_ALLIANCE:
        return "Horde"
    return None      # both, so no marker needed


def load_quests_by_area(rewards, npcs, zone_names, displays):
    by_area = {}
    for quest_id, f in rows("Database/Classic/classicQuestDB.lua"):
        area = field(f, 17)
        if not area or not area.isdigit():
            continue

        started_by = field(f, 2)
        start_name, start_zone, start_id, start_display = None, None, None, None
        if started_by:
            creatures = re.findall(r"\d+", started_by.split("}")[0])
            if creatures:
                start_id = int(creatures[0])
                name, zone = npcs.get(start_id, (None, None))
                start_name = name or None
                start_zone = zone_names.get(zone) if zone else None
                start_display = displays.get(start_id)

        level = field(f, 5)
        min_level = field(f, 4)
        by_area.setdefault(int(area), []).append({
            "id": quest_id,
            "name": unquote(field(f, 1)),
            "level": int(level) if level and level.isdigit() else None,
            "minLevel": int(min_level) if min_level and min_level.isdigit() else None,
            "side": faction_for(field(f, 6)),
            "startedBy": start_name,
            "startedById": start_id if start_name else None,
            "startedByDisplay": start_display if start_name else None,
            "startZone": start_zone,
            "rewards": sorted(rewards.get(quest_id, [])),
        })
    return by_area


def lua_string(value):
    return '"%s"' % value.replace("\\", "\\\\").replace('"', '\\"')


def render(dungeon_name, quests):
    out = [
        "--[[",
        "Copyright (C) 2023 FooxyTV (simon@fooxy.tv)",
        "All rights reserved.",
        "",
        "Programming by: FooxyTV",
        "",
        "Dungeon quests for %s." % dungeon_name,
        "",
        "Generated by tools/gen_dungeon_quests.py from a local Questie checkout. Do not",
        "edit by hand; re-run the tool instead.",
        "]]",
        "select(2, ...).SetupGlobalFacade()",
        "",
        "QuestService.Register(%s, {" % lua_string(dungeon_name),
    ]
    for q in quests:
        parts = ["id = %d" % q["id"], "name = %s" % lua_string(q["name"])]
        if q["level"]:
            parts.append("level = %d" % q["level"])
        if q["minLevel"]:
            parts.append("minLevel = %d" % q["minLevel"])
        if q["side"]:
            parts.append("side = %s" % lua_string(q["side"]))
        if q["startedBy"]:
            parts.append("startedBy = %s" % lua_string(q["startedBy"]))
        if q["startZone"]:
            parts.append("startZone = %s" % lua_string(q["startZone"]))
        if q["startedById"]:
            parts.append("startedById = %d" % q["startedById"])
        if q["startedByDisplay"]:
            parts.append("startedByDisplay = %d" % q["startedByDisplay"])
        if q["rewards"]:
            parts.append("rewards = { %s }" % ", ".join(str(i) for i in q["rewards"]))
        out.append("\t{ " + ", ".join(parts) + " },")
    out.append("})")
    return "\r\n".join(out) + "\r\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--flavour", default="era")
    args = ap.parse_args()

    areas = load_dungeon_areas()
    zone_names = load_zone_names()
    npcs = load_npcs()
    rewards = load_quest_rewards()
    displays = load_npc_displays()
    by_area = load_quests_by_area(rewards, npcs, zone_names, displays)

    src_dir = os.path.join(AG_ROOT, "data", "Dungeons", args.flavour)
    out_dir = os.path.join(AG_ROOT, "data", "Quests", args.flavour)
    if not args.dry_run:
        os.makedirs(out_dir, exist_ok=True)

    total, written, skipped = 0, 0, []
    for filename in sorted(os.listdir(src_dir)):
        if not filename.endswith(".lua"):
            continue
        text = io.open(os.path.join(src_dir, filename), encoding="utf-8",
                       errors="replace").read()
        m = re.search(r'name = "([^"]+)"', text)
        if not m:
            continue
        dungeon = m.group(1)

        key = DUNGEON_ALIASES.get(dungeon, dungeon)
        if key not in areas:
            key = next((k for k in areas if k.lower() == key.lower()), None)
        if not key:
            skipped.append((dungeon, "no Questie dungeon entry"))
            continue

        quests = [q for area in areas[key] for q in by_area.get(area, [])]
        quests.sort(key=lambda q: (q["level"] or 0, q["name"]))
        if not quests:
            skipped.append((dungeon, "Questie lists no quests for area %d" % areas[key][0]))
            continue

        total += len(quests)
        written += 1
        print("%-30s %3d quests" % (dungeon, len(quests)))
        if not args.dry_run:
            path = os.path.join(out_dir, filename)
            io.open(path, "wb").write(render(dungeon, quests).encode("utf-8"))

    print("\n%d dungeons, %d quests%s" % (written, total, " (dry run)" if args.dry_run else ""))
    for dungeon, why in skipped:
        note = " (expected: Season of Discovery)" if dungeon in NO_QUESTIE_ENTRY else ""
        print("  skipped %-28s %s%s" % (dungeon, why, note))


if __name__ == "__main__":
    main()
