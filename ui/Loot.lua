--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Loot")
local EquipMapping = GetEquipMapping()
local Colors = GetColorMapping()
local components
local lootContainer
local lootScrollBox
local previewFrame
local rotationSpeed = 0.5

-- Track pending item loads and current encounter for smart refreshing
local pendingItemIds = {}
local currentEncounterId = nil

local function truncateText(text, maxLength)
	if #text > maxLength then
		return text:sub(1, maxLength - 3) .. "..."
	else
		return text
	end
end

-- Create the preview frame for Ctrl+hover item preview
local function CreatePreviewFrame()
	if previewFrame then return previewFrame end

	local frame = CreateFrame("Frame", "ItemPreviewFrame", UIParent, "BackdropTemplate")
	frame:SetSize(200, 280)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetFrameLevel(1000)
	frame:Hide()

	-- Set backdrop to pure black to match GameTooltip
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	frame:SetBackdropColor(0, 0, 0, 0.95)
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

	-- Model frame - use DressUpModel for item preview
	frame.model = CreateFrame("DressUpModel", nil, frame)
	frame.model:SetSize(190, 260)
	frame.model:SetPoint("CENTER", 0, 5)

	-- Camera orbit animation - positioned to fit taller races like Tauren/Draenei
	frame.cameraAngle = 0
	local cameraDistance = 1.8
	local cameraHeight = 0.7
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.cameraAngle = self.cameraAngle + (rotationSpeed * elapsed)
		-- Calculate camera position orbiting around the character
		local x = math.cos(self.cameraAngle) * cameraDistance
		local y = math.sin(self.cameraAngle) * cameraDistance
		self.model:SetCustomCamera(1)
		self.model:SetCameraPosition(x, y, cameraHeight)
		self.model:SetCameraTarget(0, 0, cameraHeight)
	end)

	previewFrame = frame
	return frame
end

-- Show preview frame below tooltip
local function ShowItemPreview(itemLink, anchorFrame)
	if not itemLink then return end

	local frame = CreatePreviewFrame()

	-- Position below the tooltip
	frame:ClearAllPoints()
	frame:SetPoint("TOP", GameTooltip, "BOTTOM", 0, -5)

	-- Show frame (needs to be visible for TryOn to work)
	frame:Show()

	-- Set unit and undress
	frame.model:SetUnit("player")
	frame.model:Undress()

	-- Undress all slots
	for slot = 1, 19 do
		frame.model:UndressSlot(slot)
	end

	-- Try on the item with a small delay to let undress complete
	C_Timer.After(0.15, function()
		if frame.model and frame:IsShown() then
			frame.model:TryOn(itemLink)
		end
	end)

	-- Reset camera angle
	frame.cameraAngle = 0
end

-- Hide preview frame
local function HideItemPreview()
	if previewFrame then
		previewFrame:Hide()
	end
end

-- Helper function to process a single item and return loot data (or nil if not cached)
local function ProcessItemData(itemId)
	local itemName, itemLink, itemQuality, _, _, itemType, itemSubType, _, itemEquipLoc, itemIcon = C_Item.GetItemInfo(itemId)
	if itemName then
		return {
			isHeader = false,
			itemId = itemId,
			name = itemName,
			link = itemLink,
			quality = itemQuality,
			icon = itemIcon,
			armorType = itemSubType,
			slot = EquipMapping[itemEquipLoc] or itemEquipLoc,
		}
	end
	return nil
end

-- Shared button OnUpdate handler for Ctrl key detection
local function ButtonOnUpdate(self, elapsed)
	if self.checkCtrl then
		local isCtrlDown = IsControlKeyDown()
		if isCtrlDown and not self.wasCtrlDown then
			ShowItemPreview(self.lootItemLink, self)
			self.wasCtrlDown = true
		elseif not isCtrlDown and self.wasCtrlDown then
			HideItemPreview()
			self.wasCtrlDown = false
		end
	end
end

-- Shared button OnEnter handler
local function ButtonOnEnter(self)
	local lootItem = self.lootItem
	if lootItem and lootItem.link then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(lootItem.link)
		-- Add wishlist hint to tooltip
		if lootItem.itemId then
			if WishlistService and WishlistService.IsOnWishlist(lootItem.itemId) then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("|cff00ff00On your Wishlist|r |cffaaaaaa(Shift+Right-click to remove)|r")
			else
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("|cffaaaaaa(Shift+Right-click to add to Wishlist)|r")
			end
		end
		GameTooltip:Show()

		-- Set up Ctrl key tracking
		self.checkCtrl = true
		self.wasCtrlDown = false
		self.lootItemLink = lootItem.link
		self:SetScript("OnUpdate", ButtonOnUpdate)
	end
end

-- Shared button OnLeave handler
local function ButtonOnLeave(self)
	self.checkCtrl = false
	self.wasCtrlDown = false
	self:SetScript("OnUpdate", nil)
	HideItemPreview()
	GameTooltip_Hide()
