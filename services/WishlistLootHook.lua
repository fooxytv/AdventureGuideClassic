--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local WishlistLootHook = {}

-- Store references to glow frames we create
local glowFrames = {}

-- Sound to play when wishlist item is found
local WISHLIST_SOUND = "Interface\\AddOns\\AdventureGuideClassic\\sounds\\UIEJBossDefeated.ogg"

-- Create a glow frame for a loot button
local function CreateGlowFrame(lootButton, index)
    if glowFrames[index] then
        return glowFrames[index]
    end

    local glow = CreateFrame("Frame", "AGC_WishlistGlow" .. index, lootButton)
    glow:SetAllPoints(lootButton)
    glow:SetFrameLevel(lootButton:GetFrameLevel() + 10)

    -- Create glow texture - position around the icon (which is on the left side of loot button)
    -- Loot button icons are typically 32x32 or similar, positioned at the left
    glow.texture = glow:CreateTexture(nil, "OVERLAY")
    glow.texture:SetSize(50, 50) -- Slightly larger than the icon
    glow.texture:SetPoint("LEFT", lootButton, "LEFT", -5, 0)
    glow.texture:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    glow.texture:SetBlendMode("ADD")
    glow.texture:SetVertexColor(1, 0.8, 0) -- Gold color

    -- Create a border highlight around the entire loot button row
    glow.border = glow:CreateTexture(nil, "BACKGROUND")
    glow.border:SetAllPoints(lootButton)
    glow.border:SetColorTexture(1, 0.8, 0, 0.2) -- Subtle gold tint

    -- Create star icon - position at top right of the icon
    glow.star = glow:CreateTexture(nil, "OVERLAY")
    glow.star:SetSize(18, 18)
    glow.star:SetPoint("LEFT", lootButton, "LEFT", 25, 12)
    glow.star:SetTexture("Interface\\COMMON\\ReputationStar")
    glow.star:SetTexCoord(0, 0.5, 0, 0.5)

    -- Create pulsing animation
    glow.animGroup = glow:CreateAnimationGroup()
    glow.animGroup:SetLooping("REPEAT")

    local fadeOut = glow.animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0.3)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(1)

    local fadeIn = glow.animGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0.3)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
    fadeIn:SetOrder(2)

    glow:Hide()
    glowFrames[index] = glow
    return glow
end

-- Hide all glow frames
local function HideAllGlows()
    for _, glow in pairs(glowFrames) do
        glow:Hide()
        if glow.animGroup then
            glow.animGroup:Stop()
        end
    end
end

-- Get item ID from loot slot
local function GetLootSlotItemID(slot)
    local lootLink = GetLootSlotLink(slot)
    if lootLink then
        local itemID = GetItemInfoInstant(lootLink)
        return itemID
    end
    return nil
end

-- Check loot window for wishlist items
local function CheckLootWindow()
    local numLootItems = GetNumLootItems()
    local foundWishlistItem = false
    local wishlistItems = {} -- Store both name and ID

    for slot = 1, numLootItems do
        local itemID = GetLootSlotItemID(slot)
        if itemID and WishlistService and WishlistService.IsOnWishlist(itemID) then
            foundWishlistItem = true

            -- Get the loot button
            local lootButton = _G["LootButton" .. slot]
            if lootButton then
                local glow = CreateGlowFrame(lootButton, slot)
                glow:SetParent(lootButton)
                glow:SetAllPoints(lootButton)
                glow:Show()
                glow.animGroup:Play()
            end

            -- Track item name and ID for notification
            local itemName = C_Item.GetItemInfo(itemID)
            if itemName then
                table.insert(wishlistItems, { name = itemName, id = itemID })
            end
        end
    end

    return foundWishlistItem, wishlistItems
end

-- Handle loot window opening
local function OnLootOpened()
    HideAllGlows()

    -- Small delay to ensure loot window is fully populated
    C_Timer.After(0.1, function()
        local found, wishlistItems = CheckLootWindow()
        if found then
            -- Play sound
            -- PlaySoundFile(WISHLIST_SOUND, "Master")

            -- Show toast notification
            if AdventureGuideClassicEventToastManager then
                -- Build display text from item names
                local itemNames = {}
                local firstItemID = nil
                for _, item in ipairs(wishlistItems) do
                    table.insert(itemNames, item.name)
                    if not firstItemID then
                        firstItemID = item.id
                    end
                end
                local itemText = table.concat(itemNames, ", ")
                if #itemText > 40 then
                    itemText = itemText:sub(1, 37) .. "..."
                end
                AdventureGuideClassicEventToastManager:ShowWishlistToast("Wishlist Item Found!", itemText, firstItemID)
            else
                -- Fallback to chat message
                for _, item in ipairs(wishlistItems) do
                    print("|cff00ff00[AGC Wishlist]|r Item dropped:", item.name)
                end
            end
        end
    end)
end

-- Handle loot window closing
local function OnLootClosed()
    HideAllGlows()
end

-- Handle loot slot being cleared (item looted)
local function OnLootSlotCleared(slot)
    if glowFrames[slot] then
        glowFrames[slot]:Hide()
        if glowFrames[slot].animGroup then
            glowFrames[slot].animGroup:Stop()
        end
    end
end

-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("LOOT_OPENED")
eventFrame:RegisterEvent("LOOT_CLOSED")
eventFrame:RegisterEvent("LOOT_SLOT_CLEARED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "LOOT_OPENED" then
        OnLootOpened()
    elseif event == "LOOT_CLOSED" then
        OnLootClosed()
    elseif event == "LOOT_SLOT_CLEARED" then
        local slot = ...
        OnLootSlotCleared(slot)
    end
end)

return WishlistLootHook
