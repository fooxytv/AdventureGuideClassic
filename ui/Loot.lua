--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Loot")
local EquipMapping = GetEquipMapping()
local Colors = GetColorMapping()

-- API compatibility: Classic Era uses global functions, TBC+ uses C_Item namespace
local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo
local GetItemInfoInstantCompat = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
local function RequestLoadItemDataCompat(itemId)
    if C_Item and C_Item.RequestLoadItemDataByID then
        C_Item.RequestLoadItemDataByID(itemId)
    else
        GetItemInfo(itemId)
    end
end

local components
local lootContainer
local lootScrollBox
local previewFrame
local rotationSpeed = 0.5
local pendingItemIds = {}
local currentEncounterId = nil

local function truncateText(text, maxLength)
	if #text > maxLength then
		return text:sub(1, maxLength - 3) .. "..."
	else
		return text
	end
end

local PREVIEW_ZOOM = 0
local PREVIEW_CAM_DISTANCE_SCALE = 1

local function CreatePreviewFrame()
	if previewFrame then return previewFrame end
	local frame = CreateFrame("Frame", "ItemPreviewFrame", UIParent, "BackdropTemplate")
	frame:SetSize(200, 280)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetFrameLevel(1000)
	frame:Hide()
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
	frame.model = CreateFrame("DressUpModel", nil, frame)
	frame.model:SetSize(190, 260)
	frame.model:SetPoint("CENTER", 0, 5)
	frame.cameraAngle = 0
	frame.model:SetCamDistanceScale(PREVIEW_CAM_DISTANCE_SCALE)
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.cameraAngle = self.cameraAngle + (rotationSpeed * elapsed)
		self.model:SetRotation(self.cameraAngle)
	end)
	previewFrame = frame
	return frame
end

-- previewItem is an item link, or an item string when a token resolves to a set piece.
local function ShowItemPreview(previewItem, anchorFrame)
	if not previewItem then return end
	local frame = CreatePreviewFrame()
	if SettingsService and SettingsService.GetScale then
		frame:SetScale(SettingsService.GetScale())
	end
	frame:ClearAllPoints()
	frame:SetPoint("TOP", GameTooltip, "BOTTOM", 0, -5)
	frame:Show()
	frame.model:SetUnit("player")
	frame.model:SetCamDistanceScale(PREVIEW_CAM_DISTANCE_SCALE)
	frame.model:SetPortraitZoom(PREVIEW_ZOOM)
	frame.model:Undress()
	for slot = 1, 19 do
		frame.model:UndressSlot(slot)
	end
	C_Timer.After(0.15, function()
		if frame.model and frame:IsShown() then
			frame.model:TryOn(previewItem)
		end
	end)
	frame.cameraAngle = 0
end

local function HideItemPreview()
	if previewFrame then
		previewFrame:Hide()
	end
end

--[[
	What the character model should wear when previewing a loot entry.

	A tier token has no appearance of its own, so trying one on leaves the model
	bare. Resolve tokens to the set piece the player's class trades them for. The
	loot entry keeps showing the token; only the preview differs.

	Returns an item string rather than a bare id, since that is accepted by both
	TryOn and DressUpItemLink on every client we support.
]]
local function GetPreviewTarget(lootItem)
	if not lootItem then return nil end
	if lootItem.itemId and TierTokenService and TierTokenService.IsToken(lootItem.itemId) then
		local pieceId = TierTokenService.GetPreviewItemId(lootItem.itemId)
		if pieceId then
			RequestLoadItemDataCompat(pieceId)
			return "item:" .. pieceId
		end
	end
	return lootItem.link
end

local function ProcessItemData(itemId)
	local itemName, itemLink, itemQuality, _, _, itemType, itemSubType, _, itemEquipLoc, itemIcon = GetItemInfoCompat(itemId)
	if itemName then
		-- Numeric class/subclass for filtering: itemSubType is localised, so
		-- comparing it against "Plate" would break on a non-English client.
		local _, _, _, _, _, classID, subclassID = GetItemInfoInstantCompat(itemId)
		return {
			isHeader = false,
			itemId = itemId,
			name = itemName,
			link = itemLink,
			quality = itemQuality,
			icon = itemIcon,
			armorType = itemSubType,
			slot = EquipMapping[itemEquipLoc] or itemEquipLoc,
			classID = classID,
			subclassID = subclassID,
			equipLoc = itemEquipLoc,
		}
	end
	return nil
end

local function ButtonOnUpdate(self, elapsed)
	if self.checkCtrl then
		local isCtrlDown = IsControlKeyDown()
		if isCtrlDown and not self.wasCtrlDown then
			ShowItemPreview(self.previewTarget, self)
			self.wasCtrlDown = true
		elseif not isCtrlDown and self.wasCtrlDown then
			HideItemPreview()
			self.wasCtrlDown = false
		end
	end
