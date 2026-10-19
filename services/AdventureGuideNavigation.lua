--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
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

--[[
	Whether a boss may be shown in full, for the discovery mode. Lives here because
	every gated accessor needs the instance the boss belongs to, and this file is
	what knows which instance is selected.
]]
function AdventureGuideNavigationService.IsEncounterDiscovered(forEncounter)
	local target = forEncounter or encounter
	if not target then return true end
	return DiscoveryService.IsDiscovered(instance and instance.name, target)
end

--[[
	Gated like every other accessor here, and for a reason Copilot spotted: the list
	draws ??? over an undiscovered boss, but this feeds the detail title, the nav-bar
	breadcrumb, the model's caption and the creature tooltips. Ungated, clicking a ???
	printed the real name in four places at once.
]]
function AdventureGuideNavigationService.GetEncounterName(forEncounter)
	local target = forEncounter or encounter
	if not target then return "Unknown Encounter" end
	if not AdventureGuideNavigationService.IsEncounterDiscovered(target) then
		return DiscoveryService.UNKNOWN_NAME
	end
	return target.name or "Unknown Encounter"
end

--[[
	The selected boss's abilities, or another boss's if one is passed -- the same
	optional-argument convention as GetEncounterLoot.

	Empty rather than nil when there is no encounter or none were recorded, so a
	caller can ask `#... > 0` without first checking both. 240 of the 389 encounters
	in the data have none yet, so that is the common case, not the edge one.
]]
function AdventureGuideNavigationService.GetEncounterAbilities(forEncounter)
	local target = forEncounter or encounter
	if not AdventureGuideNavigationService.IsEncounterDiscovered(target) then
		return { }
	end
	return target and target.abilities or { }
end

function AdventureGuideNavigationService.GetEncounterContent()
	if not AdventureGuideNavigationService.IsEncounterDiscovered(encounter) then
		return { "You have not faced this foe yet. Defeat it to record what it does here." }
	end
	return encounter.overview or { }
end

--[[
	Loot for an encounter, season/difficulty filtering already applied. Defaults to the
	selected encounter; pass one explicitly to read another boss's table, which is how
	the pinned-loot filter gathers a whole instance's picks without navigating to each
	boss in turn.
]]
function AdventureGuideNavigationService.GetEncounterLoot(forEncounter)
	local target = forEncounter or encounter
	if not AdventureGuideNavigationService.IsEncounterDiscovered(target) then
		return { loot = { }, sharedLoot = { }, rareLoot = { },
			veryRareLoot = { }, extremelyRareLoot = { } }
	end
	local userFilter = InstanceService.GetExpansionFilter and InstanceService.GetExpansionFilter() or nil
	local isTBC = Compat.isTBC
	local isClassicClient = Compat.isVanillaLoot
	local isSoD = Compat.IsSoD()
	local isEra = isClassicClient and not isSoD
	local isForever = Compat.isForever
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
		elseif filterType == "forever" then
			if not isForever then
				if AdventureGuideClassic_DebugEvents then
					print("  -> FILTERED: forever-only item on non-Forever client")
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
		loot = FilterLoot(target and target.loot),
		sharedLoot = FilterLoot(target and target.sharedLoot),
		rareLoot = FilterLoot(target and target.rareLoot),
		veryRareLoot = FilterLoot(target and target.veryRareLoot),
		extremelyRareLoot = FilterLoot(target and target.extremelyRareLoot)
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

_G.AGC_DebugLootFilter = function()
	local activeSeason = Compat.GetActiveSeason()
	local userFilter = InstanceService.GetExpansionFilter and InstanceService.GetExpansionFilter() or "none"
	local isTBC = Compat.isTBC
	local isClassicClient = Compat.isVanillaLoot
	local isSoD = Compat.IsSoD()
	local isEra = isClassicClient and not isSoD
	local difficulty = InstanceService.GetDifficulty and InstanceService.GetDifficulty() or "normal"
	print("|cffff9900[AGC Loot Debug]|r")
	print("  Client:", Compat.flavor, "(toc " .. tostring(Compat.tocVersion) .. ")")
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
