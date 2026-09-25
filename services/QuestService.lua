--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

QuestService = { }

local byInstance = { }

--[[
	Registered from data/Quests/<flavour>/<Dungeon>.lua, which tools/gen_dungeon_quests.py
	generates from a Questie checkout. Keyed on the instance name because that is what
	the data files and the UI both already have to hand.
]]
function QuestService.Register(instanceName, quests)
	byInstance[instanceName] = quests
end

--[[
	Whether the player has this quest in their log.

	C_QuestLog.IsOnQuest is the direct answer and is present on Era, SoD, TBC and
	Forever alike. The log-index fallback is there for a client that has the namespace
	without that particular call rather than for any one we know of.
]]
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

--[[
	"completed", "active" or "available".

	Completed is checked first: a repeatable quest can be both flagged complete and
	sitting in the log, and the tick is the more useful thing to say about it.
]]
function QuestService.GetState(questID)
	if not questID then return "available" end
	if IsCompleted(questID) then return "completed" end
	if IsOnQuest(questID) then return "active" end
	return "available"
end

--[[
	A quest's own faction, or nil when either side can take it. The generator only
	writes the field when the quest is restricted, so nil is the common case.
]]
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

function QuestService.HasQuests(instanceName)
	if not instanceName then return false end
	local quests = byInstance[instanceName]
	if not quests then return false end

	for _, quest in ipairs(quests) do
		if PassesFaction(quest) then return true end
	end
	return false
end