end

-- Shared button OnClick handler
local function ButtonOnClick(self, mouseButton)
	local lootItem = self.lootItem
	if not lootItem then return end

	if mouseButton == "RightButton" and IsShiftKeyDown() then
		-- Toggle wishlist (Shift + Right-click)
		if lootItem.itemId and WishlistService then
			local currentEncounter = AdventureGuideNavigationService.GetEncounter()
			local currentInstance = AdventureGuideNavigationService.GetInstance()
			local sourceBoss = currentEncounter and currentEncounter.name or "Unknown"
			local sourceInstance = currentInstance and currentInstance.name or "Unknown"

			local success, wasAdded = WishlistService.ToggleItem(
				lootItem.itemId,
				lootItem.link,
				lootItem.name,
				sourceBoss,
				sourceInstance
			)

			if success then
				if wasAdded then
					self.wishlistStar:Show()
					print("|cff00ff00[AGC]|r Added to Wishlist:", lootItem.link)
				else
					self.wishlistStar:Hide()
					print("|cffff9900[AGC]|r Removed from Wishlist:", lootItem.link)
				end
				-- Refresh tooltip
				GameTooltip:Hide()
				ButtonOnEnter(self)
			end
		end
	elseif mouseButton == "LeftButton" and IsControlKeyDown() then
		if lootItem.link then
			DressUpItemLink(lootItem.link)
		end
	elseif mouseButton == "LeftButton" then
		if lootItem.link then
			ChatEdit_InsertLink(lootItem.link)
		end
	end
end

function component.Init(components_)
	components = components_
	lootContainer = CreateFrame("Frame", nil, EncounterJournal.encounter.info)
	lootContainer:SetSize(345, 382)
	lootContainer:SetPoint("BOTTOMRIGHT", -5, 1)
	EncounterJournal.encounter.LootContainer = lootContainer
	lootScrollBox = CreateFrame("Frame", nil, lootContainer, "WowScrollBoxList")
	EncounterJournal.encounter.LootScrollBox = lootScrollBox
	lootScrollBox:SetSize(345, 382)
	lootScrollBox:SetPoint("BOTTOMRIGHT", -20, 1)
	local lootScrollBar = CreateFrame("EventFrame", nil, lootContainer, "MinimalScrollBar")
	EncounterJournal.encounter.LootScrollBar = lootScrollBar
	lootScrollBar:SetPoint("TOPLEFT", lootScrollBox, "TOPRIGHT", 5, -5)
	lootScrollBar:SetPoint("BOTTOMLEFT", lootScrollBox, "BOTTOMRIGHT", 5, 5)

	local function LootButtonInitializer(button, lootItem)
		if not button.initialized then
			button.icon = button:CreateTexture()
			button.icon:SetSize(45, 45)
			button.icon:SetPoint("LEFT", 0, -5)
			button.icon:SetDrawLayer("BACKGROUND")
			button.iconBorder = button:CreateTexture()
			button.iconBorder:SetTexture("Interface/Common/WhiteIconFrame")
			button.iconBorder:SetSize(45, 45)
			button.iconBorder:SetDrawLayer("OVERLAY")
			button.iconBorder:SetPoint("TOPLEFT", button.icon, "TOPLEFT")
			button.iconOverlay = button:CreateTexture()
			button.iconOverlay:SetTexture("Interface/Common/WhiteIconFrame")
			button.iconOverlay:SetSize(45, 45)
			button.iconOverlay:SetDrawLayer("OVERLAY")
			button.iconOverlay:SetPoint("TOPLEFT", button.icon, "TOPLEFT")
			button.bosslessTexture = button:CreateTexture()
			button.bosslessTexture:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
			button.bosslessTexture:SetTexCoord(0.00195313, 0.62890625, 0.61816406, 0.66210938)
			button.bosslessTexture:SetSize(321, 45)
			button.bosslessTexture:SetPoint("LEFT", 0, -5)
			button.bosslessTexture:SetDrawLayer("BORDER")
			button.name = button:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
			button.name:SetJustifyH("LEFT")
			button.name:SetSize(250, 45)
			button.name:SetPoint("TOPLEFT", 55, 3)
			button.armorType = button:CreateFontString()
			button.armorType:SetJustifyH("LEFT")
			button.armorType:SetSize(0, 12)
			button.armorType:SetPoint("BOTTOMRIGHT", -25, 5)
			button.armorType:SetTextColor(0, 0, 0)
			button.armorType:SetFont("Fonts\\FRIZQT__.TTF", 10)
			button.slot = button:CreateFontString()
			button.slot:SetJustifyH("LEFT")
			button.slot:SetSize(0, 12)
			button.slot:SetPoint("BOTTOMLEFT", 55, 3)
			button.slot:SetTextColor(0, 0, 0)
			button.slot:SetFont("Fonts\\FRIZQT__.TTF", 10)
			button.headerText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
			button.headerText:SetPoint("LEFT", 5, -7)
			-- Wishlist star icon
			button.wishlistStar = button:CreateTexture(nil, "OVERLAY")
			button.wishlistStar:SetSize(16, 16)
			button.wishlistStar:SetPoint("TOPRIGHT", button.icon, "TOPRIGHT", 2, 2)
			button.wishlistStar:SetTexture("Interface\\COMMON\\ReputationStar")
			button.wishlistStar:SetTexCoord(0, 0.5, 0, 0.5) -- Yellow star
			button.wishlistStar:Hide()
			-- Register for right-click
			button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			button.initialized = true
		end

		-- Store loot item reference on button for shared handlers
		button.lootItem = lootItem

		if lootItem.isHeader then
			button.headerText:SetText(lootItem.text)
			button.headerText:Show()
			button.icon:Hide()
			button.iconBorder:Hide()
			button.iconOverlay:Hide()
			button.bosslessTexture:Hide()
			button.name:Hide()
			button.armorType:Hide()
			button.slot:Hide()
			button.wishlistStar:Hide()
			button:SetScript("OnEnter", nil)
			button:SetScript("OnLeave", nil)
			button:SetScript("OnClick", nil)
		else
			button.headerText:Hide()
			button.icon:SetTexture(lootItem.icon)
			button.icon:Show()
			button.iconBorder:Show()
			button.iconOverlay:Show()
			button.bosslessTexture:Show()
			local truncatedName = truncateText(lootItem.name, 31)
			button.name:SetText(truncatedName)
			button.name:Show()
			button.armorType:SetText(lootItem.armorType or "Unknown")
			button.armorType:Show()
			button.slot:SetText(lootItem.slot or "Unknown")
			button.slot:Show()
			local color = Colors[lootItem.quality] or Colors[0]
			button.name:SetTextColor(color.r, color.g, color.b)
			button.iconBorder:SetVertexColor(color.r, color.g, color.b)
			button.iconOverlay:SetVertexColor(color.r, color.g, color.b)

			-- Show wishlist star if item is on wishlist
			if lootItem.itemId and WishlistService and WishlistService.IsOnWishlist(lootItem.itemId) then
				button.wishlistStar:Show()
			else
				button.wishlistStar:Hide()
			end

			-- Use shared handlers instead of creating new functions
			button:SetScript("OnEnter", ButtonOnEnter)
			button:SetScript("OnLeave", ButtonOnLeave)
			button:SetScript("OnClick", ButtonOnClick)
		end
	end

	local lootView = CreateScrollBoxListLinearView()
	lootView:SetElementExtent(47)
	lootView:SetElementInitializer("Button", LootButtonInitializer)
	ScrollUtil.InitScrollBoxListWithScrollBar(lootScrollBox, lootScrollBar, lootView)
