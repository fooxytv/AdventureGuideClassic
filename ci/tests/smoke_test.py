#!/usr/bin/env python3
"""Load and exercise the addon against a stubbed WoW client.

luacheck parses and check_globals approximates; this runs. It catches the failures
neither can see -- load order mistakes, indexing a nil table, an API branch that was
never taken -- which otherwise only appear after a /reload in game.

Files are read out of Main.xml rather than the .toc, because the .toc lists only
Main.xml. Script and Include elements are followed recursively, so a file is covered
the moment it is wired into the load order.

The addon is loaded once per client. That is the point: the stub owns GetBuildInfo,
WOW_PROJECT_ID and whether C_Seasons exists, so Era, SoD, BCC and Forever can each be
checked here instead of on four machines. Every Compat regression this project has
shipped was a wrong answer to one of those.

Scope: Compat, services/ and data/. The ui/ layer additionally needs ScrollUtil,
CreateDataProvider and CreateScrollBoxListLinearView in the stub.

    python ci/tests/smoke_test.py

Requires: pip install lupa
"""

import re
import sys
from pathlib import Path

try:
    from lupa import LuaRuntime
except ImportError:
    print("smoke_test: lupa is not installed (pip install lupa) - skipping.")
    sys.exit(0)

ROOT = Path(__file__).resolve().parents[2]
STUB = Path(__file__).with_name("wow_stub.lua")
ADDON = "AdventureGuideClassic"

# ui/ needs a widget surface this stub does not carry yet; the rest load the addon's
# own entry point as the client would. SlashCommands, Bindings, Main and Probe are
# wiring for a running client rather than logic worth asserting on.
SKIP = (
    "ui/",
    "lib/TomCats/MinimapButton",
    "SlashCommands.lua",
    "Bindings.lua",
    "Main.lua",
    "Probe.lua",
)

failures = []


# The widget layer, loaded on top of the addon rather than as part of it. These
# files are under ui/ and so skipped above, but only their Construct functions need
# a real frame, and Construct is not called here -- IsTypeFor needs nothing at all.
# Order follows ui/UI.xml, because each type registers itself as it loads and
# GetTypeForContent returns the first match.
WIDGET_FILES = (
    "ui/widgets/Widgets.lua",
    "ui/widgets/WidgetTypeMixin.lua",
    "ui/widgets/CollapsibleSectionWidgetTypeMixin.lua",
    "ui/widgets/Root.lua",
    "ui/widgets/Text.lua",
    "ui/widgets/Heading.lua",
    "ui/widgets/Role.lua",
    "ui/widgets/Section.lua",
    "ui/widgets/Spell.lua",
    "ui/widgets/Ability.lua",
    "ui/widgets/NPC.lua",
)


def check(name, actual, expected):
    if actual != expected:
        failures.append(f"{name}: expected {expected!r}, got {actual!r}")
        print(f"    FAIL {name}: expected {expected!r}, got {actual!r}")
    else:
        print(f"    ok   {name} = {actual!r}")


def xml_files(xml_path, seen):
    """Lua files reachable from an XML file, in load order, following Includes."""
    out = []
    text = xml_path.read_text(encoding="utf-8", errors="replace")
    base = xml_path.parent
    for kind, raw in re.findall(
        r'<(Script|Include)\s+file="([^"]+)"', text, re.IGNORECASE
    ):
        rel = raw.replace("\\", "/")
        # The addon's XML names files from the addon root, not from the including
        # file's own directory -- services/Services.xml says "services/Instance.lua".
        # Root first, then relative, so either convention resolves.
        target = (ROOT / rel).resolve()
        if not target.exists():
            target = (base / rel).resolve()
        try:
            key = target.relative_to(ROOT).as_posix()
        except ValueError:
            continue
        if key in seen:
            continue
        seen.add(key)
        if kind.lower() == "include":
            if target.exists():
                out.extend(xml_files(target, seen))
        else:
            out.append(key)
    return out


def addon_files():
    files = xml_files(ROOT / "Main.xml", set())
    return [f for f in files if not any(f.startswith(s) or f == s for s in SKIP)]


def load_addon(lua, files):
    """Load every file, reproducing the global facade's environment semantics."""
    lua.execute("__ns = {}")

    make_chunk = lua.eval(
        'function(src, name, env)'
        '  if env then return assert(load(src, name, "t", env)) end'
        '  return assert(load(src, name))'
        'end'
    )

    facade = None
    loaded = 0
    for rel in files:
        source = (ROOT / rel).read_text(encoding="utf-8", errors="replace")
        chunk = make_chunk(source, "@" + rel, facade)
        chunk(ADDON, lua.globals().__ns)
        loaded += 1

        # GlobalFacade.lua builds the table and exports SetupGlobalFacade. Calling it
        # here lets the stubbed setfenv capture the real table, which then becomes the
        # _ENV for every later file -- exactly what setfenv(2, globalFacade) does. So
        # the addon's own facade is under test rather than a copy of it.
        if facade is None and rel.endswith("GlobalFacade.lua"):
            lua.execute("__ns.SetupGlobalFacade()")
            facade = lua.globals().__CapturedFacade
            if facade is None:
                raise SystemExit("smoke_test: could not capture the global facade")
    return facade, loaded


def load_widgets(lua, facade):
    """Load the widget type files into the same facade environment."""
    make_chunk = lua.eval(
        'function(src, name, env) return assert(load(src, name, "t", env)) end'
    )
    for rel in WIDGET_FILES:
        source = (ROOT / rel).read_text(encoding="utf-8", errors="replace")
        make_chunk(source, "@" + rel, facade)(ADDON, lua.globals().__ns)


