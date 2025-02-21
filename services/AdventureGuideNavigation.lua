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
	local activeSeason = C_Seasons.GetActiveSeason()
	local function ShouldIncludeLootItem(item)
		local filterType = item.seasonFilter or "all"
		if filterType == "all" then
			return true
		elseif filterType == "exclusive" and activeSeason == 2 then
			return true
		elseif filterType == "restricted" and activeSeason ~= 2 then
			return true
		end
		return false
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
