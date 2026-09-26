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


  Loot Filters

  | Filter       | Description                                    |
  |--------------|------------------------------------------------|
  | "all"        | Shows on all clients (default)                 |
  | "era"        | Classic Era only (not SoD, not TBC)            |
  | "sod"        | Season of Discovery only                       |
  | "classic"    | Classic client (both Era and SoD, but not TBC) |
  | "tbc"        | TBC client only                                |
  | "forever"    | WoW Forever only (1.60.x)                      |
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

  ## Known issues

  ### Naxxramas shows on the TBC client (low priority)

  Naxxramas (40) was removed when TBC launched, but it still appears on the BCC
  client whenever the expansion dropdown is on "Classic".

  `data/Raids/era/Naxxramas.lua` already carries `seasonFilter = "era"`, which
  would hide it. The tag is never read: `ShouldIncludeInstance` in
  `services/Instance.lua` takes an early `return true` in the `instance.season ~= nil`
  branch, before any `seasonFilter` check. Every raid sets `season`, so no raid's
  `seasonFilter` has any effect today.

  Two mechanisms say the same thing -- raids use the `season` boolean, dungeons use
  `seasonFilter = "exclusive"` -- and the boolean wins. Worth collapsing onto the tag
  vocabulary rather than patching the one instance, since the same short-circuit is
  why Zul'Gurub and both Ahn'Qiraj raids ignore their own tags too. Those three are
  correct on TBC by accident, having stayed in the game when Naxxramas did not.
