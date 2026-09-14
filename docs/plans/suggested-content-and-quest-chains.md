# Suggested Content + Quest Chains

Design plan for the `feature/suggested-content` branch.

Status: **Phases 0-3 shipped** (Suggested Content, world events). Phases 4-5 were built
as a levelling guide, then removed in favour of quest chains -- see Part 2 for why.

## Goal

Two features that share one new foundation (a "what should this character do right now?"
service):

1. **Suggested Content tab** — a first tab on the Adventure Guide window, modelled on
   retail's Adventure Guide *Suggested Content*. Tells the player what to do at their
   current level: a zone to level in, a dungeon they're in range for, any live world
   event, and at max level, raid/attunement pointers.
2. **Quest chains** — a Quests tab beside Dungeons and Raids, showing quest chains,
   prerequisites and where this character stands on each. Not a route: the point is to
   stop people getting lost in long chains, not to level them fastest. See Part 2.

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

## Part 2 — Quest chains (replaces the levelling guide)

**This part was rebuilt from scratch after Phases 4 and 5 shipped.** What was built
first was a speed-levelling guide: a floating window stepping through a hand-authored
route, with auto-accept and auto-turn-in. It worked, and it was the wrong product.

### Why it changed

A route guide and an Adventure Guide are opposite things. A speed route says "do
exactly this, in this order, don't think". The Adventure Guide is an encyclopedia:
here is what exists, here is what is in it, here is what you need to get in. This
addon already does that for dungeons and raids; a stepper sat awkwardly inside it and
every styling round made that clearer, not less.

The problem actually worth solving is the one Questie leaves untouched. Questie tells
you where a quest is. It does not tell you that this is step 3 of 7, that the next one
needs level 22, or that the chain ends in something worth having. Long chains and
hidden prerequisites are where people get lost, and nothing on Classic addresses it.

Three things follow from the change:

- It is unmistakably this addon's own product. A quest-chain browser inside a dungeon
  journal is not something any other guide addon offers, which also ends the question
  of whether the UI looks borrowed.
- The content cost collapses. Hand-authoring routes for two factions across 1-60 was
  the largest unwritten cost in this plan. A chain browser needs no routes at all --
  it needs the quest graph, and Questie's GPL-3.0 database already carries exactly
  that: `preQuestSingle`, `preQuestGroup`, `exclusiveTo`, `parentQuest`,
  `requiredLevel`, `requiredRaces`.
- The Questie importer stops being a supplement and becomes the whole data story.

### What was kept

`QuestLogService` -- the quest-state reading from the old `GuideProgressService`.
Reading the log, detecting completion across differing client APIs, tracking
objectives and remembering hand-ins per character is precisely the new product's
foundation; it was only ever incidental to the stepper.

### What was removed

The guide window, its options panel, the step/task format, the hand-authored pilot
guide, and `AutoQuestService`. Auto-accept and auto-turn-in are speed-run features
that pull against a product about understanding what you are doing, and they carried a
running cost in client-API fragility across three different NPC interaction paths.

### Shape

**`services/QuestChainService.lua`** — the quest graph. For any quest: its chain, its
position in it, what it requires, what it unlocks, and this character's status on each
link (done / available / blocked, and why blocked).

**`data/Quests/{era,tbc}/*.lua`** — generated, never hand-written. Quest name, level,
prerequisites, follow-ups, faction/race/class gating, zone, and the reward worth
mentioning.

**`tools/questie_import.py`** — build-time only, as before. AGC gains no runtime
dependency on Questie being installed.

**`ui/QuestSelect.lua` / `ui/QuestChain.lua`** — a Quests tab beside Dungeons and
Raids. Browse by zone, see chains as a tree, see where you stand on each.

No floating windows. The tab is the product.

## Phasing

Each phase is a self-contained commit set on `feature/suggested-content`; the branch is
mergeable after any of them.

| Phase | Scope | Ships something usable? |
|---|---|---|
| 0 | ~~`PlayerContextService`, instance level metadata + `tools/add_instance_levels.py`, settings scaffolding~~ **done** | No (groundwork) |
| 1 | ~~`ZoneService` + zone data, `SuggestedContentService`, Suggest tab UI with zone + dungeon cards~~ **done** | **Yes** |
| 2 | ~~`WorldEventService` + `data/WorldEvents.lua` table + event cards~~ **done** | **Yes** |
| 3 | Max-level content: raid cards, `AttunementService` + status | **Yes** |
| 4 | ~~Guide window shell + step list + pilot guide~~ **built, then removed** -- see Part 2 | — |
| 5 | ~~Auto-advance + auto accept/hand-in~~ **built, then removed**. `QuestLogService` kept from it | — |
| 6 | `tools/questie_import.py` + generated quest graph data | **Yes** |
| 7 | `QuestChainService` + the Quests tab | **Yes** |

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