# Asserted in Lua and handed back as plain values, so nothing depends on how lupa
# marshals a table whose __index falls through to _G.
#
# Loaded with the facade as its environment, exactly like an addon file: Compat and
# the services are on the facade, not in _G, so a chunk compiled against _G would
# find every one of them nil.
PROBE = """
    -- Stands in for Main.lua, which binds SavedVariables on ADDON_LOADED. Services
    -- load before that, so this is the state they are actually called in. Note that
    -- InstanceService.GetExpansionFilter indexes SavedVariables unguarded, unlike
    -- LootFilterService, so without this the first GetDungeons() call errors.
    SavedVariables = SavedVariables or {}

    local out = {}
    out.flavor = Compat.flavor
    out.tocVersion = Compat.tocVersion
    out.isForever = Compat.isForever and 1 or 0
    out.isTBC = Compat.isTBC and 1 or 0
    out.isClassicLine = Compat.isClassicLine and 1 or 0
    out.isEraClient = Compat.isEraClient and 1 or 0
    out.isVanillaLoot = Compat.isVanillaLoot and 1 or 0
    out.isSoD = Compat.IsSoD() and 1 or 0
    out.isEra = Compat.IsEra() and 1 or 0
    out.season = Compat.GetActiveSeason()
    out.combatLogAvailable = Compat.IsEventAvailable("COMBAT_LOG_EVENT_UNFILTERED") and 1 or 0
    -- Exercises both Compat.GetSpellInfo branches: C_Spell on Forever, the global on
    -- the Classic line. One shape for every client would leave one branch dead.
    local spellName, spellIcon = Compat.GetSpellInfo(123)
    out.spellName = spellName or "nil"
    out.spellIcon = spellIcon or 0

    out.tabTemplate = Compat.TabButtonTemplate
    -- The template Compat picks must actually exist on the client it picked it for.
    out.tabTemplateExists = _G[Compat.TabButtonTemplate] ~= nil and 1 or 0
    out.dungeons = #InstanceService.GetDungeons()
    out.raids = #InstanceService.GetRaids()
    out.instances = #InstanceService.GetAllInstances()

    -- One item per tag, so the filter's verdict per client is visible at a glance.
    local encounter = { loot = {
        { id = 1, filter = "all" },
        { id = 2, filter = "era" },
        { id = 3, filter = "sod" },
        { id = 4, filter = "classic" },
        { id = 5, filter = "tbc" },
        { id = 6, filter = "forever" },
        { id = 7, filter = "restricted" },
    } }
    local kept = {}
    for _, id in ipairs(AdventureGuideNavigationService.GetEncounterLoot(encounter).loot) do
        kept[#kept + 1] = tostring(id)
    end
    out.loot = table.concat(kept, ",")

    --[[
        Every ability entry in the data has to be claimed by a widget type. Root.lua
        calls SetContents on whatever GetTypeForContent hands back, so an unclaimed
        entry is a Lua error in the journal rather than a gap in the panel -- which
        is what kept the Abilities tab switched off.

        Counted under both expansion filters: GetDungeons hides the TBC instances
        under "classic" and the Era ones under "tbc", so one pass sees half the
        data.
    ]]
    local claimed, unclaimed, miscast = 0, 0, 0
    local previousFilter = SavedVariables.ExpansionFilter
    for _, expansionFilter in ipairs({ "classic", "tbc" }) do
        SavedVariables.ExpansionFilter = expansionFilter
        for _, list in ipairs({ InstanceService.GetDungeons(), InstanceService.GetRaids() }) do
            for _, instance in ipairs(list) do
                for _, encounter in ipairs(instance) do
                    for _, entry in ipairs(encounter.abilities or {}) do
                        local widgetType = Widgets.GetTypeForContent(entry)
                        if widgetType then
                            claimed = claimed + 1
                            --[[
                                Claimed is not enough: the first type whose IsTypeFor
                                passes wins, and Heading registers before Spell, so
                                { spell = N, heading = true } was claimed by Heading
                                and fed SetText a boolean. Only the two collapsible
                                types render a boss ability.
                            ]]
                            if widgetType.name ~= "Spell" and widgetType.name ~= "Ability" then
                                miscast = miscast + 1
                            end
                        else
                            unclaimed = unclaimed + 1
                        end
                    end
                end
            end
        end
    end
    SavedVariables.ExpansionFilter = previousFilter
    out.unclaimedAbilities = unclaimed
    out.miscastAbilities = miscast
    out.claimedAbilities = claimed

    --[[
        Defeat progress has to survive a reload. It used to live only on the instance
        table, which is rebuilt from the data files on every login, so every tick was
        lost. Round-trip it the way a session would: record, wipe the in-memory field
        the way a fresh login does, hydrate, and check it came back.
    ]]
    -- The first dungeon is not necessarily populated: Forever ships instances the
    -- client lists but we have no encounters for yet. Take the first that has one.
    local probeInstance, probeEncounter
    for _, candidate in ipairs(InstanceService.GetDungeons()) do
        if candidate[1] then
            probeInstance, probeEncounter = candidate, candidate[1]
            break
        end
    end
    if probeEncounter then
        local charKey = UnitName("player") .. "-" .. GetRealmName()

        --[[
            A write before the first read must not replace this character's history.
            Store writes the in-memory table wholesale, so without the load guard in
            ProgressService the first MarkDefeated of a session would leave only the
            boss that triggered it and drop everything earned before.
        ]]
        SavedVariables.Progress = { [charKey] = { defeated = { ["Seeded|Boss"] = true } } }
        ProgressService.MarkDefeated(probeInstance.name, probeEncounter)
        out.progressKeptPriorHistory =
            SavedVariables.Progress[charKey].defeated["Seeded|Boss"] and 1 or 0

        ProgressService.ClearAll()
        out.progressStartsClear = ProgressService.IsDefeated(probeInstance.name, probeEncounter) and 0 or 1

        ProgressService.MarkDefeated(probeInstance.name, probeEncounter)
        out.progressRecorded = ProgressService.IsDefeated(probeInstance.name, probeEncounter) and 1 or 0

        -- Written through to SavedVariables under this character, not the account.
        local stored = SavedVariables.Progress and SavedVariables.Progress[charKey]
        out.progressPersisted = (stored and stored.defeated and next(stored.defeated)) and 1 or 0

        probeEncounter.defeated = 0
        ProgressService.Hydrate()
        out.progressHydrated = probeEncounter.defeated == 1 and 1 or 0

        ProgressService.ClearInstance(probeInstance.name)
        out.progressCleared = ProgressService.IsDefeated(probeInstance.name, probeEncounter) and 0 or 1
        probeEncounter.defeated = 0

        --[[
            Clearing one instance must leave every other instance alone. ClearInstance
            writes the whole in-memory table back, so a fault there wipes the lot
            rather than the one instance asked for.
        ]]
        local otherInstance, otherEncounter
        for _, candidate in ipairs(InstanceService.GetDungeons()) do
            if candidate[1] and candidate.name ~= probeInstance.name then
                otherInstance, otherEncounter = candidate, candidate[1]
                break
            end
        end
        if otherEncounter then
            ProgressService.MarkDefeated(probeInstance.name, probeEncounter)
            ProgressService.MarkDefeated(otherInstance.name, otherEncounter)
            ProgressService.ClearInstance(probeInstance.name)
            out.progressClearIsScoped =
                (ProgressService.IsDefeated(otherInstance.name, otherEncounter)
                    and not ProgressService.IsDefeated(probeInstance.name, probeEncounter))
                and 1 or 0
            ProgressService.ClearAll()
        end

        --[[
            A stored defeat must be clearable even when the instance it belongs to
            cannot be looked up -- filtered out for this client or season, or simply
            gone from the data. ClearInstance used to rebuild its keys by walking
            GetInstanceByName, which returns nil in that case and cleared nothing,
            while Hydrate walks every instance and put the defeat straight back.
        ]]
        ProgressService.MarkDefeated("No Such Instance", { name = "Ghost Boss" })
        ProgressService.ClearInstance("No Such Instance")
        out.progressClearsUnresolvable =
            ProgressService.IsDefeated("No Such Instance", { name = "Ghost Boss" })
                and 0 or 1
        ProgressService.ClearAll()
    end

    --[[
        Two encounters sharing a progress key would mark each other beaten. This is
        why the key is the instance and encounter name rather than encounterID, which
        is not unique: Blackrock Spire gives Pyroguard Emberseer and Solakar
        Flamewreath the same id, and a dungeon and its SoD raid reuse ids across the
        pair.
    ]]
    local seenKey, keyCollisions = {}, 0
    for _, list in ipairs({ InstanceService.GetDungeons(), InstanceService.GetRaids() }) do
        for _, instance in ipairs(list) do
            for _, encounter in ipairs(instance) do
                local key = instance.name .. "|" .. tostring(encounter.name)
                if seenKey[key] then keyCollisions = keyCollisions + 1 end
                seenKey[key] = true
            end
        end
    end
    out.progressKeyCollisions = keyCollisions

    --[[
        Discovery mode must hide a boss that has not been beaten and reveal it when
        it has, without revealing the rest of the instance. Off, it must change
        nothing at all -- that is the default and the common case.

        What everything below rests on is the boss having something to hide. A boss
        with no loot and no abilities measures zero before and zero after, so every
        comparison here would read 0 == 0 and the whole block would go green against
        a mode that did nothing. So the boss is searched for rather than taken as the
        first one going, and the baseline is asserted non-empty rather than assumed.

        Both dimensions are preferred and neither is required, because the data will
        not support requiring them. Dungeon abilities are barely authored yet: 22
        bosses have any on Forever, 2 on Era and TBC, and none at all on SoD, whose
        one dungeon holding them is filtered out. Demanding both would have left SoD
        with no boss to test rather than a weaker test.
    ]]
    local function measure(whichInstance, target)
        AdventureGuideNavigationService.SetInstance(whichInstance)
        AdventureGuideNavigationService.SetEncounter(target)
        local l = AdventureGuideNavigationService.GetEncounterLoot()
        return #l.loot + #l.sharedLoot + #l.rareLoot + #l.veryRareLoot
            + #l.extremelyRareLoot,
            #AdventureGuideNavigationService.GetEncounterAbilities(),
            AdventureGuideNavigationService.GetEncounterName()
    end

    DiscoveryService.SetEnabled(false)
    ProgressService.ClearAll()
    local discInstance, discFirst, discSecond
    -- Pass 1 wants both, pass 2 settles for either.
    for _, wantBoth in ipairs({ true, false }) do
        for _, candidate in ipairs(InstanceService.GetDungeons()) do
            -- Two bosses at least, so "revealing one does not reveal its
            -- neighbour" has a neighbour to check.
            if #candidate >= 2 then
                for index, target in ipairs(candidate) do
                    local loot, abilities = measure(candidate, target)
                    local enough = wantBoth and (loot > 0 and abilities > 0)
                        or (not wantBoth and loot + abilities > 0)
                    if enough then
                        discInstance, discFirst = candidate, target
                        discSecond = candidate[index == 1 and 2 or 1]
                        break
                    end
                end
            end
            if discInstance then break end
        end
        if discInstance then break end
    end
    if discInstance then
        local first, second = discFirst, discSecond

        ProgressService.ClearAll()
        DiscoveryService.SetEnabled(false)
        local lootOff, abilitiesOff, nameOff = measure(discInstance, first)
        --[[
            The baseline, and the one thing here that may not be empty or wrong:
            every check below is measured against it.
        ]]
        out.discoveryBaselineNonEmpty = (lootOff + abilitiesOff > 0) and 1 or 0
        out.discoveryOffRevealsUnmet =
            AdventureGuideNavigationService.IsEncounterDiscovered(first) and 1 or 0
        out.discoveryOffKeepsName =
            (nameOff ~= DiscoveryService.UNKNOWN_NAME and nameOff == first.name)
                and 1 or 0

        DiscoveryService.SetEnabled(true)
        local lootHidden, abilitiesHidden, nameHidden = measure(discInstance, first)
        out.discoveryHidesUnmet = (lootHidden == 0 and abilitiesHidden == 0) and 1 or 0
        out.discoveryHidesName =
            (nameHidden == DiscoveryService.UNKNOWN_NAME) and 1 or 0

        ProgressService.MarkDefeated(discInstance.name, first)
        local lootShown, abilitiesShown, nameShown = measure(discInstance, first)
        out.discoveryRevealsOnDefeat =
            (lootShown == lootOff and abilitiesShown == abilitiesOff) and 1 or 0
        out.discoveryRevealsName = (nameShown == nameOff) and 1 or 0
        out.discoveryIsPerBoss =
            AdventureGuideNavigationService.IsEncounterDiscovered(second) and 0 or 1

        -- The "2/4 discovered" note. One beaten, out of however many bosses the
        -- instance the search landed on happens to have.
        local found, total = DiscoveryService.GetProgress(discInstance)
        out.discoveryProgressCountsOne =
            (found == 1 and total == #discInstance) and 1 or 0

        --[[
            Resetting the instance makes its bosses alive again; it does not make the
            player forget meeting them. Discovery read the defeat set directly, so a
            routine dungeon reset put ??? back over bosses already seen.
        ]]
        ProgressService.ClearInstance(discInstance.name)
        out.discoverySurvivesReset =
            AdventureGuideNavigationService.IsEncounterDiscovered(first)
                and 1 or 0
        out.discoveryResetClearsDefeat =
            ProgressService.IsDefeated(discInstance.name, first) and 0 or 1

        DiscoveryService.SetEnabled(false)
        ProgressService.ClearAll()
        out.discoveryDefaultsOff = DiscoveryService.IsEnabled() and 0 or 1
    end
    -- Both Compat.GetSpellDescription branches, one per client shape, and the empty
    -- string the client gives before spell data loads must read back as nil.
    out.spellDescription = Compat.GetSpellDescription(12054) or "nil"
    out.spellDescriptionUnknown = Compat.GetSpellDescription(0) == nil and 1 or 0
    out.spellDescriptionNoId = Compat.GetSpellDescription(nil) == nil and 1 or 0

    -- Only the mainline family can be asked to load spell data; the Classic clients
    -- have the description already, so there is nothing to request.
    out.requestsSpellData = Compat.RequestSpellData(1292602) and 1 or 0
    out.requestSpellDataNoId = Compat.RequestSpellData(nil) and 1 or 0

    --[[
        No ability entry should draw without an icon or a body. A bare { spell = N }
        has neither in the data and the client supplies both, so a miss here means an
        entry shape the icon or description path does not reach -- the two shapes,
        { spell = N } and { id, name, description }, are read differently.
    ]]
    local missingIcon, missingBody = 0, 0
    local prev = SavedVariables.ExpansionFilter
    for _, expansionFilter in ipairs({ "classic", "tbc" }) do
        SavedVariables.ExpansionFilter = expansionFilter
        for _, list in ipairs({ InstanceService.GetDungeons(), InstanceService.GetRaids() }) do
            for _, instance in ipairs(list) do
                for _, encounter in ipairs(instance) do
                    for _, entry in ipairs(encounter.abilities or {}) do
                        local id = entry.spell or entry.id
                        local _, icon = Compat.GetSpellInfo(id)
                        if not icon then missingIcon = missingIcon + 1 end
                        if not (#entry > 0 or entry.description
                            or Compat.GetSpellDescription(id)) then
                            missingBody = missingBody + 1
                        end
                    end
                end
            end
        end
    end
    SavedVariables.ExpansionFilter = prev
    out.abilitiesMissingIcon = missingIcon
    out.abilitiesMissingBody = missingBody
    --[[
        The seasonal window, asked about dates rather than about today -- which is
        the only way its edges can be checked at all, since a test that asked what
        is running now would answer differently every day of the year.

        Both edges are inclusive, so the day before and the day after are checked
        as well as the days themselves.
    ]]
    local function season(month, day)
        return SeasonalService.GetEventFor(month, day) or "none"
    end
    out.seasonBeforeStart = season(10, 17)
    out.seasonOnStart = season(10, 18)
    out.seasonMidway = season(10, 25)
    out.seasonOnEnd = season(11, 1)
    out.seasonAfterEnd = season(11, 2)
    out.seasonFarOff = season(3, 14)
    out.seasonNoDate = season(nil, nil)

    --[[
        The wishlist grouped by instance, which is what the wishlist tab draws a row
        from. Only the service side is reachable here, since ui/ needs frames, so the
        grouping, the boss de-duplication and the obtained filter are asserted here
        rather than left to an in-game look.

        Nothing asserts the order of the groups. Four items added in a loop all take
        the same timestamp, and the sort that orders them is not stable, so an order
        assertion would pass or fail on which way pairs() happened to walk.
    ]]
    local function DeadminesGroup(includeObtained)
        for _, group in ipairs(WishlistService.GetGrouped(includeObtained)) do
            if group.name == "Deadmines" then return group end
        end
        return nil
    end

    WishlistService.ClearAll()
    WishlistService.AddItem(101, "link101", "Item 101", "Mr. Smite", "Deadmines")
    WishlistService.AddItem(102, "link102", "Item 102", "Mr. Smite", "Deadmines")
    WishlistService.AddItem(103, "link103", "Item 103", "Cookie", "Deadmines")
    WishlistService.AddItem(201, "link201", "Item 201", "Ragnaros", "Molten Core")

    out.wishlistGroups = #WishlistService.GetGrouped(false)
    --[[
        Ordered lowest instance first. Nothing in data/ carries minLevel yet, so
        the fallback is the name -- asserted here so that the day the field lands
        it is a level sort and not a surprise.
    ]]
    local order = WishlistService.GetGrouped(false)
    out.wishlistSortedByName =
        (order[1] and order[2] and order[1].name < order[2].name) and 1 or 0

    local deadmines = DeadminesGroup(false)
    out.wishlistGroupItems = deadmines and #deadmines.items or -1
    -- Two entries name Mr. Smite; the sub-line lists a boss once.
    out.wishlistGroupBosses = deadmines and #deadmines.bosses or -1
    -- The scratch field the de-duplication uses must not reach the view.
    out.wishlistNoScratchField = (deadmines and deadmines.seenBoss == nil) and 1 or 0

    --[[
        Equipping marks rather than deletes, so the entry has to leave the default
        view and still be there when the view asks for it.
    ]]
    WishlistService.GetWishlist()[101].obtainedDate = 1
    out.wishlistObtainedFlag = WishlistService.IsObtained(101) and 1 or 0
    local visible, all = DeadminesGroup(false), DeadminesGroup(true)
    out.wishlistHidesObtained = visible and #visible.items or -1
    out.wishlistShowsObtained = all and #all.items or -1

    --[[
        "Pinned only" shows what you are still hunting. Equipping used to delete the
        entry, which took the row with it; now that it is only marked, the filter has
        to exclude it or the list keeps offering gear already on your back.
    ]]
    WishlistService.ClearAll()
    WishlistService.AddItem(301, "link301", "Item 301", "Mr. Smite", "Deadmines")
    LootFilterService.SetPinnedFilter(true)
    local pinnedItem = { itemId = 301 }
    out.pinnedShowsWanted = LootFilterService.PassesFilter(pinnedItem) and 1 or 0
    --[[
        The loot star, its tooltip and the loot-window glow all ask IsWanted rather
        than IsOnWishlist, because marking leaves an obtained item on the list and
        the broader question would have kept all three lit for gear already worn.
    ]]
    out.wantedWhileHunting = WishlistService.IsWanted(301) and 1 or 0
    WishlistService.GetWishlist()[301].obtainedDate = 1
    out.wantedDropsObtained = WishlistService.IsWanted(301) and 0 or 1
    out.listedKeepsObtained = WishlistService.IsOnWishlist(301) and 1 or 0
    out.pinnedHidesObtained = LootFilterService.PassesFilter(pinnedItem) and 0 or 1
    LootFilterService.SetPinnedFilter(false)
    out.pinnedOffShowsObtained = LootFilterService.PassesFilter(pinnedItem) and 1 or 0

    --[[
        With a level, that wins over the name. Set on the instance table itself,
        which is what GetGrouped reads through InstanceService.
    ]]
    local dungeons = InstanceService.GetDungeons()
    local first, second = dungeons[1], dungeons[2]
    WishlistService.ClearAll()
    WishlistService.AddItem(401, "l", "I", "Boss", first.name)
    WishlistService.AddItem(402, "l", "I", "Boss", second.name)
    -- The one that sorts later by name is given the lower level, so only a level
    -- sort can put it first. Named instances were no good here: the five clients
    -- do not ship the same ones, and "Deadmines" is not "The Deadmines".
    local low, high = first, second
    if second.name < first.name then low, high = second, first end
    low.minLevel, high.minLevel = 60, 10
    local byLevel = WishlistService.GetGrouped(false)
    out.wishlistLevelBeatsName = (byLevel[1].name == high.name) and 1 or 0
    low.minLevel, high.minLevel = nil, nil

    --[[
        An entry saved from the instance page, before the loot rows carried their
        boss, recorded "Unknown". The repair looks the item up in the instance's
        own encounters and gives it the right name back.

        The instance and the item are searched for rather than named, because the
        five clients do not ship the same ones.
    ]]
    WishlistService.ClearAll()
    local repairInstance, repairBoss, repairItem
    for _, candidate in ipairs(InstanceService.GetDungeons()) do
        for _, encounter in ipairs(candidate) do
            local entry = encounter.loot and encounter.loot[1]
            local id = entry and (type(entry) == "table" and entry.id or entry)
            if id and id > 0 then
                repairInstance, repairBoss, repairItem = candidate, encounter, id
                break
            end
        end
        if repairItem then break end
    end
    if repairItem then
        WishlistService.AddItem(repairItem, "link", "Item", "Unknown", repairInstance.name)
        out.repairStartsUnknown =
            (WishlistService.IsOnWishlist(repairItem).sourceBoss == "Unknown") and 1 or 0
        out.repairedCount = WishlistService.RepairSources()
        out.repairNamesTheBoss =
            (WishlistService.IsOnWishlist(repairItem).sourceBoss == repairBoss.name)
                and 1 or 0
        -- Nothing left to do on a second pass.
        out.repairIsIdempotent = (WishlistService.RepairSources() == 0) and 1 or 0
    end

    WishlistService.ClearAll()
    out.wishlistClearedGroups = #WishlistService.GetGrouped(true)

    --[[
        What a class can wear and wield, which the loot row colours red when it
        cannot. Checked as several characters, because a rule that is the same for
        everyone is not the rule being tested -- and the level-40 cases cannot be
        reached at all by asking only about a level 60.

        Note the Paladin and cloth case: CLASS_ARMOR says a Paladin *wants* plate,
        but it can wear cloth perfectly well, so that row must not go red.
    ]]
    local PROF_ARMOR, PROF_WEAPON = 4, 2
    local SUB_CLOTH, SUB_LEATHER, SUB_MAIL, SUB_PLATE, SUB_SHIELD = 1, 2, 3, 4, 6
    local SUB_BOW, SUB_SWORD1H, SUB_STAFF, SUB_DAGGER = 2, 7, 10, 15
    local function canUse(class, level, classID, subclassID, equipLoc)
        local item = { classID = classID, subclassID = subclassID, equipLoc = equipLoc }
        return LootFilterService.IsUsableByPlayer(item, class, level) and 1 or 0
    end

    out.profPlateOnMage = canUse("MAGE", 60, PROF_ARMOR, SUB_PLATE)
    out.profLeatherOnMage = canUse("MAGE", 60, PROF_ARMOR, SUB_LEATHER)
    out.profClothOnMage = canUse("MAGE", 60, PROF_ARMOR, SUB_CLOTH)
    out.profClothOnPaladin = canUse("PALADIN", 60, PROF_ARMOR, SUB_CLOTH)
    out.profPlateOnWarrior60 = canUse("WARRIOR", 60, PROF_ARMOR, SUB_PLATE)
    out.profPlateOnWarrior39 = canUse("WARRIOR", 39, PROF_ARMOR, SUB_PLATE)
    out.profMailOnWarrior39 = canUse("WARRIOR", 39, PROF_ARMOR, SUB_MAIL)
    out.profMailOnHunter39 = canUse("HUNTER", 39, PROF_ARMOR, SUB_MAIL)
    out.profMailOnHunter40 = canUse("HUNTER", 40, PROF_ARMOR, SUB_MAIL)
    out.profShieldOnRogue = canUse("ROGUE", 60, PROF_ARMOR, SUB_SHIELD)
    out.profShieldOnWarrior = canUse("WARRIOR", 60, PROF_ARMOR, SUB_SHIELD)
    -- A cloak is cloth, so without the slot pass every plate wearer would see red.
    out.profCloakOnWarrior =
        canUse("WARRIOR", 60, PROF_ARMOR, SUB_CLOTH, "INVTYPE_CLOAK")
    out.profBowOnWarlock = canUse("WARLOCK", 60, PROF_WEAPON, SUB_BOW)
    out.profDaggerOnWarlock = canUse("WARLOCK", 60, PROF_WEAPON, SUB_DAGGER)
    out.profSwordOnPriest = canUse("PRIEST", 60, PROF_WEAPON, SUB_SWORD1H)
    out.profStaffOnPriest = canUse("PRIEST", 60, PROF_WEAPON, SUB_STAFF)
    -- Neither armour nor weapon, and an unreadable subclass: both pass rather than
    -- being called unusable on a guess.
    out.profUnknownClassPasses = canUse("MAGE", 60, 15, 99)
    out.profUnknownArmorPasses = canUse("MAGE", 60, PROF_ARMOR, 99)
    return out

"""

