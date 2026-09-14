--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
Reads the player's quest state: what is in the log, what is finished, what has been
handed in, and how far along each quest's objectives are.

This is the factual layer. It answers "where does this character stand?" and nothing
more -- it holds no opinion about what to do next. QuestChainService builds on it to
work out which quests are available, blocked or done.

Quests are keyed by NAME rather than id because the addon's own quest data is written
against names, and the ids differ nowhere it matters. Ids are still used where the
client offers them, and the service learns titles from ids as it goes.

Every accessor is written against several client APIs. Which of them exists varies
between Era and BCC, and relying on one means a single missing accessor silently
reports that nothing is ever complete.
]]

QuestLogService = { }

local listeners = { }
local refreshScheduled

-- Client API shims -------------------------------------------------------------

local function GetQuestTitleByID(questID)
	if not questID then return nil end
	if type(C_QuestLog) == "table" and type(C_QuestLog.GetTitleForQuestID) == "function" then
		local ok, title = pcall(C_QuestLog.GetTitleForQuestID, questID)
		if ok and title and title ~= "" then return title end
	end
	if type(C_QuestLog) == "table" and type(C_QuestLog.GetQuestInfo) == "function" then
		local ok, title = pcall(C_QuestLog.GetQuestInfo, questID)
		if ok and title and title ~= "" then return title end
	end
	return nil
end

function QuestLogService.GetQuestTitleByID(questID)
	return GetQuestTitleByID(questID)
end

--[[
Is this quest ready to hand in?

Consults every source available rather than one, because which exists varies by client
and a single missing accessor means nothing ever registers as complete.

isComplete is tri-state on the older API: 1 complete, -1 FAILED, nil otherwise. Only a
positive value counts -- treating -1 as complete would report a failed quest as ready
to hand in.
]]
local function IsReadyToTurnIn(questID, questIndex, infoIsComplete)
	if infoIsComplete == true then return true end
	if type(infoIsComplete) == "number" and infoIsComplete > 0 then return true end

	if questID and type(C_QuestLog) == "table" then
		for _, accessor in ipairs({ "IsComplete", "ReadyForTurnIn" }) do
			if type(C_QuestLog[accessor]) == "function" then
				local ok, value = pcall(C_QuestLog[accessor], questID)
				if ok and value then return true end
			end
		end
	end

	if questIndex and type(GetQuestLogTitle) == "function" then
		local ok, _, _, _, _, _, isComplete = pcall(GetQuestLogTitle, questIndex)
		if ok and type(isComplete) == "number" and isComplete > 0 then return true end
		if ok and isComplete == true then return true end
	end

	-- Last resort, and the one that works everywhere: a quest whose objectives are all
	-- finished is done. Last because quests with no objectives at all -- deliver this,
	-- speak to them -- give it nothing to judge.
	if questIndex and type(GetNumQuestLeaderBoards) == "function"
		and type(GetQuestLogLeaderBoard) == "function" then
		local ok, count = pcall(GetNumQuestLeaderBoards, questIndex)
		if ok and type(count) == "number" and count > 0 then
			for i = 1, count do
				local ok2, _, _, finished = pcall(GetQuestLogLeaderBoard, i, questIndex)
				if not (ok2 and finished) then return false end
			end
			return true
		end
	end

	return false
end

--[[
The current quest log, as three tables keyed by quest title:

	inLog          title -> questID (or true where the client offers no id)
	readyToTurnIn  title -> true
	indexByTitle   title -> quest log index, which the older objective API needs
]]
function QuestLogService.GetQuestLogState()
	local inLog, readyToTurnIn, indexByTitle = { }, { }, { }

	-- Test that these are callable, not merely present: a partial namespace otherwise
	-- slips through and fails further in, where it is much harder to trace.
	if type(C_QuestLog) == "table"
		and type(C_QuestLog.GetNumQuestLogEntries) == "function"
		and type(C_QuestLog.GetInfo) == "function" then
		local ok, numEntries = pcall(C_QuestLog.GetNumQuestLogEntries)
		if not (ok and type(numEntries) == "number") then numEntries = 0 end
		for index = 1, numEntries do
			local ok2, info = pcall(C_QuestLog.GetInfo, index)
			if ok2 and info and not info.isHeader and info.title then
				inLog[info.title] = info.questID or true
				indexByTitle[info.title] = index
				if IsReadyToTurnIn(info.questID, index, info.isComplete) then
					readyToTurnIn[info.title] = true
				end
			end
		end
		return inLog, readyToTurnIn, indexByTitle
	end

	if type(GetNumQuestLogEntries) == "function" and type(GetQuestLogTitle) == "function" then
		local ok, numEntries = pcall(GetNumQuestLogEntries)
		if not (ok and type(numEntries) == "number") then numEntries = 0 end
		for index = 1, numEntries do
			local title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
			if title and not isHeader then
				inLog[title] = questID or true
				indexByTitle[title] = index
				if IsReadyToTurnIn(questID, index, isComplete) then
					readyToTurnIn[title] = true
				end
			end
		end
	end
	return inLog, readyToTurnIn, indexByTitle
end

