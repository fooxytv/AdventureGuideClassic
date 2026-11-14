#!/usr/bin/env python3
"""
Questie -> Adventure Guide Classic dungeon quest tool.

Generates `data/Quests/<flavour>/<Dungeon>.lua`, one QuestService.Register call per
dungeon, from a local Questie checkout. Forever's new dungeons are not in Questie; they
come from a QuestieDB checkout instead, which keeps them as layers of corrections.

Join key: Questie's dungeon AreaTable id == the quest's `zoneOrSort` (field 17).
Our own instance files supply the dungeon names; Questie's Zones/data/dungeons.lua
supplies the area ids.

Rewards are not in Questie's quest table. They are in its *item* table, where field 6
(`questRewards`) lists the quests an item is a reward for, so this inverts that.

Usage:
    python tools/gen_dungeon_quests.py                    # write data/Quests/era/*.lua
    python tools/gen_dungeon_quests.py --flavour forever  # write data/Quests/forever/*.lua
    python tools/gen_dungeon_quests.py --dry-run          # report coverage, write nothing
"""
import argparse
import io
import os
import re
import sys

Q_ROOT = os.path.expanduser("~/workspaces/home-projects/Questie")
QDB_ROOT = os.path.expanduser("~/workspaces/home-projects/QuestieDB")
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


def rows(path, root=Q_ROOT):
    """Yield (id, fields) for each `[id] = {...},` line of a Questie database file."""
    full = os.path.join(root, path)
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


def load_area_maps(path=os.path.join(Q_ROOT, "Database/Zones/data/areaIdToUiMapId.lua")):
    """AreaTable id -> uiMapID, so the guide can open the map at a quest giver's zone."""
    if not os.path.exists(path):
        return {}
    text = io.open(path, encoding="utf-8", errors="replace").read()
    maps = {}
    for m in re.finditer(r"^\s*\[(\d+)\]\s*=\s*(\d+)", text, re.M):
        maps[int(m.group(1))] = int(m.group(2))
    return maps


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


def load_quests_by_area(rewards, npcs, zone_names, displays, area_maps):
    by_area = {}
    for quest_id, f in rows("Database/Classic/classicQuestDB.lua"):
        area = field(f, 17)
        if not area or not area.isdigit():
            continue

        started_by = field(f, 2)
        start_name, start_zone, start_id, start_display = None, None, None, None
        start_map = None
        if started_by:
            creatures = re.findall(r"\d+", started_by.split("}")[0])
            if creatures:
                start_id = int(creatures[0])
                name, zone = npcs.get(start_id, (None, None))
                start_name = name or None
                start_zone = zone_names.get(zone) if zone else None
                start_display = displays.get(start_id)
                start_map = area_maps.get(zone) if zone else None

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
            "startZoneMap": start_map if start_zone else None,
            "rewards": sorted(rewards.get(quest_id, [])),
        })
    return by_area


def lua_string(value):
    return '"%s"' % value.replace("\\", "\\\\").replace('"', '\\"')


# --- Forever, from a QuestieDB checkout ---------------------------------------

FOREVER = "src/corrections/Forever/"
FOREVER_ZONES = "support/Forever/Zones/"

# Instances QuestieDB's dungeon list does not carry yet, by the area it files them under.
FOREVER_EXTRA_AREAS = {
    "Shaper's Terrace": [16985],
    "Krol'Dok Stronghold": [17780],
}

# Forever adds a Skyborne race to each side, on bits the Classic masks do not reach.
FOREVER_SIDES = (
    ("Alliance", RACES_ALLIANCE | 1 << 32),
    ("Horde", RACES_HORDE | 1 << 33),
)
RACE_SIDES = {
    "HUMAN": "Alliance", "DWARF": "Alliance", "NIGHT_ELF": "Alliance", "GNOME": "Alliance",
    "ORC": "Horde", "UNDEAD": "Horde", "TAUREN": "Horde", "TROLL": "Horde",
}

