#!/usr/bin/env python3
"""
AtlasLoot -> Adventure Guide Classic loot tool.

Two capabilities, one mapping:
  * audit    : compare a user boss's existing loot ids vs AtlasLoot, report missing/extra
  * generate : emit a `loot = { {id=..,seasonFilter=..}, .. }` array for a boss

Join key: user boss.encounterID  ==  AtlasLoot boss.npcID   (npcIDs are globally unique).
Fallback: normalized boss name.

AtlasLoot sources (season tag):
    data.lua       -> "all"   (Classic Era / Vanilla)
    data-tbc.lua   -> "tbc"
    data-sod.lua   -> "sod"   (Season of Discovery)
"""
import re, sys, os, argparse, json

AL_ROOT = os.path.expanduser("~/workspaces/home-projects/AllAtlasLoot")
DR_ROOT = os.path.join(AL_ROOT, "AtlasLootClassic_DungeonsAndRaids")
AG_ROOT = os.path.expanduser("~/workspaces/home-projects/AdventureGuideClassic/data")

SOURCES = {
    "all": os.path.join(DR_ROOT, "data.lua"),
    "tbc": os.path.join(DR_ROOT, "data-tbc.lua"),
    "sod": os.path.join(AL_ROOT, "TBC/AtlasLootClassic_DungeonsAndRaids/data-sod.lua"),
}
DROPRATE = os.path.join(DR_ROOT, "droprate.lua")
TOKEN_DATA = os.path.join(AL_ROOT, "AtlasLootClassic/Data/Token.lua")
COMPANION_DATA = os.path.join(AL_ROOT, "AtlasLootClassic/Data/Companion.lua")
# id \t quality \t classID \t inventorySlot \t name, sourced from Wowhead's item XML.
ITEM_META = os.path.join(os.path.dirname(os.path.abspath(__file__)), "item_meta.tsv")

# ---------- brace-aware helpers ----------
def match_brace(s, i):
    """i points at an opening '{'; return index just past its matching '}'."""
    depth = 0
    while i < len(s):
        c = s[i]
        if c == '{': depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0: return i + 1
        i += 1
    return len(s)

def norm(name):
    return re.sub(r'[^a-z0-9]', '', name.lower())

# ---------- parse AtlasLoot data-*.lua ----------
LEAF = re.compile(r'\{\s*\d+\s*,\s*(\d+)')  # { slot, itemID ...}  -> itemID

