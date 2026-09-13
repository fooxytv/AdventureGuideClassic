--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
Accepts and hands in quests automatically, but ONLY the ones the current guide asks
for.

The restriction matters. Blanket auto-accept picks up every quest an NPC offers,
which pollutes the log and grabs things the route never intended. Here a quest is only
touched if its title matches an accept or turn-in step within a short window around
the player's current position in the guide, so the automation stays inside what the
player has already opted into by following that guide.

Reward choice is deliberately left alone. Where a quest offers a choice of rewards the
service stops and lets the player pick: choosing gear for someone is not ours to do,
and the "wrong" pick is not undoable.

Both the modern C_GossipInfo API and the older global gossip functions are supported;
the two clients differ and neither can be assumed.
]]

AutoQuestService = { }

-- How far around the current step to look for a matching quest. Generous enough to
-- cover a hub where several quests are taken at once, tight enough that it will not
-- grab something from much later in the route.
local LOOKAHEAD = 12
local LOOKBEHIND = 4

local function Trim(text)
	if not text then return nil end
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

--[[
Does the guide want this quest title, and for what? Returns "accept", "turnin" or nil.
]]
function AutoQuestService.GetIntent(title)
	title = Trim(title)
	if not title or title == "" then return nil end

	local guide = GuideService.GetCurrentGuide()
	if not guide then return nil end

	local index = GuideService.GetStepIndex(guide)
	local from = math.max(1, index - LOOKBEHIND)
	local to = math.min(#guide.steps, index + LOOKAHEAD)

	local function Match(i)
		local task = guide.steps[i]
		local kind = task[1]
		if (kind == "accept" or kind == "turnin") and Trim(task.quest) == title then
			return kind
		end
		return nil
	end

	-- Search forward from the current step FIRST, then behind it. A quest appears in
	-- the guide twice -- once to accept, once to hand in -- so scanning the window in
	-- plain order would keep returning "accept" for a quest already in the log, and
	-- the hand-in would never fire. What is still ahead of the player is what matters.
	for i = index, to do
		local kind = Match(i)
		if kind then return kind end
	end
	for i = index - 1, from, -1 do
		local kind = Match(i)
		if kind then return kind end
	end
	return nil
end

local function AutoAcceptEnabled()
	return SettingsService.IsGuideAutoAcceptEnabled()
end

local function AutoTurnInEnabled()
	return SettingsService.IsGuideAutoTurnInEnabled()
end

-- Quest frame ------------------------------------------------------------------

local function OnQuestDetail()
	if not AutoAcceptEnabled() then return end
	local title = GetTitleText and GetTitleText()
	if AutoQuestService.GetIntent(title) == "accept" and AcceptQuest then
		AcceptQuest()
	end
end

local function OnQuestProgress()
	if not AutoTurnInEnabled() then return end
	local title = GetTitleText and GetTitleText()
	if AutoQuestService.GetIntent(title) ~= "turnin" then return end
	if IsQuestCompletable and IsQuestCompletable() and CompleteQuest then
		CompleteQuest()
	end
end

local function OnQuestComplete()
	if not AutoTurnInEnabled() then return end
	local title = GetTitleText and GetTitleText()
	if AutoQuestService.GetIntent(title) ~= "turnin" then return end

	local choices = GetNumQuestChoices and GetNumQuestChoices() or 0
	if choices > 1 then
		-- A real choice of rewards. Leave it to the player.
		return
	end
	if GetQuestReward then
		GetQuestReward(choices == 1 and 1 or nil)
	end
end

-- Gossip ------------------------------------------------------------------------

local function GetGossipAvailable()
	if C_GossipInfo and C_GossipInfo.GetAvailableQuests then
		local ok, quests = pcall(C_GossipInfo.GetAvailableQuests)
		if ok and type(quests) == "table" then return quests, true end
	end
	if GetGossipAvailableQuests then
		local packed = { GetGossipAvailableQuests() }
		local quests = { }
		-- Older clients return a flat list, several fields per quest.
		local stride = (GetNumGossipAvailableQuests and #packed > 0
			and math.floor(#packed / math.max(1, GetNumGossipAvailableQuests()))) or 6
		for i = 1, #packed, stride do
			table.insert(quests, { title = packed[i] })
		end
		return quests, false
	end
	return { }, false
end

local function GetGossipActive()
	if C_GossipInfo and C_GossipInfo.GetActiveQuests then
		local ok, quests = pcall(C_GossipInfo.GetActiveQuests)
		if ok and type(quests) == "table" then return quests, true end
	end
	if GetGossipActiveQuests then
		local packed = { GetGossipActiveQuests() }
		local quests = { }
		local stride = (GetNumGossipActiveQuests and #packed > 0
			and math.floor(#packed / math.max(1, GetNumGossipActiveQuests()))) or 6
		for i = 1, #packed, stride do
			table.insert(quests, { title = packed[i], isComplete = nil })
		end
		return quests, false
	end
	return { }, false
end

local function SelectAvailable(index, modern)
	if modern and C_GossipInfo and C_GossipInfo.SelectAvailableQuest then
		C_GossipInfo.SelectAvailableQuest(index)
	elseif SelectGossipAvailableQuest then
		SelectGossipAvailableQuest(index)
	end
end

local function SelectActive(index, modern)
	if modern and C_GossipInfo and C_GossipInfo.SelectActiveQuest then
		C_GossipInfo.SelectActiveQuest(index)
	elseif SelectGossipActiveQuest then
		SelectGossipActiveQuest(index)
	end
end

--[[
An NPC with a gossip menu hides its quests one level down. Pick the one the guide is
after -- turn-ins first, so a hub NPC who both takes and gives closes the loop before
starting a new one.
]]
local function OnGossipShow()
	if AutoTurnInEnabled() then
		local active, modern = GetGossipActive()
		for index, quest in ipairs(active) do
			if AutoQuestService.GetIntent(quest.title) == "turnin" then
				SelectActive(index, modern)
				return
			end
		end
	end
	if AutoAcceptEnabled() then
		local available, modern = GetGossipAvailable()
		for index, quest in ipairs(available) do
			if AutoQuestService.GetIntent(quest.title) == "accept" then
				SelectAvailable(index, modern)
				return
			end
		end
	end
end

-- Events -------------------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")
frame:RegisterEvent("GOSSIP_SHOW")
frame:SetScript("OnEvent", function(_, event)
	-- Never fight the player mid-combat, and never act without a guide loaded.
	if InCombatLockdown() then return end
	if not GuideService.GetCurrentGuide() then return end

	if event == "QUEST_DETAIL" then
		OnQuestDetail()
	elseif event == "QUEST_PROGRESS" then
		OnQuestProgress()
	elseif event == "QUEST_COMPLETE" then
		OnQuestComplete()
	elseif event == "GOSSIP_SHOW" then
		OnGossipShow()
	end
end)

-- Debug helpers (see todo.md) -------------------------------------------------

_G.AGC_QuestIntent = function(title)
	if not title then
		title = GetTitleText and GetTitleText() or nil
	end
	print(("|cff33ff99[AGC]|r intent for %s: %s"):format(
		tostring(title), tostring(AutoQuestService.GetIntent(title) or "none")))
end
