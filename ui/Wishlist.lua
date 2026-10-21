--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Wishlist")
local components
local wishlist
local scrollbox
local showObtained = false
local scopeFilter = "all"

local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo

local ROW_WIDTH = 740
local ROW_HEIGHT = 48
local ICON_SIZE = 34
local ICON_GAP = 3
local ICON_START = 360
local MAX_ICONS = 9

local pendingItemIds = { }
local failedItemIds = { }

--[[
	The six frames on LootTabBorders, which is Blizzard's own LootTab sheet: six 38x38
	cells on a 43px grid, measured off the pixels rather than guessed.

	Four carry an unambiguous colour -- green, blue, purple and orange. The other two
	are a neutral grey frame and a warm gold one, so poor and common share the grey
	while artifact and heirloom share the gold. If a border looks wrong in game, those
	two are the inference; the coloured four are not.
]]
local QUALITY_BORDER = {
	[0] = { 0.347656, 0.496094, 0.359375, 0.656250 },
	[1] = { 0.347656, 0.496094, 0.359375, 0.656250 },
	[2] = { 0.179688, 0.328125, 0.023438, 0.320312 },
	[3] = { 0.347656, 0.496094, 0.023438, 0.320312 },
	[4] = { 0.011719, 0.160156, 0.023438, 0.320312 },
	[5] = { 0.179688, 0.328125, 0.359375, 0.656250 },
	[6] = { 0.011719, 0.160156, 0.359375, 0.656250 },
	[7] = { 0.011719, 0.160156, 0.359375, 0.656250 },
}

local function RequestLoadItemDataCompat(itemId)
	if C_Item and C_Item.RequestLoadItemDataByID then
		C_Item.RequestLoadItemDataByID(itemId)
	else
		GetItemInfo(itemId)
	end
end

--[[
	What to draw for one entry. The wishlist stores the link and the name at the moment
	the item was added, so a row can always be drawn; the icon and the quality are only
	in the item cache, which may not hold them yet on a fresh login.
]]
local function ItemDisplay(entry)
	local itemID = entry.itemID
	local name, link, quality, _, _, _, _, _, _, icon = GetItemInfoCompat(itemID)
	if not name and not failedItemIds[itemID] then
		pendingItemIds[itemID] = true
		RequestLoadItemDataCompat(itemID)
	end
	return {
		itemID = itemID,
		name = name or entry.itemName,
		link = link or entry.itemLink,
		quality = quality or 1,
		icon = icon or "Interface/Icons/INV_Misc_QuestionMark",
		sourceBoss = entry.sourceBoss,
		sourceInstance = entry.sourceInstance,
		obtained = entry.obtainedDate ~= nil,
	}
end

local function FindEncounter(instance, bossName)
	for _, encounter in ipairs(instance) do
		if encounter.name == bossName then return encounter end
	end
	return nil
end

--[[
	Land on the boss the item came from with its loot open, which is the same place the
	search results go. The wishlist only ever stored names, so the instance and the boss
	are resolved back to their tables here.
]]
local function GoTo(instanceName, bossName)
	local instance = InstanceService.GetInstanceByName(instanceName)
	if not instance then return end
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
	AdventureGuideNavigationService.Reset()
	AdventureGuideNavigationService.SetInstance(instance)
	local encounter = bossName and FindEncounter(instance, bossName)
	if encounter then
		AdventureGuideNavigationService.SetEncounter(encounter)
	end
	components.EncounterFrame.ShowInstanceInfo(instance)
	components.NavBar.SetInstance(instance)
	if encounter then
		components.NavBar.SetEncounter(encounter.encounterID)
		components.NavBar.Refresh(AdventureGuideNavigationService.GetEncounterName())
		if components.Loot and components.Loot.Show then
			components.Loot.Show()
		end
	end
end

local function IconOnEnter(self)
	local item = self.item
	if not item then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if item.link then
		GameTooltip:SetHyperlink(item.link)
	else
		GameTooltip:SetText(item.name or "Unknown")
	end
	GameTooltip:AddLine(" ")
	if item.sourceBoss then
		GameTooltip:AddLine("|cffaaaaaaFrom|r " .. item.sourceBoss)
	end
	if item.obtained then
		GameTooltip:AddLine("|cff00ff00Obtained|r")
	end
	GameTooltip:AddLine("|cffaaaaaa(Click to open its loot)|r")
	GameTooltip:Show()
end

local function IconOnLeave()
	GameTooltip_Hide()
end

local function IconOnClick(self)
	local item = self.item
	if item then GoTo(item.sourceInstance, item.sourceBoss) end
end

local function RowOnClick(self)
	if self.group then GoTo(self.group.name, nil) end
end