def parse_atlasloot(path):
    """Return list of bosses: {name, npcids:set[int], items:list[int]} across all instances."""
    if not os.path.exists(path): return []
    s = open(path, encoding='utf-8').read()
    bosses = []
    for m in re.finditer(r'\bdata\["([^"]+)"\]', s):
        inst = m.group(1)
        # find the instance table '{' after 'data["X"] ='
        eq = s.find('=', m.end())
        br = s.find('{', eq)
        end = match_brace(s, br)
        block = s[br:end]
        im = re.search(r'\bitems\s*=\s*\{', block)
        if not im: continue
        istart = block.find('{', im.end()-1)
        iend = match_brace(block, istart)
        items_body = block[istart+1:iend-1]
        # iterate top-level boss entries inside items = { ... }
        i = 0
        while i < len(items_body):
            if items_body[i] == '{':
                j = match_brace(items_body, i)
                entry = items_body[i:j]
                nm = re.search(r'name\s*=\s*AL\["([^"]+)"\]', entry) or \
                     re.search(r'name\s*=\s*"([^"]+)"', entry)
                name = nm.group(1) if nm else None
                npcids, npcorder = set(), []
                nm2 = re.search(r'npcID\s*=\s*\{([^}]*)\}', entry)
                if nm2:
                    npcorder = [int(x) for x in re.findall(r'\d+', nm2.group(1))]
                else:
                    nm3 = re.search(r'npcID\s*=\s*(\d+)', entry)
                    if nm3: npcorder = [int(nm3.group(1))]
                npcids = set(npcorder)
                # DisplayIDs = {{23404},{23428}} -- one inner list per npcID, in order.
                displayids = []
                dm = re.search(r'DisplayIDs\s*=\s*\{', entry)
                if dm:
                    dstart = entry.find('{', dm.end() - 1)
                    dbody = entry[dstart + 1:match_brace(entry, dstart) - 1]
                    for inner in re.finditer(r'\{([^}]*)\}', dbody):
                        displayids.append([int(x) for x in re.findall(r'\d+', inner.group(1))])
                is_extra = 'ExtraList' in entry and re.search(r'ExtraList\s*=\s*true', entry)
                # per-difficulty item lists: [XXX_DIFF] = { {slot,id}, ... }
                # items come ONLY from inside difficulty tables, so npcID={a,b}/DisplayIDs
                # can never be misread as item tuples.
                diffs = {}
                items, seen = [], set()
                for dm in re.finditer(r'\[([A-Z0-9_]+_DIFF)\]\s*=\s*\{', entry):
                    dstart = entry.find('{', dm.end()-1)
                    dend = match_brace(entry, dstart)
                    body = entry[dstart:dend]
                    ids = [int(x) for x in LEAF.findall(body)]
                    diffs[dm.group(1)] = ids
                    for i in ids:
                        if i not in seen: seen.add(i); items.append(i)
                bosses.append({"name": name, "npcids": npcids, "inst": inst,
                               "npcorder": npcorder, "displayids": displayids,
                               "items": items, "diffs": diffs, "extra": bool(is_extra)})
                i = j
            else:
                i += 1
    return bosses

def parse_droprate(path):
    s = open(path, encoding='utf-8').read()
    rates = {}   # npcID -> {itemID: pct}
    for m in re.finditer(r'\[(\d+)\]\s*=\s*\{', s):
        npc = int(m.group(1))
        st = m.end()-1
        en = match_brace(s, st)
        body = s[st+1:en-1]
        d = {}
        for im in re.finditer(r'\[(\d+)\]\s*=\s*([\d.]+)', body):
            d[int(im.group(1))] = float(im.group(2))
        if d: rates.setdefault(npc, {}).update(d)
    return rates

# ---------- parse user's AdventureGuideClassic file ----------
def parse_user(path):
    """Return list of bosses: {name, encounterID, ids:set[int]} in file order."""
    s = open(path, encoding='utf-8').read()
    # Anchor on encounterID and walk back to the '{' that opens its entry, rather
    # than matching a fixed indent. Files do not agree on indentation -- Blackrock
    # Spire nests its encounters a level deeper -- and an indent-based match
    # silently returned nothing for those files rather than failing loudly.
    bosses = []
    seen = set()
    for m in re.finditer(r'\bencounterID\s*=\s*\d+', s):
        depth, i = 0, m.start()
        while i > 0:
            c = s[i]
            if c == '}':
                depth += 1
            elif c == '{':
                if depth == 0: break
                depth -= 1
            i -= 1
        if i <= 0 or i in seen: continue
        seen.add(i)
        st = i
        en = match_brace(s, st)
        entry = s[st:en]
        nm = re.search(r'name\s*=\s*"([^"]+)"', entry)
        ec = re.search(r'encounterID\s*=\s*(\d+)', entry)
        if not nm or not ec: continue
        # collect loot ids ONLY from the five loot-category blocks, never from
        # `abilities` (whose entries can also carry an `id = N` field).
        ids = set()
        cats = {}
        for cat in ("loot", "sharedLoot", "rareLoot", "veryRareLoot", "extremelyRareLoot"):
            cm = re.search(r'(?<![A-Za-z])' + cat + r'\s*=\s*\{', entry)
            if not cm: continue
            cstart = entry.find('{', cm.end()-1)
            cend = match_brace(entry, cstart)
            body = entry[cstart:cend]
            cats[cat] = [(int(i), sf) for i, sf in
                         re.findall(r'\bid\s*=\s*(\d+)\s*,\s*seasonFilter\s*=\s*"([^"]*)"', body)]
            for x in re.findall(r'\bid\s*=\s*(\d+)', body):
                ids.add(int(x))
        bosses.append({"name": nm.group(1), "encounterID": int(ec.group(1)),
                       "ids": ids, "cats": cats, "span": (st, en)})
    return bosses

