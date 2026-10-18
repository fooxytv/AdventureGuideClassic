-- Luacheck configuration for Adventure Guide Classic

-- 5.1 because that is what the client runs, and because this addon depends on
-- setfenv, which does not exist in 5.2+.
std = "lua51"
max_line_length = false

exclude_files = {
    "ci/**",
    "tools/**",
    -- Third-party and vendored. Not ours to fix, and linting it only buries
    -- the findings that are.
    "lib/**",
}

-- Every file starts with `select(2, ...).SetupGlobalFacade()`, which does
-- `setfenv(2, globalFacade)` -- so the file's environment is a table whose
-- __index falls through to _G. luacheck cannot see through setfenv, so every
-- name below reads to it as a plain global and has to be declared here.
--
-- That is what makes this list worth keeping accurate rather than silencing:
-- with the 11x diagnostics on, a mistyped API name is caught here instead of
-- resolving to nil through the facade and failing silently in game.

globals = {
    -- Namespaces and services the addon defines
    "UI", "Widgets", "Atlas", "DynamicTable", "SavedVariables",
    "SavedVariablesName", "addonName",
    "AdventureGuideNavigationService", "AdventureObjectives",
    "CreatureModelService", "DungeonMapService", "HyperlinkService",
    "ProgressService",
    "InstanceService", "LootFilterService", "ModelPresetService", "NPCService",
    "SearchService", "SettingsService", "SpellsByLevelService",
    "TierTokenService", "TokenizedTextService", "WishlistService",

    -- Frames and widget mixins the addon creates. EncounterJournal is in here
    -- rather than read_globals because the addon builds its entire frame tree
    -- onto it, and SlashCmdList because it registers handlers into it -- both
    -- are writes, and read_globals would reject them as read-only.
    "EncounterJournal", "SlashCmdList",
    "Compat", "ForeverContentService", "QuestService",
    "AdventureGuideClassicEventToastManager", "DungeonMapFrame", "DungeonMap",
    "MapNavBar", "CollapsibleSectionWidgetTypeMixin", "WidgetTypeMixin",

    -- Mapping lookups (ui/mappings)
    "GetColorMapping", "GetDungeonInstanceMapping", "GetEquipMapping",
    "GetEquipRestrictions", "GetSeasons",

    -- Data tables and filter constants the addon defines
    "DUNGEONS", "RAIDS", "npcs",
    "FILTER_AOE", "FILTER_DAMAGE_DEALER", "FILTER_HEALER", "FILTER_OTHER",
    "FILTER_PERSONAL_RESPONSIBILITY", "FILTER_TANK",

    -- From lib/TomCats (excluded from linting, but it defines these)
    "I", "MinimapButton", "CreateMinimapButton",

    -- Saved variables, per the .toc
    "AdventureGuideClassic_Account", "AdventureGuideClassic_Lockout",

    -- Slash commands and the debug/test entry points driven from todo.md
    "SLASH_ADVENTUREGUIDECLASSIC1", "SLASH_AGCTEST1",
    "AdventureGuideClassic_DebugEvents",
    "AGC_CheckEquipped", "AGC_DebugLootFilter", "AGC_ResetAllEncounters",
    "AGC_ResetInstance", "AGC_ToggleDebug", "AGC_Wishlist",
    "AGC_NpcPreview", "AGC_PreviewQuests", "AGC_Probe", "AGC_ProbeEvents",
    "AGC_Ids", "SLASH_AGCIDS1",
    "AGC_MarkDefeated", "AGC_MarkInstanceDefeated",
    "SLASH_AGCPROBE1", "SLASH_AGCPROBEEVENTS1",
    "TestBossDefeatedToast", "TestBossDefeatedToastCustom",
    "TestLevelUpToast", "TestLevelUpToastAt",
    "TestWishlistToast", "TestWishlistToastCustom",
}

