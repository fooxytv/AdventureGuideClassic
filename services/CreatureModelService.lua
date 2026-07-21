--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

CreatureModelService = {}

-- Both from data/CreatureModels.lua.
local displaysByEncounter = {}   -- [encounterID] = { creatureDisplayID, ... }
local heightByDisplay = {}       -- [creatureDisplayID] = model height in world units

--[[
	Camera tuning. Creature heights run from about 0.9 (Pusillin) to 66
	(Supremus), so one framing cannot suit every model and the camera is pulled
	back in proportion to height.

	BASELINE is the height that needs no correction -- roughly a humanoid boss.
	The exponent softens the curve: pulling back in strict proportion would leave
	the largest models as specks. The scale is never allowed below 1, so this only
	ever pulls the camera back, and a model that already framed correctly is left
	where it was.

	If everything comes out uniformly too small or too large, BASELINE is the one
	number to change.
]]
local BASELINE_HEIGHT = 3.0
local SCALE_EXPONENT = 0.6
local MIN_SCALE, MAX_SCALE = 1.0, 8.0

function CreatureModelService.Register(data, heights)
	for encounterID, displayIds in pairs(data) do
		displaysByEncounter[encounterID] = displayIds
	end
	if heights then
		for displayId, height in pairs(heights) do
			heightByDisplay[displayId] = height
		end
	end
end

function CreatureModelService.GetHeight(displayId)
	return displayId and heightByDisplay[displayId] or nil
end

--[[
	How far to pull the camera back for a display id, as a SetCamDistanceScale
	value. Returns MIN_SCALE when the height is unknown, which leaves the model
	at whatever framing it already had.
]]
function CreatureModelService.GetCameraScale(displayId)
	local height = CreatureModelService.GetHeight(displayId)
	if not height or height <= 0 then return MIN_SCALE end
	local scale = (height / BASELINE_HEIGHT) ^ SCALE_EXPONENT
	if scale < MIN_SCALE then return MIN_SCALE end
	if scale > MAX_SCALE then return MAX_SCALE end
	return scale
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