end

local function ButtonOnEnter(self)
	local lootItem = self.lootItem
	if lootItem and lootItem.link then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(lootItem.link)
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
		self.checkCtrl = true
		self.wasCtrlDown = false
		self.previewTarget = GetPreviewTarget(lootItem)
		self:SetScript("OnUpdate", ButtonOnUpdate)
	end
end

local function ButtonOnLeave(self)
	self.checkCtrl = false
	self.wasCtrlDown = false
	self:SetScript("OnUpdate", nil)
	HideItemPreview()
	GameTooltip_Hide()
end

local function ButtonOnClick(self, mouseButton)
	local lootItem = self.lootItem
	if not lootItem then return end
	if mouseButton == "RightButton" and IsShiftKeyDown() then
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
				GameTooltip:Hide()
				ButtonOnEnter(self)
			end
		end
	elseif mouseButton == "LeftButton" and IsControlKeyDown() then
		local target = GetPreviewTarget(lootItem)
		if target then
			DressUpItemLink(target)
		end
	elseif mouseButton == "LeftButton" then
		if lootItem.link then
			ChatEdit_InsertLink(lootItem.link)
		end
	end
end

local FILTER_ROW_HEIGHT = 26
local ALL_CLASSES = "ALL"
local ALL_ARMOR = "ALL"
local classDropdown, armorDropdown

local function RefreshAfterFilterChange(dropdown, text)
	UIDropDownMenu_SetText(dropdown, text)
	CloseDropDownMenus()
	component.Show()
end

local function OnClassFilterSelected(self)
	LootFilterService.SetClassFilter(self.value ~= ALL_CLASSES and self.value or nil)
	RefreshAfterFilterChange(classDropdown, self:GetText())
end

local function OnArmorFilterSelected(self)
	LootFilterService.SetArmorFilter(self.value ~= ALL_ARMOR and self.value or nil)
	RefreshAfterFilterChange(armorDropdown, self:GetText())
end

local function InitializeClassDropdown()
	local current = LootFilterService.GetClassFilter()
	local info = UIDropDownMenu_CreateInfo()
	info.text = "All Classes"
	info.value = ALL_CLASSES
	info.func = OnClassFilterSelected
	info.checked = (current == nil)
	UIDropDownMenu_AddButton(info)
	for _, class in ipairs(LootFilterService.GetClasses()) do
		info = UIDropDownMenu_CreateInfo()
		info.text = class.label
		info.value = class.token
		info.func = OnClassFilterSelected
		info.checked = (current == class.token)
		info.colorCode = class.colorCode
		UIDropDownMenu_AddButton(info)
	end
end

local function InitializeArmorDropdown()
	local current = LootFilterService.GetArmorFilter()
	local info = UIDropDownMenu_CreateInfo()
	info.text = "All Armor"
	info.value = ALL_ARMOR
	info.func = OnArmorFilterSelected
	info.checked = (current == nil)
	UIDropDownMenu_AddButton(info)
	for _, armor in ipairs(LootFilterService.GetArmorTypes()) do
		info = UIDropDownMenu_CreateInfo()
		info.text = armor.label
		info.value = armor.subclass
		info.func = OnArmorFilterSelected
		info.checked = (current == armor.subclass)
		UIDropDownMenu_AddButton(info)
	end
end

-- Restores the dropdown captions from saved state, so a filter kept across
-- sessions is visible rather than silently hiding loot.
local function RefreshFilterCaptions()
	if not classDropdown then return end
	local class = LootFilterService.GetClassFilter()
	local label = "All Classes"
	if class then
		for _, entry in ipairs(LootFilterService.GetClasses()) do
			if entry.token == class then label = entry.label break end
		end
	end
	UIDropDownMenu_SetText(classDropdown, label)

	local armor = LootFilterService.GetArmorFilter()
	label = "All Armor"
	if armor then
		for _, entry in ipairs(LootFilterService.GetArmorTypes()) do
			if entry.subclass == armor then label = entry.label break end
		end
	end
	UIDropDownMenu_SetText(armorDropdown, label)
end

local function CreateFilterDropdowns(parent)
	classDropdown = CreateFrame("Frame", "AGCLootClassFilter", parent, "UIDropDownMenuTemplate")
	-- UIDropDownMenuTemplate carries ~16px of invisible padding either side, hence
	-- the negative x offsets used to line the widgets up with the list below.
	classDropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", -12, -2)
	UIDropDownMenu_SetWidth(classDropdown, 100)
	UIDropDownMenu_Initialize(classDropdown, InitializeClassDropdown)

	armorDropdown = CreateFrame("Frame", "AGCLootArmorFilter", parent, "UIDropDownMenuTemplate")
	armorDropdown:SetPoint("LEFT", classDropdown, "RIGHT", -12, 0)
	UIDropDownMenu_SetWidth(armorDropdown, 90)
	UIDropDownMenu_Initialize(armorDropdown, InitializeArmorDropdown)

	RefreshFilterCaptions()
