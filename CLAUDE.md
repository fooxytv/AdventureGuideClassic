# AdventureGuideClassic

A dungeon and raid journal for the Classic-line WoW clients, modelled on retail's
Encounter Journal. One codebase, five TOCs.

This file exists so an agent or a new contributor does not have to re-derive the
architecture by reading everything. It records the things that are **not** obvious from
the code — the patterns that will mislead you, and the conventions that are easy to
break by accident.

## Clients

| TOC | Interface | Client |
|---|---|---|
| `AdventureGuideClassic.toc` | 11509 | Classic Era (also SoD) |
| `AdventureGuideClassic_Classic.toc` | 11509 | Era, packager flavour name |
| `AdventureGuideClassic_BCC.toc` | 20506 | Burning Crusade Classic |
| `AdventureGuideClassic_Mainline.toc` | 16001 | Forever |
| `AdventureGuideClassic_Camelot.toc` | 16001 | Forever, packager flavour name |

`ci/scripts/publish.sh` bumps the version in **every** TOC; never bump one by hand.

## Load order

`Main.xml` is the single entry point and the order in it matters:

1. `Templates.xml`
2. `lib/TomCats/GlobalFacade.lua` — must be first code
3. `Compat.lua` — client detection, before anything that branches on the client
4. `lib/TomCats/Images.lua`, MinimapButton, `DynamicTable.lua`, `Atlas.lua`
5. `services/Services.xml`, `data/Data.xml`, `ui/UI.xml`, `ui/InstanceSelectTemplates.xml`
6. `SlashCommands.lua`, `Bindings.lua`, `Main.lua`, `Probe.lua`

## The global facade — read this before writing any file

Every source file starts with:

```lua
select(2, ...).SetupGlobalFacade()
```

That `setfenv`s the file to a shared facade table whose `__index` falls through to `_G`.
Consequences that catch people out:

- Assigning what looks like a global puts it **on the facade, not in `_G`**. That is why
  services can write `LootFilterService = {}` and see each other. If you need a genuine
  global — a slash-command helper, a `/run`-able test function — write `_G.Name = ...`
  explicitly, as `ui/EventToastManager.lua` does for its `TestLevelUpToast` helpers.
- `CreateFrame`, `ScrollUtil`, `CreateDataProvider` and `CreateScrollBoxListLinearView`
  are cached on the facade deliberately, so another addon overwriting those globals
  cannot break us. Use the bare names; they resolve to the cached copies.
- Because of `setfenv`, these files will not load in stock Lua 5.2+ without a stub. See
  *Checking work without the game* below.

## Client detection lives in exactly one place

`Compat.lua` resolves the client once, and is the only file that should read `GetBuildInfo()`
or `WOW_PROJECT_ID` *to decide anything*. Everything else asks it:

- Flags: `Compat.flavor` (`era` / `tbc` / `wrath` / `cata` / `forever` / `retail`),
  `isForever`, `isRetail`, `isTBC`, `isClassicLine`, `isEraClient`, `isVanillaLoot`
  (Era **or** Forever), `tocVersion`
- Season: `GetActiveSeason()`, `HasActiveSeason()`, `IsSoD()`, `IsEra()` — `C_Seasons`
  does not exist on every client, so never call it directly
- Shims: `GetSpellInfo(spellID)` (modern `C_Spell` returns a table, not a list),
  `TabButtonTemplate` (`CharacterFrameTabButtonTemplate` is missing on Forever)
- Events: `RegisterEvents(frame, ...)`, `IsEventAvailable(event)`

The one deliberate exception is `Probe.lua`, the `/agcprobe` diagnostic dump, which
reports `GetBuildInfo()` and `WOW_PROJECT_ID` raw because that is the point of it —
it answers "what does the addon think it is running on", so it must not go through
the layer being checked.

**If you need a new client difference, add an accessor to `Compat.lua`.** Do not add a
build check elsewhere. Detecting Forever needs *both* the project ID and the interface
version, which is exactly the kind of thing that goes wrong when it is duplicated.

## UI components

```lua
local component = UI.CreateComponent("Loot")   -- top of file
-- ...
UI.Add(component)                              -- bottom of file
```

`UI.Init()` calls each `component.Init(components)`, passing the registry, so components
reach each other as `components.EncounterFrame`. `UI.GetComponent(name)` also works.
Register the file in `ui/UI.xml`. By convention `component.Show()` rebuilds and displays
the view.

## Data shapes that will surprise you

- **An instance table *is* its array of encounters**, and also carries `name`. So
  `for _, encounter in ipairs(instance)` walks the bosses. There is no
  `instance.encounters`.
- Loot categories on an encounter: `loot`, `sharedLoot`, `rareLoot`, `veryRareLoot`,
  `extremelyRareLoot`.
