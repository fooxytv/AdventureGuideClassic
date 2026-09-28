--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("QuestList")
local components
local scrollbox
local currentInstance

local GetItemInfoCompat = C_Item and C_Item.GetItemInfo or GetItemInfo

local function RequestLoadItemDataCompat(itemId)
	if C_Item and C_Item.RequestLoadItemDataByID then
		C_Item.RequestLoadItemDataByID(itemId)
	elseif GetItemInfo then
		GetItemInfo(itemId)
	end
end

-- A flat near-black, biased warm. The journal parchment shows through anything
-- translucent at a mid-brown that gold and white text cannot sit on.
local GROUND = { 0.09, 0.075, 0.06 }

-- Lower and the warm parchment bleeds through enough to kill text contrast.
local GROUND_ALPHA = 0.9

-- Steps in the soft edge, each a one-pixel line fading outwards.
local FEATHER = 10

-- Detail fades for a quest in hand or done; the icon stays at full strength.
local DIMMED_ALPHA = 0.45

local GOLD = { 1, 0.82, 0 }
local SUBTLE = { 0.62, 0.57, 0.5 }
local WHITE = { 1, 1, 1 }
-- Faint enough to read as the row lifting rather than as a selection.
local HIGHLIGHT = { 1, 0.82, 0, 0.07 }

local PAD_X = 10
local PAD_Y = 8
local ICON = 16
local TITLE_H = 16
local SOURCE_H = 15
local REWARD_H = 17

-- Preferred minimum widths for the giver and zone names. Preferences, not guarantees:
-- staying inside the row outranks both floors. See FitSourceLine.
local GIVER_MIN = 60
local ZONE_MIN = 70

-- Measure at this width first. Rows are recycled, and a string still narrowed by the
-- previous quest would ratchet smaller on every reuse.
local MEASURE_W = 600

--[[
	A start zone inside a dungeon carries the instance's modern uiMapID -- Blackrock
	Depths is 243 -- and not every client has those. Forever does not, and SetMapID does
	not validate: it takes the id, then Blizzard's world quest data provider indexes
	GetMapInfo(243) on every refresh and errors, from inside Blizzard's own files and long
	after our pcall around SetMapID has returned. So the id is rejected before it is
	offered, not caught afterwards.

	Asked fresh rather than cached. Forever is a beta with incomplete map data, so nil
	means "not on this client yet" and the link starts working on its own once the data
	lands. GetMapInfo goes through pcall because API on these clients has raised where it
	was expected to return nil.
]]
local function IsMapIDUsable(mapID)
	if not mapID then return false end
	if not (C_Map and C_Map.GetMapInfo) then return false end
	local ok, info = pcall(C_Map.GetMapInfo, mapID)
	return (ok and info ~= nil) and true or false
end

local function RowHeight(quest)
	local rewards = quest.rewards and #quest.rewards or 0
	return PAD_Y + TITLE_H
		+ (quest.startedBy and SOURCE_H or 0)
		+ rewards * REWARD_H
		+ PAD_Y
end

--[[
	Hovering lifts the whole row. The giver, the zone and each reward are their own
	buttons inside it, so moving onto one fires the row's OnLeave -- IsMouseOver tests the
	row's own rectangle and stays true over a child, so every leave asks it.
]]
local function HighlightRow(frame)
	local row = frame.highlight and frame or frame:GetParent()
	if row and row.highlight then row.highlight:Show() end
end

local function UnhighlightRow(frame)
	local row = frame.highlight and frame or frame:GetParent()
	if row and row.highlight then row.highlight:SetShown(row:IsMouseOver()) end
end