# ---------- gear filter ----------
GEAR_CLASSES = {2, 4}   # Wowhead item class: 2 = Weapon, 4 = Armor
# Slots that carry an equip line but aren't gear a player wears.
NON_GEAR_SLOTS = {"bag", "quiver", "ammo"}

def parse_tier_tokens(path=TOKEN_DATA):
    """itemIDs AtlasLoot marks `type = 6` -- the tier-set tokens.

    Entries nest (`{231331, "SoD"}` alternates), so the body has to be taken by
    brace matching; a `[^}]*` body stops at the first inner brace and silently
    misses every token that has a SoD variant."""
    if not os.path.exists(path): return set()
    s = open(path, encoding='utf-8').read()
    out = set()
    for m in re.finditer(r'\[(\d+)\]\s*=\s*\{', s):
        st = s.find('{', m.end() - 1)
        body = s[st:match_brace(s, st)]
        if re.search(r'type\s*=\s*6\b', body): out.add(int(m.group(1)))
    return out

def parse_companions(path=COMPANION_DATA):
    """itemID -> 1 (pet) or 2 (mount), from AtlasLoot's companion table."""
    if not os.path.exists(path): return {}
    s = open(path, encoding='utf-8').read()
    out = {}
    for m in re.finditer(r'\[(\d+)\]\s*=\s*\{\s*\d+\s*,\s*\d+\s*,\s*(\d+)\s*\}', s):
        out[int(m.group(1))] = int(m.group(2))
    return out

def load_meta(path=ITEM_META):
    meta = {}
    if not os.path.exists(path): return meta
    for line in open(path, encoding='utf-8'):
        p = line.rstrip("\n").split("\t")
        if not p or not p[0].isdigit(): continue
        def num(n, d=-1):
            v = p[n] if len(p) > n else ""
            return int(v) if v.lstrip("-").isdigit() else d
        meta[int(p[0])] = {"quality": num(1), "class": num(2),
                           "slot": (p[3] if len(p) > 3 else "").strip(),
                           "name": p[4] if len(p) > 4 else ""}
    return meta

class GearFilter:
    """Keep equippable Weapon/Armor of common quality or better, plus tier-set
    tokens and mounts/pets. Everything else -- greys, badges and other currency,
    recipes/designs/patterns, gems, quest and attunement items, fishing junk --
    stays out of the guide.

    An equip slot is the signal for "gear": trinkets, rings and cloaks carry no
    subclass, so class alone would miss them. Where a class IS present it must be
    Weapon or Armor, which keeps bags and quivers out. Tokens and mounts have no
    slot at all, hence the explicit whitelists."""
    def __init__(self):
        self.meta = load_meta()
        self.tokens = parse_tier_tokens()
        self.companions = parse_companions()
    def keep(self, i):
        if i in self.tokens or i in self.companions: return True
        m = self.meta.get(i)
        if not m or m["quality"] < 0: return False  # unresolved -> not a real item
        if m["quality"] < 1: return False           # grey
        if not m["slot"] or m["slot"].lower() in NON_GEAR_SLOTS: return False
        return m["class"] in GEAR_CLASSES or m["class"] < 0
    def why(self, i):
        m = self.meta.get(i)
        if not m: return "not in item_meta.tsv"
        if m["quality"] < 0: return "nonexistent"
        if m["quality"] < 1: return f"grey -- {m['name']}"
        if not m["slot"]: return f"not equippable -- {m['name']}"
        if m["slot"].lower() in NON_GEAR_SLOTS: return f"{m['slot']} -- {m['name']}"
        return f"class {m['class']} -- {m['name']}"