--[[
Live objectives for a quest in the log, as { text, done } lines ready to display.

Both APIs return the objective already formatted ("Kobold Vermin slain: 4/10"), so
there is nothing to parse and nothing to localise -- take the client's own wording.
]]
function QuestLogService.GetObjectives(questTitle)
	if not questTitle then return { } end
	local inLog, _, indexByTitle = QuestLogService.GetQuestLogState()
	local questID = inLog[questTitle]
	local questIndex = indexByTitle[questTitle]
	if not questIndex then return { } end

	local objectives = { }

	if type(questID) == "number"
		and type(C_QuestLog) == "table"
		and type(C_QuestLog.GetQuestObjectives) == "function" then
		local ok, list = pcall(C_QuestLog.GetQuestObjectives, questID)
		if ok and type(list) == "table" then
			for _, objective in ipairs(list) do
				if objective and objective.text and objective.text ~= "" then
					table.insert(objectives, {
						text = objective.text,
						done = objective.finished and true or false,
					})
				end
			end
			if #objectives > 0 then return objectives end
		end
	end

	if type(GetNumQuestLeaderBoards) == "function"
		and type(GetQuestLogLeaderBoard) == "function" then
		local ok, count = pcall(GetNumQuestLeaderBoards, questIndex)
		if ok and type(count) == "number" then
			for i = 1, count do
				local ok2, text, _, finished = pcall(GetQuestLogLeaderBoard, i, questIndex)
				if ok2 and text and text ~= "" then
					table.insert(objectives, { text = text, done = finished and true or false })
				end
			end
		end
	end

	return objectives
end

-- Completed-quest memory -------------------------------------------------------

--[[
Which quests this character has handed in.

The client can answer this by id where IsQuestFlaggedCompleted exists, but that covers
only quests it knows about and says nothing for a name we have no id for. So the
service also remembers, per character, every hand-in it has seen -- which makes the
record grow more accurate the longer the addon is used.
]]
local function EnsureStore()
	SavedVariablesPerCharacter = SavedVariablesPerCharacter or { }
	SavedVariablesPerCharacter.Quests = SavedVariablesPerCharacter.Quests or { }
	local store = SavedVariablesPerCharacter.Quests
	store.completed = store.completed or { }
	return store
end

function QuestLogService.MarkCompleted(title)
	if not title or title == "" then return end
	EnsureStore().completed[title] = true
end

function QuestLogService.IsCompleted(title, questID)
	if questID and type(IsQuestFlaggedCompleted) == "function" then
		local ok, value = pcall(IsQuestFlaggedCompleted, questID)
		if ok and value then return true end
	end
	if not title then return false end
	return EnsureStore().completed[title] == true
end

function QuestLogService.ForgetCompleted()
	EnsureStore().completed = { }
end

function QuestLogService.GetCompletedCount()
	local count = 0
	for _ in pairs(EnsureStore().completed) do count = count + 1 end
	return count
end

-- Change notification ------------------------------------------------------------

--[[
Fired after the quest log settles. Objective counts and hand-ins change far more often
than anything reading them needs to redraw, so the burst of events the client sends is
coalesced into one notification.
]]
function QuestLogService.RegisterListener(callback)
	table.insert(listeners, callback)
end

local function NotifyListeners()
	for _, listener in ipairs(listeners) do
		local ok, err = pcall(listener)
		if not ok and AdventureGuideClassic_Debug then
			print("|cffff0000AGC|r QuestLogService listener error: " .. tostring(err))
		end
	end
end

local function ScheduleRefresh()
	if refreshScheduled then return end
	refreshScheduled = true
	C_Timer.After(0.1, function()
		refreshScheduled = false
		NotifyListeners()
	end)
end

--[[
QUEST_TURNED_IN does not exist on every client. Where it is missing, a quest that
leaves the log while its objectives were complete counts as handed in -- which is why
the previous state is kept between updates. Abandoning a quest removes it too, but an
abandoned quest was not complete, so the two do not collide.
]]
local previousReady = { }

local function PollForTurnIns()
	local inLog, readyToTurnIn = QuestLogService.GetQuestLogState()
	for title in pairs(previousReady) do
		if not inLog[title] then
			QuestLogService.MarkCompleted(title)
		end
	end
	previousReady = readyToTurnIn
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("QUEST_REMOVED")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
frame:SetScript("OnEvent", function(_, event, arg1, arg2)
	if event == "QUEST_TURNED_IN" then
		-- Signature differs across clients: (questID, xp, money) on some,
		-- (questLogIndex, questID) on others, so try both positions.
		QuestLogService.MarkCompleted(GetQuestTitleByID(arg1) or GetQuestTitleByID(arg2))
	end
	if event == "QUEST_LOG_UPDATE" then
		PollForTurnIns()
	end
	ScheduleRefresh()
end)

-- Debug helpers (see todo.md) -------------------------------------------------

_G.AGC_QuestLog = function()
	local inLog, ready = QuestLogService.GetQuestLogState()
	local count = 0
	print("|cff33ff99[AGC]|r quest log:")
	for title in pairs(inLog) do
		count = count + 1
		print(("  %s%s"):format(title, ready[title] and "  |cff40ff40(ready to hand in)|r" or ""))
	end
	if count == 0 then print("  (empty)") end
	print(("  %d quest(s) remembered as completed"):format(QuestLogService.GetCompletedCount()))
end

_G.AGC_QuestObjectives = function(title)
	for _, objective in ipairs(QuestLogService.GetObjectives(title)) do
		print(("  [%s] %s"):format(objective.done and "x" or " ", objective.text))
	end
end
