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
5. `services/Services.xml`, `data/Data.xml`, `ui/UI.xml`
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

`Compat.lua` is the only file that may read `GetBuildInfo()` or `WOW_PROJECT_ID`.
Everything else asks it:

- Flags: `Compat.flavor` (`era` / `tbc` / `wrath` / `cata` / `forever` / `retail`),
  `isForever`, `isRetail`, `isTBC`, `isClassicLine`, `isEraClient`, `isVanillaLoot`
  (Era **or** Forever), `tocVersion`
- Season: `GetActiveSeason()`, `HasActiveSeason()`, `IsSoD()`, `IsEra()` — `C_Seasons`
  does not exist on every client, so never call it directly
- Shims: `GetSpellInfo(spellID)` (modern `C_Spell` returns a table, not a list),
  `TabButtonTemplate` (`CharacterFrameTabButtonTemplate` is missing on Forever)
- Events: `RegisterEvents(frame, ...)`, `IsEventAvailable(event)`

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

## Known, deliberate rough edges

`todo.md` is the running list. Two worth knowing before you "fix" them:

- Naxxramas, Zul'Gurub and both Ahn'Qiraj raids ignore their own `seasonFilter`, because
  every raid sets the `season` boolean and the branch reading it returns before any tag
  is checked. Left alone because it changes what live SoD and TBC players see.
- `data/Raids/era/Onyxias_Lair.lua` is intentionally not registered in `data/Data.xml`;
  its data is wrong. There is a note where its `<Script>` line would go.
