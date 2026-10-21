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
local measure
local showObtained = false
local scopeFilter = "all"

local Colors = GetColorMapping()
local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo

-- The order ui/EncounterJournalTabs.lua adds them in.
local DUNGEONS_TAB, RAIDS_TAB = 1, 2

-- Blizzard's own offset for this page: the parchment starts 51 below the inset
-- top and the band above it carries the title and the first filter.
local HEADER_HEIGHT = 50

--[[
	Blizzard's own numbers for this row, from LootJournalItemSetButtonTemplate:
	744x41, the name at (39, -6) in GameFontNormal, the line under it in
	GameFontNormalSmall tinted (0.718, 0.561, 0.416), and the icons starting at
	x=360 as 32x32 buttons five apart holding a 28x28 icon.

	ROW_WIDTH is only a fallback; the list sizes its rows from the scroll box.
]]
local ROW_WIDTH = 700
local ROW_HEIGHT = 41
-- How far the dark eases in at the left before it is at full strength.
local ROW_FADE_IN = 70
-- One line of the sub-line's font; anything taller is a wrap.
local SUBLINE_HEIGHT = 12
-- Breathing room under the boss list, so a wrapped one is not against the edge.
local ROW_PADDING = 9
-- One line of the name's font, which the boss list is anchored under.
local NAME_LINE_HEIGHT = 14
local NAME_WIDTH = 318
local NAME_X, NAME_Y = 39, -6
local SUBTEXT_R, SUBTEXT_G, SUBTEXT_B = 0.718, 0.561, 0.416
local ICON_SIZE = 32
local ICON_INNER = 28
local ICON_BORDER = 38
local ICON_GAP = 5
local ICON_START = 360
-- Eight, not nine: the ninth left no room for the overflow count beside it.
local MAX_ICONS = 8

local pendingItemIds = { }
local failedItemIds = { }

--[[
	An empty wishlist and one filtered down to nothing look identical and mean
	opposite things, so they do not share a message: the first needs telling how to
	add an item, the second needs telling the items are still there.
]]
local EMPTY_TEXT = "Nothing on your wishlist yet.\n"
		.. "|cffaaaaaaShift+Right-click an item in a boss's loot to add it.|r"
local FILTERED_TEXT = "Nothing matches this filter.\n"
		.. "|cffaaaaaaYour wishlist is not empty -- try Show Obtained, or All.|r"

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
	--[[
		Clicking through leaves the journal showing a dungeon or a raid, so the lit
		tab has to agree with that rather than still claiming the wishlist, and the
		instance list behind it has to be the one Home will draw. The nav bar works
		dungeon-or-raid out from the selection itself, so this only has to match it.
	]]
	local isRaid = false
	for _, raid in ipairs(InstanceService.GetRaids() or { }) do
		if raid.name == instance.name then
			isRaid = true
			break
		end
	end
	AdventureGuideNavigationService.SetInstances(
			isRaid and InstanceService.GetRaids() or InstanceService.GetDungeons())
	components.InstanceSelect.SetTitle(isRaid and RAIDS or DUNGEONS)
	components.EncounterJournalTabs.SelectTab(isRaid and RAIDS_TAB or DUNGEONS_TAB)
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
	GameTooltip:AddLine("|cffaaaaaa(Shift+Right-click to remove it)|r")
	GameTooltip:Show()
end

local function IconOnLeave()
	GameTooltip_Hide()
end

--[[
	Shift+right-click to drop it, which is the gesture that put it here from the
	loot view, so there is one thing to remember rather than two. A plain
	right-click on an item icon usually means link or compare, and this is the one
	place where a mis-click costs a trip back to the boss to undo.
]]
local function IconOnClick(self, button)
	local item = self.item
	if not item then return end
	if button == "RightButton" and IsShiftKeyDown() then
		WishlistService.RemoveItem(item.itemID)
		print("|cffff9900[AGC]|r Removed from Wishlist:", item.link or item.name)
		GameTooltip_Hide()
		return
	end
	GoTo(item.sourceInstance, item.sourceBoss)
end

