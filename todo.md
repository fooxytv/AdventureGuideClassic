/run AdventureGuideClassic_Debug = true
/run AGC_ResetAllEncounters()
/run AGC_ResetInstance("name of dungeon")
/run AGC_ToggleDebug()
/run AGC_Wishlist()
/run AGC_CheckEquipped()
/run WishlistService.ClearAll()
/run TestWishlistToast()
/run TestWishlistToastCustom(<id>)
/run TestLevelUpToast()
/run TestBossDefeatedToast()
/run TestBossDefeatedToastCustom("Custom Boss Name")
/run TestWishlistToast()
/run TestWishlistToastCustom(itemID)
/run AGC_DumpPlayerContext()
/run AGC_InstancesForLevel(24)
/run AGC_InstancesForLevel(24, "Alliance")
/run AGC_ZonesForLevel(24)
/run AGC_TestSuggestionsAt(24)
/run AGC_TestSuggestionsAt(24, "Horde")
/run AGC_VerifyZoneMapIDs()
/run AGC_DumpZoneMapIDs()
/run AGC_ActiveEvents()
/run AGC_ActiveEvents(2026, 10, 20)
/run AGC_ListGuides()
/run AGC_ToggleGuide()
/run AGC_GuideStatus()
/run AGC_GuideProgress()
/run AGC_GuideScan()
/run AGC_GuideObjectives()
/run AGC_QuestIntent("A Threat Within")
/run AGC_ResetGuidePosition()
/run SettingsService.SetGuideOpacity(0.55)   -- guide panel transparency
/run SettingsService.SetGuideScale(0.9)
/agc guide

NOTE: every file calls SetupGlobalFacade(), which setfenv's the chunk into the
addon's facade table. A bare `function Foo()` therefore lands on the facade, NOT
in _G, and /run cannot see it. Declare chat-reachable helpers as
`_G.Foo = function() ... end`.


  Loot Filters

  | Filter       | Description                                    |
  |--------------|------------------------------------------------|
  | "all"        | Shows on all clients (default)                 |
  | "era"        | Classic Era only (not SoD, not TBC)            |
  | "sod"        | Season of Discovery only                       |
  | "classic"    | Classic client (both Era and SoD, but not TBC) |
  | "tbc"        | TBC client only                                |
  | "exclusive"  | Legacy - same as "sod"                         |
  | "restricted" | Legacy - NOT on SoD                            |

  Usage Example

  For Deadmines where an item is different between Era and TBC:

  loot = {
      { id = 872, filter = "era" },      -- Gray version for Classic Era
      { id = 872, filter = "sod" },      -- Same item for SoD (if applicable)
      { id = 12345, filter = "tbc" },    -- Blue upgraded version for TBC
  }

  Or if an item exists in both Era and SoD but not TBC:
  loot = {
      { id = 872, filter = "classic" },  -- Shows on Era and SoD, not TBC
  }

  You can use either filter or seasonFilter as the key - both work:
  { id = 872, filter = "era" }
  -- or
  { id = 872, seasonFilter = "era" }

  The system also supports the difficulty field for TBC heroic/normal filtering:
  { id = 12345, filter = "tbc", difficulty = "heroic" }

    loot = {
      -- Shows on both normal and heroic (no difficulty field = "both")
      { id = 24024, seasonFilter = "all" },

      -- Only shows on normal difficulty
      { id = 24025, seasonFilter = "all", difficulty = "normal" },

      -- Only shows on heroic difficulty
      { id = 27448, seasonFilter = "all", difficulty = "heroic" },
  }