# ---------- matching ----------
def build_index(al_bosses):
    by_npc, by_name = {}, {}
    for b in al_bosses:
        for n in b["npcids"]:
            by_npc.setdefault(n, b)
        if b["name"]:
            by_name.setdefault(norm(b["name"]), b)
    return by_npc, by_name

# User boss name -> AtlasLoot boss name(s), for encounters the guide models as one
# unit but AtlasLoot splits (Karazhan's Opera Event) or simply names differently.
ALIASES = {
    "reliquaryofsouls": ["Reliquary of the Lost"],
    "operahall": ["The Wizard of Oz", "The Big Bad Wolf", "Romulo and Julianne"],
}

def merge_bosses(bs):
    """Union several AtlasLoot boss entries into one synthetic entry."""
    if len(bs) == 1: return bs[0]
    items, seen, diffs, npcids = [], set(), {}, set()
    for b in bs:
        npcids |= b["npcids"]
        for d, ids in b["diffs"].items(): diffs.setdefault(d, []).extend(ids)
        for i in b["items"]:
            if i not in seen: seen.add(i); items.append(i)
    return {"name": bs[0]["name"], "npcids": npcids, "inst": bs[0]["inst"],
            "items": items, "diffs": diffs, "extra": False}

def find_al(ub, by_npc, by_name):
    k = norm(ub["name"])
    if k in ALIASES:
        hits = [by_name[norm(n)] for n in ALIASES[k] if norm(n) in by_name]
        if hits: return merge_bosses(hits), "alias"
    if ub["encounterID"] in by_npc: return by_npc[ub["encounterID"]], "npcID"
    if k in by_name: return by_name[k], "name"
    return None, None

# ---------- commands ----------
def load_sources(prefer):
    """-> (order, idx, inst_ids) where inst_ids[src][instanceKey] = the instance's
    *unassigned* item pool: ids AtlasLoot lists only under npcID-less entries such as
    Trash and Patterns. Ids belonging to a specific boss are deliberately excluded, so
    an id parked on the wrong boss reads as a fabrication and gets dropped."""
    order = [prefer] + [k for k in SOURCES if k != prefer]
    idx, inst_ids = {}, {}
    for k in order:
        bs = parse_atlasloot(SOURCES[k])
        idx[k] = build_index(bs)
        pool, assigned = {}, {}
        for b in bs:
            tgt = assigned if b["npcids"] else pool
            tgt.setdefault(b["inst"], set()).update(b["items"])
        inst_ids[k] = {i: ids - assigned.get(i, set()) for i, ids in pool.items()}
    return order, idx, inst_ids

def cmd_audit(userfile, prefer):
    order, idx, _ = load_sources(prefer)
    gf = GearFilter()
    ub_list = parse_user(userfile)
    # first pass: match every boss, tally AtlasLoot item frequency across the instance
    matched = []
    freq = {}
    for ub in ub_list:
        al = src = mk = None
        for k in order:
            by_npc, by_name = idx[k]
            a, mk = find_al(ub, by_npc, by_name)
            if a: al, src = a, k; break
        matched.append((ub, al, src, mk))
        if al:
            for it in set(al["items"]): freq[it] = freq.get(it, 0) + 1
    nbosses = sum(1 for _, al, _, _ in matched if al)
    # an item on >=3 bosses (or >=40% of them) is an instance-wide SHARED drop, not per-boss
    shared = {it for it, c in freq.items() if c >= max(3, round(0.4 * nbosses))}
    print(f"\n=== AUDIT {os.path.basename(userfile)}  (prefer '{prefer}', {nbosses} bosses matched) ===")
    if shared:
        print(f"  instance-wide shared drops (ignored per-boss): {sorted(shared)}")
    for ub, al, src, mk in matched:
        if not al:
            print(f"  [!] {ub['name']} (enc {ub['encounterID']}): NO AtlasLoot match")
            continue
        al_items = {i for i in al["items"] if gf.keep(i)} - shared
        have     = ub["ids"] - shared
        missing = al_items - have
        extra   = have - al_items
        flag = "OK  " if not missing and not extra else "DIFF"
        print(f"  [{flag}] {ub['name']}  <{src}/{mk}>  have {len(have)} / AL {len(al_items)}")
        if missing: print(f"        missing (in AL, not you): {sorted(missing)}")
        if extra:   print(f"        extra   (you, not AL)   : {sorted(extra)}")