local function IconAt(row, index)
	local icon = row.icons[index]
	if not icon then
		icon = CreateFrame("Button", nil, row)
		icon:SetSize(ICON_SIZE, ICON_SIZE)
		icon:SetPoint("LEFT", ICON_START + (index - 1) * (ICON_SIZE + ICON_GAP), 0)
		icon.tex = icon:CreateTexture(nil, "ARTWORK")
		icon.tex:SetSize(ICON_SIZE - 6, ICON_SIZE - 6)
		icon.tex:SetPoint("CENTER")
		icon.border = icon:CreateTexture(nil, "OVERLAY")
		icon.border:SetTexture(I.LootTabBorders)
		icon.border:SetAllPoints()
		icon:SetScript("OnEnter", IconOnEnter)
		icon:SetScript("OnLeave", IconOnLeave)
		icon:SetScript("OnClick", IconOnClick)
		row.icons[index] = icon
	end
	return icon
end

local function RowInitializer(row, group)
	if not row.initialized then
		row:SetSize(ROW_WIDTH, ROW_HEIGHT)
		row.bg = row:CreateTexture(nil, "BACKGROUND")
		row.bg:SetPoint("TOPLEFT", 2, -2)
		row.bg:SetPoint("BOTTOMRIGHT", -2, 2)
		row.bg:SetColorTexture(0, 0, 0, 0.22)
		row.hover = row:CreateTexture(nil, "HIGHLIGHT")
		row.hover:SetPoint("TOPLEFT", 2, -2)
		row.hover:SetPoint("BOTTOMRIGHT", -2, 2)
		row.hover:SetColorTexture(1, 0.88, 0.60, 0.07)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		row.name:SetJustifyH("LEFT")
		row.name:SetSize(330, 18)
		row.name:SetPoint("TOPLEFT", 14, -7)
		row.bosses = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		row.bosses:SetJustifyH("LEFT")
		row.bosses:SetSize(330, 12)
		row.bosses:SetPoint("TOPLEFT", 14, -28)
		row.more = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		row.more:SetPoint("RIGHT", -10, 0)
		row.icons = { }
		row:RegisterForClicks("LeftButtonUp")
		row:SetScript("OnClick", RowOnClick)
		row.initialized = true
	end
	row.group = group
	row.name:SetText(group.name)
	row.bosses:SetText(table.concat(group.bosses, ", "))

	local shown = math.min(#group.items, MAX_ICONS)
	for index = 1, shown do
		local item = ItemDisplay(group.items[index])
		local icon = IconAt(row, index)
		local coords = QUALITY_BORDER[item.quality] or QUALITY_BORDER[1]
		icon.item = item
		icon.tex:SetTexture(item.icon)
		icon.tex:SetDesaturated(item.obtained)
		icon.border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
		icon:SetAlpha(item.obtained and 0.45 or 1)
		icon:Show()
	end
	for index = shown + 1, #row.icons do
		row.icons[index]:Hide()
	end

	local hidden = #group.items - shown
	row.more:SetText(hidden > 0 and ("+" .. hidden) or "")
end

local function BuildFilters(parent)
	parent.filterDropdown = CreateFrame("Frame", parent:GetName() .. "FilterDropdown",
			parent, "UIDropDownMenuTemplate")
	parent.filterDropdown:SetPoint("TOPLEFT", 4, -36)
	UIDropDownMenu_SetWidth(parent.filterDropdown, 140)

	local SCOPES = {
		{ value = "all", text = ALL },
		{ value = "dungeons", text = DUNGEONS },
		{ value = "raids", text = RAIDS },
	}

	local function TextFor(value)
		for _, scope in ipairs(SCOPES) do
			if scope.value == value then return scope.text end
		end
		return ALL
	end

	local function OnScopeClick(self)
		scopeFilter = self.value
		UIDropDownMenu_SetText(parent.filterDropdown, TextFor(scopeFilter))
		CloseDropDownMenus()
		component.Refresh()
	end

	UIDropDownMenu_Initialize(parent.filterDropdown, function()
		for _, scope in ipairs(SCOPES) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = scope.text
			info.value = scope.value
			info.func = OnScopeClick
			info.checked = (scopeFilter == scope.value)
			UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetText(parent.filterDropdown, TextFor(scopeFilter))

	--[[
		An equipped item is marked rather than deleted, so it can be looked back at.
		Hidden by default, which is how the old delete-on-equip behaved from outside.
	]]
	parent.obtainedButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	parent.obtainedButton:SetSize(140, 22)
	parent.obtainedButton:SetPoint("TOPRIGHT", -18, -40)
	parent.obtainedButton:SetText("Show Obtained")
	parent.obtainedButton:SetScript("OnClick", function(self)
		showObtained = not showObtained
		self:SetText(showObtained and "Hide Obtained" or "Show Obtained")
		component.Refresh()
	end)
end

local function InScope(instanceName)
	if scopeFilter == "all" then return true end
	local list = (scopeFilter == "raids") and InstanceService.GetRaids()
			or InstanceService.GetDungeons()
	for _, instance in ipairs(list) do
		if instance.name == instanceName then return true end
	end
	return false
end

function component.Init(components_)
	components = components_
	wishlist = CreateFrame("Frame", EncounterJournal:GetName() .. "Wishlist", EncounterJournal)
	component.frame = wishlist
	EncounterJournal.wishlist = wishlist
	wishlist:SetPoint("TOPLEFT", EncounterJournal.inset, 0, -2)
	wishlist:SetPoint("BOTTOMRIGHT", EncounterJournal.inset, -3, 0)
	wishlist.bg = wishlist:CreateTexture(nil, "BACKGROUND")
	wishlist.bg:SetTexture(I.LootTabBackground)
	-- Only the top-left 788x426 of the 1024x512 sheet carries the parchment.
	wishlist.bg:SetTexCoord(0, 0.769531, 0, 0.832031)
	wishlist.bg:SetAllPoints()
	wishlist.bg:SetPoint("TOPLEFT", 3, -1)
	wishlist.title = wishlist:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge2")
	wishlist.title:SetJustifyH("LEFT")
	wishlist.title:SetPoint("TOPLEFT", 20, -15)
	BuildFilters(wishlist)

	wishlist.empty = wishlist:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	wishlist.empty:SetPoint("CENTER", 0, 20)
	wishlist.empty:SetSize(460, 40)
	wishlist.empty:SetText("Nothing on your wishlist yet.\n"
			.. "|cffaaaaaaShift+Right-click an item in a boss's loot to add it.|r")
	wishlist.empty:Hide()

	scrollbox = CreateFrame("Frame", nil, wishlist, "WowScrollBoxList")
	scrollbox:SetSize(ROW_WIDTH, 348)
	scrollbox:SetPoint("TOPLEFT", 14, -72)
	local scrollbar = CreateFrame("EventFrame", nil, wishlist, "MinimalScrollBar")
	scrollbar:SetPoint("TOPLEFT", scrollbox, "TOPRIGHT", 12, -6)
	scrollbar:SetPoint("BOTTOMLEFT", scrollbox, "BOTTOMRIGHT", 12, 4)

	local view = CreateScrollBoxListLinearView()
	view:SetElementExtent(ROW_HEIGHT)
	view:SetElementInitializer("Button", RowInitializer)
	ScrollUtil.InitScrollBoxListWithScrollBar(scrollbox, scrollbar, view)

	--[[
		ui/Loot.lua owns OnWishlistChanged, so this registers alongside it rather than
		assigning over it. Adding or removing an item while the tab is open should be
		visible without leaving and coming back.
	]]
	WishlistService.RegisterChangeListener(function()
		if wishlist:IsShown() then component.Refresh() end
	end)

	--[[
		Both events, for the reason ui/Loot.lua records: which one a client raises for
		an uncached item does not follow from which API it exposes.
	]]
	local eventFrame = CreateFrame("Frame")
	Compat.RegisterEvents(eventFrame, "ITEM_DATA_LOAD_RESULT", "GET_ITEM_INFO_RECEIVED")
	eventFrame:SetScript("OnEvent", function(_, event, itemId, success)
		if event == "GET_ITEM_INFO_RECEIVED" then success = true end
		if not pendingItemIds[itemId] then return end
		pendingItemIds[itemId] = nil
		if not success then
			failedItemIds[itemId] = true
			return
		end
		if wishlist:IsShown() then component.Refresh() end
	end)

	wishlist:Hide()
end

--[[
	Rebuild the list in place. Separate from Show so an item arriving from the cache,
	or a change made from the loot view, does not re-enter the view or reset the nav bar.
]]
function component.Refresh()
	local groups = { }
	for _, group in ipairs(WishlistService.GetGrouped(showObtained)) do
		if InScope(group.name) then
			table.insert(groups, group)
		end
	end
	local dataProvider = CreateDataProvider()
	for _, group in ipairs(groups) do
		dataProvider:Insert(group)
	end
	scrollbox:SetDataProvider(dataProvider)
	wishlist.empty:SetShown(#groups == 0)
	wishlist.title:SetText(("Wishlist (%d)"):format(WishlistService.GetCount()))
end

function component.Show()
	component.Refresh()
	components.EncounterJournal.SetCurrentView(wishlist)
	components.NavBar.Reset()
end

UI.Add(component)