read_globals = {
    -- API namespaces
    "C_AddOns", "C_Item", "C_KeyBindings", "C_Seasons", "C_Spell", "C_Timer",

    -- Widgets and frames
    "CreateFrame", "UIParent", "GameTooltip", "GameTooltip_Hide",
    "UISpecialFrames", "Settings",

    -- Mixins and helpers
    "Mixin", "CreateFromMixins", "CreateColor", "AutoScalingFontStringMixin",
    "ScrollUtil", "CreateDataProvider", "CreateScrollBoxListLinearView",
    "CreateScrollBoxListGridView", "ScrollFrame_OnLoad",
    "PanelTemplates_SetTab", "PanelTemplates_TabResize",
    "PanelTemplates_Tab_OnClick",
    "NavBar_Initialize", "NavBar_Reset", "NavBar_AddButton",
    "UIFrameFadeIn", "UIFrameFadeOut", "UIFrameFadeRemoveFrame",
    "SetPortraitTextureFromCreatureDisplayID",

    -- Dropdowns (legacy UIDropDownMenu, still what Classic ships)
    "CloseDropDownMenus", "UIDropDownMenu_AddButton",
    "UIDropDownMenu_CreateInfo", "UIDropDownMenu_Initialize",
    "UIDropDownMenu_SetSelectedValue", "UIDropDownMenu_SetText",
    "UIDropDownMenu_SetWidth",

    -- Legacy options panel. Only reached in the else branch of a
    -- `if Settings and Settings.RegisterCanvasLayoutCategory` guard, for
    -- clients predating the Settings API.
    "InterfaceOptions_AddCategory", "InterfaceOptionsFrame_OpenToCategory",

    -- Encounter journal, quest log, map and lockout APIs
    "C_EncounterJournal", "C_QuestLog", "C_Map", "C_CombatLog",
    "EJ_GetInstanceByIndex", "EJ_GetNumTiers",
    "GetNumSavedInstances", "GetSavedInstanceInfo", "INSTANCE_RESET_SUCCESS",
    "WorldMapFrame", "OpenWorldMap", "ShowUIPanel",

    -- Project constants. Only Compat.lua and Probe.lua should read these
    -- directly; everything else asks Compat. Declared because those two do.
    "WOW_PROJECT_ID", "WOW_PROJECT_CLASSIC", "WOW_PROJECT_MAINLINE",

    -- Unit, item and world queries
    "GetBuildInfo", "GetInstanceInfo", "GetRealmName", "GetTime",
    "IsInInstance", "InCombatLockdown", "UnitClass", "UnitFactionGroup",
    "UnitGUID", "UnitLevel", "UnitName",
    "GetInventoryItemID", "GetItemInfo", "GetItemInfoInstant",
    "GetSpellInfo", "GetSpellTexture", "GetBindingByKey",
    "GetLootSlotLink", "GetNumLootItems",
    "ITEM_QUALITY_COLORS", "RAID_CLASS_COLORS",
    "CombatLogGetCurrentEventInfo",

    -- Input, sound, chat
    "GetBindingKey", "SetBinding", "GetCursorPosition",
    "IsControlKeyDown", "IsShiftKeyDown",
    "PlaySound", "PlaySoundFile", "SOUNDKIT",
    "ChatEdit_InsertLink", "DressUpItemLink",

    -- Lua/WoW shims
    "strsplit", "wipe", "nop", "floor", "mod", "time",

    -- Encounter-journal section flags, used by data/ to tag boss abilities.
    -- TANK, HEALER, DAMAGE, ALL, IMPORTANT and INTERRUPT are confirmed in the
    -- Classic client's UI source; DISPEL, CURSE, MELEE and BLEED are not, and
    -- the mirror does not ship GlobalStrings, so they are declared here on the
    -- strength of the others rather than verified. If a boss ability's flag
    -- comes out nil in game, start here.
    "TANK", "HEALER", "DAMAGE", "DAMAGER", "ALL", "IMPORTANT", "INTERRUPT",
    "DISPEL", "CURSE", "MELEE", "BLEED",
}
