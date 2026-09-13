# Suggested Content + Integrated Levelling Guide

Design plan for the `feature/suggested-content` branch.

Status: **Phases 0 and 1 implemented**; Phase 2 onwards still design only.

## Goal

Two features that share one new foundation (a "what should this character do right now?"
service):

1. **Suggested Content tab** — a first tab on the Adventure Guide window, modelled on
   retail's Adventure Guide *Suggested Content*. Tells the player what to do at their
   current level: a zone to level in, a dungeon they're in range for, any live world
   event, and at max level, raid/attunement pointers.
2. **Integrated levelling guide** — a pop-out step-by-step guide window in the same
   "if Blizzard shipped it" visual language as the rest of AGC, launched from the
   Suggested Content tab's zone card.

## Constraints and ground rules

- **JoanasGuides is a style reference only.** `JoanasGuides/license.txt` is
  *"Copyright (C) 2006-2024 JoanasWorld, All rights reserved."* AGC ships GPL-3.0.
  No code, artwork, or guide content may be copied from it. What we take is the
  *idea* of the layout (compact right-anchored frame, portrait ring header, step
  list with per-task icons, next/back/settings header buttons) and rebuild it from
  Blizzard templates the same way the rest of AGC is built. Their guide content is
  Base64-encoded Lua inside `SimpleHTML` frames and is not to be decoded or reused.
- **Route content source: Questie (GPL-3.0).** Compatible with AGC's licence.
  Used as a **build-time** source only (see "Questie importer") — AGC must not gain a
  runtime dependency on Questie being installed.
- **Guide data is bundled inside AGC**, under `data/Guides/`. One addon, one `.toc`,
  one CurseForge package.