# flavor, isForever, isClassicLine, isEraClient, isVanillaLoot, isSoD, combat log,
# and which of the seven tagged items survive the loot filter.
EXPECTED = {
    "era": {
        "flavor": "era", "isForever": 0, "isClassicLine": 1, "isEraClient": 1,
        "isVanillaLoot": 1, "isSoD": 0, "isEra": 1, "combatLogAvailable": 1,
        "loot": "1,2,4,7", "dungeons": 19, "raids": 6,
        "spellName": "Spell 123", "spellIcon": 1, "tabTemplateExists": 1,
        "tabTemplate": "CharacterFrameTabButtonTemplate",
        "seasonBeforeStart": "none",
        "seasonOnStart": "hallowsend",
        "seasonMidway": "hallowsend",
        "seasonOnEnd": "hallowsend",
        "seasonAfterEnd": "none",
        "seasonFarOff": "none",
        "seasonNoDate": "none",
        "unclaimedAbilities": 0,
        "miscastAbilities": 0,
        "progressKeptPriorHistory": 1,
        "progressStartsClear": 1,
        "progressRecorded": 1,
        "progressPersisted": 1,
        "progressHydrated": 1,
        "progressCleared": 1,
        "progressClearIsScoped": 1,
        "progressClearsUnresolvable": 1,
        "progressKeyCollisions": 0,
        "discoveryBaselineNonEmpty": 1,
        "discoveryOffRevealsUnmet": 1,
        "discoveryOffKeepsName": 1,
        "discoveryHidesUnmet": 1,
        "discoveryHidesName": 1,
        "discoveryRevealsOnDefeat": 1,
        "discoveryRevealsName": 1,
        "discoveryIsPerBoss": 1,
        "discoveryProgressCountsOne": 1,
        "discoverySurvivesReset": 1,
        "discoveryResetClearsDefeat": 1,
        "discoveryDefaultsOff": 1,
        "spellDescription": "Description of spell 12054",
        "spellDescriptionUnknown": 1,
        "spellDescriptionNoId": 1,
        "requestSpellDataNoId": 0,
        "requestsSpellData": 0,
        "abilitiesMissingIcon": 0,
        "abilitiesMissingBody": 0,
        "wishlistGroups": 2,
        "wishlistSortedByName": 1,
        "wishlistLevelBeatsName": 1,
        "wishlistGroupItems": 3,
        "wishlistGroupBosses": 2,
        "wishlistNoScratchField": 1,
        "wishlistObtainedFlag": 1,
        "wishlistHidesObtained": 2,
        "wishlistShowsObtained": 3,
        "wishlistClearedGroups": 0,
        "repairStartsUnknown": 1,
        "repairedCount": 1,
        "repairNamesTheBoss": 1,
        "repairIsIdempotent": 1,
        "profPlateOnMage": 0,
        "profLeatherOnMage": 0,
        "profClothOnMage": 1,
        "profClothOnPaladin": 1,
        "profPlateOnWarrior60": 1,
        "profPlateOnWarrior39": 0,
        "profMailOnWarrior39": 1,
        "profMailOnHunter39": 0,
        "profMailOnHunter40": 1,
        "profShieldOnRogue": 0,
        "profShieldOnWarrior": 1,
        "profCloakOnWarrior": 1,
        "profBowOnWarlock": 0,
        "profDaggerOnWarlock": 1,
        "profSwordOnPriest": 0,
        "profStaffOnPriest": 1,
        "profUnknownClassPasses": 1,
        "profUnknownArmorPasses": 1,
        "pinnedShowsWanted": 1,
        "wantedWhileHunting": 1,
        "wantedDropsObtained": 1,
        "listedKeepsObtained": 1,
        "pinnedHidesObtained": 1,
        "pinnedOffShowsObtained": 1,
    },
    "sod": {
        "flavor": "era", "isForever": 0, "isClassicLine": 1, "isEraClient": 1,
        "isVanillaLoot": 1, "isSoD": 1, "isEra": 0, "combatLogAvailable": 1,
        "loot": "1,3,4", "dungeons": 18, "raids": 10,
        "spellName": "Spell 123", "spellIcon": 1, "tabTemplateExists": 1,
        "tabTemplate": "CharacterFrameTabButtonTemplate",
        "seasonBeforeStart": "none",
        "seasonOnStart": "hallowsend",
        "seasonMidway": "hallowsend",
        "seasonOnEnd": "hallowsend",
        "seasonAfterEnd": "none",
        "seasonFarOff": "none",
        "seasonNoDate": "none",
        "unclaimedAbilities": 0,
        "miscastAbilities": 0,
        "progressKeptPriorHistory": 1,
        "progressStartsClear": 1,
        "progressRecorded": 1,
        "progressPersisted": 1,
        "progressHydrated": 1,
        "progressCleared": 1,
        "progressClearIsScoped": 1,
        "progressClearsUnresolvable": 1,
        "progressKeyCollisions": 0,
        "discoveryBaselineNonEmpty": 1,
        "discoveryOffRevealsUnmet": 1,
        "discoveryOffKeepsName": 1,
        "discoveryHidesUnmet": 1,
        "discoveryHidesName": 1,
        "discoveryRevealsOnDefeat": 1,
        "discoveryRevealsName": 1,
        "discoveryIsPerBoss": 1,
        "discoveryProgressCountsOne": 1,
        "discoverySurvivesReset": 1,
        "discoveryResetClearsDefeat": 1,
        "discoveryDefaultsOff": 1,
        "spellDescription": "Description of spell 12054",
        "spellDescriptionUnknown": 1,
        "spellDescriptionNoId": 1,
        "requestSpellDataNoId": 0,
        "requestsSpellData": 0,
        "abilitiesMissingIcon": 0,
        "abilitiesMissingBody": 0,
        "wishlistGroups": 2,
        "wishlistSortedByName": 1,
        "wishlistLevelBeatsName": 1,
        "wishlistGroupItems": 3,
        "wishlistGroupBosses": 2,
        "wishlistNoScratchField": 1,
        "wishlistObtainedFlag": 1,
        "wishlistHidesObtained": 2,
        "wishlistShowsObtained": 3,
        "wishlistClearedGroups": 0,
        "repairStartsUnknown": 1,
        "repairedCount": 1,
        "repairNamesTheBoss": 1,
        "repairIsIdempotent": 1,
        "profPlateOnMage": 0,
        "profLeatherOnMage": 0,
        "profClothOnMage": 1,
        "profClothOnPaladin": 1,
        "profPlateOnWarrior60": 1,
        "profPlateOnWarrior39": 0,
        "profMailOnWarrior39": 1,
        "profMailOnHunter39": 0,
        "profMailOnHunter40": 1,
        "profShieldOnRogue": 0,
        "profShieldOnWarrior": 1,
        "profCloakOnWarrior": 1,
        "profBowOnWarlock": 0,
        "profDaggerOnWarlock": 1,
        "profSwordOnPriest": 0,
        "profStaffOnPriest": 1,
        "profUnknownClassPasses": 1,
        "profUnknownArmorPasses": 1,
        "pinnedShowsWanted": 1,
        "wantedWhileHunting": 1,
        "wantedDropsObtained": 1,
        "listedKeepsObtained": 1,
        "pinnedHidesObtained": 1,
        "pinnedOffShowsObtained": 1,
    },
    "tbc": {
        "flavor": "tbc", "isForever": 0, "isClassicLine": 1, "isEraClient": 0,
        "isVanillaLoot": 0, "isSoD": 0, "isEra": 0, "combatLogAvailable": 1,
        "loot": "1,5,7", "dungeons": 19, "raids": 6,
        "spellName": "Spell 123", "spellIcon": 1, "tabTemplateExists": 1,
        "tabTemplate": "CharacterFrameTabButtonTemplate",
        "seasonBeforeStart": "none",
        "seasonOnStart": "hallowsend",
        "seasonMidway": "hallowsend",
        "seasonOnEnd": "hallowsend",
        "seasonAfterEnd": "none",
        "seasonFarOff": "none",
        "seasonNoDate": "none",
        "unclaimedAbilities": 0,
        "miscastAbilities": 0,
        "progressKeptPriorHistory": 1,
        "progressStartsClear": 1,
        "progressRecorded": 1,
        "progressPersisted": 1,
        "progressHydrated": 1,
        "progressCleared": 1,
        "progressClearIsScoped": 1,
        "progressClearsUnresolvable": 1,
        "progressKeyCollisions": 0,
        "discoveryBaselineNonEmpty": 1,
        "discoveryOffRevealsUnmet": 1,
        "discoveryOffKeepsName": 1,
        "discoveryHidesUnmet": 1,
        "discoveryHidesName": 1,
        "discoveryRevealsOnDefeat": 1,
        "discoveryRevealsName": 1,
        "discoveryIsPerBoss": 1,
        "discoveryProgressCountsOne": 1,
        "discoverySurvivesReset": 1,
        "discoveryResetClearsDefeat": 1,
        "discoveryDefaultsOff": 1,
        "spellDescription": "Description of spell 12054",
        "spellDescriptionUnknown": 1,
        "spellDescriptionNoId": 1,
        "requestSpellDataNoId": 0,
        "requestsSpellData": 0,
        "abilitiesMissingIcon": 0,
        "abilitiesMissingBody": 0,
        "wishlistGroups": 2,
        "wishlistSortedByName": 1,
        "wishlistLevelBeatsName": 1,
        "wishlistGroupItems": 3,
        "wishlistGroupBosses": 2,
        "wishlistNoScratchField": 1,
        "wishlistObtainedFlag": 1,
        "wishlistHidesObtained": 2,
        "wishlistShowsObtained": 3,
        "wishlistClearedGroups": 0,
        "repairStartsUnknown": 1,
        "repairedCount": 1,
        "repairNamesTheBoss": 1,
        "repairIsIdempotent": 1,
        "profPlateOnMage": 0,
        "profLeatherOnMage": 0,
        "profClothOnMage": 1,
        "profClothOnPaladin": 1,
        "profPlateOnWarrior60": 1,
        "profPlateOnWarrior39": 0,
        "profMailOnWarrior39": 1,
        "profMailOnHunter39": 0,
        "profMailOnHunter40": 1,
        "profShieldOnRogue": 0,
        "profShieldOnWarrior": 1,
        "profCloakOnWarrior": 1,
        "profBowOnWarlock": 0,
        "profDaggerOnWarlock": 1,
        "profSwordOnPriest": 0,
        "profStaffOnPriest": 1,
        "profUnknownClassPasses": 1,
        "profUnknownArmorPasses": 1,
        "pinnedShowsWanted": 1,
        "wantedWhileHunting": 1,
        "wantedDropsObtained": 1,
        "listedKeepsObtained": 1,
        "pinnedHidesObtained": 1,
        "pinnedOffShowsObtained": 1,
    },
    # The build that broke 1.8.0: WOW_PROJECT_ID 18, neither mainline nor classic.
    #
    # Note isEra = 0 while era-tagged loot is still kept. Those are two different
    # tests with the same name: Compat.IsEra() requires isEraClient, which Forever is
    # not, while GetEncounterLoot has its own local isEra = isClassicClient and not
    # isSoD, and isClassicClient there is isVanillaLoot -- true on Forever. The local
    # is what admits the loot. Worth knowing before "simplifying" either one.
    #
    # era and classic loot is kept here on purpose. Compat.isVanillaLoot is
    # deliberately wider than isEraClient -- Forever shares vanilla's item ids
    # wherever it shares an instance -- so loot tagged era or classic belongs on it
    # and only tbc loot does not. The 28 dungeons are Era's 19 plus Forever's 9:
    # with the journal cold, ForeverContentService falls back to ABSENT_ON_FOREVER
    # and unknown beats hidden.
    "forever": {
        "flavor": "forever", "isForever": 1, "isClassicLine": 0, "isEraClient": 0,
        "isVanillaLoot": 1, "isSoD": 0, "isEra": 0, "combatLogAvailable": 0,
        "loot": "1,2,4,6,7", "dungeons": 28, "raids": 2,
        "spellName": "Spell 123", "spellIcon": 1, "tabTemplateExists": 1,
        "tabTemplate": "PanelTabButtonTemplate",
        "seasonBeforeStart": "none",
        "seasonOnStart": "hallowsend",
        "seasonMidway": "hallowsend",
        "seasonOnEnd": "hallowsend",
        "seasonAfterEnd": "none",
        "seasonFarOff": "none",
        "seasonNoDate": "none",
        "unclaimedAbilities": 0,
        "miscastAbilities": 0,
        "progressKeptPriorHistory": 1,
        "progressStartsClear": 1,
        "progressRecorded": 1,
        "progressPersisted": 1,
        "progressHydrated": 1,
        "progressCleared": 1,
        "progressClearIsScoped": 1,
        "progressClearsUnresolvable": 1,
        "progressKeyCollisions": 0,
        "discoveryBaselineNonEmpty": 1,
        "discoveryOffRevealsUnmet": 1,
        "discoveryOffKeepsName": 1,
        "discoveryHidesUnmet": 1,
        "discoveryHidesName": 1,
        "discoveryRevealsOnDefeat": 1,
        "discoveryRevealsName": 1,
        "discoveryIsPerBoss": 1,
        "discoveryProgressCountsOne": 1,
        "discoverySurvivesReset": 1,
        "discoveryResetClearsDefeat": 1,
        "discoveryDefaultsOff": 1,
        "spellDescription": "Description of spell 12054",
        "spellDescriptionUnknown": 1,
        "spellDescriptionNoId": 1,
        "requestSpellDataNoId": 0,
        "requestsSpellData": 1,
        "abilitiesMissingIcon": 0,
        "abilitiesMissingBody": 0,
        "wishlistGroups": 2,
        "wishlistSortedByName": 1,
        "wishlistLevelBeatsName": 1,
        "wishlistGroupItems": 3,
        "wishlistGroupBosses": 2,
        "wishlistNoScratchField": 1,
        "wishlistObtainedFlag": 1,
        "wishlistHidesObtained": 2,
        "wishlistShowsObtained": 3,
        "wishlistClearedGroups": 0,
        "repairStartsUnknown": 1,
        "repairedCount": 1,
        "repairNamesTheBoss": 1,
        "repairIsIdempotent": 1,
        "profPlateOnMage": 0,
        "profLeatherOnMage": 0,
        "profClothOnMage": 1,
        "profClothOnPaladin": 1,
        "profPlateOnWarrior60": 1,
        "profPlateOnWarrior39": 0,
        "profMailOnWarrior39": 1,
        "profMailOnHunter39": 0,
        "profMailOnHunter40": 1,
        "profShieldOnRogue": 0,
        "profShieldOnWarrior": 1,
        "profCloakOnWarrior": 1,
        "profBowOnWarlock": 0,
        "profDaggerOnWarlock": 1,
        "profSwordOnPriest": 0,
        "profStaffOnPriest": 1,
        "profUnknownClassPasses": 1,
        "profUnknownArmorPasses": 1,
        "pinnedShowsWanted": 1,
        "wantedWhileHunting": 1,
        "wantedDropsObtained": 1,
        "listedKeepsObtained": 1,
        "pinnedHidesObtained": 1,
        "pinnedOffShowsObtained": 1,
    },
    # Older Forever, reporting WOW_PROJECT_MAINLINE. A fix must satisfy both.
    "forever_old": {
        "flavor": "forever", "isForever": 1, "isClassicLine": 0, "isEraClient": 0,
        "isVanillaLoot": 1, "isSoD": 0, "isEra": 0, "combatLogAvailable": 0,
        "loot": "1,2,4,6,7", "dungeons": 28, "raids": 2,
        "spellName": "Spell 123", "spellIcon": 1, "tabTemplateExists": 1,
        "tabTemplate": "PanelTabButtonTemplate",
        "seasonBeforeStart": "none",
        "seasonOnStart": "hallowsend",
        "seasonMidway": "hallowsend",
        "seasonOnEnd": "hallowsend",
        "seasonAfterEnd": "none",
        "seasonFarOff": "none",
        "seasonNoDate": "none",
        "unclaimedAbilities": 0,
        "miscastAbilities": 0,
        "progressKeptPriorHistory": 1,
        "progressStartsClear": 1,
        "progressRecorded": 1,
        "progressPersisted": 1,
        "progressHydrated": 1,
        "progressCleared": 1,
        "progressClearIsScoped": 1,
        "progressClearsUnresolvable": 1,
        "progressKeyCollisions": 0,
        "discoveryBaselineNonEmpty": 1,
        "discoveryOffRevealsUnmet": 1,
        "discoveryOffKeepsName": 1,
        "discoveryHidesUnmet": 1,
        "discoveryHidesName": 1,
        "discoveryRevealsOnDefeat": 1,
        "discoveryRevealsName": 1,
        "discoveryIsPerBoss": 1,
        "discoveryProgressCountsOne": 1,
        "discoverySurvivesReset": 1,
        "discoveryResetClearsDefeat": 1,
        "discoveryDefaultsOff": 1,
        "spellDescription": "Description of spell 12054",
        "spellDescriptionUnknown": 1,
        "spellDescriptionNoId": 1,
        "requestSpellDataNoId": 0,
        "requestsSpellData": 1,
        "abilitiesMissingIcon": 0,
        "abilitiesMissingBody": 0,
        "wishlistGroups": 2,
        "wishlistSortedByName": 1,
        "wishlistLevelBeatsName": 1,
        "wishlistGroupItems": 3,
        "wishlistGroupBosses": 2,
        "wishlistNoScratchField": 1,
        "wishlistObtainedFlag": 1,
        "wishlistHidesObtained": 2,
        "wishlistShowsObtained": 3,
        "wishlistClearedGroups": 0,
        "repairStartsUnknown": 1,
        "repairedCount": 1,
        "repairNamesTheBoss": 1,
        "repairIsIdempotent": 1,
        "profPlateOnMage": 0,
        "profLeatherOnMage": 0,
        "profClothOnMage": 1,
        "profClothOnPaladin": 1,
        "profPlateOnWarrior60": 1,
        "profPlateOnWarrior39": 0,
        "profMailOnWarrior39": 1,
        "profMailOnHunter39": 0,
        "profMailOnHunter40": 1,
        "profShieldOnRogue": 0,
        "profShieldOnWarrior": 1,
        "profCloakOnWarrior": 1,
        "profBowOnWarlock": 0,
        "profDaggerOnWarlock": 1,
        "profSwordOnPriest": 0,
        "profStaffOnPriest": 1,
        "profUnknownClassPasses": 1,
        "profUnknownArmorPasses": 1,
        "pinnedShowsWanted": 1,
        "wantedWhileHunting": 1,
        "wantedDropsObtained": 1,
        "listedKeepsObtained": 1,
        "pinnedHidesObtained": 1,
        "pinnedOffShowsObtained": 1,
    },
}