--[[
	The overflow count. A row draws at most MAX_ICONS, so a well-worked instance
	runs out of room; rather than leave "+3" to be guessed at, it lists what is
	not being shown. They come back into the row as the ones ahead of them are
	obtained or removed, which the tooltip says so the count does not look stuck.
]]
local function MoreOnEnter(self)
	local hidden = self.hidden
	if not hidden or #hidden == 0 then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(("%d more from here"):format(#hidden))
	for _, item in ipairs(hidden) do
		local color = Colors[item.quality] or Colors[1]
		GameTooltip:AddLine(item.name or "Unknown", color.r, color.g, color.b)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cffaaaaaaShown here as the items above are obtained or removed.|r")
	GameTooltip:Show()
end

local function MoreOnLeave()
	GameTooltip_Hide()
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
		icon.tex:SetSize(ICON_INNER, ICON_INNER)
		icon.tex:SetPoint("CENTER")
		-- The border cell is larger than the button it frames, as Blizzard's is.
		icon.border = icon:CreateTexture(nil, "OVERLAY")
		icon.border:SetTexture(I.LootTabBorders)
		icon.border:SetSize(ICON_BORDER, ICON_BORDER)
		icon.border:SetPoint("CENTER")
		icon:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		icon:SetScript("OnEnter", IconOnEnter)
		icon:SetScript("OnLeave", IconOnLeave)
		icon:SetScript("OnClick", IconOnClick)
		row.icons[index] = icon
	end
	return icon
end

--[[
	How tall this row needs to be. A well-worked instance names more bosses than
	fit on one line, so the list is wrapped and the row grows to suit rather than
	the names being cut off.

	The height is measured rather than counted. Working it out from the number of
	characters would have to assume an average width per glyph, and the names it
	would be wrong about -- the long ones -- are exactly the ones that wrap.
]]
local function RowExtent(_, group)
	if not measure then return ROW_HEIGHT end
	measure:SetText(table.concat(group.bosses, ", "))
	local height = measure:GetStringHeight() or SUBLINE_HEIGHT
	if height < SUBLINE_HEIGHT then height = SUBLINE_HEIGHT end
	--[[
		Built from what the row actually holds rather than adjusted off Blizzard's
		41: the name sits NAME_Y down and is one line tall, the boss list follows
		two below it, and ROW_PADDING finishes it. For a single line that comes to
		41 anyway, so a plain row still matches theirs.
	]]
	return -NAME_Y + NAME_LINE_HEIGHT + 2 + math.ceil(height) + ROW_PADDING
end

