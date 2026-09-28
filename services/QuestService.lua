--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

QuestService = { }

local byInstance = { }

-- Registered from data/Quests/<flavour>/<Dungeon>.lua, which tools/gen_dungeon_quests.py
-- generates from a Questie checkout. Keyed on instance name.
function QuestService.Register(instanceName, quests)
	byInstance[instanceName] = quests
end

-- C_QuestLog.IsOnQuest is present on Era, SoD, TBC and Forever alike; the log-index
-- fallback is for a client with the namespace but not that call.
local function IsOnQuest(questID)
	if not C_QuestLog then return false end
	if C_QuestLog.IsOnQuest then
		return C_QuestLog.IsOnQuest(questID) == true
	end
	if C_QuestLog.GetLogIndexForQuestID then
		return C_QuestLog.GetLogIndexForQuestID(questID) ~= nil
	end
	return false
end

local function IsCompleted(questID)
	if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
		return C_QuestLog.IsQuestFlaggedCompleted(questID) == true
	end
	return false
end

local previewState

local VALID_STATES = { available = true, active = true, completed = true }

function QuestService.SetPreviewState(state)
	if state ~= nil and not VALID_STATES[state] then return false end
	previewState = state
	return true
end

function QuestService.GetPreviewState()
	return previewState
end

-- Completed is checked before active: a repeatable quest can be both flagged complete
-- and sitting in the log.
function QuestService.GetState(questID)
	if previewState then return previewState end
	if not questID then return "available" end
	if IsCompleted(questID) then return "completed" end
	if IsOnQuest(questID) then return "active" end
	return "available"
end

-- The generator only writes the field when the quest is faction-restricted.
local function PassesFaction(quest)
	if not quest.side then return true end
	return quest.side == UnitFactionGroup("player")
end

function QuestService.GetQuests(instanceName)
	local quests = byInstance[instanceName]
	if not quests then return { } end

	local result = { }
	for _, quest in ipairs(quests) do
		if PassesFaction(quest) then
			table.insert(result, quest)
		end
	end
	return result
end

local STATE_ICON = {
	available = "Interface/GossipFrame/AvailableQuestIcon",
	active    = "Interface/GossipFrame/ActiveQuestIcon",
	completed = "Interface/RaidFrame/ReadyCheck-Ready",
}

function QuestService.GetStateIcon(questID)
	return STATE_ICON[QuestService.GetState(questID)] or STATE_ICON.available
end

function QuestService.GetAllQuests()
	local all = { }
	for instanceName, quests in pairs(byInstance) do
		for _, quest in ipairs(quests) do
			if PassesFaction(quest) then
				table.insert(all, { quest = quest, instanceName = instanceName })
			end
		end
	end
	return all
end

function QuestService.HasQuests(instanceName)
	if not instanceName then return false end
	local quests = byInstance[instanceName]
	if not quests then return false end

	for _, quest in ipairs(quests) do
		if PassesFaction(quest) then return true end
	end
	return false
end
