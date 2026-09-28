--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

local dungeons = { }
local raids = { }

InstanceService = { }

function InstanceService.AddDungeon(dungeon)
	table.insert(dungeons, dungeon)
end

function InstanceService.AddRaid(raid)
	table.insert(raids, raid)
end

function InstanceService.GetExpansionFilter()
	return SavedVariables.ExpansionFilter or "classic"
end

function InstanceService.SetExpansionFilter(filter)
	SavedVariables.ExpansionFilter = filter
end

function InstanceService.GetDifficulty()
	return SavedVariables.Difficulty or "normal"
end

function InstanceService.SetDifficulty(difficulty)
	SavedVariables.Difficulty = difficulty
end

function InstanceService.GetAllInstances()
	local all = { }
	for _, dungeon in ipairs(dungeons) do table.insert(all, dungeon) end
	for _, raid in ipairs(raids) do table.insert(all, raid) end
	return all
end

-- The journal decides what shows on Forever. Season tags still rule out SoD and TBC,
-- because a SoD instance borrows its journal id from the vanilla instance it reuses.
local function ShouldIncludeOnForever(instance, filterType)
	if instance.season == true then return false end
	if filterType == "exclusive" or filterType == "sod" then return false end
	if filterType == "tbc" then return false end
	return ForeverContentService.HasInstance(instance)
end

local function ShouldIncludeInstance(instance)
	local filterType = instance.seasonFilter or "all"

	-- On Era, SoD and TBC this is an unrecognised tag, and unrecognised tags fall through to show.
	if filterType == "forever" then
		return Compat.isForever
	end

	if Compat.isForever then
		return ShouldIncludeOnForever(instance, filterType)
	end

	local activeSeason = Compat.GetActiveSeason()
	local isTBC = Compat.isTBC
	local userFilter = InstanceService.GetExpansionFilter()

	if instance.season ~= nil then
		if instance.season and activeSeason ~= 2 then
			return false
		end
		if userFilter == "tbc" then
			return false
		end
		return true
	end

	if filterType == "tbc" and not isTBC then
		return false
	end

	if userFilter == "classic" then
		if filterType == "tbc" then
			return false
		end
	elseif userFilter == "tbc" then
		if filterType ~= "tbc" then
			return false
		end
	end

	if filterType == "exclusive" and activeSeason ~= 2 then
		return false
	elseif filterType == "restricted" and activeSeason == 2 then
		return false
	end

	return true
end

-- Registration order is by file name, which differs: Stormwind Stockade lives in
-- The_Stockade.lua.
local function ByDisplayName(a, b)
	return (a.name or "") < (b.name or "")
end

function InstanceService.GetDungeons()
	local filteredDungeons = { }
	for _, dungeon in ipairs(dungeons) do
		if ShouldIncludeInstance(dungeon) then
			table.insert(filteredDungeons, dungeon)
		end
	end
	table.sort(filteredDungeons, ByDisplayName)
	return filteredDungeons
end

function InstanceService.GetRaids()
	local filteredRaids = { }
	for _, raid in ipairs(raids) do
		if ShouldIncludeInstance(raid) then
			table.insert(filteredRaids, raid)
		end
	end
	table.sort(filteredRaids, ByDisplayName)
	return filteredRaids
end

function InstanceService.GetInstanceByName(name)
	for _, dungeon in ipairs(dungeons) do
		if dungeon.name == name then return dungeon end
	end
	for _, raid in ipairs(raids) do
		if raid.name == name then return raid end
	end
	return nil
end
