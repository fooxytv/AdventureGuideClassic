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

InsetFrameTemplate brings a translucent background of its own, and over the journal
parchment that lands at a warm mid-brown, which is what made this page hard to read
however the type was set. So hide the template's background and paint a solid colour
inside the border instead: near-black, biased warm so it belongs to the journal rather
than reading as a grey box dropped onto it.

The fill sits high within BACKGROUND, above the template's own background at sublevel 0.
Below it and the translucent texture simply draws over the top. It need not be below the
content: the rows are child frames, and a child frame always draws above its parent's
textures.
]]
local GROUND = { 0.09, 0.075, 0.06 }

local function AddDarkGround(inset)
	for _, key in ipairs({ "Bg", "bg", "InsetBg" }) do
		local texture = rawget(inset, key)
		if type(texture) == "table" and type(texture.Hide) == "function" then
			texture:Hide()
		end
	end
	local fill = inset:CreateTexture(nil, "BACKGROUND", nil, 7)
	fill:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], 1)
	fill:SetPoint("TOPLEFT", 3, -3)
	fill:SetPoint("BOTTOMRIGHT", -3, 3)
	return fill
end

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
	row.rule:SetColorTexture(1, 1, 1, 0.055)

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

	row.zone = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.zone:SetJustifyH("LEFT")
	row.zone:SetPoint("LEFT", row.giver, "RIGHT", 0, 0)
	row.zone:SetTextColor(unpack(SUBTLE))

	row.giver:SetScript("OnEnter", function(self)
		if self.npc and components and components.NpcPreview then
			components.NpcPreview.Show(self.npc)
		end
	end)
	row.giver:SetScript("OnLeave", function()
		if components and components.NpcPreview then
			components.NpcPreview.Hide()
		end
	end)

	row.rewards = { }
	row.initialized = true
end

local function SetRewards(row, rewards, anchor)
	for _, reward in ipairs(row.rewards) do
		reward:Hide()
	end
	if not rewards then return end

	for index, itemId in ipairs(rewards) do
		local reward = row.rewards[index]
		if not reward then
			reward = CreateFrame("Frame", nil, row)
			reward:SetHeight(REWARD_H)
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
		local name, _, quality, _, _, _, _, _, _, icon = GetItemInfoCompat(itemId)
		if not name then
			RequestLoadItemDataCompat(itemId)
		end
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
		row.zone:SetText(quest.startZone and (" \226\128\162 " .. quest.startZone) or "")
		row.zone:SetAlpha(dim)
		--[[
		Only a giver we have a model for is worth hovering. Without one the name still
		shows, in the plain colour, so the row never offers a link that does nothing.
		]]
		row.giver.npc = quest.startedByDisplay
			and { name = quest.startedBy, display = quest.startedByDisplay }
			or nil
		row.giver:EnableMouse(row.giver.npc ~= nil)
	end

	local anchor = hasGiver and row.giver or row.title
	SetRewards(row, quest.rewards, anchor)
	for _, reward in ipairs(row.rewards) do
		reward:SetAlpha(dim)
	end

	row:SetHeight(RowHeight(quest))
end

function component.Init(components_)
	components = components_

	local quests = CreateFrame("Frame", nil, EncounterJournal.encounter)
	component.frame = quests
	EncounterJournal.encounter.quests = quests
	quests:SetSize(390, 425)
	quests:SetPoint("BOTTOMRIGHT", -1, 2)

	quests.title = quests:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	quests.title:SetPoint("TOPLEFT", 16, -12)
	quests.title:SetTextColor(unpack(GOLD))

	local inset = CreateFrame("Frame", nil, quests, "InsetFrameTemplate")
	inset:SetPoint("TOPLEFT", 8, -36)
	inset:SetPoint("BOTTOMRIGHT", -8, 8)
	AddDarkGround(inset)
	quests.inset = inset

	quests.empty = inset:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	quests.empty:SetPoint("TOPLEFT", 14, -14)
	quests.empty:SetPoint("TOPRIGHT", -14, -14)
	quests.empty:SetJustifyH("LEFT")
	quests.empty:SetText("No dungeon quests are known for this instance.")
	quests.empty:SetTextColor(unpack(SUBTLE))
	quests.empty:Hide()

	scrollbox = CreateFrame("Frame", nil, inset, "WowScrollBoxList")
	scrollbox:SetPoint("TOPLEFT", 8, -8)
	scrollbox:SetPoint("BOTTOMRIGHT", -20, 8)

	local scrollbar = CreateFrame("EventFrame", nil, inset, "MinimalScrollBar")
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
	component.frame.title:SetText(instance and instance.name or "Quests")
	components.EncounterFrame.SetCurrentView(component.frame)
end

--[[
Quest state changes while the guide is open -- picking one up, handing it in -- and item
names arrive late, so the list is rebuilt on both rather than only on show.
]]
local eventFrame = CreateFrame("Frame")
Compat.RegisterEvents(eventFrame,
	"QUEST_LOG_UPDATE",
	"QUEST_TURNED_IN",
	"GET_ITEM_INFO_RECEIVED")
eventFrame:SetScript("OnEvent", function()
	if component.frame and component.frame:IsShown() and currentInstance then
		component.Show(currentInstance)
	end
end)

UI.Add(component)
