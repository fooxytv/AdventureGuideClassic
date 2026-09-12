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

local function GetActiveSeason()
	if C_Seasons and C_Seasons.GetActiveSeason then
		return C_Seasons.GetActiveSeason()
	end
	return nil
end

--[[
Rules imposed by the client itself: which expansion we're running on and whether a
season is active. These are facts about the game, not preferences, so nothing may
opt out of them.
]]
local function PassesClientRules(instance)
	local activeSeason = GetActiveSeason()
	local filterType = instance.seasonFilter or "all"
	local isTBC = IsBurningCrusade()

	if instance.season ~= nil then
		if instance.season and activeSeason ~= 2 then
			return false
		end
		return true
	end

	if filterType == "tbc" and not isTBC then
		return false
	end

	if filterType == "exclusive" and activeSeason ~= 2 then
		return false
	elseif filterType == "restricted" and activeSeason == 2 then
		return false
	end

	return true
end

--[[
The user's Classic/Burning Crusade dropdown on the Dungeons and Raids tabs. This is a
browsing preference, so anything answering "what can this character actually do right
now?" (Suggested Content) must skip it and use GetAllDungeons/GetAllRaids instead.
]]
local function PassesUserFilter(instance)
	local userFilter = InstanceService.GetExpansionFilter()
	local filterType = instance.seasonFilter or "all"

	if instance.season ~= nil then
		return userFilter ~= "tbc"
	end

	if userFilter == "classic" then
		return filterType ~= "tbc"
	elseif userFilter == "tbc" then
		return filterType == "tbc"
	end

	return true
end

local function ShouldIncludeInstance(instance)
	return PassesClientRules(instance) and PassesUserFilter(instance)
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

--[[
Every dungeon/raid valid on this client, ignoring the user's expansion dropdown.
Suggested Content uses these so a browsing preference can't change what the addon
recommends; level gating is the caller's job.
]]
function InstanceService.GetAllDungeons()
	local result = { }
	for _, dungeon in ipairs(dungeons) do
		if PassesClientRules(dungeon) then
			table.insert(result, dungeon)
		end
	end
	return result
end

function InstanceService.GetAllRaids()
	local result = { }
	for _, raid in ipairs(raids) do
		if PassesClientRules(raid) then
			table.insert(result, raid)
		end
	end
	return result
end

--[[
Instances whose level range overlaps [minLevel, maxLevel], optionally restricted to a
faction. An instance with no levelRange is skipped rather than guessed at.
]]
function InstanceService.GetInstancesForLevelRange(instanceList, minLevel, maxLevel, faction)
	local result = { }
	for _, instance in ipairs(instanceList) do
		local range = instance.levelRange
		if range and range.min and range.max then
			if range.min <= maxLevel and range.max >= minLevel then
				if (not faction) or (not instance.faction) or instance.faction == faction then
					table.insert(result, instance)
				end
			end
		end
	end
	return result
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