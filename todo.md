/run AdventureGuideClassic_Debug = true
/run AGC_ResetAllEncounters()
/run AGC_ResetInstance("name of dungeon")
/run AGC_ToggleDebug()
/run AGC_Wishlist()
/run AGC_CheckEquipped()
/run WishlistService.ClearAll()
/run TestWishlistToast()
/run TestWishlistToastCustom(<id>)


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