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

-- Detect if we're running on Burning Crusade Classic vs Classic Era
local function IsBurningCrusade()
	local version, build, date, tocversion = GetBuildInfo()
	-- TOC version 20505 = Burning Crusade Classic
	-- TOC version 11505 = Classic Era
	return tocversion >= 20000
end

-- Get the user's preferred expansion filter from saved variables
function InstanceService.GetExpansionFilter()
	return SavedVariables.ExpansionFilter or "classic"
end

-- Set the user's preferred expansion filter
function InstanceService.SetExpansionFilter(filter)
	SavedVariables.ExpansionFilter = filter
end

-- Get the user's preferred difficulty (Normal/Heroic) for TBC dungeons
function InstanceService.GetDifficulty()
	return SavedVariables.Difficulty or "normal"
end

-- Set the user's preferred difficulty
function InstanceService.SetDifficulty(difficulty)
	SavedVariables.Difficulty = difficulty
end

local function ShouldIncludeInstance(instance)
	local activeSeason = C_Seasons.GetActiveSeason()
	local filterType = instance.seasonFilter or "all"
	local isTBC = IsBurningCrusade()
	local userFilter = InstanceService.GetExpansionFilter()

	-- Handle old 'season' field for backward compatibility (classic raids)
	if instance.season ~= nil then
		-- Old season-based filtering (Season of Discovery)
		if instance.season and activeSeason ~= 2 then
			return false
		end
		-- If season = false or nil, treat as classic content
		-- Apply user filter
		if userFilter == "tbc" then
			-- User wants only TBC, skip classic raids with season field
			return false
		end
		-- Otherwise include it (it's classic content)
		return true
	end

	-- First check if content is available for this game client
	-- TBC content can only show on TBC clients
	if filterType == "tbc" and not isTBC then
		return false
	end

	-- Apply user's expansion filter preference
	if userFilter == "classic" then
		-- User wants to see only Classic content
		-- Show "all" and "classic" content, hide "tbc" content
		if filterType == "tbc" then
			return false
		end
	elseif userFilter == "tbc" then
		-- User wants to see only TBC content
		-- Only show content marked as "tbc"
		if filterType ~= "tbc" then
			return false
		end
	end

	-- Handle Season of Discovery filtering
	if filterType == "exclusive" and activeSeason ~= 2 then
		return false
	elseif filterType == "restricted" and activeSeason == 2 then
		return false
	end

	-- If we got here, include the instance
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