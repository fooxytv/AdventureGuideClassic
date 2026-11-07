#!/usr/bin/env python3
"""Generate data/TierTokens.lua from AtlasLoot's Token.lua.

A tier token has no appearance of its own, so previewing one on the character
model shows nothing. AtlasLoot already records which set piece each class trades
a given token for; that mapping is what the preview needs.

Entry shapes in Token.lua (all end with `type = 6`):
    { ICONS.PALADIN, 34485, 34487, 0, ICONS.PRIEST, 34527, type = 6 }
    { ICONS.HUNTER, 19831, {231321, "SoD"}, 0, ICONS.ROGUE, 19834, type = 6 }
    { 21268, 21273, 21275, type = 6 }        -- not class-specific
`0` separates class blocks; nested `{id, "SoD"}` are Season of Discovery
re-itemisations of the preceding piece and are emitted under `sod`.
"""
import os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atlasloot_tool import TOKEN_DATA, match_brace, parse_tier_tokens

AG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(AG_ROOT, "data", "TierTokens.lua")

HEADER = """--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming

GENERATED FILE -- do not edit by hand. Regenerate with:
    python tools/gen_tier_tokens.py

Maps each tier-set token to the item every class trades it for, so the loot
preview can dress the character in the piece the token actually grants. The
loot entry itself still shows the token; this only drives the preview.
Source: AtlasLootClassic Data/Token.lua (`type = 6` entries).
]]
select(2, ...).SetupGlobalFacade()

TierTokenService.Register({
"""


def parse_entry(body):
    """-> {class -> [itemIDs]}, with 'any' for tokens that aren't class-specific."""
    out, cur = {}, None
    # Strip the trailing `type = N` so it can't be read as an item id.
    body = re.sub(r'type\s*=\s*\d+', '', body)
    for m in re.finditer(r'ICONS\.(\w+)|\{\s*(\d+)\s*,\s*"(\w+)"\s*\}|(\d+)', body):
        icon, sod_id, sod_tag, plain = m.groups()
        if icon:
            cur = icon
            out.setdefault(cur, [])
        elif sod_id:
            out.setdefault((cur or "ANY") + "_SOD", []).append(int(sod_id))
        elif plain:
            v = int(plain)
            if v == 0:                      # class-block separator
                continue
            out.setdefault(cur or "ANY", []).append(v)
    return {k: v for k, v in out.items() if v}


def main():
    s = open(TOKEN_DATA, encoding="utf-8").read()
    tokens = parse_tier_tokens()
    rows = []
    for m in re.finditer(r'\[(\d+)\]\s*=\s*\{', s):
        tid = int(m.group(1))
        if tid not in tokens:
            continue
        st = s.find('{', m.end() - 1)
        entry = parse_entry(s[st + 1:match_brace(s, st) - 1])
        if not entry:
            continue
        parts = ", ".join(
            f'{k} = {{ {", ".join(str(i) for i in v)} }}'
            for k, v in sorted(entry.items())
        )
        rows.append(f"\t[{tid}] = {{ {parts} }},")

    body = HEADER + "\n".join(sorted(rows, key=lambda r: int(re.search(r'\[(\d+)\]', r).group(1))))
    body += "\n})\n"
    with open(OUT, "w", encoding="utf-8", newline="\r\n") as fh:
        fh.write(body)
    print(f"wrote {OUT}: {len(rows)} tokens")


if __name__ == "__main__":
    main()