- `AdventureGuideNavigationService.GetEncounterLoot([encounter])` returns **item IDs**
  with season and difficulty filtering already applied, defaulting to the selected
  encounter. Pass one explicitly to read another boss without navigating to it.
- `LootFilterService.PassesFilter(lootItem)` is the single gate for what the loot view
  shows. Add a filter there rather than filtering at a call site.
- Wishlist entries are **per character**, keyed `"Name-Realm"` under
  `SavedVariables.Wishlists`.

## Artwork

Two patterns, and both are easy to get wrong:

- **`I` is a path generator, not a table of assets.** `lib/TomCats/Images.lua` gives `I`
  a metatable returning `Interface\AddOns\AdventureGuideClassic\images\<key>.png` for
  *any* key. `I.Anything` is therefore never `nil`, so a typo is a silently blank
  texture rather than an error.
- **Use `Atlas.lua`, not `SetAtlas`.** Retail atlas *names* do not reliably resolve in
  the client atlas database on these clients, even when the art exists. `Atlas.lua`
  keeps hand-recorded entries (tex coords plus size) pointing at a sheet we ship in
  `images/`, and `Atlas.SetAtlas()` applies them. Raw Blizzard texture *file* paths
  (`Interface/EncounterJournal/...`) do work directly and are used throughout.

## SavedVariables

`Main.lua` binds `SavedVariables` to `_G.AdventureGuideClassic_Account` on
`ADDON_LOADED`. **Services load before that happens**, so they follow a Load/Store
pattern: in-memory state is the source of truth and is mirrored into SavedVariables once
it exists. `LootFilterService` is the clearest example. Copy it rather than reading
`SavedVariables` at file scope.

## Events and taint

- `Compat.RegisterEvents` skips events the client restricts. Registering a restricted
  event (`COMBAT_LOG_EVENT_UNFILTERED` on some clients) raises
  `ADDON_ACTION_FORBIDDEN`.
- **`pcall` does not suppress `ADDON_ACTION_FORBIDDEN`.** Wrapping a forbidden call
  changes nothing; the popup still fires. Don't try to pre-warm or prime Blizzard
  journal APIs.

## Line endings

`.gitattributes` stores `*.lua`, `*.xml` and `*.toc` as LF in the repository and checks
them out as **CRLF**; `*.sh` is LF everywhere so CI shebangs work. Any script that
rewrites a file wholesale will turn a one-line change into a whole-file diff. If a diff
looks far too large, `git add --renormalize .` is the fix.

**Everything else has no rule**, so git falls back to whoever's `core.autocrlf` is
running. A Windows checkout has it `true` and writes CRLF working copies; the CI
container's git has it unset and reads that CRLF as genuine content. So a `git add .`
run in the container commits a repo-wide line-ending flip -- thousands of changed
lines with no content change. **Stage named files, never `git add .`, from inside a
container.** A commit whose insertions exactly equal its deletions is this bug.

## Checking work without the game

Most logic here can be verified before it ever reaches a client:

- `luac -p <files>` catches syntax errors.
- To exercise a service, load it with a stub environment. The facade's `setfenv` does
  not exist in modern Lua, so stub it and pass your own `_ENV`:

```lua
local env = setmetatable({}, { __index = _G })
env.SavedVariables = {}
local src = assert(io.open("services/LootFilterService.lua")):read("a")
local chunk = assert(load(src, "LootFilterService", "t", env))
chunk("AdventureGuideClassic", { SetupGlobalFacade = function() end })
env.LootFilterService.PassesFilter(...)  -- the real code, no game needed
```

Anything touching frames, templates or textures still needs an in-game pass, and so
does anything client-specific. Say plainly which of the two a change has had.

## Releasing

Branch to release type:

| Branch | Publishes |
|---|---|
| `develop` | alpha |
| `release/*` | beta |
| `main` | release |

The **tag** decides what the workflow publishes, not the branch: a tag containing
`alpha` or `beta` publishes as that, anything else publishes as a release. The table
above is the convention the tags are expected to agree with.

`ci/scripts/publish.sh <bump> [alpha|beta]` bumps the version across every TOC, commits
and tags **locally only** — its push and `gh release` steps are commented out, so
pushing the tag is a separate, deliberate step. `<bump>` is `major`, `minor`, `patch` or
`none`; `none` keeps the version and only re-stamps the prerelease suffix, while
anything else bumps from the base version with an existing suffix stripped (so `minor`
on `1.8.0-alpha.x` gives `1.9.0`, not `1.8.1`).

### Which number to bump

A pre-release is a pre-release **of** the version it names: `1.8.0-alpha.abc1234` sorts
*before* `1.8.0`. So every alpha cut while 1.8.0 is being built keeps the same base and
only re-stamps the suffix, which is what `none` is for and is the normal case during
development.

The base changes when a new release **starts**, not while one is being built:

| Situation | Bump |
|---|---|
| More alphas toward the release being built | `none` |
| Fixes after a stable release shipped | `patch` |
| Features after a stable release shipped | `minor` |