local function BuildRow(row)
	row.highlight = row:CreateTexture(nil, "BACKGROUND")
	row.highlight:SetPoint("TOPLEFT", 2, -1)
	row.highlight:SetPoint("BOTTOMRIGHT", -2, 1)
	row.highlight:SetColorTexture(unpack(HIGHLIGHT))
	row.highlight:Hide()
	row:EnableMouse(true)
	row:SetScript("OnEnter", HighlightRow)
	row:SetScript("OnLeave", UnhighlightRow)

	row.rule = row:CreateTexture(nil, "ARTWORK")
	row.rule:SetHeight(1)
	row.rule:SetPoint("BOTTOMLEFT", PAD_X, 0)
	row.rule:SetPoint("BOTTOMRIGHT", -PAD_X, 0)
	row.rule:SetColorTexture(1, 0.92, 0.75, 0.16)

	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(ICON, ICON)
	row.icon:SetPoint("TOPLEFT", PAD_X, -PAD_Y)

	row.level = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.level:SetJustifyH("RIGHT")
	row.level:SetPoint("TOPRIGHT", -PAD_X, -PAD_Y)

	row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.title:SetJustifyH("LEFT")
	row.title:SetWordWrap(false)
	row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, 1)
	row.title:SetPoint("RIGHT", row.level, "LEFT", -6, 0)
	row.title:SetTextColor(unpack(GOLD))

	row.giver = CreateFrame("Button", nil, row)
	row.giver:SetHeight(SOURCE_H)
	row.giver:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -2)

	row.giverText = row.giver:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.giverText:SetJustifyH("LEFT")
	-- Anchored to both sides so the string is as wide as the button, which is what makes
	-- a non-wrapping string truncate with an ellipsis rather than overrun.
	row.giverText:SetPoint("LEFT")
	row.giverText:SetPoint("RIGHT")
	row.giverText:SetWordWrap(false)
	row.giver:SetFontString(row.giverText)

	row.zone = CreateFrame("Button", nil, row)
	row.zone:SetHeight(SOURCE_H)
	row.zone:SetPoint("LEFT", row.giver, "RIGHT", 0, 0)
	row.zoneText = row.zone:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.zoneText:SetJustifyH("LEFT")
	row.zoneText:SetPoint("LEFT")
	row.zoneText:SetPoint("RIGHT")
	row.zoneText:SetWordWrap(false)
	row.zone:SetFontString(row.zoneText)

	--[[
		Not through OpenWorldMap, even though it exists everywhere: it wraps
		WorldMapFrame:HandleUserActionOpenSelf, which Era's world map does not have, so on
		Era the call got past the guard and raised inside Blizzard's own file. SetMapID comes
		from MapCanvasMixin and is on every client this addon supports, so it is asked first
		with OpenWorldMap kept only as a fallback.
	]]
	row.zone:SetScript("OnClick", function(self)
		if not self.mapID then return end
		local frame = WorldMapFrame
		if frame and type(frame.SetMapID) == "function" then
			if not frame:IsShown() then
				if type(ShowUIPanel) == "function" then
					ShowUIPanel(frame)
				else
					frame:Show()
				end
			end
			if pcall(frame.SetMapID, frame, self.mapID) then return end
		end
		if type(OpenWorldMap) == "function" then
			pcall(OpenWorldMap, self.mapID)
		end
	end)
	row.zone:SetScript("OnEnter", function(self)
		HighlightRow(self)
		if not self.mapID then return end
		row.zoneText:SetTextColor(unpack(GOLD))
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Open the map at " .. (self.zoneName or ""), 1, 1, 1)
		GameTooltip:Show()
	end)
	row.zone:SetScript("OnLeave", function(self)
		row.zoneText:SetTextColor(unpack(SUBTLE))
		GameTooltip_Hide()
		UnhighlightRow(self)
	end)

	row.giver:SetScript("OnEnter", function(self)
		HighlightRow(self)
		row.giverText:SetTextColor(unpack(GOLD))
		if not self.npc then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.npc.name, 1, 0.82, 0)
		if self.npc.zone then
			GameTooltip:AddLine(self.npc.zone, 0.62, 0.57, 0.5)
		end
		GameTooltip:Show()
		if components and components.NpcPreview then
			components.NpcPreview.Show(self.npc)
		end
	end)
	row.giver:SetScript("OnLeave", function(self)
		if components and components.NpcPreview then
			components.NpcPreview.Hide()
		end
		GameTooltip_Hide()
		row.giverText:SetTextColor(unpack(row.giverIsPreviewable and WHITE or SUBTLE))
		UnhighlightRow(self)
	end)

	row.rewards = { }
	row.initialized = true