end

-- Handle item data load results - only refresh if the item is one we're waiting for
local function OnItemDataLoadResult(event, itemId, success)
	if success and pendingItemIds[itemId] then
		pendingItemIds[itemId] = nil
		component.Show()
	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	OnItemDataLoadResult(event, ...)
end)

function component.Show()
	if not lootScrollBox then return end

	local encounterLoot = AdventureGuideNavigationService.GetEncounterLoot()
	if not encounterLoot then return end

	-- Clear pending items for fresh load
	wipe(pendingItemIds)

	local dataProvider = CreateDataProvider()

	-- Process main loot
	for _, itemId in ipairs(encounterLoot.loot or {}) do
		local lootItem = ProcessItemData(itemId)
		if lootItem then
			dataProvider:Insert(lootItem)
		else
			pendingItemIds[itemId] = true
			C_Item.RequestLoadItemDataByID(itemId)
		end
	end

	-- Process categorized loot
	local lootCategories = {
		{ loot = encounterLoot.sharedLoot, headerTitle = "Shared Loot" },
		{ loot = encounterLoot.rareLoot, headerTitle = "Rare Loot" },
		{ loot = encounterLoot.veryRareLoot, headerTitle = "Very Rare" },
		{ loot = encounterLoot.extremelyRareLoot, headerTitle = "Extremely Rare" },
	}

	for _, category in ipairs(lootCategories) do
		local categoryLoot = category.loot
		if categoryLoot and #categoryLoot > 0 then
			dataProvider:Insert({ isHeader = true, text = category.headerTitle })
			for _, itemId in ipairs(categoryLoot) do
				local lootItem = ProcessItemData(itemId)
				if lootItem then
					dataProvider:Insert(lootItem)
				else
					pendingItemIds[itemId] = true
					C_Item.RequestLoadItemDataByID(itemId)
				end
			end
		end
	end

	lootScrollBox:SetDataProvider(dataProvider)
	components.EncounterFrame.SetCurrentView(lootContainer)
end

UI.Add(component)
