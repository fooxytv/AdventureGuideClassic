--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

CreatureModelService = {}

-- [encounterID] = { creatureDisplayID, ... }, from data/CreatureModels.lua.
local displaysByEncounter = {}

function CreatureModelService.Register(data)
	for encounterID, displayIds in pairs(data) do
		displaysByEncounter[encounterID] = displayIds
	end
end

--[[
	The creature display ids to show for an encounter, or nil when we have none.

	Keyed by encounter rather than by npc: AtlasLoot lists one display per
	distinct creature while an encounter's npc list also carries the heroic
	copies of those creatures, so the two do not line up one to one.
]]
function CreatureModelService.GetDisplayIds(encounterID)
	if not encounterID then return nil end
	local displayIds = displaysByEncounter[encounterID]
	if displayIds and #displayIds > 0 then return displayIds end
	return nil
end

function CreatureModelService.HasModels(encounterID)
	return CreatureModelService.GetDisplayIds(encounterID) ~= nil
end
