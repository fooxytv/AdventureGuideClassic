--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Loot")
local EquipMapping = GetEquipMapping()
local Colors = GetColorMapping()
local components
local lootContainer
local lootScrollBox
local previewFrame
-- A three-quarter view, so the model is not square-on to the camera.
local PREVIEW_ROTATION = 0.45
local pendingItemIds = {}
local PREVIEW_ZOOM = 0
local PREVIEW_CAM_DISTANCE_SCALE = 1
local currentEncounterId = nil
local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo
local GetItemInfoInstantCompat = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant

local function RequestLoadItemDataCompat(itemId)
    if C_Item and C_Item.RequestLoadItemDataByID then
        C_Item.RequestLoadItemDataByID(itemId)
    else
        GetItemInfo(itemId)
    end
end

local function truncateText(text, maxLength)
	if #text > maxLength then
		return text:sub(1, maxLength - 3) .. "..."
	else
		return text
	end
end

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
	--[[
	The model holds still.

	It used to turn continuously, a SetRotation every frame, which read as a flicker
	rather than a turn: the model re-renders on each call and at this size the
	difference between one frame and the next is too small to look like movement. A
	fixed three-quarter view shows the piece better than a slow spin did.
	]]
	frame.model:SetCamDistanceScale(PREVIEW_CAM_DISTANCE_SCALE)
	previewFrame = frame
	return frame
end

local previewedItem

local function ShowItemPreview(previewItem, anchorFrame)
	if not previewItem then return end
	local frame = CreatePreviewFrame()
	if SettingsService and SettingsService.GetScale then
		frame:SetScale(SettingsService.GetScale())
	end
	frame:ClearAllPoints()
	frame:SetPoint("TOP", GameTooltip, "BOTTOM", 0, -5)
	frame:Show()

	--[[
	Asking for the item already on the model is not a request to put it on again.
	Redressing means undressing first and waiting for the model to catch up, which is
	visible as a flash, so a repeat call only re-anchors and leaves the model alone.
	]]
	if previewedItem == previewItem then return end
	previewedItem = previewItem

	frame.model:SetUnit("player")
	frame.model:SetCamDistanceScale(PREVIEW_CAM_DISTANCE_SCALE)
	frame.model:SetPortraitZoom(PREVIEW_ZOOM)
	--[[
	Undress once, not twenty times.

	Undress already strips the model; the nineteen UndressSlot calls that followed it
	each forced their own re-render, which is the burst of flashes before the preview
	settles. One call does the same job in one frame.
	]]
	frame.model:Undress()
	C_Timer.After(0.15, function()
		if frame.model and frame:IsShown() then
			frame.model:TryOn(previewItem)
		end
	end)
	if type(frame.model.SetRotation) == "function" then
		frame.model:SetRotation(PREVIEW_ROTATION)
	end
end

local function HideItemPreview()
	previewedItem = nil
	if previewFrame then
		previewFrame:Hide()
	end
end

--[[
	Exposed so the Quests tab can preview a reward on the character without standing up
	a second DressUpModel. One preview frame, one place that knows how to undress the
	model before trying an item on.
]]
function component.PreviewItem(link)
	ShowItemPreview(link)
end

function component.HidePreview()
	HideItemPreview()
end

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
				--[[
					Unpinning while the pinned filter is on has to drop the row, so the list
					is rebuilt rather than just restoring the tooltip. Safe here because the
					rebuild is answering a click: it is hover-driven refreshes that pull rows
					out from under the cursor.
				]]
				if LootFilterService.GetPinnedFilter() then
					component.Show()
				else
					ButtonOnEnter(self)
				end
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
local classDropdown, armorDropdown, pinnedToggle, clearFiltersButton

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
-- sessions is visible rather than silently hiding loot. Also shows the clear
-- button only while something is actually filtered.
local function RefreshFilterCaptions()
	if not classDropdown then return end
	if clearFiltersButton then
		clearFiltersButton:SetShown(LootFilterService.IsFiltered())
	end
	if pinnedToggle then
		pinnedToggle:SetChecked(LootFilterService.GetPinnedFilter())
	end
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

	--[[
		Unlabelled on purpose: the filter row has no width left for a caption. The star
		beside it is the same one drawn on a pinned row, so the toggle reads as "show only
		the starred ones" without a word of explanation, and the tooltip covers the rest.
	]]
	pinnedToggle = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	pinnedToggle:SetSize(24, 24)
	pinnedToggle:SetPoint("LEFT", armorDropdown, "RIGHT", -8, 2)
	pinnedToggle.star = pinnedToggle:CreateTexture(nil, "OVERLAY")
	pinnedToggle.star:SetSize(14, 14)
	pinnedToggle.star:SetPoint("LEFT", pinnedToggle, "RIGHT", -1, 0)
	pinnedToggle.star:SetTexture("Interface\\COMMON\\ReputationStar")
	pinnedToggle.star:SetTexCoord(0, 0.5, 0, 0.5)
	pinnedToggle:SetScript("OnClick", function(self)
		LootFilterService.SetPinnedFilter(self:GetChecked())
		CloseDropDownMenus()
		component.Show()
	end)
	pinnedToggle:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Pinned loot only")
		GameTooltip:AddLine(
			"Shows just the items on your wishlist, grouped by boss across this instance.",
			1, 1, 1, true)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("|cffaaaaaaShift+Right-click an item to pin it.|r")
		GameTooltip:Show()
	end)
	pinnedToggle:SetScript("OnLeave", GameTooltip_Hide)

	clearFiltersButton = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
	clearFiltersButton:SetSize(22, 22)
	clearFiltersButton:SetPoint("LEFT", pinnedToggle.star, "RIGHT", 0, 0)
	clearFiltersButton:SetScript("OnClick", function()
		LootFilterService.ClearFilters()
		CloseDropDownMenus()
		GameTooltip_Hide()
		component.Show()
	end)
	clearFiltersButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Clear filters")
		GameTooltip:Show()
	end)
	clearFiltersButton:SetScript("OnLeave", GameTooltip_Hide)
	clearFiltersButton:Hide()

	RefreshFilterCaptions()
