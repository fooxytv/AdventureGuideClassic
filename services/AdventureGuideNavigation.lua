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
	-- Safe call to C_Seasons (may not exist on all clients)
	local activeSeason = C_Seasons and C_Seasons.GetActiveSeason and C_Seasons.GetActiveSeason() or 0
	local userFilter = InstanceService.GetExpansionFilter and InstanceService.GetExpansionFilter() or nil
	local tocVersion = select(4, GetBuildInfo())
	local isTBC = tocVersion >= 20000
	local isClassicClient = tocVersion < 20000
	local isSoD = isClassicClient and activeSeason == 2
	local isEra = isClassicClient and activeSeason ~= 2
	local difficulty = InstanceService.GetDifficulty and InstanceService.GetDifficulty() or "normal"

	local function ShouldIncludeLootItem(item)
		-- Handle empty tables like {{ }} which have no id
		if not item.id then
			return false
		end

		local filterType = item.seasonFilter or item.filter or "all"
		-- For TBC items, default to "both" difficulties if not specified (so they show in both normal and heroic)
		local itemDifficulty = item.difficulty or "both"

		-- Debug output if enabled
		if AdventureGuideClassic_DebugEvents then
			print("|cffff9900[AGC Filter]|r Item:", item.id, "filterType:", filterType, "isTBC:", tostring(isTBC), "isClassicClient:", tostring(isClassicClient))
		end

		-- Filter logic:
		-- - Dropdown (userFilter) controls which DUNGEONS/INSTANCES to show
		-- - Client type controls which VERSION OF LOOT to show
		--
		-- Filter types:
		-- "all"      - Show on all clients
		-- "classic"  - Show on Classic clients (Era/SoD), hide on TBC
		-- "tbc"      - Show on TBC client, hide on Classic clients
		-- "era"      - Show only on Classic Era (not SoD, not TBC)
		-- "sod"      - Show only on Season of Discovery
		-- "restricted" - Legacy: hide on SoD

		if filterType == "tbc" then
			-- TBC version of loot - only show on TBC client
			if not isTBC then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: tbc loot on non-TBC client")
				end
				return false
			end
		elseif filterType == "classic" then
			-- Classic version of loot - only show on Classic clients (Era or SoD)
			if not isClassicClient then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: classic loot on TBC client")
				end
				return false
			end
		elseif filterType == "sod" or filterType == "exclusive" then
			-- SoD-only items (like runes) - only exist on Season of Discovery
			if not isSoD then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: sod-only item on non-SoD client")
				end
				return false
			end
		elseif filterType == "era" then
			-- Era-only items - only exist on Classic Era (not SoD, not TBC)
			if not isEra then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: era-only item on non-Era client")
				end
				return false
			end
		elseif filterType == "restricted" then
			-- Legacy: Not available on SoD
			if isSoD then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: restricted item on SoD")
				end
				return false
			end
		end
		-- "all" passes through

		-- Apply difficulty filter for TBC content
		if isTBC and filterType == "tbc" then
			if itemDifficulty == "both" then
				-- Item drops in both difficulties
				if AdventureGuideClassic_DebugEvents then
					print("  -> INCLUDED: tbc item with both difficulties")
				end
				return true
			elseif difficulty == "normal" and itemDifficulty ~= "normal" then
				-- User wants normal, but item is not normal
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: heroic-only item on normal difficulty")
				end
				return false
			elseif difficulty == "heroic" and itemDifficulty ~= "heroic" then
				-- User wants heroic, but item is not heroic
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

-- Debug function to diagnose loot filtering issues
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

-- Auto-navigate to current instance when player opens the journal while in a dungeon/raid
-- Returns true if navigation occurred, false otherwise
function AdventureGuideNavigationService.AutoNavigateToCurrentInstance(components)
	local instanceName, instanceType = GetInstanceInfo()

	-- Only proceed if player is in a dungeon ("party") or raid ("raid")
	if instanceType ~= "party" and instanceType ~= "raid" then
		return false
	end

	-- Search dungeons for a match
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

	-- Search raids for a match
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
