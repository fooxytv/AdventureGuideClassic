--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local instance
local instances
local encounter

AdventureGuideNavigationService = { }

function AdventureGuideNavigationService.Reset()
	instance = nil
	instances = nil
	encounter = nil
end

function AdventureGuideNavigationService.GetEncounter()
	return encounter
end

function AdventureGuideNavigationService.GetEncounterName()
    return encounter and encounter.name or "Unknown Encounter"
end

function AdventureGuideNavigationService.GetEncounterContent()
	return encounter.overview or { }
end

function AdventureGuideNavigationService.GetEncounterLoot()
	local activeSeason = C_Seasons and C_Seasons.GetActiveSeason and C_Seasons.GetActiveSeason() or 0
	local userFilter = InstanceService.GetExpansionFilter and InstanceService.GetExpansionFilter() or nil
	local tocVersion = select(4, GetBuildInfo())
	local isTBC = tocVersion >= 20000
	local isClassicClient = tocVersion < 20000
	local isSoD = isClassicClient and activeSeason == 2
	local isEra = isClassicClient and activeSeason ~= 2
	local difficulty = InstanceService.GetDifficulty and InstanceService.GetDifficulty() or "normal"
	local function ShouldIncludeLootItem(item)
		if not item.id then
			return false
		end
		local filterType = item.seasonFilter or item.filter or "all"
		local itemDifficulty = item.difficulty or "both"
		if AdventureGuideClassic_DebugEvents then
			print("|cffff9900[AGC Filter]|r Item:", item.id, "filterType:", filterType, "isTBC:", tostring(isTBC), "isClassicClient:", tostring(isClassicClient))
		end
		if filterType == "tbc" then
			if not isTBC then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: tbc loot on non-TBC client")
				end
				return false
			end
		elseif filterType == "classic" then
			if not isClassicClient then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: classic loot on TBC client")
				end
				return false
			end
		elseif filterType == "sod" or filterType == "exclusive" then
			if not isSoD then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: sod-only item on non-SoD client")
				end
				return false
			end
		elseif filterType == "era" then
			if not isEra then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: era-only item on non-Era client")
				end
				return false
			end
		elseif filterType == "restricted" then
			if isSoD then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: restricted item on SoD")
				end
				return false
			end
		end
		if isTBC and filterType == "tbc" then
			if itemDifficulty == "both" then
				if AdventureGuideClassic_DebugEvents then
					print("  -> INCLUDED: tbc item with both difficulties")
				end
				return true
			elseif difficulty == "normal" and itemDifficulty ~= "normal" then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: heroic-only item on normal difficulty")
				end
				return false
			elseif difficulty == "heroic" and itemDifficulty ~= "heroic" then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: normal-only item on heroic difficulty")
				end
				return false
			end
		end

		if AdventureGuideClassic_DebugEvents then
			print("  -> INCLUDED")
		end
		return true
	end
	local function FilterLoot(lootTable)
		local filteredLoot = {}
		for _, item in ipairs(lootTable or {}) do
			if ShouldIncludeLootItem(item) then
				table.insert(filteredLoot, item.id)
			end
		end
		return filteredLoot
	end
	return {
		loot = FilterLoot(encounter and encounter.loot),
		sharedLoot = FilterLoot(encounter and encounter.sharedLoot),
		rareLoot = FilterLoot(encounter and encounter.rareLoot),
		veryRareLoot = FilterLoot(encounter and encounter.veryRareLoot),
		extremelyRareLoot = FilterLoot(encounter and encounter.extremelyRareLoot)
	}
end

function AdventureGuideNavigationService.GetInstance()
	return instance
end

function AdventureGuideNavigationService.GetInstances()
	return instances
end

function AdventureGuideNavigationService.SetEncounter(ref)
	encounter = ref
end

function AdventureGuideNavigationService.SetInstance(ref)
	instance = ref
end

function AdventureGuideNavigationService.SetInstances(ref)
	instances = ref
end

-- Usage: /run AGC_DebugLootFilter()
_G.AGC_DebugLootFilter = function()
	local activeSeason = C_Seasons and C_Seasons.GetActiveSeason and C_Seasons.GetActiveSeason() or 0
	local userFilter = InstanceService.GetExpansionFilter and InstanceService.GetExpansionFilter() or "none"
	local tocVersion = select(4, GetBuildInfo())
	local isTBC = tocVersion >= 20000
	local isClassicClient = tocVersion < 20000
	local isSoD = isClassicClient and activeSeason == 2
	local isEra = isClassicClient and activeSeason ~= 2
	local difficulty = InstanceService.GetDifficulty and InstanceService.GetDifficulty() or "normal"
	print("|cffff9900[AGC Loot Debug]|r")
	print("  TOC Version:", tocVersion)
	print("  isTBC:", tostring(isTBC))
	print("  isClassicClient:", tostring(isClassicClient))
	print("  activeSeason:", tostring(activeSeason))
	print("  isSoD:", tostring(isSoD))
	print("  isEra:", tostring(isEra))
	print("  userFilter:", tostring(userFilter))
	print("  difficulty:", tostring(difficulty))
	if encounter then
		print("  Current encounter:", encounter.name or "Unknown")
		if encounter.loot then
			print("  Loot items:")
			for i, item in ipairs(encounter.loot) do
				local filterType = item.seasonFilter or item.filter or "all"
				local itemDifficulty = item.difficulty or "both"
				print("    ", i, "- ID:", item.id, "filter:", filterType, "difficulty:", itemDifficulty)
			end
		end
	else
		print("  No encounter selected")
	end
end

function AdventureGuideNavigationService.AutoNavigateToCurrentInstance(components)
	local instanceName, instanceType = GetInstanceInfo()
	if instanceType ~= "party" and instanceType ~= "raid" then
		return false
	end
	local dungeons = InstanceService.GetDungeons()
	for _, dungeon in ipairs(dungeons) do
		if dungeon.name == instanceName then
			AdventureGuideNavigationService.SetInstance(dungeon)
			if components and components.EncounterFrame then
				components.EncounterFrame.ShowInstanceInfo(dungeon)
			end
			return true
		end
	end
	local raids = InstanceService.GetRaids()
	for _, raid in ipairs(raids) do
		if raid.name == instanceName then
			AdventureGuideNavigationService.SetInstance(raid)
			if components and components.EncounterFrame then
				components.EncounterFrame.ShowInstanceInfo(raid)
			end
			return true
		end
	end

	return false
end
