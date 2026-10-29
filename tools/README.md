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
python tools/gen_creature_models.py --models-only   # leave npcs alone
```

`--models-only` regenerates the display table and touches no encounter data, which
is what to use when the point is the models: the `npcs` pass rewrites dozens of
lines across the data files and does not belong in a change about something else.

Both outputs join on `encounterID`, the one field in our data that is reliable.
Much of `npcs` was a placeholder (`{2135, 12456, 12314}`) copy-pasted across 156
encounters; where AtlasLoot knows the boss, the real npc ids replace it, and
where it doesn't, the placeholder is cleared rather than left to mislead.

Display ids are keyed by encounter, not by npc, because AtlasLoot lists one
`DisplayIDs` entry per distinct creature while `npcID` also carries the heroic
copies — 68 entries have mismatched counts, so zipping them by index would
attach the wrong model to half the heroic encounters.

Use `--skip` to leave files with uncommitted work alone.

### Where AtlasLoot has no model

AtlasLoot carries no `DisplayIDs` for about a quarter of the encounters we ship, and
those bosses opened the model viewer on an empty frame with nothing to say why — 65
of them, Ghamoo-ra and Mekgineer Thermaplugg among them. They are filled in from
`npc_models.tsv`, the CMaNGOS Classic world database, by three joins:

| Join | Fills |
|---|---|
| `encounterID` as an npc id | 48 |
| the encounter's own `npcs` list | 2 |
| the boss's name, when it picks out exactly one creature | 1 |

The first one carries almost all of it because **Era encounterIDs are vanilla npc
ids** — Ghamoo-ra is encounter 4887 and npc 4887. A name is used only when it is
unambiguous, since the world database has distinct creatures sharing a name.

That leaves 15, all of them invented content with no creature in a Classic database:
Demon Fall Canyon's six, Karazhan Crypts' six, Atrexis the Grave Knight, Alexei the
Beastlord, and Reliquary of Souls, which is two spirits and has no single model at
all. Those need a display id by hand.

New display ids arrive without a measured height and fall back to a neutral camera
distance, so `creature_heights.tsv` is worth regenerating after a run like this.

### creature_heights.tsv

`displayID <TAB> height`, the model height in world units, used to pull the
camera back for large creatures. Heights span roughly 0.9 (Pusillin) to 66
(Supremus), so no single camera framing suits every model.

Computed from the game's own tables, exported by wago.tools:

```
height = (CreatureModelData.GeoBox_5 - CreatureModelData.GeoBox_2)
       *  CreatureModelData.ModelScale