BASE_DIFFS = {"NORMAL_DIFF", "RAID10_DIFF", "RAID20_DIFF", "RAID40_DIFF",
              "ALLIANCE_DIFF", "HORDE_DIFF", "HEROIC_DIFF"}

def season_tag(item, base_ids, sod_ids, has_sod, src):
    """Map an item to a seasonFilter based on which AtlasLoot difficulty it came from.
    SoD content uses "exclusive" (the project's dominant convention; identical to "sod"
    in the addon's filter code)."""
    if src == "tbc":
        return "tbc"
    if src == "sod":
        return "exclusive"
    in_base, in_sod = item in base_ids, item in sod_ids
    if in_base and in_sod:            return "all"        # drops in Era AND SoD (e.g. Atiesh)
    if in_sod:                        return "exclusive"  # SoD re-itemized version
    if in_base:                       return "era" if has_sod else "all"
    return "all"                                          # no difficulty info

def cmd_generate(userfile, prefer, autobucket):
    order, idx, _ = load_sources(prefer)
    rates = parse_droprate(DROPRATE)
    ub_list = parse_user(userfile)
    # match all bosses first, tally item frequency across the instance for shared detection
    matched = []
    freq = {}
    for ub in ub_list:
        al = src = None
        for k in order:
            a, _ = find_al(ub, idx[k][0], idx[k][1])
            if a: al, src = a, k; break
        matched.append((ub, al, src))
        if al:
            for it in set(al["items"]): freq[it] = freq.get(it, 0) + 1
    nb = sum(1 for _, al, _ in matched if al)
    shared_ids = {it for it, c in freq.items() if c >= max(3, round(0.4 * nb))}
    print(f"\n=== GENERATE {os.path.basename(userfile)}  ({nb} bosses matched) ===")
    if shared_ids:
        print(f"-- instance-wide shared drops -> sharedLoot: {sorted(shared_ids)}")
    for ub, al, src in matched:
        print(f"\n-- {ub['name']} (enc {ub['encounterID']}) --")
        if not al or not al["items"]:
            print("   loot = {},  -- no AtlasLoot data (drops no fixed loot)")
            continue
        base_ids = set()
        for d, ids in al["diffs"].items():
            if d in BASE_DIFFS: base_ids.update(ids)
        sod_ids = set(al["diffs"].get("SOD_DIFF", []))
        has_sod = bool(sod_ids)
        loot, sharedLoot = [], []
        seen = set()
        for it in al["items"]:
            if it in seen: continue
            seen.add(it)
            r = None
            for npc in al["npcids"]:
                if npc in rates and it in rates[npc]:
                    r = rates[npc][it]; break
            sf = season_tag(it, base_ids, sod_ids, has_sod, src)
            (sharedLoot if it in shared_ids else loot).append((it, sf, r))
        for cat, rows in (("loot", loot), ("sharedLoot", sharedLoot)):
            if not rows: continue
            print(f"   {cat} = {{")
            for it, sf, r in rows:
                rc = f"  -- {r}%" if r is not None else ""
                print(f'      {{ id = {it}, seasonFilter = "{sf}" }},{rc}')
            print("   },")