end

-- A reward behaves like a loot row: tooltip on hover, Ctrl dresses the preview model.
-- The preview frame belongs to the Loot component, so there is one model and one place
-- that knows how to undress it first.
local function RewardOnEnter(self)
	HighlightRow(self)
	if not self.link then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink(self.link)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cffaaaaaa(Hold Ctrl to preview)|r")
	GameTooltip:Show()
	self.checkCtrl = true
end

local function RewardOnLeave(self)
	UnhighlightRow(self)
	self.checkCtrl = false
	self.wasCtrlDown = false
	if components and components.Loot then components.Loot.HidePreview() end
	GameTooltip_Hide()
end

local function RewardOnUpdate(self)
	if not self.checkCtrl then return end
	local down = IsControlKeyDown()
	if down and not self.wasCtrlDown then
		if components and components.Loot then components.Loot.PreviewItem(self.link) end
		self.wasCtrlDown = true
	elseif not down and self.wasCtrlDown then
		if components and components.Loot then components.Loot.HidePreview() end
		self.wasCtrlDown = false
	end
end

local function RewardOnClick(self)
	if self.link and IsControlKeyDown() and DressUpItemLink then
		DressUpItemLink(self.link)
	end
end

--[[
	Only the surplus buttons are hidden. Hiding a frame under the cursor fires its
	OnLeave and showing it back fires its OnEnter, so a refresh under the pointer put the
	hovered reward through leave-and-enter, clearing the Ctrl-held flag and setting it
	again, and the preview started over. Refreshes come from GET_ITEM_INFO_RECEIVED,
	which hovering a reward causes, so previewing on a cold cache restarted itself once
	per item that arrived. Showing an already-shown frame does nothing, so the ones that
	stay are left alone and only their contents are rewritten.
]]
--[[
	Budgets the giver and the zone against the row width; each was sized to its own text,
	so a long pair ran past the panel edge. The zone gives up space first, and the floors
	are preferences the budget outranks -- the last two lines hold the total to the budget
	whatever the floors asked for. Only ever shrinks: a button wider than its text would
	push the zone rightwards and overflow again.
]]
local function FitSourceLine(row)
	local available = row:GetWidth()
	if not available or available <= 0 then
		available = scrollbox and scrollbox:GetWidth() or 0
	end
	local budget = available - (PAD_X + ICON + 6) - PAD_X
	local giverW = row.giverText:GetStringWidth() + 2
	local zoneW = row.zoneText:GetStringWidth() + 2
	if budget > 0 and giverW + zoneW > budget then
		zoneW = math.min(zoneW, math.max(budget - giverW, math.min(zoneW, ZONE_MIN)))
		giverW = math.min(giverW, math.max(budget - zoneW, math.min(giverW, GIVER_MIN)))
		giverW = math.min(giverW, budget)
		zoneW = math.min(zoneW, math.max(budget - giverW, 0))
	end
	row.giver:SetWidth(giverW)
	row.zone:SetWidth(zoneW)
end