```

`CreatureDisplayInfo.CreatureModelScale` is deliberately **not** applied. It is
what the game multiplies a creature by when spawning it in the world, but the
model frame renders the base model without it, so including it pulled the camera
back by up to 7x on creatures like Hakkar and Supremus. Measured against 78
hand-tuned presets, dropping it improves the fit from 0.699 to 0.595 rms in log
space.

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

## gen_instance_levels.py

Writes `minLevel` and `levelRange` onto every instance, from AtlasLoot's
`LevelRange`:

```bash
python tools/gen_instance_levels.py            # report the join, write nothing
python tools/gen_instance_levels.py --apply    # write it in
```

56 of 67 instances resolve. The eleven that do not are Forever's own, which
AtlasLoot has never heard of; they ship without a range rather than with a guess.

**Joined on the name, never on an id.** `instanceID` and `mapID` mean opposite
things in the two halves of `data/` — Era files are journal-id/map-id, TBC files
are the reverse, Forever files carry `mapID` alone. Joining on `mapID` matches 27
of 67 and puts three of them on the wrong instance.

Two wrinkles the script handles and the docstring explains at length: AtlasLoot
splits Scarlet Monastery, Dire Maul and Blackrock Spire into wings, and its
current Classic file has replaced Blackfathom Deeps, Gnomeregan and Sunken
Temple with their Season of Discovery *raid* entries. The pre-SoD copy on the
checkout's TBC branch still has the dungeons, so `Dungeons/` reads that one and
`Raids/` reads the newer — which is why Blackfathom Deeps reads 24–32 as a
dungeon and 25–40 as a raid.

## gen_npc_meta.py

Gives the boss portrait tooltip its second line — "Level 19 Humanoid Elite" — by
writing `level`, `creatureType` and `classification` onto each encounter.

```bash
python tools/gen_npc_meta.py extract <classicmangos.sql> <tbcmangos.sql>
python tools/gen_npc_meta.py apply [--force]
python tools/gen_npc_meta.py report
```

`extract` needs the CMaNGOS world dumps; `apply` reads only the checked-in
`tools/npc_meta.tsv`, so a normal run needs neither the 85MB of SQL nor the
network. Re-extract only when encounters are added.

    https://github.com/cmangos/classic-db  (GPL-2.0)
    https://github.com/cmangos/tbc-db      (GPL-2.0)

A creature's level, type and classification are server-side in this era: the
client learns them from the unit in front of it, the journal has no API for
them, and `Creature.db2` ships empty. wago.tools cannot stand in — its Era
`Creature.db2` has one row, and retail's covers 8 of our 361 encounter ids and
carries no level at all.

**The name has to agree before a row is accepted.** Our `encounterID` is an npc
id, but Forever numbers its own bosses in the vanilla range: Witherfang in the
Ruins of Lordaeron is 3353, which in classic-db is Grezz Ragefist, a level 60
Humanoid in Orgrimmar. So a dump is only consulted for the matching folder, the
name must match, and every rejection is printed. That guard found Shirrak the
Dead Watcher carrying 17371 — a Shadowmoon Warlock — instead of 18371.

`ALIASES` carries the encounters the guide models as one fight and the database
as several, naming the combatant whose stats stand for it. Fights whose id
points at an announcer rather than a fighter are left out: Blackrock Depths' Ring
of Law resolves to the herald on the balcony, Karazhan's Opera Hall to Barnes.

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

## blp2png.py

Converts Blizzard BLP textures to PNG.

The client reads PNG, so this is not needed to *ship* art -- it is needed to *look* at
it. Picking tex coords for an `Atlas.lua` entry means knowing where a piece sits on its
sheet, which cannot be done without seeing the pixels.

```sh
python tools/blp2png.py path/to/sheet.blp -o images/      # convert one
python tools/blp2png.py <art-dir> -r --info               # report size and format only
```

`--info` writes nothing and is usually all that is wanted when deciding whether a
texture is worth shipping at all -- a path reference to art the client already has
costs nothing, and only retail-only pieces need to land in `images/`. It reads only
the 148-byte header, so a sweep over a directory decodes nothing: the pure-Python
DXT decode is about half a second for a 512x512, which adds up over an art folder.
A file whose header is sound but whose pixel data is truncated still reports what it
is, rather than failing.

Handles BLP2 in its three encodings: palettised, DXT1/3/5, and raw BGRA. DXT1 and DXT5
are verified against real files; palettised and BGRA are implemented from the format
and have not had a sample to test against. BLP1 is reported rather than guessed at.

Needs Pillow (`pip install pillow`); no other dependency.

## make_lorebg.py

Builds an instance's lore background -- the picture behind the overview text.

Forever publishes no journal, so its dungeons ship no `UI-EJ-LOREBG-*` art and the
overview falls back to a flat dark panel. Making one by hand in Photoshop is slow and
hard to repeat; it is also unnecessary, because a lore background is a recipe rather
than a composition.

```sh
python tools/make_lorebg.py build <source> CityOfDalaran
python tools/make_lorebg.py build <source> CityOfDalaran --zoom 1.3 --pan-y 0.3
```

`build` writes `images/UIEJLoreBG<Name>.png` and prints the `splash` line to paste
into the instance's data file. The source may be PNG, JPEG or BLP; `--zoom` and
`--pan-x/--pan-y` choose the crop when the default centre is wrong.

Forever's own loading screens are the best sources and are already the right subject:
they live in the client under `Interface/GLUES/LOADINGSCREENS/Camelot160/Main/`, as
2992x1684 painted art. The flat grey bands they are padded with are detected and
trimmed, so the source can be passed as it comes.

### The frame

`lorebg_mask.png` and `lorebg_frame.png` beside the script are the template, measured
from the 179 retail lore backgrounds rather than guessed:

- The canvas is 512x512 and the picture occupies exactly (4, 4)-(394, 340).
- The torn edge is an alpha mask, identical in 99.4% of pixels across all of them.
- The frame is an overlay, which is why `splash` art cannot simply be a screenshot.
  Pixels near the edge barely vary between instances -- a luminance spread of about
  17 six pixels in, against 100 forty pixels in -- so frame and picture separate on
  that spread.

`python tools/make_lorebg.py frame <dir-of-retail-lore-art>` rebuilds both from a
folder of `UI-EJ-LOREBG-*` art. That has been run; it is here so the two templates
are reproducible rather than mystery binaries, and needs running again only if they
are lost.

## make_bossportrait.py

Builds a boss portrait -- the cut-out of the model on the encounter button.

```sh
python tools/make_bossportrait.py worklist              # who still needs one
python tools/make_bossportrait.py worklist --names      # the filenames to shoot
python tools/make_bossportrait.py batch shots/ --wire   # do the lot
python tools/make_bossportrait.py build shot.png LynTheIgnored
python tools/make_bossportrait.py build shot.png LynTheIgnored --tolerance 40 --erode 2
```

### The whole job, three steps

1. `worklist --names` prints one filename per boss still on the placeholder id.
2. Shoot those models, saving each under the name it printed. Capitalisation,
   spaces, underscores and apostrophes are all ignored when matching, so
   `lyn_the_ignored.png` finds Lyn the Ignored.
3. `batch shots/ --wire` builds every one into `images/` **and** repoints that
   encounter's `portrait` in `data/`.

`--wire` edits one line per boss and nothing else, preserving the file's line
endings; `--dry-run` shows what it would do first. Files matching no boss on the
placeholder are listed rather than guessed at, so a typo is reported instead of
landing on the wrong encounter.

It writes `images/UIEJBoss<Name>.png` and prints the `portrait` line. The source may
be PNG, JPEG or BLP; art that is already a 128x64 cut-out passes through untouched,
so retail's own `UI-EJ-BOSS-*` files can be used directly.

The format, measured from the 59 shipped and confirmed against retail's (also
128x64): the model stands on the bottom edge, fills about 60 of the 64 points of
height and 96 of the 128 across, and centres at x 59 rather than 64.

### Shooting the model

What the script cannot do is produce the model. That still comes from the game,
through the addon's own viewer -- `/run AGC_NpcPreview(id)`.

**Shoot it against a flat colour the model does not contain.** Magenta or green, for
the same reason film uses them. The backdrop is removed by flooding in from the
edges, so a creature sharing the backdrop's colour somewhere in its middle will not
be punched through. The edges are the hard part: an edge pixel is a genuine blend of
model and backdrop, and recovering those is what decides whether the result looks
cut out or looks like it has a coloured rim.

That recovery is a colour-difference key rather than a distance test, because
distance does not work -- half a dark model mixed into magenta still lands far from
magenta, so it reads as pure model and keeps its rim. What shrinks in proportion as
model mixes in is the backdrop's shape: magenta is high red and blue against low
green. That is what is measured. If a rim survives anyway, raise `--erode`.

## make_dungeonbutton.py

Builds an instance's two smaller pictures: the tile in the instance list, and the
round portrait on the overview header.

```sh
python tools/make_dungeonbutton.py build <source> CityOfDalaran
python tools/make_dungeonbutton.py build <source> CityOfDalaran --pan-x 0.5
python tools/make_dungeonbutton.py check <source> TheHallOfThanes
```

`build` writes `images/UIEJDungeonButton<Name>.png` and
`images/UIEJDungeonPortrait<Name>.png` and prints the `thumbnail` and `icon` lines to
paste in. Same sources as `make_lorebg.py`, and the same grey bands are trimmed.

An instance with no `thumbnail` gets a plain dark tile rather than a broken one, so a
missing picture is easy to miss: City of Dalaran shipped without either of these for
three weeks because nothing says anything is wrong.

### The recipe

Recovered from the five tiles that already shipped, by correlating each against its
loading screen **on luminance**. The paintings are each a single hue, so a colour
difference finds nothing and reports art as unrelated when it is a crop of exactly
that picture -- which is what it did at first.

- Everything is cut from the painted band, never the padded file.
- The tile is the **left** of the band, at the tile's aspect, full band height. Left
  rather than centre because these paintings put their subject left of centre, and
  all five that shipped are anchored there. `--pan-x` overrides it.
- The picture occupies (3, 3)-(172, 88) of a 256x128 canvas and is transparent
  outside that. The margin is not decoration: the button draws a frame over the art,
  and art without a margin runs under it.
- The portrait is the centre square of that same crop, at 128x128.

`check` rebuilds art that already ships and scores it against what is there, then puts
the original back. That is how the recipe above was confirmed -- 0.96 on Excavation
Site: Wetlands. The other two score lower because each was hand-nudged by a few
percent of zoom, not because the crop is wrong.

The portrait is masked round at runtime, so it must not also carry tex coords -- the
client errors rather than ignoring one. See *Masked textures take no tex coords*.