local function RowInitializer(row, group)
	if not row.initialized then
		row:SetSize(ROW_WIDTH, ROW_HEIGHT)
		--[[
			loottab-item-background, which is the texture this row is actually drawn
			with in retail -- not something approximated off the EJ sheet. Measured:
			the dark runs solid from x=78, holds to about x=230 and is gone by 358,
			over y 14 to 79 of a 512x128 file. Stretched across the row that gives
			dark under the names, fading out before the icons start, which is the
			shape the earlier guesses were reaching for.
		]]
		--[[
			Two pieces because the texture has no left fade of its own: its dark
			begins at x=75 with alpha going 13 to 255 in a single pixel. Retail's
			row eases in from the left, so the piece that does it here is the
			texture's own right-hand fade, mirrored by swapping the two horizontal
			coordinates and laid over the first ROW_FADE_IN pixels.

			Both pieces start at x=90, where the texture reaches its flat plateau,
			and that is what makes the join invisible. Earlier tries started at 78
			and at 84, which are inside the dark border the texture carries on its
			left edge -- luminance 9 there against 29 on the plateau. Mirroring put
			that border in the middle of the row, so the darkest pixel in the bar
			was a vertical stripe at the join. Rendering the composite outside the
			game is what finally showed it; it is not visible in the source art.

			The two abut rather than overlap; overlapping would darken twice.
		]]
		row.fade = row:CreateTexture(nil, "BACKGROUND")
		row.fade:SetTexture(I.LootTabRow)
		row.fade:SetTexCoord(0.69921875, 0.17578125, 0.109375, 0.6171875)
		row.fade:SetPoint("TOPLEFT")
		row.fade:SetPoint("BOTTOMLEFT")
		row.fade:SetWidth(ROW_FADE_IN)
		row.bg = row:CreateTexture(nil, "BACKGROUND")
		row.bg:SetTexture(I.LootTabRow)
		row.bg:SetTexCoord(0.17578125, 0.69921875, 0.109375, 0.6171875)
		row.bg:SetPoint("TOPLEFT", ROW_FADE_IN, 0)
		row.bg:SetPoint("BOTTOMRIGHT")
		row.hover = row:CreateTexture(nil, "HIGHLIGHT")
		row.hover:SetPoint("TOPLEFT", 2, -2)
		row.hover:SetPoint("BOTTOMRIGHT", -2, 2)
		row.hover:SetColorTexture(1, 0.88, 0.60, 0.07)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		row.name:SetJustifyH("LEFT")
		row.name:SetWidth(NAME_WIDTH)
		row.name:SetWordWrap(false)
		row.name:SetPoint("TOPLEFT", NAME_X, NAME_Y)
		row.bosses = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		row.bosses:SetJustifyH("LEFT")
		row.bosses:SetWidth(NAME_WIDTH)
		row.bosses:SetWordWrap(true)
		row.bosses:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
		row.bosses:SetTextColor(SUBTEXT_R, SUBTEXT_G, SUBTEXT_B)
		row.more = CreateFrame("Frame", nil, row)
		row.more:SetSize(24, 24)
		-- Measured off the icons rather than the row's right edge, so the gap after
		-- the last one is the same whoever is looking at it.
		row.more:SetPoint("LEFT", ICON_START + MAX_ICONS * (ICON_SIZE + ICON_GAP) + 12, 0)
		row.more:EnableMouse(true)
		--[[
			A chevron rather than "+7". The count was a number with nowhere to go --
			it could not be clicked and did not say what it stood for -- whereas an
			arrow reads as "there is more this way" and invites the hover that
			actually answers it. The tooltip still leads with the count.

			ChatFrameExpandArrow is the chat frame's own expand chevron, so it is on
			every client and needs nothing shipped.
		]]
		--[[
			The chevron sits past the end of the bar, so it is gold on bare
			parchment and reads weakly. A second copy of it behind, tinted black
			and offset a pixel, gives it an edge to stand on -- cheaper than
			finding a bordered arrow, and it suits whatever is behind the row.
		]]
		row.more.shadow = row.more:CreateTexture(nil, "ARTWORK")
		row.more.shadow:SetTexture("Interface/ChatFrame/ChatFrameExpandArrow")
		row.more.shadow:SetSize(18, 18)
		row.more.shadow:SetPoint("CENTER", 1, -1)
		row.more.shadow:SetVertexColor(0, 0, 0, 0.75)
		row.more.arrow = row.more:CreateTexture(nil, "OVERLAY")
		row.more.arrow:SetTexture("Interface/ChatFrame/ChatFrameExpandArrow")
		row.more.arrow:SetSize(16, 16)
		row.more.arrow:SetPoint("CENTER")
		row.more:SetScript("OnEnter", MoreOnEnter)
		row.more:SetScript("OnLeave", MoreOnLeave)
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

	local overflow = { }
	for index = shown + 1, #group.items do
		table.insert(overflow, ItemDisplay(group.items[index]))
	end
	row.more.hidden = overflow
	row.more:SetShown(#overflow > 0)
end

local function BuildFilters(parent)
	parent.filterDropdown = CreateFrame("Frame", parent:GetName() .. "FilterDropdown",
			parent, "UIDropDownMenuTemplate")
	-- On the dark band beside the title, where "Current Season" sits.
	parent.filterDropdown:SetPoint("TOPRIGHT", -8, -9)
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
	-- On the parchment rather than the band, which is where "Havoc" sits.
	parent.obtainedButton:SetPoint("TOPRIGHT", -26, -(HEADER_HEIGHT + 12))
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
	--[[
		The whole sheet, bottom edge included. Cutting the shadow off the bottom also
		cut off the page edge, which is the border the panel looked to be missing:
		Blizzard's page ends in that shadow rather than at a hard line, which is what
		makes it read as a sheet of parchment lying in the frame.

		No overscan either. At 788x426 against a roughly 760x430 inset the sheet is
		within a few percent of its own proportions, so stretching it to the frame
		costs nothing and its edges land where the frame's edges are.
	]]
	--[[
		The structure, not just the art. Blizzard's own markup anchors this page at
		`TOPLEFT $parentInset x=4 y=-51`, which is the whole point: the title and the
		first filter sit on a dark band *above* the parchment, and only the second
		filter sits on the page itself. Stretching the parchment over the full inset
		and putting everything on its orange strip is what kept looking wrong, and no
		amount of adjusting tex coords was going to fix it.
	]]
	wishlist.header = wishlist:CreateTexture(nil, "BACKGROUND")
	wishlist.header:SetColorTexture(0.102, 0.094, 0.086, 1)
	wishlist.header:SetPoint("TOPLEFT", 3, -1)
	wishlist.header:SetPoint("TOPRIGHT", -2, -1)
	wishlist.header:SetHeight(HEADER_HEIGHT)

	wishlist.bg = wishlist:CreateTexture(nil, "BACKGROUND")
	wishlist.bg:SetTexture(I.LootTabBackground)
	--[[
		Measured off the sheet: the page is solid to y=382, and everything below that
		is the shadow it was drawn with. Drawn over the frame's dark backing that
		shadow reads as a black strip along the bottom, so the cut stops at the solid
		edge and the parchment runs to the frame.

		The right edge keeps its full width on purpose. The page darkens from x=756
		to x=791, and that band is where the scroll bar belongs.
	]]
	wishlist.bg:SetTexCoord(0, 0.769531, 0, 0.74609375)
	wishlist.bg:SetPoint("TOPLEFT", 3, -HEADER_HEIGHT)
	wishlist.bg:SetPoint("BOTTOMRIGHT", -2, 1)

	-- On the dark band, as "Item Sets" is, not on the parchment below it.
	wishlist.title = wishlist:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge2")
	wishlist.title:SetJustifyH("LEFT")
	wishlist.title:SetPoint("TOPLEFT", 20, -14)
	BuildFilters(wishlist)

	--[[
		Invisible, but anchored and shown, because that is what makes its height
		mean anything. A font string with no anchor has no layout to speak of, and
		a hidden one is not laid out at all, so GetStringHeight was answering for a
		single line however much text it was given -- which is why a wrapped boss
		list overflowed the row that was sized from it.

		Alpha zero rather than Hide, for the same reason.
	]]
	measure = wishlist:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	measure:SetPoint("TOPLEFT", wishlist, "TOPLEFT", 0, 0)
	measure:SetWidth(NAME_WIDTH)
	measure:SetWordWrap(true)
	measure:SetAlpha(0)

	wishlist.empty = wishlist:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	wishlist.empty:SetPoint("CENTER", 0, 20)
	wishlist.empty:SetSize(460, 40)
	wishlist.empty:Hide()

	scrollbox = CreateFrame("Frame", nil, wishlist, "WowScrollBoxList")
	--[[
		Both are anchored to the frame's own edges rather than given a width. The
		inset is wider than the numbers here used to assume, which is what left the
		scroll bar stranded on parchment instead of sitting in the page's dark edge.
	]]
	scrollbox:SetPoint("BOTTOMLEFT", 28, 12)
	scrollbox:SetPoint("TOPRIGHT", wishlist, "TOPRIGHT", -40, -(HEADER_HEIGHT + 64))
	local scrollbar = CreateFrame("EventFrame", nil, wishlist, "MinimalScrollBar")
	scrollbar:SetPoint("TOPRIGHT", wishlist, "TOPRIGHT", -14, -(HEADER_HEIGHT + 70))
	scrollbar:SetPoint("BOTTOMRIGHT", wishlist, "BOTTOMRIGHT", -14, 18)

	local view = CreateScrollBoxListLinearView()
	view:SetElementExtentCalculator(RowExtent)
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
	local total = WishlistService.GetCount()
	if #groups == 0 then
		wishlist.empty:SetText(total == 0 and EMPTY_TEXT or FILTERED_TEXT)
		wishlist.empty:Show()
	else
		wishlist.empty:Hide()
	end
	wishlist.title:SetText(("Wishlist (%d)"):format(total))
end

function component.Show()
	component.Refresh()
	components.EncounterJournal.SetCurrentView(wishlist)
	components.NavBar.Reset()
end

UI.Add(component)