# Known drop-mounts that lack a droprate.lua entry -> force into a rarity tier.
KNOWN_MOUNTS = {
    13335: "extremelyRareLoot",  # Rivendare's Deathcharger (Stratholme)
    19872: "extremelyRareLoot",  # Swift Razzashi Raptor (Zul'Gurub)
    19902: "extremelyRareLoot",  # Swift Zulian Tiger (Zul'Gurub)
    30480: "rareLoot",           # Fiery Warhorse's Reins (Karazhan)
    32458: "extremelyRareLoot",  # Ashes of Al'ar (The Eye)
    32768: "extremelyRareLoot",  # Reins of the Raven Lord (Sethekk Halls H)
    35513: "extremelyRareLoot",  # Swift White Hawkstrider (Magisters' Terrace H)
}

CATS = ("loot", "sharedLoot", "rareLoot", "veryRareLoot", "extremelyRareLoot")

def rarity_tier(rate):
    """User's calibrated drop-chance thresholds."""
    if rate is None:   return "loot"
    if rate >= 5:      return "loot"
    if rate >= 1:      return "rareLoot"
    if rate >= 0.1:    return "veryRareLoot"
    return "extremelyRareLoot"

def build_arrays(al, src, shared_ids, rates, gf=None):
    """Return dict cat -> [(id, seasonFilter)], Era items before SoD within each."""
    base_ids = set()
    for d, ids in al["diffs"].items():
        if d in BASE_DIFFS: base_ids.update(ids)
    sod_ids = set(al["diffs"].get("SOD_DIFF", []))
    has_sod = bool(sod_ids)
    out = {c: [] for c in CATS}
    seen, nodrop = set(), []
    for it in al["items"]:
        if it in seen: continue
        seen.add(it)
        if gf and not gf.keep(it): continue
        sf = season_tag(it, base_ids, sod_ids, has_sod, src)
        r = None
        for npc in al["npcids"]:
            if npc in rates and it in rates[npc]:
                r = rates[npc][it]; break
        if it in shared_ids:
            cat = "sharedLoot"
        elif it in KNOWN_MOUNTS:
            cat = KNOWN_MOUNTS[it]
        else:
            cat = rarity_tier(r)
        out[cat].append((it, sf))
        if r is None and it not in shared_ids and cat == "loot":
            nodrop.append(it)
    order = {"era": 0, "all": 1, "exclusive": 2, "tbc": 0}  # Era first, then shared, then SoD
    for c in out: out[c].sort(key=lambda row: order.get(row[1], 1))
    return out, nodrop

def fmt_block(key, rows):
    if not rows:
        return f"\n\t\t{key} = {{}},"
    body = "".join(f'\t\t\t{{ id = {i}, seasonFilter = "{sf}" }},\n' for i, sf in rows)
    return f"\n\t\t{key} = {{\n{body}\t\t}},"

def fmt_body(rows):
    """Category value only, matching the data files' style (no trailing comma)."""
    if not rows: return "{}"
    lines = ",\n".join(f'\t\t\t{{ id = {i}, seasonFilter = "{sf}" }}' for i, sf in rows)
    return "{\n" + lines + "\n\t\t}"

def replace_cat(entry, cat, rows):
    """Overwrite a category block whatever its current contents."""
    m = re.search(r'(?<![A-Za-z])' + cat + r'\s*=\s*\{', entry)
    if not m: return entry
    st = entry.find('{', m.end() - 1)
    en = match_brace(entry, st)
    return entry[:st] + fmt_body(rows) + entry[en:]

