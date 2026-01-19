--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

WishlistService = {}

-- API compatibility: Classic Era uses global functions, TBC+ uses C_Item namespace
local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo

-- Get character-specific key for SavedVariables
local function GetCharacterKey()
    local name = UnitName("player")
    local realm = GetRealmName()
    return name .. "-" .. realm
end

-- Initialize wishlist storage
local function InitWishlist()
    if not SavedVariables then return end
    SavedVariables.Wishlists = SavedVariables.Wishlists or {}
    local charKey = GetCharacterKey()
    SavedVariables.Wishlists[charKey] = SavedVariables.Wishlists[charKey] or {}
end

-- Get the current character's wishlist
function WishlistService.GetWishlist()
    InitWishlist()
    local charKey = GetCharacterKey()
    return SavedVariables.Wishlists[charKey] or {}
end

-- Check if an item is on the wishlist
-- Returns the wishlist entry if found, nil otherwise
function WishlistService.IsOnWishlist(itemID)
    if not itemID then return nil end
    itemID = tonumber(itemID)
    local wishlist = WishlistService.GetWishlist()
    return wishlist[itemID]
end

-- Add an item to the wishlist
function WishlistService.AddItem(itemID, itemLink, itemName, sourceBoss, sourceInstance)
    if not itemID then return false end
    itemID = tonumber(itemID)

    InitWishlist()
    local charKey = GetCharacterKey()

    -- Don't add if already on list
    if SavedVariables.Wishlists[charKey][itemID] then
        return false
    end

    -- Get item info if not provided
    if not itemName and itemLink then
        itemName = GetItemInfoCompat(itemLink)
    end

    SavedVariables.Wishlists[charKey][itemID] = {
        itemID = itemID,
        itemLink = itemLink,
        itemName = itemName or "Unknown",
        sourceBoss = sourceBoss,
        sourceInstance = sourceInstance,
        addedDate = time(),
    }

    -- Fire callback for UI updates
    if WishlistService.OnWishlistChanged then
        WishlistService.OnWishlistChanged()
    end

    return true
end

-- Remove an item from the wishlist
function WishlistService.RemoveItem(itemID)
    if not itemID then return false end
    itemID = tonumber(itemID)

    InitWishlist()
    local charKey = GetCharacterKey()

    if SavedVariables.Wishlists[charKey][itemID] then
        SavedVariables.Wishlists[charKey][itemID] = nil

        -- Fire callback for UI updates
        if WishlistService.OnWishlistChanged then
            WishlistService.OnWishlistChanged()
        end

        return true
    end

    return false
end

-- Toggle an item on/off the wishlist
function WishlistService.ToggleItem(itemID, itemLink, itemName, sourceBoss, sourceInstance)
    if WishlistService.IsOnWishlist(itemID) then
        return WishlistService.RemoveItem(itemID), false -- removed
    else
        return WishlistService.AddItem(itemID, itemLink, itemName, sourceBoss, sourceInstance), true -- added
    end
end

-- Get count of items on wishlist
function WishlistService.GetCount()
    local wishlist = WishlistService.GetWishlist()
    local count = 0
    for _ in pairs(wishlist) do
        count = count + 1
    end
    return count
end

-- Get all items as an array (for display)
function WishlistService.GetAllItems()
    local wishlist = WishlistService.GetWishlist()
    local items = {}
    for itemID, data in pairs(wishlist) do
        table.insert(items, data)
    end
    -- Sort by added date (newest first)
    table.sort(items, function(a, b)
        return (a.addedDate or 0) > (b.addedDate or 0)
    end)
    return items
end

-- Check if any items in a loot table are on the wishlist
-- Returns array of matching itemIDs
function WishlistService.CheckLootTable(lootItems)
    local matches = {}
    for _, itemID in ipairs(lootItems) do
        if WishlistService.IsOnWishlist(itemID) then
            table.insert(matches, itemID)
        end
    end
    return matches
end

-- Clear entire wishlist for current character
function WishlistService.ClearAll()
    InitWishlist()
    local charKey = GetCharacterKey()
    SavedVariables.Wishlists[charKey] = {}

    if WishlistService.OnWishlistChanged then
        WishlistService.OnWishlistChanged()
    end
end

-- Debug: Print wishlist contents
function WishlistService.DebugPrint()
    local items = WishlistService.GetAllItems()
    print("|cffff9900[AGC Wishlist]|r", WishlistService.GetCount(), "items:")
    for _, item in ipairs(items) do
        print("  -", item.itemLink or item.itemName, "from", item.sourceBoss or "Unknown")
    end
end

-- Global function for easy access
_G.AGC_Wishlist = WishlistService.DebugPrint

-- Equipment tracking to auto-remove wishlisted items when equipped
local function GetEquippedItemIDs()
    local equippedIDs = {}
    for slot = 1, 19 do
        local itemID = GetInventoryItemID("player", slot)
        if itemID then
            equippedIDs[itemID] = true
        end
    end
    return equippedIDs
end

local function CheckEquippedItems()
    local wishlist = WishlistService.GetWishlist()
    local equippedIDs = GetEquippedItemIDs()
    local removedItems = {}

    for itemID, data in pairs(wishlist) do
        if equippedIDs[itemID] then
            table.insert(removedItems, data)
        end
    end

    -- Remove equipped items from wishlist
    for _, data in ipairs(removedItems) do
        WishlistService.RemoveItem(data.itemID)
        local itemLink = data.itemLink or data.itemName or "Unknown Item"
        print("|cff00ff00[AGC Wishlist]|r Equipped and removed from wishlist:", itemLink)
    end
end

-- Listen for equipment changes
local equipFrame = CreateFrame("Frame")
equipFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
equipFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

equipFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        -- Small delay to ensure item info is available
        C_Timer.After(0.2, CheckEquippedItems)
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Check on login/reload in case items were equipped while offline
        C_Timer.After(1, CheckEquippedItems)
    end
end)

-- Global function to manually check equipped items
_G.AGC_CheckEquipped = CheckEquippedItems