**Measure the scope from the last stable, not from the last alpha.** A release that took
a dozen alphas reads as nothing but fixes if you compare it with the alpha before it,
while being a large release next to what players actually last received.

The trap this avoids is reaching for `patch` because the recent work was fixes, when the
version those fixes belong to has not shipped yet. Cutting 1.8.1 while 1.8.0 exists only
as an alpha leaves a version number that was never released and understates the release.

So the first question is which versions actually shipped:

```sh
git tag | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$'
```

Publish from the branch matching the release type, never from a feature branch.
`develop` and `main` both require a pull request.

Who is allowed to approve, merge and publish is a personal delegation rather than a
property of this project, so it is not recorded here — committing it would hand the same
standing authority to anyone else's agent working in a clone or fork. It lives in
`CLAUDE.local.md`, which is gitignored and imported below if present.

@CLAUDE.local.md

## Changing this file

Agents read these instructions and act on them, so an edit here can change behaviour as
surely as an edit to a Lua file — and this is a public repository that accepts pull
requests. Review changes to `CLAUDE.md` with the same care as code, and be suspicious of
any that arrive alongside unrelated changes. Never put credentials, tokens or private
URLs in it.

## Loot and instance data tags

Loot entries carry a client tag, as `filter` or `seasonFilter` -- both keys work and mean
the same thing:

| Tag | Shown on |
|---|---|
| `all` | every client (the default) |
| `era` | Classic Era only, not SoD, not TBC |
| `sod` | Season of Discovery only |
| `classic` | Era and SoD, not TBC |
| `tbc` | TBC only |
| `forever` | Forever (1.60.x) only |
| `exclusive` | legacy spelling of `sod` |
| `restricted` | legacy: everywhere *except* SoD |

TBC items may also carry `difficulty = "normal"` or `"heroic"`; without it an item shows
on both.

```lua
loot = {
    { id = 872, filter = "era" },                          -- Era only
    { id = 872, filter = "classic" },                      -- Era and SoD
    { id = 27448, filter = "tbc", difficulty = "heroic" },  -- TBC heroic only
}
```

Dungeons tag the same way. **Era raids do not tag at all**: all eleven in
`data/Raids/era/` carry a `season` boolean instead and have no instance-level
`seasonFilter`. `ShouldIncludeInstance` in `services/Instance.lua` returns inside its
`instance.season ~= nil` branch, so adding a tag to one of them would have no effect
either. TBC and Forever raids do carry tags, and those work.

The consequence is that nothing excludes an Era raid from a TBC client, which is why
Naxxramas shows on BCC. Tracked in the issues; do not add a tag to an Era raid and expect
it to be read.

## In-game helpers

`/agc` opens the journal. `/run` the rest:

| Helper | Does |
|---|---|
| `AGC_Probe()` | what the addon thinks it is running on |
| `AGC_PreviewQuests("active")` | draw every quest row in that state (`available`, `active`, `completed`; no argument to clear) |
| `AGC_DebugLootFilter()` | why the selected encounter's loot was filtered |
| `AGC_ToggleDebug()` | encounter-detection debug printing |
| `AGC_ResetInstance("Deadmines")` | clear defeated marks for one instance |
| `AGC_ResetAllEncounters()` | clear them everywhere |
| `AGC_Wishlist()` | print the wishlist |
| `AGC_CheckEquipped()` | re-run the equipped-item wishlist sweep |
| `AGC_NpcPreview(id)` | show an NPC model |
| `TestLevelUpToast()`, `TestLevelUpToastAt(level)` | level-up toast |
| `TestBossDefeatedToast()`, `TestBossDefeatedToastCustom(name)` | defeat toast |
| `TestWishlistToast()`, `TestWishlistToastCustom(itemID)` | wishlist toast |

## Commit and pull request attribution

Commits made by an agent end with a `Co-Authored-By:` line and nothing else. Pull
request bodies carry no attribution footer at all.

So: no `Claude-Session:` trailer, no session URL, and no "Generated with Claude Code"
line on a pull request.

Session links are not readable without authentication, so they leak no conversation, but
this repository is public and a session identifier is not something the maintainer has
chosen to publish permanently in git history. The footer is simply noise: there is one
contributor, and he knows.

## Known, deliberate rough edges

`todo.md` is the running list. Two worth knowing before you "fix" them:

- Era raids carry no instance-level `seasonFilter`, only a `season` boolean, and
  `ShouldIncludeInstance` returns inside the branch that reads it. So nothing excludes
  them from a TBC client and Naxxramas shows on BCC. Left alone because fixing it changes
  what live SoD and TBC players see.
- `data/Raids/era/Onyxias_Lair.lua` is intentionally not registered in `data/Data.xml`;
  its data is wrong. There is a note where its `<Script>` line would go.
