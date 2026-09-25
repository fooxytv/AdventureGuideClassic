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

--[[
A flat colour behind the panel rather than a texture.

The journal parchment shows through anything translucent laid over it, landing at a
warm mid-brown that gold and white text cannot sit on however the type is set. So the
panel paints a solid colour instead: near-black, biased warm so it belongs to the
journal rather than reading as a grey box dropped onto it.
]]
local GROUND = { 0.09, 0.075, 0.06 }

local STATE_ICON = {
	available = "Interface/GossipFrame/AvailableQuestIcon",
	active    = "Interface/GossipFrame/ActiveQuestIcon",
	completed = "Interface/RaidFrame/ReadyCheck-Ready",
}

-- A quest already in hand or already done is not something to go and pick up, so both
-- fade. The icon is what separates them, and it stays at full strength so it still
-- reads against a faded row.
local DIMMED_ALPHA = 0.45

local GOLD = { 1, 0.82, 0 }
local SUBTLE = { 0.62, 0.57, 0.5 }

-- Without a border the rule is the only separator, so the vertical gap is what keeps
-- one quest from reading as part of the next.
local PAD_X = 10
local PAD_Y = 8
local ICON = 16
local TITLE_H = 16
local SOURCE_H = 15
local REWARD_H = 17

local function RowHeight(quest)
	local rewards = quest.rewards and #quest.rewards or 0
	return PAD_Y + TITLE_H
		+ (quest.startedBy and SOURCE_H or 0)
		+ rewards * REWARD_H
		+ PAD_Y
end

