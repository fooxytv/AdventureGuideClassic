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

-- function InstanceService.GetDungeons()
--     local filteredDungeons = { }
--     for i, dungeon in ipairs(dungeons) do
--         if C_Seasons.GetActiveSeason() ~= 2 or (C_Seasons.GetActiveSeason() == 2 and not dungeon.season) then
--             table.insert(filteredDungeons, dungeon)
--         end
--     end
--     return filteredDungeons
-- end

local function ShouldIncludeInstance(instance)
	local activeSeason = C_Seasons.GetActiveSeason()
	local filterType = instance.seasonFilter or "all"
	if filterType == "all" then
		return true
	elseif filterType == "exclusive" and activeSeason == 2 then
		return true
	elseif filterType == "restricted" and activeSeason ~= 2 then
		return true
	end
	return false
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
	for i, raid in ipairs(raids) do
		if raid.season and C_Seasons.GetActiveSeason() == 2 then
			table.insert(filteredRaids, raid)
		elseif not raid.season then
			table.insert(filteredRaids, raid)
		end
	end
	return filteredRaids
end