end

function component.Init(components_)
	components = components_
	lootContainer = CreateFrame("Frame", nil, EncounterJournal.encounter.info)
	lootContainer:SetSize(345, 382)
	lootContainer:SetPoint("BOTTOMRIGHT", -5, 1)
	EncounterJournal.encounter.LootContainer = lootContainer
	lootScrollBox = CreateFrame("Frame", nil, lootContainer, "WowScrollBoxList")
	EncounterJournal.encounter.LootScrollBox = lootScrollBox
	-- The filter row sits above the list, inside the loot container, so it is
	-- shown and hidden along with the loot view.
	lootScrollBox:SetSize(345, 382 - FILTER_ROW_HEIGHT)
	lootScrollBox:SetPoint("BOTTOMRIGHT", -20, 1)
	CreateFilterDropdowns(lootContainer)
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
			button.wishlistStar = button:CreateTexture(nil, "OVERLAY")
			button.wishlistStar:SetSize(16, 16)
			button.wishlistStar:SetPoint("TOPRIGHT", button.icon, "TOPRIGHT", 2, 2)
			button.wishlistStar:SetTexture("Interface\\COMMON\\ReputationStar")
			button.wishlistStar:SetTexCoord(0, 0.5, 0, 0.5)
			button.wishlistStar:Hide()
			button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			button.initialized = true
		end
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
			if lootItem.itemId and WishlistService and WishlistService.IsOnWishlist(lootItem.itemId) then
				button.wishlistStar:Show()
			else
				button.wishlistStar:Hide()
			end
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

local function OnItemDataLoadResult(event, itemId, success)
	if event == "GET_ITEM_INFO_RECEIVED" then
		success = true
	end
	if success and pendingItemIds[itemId] then
		pendingItemIds[itemId] = nil
		component.Show()
	end
end

local eventFrame = CreateFrame("Frame")
if C_Item and C_Item.RequestLoadItemDataByID then
	eventFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
else
	eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
end
eventFrame:SetScript("OnEvent", function(self, event, ...)
	OnItemDataLoadResult(event, ...)
end)

function component.Show()
	if not lootScrollBox then return end
	local encounterLoot = AdventureGuideNavigationService.GetEncounterLoot()
	if not encounterLoot then return end
	-- Init runs before ADDON_LOADED populates SavedVariables, so the captions are
	-- resynced here rather than only at creation.
	RefreshFilterCaptions()
	wipe(pendingItemIds)
	local dataProvider = CreateDataProvider()
	local shownCount = 0

	--[[
		Resolve a category to the loot items that survive the filter, requesting
		anything not yet cached. Collecting before inserting is what lets a
		category header be skipped when the filter empties it out.
	]]
	local function Collect(itemIds)
		local items = {}
		for _, itemId in ipairs(itemIds or {}) do
			local lootItem = ProcessItemData(itemId)
			if lootItem then
				if LootFilterService.PassesFilter(lootItem) then
					table.insert(items, lootItem)
				end
			else
				pendingItemIds[itemId] = true
				RequestLoadItemDataCompat(itemId)
			end
		end
		return items
	end

	for _, lootItem in ipairs(Collect(encounterLoot.loot)) do
		dataProvider:Insert(lootItem)
		shownCount = shownCount + 1
	end
	local lootCategories = {
		{ loot = encounterLoot.sharedLoot, headerTitle = "Shared Loot" },
		{ loot = encounterLoot.rareLoot, headerTitle = "Rare Loot" },
		{ loot = encounterLoot.veryRareLoot, headerTitle = "Very Rare" },
		{ loot = encounterLoot.extremelyRareLoot, headerTitle = "Extremely Rare" },
	}
	for _, category in ipairs(lootCategories) do
		local items = Collect(category.loot)
		if #items > 0 then
			dataProvider:Insert({ isHeader = true, text = category.headerTitle })
			for _, lootItem in ipairs(items) do
				dataProvider:Insert(lootItem)
				shownCount = shownCount + 1
			end
		end
	end

	-- Only claim there is nothing once everything has actually loaded, otherwise
	-- the message flashes up while item data is still arriving.
	if shownCount == 0 and not next(pendingItemIds) and LootFilterService.IsFiltered() then
		dataProvider:Insert({ isHeader = true, text = "No loot matches this filter" })
	end

	lootScrollBox:SetDataProvider(dataProvider)
	components.EncounterFrame.SetCurrentView(lootContainer)
end

UI.Add(component)