LUA_STRING = r'"(?:\\.|[^"\\])*"' + "|" + r"'(?:\\.|[^'\\])*'"
LUA_COMMENT = re.compile("(%s)|--\\[\\[.*?\\]\\]|--[^\n]*" % LUA_STRING, re.S)
STRUCTURE = re.compile(LUA_STRING + "|[{},]")
ENTRY = re.compile(r"\[(\d+)\]\s*=\s*\{")
KEYED = re.compile(r"\s*\[\w+Keys\.(\w+)\]\s*=\s*(.*)", re.S)


def qdb_text(path):
    full = os.path.join(QDB_ROOT, path)
    if not os.path.exists(full):
        sys.exit("QuestieDB file not found: %s" % full)
    return io.open(full, encoding="utf-8", errors="replace").read()


def split_fields(text, start):
    """
    The comma-separated pieces of the table opening at text[start], and the index just
    past its closing brace. A brace or comma inside a string is text, not structure.
    """
    pieces, depth, cut = [], 0, start + 1
    for m in STRUCTURE.finditer(text, start):
        token = m.group()
        if token == "{":
            depth += 1
        elif token == "}":
            depth -= 1
            if depth == 0:
                pieces.append(text[cut:m.start()])
                return pieces, m.end()
        elif token == "," and depth == 1:
            pieces.append(text[cut:m.start()])
            cut = m.end()
    sys.exit("unbalanced Lua table at offset %d" % start)


def corrections(path):
    """
    One layer: id -> {key: raw value}, from a QuestieDB corrections file.

    Those are written `[id] = { [questKeys.name] = "...", ... }`. Comments go first,
    because the relation traces park whole entries in them.
    """
    text = LUA_COMMENT.sub(lambda m: m.group(1) or "", qdb_text(path))
    layer, pos = {}, 0
    while True:
        m = ENTRY.search(text, pos)
        if not m:
            return layer
        pieces, pos = split_fields(text, m.end() - 1)
        fields = {}
        for piece in pieces:
            keyed = KEYED.match(piece)
            if keyed:
                fields[keyed.group(1)] = keyed.group(2).strip()
        if fields:
            layer.setdefault(int(m.group(1)), {}).update(fields)


def row_layer(path, keys):
    """The raw database underneath the corrections, as a layer of the named fields."""
    layer = {}
    for entity, f in rows(path, QDB_ROOT):
        fields = {key: field(f, index) for key, index in keys.items()}
        layer[entity] = {key: value for key, value in fields.items() if value is not None}
    return layer


def last(layers, entity, key):
    """A plain field as the last layer to set it left it."""
    for layer in reversed(layers):
        if key in layer.get(entity, {}):
            return layer[entity][key]
    return None


def id_lists(raw, slots):
    """`{1, 2}` as one list of ids, or `{{npcs}, {objects}, {items}}` as one per slot."""
    if slots > 1 and "{" in raw:
        pieces, _ = split_fields(raw, raw.index("{"))
    else:
        pieces = [raw]
    lists = [[int(x) for x in re.findall(r"\d+", piece)] for piece in pieces]
    return (lists + [[] for _ in range(slots)])[:slots]


def fold_ids(layers, entity, key, slots=1):
    """A list field after every layer. Each applies `key_remove`, `key`, then `key_add`."""
    value = [[] for _ in range(slots)]
    for layer in layers:
        fields = layer.get(entity, {})
        for suffix in ("_remove", "", "_add"):
            raw = fields.get(key + suffix)
            if raw is None:
                continue
            for slot, ids in enumerate(id_lists(raw, slots)):
                if suffix == "_remove":
                    value[slot] = [i for i in value[slot] if i not in ids]
                elif suffix == "_add":
                    value[slot] += [i for i in ids if i not in value[slot]]
                else:
                    value[slot] = ids
    return value


def forever_dungeons():
    """(area id, name) for each dungeon QuestieDB lists."""
    for m in re.finditer(r'\[(\d+)\]\s*=\s*\{"([^"]+)"', qdb_text(FOREVER_ZONES + "dungeons.lua")):
        yield int(m.group(1)), m.group(2)