local function SetRewards(row, rewards, anchor)
	local wanted = rewards and #rewards or 0
	for index = wanted + 1, #row.rewards do
		row.rewards[index]:Hide()
	end
	if wanted == 0 then return end

	for index, itemId in ipairs(rewards) do
		local reward = row.rewards[index]
		if not reward then
			reward = CreateFrame("Button", nil, row)
			reward:SetHeight(REWARD_H)
			reward:RegisterForClicks("LeftButtonUp")
			reward:SetScript("OnEnter", RewardOnEnter)
			reward:SetScript("OnLeave", RewardOnLeave)
			reward:SetScript("OnUpdate", RewardOnUpdate)
			reward:SetScript("OnClick", RewardOnClick)
			reward.icon = reward:CreateTexture(nil, "ARTWORK")
			reward.icon:SetSize(13, 13)
			reward.icon:SetPoint("LEFT")
			reward.label = reward:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			reward.label:SetJustifyH("LEFT")
			reward.label:SetPoint("LEFT", reward.icon, "RIGHT", 5, 0)
			row.rewards[index] = reward
		end

		-- The item cache is cold the first time an instance is opened, so a row shows its icon
		-- alone until GET_ITEM_INFO_RECEIVED answers.
		local name, link, quality, _, _, _, _, _, _, icon = GetItemInfoCompat(itemId)
		if not name then
			RequestLoadItemDataCompat(itemId)
		end
		reward.itemId = itemId
		reward.link = link
		reward.icon:SetTexture(icon or "Interface/Icons/INV_Misc_QuestionMark")
		reward.label:SetText(name or "")
		local color = quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
		if color then
			reward.label:SetTextColor(color.r, color.g, color.b)
		else
			reward.label:SetTextColor(unpack(SUBTLE))
		end

		reward:ClearAllPoints()
		reward:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", index == 1 and 2 or 0, index == 1 and -3 or 0)
		reward:SetPoint("RIGHT", row, "RIGHT", -PAD_X, 0)
		reward:Show()
		anchor = reward
	end
end

local function Initializer(row, quest)
	if not row.initialized then
		BuildRow(row)
	end

	local state = QuestService.GetState(quest.id)
	-- The title keeps its gold; only the detail under it dims, as the tracker does.
	local dim = (state == "active" or state == "completed") and DIMMED_ALPHA or 1

	row.icon:SetTexture(QuestService.GetStateIcon(quest.id))
	row.title:SetText(quest.name or "")
	row.title:SetAlpha(1)
	row.level:SetText(quest.level and tostring(quest.level) or "")
	row.level:SetAlpha(1)

	local hasGiver = quest.startedBy ~= nil
	row.giver:SetShown(hasGiver)
	row.zone:SetShown(hasGiver and quest.startZone ~= nil)
	if hasGiver then
		row.giver:SetWidth(MEASURE_W)
		row.zone:SetWidth(MEASURE_W)
		row.giverText:SetText(quest.startedBy)
		row.giverIsPreviewable = quest.startedByDisplay and true or false
		row.giverText:SetTextColor(unpack(quest.startedByDisplay and WHITE or SUBTLE))
		row.giver:SetAlpha(dim)
		row.zoneText:SetText(quest.startZone and (" \226\128\162 " .. quest.startZone) or "")
		row.zoneText:SetTextColor(unpack(SUBTLE))
		row.zone:SetAlpha(dim)
		FitSourceLine(row)
		-- Not every start zone resolves on every client; see IsMapIDUsable.
		row.zone.mapID = IsMapIDUsable(quest.startZoneMap) and quest.startZoneMap or nil
		row.zone.zoneName = quest.startZone
		row.zone:EnableMouse(row.zone.mapID ~= nil)
		row.giver.npc = quest.startedByDisplay
			and { name = quest.startedBy, display = quest.startedByDisplay,
				zone = quest.startZone }
			or nil
		row.giver:EnableMouse(row.giver.npc ~= nil)
	end

	local anchor = hasGiver and row.giver or row.title
	SetRewards(row, quest.rewards, anchor)
	for _, reward in ipairs(row.rewards) do
		reward:SetAlpha(dim)
	end

end

