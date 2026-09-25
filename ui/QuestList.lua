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

local ROW_WIDTH = 360
local REWARD_ICON = 14
local TITLE_COLOR = { 1, 0.82, 0 }
local SUBTLE_COLOR = { 0.62, 0.57, 0.5 }

--[[
	Completed and in-progress quests both dim, which says "not something to go and pick
	up". The tick is what separates them, and it stays at full strength so it still
	reads against a faded row.
]]
local DIMMED_ALPHA = 0.45

local function ApplyState(row, state)
	row.tick:SetShown(state == "completed")
	row.content:SetAlpha((state == "completed" or state == "active") and DIMMED_ALPHA or 1)
end

local function BuildRow(row)
	row:SetSize(ROW_WIDTH, 20)

	row.content = CreateFrame("Frame", nil, row)
	row.content:SetPoint("TOPLEFT", 16, 0)
	row.content:SetPoint("BOTTOMRIGHT", 0, 0)

	row.tick = row:CreateTexture(nil, "OVERLAY")
	row.tick:SetSize(13, 13)
	row.tick:SetPoint("TOPLEFT", 0, -2)
	row.tick:SetTexture("Interface/RaidFrame/ReadyCheck-Ready")
	row.tick:Hide()

	row.title = row.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.title:SetJustifyH("LEFT")
	row.title:SetPoint("TOPLEFT")
	row.title:SetTextColor(unpack(TITLE_COLOR))

	row.level = row.content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.level:SetJustifyH("RIGHT")
	row.level:SetPoint("TOPRIGHT")

	row.title:SetPoint("TOPRIGHT", row.level, "TOPLEFT", -6, 0)

	row.source = row.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.source:SetJustifyH("LEFT")
	row.source:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -2)
	row.source:SetTextColor(unpack(SUBTLE_COLOR))

	row.rewards = { }
	row.initialized = true
end

--[[
	Reward names arrive from the item cache, which is often cold on a first look at an
	instance. A missing one is requested and the row shows the icon alone until the
	cache answers; ui/Loot.lua drives a refresh off GET_ITEM_INFO_RECEIVED for the same
	reason.
]]
local function SetRewards(row, rewards)
	for _, reward in ipairs(row.rewards) do
		reward:Hide()
	end

	if not rewards then return 0 end

	local shown = 0
	for index, itemId in ipairs(rewards) do
		local reward = row.rewards[index]
		if not reward then
			reward = CreateFrame("Frame", nil, row.content)
			reward:SetSize(ROW_WIDTH, REWARD_ICON)
			reward.icon = reward:CreateTexture(nil, "ARTWORK")
			reward.icon:SetSize(REWARD_ICON, REWARD_ICON)
			reward.icon:SetPoint("LEFT")
			reward.label = reward:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			reward.label:SetJustifyH("LEFT")
			reward.label:SetPoint("LEFT", reward.icon, "RIGHT", 5, 0)
			row.rewards[index] = reward
		end

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
			reward.label:SetTextColor(unpack(SUBTLE_COLOR))
		end

		reward:ClearAllPoints()
		local anchor = index == 1 and row.source or row.rewards[index - 1]
		reward:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
		reward:Show()
		shown = index
	end
	return shown
end

local function Initializer(row, quest)
	if not row.initialized then
		BuildRow(row)
	end

	row.title:SetText(quest.name or "")
	row.level:SetText(quest.level and tostring(quest.level) or "")

	local source = quest.startedBy
	if source and quest.startZone then
		source = source .. " \226\128\162 " .. quest.startZone
	end
	row.source:SetText(source or "")
	row.source:SetShown(source ~= nil)

	local rewardCount = SetRewards(row, quest.rewards)
	ApplyState(row, QuestService.GetState(quest.id))

	-- Title, source line, then one line per reward, plus a gap between quests.
	local height = 16 + (source and 14 or 0) + rewardCount * (REWARD_ICON + 2) + 8
	row:SetHeight(height)
end

function component.Init(components_)
	components = components_

	local quests = CreateFrame("Frame", nil, EncounterJournal.encounter)
	component.frame = quests
	EncounterJournal.encounter.quests = quests
	quests:SetSize(390, 425)
	quests:SetPoint("BOTTOMRIGHT", -1, 2)

	quests.title = quests:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	quests.title:SetPoint("TOPLEFT", 18, -14)
	quests.title:SetText("Quests")

	quests.empty = quests:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	quests.empty:SetPoint("TOPLEFT", quests.title, "BOTTOMLEFT", 0, -10)
	quests.empty:SetText("No dungeon quests are known for this instance.")
	quests.empty:SetTextColor(unpack(SUBTLE_COLOR))
	quests.empty:Hide()

	scrollbox = CreateFrame("Frame", nil, quests, "WowScrollBoxList")
	scrollbox:SetPoint("TOPLEFT", 18, -40)
	scrollbox:SetPoint("BOTTOMRIGHT", -26, 10)

	local scrollbar = CreateFrame("EventFrame", nil, quests, "MinimalScrollBar")
	scrollbar:SetPoint("TOPLEFT", scrollbox, "TOPRIGHT", 8, 0)
	scrollbar:SetPoint("BOTTOMLEFT", scrollbox, "BOTTOMRIGHT", 8, 0)

	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("Frame", Initializer)
	view:SetElementExtentCalculator(function(_, quest)
		local lines = quest.rewards and #quest.rewards or 0
		return 16 + (quest.startedBy and 14 or 0) + lines * (REWARD_ICON + 2) + 8
	end)
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
	Quest state changes while the guide is open -- picking one up, handing it in -- and
	item names arrive late, so the list is rebuilt on both rather than only on show.
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
