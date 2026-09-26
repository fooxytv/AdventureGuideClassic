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

--[[
	Every registered instance, before any filtering. ForeverContentService needs the
	raw set to decide whether the client's journal agrees with our data.
]]
function InstanceService.GetAllInstances()
	local all = { }
	for _, dungeon in ipairs(dungeons) do table.insert(all, dungeon) end
	for _, raid in ipairs(raids) do table.insert(all, raid) end
	return all
end

--[[
	Forever has its own instance list, so the client's journal decides what shows
	rather than our season tags. The tags still rule out content that cannot be there
	under any reading -- Season of Discovery instances and TBC instances -- because
	those are ours to know and the journal id for a SoD instance is borrowed from the
	vanilla instance it reuses, so it would otherwise match.
]]
local function ShouldIncludeOnForever(instance, filterType)
	if instance.season == true then return false end
	if filterType == "exclusive" or filterType == "sod" then return false end
	if filterType == "tbc" then return false end
	return ForeverContentService.HasInstance(instance)
end

local function ShouldIncludeInstance(instance)
	local filterType = instance.seasonFilter or "all"

	--[[
		Forever's own instances. Checked ahead of everything else so the tag can never
		leak onto a client that does not have the content -- on Era, SoD and TBC it is
		an unrecognised tag, and unrecognised tags fall through to "show".
	]]
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

--[[
	Instances are listed by the name the player actually sees.

	Registration order is by file name, which is close but not the same: Stormwind
	Stockade lives in The_Stockade.lua, and Forever's instances are registered after
	the vanilla ones, so both land in the wrong place without this.
]]
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