function component.Init(components_)
	components = components_

	local quests = CreateFrame("Frame", nil, EncounterJournal.encounter)
	component.frame = quests
	EncounterJournal.encounter.quests = quests
	-- Held off the journal's own border at the bottom and the right, where the panel used
	-- to run over it -- five pixels in, matching the Loot container in the same parent. The
	-- size shrinks by as much as the anchor moves, so the top and left edges do not move.
	quests:SetSize(386, 421)
	quests:SetPoint("BOTTOMRIGHT", -5, 6)

	-- Sit above the journal's own furniture. Every view here is a sibling under
	-- EncounterJournal.encounter, and a frame's textures draw over a sibling's only if its
	-- level is higher; the default left that to creation order.
	local parentLevel = EncounterJournal.encounter:GetFrameLevel() or 0
	quests:SetFrameLevel(parentLevel + 10)

	-- Fills its side of the journal below the header, and must stop short at the top: the
	-- journal draws the instance name in that strip, and running the ground the full height
	-- of the column covered it.
	local HEADER = 34
	local ground = quests:CreateTexture(nil, "BACKGROUND", nil, 1)
	ground:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], GROUND_ALPHA)
	ground:SetPoint("TOPLEFT", 2, -HEADER)
	ground:SetPoint("BOTTOMRIGHT", -2, 2)

	for step = 1, FEATHER do
		local alpha = GROUND_ALPHA * (1 - step / (FEATHER + 1))
		local offset = step - 1

		local top = quests:CreateTexture(nil, "BACKGROUND", nil, 1)
		top:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], alpha)
		top:SetHeight(1)
		top:SetPoint("BOTTOMLEFT", ground, "TOPLEFT", 0, offset)
		top:SetPoint("BOTTOMRIGHT", ground, "TOPRIGHT", 0, offset)

		local bottom = quests:CreateTexture(nil, "BACKGROUND", nil, 1)
		bottom:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], alpha)
		bottom:SetHeight(1)
		bottom:SetPoint("TOPLEFT", ground, "BOTTOMLEFT", 0, -offset)
		bottom:SetPoint("TOPRIGHT", ground, "BOTTOMRIGHT", 0, -offset)

		local left = quests:CreateTexture(nil, "BACKGROUND", nil, 1)
		left:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], alpha)
		left:SetWidth(1)
		left:SetPoint("TOPRIGHT", ground, "TOPLEFT", -offset, 0)
		left:SetPoint("BOTTOMRIGHT", ground, "BOTTOMLEFT", -offset, 0)

		local right = quests:CreateTexture(nil, "BACKGROUND", nil, 1)
		right:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], alpha)
		right:SetWidth(1)
		right:SetPoint("TOPLEFT", ground, "TOPRIGHT", offset, 0)
		right:SetPoint("BOTTOMLEFT", ground, "BOTTOMRIGHT", offset, 0)
	end

	quests.empty = quests:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	quests.empty:SetPoint("TOPLEFT", 16, -(HEADER + 14))
	quests.empty:SetPoint("TOPRIGHT", -16, -(HEADER + 14))
	quests.empty:SetJustifyH("LEFT")
	quests.empty:SetText("No dungeon quests are known for this instance.")
	quests.empty:SetTextColor(unpack(SUBTLE))
	quests.empty:Hide()

	scrollbox = CreateFrame("Frame", nil, quests, "WowScrollBoxList")
	scrollbox:SetPoint("TOPLEFT", 6, -(HEADER + 6))
	scrollbox:SetPoint("BOTTOMRIGHT", -20, 8)
	-- Clip to the box, or a row scrolled half out keeps drawing onto the parchment above.
	if type(scrollbox.SetClipsChildren) == "function" then
		scrollbox:SetClipsChildren(true)
	end

	local scrollbar = CreateFrame("EventFrame", nil, quests, "MinimalScrollBar")
	scrollbar:SetPoint("TOPLEFT", scrollbox, "TOPRIGHT", 6, 0)
	scrollbar:SetPoint("BOTTOMLEFT", scrollbox, "BOTTOMRIGHT", 6, 0)

	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("Frame", Initializer)
	view:SetElementExtentCalculator(function(_, quest) return RowHeight(quest) end)
	view:SetPadding(2, 2, 0, 0, 4)
	ScrollUtil.InitScrollBoxWithScrollBar(scrollbox, scrollbar, view)

	-- Fades the list out at the top and bottom. Must be its own frame anchored to the
	-- scroll box exactly: a texture on the panel draws underneath the box's rows however
	-- high its layer, because a child frame draws over its parent's regions regardless.
	-- Anchored to the panel instead, the fades missed the rows. Takes no mouse input.
	local FADE = 16
	local fade = CreateFrame("Frame", nil, quests)
	fade:SetPoint("TOPLEFT", scrollbox, "TOPLEFT", 0, 0)
	fade:SetPoint("BOTTOMRIGHT", scrollbox, "BOTTOMRIGHT", 0, 0)
	fade:SetFrameLevel(scrollbox:GetFrameLevel() + 5)
	for step = 1, FADE do
		local alpha = GROUND_ALPHA * (1 - (step - 1) / FADE)
		local offset = step - 1

		local top = fade:CreateTexture(nil, "OVERLAY")
		top:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], alpha)
		top:SetHeight(1)
		top:SetPoint("TOPLEFT", fade, "TOPLEFT", 0, -offset)
		top:SetPoint("TOPRIGHT", fade, "TOPRIGHT", 0, -offset)

		local bottom = fade:CreateTexture(nil, "OVERLAY")
		bottom:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], alpha)
		bottom:SetHeight(1)
		bottom:SetPoint("BOTTOMLEFT", fade, "BOTTOMLEFT", 0, offset)
		bottom:SetPoint("BOTTOMRIGHT", fade, "BOTTOMRIGHT", 0, offset)
	end

	quests:Hide()