def load_forever_zones():
    """(`zoneIDs.NAME` -> area id, area id -> readable name)."""
    symbols = {m.group(1): int(m.group(2)) for m in re.finditer(
        r"^\s*([A-Z][A-Z0-9_]*)\s*=\s*(\d+)", qdb_text("src/corrections/enum/zones.lua"), re.M)}
    names = {}
    for symbol, area in symbols.items():
        names.setdefault(area, symbol.replace("_", " ").title())
    names.update(forever_dungeons())
    # The map table's comments spell each area the way the game does, apostrophes and all.
    for m in re.finditer(r"^\s*\[(\d+)\]\s*=\s*[1-9]\d*,\s*--\s*(.+?)\s*(?:->.*)?$",
                         qdb_text(FOREVER_ZONES + "areaIdToUiMapId.lua"), re.M):
        names[int(m.group(1))] = m.group(2)
    return symbols, names


def load_forever_areas():
    """Dungeon name -> [area id, sub-area ids...], for the dungeons QuestieDB lists."""
    areas = {name: list(ids) for name, ids in FOREVER_EXTRA_AREAS.items()}
    for area, name in forever_dungeons():
        areas.setdefault(name, []).append(area)
    children = {}
    for m in re.finditer(r"^\s*\[(\d+)\]\s*=\s*(\d+)",
                         qdb_text(FOREVER_ZONES + "subZoneToParentZone.lua"), re.M):
        children.setdefault(int(m.group(2)), []).append(int(m.group(1)))
    for ids in areas.values():
        ids.extend(child for area in list(ids) for child in children.get(area, []))
    return areas


def forever_side(races):
    """Alliance, Horde or None, from a race mask written as a number or as raceIDs names."""
    sides = set()
    for term in (races or "").split("+"):
        term = term.strip().replace("raceIDs.", "")
        if term.isdigit():
            sides.update(side for side, mask in FOREVER_SIDES if int(term) & mask)
        elif term in RACE_SIDES:
            sides.add(RACE_SIDES[term])
        elif "ALLIANCE" in term:
            sides.add("Alliance")
        elif "HORDE" in term:
            sides.add("Horde")
        elif term not in ("", "NONE"):
            sys.exit("unknown race in requiredRaces: %s" % races)
    return sides.pop() if len(sides) == 1 else None


def names_dungeon(text, dungeon):
    """Whether a quest's objectives name the dungeon, give or take a leading The."""
    return re.sub(r"^the\s+", "", dungeon.lower()) in text.lower()


def load_forever(displays):
    """
    (areas, quests by area, unfiled quests) for Forever.

    QuestieDB builds each entity from layers, and a later one overrides: the raw
    database, a generated base, what players' traces saw, then hand-written fixes.

    Unfiled quests are Forever's own with no zone recorded. The quests for four of
    the new dungeons are all like that, so main() also takes one whose objectives
    name the dungeon.
    """
    def layers(kind, fixes, keys):
        return [
            row_layer("data/Forever/forever%sDB.lua" % kind, keys),
            corrections(FOREVER + "generated/foreverBase%s.lua" % kind),
            corrections(FOREVER + "traces/forever%sTraces.lua" % kind),
            corrections(FOREVER + fixes),
        ]

    quests = layers("Quest", "foreverQuestFixes.lua", {
        "name": 1, "startedBy": 2, "requiredLevel": 4, "questLevel": 5,
        "requiredRaces": 6, "objectivesText": 8, "zoneOrSort": 17,
    })
    npcs = layers("Npc", "foreverNPCFixes.lua", {"name": 1, "zoneID": 9})
    items = layers("Item", "foreverItemFixes.lua", {"questRewards": 6})

    symbols, zone_names = load_forever_zones()
    area_maps = load_area_maps(os.path.join(QDB_ROOT, FOREVER_ZONES, "areaIdToUiMapId.lua"))

    def zone_of(raw):
        raw = (raw or "").replace("zoneIDs.", "")
        return symbols.get(raw) or (int(raw) if raw.isdigit() else None)

    def number(raw):
        return int(raw) if raw and raw.isdigit() else None

    rewards = {}
    for item in sorted(set().union(*items)):
        for quest in fold_ids(items, item, "questRewards")[0]:
            rewards.setdefault(quest, []).append(item)

    by_area, unfiled = {}, []
    for quest_id in sorted(set().union(*quests)):
        name = unquote(last(quests, quest_id, "name"))
        if not name:
            continue

        start_id = next(iter(fold_ids(quests, quest_id, "startedBy", 3)[0]), None)
        start_name = unquote(last(npcs, start_id, "name")) or None
        zone = zone_of(last(npcs, start_id, "zoneID")) if start_name else None
        start_zone = zone_names.get(zone)

        objectives = last(quests, quest_id, "objectivesText") or ""
        quest = {
            "id": quest_id,
            "name": name,
            "level": number(last(quests, quest_id, "questLevel")),
            "minLevel": number(last(quests, quest_id, "requiredLevel")),
            "side": forever_side(last(quests, quest_id, "requiredRaces")),
            "startedBy": start_name,
            "startedById": start_id if start_name else None,
            "startedByDisplay": displays.get(start_id) if start_name else None,
            "startZone": start_zone,
            "startZoneMap": area_maps.get(zone) if start_zone else None,
            "rewards": sorted(rewards.get(quest_id, [])),
            "text": " ".join(unquote(s) for s in re.findall(LUA_STRING, objectives)),
        }

        filed = last(quests, quest_id, "zoneOrSort")
        if zone_of(filed):
            by_area.setdefault(zone_of(filed), []).append(quest)
        elif not filed and quest_id not in quests[0]:
            unfiled.append(quest)
    return load_forever_areas(), by_area, unfiled


