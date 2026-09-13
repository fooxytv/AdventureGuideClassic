--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
Advances the levelling guide automatically as the player plays.

Guide steps name quests rather than carrying ids (see GuideService), so completion is
tracked by name. The addon LEARNS the ids as it goes: QUEST_ACCEPTED and
QUEST_TURNED_IN both hand us a questID, we resolve its title, and record the title in
a per-character set. That keeps the data hand-editable while making completion
detection reliable, and it needs no quest database.

After any relevant event the service scans forward from the current step and skips
every step it can prove is already done, so playing out of order, sharing quests, or
completing something before the guide asks for it all resolve correctly.

Steps that cannot be detected -- travel, vendoring, training, notes -- stop the scan.
The player clicks Next for those. Better to pause on a step the player has already
done than to race past several they have not.
]]

GuideProgressService = { }

local frame
local scanScheduled
local listeners = { }

--[[
Fired after every scan, whether or not a step advanced. Objective counts change far
more often than steps do, and the window has to follow them.
]]
function GuideProgressService.RegisterListener(callback)
	table.insert(listeners, callback)
end

local function NotifyListeners()
	for _, listener in ipairs(listeners) do
		local ok, err = pcall(listener)
		if not ok and AdventureGuideClassic_Debug then
			print("|cffff0000AGC|r GuideProgressService listener error: " .. tostring(err))
		end
	end
end

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

--[[
Every quest currently in the log, as a set of titles, plus a second set of the ones
whose objectives are all done. Written against both the modern C_QuestLog API and the
older GetQuestLogTitle, since the two clients differ.
]]
--[[
Is this quest ready to hand in?

Deliberately consults every source available rather than one, because which of them
exists varies by client and a single missing accessor means nothing ever registers as
complete -- which leaves kill and collect steps stuck forever and the guide never
reaching the turn-in.

Note that isComplete is tri-state on the older API: 1 complete, -1 FAILED, nil
otherwise. Only a positive value counts.
]]
local function IsQuestReadyToTurnIn(questID, questIndex, infoIsComplete)
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

	-- Last resort, and the one that works everywhere: if the quest has objectives and
	-- every one of them is finished, it is done. Quests with no objectives at all
	-- (deliver-this, speak-to-them) have no signal here, which is why this is last.
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

function GuideProgressService.GetQuestLogState()
	local inLog, readyToTurnIn, indexByTitle = { }, { }, { }

	-- Test that these are callable, not merely present. Checking presence alone lets a
	-- partial or shimmed namespace through and fails further in, where it is much
	-- harder to trace.
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
				if IsQuestReadyToTurnIn(info.questID, index, info.isComplete) then
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
				if IsQuestReadyToTurnIn(questID, index, isComplete) then
					readyToTurnIn[title] = true
				end
			end
		end
	end
	return inLog, readyToTurnIn, indexByTitle
end

--[[
Live objectives for a quest in the log, as { text, done } lines ready to display.

Both APIs already return the objective pre-formatted ("Kobold Vermin slain: 4/10"),
so there is nothing to parse or localise here -- take the client's own wording.
]]
function GuideProgressService.GetObjectives(questTitle)
	if not questTitle then return { } end
	local inLog, _, indexByTitle = GuideProgressService.GetQuestLogState()
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

local function EnsureStore()
	SavedVariablesPerCharacter = SavedVariablesPerCharacter or { }
	SavedVariablesPerCharacter.Guide = SavedVariablesPerCharacter.Guide or { }
	local store = SavedVariablesPerCharacter.Guide
	store.completedQuests = store.completedQuests or { }
	return store
end

function GuideProgressService.MarkQuestCompleted(title)
	if not title or title == "" then return end
	EnsureStore().completedQuests[title] = true
end

function GuideProgressService.IsQuestCompleted(title)
	if not title then return false end
	return EnsureStore().completedQuests[title] == true
end

function GuideProgressService.ForgetQuests()
	EnsureStore().completedQuests = { }
end

-- Step completion --------------------------------------------------------------