end

function component.Init(components_)
	components = components_
	lootContainer = CreateFrame("Frame", nil, EncounterJournal.encounter.info)
	lootContainer:SetSize(345, 382)
	lootContainer:SetPoint("BOTTOMRIGHT", -5, 1)
	lootContainer:Hide()
	EncounterJournal.encounter.LootContainer = lootContainer
	lootScrollBox = CreateFrame("Frame", nil, lootContainer, "WowScrollBoxList")
	EncounterJournal.encounter.LootScrollBox = lootScrollBox
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

	--[[
		WishlistService drops an item as soon as it is equipped. With the pinned filter on
		that row has to go, and nothing clicked to cause it, so the view needs telling.
		Nothing else claims this hook.
	]]
	if WishlistService then
		WishlistService.OnWishlistChanged = function()
			if lootContainer:IsShown() and LootFilterService.GetPinnedFilter() then
				component.Show()
			end
		end
	end
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

--[[
	Pinned mode ignores the selected boss and lists the whole instance's pinned loot,
	grouped under a header per boss.

	The per-encounter alternative was to filter only the boss on screen, but a player's
	pins are spread across an instance, so that view is empty on most bosses — which is
	the opposite of what pinning is for. Reading every encounter costs nothing: the
	instance table *is* the encounter list, and GetEncounterLoot takes an encounter.

	An item is attributed to the first boss that drops it and not repeated. Shared loot
	would otherwise appear under every boss in the instance.
]]
local function ShowPinnedAcrossInstance(dataProvider, Collect)
	local instance = AdventureGuideNavigationService.GetInstance()
	local encounters = instance
	if not (encounters and #encounters > 0) then
		encounters = { AdventureGuideNavigationService.GetEncounter() }
	end

	local shownCount = 0
	local seen = {}
	for _, boss in ipairs(encounters) do
		if boss then
			local bossLoot = AdventureGuideNavigationService.GetEncounterLoot(boss)
			local items = {}
			for _, itemIds in ipairs({
				bossLoot.loot, bossLoot.sharedLoot, bossLoot.rareLoot,
				bossLoot.veryRareLoot, bossLoot.extremelyRareLoot,
			}) do
				for _, lootItem in ipairs(Collect(itemIds)) do
					if not seen[lootItem.itemId] then
						seen[lootItem.itemId] = true
						table.insert(items, lootItem)
					end
				end
			end
			if #items > 0 then
				dataProvider:Insert({ isHeader = true, text = boss.name or "Unknown" })
				for _, lootItem in ipairs(items) do
					dataProvider:Insert(lootItem)
					shownCount = shownCount + 1
				end
			end
		end
	end
	return shownCount
end

function component.Show()
	if not lootScrollBox then return end
	local encounterLoot = AdventureGuideNavigationService.GetEncounterLoot()
	if not encounterLoot then return end
	RefreshFilterCaptions()
	wipe(pendingItemIds)
	local dataProvider = CreateDataProvider()
	local shownCount = 0
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

	if LootFilterService.GetPinnedFilter() then
		shownCount = ShowPinnedAcrossInstance(dataProvider, Collect)
	else
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
	end

	if shownCount == 0 and not next(pendingItemIds) and LootFilterService.IsFiltered() then
		local emptyText = "No loot matches this filter"
		if LootFilterService.GetPinnedFilter() then
			emptyText = "Nothing pinned in this instance"
		end
		dataProvider:Insert({ isHeader = true, text = emptyText })
	end

	lootScrollBox:SetDataProvider(dataProvider)
	components.EncounterFrame.SetCurrentView(lootContainer)
end

UI.Add(component)
