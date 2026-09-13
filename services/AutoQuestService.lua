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

local verbose = false

local function Trace(fmt, ...)
	if not verbose then return end
	print("|cff33ff99[AGC quest]|r " .. fmt:format(...))
end

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

--[[
The title of the quest the open quest frame is about.

GetTitleText is the obvious source but is not dependable at the moment these events
fire, so fall back to resolving GetQuestID through the quest database -- which is what
the established guide addons key off throughout. Either alone leaves a gap; the guides
here are written against names, so a name is what has to come out.
]]
local function OfferedQuestTitle()
	if type(GetTitleText) == "function" then
		local ok, title = pcall(GetTitleText)
		title = ok and Trim(title) or nil
		if title and title ~= "" then return title end
	end
	if type(GetQuestID) == "function" then
		local ok, questID = pcall(GetQuestID)
		if ok and type(questID) == "number" and questID > 0 then
			local title = GuideProgressService.GetQuestTitleByID
				and GuideProgressService.GetQuestTitleByID(questID)
			if title and title ~= "" then return Trim(title) end
		end
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
	local title = OfferedQuestTitle()
	Trace("QUEST_DETAIL %s -> %s", tostring(title),
		tostring(AutoQuestService.GetIntent(title) or "none"))
	if AutoQuestService.GetIntent(title) == "accept" and AcceptQuest then
		AcceptQuest()
	end
end

--[[
QUEST_GREETING is the frame Classic shows when an NPC has several quests but no
gossip options -- very common, and the path a hub NPC takes as soon as they have both
something to hand in and something to offer. It is a different API from gossip:
GetActiveTitle/SelectActiveQuest rather than the gossip equivalents.

Missing this was why hand-ins silently did nothing. The first quest of a chain arrives
via QUEST_DETAIL and worked; as soon as the same NPC had two quests the greeting frame
took over and nothing was listening for it.
]]
local function OnQuestGreeting()
	if AutoTurnInEnabled() and type(GetNumActiveQuests) == "function" then
		local ok, count = pcall(GetNumActiveQuests)
		for index = 1, (ok and count or 0) do
			local title = GetActiveTitle and GetActiveTitle(index)
			Trace("greeting active %d: %s -> %s", index, tostring(title),
				tostring(AutoQuestService.GetIntent(title) or "none"))
			if AutoQuestService.GetIntent(title) == "turnin" and SelectActiveQuest then
				SelectActiveQuest(index)
				return
			end
		end
	end
	if AutoAcceptEnabled() and type(GetNumAvailableQuests) == "function" then
		local ok, count = pcall(GetNumAvailableQuests)
		for index = 1, (ok and count or 0) do
			local title = GetAvailableTitle and GetAvailableTitle(index)
			Trace("greeting available %d: %s -> %s", index, tostring(title),
				tostring(AutoQuestService.GetIntent(title) or "none"))
			if AutoQuestService.GetIntent(title) == "accept" and SelectAvailableQuest then
				SelectAvailableQuest(index)
				return
			end
		end
	end
end

local function OnQuestProgress()
	if not AutoTurnInEnabled() then return end
	local title = OfferedQuestTitle()
	local completable = IsQuestCompletable and IsQuestCompletable()
	Trace("QUEST_PROGRESS %s -> %s (completable %s)", tostring(title),
		tostring(AutoQuestService.GetIntent(title) or "none"), tostring(completable))
	if AutoQuestService.GetIntent(title) ~= "turnin" then return end
	if completable and CompleteQuest then
		CompleteQuest()
	end
end

local function OnQuestComplete()
	if not AutoTurnInEnabled() then return end
	local title = OfferedQuestTitle()
	Trace("QUEST_COMPLETE %s -> %s", tostring(title),
		tostring(AutoQuestService.GetIntent(title) or "none"))
	if AutoQuestService.GetIntent(title) ~= "turnin" then return end

	local choices = GetNumQuestChoices and GetNumQuestChoices() or 0
	if choices > 1 then
		-- A real choice of rewards. Leave it to the player.
		Trace("  leaving %s to you: %d reward choices", tostring(title), choices)
		return
	end
	if GetQuestReward then
		-- 0 means "no choice made", which is what Blizzard's own quest frame passes
		-- when a quest offers no choice of reward. nil is not valid here.
		Trace("completing %s (%d reward choices)", tostring(title), choices)
		GetQuestReward(choices == 1 and 1 or 0)
	end
end

-- Gossip ------------------------------------------------------------------------