end

function component.Show(instance)
	currentInstance = instance
	EncounterJournal.encounter.info.encounterTitle:SetText("")

	local quests = QuestService.GetQuests(instance and instance.name)
	local dataProvider = CreateDataProvider()
	for _, quest in ipairs(quests) do
		dataProvider:Insert(quest)
	end
	scrollbox:SetDataProvider(dataProvider)

	component.frame.empty:SetShown(#quests == 0)
	components.EncounterFrame.SetCurrentView(component.frame)
end

-- Coalesced. QUEST_LOG_UPDATE fires many times a second and GET_ITEM_INFO_RECEIVED
-- once per item as a cold cache fills; rebuilding on each tore the data provider down
-- under the cursor and restarted the hovered giver's model preview every time.
local REFRESH_DELAY = 0.1
local refreshPending = false

-- Re-draws the rows on screen without replacing the data provider, which would rebuild
-- the list from the top while the player is reading it. Nothing here changes which
-- quests are listed, only how they are drawn.
local function RefreshVisibleRows()
	if not scrollbox or type(scrollbox.ForEachFrame) ~= "function" then
		return false
	end
	scrollbox:ForEachFrame(Initializer)
	return true
end

local function RequestRefresh()
	if refreshPending then return end
	if not (component.frame and component.frame:IsShown() and currentInstance) then return end

	refreshPending = true
	C_Timer.After(REFRESH_DELAY, function()
		refreshPending = false
		if not (component.frame and component.frame:IsShown() and currentInstance) then return end
		if not RefreshVisibleRows() then
			component.Show(currentInstance)
		end
	end)
end

local eventFrame = CreateFrame("Frame")
Compat.RegisterEvents(eventFrame,
	"QUEST_LOG_UPDATE",
	"QUEST_TURNED_IN",
	"GET_ITEM_INFO_RECEIVED")
eventFrame:SetScript("OnEvent", RequestRefresh)

UI.Add(component)

-- Draws every row as though the quest were in that state: "available", "active",
-- "completed", or no argument to clear. Goes through QuestService so the state icons in
-- the search results agree with the list.
_G.AGC_PreviewQuests = function(state)
	if not QuestService.SetPreviewState(state) then
		print("|cffff9900[AGC]|r AGC_PreviewQuests(\"available\"|\"active\"|\"completed\") or no argument to clear")
		return
	end
	if state then
		print("|cff00ff00[AGC]|r Quest rows drawn as: " .. state)
	else
		print("|cff00ff00[AGC]|r Quest rows back to their real state")
	end
	if component.frame and component.frame:IsShown() and currentInstance then
		component.Show(currentInstance)
	end
end
