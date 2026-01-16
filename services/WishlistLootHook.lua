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

-- Marching ants configuration
local MARCH_SPEED = 40           -- Pixels per second
local DASH_LENGTH = 4            -- Length of each dash in pixels
local DASH_GAP = 3               -- Gap between dashes in pixels
local BORDER_THICKNESS = 2       -- Thickness of border line
local BORDER_COLOR = {0, 0.8, 0} -- Green RGB
local ICON_SIZE = 32             -- WoW loot icon size
local ICON_OFFSET = 7            -- Offset from left edge of loot button to icon

-- Debug mode: set to true to show marching ants on ALL loot items (for testing)
local DEBUG_SHOW_ALL = false

-- Create a glow frame for a loot button with marching ants effect
local function CreateGlowFrame(lootButton, index)
    if glowFrames[index] then
        return glowFrames[index]
    end

    local glow = CreateFrame("Frame", "AGC_WishlistGlow" .. index, lootButton)
    glow:SetAllPoints(lootButton)
    glow:SetFrameLevel(lootButton:GetFrameLevel() + 10)

    -- Create a subtle green background tint on the row
    glow.border = glow:CreateTexture(nil, "BACKGROUND")
    glow.border:SetAllPoints(lootButton)
    glow.border:SetColorTexture(0, 0.8, 0, 0.15) -- Subtle green tint

    -- Calculate dash spacing and count
    local dashSpacing = DASH_LENGTH + DASH_GAP
    local dashesPerSide = math.ceil(ICON_SIZE / dashSpacing) + 2 -- Extra dashes for seamless looping

    -- Create dashes for all 4 sides (top, right, bottom, left)
    glow.dashes = {}
    for side = 1, 4 do
        glow.dashes[side] = {}
        for i = 1, dashesPerSide do
            local dash = glow:CreateTexture(nil, "OVERLAY")
            dash:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], 1)

            if side == 1 or side == 3 then -- horizontal (top/bottom)
                dash:SetSize(DASH_LENGTH, BORDER_THICKNESS)
            else -- vertical (right/left)
                dash:SetSize(BORDER_THICKNESS, DASH_LENGTH)
            end

            glow.dashes[side][i] = dash
        end
    end

    -- Animation state
    glow.marchOffset = 0
    glow.dashSpacing = dashSpacing
    glow.iconSize = ICON_SIZE
    glow.iconOffset = ICON_OFFSET

    -- OnUpdate handler for marching animation
    glow:SetScript("OnUpdate", function(self, elapsed)
        self.marchOffset = (self.marchOffset + elapsed * MARCH_SPEED) % self.dashSpacing

        local iconLeft = self.iconOffset
        local iconTop = (lootButton:GetHeight() - self.iconSize) / 2 + self.iconSize
        local iconRight = iconLeft + self.iconSize
        local iconBottom = iconTop - self.iconSize

        -- Update dash positions for each side
        for side, dashes in ipairs(self.dashes) do
            for i, dash in ipairs(dashes) do
                local basePos = (i - 1) * self.dashSpacing - self.marchOffset
                local pos, visible

                if side == 1 then -- Top edge: moves left to right
                    pos = iconLeft + basePos
                    visible = pos >= iconLeft - DASH_LENGTH and pos <= iconRight
                    dash:ClearAllPoints()
                    dash:SetPoint("BOTTOMLEFT", lootButton, "TOPLEFT", pos, -iconTop + BORDER_THICKNESS)
                elseif side == 2 then -- Right edge: moves top to bottom
                    pos = basePos
                    visible = pos >= -DASH_LENGTH and pos <= self.iconSize
                    dash:ClearAllPoints()
                    dash:SetPoint("TOPLEFT", lootButton, "TOPLEFT", iconRight - BORDER_THICKNESS, -iconBottom - pos - DASH_LENGTH)
                elseif side == 3 then -- Bottom edge: moves right to left
                    pos = self.iconSize - basePos
                    visible = pos >= -DASH_LENGTH and pos <= self.iconSize
                    dash:ClearAllPoints()
                    dash:SetPoint("BOTTOMLEFT", lootButton, "TOPLEFT", iconLeft + pos, -iconTop)
                else -- Left edge: moves bottom to top
                    pos = self.iconSize - basePos
                    visible = pos >= -DASH_LENGTH and pos <= self.iconSize
                    dash:ClearAllPoints()
                    dash:SetPoint("TOPLEFT", lootButton, "TOPLEFT", iconLeft, -iconBottom - pos)
                end

                if visible then
                    dash:Show()
                else
                    dash:Hide()
                end
            end
        end
    end)

    glow:Hide()
    glowFrames[index] = glow
    return glow
end

-- Hide all glow frames
local function HideAllGlows()
    for _, glow in pairs(glowFrames) do
        glow:Hide()
        -- Hide all dash textures
        if glow.dashes then
            for _, sideDashes in ipairs(glow.dashes) do
                for _, dash in ipairs(sideDashes) do
                    dash:Hide()
                end
            end
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
        local isOnWishlist = itemID and WishlistService and WishlistService.IsOnWishlist(itemID)
        if DEBUG_SHOW_ALL or isOnWishlist then
            foundWishlistItem = true

            -- Get the loot button
            local lootButton = _G["LootButton" .. slot]
            if lootButton then
                local glow = CreateGlowFrame(lootButton, slot)
                glow:SetParent(lootButton)
                glow:SetAllPoints(lootButton)
                glow.marchOffset = 0 -- Reset animation
                glow:Show()
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
        -- Hide all dash textures for this slot
        if glowFrames[slot].dashes then
            for _, sideDashes in ipairs(glowFrames[slot].dashes) do
                for _, dash in ipairs(sideDashes) do
                    dash:Hide()
                end
            end
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