--[[
Gossip quest lists, returned as entries that know how to select THEMSELVES.

The two APIs disagree about what a quest is addressed by, and mixing them up fails
silently -- you select the wrong quest, or none:

  modern  C_GossipInfo.SelectAvailableQuest takes a QUEST ID
  legacy  SelectGossipAvailableQuest takes a 1-based INDEX

Returning a closure per entry keeps that difference in one place instead of leaking an
"is this an index or an id?" question into the caller.

The legacy calls also return a flat varargs list, several fields per quest, and the
field count differs between the two: 7 for available, 6 for active. The stride is
computed from the actual count where possible and falls back to those figures.
]]
local function UnpackLegacy(packed, countFn, fallbackStride, makeSelect)
	local entries = { }
	if #packed == 0 then return entries end
	local count
	if type(countFn) == "function" then
		local ok, value = pcall(countFn)
		if ok and type(value) == "number" and value > 0 then count = value end
	end
	local stride = fallbackStride
	if count and count > 0 and #packed % count == 0 then
		stride = math.floor(#packed / count)
	end
	if stride < 1 then stride = fallbackStride end
	local index = 0
	for i = 1, #packed, stride do
		index = index + 1
		local position = index
		table.insert(entries, {
			title = packed[i],
			Select = function() makeSelect(position) end,
		})
	end
	return entries
end

local function GetGossipAvailable()
	if type(C_GossipInfo) == "table"
		and type(C_GossipInfo.GetAvailableQuests) == "function"
		and type(C_GossipInfo.SelectAvailableQuest) == "function" then
		local ok, quests = pcall(C_GossipInfo.GetAvailableQuests)
		if ok and type(quests) == "table" then
			local entries = { }
			for _, quest in ipairs(quests) do
				local questID = quest.questID
				table.insert(entries, {
					title = quest.title,
					Select = function() C_GossipInfo.SelectAvailableQuest(questID) end,
				})
			end
			return entries
		end
	end
	if type(GetGossipAvailableQuests) == "function"
		and type(SelectGossipAvailableQuest) == "function" then
		return UnpackLegacy({ GetGossipAvailableQuests() }, GetNumGossipAvailableQuests, 7,
			SelectGossipAvailableQuest)
	end
	return { }
end

local function GetGossipActive()
	if type(C_GossipInfo) == "table"
		and type(C_GossipInfo.GetActiveQuests) == "function"
		and type(C_GossipInfo.SelectActiveQuest) == "function" then
		local ok, quests = pcall(C_GossipInfo.GetActiveQuests)
		if ok and type(quests) == "table" then
			local entries = { }
			for _, quest in ipairs(quests) do
				local questID = quest.questID
				table.insert(entries, {
					title = quest.title,
					Select = function() C_GossipInfo.SelectActiveQuest(questID) end,
				})
			end
			return entries
		end
	end
	if type(GetGossipActiveQuests) == "function"
		and type(SelectGossipActiveQuest) == "function" then
		return UnpackLegacy({ GetGossipActiveQuests() }, GetNumGossipActiveQuests, 6,
			SelectGossipActiveQuest)
	end
	return { }
end

local function OnGossipShow()
	if AutoTurnInEnabled() then
		local active = GetGossipActive()
		Trace("  gossip: %d active quest(s)", #active)
		for index, quest in ipairs(active) do
			Trace("    active %d: %s -> %s", index, tostring(quest.title),
				tostring(AutoQuestService.GetIntent(quest.title) or "none"))
			if AutoQuestService.GetIntent(quest.title) == "turnin" then
				quest.Select()
				return
			end
		end
	end
	if AutoAcceptEnabled() then
		local available = GetGossipAvailable()
		Trace("  gossip: %d available quest(s)", #available)
		for index, quest in ipairs(available) do
			Trace("    available %d: %s -> %s", index, tostring(quest.title),
				tostring(AutoQuestService.GetIntent(quest.title) or "none"))
			if AutoQuestService.GetIntent(quest.title) == "accept" then
				quest.Select()
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
frame:RegisterEvent("QUEST_GREETING")
frame:SetScript("OnEvent", function(_, event)
	Trace("event %s", event)
	-- Never fight the player mid-combat, and never act without a guide loaded.
	if InCombatLockdown() then
		Trace("  ignored: in combat")
		return
	end
	if not GuideService.GetCurrentGuide() then
		Trace("  ignored: no guide selected")
		return
	end
	Trace("  auto-accept %s, auto-turn-in %s, step %d",
		tostring(AutoAcceptEnabled()), tostring(AutoTurnInEnabled()),
		GuideService.GetStepIndex())

	if event == "QUEST_DETAIL" then
		OnQuestDetail()
	elseif event == "QUEST_PROGRESS" then
		OnQuestProgress()
	elseif event == "QUEST_COMPLETE" then
		OnQuestComplete()
	elseif event == "GOSSIP_SHOW" then
		OnGossipShow()
	elseif event == "QUEST_GREETING" then
		OnQuestGreeting()
	end
end)

-- Debug helpers (see todo.md) -------------------------------------------------

-- Turns on a running commentary of what the automation sees and decides. It is
-- otherwise entirely invisible when it does nothing, which is the hard case.
_G.AGC_QuestDebug = function(enabled)
	if enabled == nil then enabled = not verbose end
	verbose = enabled and true or false
	print(("|cff33ff99[AGC]|r quest automation tracing %s."):format(verbose and "ON" or "OFF"))
end

_G.AGC_QuestIntent = function(title)
	if not title then
		title = OfferedQuestTitle()
	end
	print(("|cff33ff99[AGC]|r intent for %s: %s"):format(
		tostring(title), tostring(AutoQuestService.GetIntent(title) or "none")))
end