def main():
    files = addon_files()
    print(f"smoke_test: {len(files)} files from Main.xml, skipping {len(SKIP)} patterns\n")

    for name, expected in EXPECTED.items():
        print(f"  == {name} ==")
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute(STUB.read_text(encoding="utf-8"))
        lua.globals().__SetClient(name)

        facade, loaded = load_addon(lua, files)
        load_widgets(lua, facade)
        make_probe = lua.eval(
            'function(src, env) return assert(load(src, "@probe", "t", env)) end'
        )
        probe = make_probe(PROBE, facade)()
        print(f"    ok   loaded {loaded} files, toc {probe['tocVersion']}")
        print(f"    ok   {probe['claimedAbilities']} ability entries claimed by a widget type")

        for key, want in expected.items():
            check(f"{name}.{key}", probe[key], want)

        # Era and Forever must not both offer the same instance list; a count of zero
        # would mean the data layer never registered anything at all.
        if probe["instances"] == 0:
            failures.append(f"{name}: no instances registered")
            print(f"    FAIL {name}: no instances registered")
        else:
            print(f"    ok   {name}.instances = {probe['instances']}"
                  f" ({probe['dungeons']} dungeons, {probe['raids']} raids)")
        print()

    if failures:
        print(f"smoke_test: {len(failures)} failure(s)")
        for f in failures:
            print(f"  {f}")
        return 1
    print("smoke_test: all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
