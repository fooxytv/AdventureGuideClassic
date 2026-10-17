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
    },
    "sod": {
        "flavor": "era", "isForever": 0, "isClassicLine": 1, "isEraClient": 1,
        "isVanillaLoot": 1, "isSoD": 1, "isEra": 0, "combatLogAvailable": 1,
        "loot": "1,3,4", "dungeons": 18, "raids": 10,
        "spellName": "Spell 123", "spellIcon": 1, "tabTemplateExists": 1,
        "tabTemplate": "CharacterFrameTabButtonTemplate",
    },
    "tbc": {
        "flavor": "tbc", "isForever": 0, "isClassicLine": 1, "isEraClient": 0,
        "isVanillaLoot": 0, "isSoD": 0, "isEra": 0, "combatLogAvailable": 1,
        "loot": "1,5,7", "dungeons": 19, "raids": 6,
        "spellName": "Spell 123", "spellIcon": 1, "tabTemplateExists": 1,
        "tabTemplate": "CharacterFrameTabButtonTemplate",
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
    },
    # Older Forever, reporting WOW_PROJECT_MAINLINE. A fix must satisfy both.
    "forever_old": {
        "flavor": "forever", "isForever": 1, "isClassicLine": 0, "isEraClient": 0,
        "isVanillaLoot": 1, "isSoD": 0, "isEra": 0, "combatLogAvailable": 0,
        "loot": "1,2,4,6,7", "dungeons": 28, "raids": 2,
        "spellName": "Spell 123", "spellIcon": 1, "tabTemplateExists": 1,
        "tabTemplate": "PanelTabButtonTemplate",
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
        make_probe = lua.eval(
            'function(src, env) return assert(load(src, "@probe", "t", env)) end'
        )
        probe = make_probe(PROBE, facade)()
        print(f"    ok   loaded {loaded} files, toc {probe['tocVersion']}")

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