--[[
The quest a step belongs to. Kill and collect steps usually do not name one, so fall
back to the next turn-in ahead of them: that is the quest those objectives feed.
]]
local function QuestForStep(guide, index)
	local task = guide.steps[index]
	if task.quest then return task.quest end
	for lookahead = index + 1, math.min(index + 6, #guide.steps) do
		local later = guide.steps[lookahead]
		if later[1] == "turnin" and later.quest then return later.quest end
		if later[1] == "accept" then break end
	end
	return nil
end

-- Public form of the above, for callers that need to know which quest a step belongs
-- to (the window, to show that quest's objectives).
function GuideProgressService.GetQuestForStep(guide, index)
	return QuestForStep(guide, index)
end

--[[
Whether a step is provably done. Returns nil (rather than false) for steps we have no
way to judge, so the caller can tell "not done" from "cannot tell".
]]
function GuideProgressService.IsStepComplete(guide, index, inLog, readyToTurnIn)
	local task = guide.steps[index]
	if not task then return nil end
	local kind = task[1]

	if kind == "accept" then
		if not task.quest then return nil end
		return (inLog[task.quest] ~= nil) or GuideProgressService.IsQuestCompleted(task.quest)
	end

	if kind == "turnin" then
		if not task.quest then return nil end
		return GuideProgressService.IsQuestCompleted(task.quest)
	end

	if kind == "kill" or kind == "collect" then
		local quest = QuestForStep(guide, index)
		if not quest then return nil end
		if GuideProgressService.IsQuestCompleted(quest) then return true end
		-- Objectives done but not yet handed in: the killing is finished.
		return readyToTurnIn[quest] == true
	end

	if kind == "level" then
		if not task.level then return nil end
		return PlayerContextService.GetLevel() >= task.level
	end

	if kind == "sethearth" then
		if not (task.place and GetBindLocation) then return nil end
		local bind = GetBindLocation()
		return bind ~= nil and bind == task.place
	end

	-- goto / hearth / taxi / vendor / train / note: no reliable signal.
	return nil
end

--[[
Walks forward from the current step, skipping everything provably done. Stops at the
first step that is either unfinished or undetectable.
]]
function GuideProgressService.Scan()
	if not SettingsService.IsGuideAutoAdvanceEnabled() then return 0 end
	local guide = GuideService.GetCurrentGuide()
	if not guide then return 0 end

	local inLog, readyToTurnIn = GuideProgressService.GetQuestLogState()
	local index = GuideService.GetStepIndex(guide)
	local advanced = 0

	while index < #guide.steps do
		local complete = GuideProgressService.IsStepComplete(guide, index, inLog, readyToTurnIn)
		if complete ~= true then break end
		index = index + 1
		advanced = advanced + 1
	end

	if advanced > 0 then
		GuideService.SetStepIndex(index, guide)
	end
	NotifyListeners()
	return advanced
end

-- Events -----------------------------------------------------------------------

--[[
Several of these fire in bursts (QUEST_LOG_UPDATE especially), and the quest log is
not always settled at the moment the event arrives, so coalesce into a single scan on
the next frame.
]]
local function ScheduleScan()
	if scanScheduled then return end
	scanScheduled = true
	C_Timer.After(0.1, function()
		scanScheduled = false
		GuideProgressService.Scan()
	end)
end

local function OnEvent(_, event, arg1, arg2)
	if event == "QUEST_TURNED_IN" then
		-- Signature differs across clients: (questID, xp, money) on some,
		-- (questLogIndex, questID) on others, so try both positions.
		GuideProgressService.MarkQuestCompleted(
			GetQuestTitleByID(arg1) or GetQuestTitleByID(arg2))
	end
	-- QUEST_ACCEPTED needs no special handling: acceptance is read straight off the
	-- quest log. QUEST_REMOVED is deliberately ignored -- abandoning a quest removes
	-- it too, and must not count as completion.
	ScheduleScan()
end

frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("QUEST_REMOVED")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:SetScript("OnEvent", OnEvent)

--[[
QUEST_TURNED_IN does not exist on every client. Where it is missing, a quest that
leaves the log while its objectives were complete is treated as handed in -- which is
why the log state is sampled before and after.
]]
local previousReady = { }

local function PollForTurnIns()
	local inLog, readyToTurnIn = GuideProgressService.GetQuestLogState()
	for title in pairs(previousReady) do
		if not inLog[title] then
			GuideProgressService.MarkQuestCompleted(title)
		end
	end
	previousReady = readyToTurnIn
end

local pollFrame = CreateFrame("Frame")
pollFrame:RegisterEvent("QUEST_LOG_UPDATE")
pollFrame:SetScript("OnEvent", PollForTurnIns)

-- Debug helpers (see todo.md) -------------------------------------------------

_G.AGC_GuideProgress = function()
	local guide = GuideService.GetCurrentGuide()
	if not guide then
		print("|cffff5555[AGC]|r no guide selected.")
		return
	end
	local inLog, ready = GuideProgressService.GetQuestLogState()
	local index = GuideService.GetStepIndex(guide)
	print(("|cff33ff99[AGC]|r %s, step %d of %d, auto-advance %s"):format(
		guide.id, index, #guide.steps,
		SettingsService.IsGuideAutoAdvanceEnabled() and "on" or "off"))
	local anyReady = false
	for title in pairs(ready) do
		anyReady = true
		print(("  ready to hand in: %s"):format(title))
	end
	if not anyReady then
		print("  nothing in the log reads as ready to hand in")
	end
	for offset = 0, 4 do
		local i = index + offset
		if not guide.steps[i] then break end
		local state = GuideProgressService.IsStepComplete(guide, i, inLog, ready)
		print(("  %d. [%-9s] %s"):format(i, tostring(guide.steps[i][1]),
			state == true and "done" or (state == nil and "cannot tell" or "not done")))
	end
end

_G.AGC_GuideObjectives = function()
	local guide = GuideService.GetCurrentGuide()
	if not guide then
		print("|cffff5555[AGC]|r no guide selected.")
		return
	end
	local index = GuideService.GetStepIndex(guide)
	local quest = GuideProgressService.GetQuestForStep(guide, index)
	print(("|cff33ff99[AGC]|r step %d belongs to quest: %s"):format(index, tostring(quest)))
	for _, objective in ipairs(GuideProgressService.GetObjectives(quest)) do
		print(("  [%s] %s"):format(objective.done and "x" or " ", objective.text))
	end
end

_G.AGC_GuideScan = function()
	local advanced = GuideProgressService.Scan()
	print(("|cff33ff99[AGC]|r advanced %d step(s)."):format(advanced))
end
