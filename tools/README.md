# tools/

## atlasloot_tool.py

Fills and audits boss loot in `data/` against a local AtlasLootClassic checkout.

### Setup

Expects **AllAtlasLoot** as a sibling checkout of this repo:

```
workspaces/home-projects/
  AdventureGuideClassic/     <- this repo
  AllAtlasLoot/              <- https://github.com/hobbs11/AtlasLootClassic (or your fork)
```

Override via `AL_ROOT` / `AG_ROOT` at the top of the script.

### Usage

```bash
python tools/atlasloot_tool.py audit    data/Raids/tbc/Sunwell_Plateau.lua --prefer tbc
python tools/atlasloot_tool.py generate data/Raids/tbc/Sunwell_Plateau.lua --prefer tbc
python tools/atlasloot_tool.py apply    data/Raids/tbc/Sunwell_Plateau.lua --prefer tbc
python tools/atlasloot_tool.py apply    data/Raids/tbc/Sunwell_Plateau.lua --prefer tbc --force
```

- `audit` — report per boss what AtlasLoot has that we don't, and vice versa.
- `generate` — print the loot arrays without touching the file.
- `apply` — write them in. By default only fills bosses whose `loot` is still the
  empty `{}` placeholder, so it can't clobber curated data.
- `--force` — also overwrite non-empty loot blocks. Existing ids survive only if
  they pass the gear filter *and* AtlasLoot lists them in that instance's
  unassigned pool (Trash, Patterns). An id parked on the wrong boss is dropped.

`--prefer` is inferred from the path (`tbc` for `data/**/tbc/**`, else `all`).

Bosses are joined on `encounterID == AtlasLoot npcID`, falling back to name. Where
the guide models an encounter differently from AtlasLoot (Karazhan's Opera Hall,
Black Temple's Reliquary of Souls) the `ALIASES` table maps it across.

### Gear filter

Only real, equippable gear goes into the guide. An item is kept when it is a
tier-set token (AtlasLoot `Token.lua`, `type = 6`) **or** it is a Weapon/Armor
class item of common quality or better with a real inventory slot.

That deliberately excludes greys, Badge of Justice and other currency,
recipes/designs/patterns, quest and attunement items, and fishing junk.

## gen_tier_tokens.py

Regenerates `data/TierTokens.lua` from AtlasLoot's `Token.lua`:

```bash
python tools/gen_tier_tokens.py
```

Maps each tier-set token to the item every class trades it for. A token has no
appearance of its own, so `TierTokenService` uses this to dress the character in
the piece the token actually grants. The loot entry still shows the token.

Re-run it whenever the AllAtlasLoot checkout is updated.

## gen_creature_models.py

Corrects `npcs` in the encounter data and regenerates `data/CreatureModels.lua`:

```bash
python tools/gen_creature_models.py [--dry-run] [--skip path ...]
```

Both outputs join on `encounterID`, the one field in our data that is reliable.
Much of `npcs` was a placeholder (`{2135, 12456, 12314}`) copy-pasted across 156
encounters; where AtlasLoot knows the boss, the real npc ids replace it, and
where it doesn't, the placeholder is cleared rather than left to mislead.

Display ids are keyed by encounter, not by npc, because AtlasLoot lists one
`DisplayIDs` entry per distinct creature while `npcID` also carries the heroic
copies — 68 entries have mismatched counts, so zipping them by index would
attach the wrong model to half the heroic encounters.

Use `--skip` to leave files with uncommitted work alone.

### creature_heights.tsv

`displayID <TAB> height`, the model height in world units, used to pull the
camera back for large creatures. Heights span roughly 0.9 (Pusillin) to 66
(Supremus), so no single camera framing suits every model.

Computed from the game's own tables, exported by wago.tools:

```
height = (CreatureModelData.GeoBox_5 - CreatureModelData.GeoBox_2)
       *  CreatureModelData.ModelScale
       *  CreatureDisplayInfo.CreatureModelScale
```

To rebuild after adding encounters, download both tables for a current build and
re-join them on `CreatureDisplayInfo.ModelID`:

```
https://wago.tools/db2/CreatureDisplayInfo/csv?build=<build>
https://wago.tools/db2/CreatureModelData/csv?build=<build>
```

Build ids come from `https://wago.tools/api/builds`. The Era build only covers
Era creatures, so TBC displays need a later Classic build as well; the committed
file was built from `5.5.4.68806` with `1.15.9.68808` filling the gaps.

The camera curve itself lives in `services/CreatureModelService.lua`, not here —
tune `BASELINE_HEIGHT` there rather than regenerating this file.

## item_meta.tsv

The filter reads item quality/class/slot from `tools/item_meta.tsv`:

```
itemID <TAB> quality <TAB> classID <TAB> equipSlot <TAB> name
```

`classID` is `-1` when the item has no subclass line (trinkets, rings, cloaks);
`equipSlot` is empty for anything not equippable. Sourced from
`https://nether.wowhead.com/tbc/tooltip/item/<id>` — note `www.wowhead.com`
returns 403 to scripted requests, so use the `nether` host.
It's committed so the tool runs offline and gives reproducible results. To add
ids, append rows; anything missing from the file is treated as not-gear and
dropped, so regenerate before adding a new instance.