def cmd_apply(userfile, prefer, force=False):
    order, idx, inst_ids = load_sources(prefer)
    rates = parse_droprate(DROPRATE)
    gf = GearFilter()
    raw = open(userfile, "rb").read()
    crlf = b"\r\n" in raw
    s = raw.decode("utf-8").replace("\r\n", "\n")   # normalize to \n for processing
    ub_list = parse_user(userfile)
    # instance-wide shared detection
    matched, freq = [], {}
    for ub in ub_list:
        al = src = None
        for k in order:
            a, _ = find_al(ub, idx[k][0], idx[k][1])
            if a: al, src = a, k; break
        matched.append((ub, al, src))
        if al:
            for it in set(al["items"]): freq[it] = freq.get(it, 0) + 1
    nb = sum(1 for _, al, _ in matched if al)
    shared_ids = {it for it, c in freq.items() if c >= max(3, round(0.4 * nb))}
    filled = skipped = 0
    nodrop_all, dropped_all, kept_all = [], [], []
    # process bosses in REVERSE so string offsets stay valid
    for ub, al, src in reversed(matched):
        st, en = ub["span"]
        entry = s[st:en]
        # without --force, only fill bosses whose main loot is still the empty placeholder
        if not force and not re.search(r'\n\t\tloot = \{\},', entry):
            skipped += 1; continue
        if not al or not al["items"]:
            skipped += 1; continue
        out, nodrop = build_arrays(al, src, shared_ids, rates, gf)
        nodrop_all += [(ub["name"], i) for i in nodrop]
        if force:
            # Keep an existing id only if it is real gear AND AtlasLoot lists it in this
            # instance's unassigned pool (Trash etc). An id parked on the wrong boss, or
            # anything that isn't gear, is dropped.
            known = inst_ids[src].get(al["inst"], set())
            al_ids = {i for rows in out.values() for i, _ in rows}
            for cat, rows in ub["cats"].items():
                for i, sf in rows:
                    if i in al_ids: continue
                    if i in known and gf.keep(i):
                        out[cat].append((i, sf)); al_ids.add(i)
                        kept_all.append((ub["name"], i))
                    else:
                        dropped_all.append((ub["name"], i, gf.why(i)))
        for cat in CATS:
            entry = replace_cat(entry, cat, out[cat]) if force else \
                    re.sub(r'\n\t\t' + cat + r' = \{\},', fmt_block(cat, out[cat]), entry, count=1)
        s = s[:st] + entry + s[en:]
        filled += 1
    out_s = s.replace("\n", "\r\n") if crlf else s
    open(userfile, "wb").write(out_s.encode("utf-8"))
    print(f"APPLIED to {os.path.basename(userfile)}: filled {filled} boss(es), skipped {skipped} "
          f"({'CRLF' if crlf else 'LF'} preserved).")
    if kept_all:
        print(f"  [kept] {len(kept_all)} existing id(s) not on the boss but known to the instance:")
        for n, i in kept_all: print(f"     {n}: {i}")
    if dropped_all:
        print(f"  [dropped] {len(dropped_all)} existing id(s):")
        for n, i, why in dropped_all: print(f"     {n}: {i}  -- {why}")
    # only report no-droprate items that are NOT the huge SoD 236xxx block (those are known gear)
    review = [(n, i) for n, i in nodrop_all if i < 200000]
    if review:
        print(f"  [review] {len(review)} item(s) with no droprate (check for mounts/specials):")
        for n, i in review: print(f"     {n}: {i}")

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["audit", "generate", "apply"])
    ap.add_argument("file", help="path to user data .lua (relative to data/ ok)")
    ap.add_argument("--prefer", default=None, help="all|tbc|sod (default: infer from path)")
    ap.add_argument("--autobucket", action="store_true")
    ap.add_argument("--force", action="store_true",
                    help="apply: overwrite non-empty loot blocks (keeps instance-known extras)")
    a = ap.parse_args()
    f = a.file
    if not os.path.isabs(f) and not os.path.exists(f):
        f = os.path.join(AG_ROOT, f)
    prefer = a.prefer or ("tbc" if re.search(r'[\\/]tbc[\\/]', f) else "all")
    if a.mode == "audit": cmd_audit(f, prefer)
    elif a.mode == "apply": cmd_apply(f, prefer, force=a.force)
    else: cmd_generate(f, prefer, a.autobucket)
