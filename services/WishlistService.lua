--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

WishlistService = {}

local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo

local function GetCharacterKey()
    local name = UnitName("player")
    local realm = GetRealmName()
    return name .. "-" .. realm
end

--[[
    `OnWishlistChanged` is a single slot and ui/Loot.lua already owns it. A second
    view assigning over it would silently unhook the first, so anything else that
    needs telling registers here instead and both are called.
]]
local changeListeners = {}

function WishlistService.RegisterChangeListener(listener)
    table.insert(changeListeners, listener)
end

local function NotifyChanged()
    if WishlistService.OnWishlistChanged then
        WishlistService.OnWishlistChanged()
    end
    for _, listener in ipairs(changeListeners) do
        listener()
    end
end

local function InitWishlist()
    if not SavedVariables then return end
    SavedVariables.Wishlists = SavedVariables.Wishlists or {}
    local charKey = GetCharacterKey()
    SavedVariables.Wishlists[charKey] = SavedVariables.Wishlists[charKey] or {}
end

function WishlistService.GetWishlist()
    InitWishlist()
    local charKey = GetCharacterKey()
    return SavedVariables.Wishlists[charKey] or {}
end

function WishlistService.IsOnWishlist(itemID)
    if not itemID then return nil end
    itemID = tonumber(itemID)
    local wishlist = WishlistService.GetWishlist()
    return wishlist[itemID]
end

function WishlistService.AddItem(itemID, itemLink, itemName, sourceBoss, sourceInstance)
    if not itemID then return false end
    itemID = tonumber(itemID)
    InitWishlist()
    local charKey = GetCharacterKey()
    if SavedVariables.Wishlists[charKey][itemID] then
        return false
    end

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
    NotifyChanged()

    return true
end

function WishlistService.RemoveItem(itemID)
    if not itemID then return false end
    itemID = tonumber(itemID)
    InitWishlist()
    local charKey = GetCharacterKey()
    if SavedVariables.Wishlists[charKey][itemID] then
        SavedVariables.Wishlists[charKey][itemID] = nil

        NotifyChanged()

        return true
    end

    return false
end

function WishlistService.ToggleItem(itemID, itemLink, itemName, sourceBoss, sourceInstance)
    if WishlistService.IsOnWishlist(itemID) then
        return WishlistService.RemoveItem(itemID), false -- removed
    else
        return WishlistService.AddItem(itemID, itemLink, itemName, sourceBoss, sourceInstance), true -- added
    end
end

function WishlistService.GetCount()
    local wishlist = WishlistService.GetWishlist()
    local count = 0
    for _ in pairs(wishlist) do
        count = count + 1
    end
    return count
end

function WishlistService.GetAllItems()
    local wishlist = WishlistService.GetWishlist()
    local items = {}
    for itemID, data in pairs(wishlist) do
        table.insert(items, data)
    end
    table.sort(items, function(a, b)
        return (a.addedDate or 0) > (b.addedDate or 0)
    end)
    return items
end

function WishlistService.IsObtained(itemID)
    local data = WishlistService.IsOnWishlist(itemID)
    return data and data.obtainedDate ~= nil or false
end

--[[
    The wishlist grouped by the instance each item was added from, newest group
    first, for the wishlist tab's one-row-per-instance list.

    Grouping lives here rather than in the view because `sourceInstance` is only
    ever a name -- the instance table itself is not stored -- so this is the one
    place that has to know the entries are joined on a string. It is also the only
    part of the tab the smoke test can reach, since ui/ needs frames.
]]
function WishlistService.GetGrouped(includeObtained)
    local groups, byName = {}, {}
    for _, data in ipairs(WishlistService.GetAllItems()) do
        if includeObtained or not data.obtainedDate then
            local name = data.sourceInstance or "Unknown"
            local group = byName[name]
            if not group then
                group = { name = name, items = {}, bosses = {}, seenBoss = {} }
                byName[name] = group
                table.insert(groups, group)
            end
            table.insert(group.items, data)
            local boss = data.sourceBoss
            if boss and not group.seenBoss[boss] then
                group.seenBoss[boss] = true
                table.insert(group.bosses, boss)
            end
        end
    end
    for _, group in ipairs(groups) do
        group.seenBoss = nil
    end
    return groups
end

function WishlistService.CheckLootTable(lootItems)
    local matches = {}
    for _, itemID in ipairs(lootItems) do
        if WishlistService.IsOnWishlist(itemID) then
            table.insert(matches, itemID)
        end
    end
    return matches
end

function WishlistService.ClearAll()
    InitWishlist()
    local charKey = GetCharacterKey()
    SavedVariables.Wishlists[charKey] = {}
    NotifyChanged()
end

function WishlistService.DebugPrint()
    local items = WishlistService.GetAllItems()
    print("|cffff9900[AGC Wishlist]|r", WishlistService.GetCount(), "items:")
    for _, item in ipairs(items) do
        print("  -", item.itemLink or item.itemName, "from", item.sourceBoss or "Unknown")
    end
end

_G.AGC_Wishlist = WishlistService.DebugPrint

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

--[[
    Equipping a wishlisted item used to delete it outright. The wishlist view wants
    to show what you have finished hunting, so it is marked instead. The view hides
    obtained items by default, which is what the deletion looked like from outside.
]]
local function CheckEquippedItems()
    local wishlist = WishlistService.GetWishlist()
    local equippedIDs = GetEquippedItemIDs()
    local changed = false

    for itemID, data in pairs(wishlist) do
        if equippedIDs[itemID] and not data.obtainedDate then
            data.obtainedDate = time()
            changed = true
            local itemLink = data.itemLink or data.itemName or "Unknown Item"
            print("|cff00ff00[AGC Wishlist]|r Obtained:", itemLink)
        end
    end

    if changed then
        NotifyChanged()
    end
end

local equipFrame = CreateFrame("Frame")
equipFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
equipFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

equipFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        C_Timer.After(0.2, CheckEquippedItems)
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, CheckEquippedItems)
    end
end)

_G.AGC_CheckEquipped = CheckEquippedItems
