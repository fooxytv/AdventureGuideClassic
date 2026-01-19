--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.
]]
select(2, ...).SetupGlobalFacade()

local WishlistLootHook = {}
local glowFrames = {}
local WISHLIST_SOUND = "Interface\\AddOns\\AdventureGuideClassic\\sounds\\UIEJBossDefeated.ogg"
local MARCH_SPEED = 15
local DASH_LENGTH = 3
local DASH_GAP = 3
local BORDER_THICKNESS = 1
local BORDER_COLOR = {0, 0.8, 0}
local ICON_SIZE = 32
local ICON_OFFSET = 7
local DEBUG_SHOW_ALL = false
local DEBUG_LOG = false

-- API compatibility: Classic Era uses global functions, TBC+ uses C_Item namespace
local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo
local GetItemInfoInstantCompat = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant

local function CreateGlowFrame(lootButton, index)
    if glowFrames[index] then
        return glowFrames[index]
    end
    local iconTexture = lootButton.icon or lootButton.Icon or _G[lootButton:GetName() .. "IconTexture"]
    if not iconTexture then
        return nil
    end

    local glow = CreateFrame("Frame", "AGC_WishlistGlow" .. index, lootButton)
    glow:SetAllPoints(lootButton)
    glow:SetFrameLevel(lootButton:GetFrameLevel() + 10)
    glow.iconTexture = iconTexture
    glow.border = glow:CreateTexture(nil, "BACKGROUND")
    glow.border:SetAllPoints(lootButton)
    glow.border:SetColorTexture(0, 0.8, 0, 0.15)
    local clipFrame = CreateFrame("Frame", nil, glow)
    clipFrame:SetPoint("TOPLEFT", iconTexture, "TOPLEFT", 0, 0)
    clipFrame:SetPoint("BOTTOMRIGHT", iconTexture, "BOTTOMRIGHT", 0, 0)
    clipFrame:SetClipsChildren(true)
    glow.clipFrame = clipFrame
    local dashSpacing = DASH_LENGTH + DASH_GAP
    local dashesPerSide = math.ceil(ICON_SIZE / dashSpacing) + 2
    glow.dashes = {}
    for side = 1, 4 do
        glow.dashes[side] = {}
        for i = 1, dashesPerSide do
            local dash = clipFrame:CreateTexture(nil, "OVERLAY")
            dash:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], 1)
            if side == 1 or side == 3 then -- horizontal (top/bottom)
                dash:SetSize(DASH_LENGTH, BORDER_THICKNESS)
            else
                dash:SetSize(BORDER_THICKNESS, DASH_LENGTH)
            end
            glow.dashes[side][i] = dash
        end
    end
    glow.marchOffset = 0
    glow.dashSpacing = dashSpacing
    glow:SetScript("OnUpdate", function(self, elapsed)
        self.marchOffset = (self.marchOffset + elapsed * MARCH_SPEED) % self.dashSpacing
        local clip = self.clipFrame
        local iconWidth, iconHeight = clip:GetSize()
        for side, dashes in ipairs(self.dashes) do
            for i, dash in ipairs(dashes) do
                local basePos = (i - 1) * self.dashSpacing - self.marchOffset
                dash:ClearAllPoints()
                if side == 1 then
                    dash:SetPoint("TOPLEFT", clip, "TOPLEFT", basePos, 0)
                elseif side == 2 then
                    dash:SetPoint("TOPRIGHT", clip, "TOPRIGHT", 0, -basePos)
                elseif side == 3 then
                    dash:SetPoint("BOTTOMRIGHT", clip, "BOTTOMRIGHT", -basePos, 0)
                else
                    dash:SetPoint("BOTTOMLEFT", clip, "BOTTOMLEFT", 0, basePos)
                end
                dash:Show()
            end
        end
    end)
    glow:Hide()
    glowFrames[index] = glow
    return glow
end

local function HideAllGlows()
    for _, glow in pairs(glowFrames) do
        glow:Hide()
        if glow.dashes then
            for _, sideDashes in ipairs(glow.dashes) do
                for _, dash in ipairs(sideDashes) do
                    dash:Hide()
                end
            end
        end
    end
end

local function GetLootSlotItemID(slot)
    local lootLink = GetLootSlotLink(slot)
    if lootLink then
        local itemID = GetItemInfoInstantCompat(lootLink)
        return itemID
    end
    return nil
end

local function CheckLootWindow()
    local numLootItems = GetNumLootItems()
    local foundWishlistItem = false
    local wishlistItems = {}

    for slot = 1, numLootItems do
        local itemID = GetLootSlotItemID(slot)
        local isOnWishlist = itemID and WishlistService and WishlistService.IsOnWishlist(itemID)
        if DEBUG_LOG then
            print("|cffff00ff[AGC Debug]|r Slot", slot, "- itemID:", tostring(itemID), "isOnWishlist:", tostring(isOnWishlist))
        end
        if DEBUG_SHOW_ALL or isOnWishlist then
            foundWishlistItem = true
            local lootButton = _G["LootButton" .. slot]
            if lootButton then
                local glow = CreateGlowFrame(lootButton, slot)
                if glow then
                    glow:SetParent(lootButton)
                    glow:SetAllPoints(lootButton)
                    glow.marchOffset = 0
                    glow:Show()
                end
            end
            if itemID then
                local itemName = GetItemInfoCompat(itemID)
                if itemName then
                    table.insert(wishlistItems, { name = itemName, id = itemID })
                end
            end
        end
    end
    return foundWishlistItem, wishlistItems
end

local function OnLootOpened()
    HideAllGlows()
    C_Timer.After(0.1, function()
        local found, wishlistItems = CheckLootWindow()
        if found then
            if AdventureGuideClassicEventToastManager then
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
                for _, item in ipairs(wishlistItems) do
                    print("|cff00ff00[AGC Wishlist]|r Item dropped:", item.name)
                end
            end
        end
    end)
end

local function OnLootClosed()
    HideAllGlows()
end

local function OnLootSlotCleared(slot)
    if glowFrames[slot] then
        glowFrames[slot]:Hide()
        if glowFrames[slot].dashes then
            for _, sideDashes in ipairs(glowFrames[slot].dashes) do
                for _, dash in ipairs(sideDashes) do
                    dash:Hide()
                end
            end
        end
    end
end

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