--[[
Quests are separated by a hairline rather than boxed.

A bordered panel per quest is what the quest-chain browser on feature/suggested-content
uses, but that is a full page with a 232px rail and rows that carry hover and selection
states. This is a 390px tab with no row interaction and as many as 41 quests in
Blackrock Depths: forty-one nested borders inside an already bordered inset reads as
noise, and the edge art costs width the reward names need.
]]
local function BuildRow(row)
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

	--[[
	The quest giver is its own small button rather than a hyperlink inside a sentence.
	There is exactly one per quest, so hovering it needs no text parsing, and a button
	gives the model preview a real frame to anchor its enter and leave to.
	]]
	row.giver = CreateFrame("Button", nil, row)
	row.giver:SetHeight(SOURCE_H)
	row.giver:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -2)

	row.giverText = row.giver:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.giverText:SetJustifyH("LEFT")
	row.giverText:SetPoint("LEFT")
	row.giver:SetFontString(row.giverText)

	row.zone = CreateFrame("Button", nil, row)
	row.zone:SetHeight(SOURCE_H)
	row.zone:SetPoint("LEFT", row.giver, "RIGHT", 0, 0)
	row.zoneText = row.zone:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.zoneText:SetJustifyH("LEFT")
	row.zoneText:SetPoint("LEFT")
	row.zone:SetFontString(row.zoneText)

	--[[
	Clicking the zone opens the world map there, which is the question the line exists
	to answer: where do I go to pick this up. Only where the zone resolved to a map id,
	so the name never looks clickable when nothing would happen.
	]]
	row.zone:SetScript("OnClick", function(self)
		if self.mapID and OpenWorldMap then OpenWorldMap(self.mapID) end
	end)
	row.zone:SetScript("OnEnter", function(self)
		if not self.mapID then return end
		row.zoneText:SetTextColor(unpack(GOLD))
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Open the map at " .. (self.zoneName or ""), 1, 1, 1)
		GameTooltip:Show()
	end)
	row.zone:SetScript("OnLeave", function()
		row.zoneText:SetTextColor(unpack(SUBTLE))
		GameTooltip_Hide()
	end)

	--[[
	A tooltip first, then the model beneath it. The reward rows already work this way,
	the loot tab before them, and hanging both previews off the tooltip puts them in the
	same place on screen instead of one by the cursor and one by the row.
	]]
	row.giver:SetScript("OnEnter", function(self)
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
	row.giver:SetScript("OnLeave", function()
		if components and components.NpcPreview then
			components.NpcPreview.Hide()
		end
		GameTooltip_Hide()
	end)

	row.rewards = { }
	row.initialized = true
end

--[[
A reward behaves like a loot row: its tooltip on hover, and holding Ctrl dresses the
preview model in it. The preview frame belongs to the Loot component rather than being
stood up again here, so there is one model and one place that knows how to undress it
first.
]]
local function RewardOnEnter(self)
	if not self.link then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink(self.link)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cffaaaaaa(Hold Ctrl to preview)|r")
	GameTooltip:Show()
	self.checkCtrl = true
end

local function RewardOnLeave(self)
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

local function SetRewards(row, rewards, anchor)
	for _, reward in ipairs(row.rewards) do
		reward:Hide()
	end
	if not rewards then return end

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

		--[[
		Reward names come from the item cache, which is cold the first time an instance
		is opened. A missing one is requested and the row shows its icon alone until the
		cache answers; the component refreshes on GET_ITEM_INFO_RECEIVED.
		]]
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
	local dim = (state == "active" or state == "completed") and DIMMED_ALPHA or 1

	row.icon:SetTexture(STATE_ICON[state] or STATE_ICON.available)
	row.title:SetText(quest.name or "")
	row.title:SetAlpha(dim)
	row.level:SetText(quest.level and tostring(quest.level) or "")
	row.level:SetAlpha(dim)

	local hasGiver = quest.startedBy ~= nil
	row.giver:SetShown(hasGiver)
	row.zone:SetShown(hasGiver and quest.startZone ~= nil)
	if hasGiver then
		row.giverText:SetText(quest.startedBy)
		row.giverText:SetTextColor(unpack(quest.startedByDisplay and GOLD or SUBTLE))
		row.giver:SetWidth(row.giverText:GetStringWidth() + 2)
		row.giver:SetAlpha(dim)
		row.zoneText:SetText(quest.startZone and (" \226\128\162 " .. quest.startZone) or "")
		row.zoneText:SetTextColor(unpack(SUBTLE))
		row.zone:SetWidth(row.zoneText:GetStringWidth() + 2)
		row.zone:SetAlpha(dim)
		row.zone.mapID = quest.startZoneMap
		row.zone.zoneName = quest.startZone
		row.zone:EnableMouse(quest.startZoneMap ~= nil)
		--[[
		Only a giver we have a model for is worth hovering. Without one the name still
		shows, in the plain colour, so the row never offers a link that does nothing.
		]]
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
	quests:SetSize(390, 425)
	quests:SetPoint("BOTTOMRIGHT", -1, 2)

	--[[
	Sit above the journal's own furniture.

	Every view on this side of the page is a sibling under EncounterJournal.encounter,
	and a frame's textures only draw over a sibling's if its level is higher. Taking the
	default left that to creation order, so whether the dark ground was visible depended
	on which component happened to be built last -- which is why it came and went.
	]]
	local parentLevel = EncounterJournal.encounter:GetFrameLevel() or 0
	quests:SetFrameLevel(parentLevel + 10)

	--[[
	The panel fills its side of the journal below the header, rather than floating
	inside it.

	InsetFrameTemplate was drawing a second border within the journal's own inset, so
	the dark ground read as a box dropped onto the page with parchment showing round it.
	The ground now runs to the edges, seated with a one-pixel dark line rather than a
	frame of its own.

	It stops short at the top. The journal draws the instance name in that strip, and
	running the ground the full height of the column covered it.

	The strip it leaves clear carries a heading, so the column says what it is holding.
	Not the instance name, which the journal header and the nav bar both already show.
	]]
	local HEADER = 34
	local ground = quests:CreateTexture(nil, "BACKGROUND", nil, 1)
	ground:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], 1)
	ground:SetPoint("TOPLEFT", 2, -HEADER)
	ground:SetPoint("BOTTOMRIGHT", -2, 2)

	local edge = quests:CreateTexture(nil, "BACKGROUND", nil, 0)
	edge:SetColorTexture(0, 0, 0, 0.85)
	edge:SetPoint("TOPLEFT", ground, -1, 1)
	edge:SetPoint("BOTTOMRIGHT", ground, 1, -1)

	quests.title = quests:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	quests.title:SetPoint("BOTTOMLEFT", ground, "TOPLEFT", 4, 7)
	quests.title:SetText("Quests")
	quests.title:SetTextColor(unpack(GOLD))

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

	local scrollbar = CreateFrame("EventFrame", nil, quests, "MinimalScrollBar")
	scrollbar:SetPoint("TOPLEFT", scrollbox, "TOPRIGHT", 6, 0)
	scrollbar:SetPoint("BOTTOMLEFT", scrollbox, "BOTTOMRIGHT", 6, 0)

	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("Frame", Initializer)
	view:SetElementExtentCalculator(function(_, quest) return RowHeight(quest) end)
	view:SetPadding(2, 2, 0, 0, 4)
	ScrollUtil.InitScrollBoxWithScrollBar(scrollbox, scrollbar, view)

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

--[[
Quest state changes while the guide is open -- picking one up, handing it in -- and item
names arrive late, so the list is rebuilt on both rather than only on show.

Coalesced, because QUEST_LOG_UPDATE fires many times a second and
GET_ITEM_INFO_RECEIVED arrives once per item as a cold cache fills. Rebuilding on each
one tore the data provider down under the cursor: the quest giver button beneath the
pointer went away and came back, so its preview was hidden and re-shown, and the model
restarted its idle animation every time. That is the stutter.

A tenth of a second is under a frame's notice for a list that only has to keep up with
picking up a quest, and it collapses a burst of twenty events into one rebuild.
]]
local REFRESH_DELAY = 0.1
local refreshPending = false

--[[
Re-draws the rows that are on screen, without touching the data provider.

Replacing the provider rebuilds the list from the top, and these events fire while the
player is reading: QUEST_LOG_UPDATE many times a second, and GET_ITEM_INFO_RECEIVED once
per reward as a cold cache fills -- which hovering a row causes more of, because that is
what requests the item. So the list kept jumping back under the pointer, and scrolling
fought it every time the mouse moved.

Nothing here changes which quests are in the list, only how they are drawn, so the rows
already laid out are the right ones to restyle.
]]
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