- **Dual-client from day one.** Everything must work on Classic Era (`11509`) and
  BCC (`20506`). Feature-detect client APIs rather than assuming — this has bitten us
  before (ScrollBox grid views, issue #39).

## Existing hook points

| Thing | Where |
|---|---|
| Commented-out `Suggest` tab stub | `ui/EncounterJournalTabs.lua:53-57` |
| Tab registration + view switching | `ui/EncounterJournalTabs.lua`, `ui/EncounterJournal.lua` (`component.SetCurrentView`) |
| View pattern to mirror | `ui/InstanceSelect.lua` (anchors into `EncounterJournal.inset`, `UI-EJ-Classic` background) |
| Rich-text rendering | `ui/widgets/` + `ui/DynamicContentScroller.lua` |
| "By level" precedent | `services/SpellsByLevelService.lua` |
| Settings panel | `services/SettingsService.lua` defaults table + `ui/Settings.lua` |
| Python tooling precedent | `tools/atlasloot_tool.py`, `tools/gen_tier_tokens.py` |

---

## Part 1 — Suggested Content

### New services

**`services/PlayerContextService.lua`**
Single source of truth for the character's situation, so every consumer stops
re-deriving it. Exposes `GetLevel()`, `GetMaxLevel()`, `GetClass()`, `GetFaction()`,
`GetRace()`, `GetZone()` (uiMapID), `IsMaxLevel()`, and a `RegisterListener(fn)` that
fires on `PLAYER_LEVEL_UP`, `ZONE_CHANGED_NEW_AREA`, and `PLAYER_ENTERING_WORLD`.

Max level is `GetMaxPlayerLevel()` (60 Era / 70 BCC) — never hard-code 60.

**`services/SuggestedContentService.lua`**
Builds an ordered list of suggestion cards for the current context. Each card is a
plain table so the UI stays dumb:

```lua
{
    type = "zone",                 -- zone | dungeon | raid | event | guide | attunement
    priority = 10,                 -- lower sorts first
    title = "Westfall",
    subtitle = "Levels 10-20",
    description = "...",
    thumbnail = nil,               -- reuse instance thumbnails where we have them
    instance = nil,                -- or `zone`, depending on type
}
```

Cards carry no behaviour. What clicking one does is the view's business
(`ui/SuggestedContent.lua`), keyed off `type`, which keeps this service free of UI
lookups and exercisable headlessly.

Composition rules (first pass):

- Below max level: 1 zone card (primary/hero), 1-2 dungeon cards, plus any active
  event card.
- At max level: raid cards ordered by progression, attunement status cards, plus any
  active event card.
- Event cards always surface when live, regardless of level.

**`services/ZoneService.lua`** + `data/Zones/era.lua`, `data/Zones/tbc.lua`
New dataset. Per zone: `name`, `levelRange = { min, max }`, `faction` (`nil` =
contested/both), `continent`, `rec`, `races` for starting zones, short `overview`, and
an optional `guideID` linking to a levelling guide (Part 2). 38 Era zones, 12 TBC.

**Map ids are never hard-coded.** Era, BCC and retail number their maps differently --
Elwynn Forest is 1429 on Era but 37 on retail -- so a hand-written list is wrong on at
least one client, and wrong *silently*: the card renders fine and just opens the wrong
map. The data carries only the zone's name and `ZoneService` asks the client for the
id, walking the map tree with a bounded scan as fallback. This was learned the hard
way: the first attempt hard-coded retail ids and all 50 were wrong in-game.

**`services/WorldEventService.lua`** + `data/WorldEvents.lua`
Darkmoon Faire and holiday events (Lunar Festival, Love is in the Air, Noblegarden,
Children's Week, Midsummer, Harvest Festival, Hallow's End, Brewfest, Winter Veil).
Per event: name, icon, location(s), date rule, and a one-line "what you can do here".

**Decision: no calendar API at all.** `C_Calendar` is not used, not feature-detected,
not referenced. `data/WorldEvents.lua` is a prepopulated table and the sole source of
truth, and `WorldEventService` just answers "what is live on this date?" against it.

This removes the only in-game unknown from the whole plan and behaves identically on
Era and BCC. Two kinds of entry:

```lua
-- Fixed calendar dates, repeating annually
{ id = "hallowsend", name = "Hallow's End", rule = "fixedDate",
  starts = { month = 10, day = 18 }, ends = { month = 11, day = 1 },
  locations = { { name = "Capital cities" } }, summary = "..." },

-- Rule-based, for events that move
{ id = "darkmoon", name = "Darkmoon Faire",
  rule = "firstMondayOfMonth", duration = 7, rotationOffset = 0,
  locations = {                 -- rotating month by month
    { name = "Elwynn Forest" }, { name = "Mulgore" },
    { name = "Terokkar Forest", expansion = "tbc" },
  },
  summary = "..." },
```

Only two rule kinds are needed (`fixedDate` and `firstMondayOfMonth`), both computed
from `C_DateAndTime.GetCurrentCalendarTime()` with a plain `date()` fallback. Winter
Veil's wrap across the year boundary is the one case needing care in the date maths.

The cost is that dates are maintained by hand when Blizzard shifts a holiday — cheap,
and the table is a single obvious file to edit.

**`services/AttunementService.lua`** + `data/Attunements.lua`
Deliberately *shallow* — a pointer, not a walkthrough, because better addons exist for
the full chains. Per raid: prerequisite summary, the quest chain name, where it starts,
and the key quest IDs. Live status via `IsQuestFlaggedCompleted(questID)` so cards can
read "Attuned" / "Not attuned" rather than generic text.

### Instance data additions

Every dungeon and raid entry needs level metadata it currently lacks
(`data/Dungeons/{era,tbc}/*.lua`, `data/Raids/{era,tbc}/*.lua` — ~55 files):

```lua
levelRange = { min = 13, max = 18 },
recommendedLevel = 15,
faction = nil,            -- "Alliance" | "Horde" | nil for both
continent = "Kalimdor",
```

Batch-applied with a new `tools/add_instance_levels.py` (same shape as the existing
AtlasLoot tool) rather than by hand, then reviewed in the diff.

### UI

**`ui/SuggestedContent.lua`** — a new view component registered like `InstanceSelect`,
anchored into `EncounterJournal.inset`, using the same `UI-EJ-Classic` background so it
reads as part of the same window.

Layout follows retail's Suggest tab: one large hero card across the top, secondary
cards below it. Card buttons reuse the visual treatment in
`ui/InstanceSelectTemplates.xml` for consistency.

Avoid `WowScrollBoxList` grid views here if a plain `ScrollFrame` will do — that is the
exact API surface that diverges between Era and BCC (`SetElementExtent` vs
`SetElementSize`). If a ScrollBox is needed, feature-detect as `ui/InstanceSelect.lua`
already does.

**`ui/EncounterJournalTabs.lua`** — uncomment and wire the `Suggest` tab, and make it
tab index 1 so it is the default view (retail puts Suggested first). This shifts
Dungeons/Raids to 2/3; check the `EncounterJournal.Tabs[1]:GetScript("OnClick")()` call
at the end of `Init` still does the right thing.

---

## Part 2 — Integrated levelling guide

### Guide data format

Plain, readable, hand-editable Lua — explicitly *not* the Base64/SimpleHTML packaging
Joana's uses. Registered through the same `Add*` pattern as instances and spells:

```lua
GuideService.AddGuide({
    id       = "era-alliance-elwynn-1-10",
    module   = "era",
    faction  = "Alliance",
    levels   = { min = 1, max = 10 },
    zone     = 37,                       -- uiMapID
    title    = "Elwynn Forest (1-10)",
    next     = "era-alliance-westfall-10-20",
    steps = {
        { "accept", quest = 783,  npc = 197, loc = { 37, 41.7, 65.9 } },
        { "kill",   quest = 783,  npc = 299, count = 10 },
        { "turnin", quest = 783,  npc = 197 },
        { "hearth", loc = { 37, 42.1, 65.6 }, note = "Set hearth at Goldshire" },
        { "level",  level = 6 },
    },
})
```

Task types (one file each, mirroring how `ui/widgets/` registers widget types):
`accept`, `turnin`, `kill`, `collect`, `goto`, `hearth`, `sethearth`, `taxi`,
`vendor`, `train`, `level`, `note`.

### Questie importer

`tools/questie_import.py` — build-time only. Reads Questie's GPL-3.0 quest/NPC/object
databases for Era and TBC, and emits **only the entries our route files actually
reference** into `data/Guides/QuestData_era.lua` / `_tbc.lua` (quest name, objectives
text, NPC name + coordinates, required level, faction).

This is the decision that keeps the feature honest: AGC stays standalone (no
`OptionalDeps: Questie`, works for users who don't run it) and the bundled data stays
small because it is scoped to the routes we ship. GPL-3.0 attribution goes in a header
comment in the generated files and in the addon's licence notes.

### Services

- **`services/GuideService.lua`** — guide registry, lookup by faction/level/zone,
  current guide + step persisted in `AdventureGuideClassic_Lockout`
  (SavedVariablesPerCharacter — progress is per character, not per account).
- **`services/GuideProgressService.lua`** — auto-advance from game events:
  `QUEST_ACCEPTED`, `QUEST_TURNED_IN`, `QUEST_LOG_UPDATE`, `UNIT_QUEST_LOG_CHANGED`,
  `PLAYER_LEVEL_UP`, `BAG_UPDATE`. Manual next/back always overrides.
- **`services/GuideWaypointService.lua`** — waypoint arrow + world-map/minimap pins for
  the current step, reusing `lib/TomCats/Maps.lua` patterns and the existing
  `ui/Map.lua`. TomTom as an optional integration, not a requirement.

### UI

- **`ui/guide/GuideWindow.lua`** — the pop-out. **Decision: it floats**, parented to
  `UIParent` rather than to the Adventure Guide frame, so it stays up while the main
  window is closed. That is the whole point — you read it while questing, not while
  browsing the journal. Built from `BackdropTemplate` with
  `BACKDROP_GLUE_TOOLTIP_16_16`, narrow (~242px) and auto-sizing to the step content.

  Behaviours to match (rebuilt from Blizzard templates, not copied):

  | Behaviour | Notes |
  |---|---|
  | Default anchor top-right | Roughly `TOPRIGHT, -15, -330` — clear of the minimap and buff bars |
  | Left-drag to move | Position saved account-wide; re-validated on load so a resolution change can't strand it off-screen |
  | Right-click passes through | `SetPassThroughButtons("RightButton")` so right-click still turns the camera. **Feature-detect it** — it does not exist on every client |
  | Clamped to screen | `SetClampedToScreen(true)` |
  | Lockable | Lock disables mouse entirely so clicks fall through to the world, not just "can't drag" |
  | Independently scalable | Its own scale setting, separate from the main window's `SettingsService.GetScale()` |
  | Auto-hide in instances | On by default, suppressed when the current step *is* an instance step |
  | Combat-safe | Guard scale/size changes behind `InCombatLockdown()` |
  | Screen-side aware | Detect which half of the screen it sits on so menus and tooltips open away from the edge |
  | Minimal chrome | No title bar or close button; the header *is* the chrome |
  | Shown state persisted | Toggled via slash command, minimap button and a keybind (`Bindings.lua` already exists) |
- **`ui/guide/GuideHeader.lua`** — portrait ring (AGC's own EJ portrait art, masked the
  way `EncounterJournal.portrait` is), title, step counter, back / next / settings
  buttons.
- **`ui/guide/GuideStepList.lua`** — the current step's tasks with per-type icons and
  completion state.
- **`ui/guide/tasks/*.lua`** — one mixin per task type, registered like widget types.
- **`ui/guide/GuideMenu.lua`** — pick guide / jump to zone / reset progress.

### Wiring back to Part 1

The Suggested Content zone card's `onClick` calls
`GuideService.StartGuideForLevel(level, faction)` and shows the guide window at the
right step. That closes the loop: *"here's where to level"* → *"here's exactly what to
do there"*.

---

## Phasing

Each phase is a self-contained commit set on `feature/suggested-content`; the branch is
mergeable after any of them.

| Phase | Scope | Ships something usable? |
|---|---|---|
| 0 | ~~`PlayerContextService`, instance level metadata + `tools/add_instance_levels.py`, settings scaffolding~~ **done** | No (groundwork) |
| 1 | ~~`ZoneService` + zone data, `SuggestedContentService`, Suggest tab UI with zone + dungeon cards~~ **done** | **Yes** |
| 2 | ~~`WorldEventService` + `data/WorldEvents.lua` table + event cards~~ **done** | **Yes** |
| 3 | Max-level content: raid cards, `AttunementService` + status | **Yes** |
| 4 | Guide window shell + step list + one hand-authored pilot guide (Elwynn 1-10) | **Yes** (preview quality) |
| 5 | `GuideProgressService` auto-advance + waypoints/map pins | **Yes** |
| 6 | `tools/questie_import.py` + full 1-60 Era route content | **Yes** |
| 7 | Suggested Content → guide wiring; BCC 58-70 routes | **Yes** |

## Decisions

**Guide window: floats.** Parented to `UIParent`, top-right by default. See the
behaviour table above.

**Expansion filter: Suggested Content always follows the live client.** It does *not*
read the Classic/BCC dropdown in `ui/InstanceSelect.lua` — that dropdown stays a
browsing convenience for the Dungeons and Raids tabs. Suggestions describe what this
character can actually do right now, so they are driven by
`PlayerContextService` (level, faction, client) alone. This also means
`SuggestedContentService` must do its own level-gating rather than leaning on the
filter, and `InstanceService.GetDungeons()` — which *does* apply the user filter — is
the wrong entry point. Suggested Content needs an unfiltered accessor:
add `InstanceService.GetAllDungeons()` / `GetAllRaids()` that apply only the
client/season rules from `ShouldIncludeInstance`, not `GetExpansionFilter()`.

**Season of Discovery: treated as Era for now.** SoD characters get standard Era zone
and dungeon suggestions. `C_Seasons.GetActiveSeason()` is already wired up for loot
filtering, so SoD-specific rules (phase level caps, the BFD and Gnomeregan raids,
rune hunting) can be layered on later behind that same check. Revisit once the core
tab has shipped.

**Settings toggles: all four ship.** Added to the `defaults` table in
`services/SettingsService.lua` and surfaced in `ui/Settings.lua`:

| Setting | Default | Notes |
|---|---|---|
| Suggested Content as default tab | **off** | Existing users keep opening on Dungeons; new behaviour is opt-in |
| Guide window: show / lock / scale | shown, unlocked, 1.0 | Scale is independent of the main window's `SettingsService.GetScale()` |
| Auto-advance steps | **on** | Off means the player drives with Next/Back only |
| Guide waypoints on map/minimap | **on** | Independent of the guide window, for users already running TomTom |

Following the `LevelUpSpells` precedent already in `SettingsService`: anything whose
underlying data is still being validated ships **off** by default and is opt-in.

## Open questions

- Guide step granularity — one screenful of tasks per "step" (Joana's model), or one
  task per step with a progress bar? Decide during Phase 4 against the pilot guide.

## Testing

No unit tests exist and there is no local Lua tooling — verification is in-game
(`/reload`, exercise the UI) on **both** an Era and a BCC client. Add `/run` debug
helpers to `todo.md` as we go, matching the existing convention
(`TestLevelUpToastAt(40)`, `TestBossDefeatedToast()`), e.g.
`AGC_TestSuggestionsAt(level)` to preview suggestions at an arbitrary level without
levelling a character.