def render(dungeon_name, quests, source="Questie"):
    out = [
        "--[[",
        "Copyright (C) 2023 FooxyTV (simon@fooxy.tv)",
        "All rights reserved.",
        "",
        "Programming by: FooxyTV",
        "",
        "Dungeon quests for %s." % dungeon_name,
        "",
        "Generated by tools/gen_dungeon_quests.py from a local %s checkout. Do not" % source,
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
        if q["startZoneMap"]:
            parts.append("startZoneMap = %d" % q["startZoneMap"])
        if q["startedById"]:
            parts.append("startedById = %d" % q["startedById"])
        if q["startedByDisplay"]:
            parts.append("startedByDisplay = %d" % q["startedByDisplay"])
        if q["rewards"]:
            parts.append("rewards = { %s }" % ", ".join(str(i) for i in q["rewards"]))
        out.append("\t{")
        out.extend("\t\t%s," % part for part in parts)
        out.append("\t},")
    out.append("})")
    return "\r\n".join(out) + "\r\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--flavour", default="era")
    args = ap.parse_args()

    displays = load_npc_displays()
    if args.flavour == "forever":
        source = "QuestieDB"
        areas, by_area, unfiled = load_forever(displays)
    else:
        source, unfiled = "Questie", []
        areas = load_dungeon_areas()
        zone_names = load_zone_names()
        npcs = load_npcs()
        rewards = load_quest_rewards()
        area_maps = load_area_maps()
        by_area = load_quests_by_area(rewards, npcs, zone_names, displays, area_maps)

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
        named = [q for q in unfiled if names_dungeon(q["text"], dungeon)]
        if not key and not named:
            skipped.append((dungeon, "no %s dungeon entry" % source))
            continue

        quests = [q for area in areas.get(key, []) for q in by_area.get(area, [])] + named
        quests.sort(key=lambda q: (q["level"] or 0, q["name"]))
        if not quests:
            skipped.append((dungeon, "%s lists no quests for area %d" % (source, areas[key][0])))
            continue

        total += len(quests)
        written += 1
        note = "  (%d by name)" % len(named) if named else ""
        print("%-30s %3d quests%s" % (dungeon, len(quests), note))
        if not args.dry_run:
            path = os.path.join(out_dir, filename)
            io.open(path, "wb").write(render(dungeon, quests, source).encode("utf-8"))

    print("\n%d dungeons, %d quests%s" % (written, total, " (dry run)" if args.dry_run else ""))
    for dungeon, why in skipped:
        note = " (expected: Season of Discovery)" if dungeon in NO_QUESTIE_ENTRY else ""
        print("  skipped %-28s %s%s" % (dungeon, why, note))


if __name__ == "__main__":
    main()
