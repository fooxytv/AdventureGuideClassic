--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
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

local function IsBurningCrusade()
	local version, build, date, tocversion = GetBuildInfo()
	return tocversion >= 20000
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

local function ShouldIncludeInstance(instance)
	local activeSeason = C_Seasons.GetActiveSeason()
	local filterType = instance.seasonFilter or "all"
	local isTBC = IsBurningCrusade()
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

function InstanceService.GetDungeons()
	local filteredDungeons = { }
	for _, dungeon in ipairs(dungeons) do
		if ShouldIncludeInstance(dungeon) then
			table.insert(filteredDungeons, dungeon)
		end
	end
	return filteredDungeons
end

function InstanceService.GetRaids()
	local filteredRaids = { }
	for _, raid in ipairs(raids) do
		if ShouldIncludeInstance(raid) then
			table.insert(filteredRaids, raid)
		end
	end
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