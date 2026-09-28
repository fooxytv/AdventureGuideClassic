--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

CreatureModelService = {}

-- Both from data/CreatureModels.lua.
local displaysByEncounter = {}   -- [encounterID] = { creatureDisplayID, ... }
local heightByDisplay = {}       -- [creatureDisplayID] = model height in world units

-- Heights are of the model as the frame renders it, not the size the creature appears in
-- the world: the game multiplies many on spawn and the model frame does not. Hakkar is 2.9
-- units here against 20 in the world, Supremus 4.2 against 66. BASELINE is the knob.
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

function CreatureModelService.GetCameraScale(displayId)
	local height = CreatureModelService.GetHeight(displayId)
	if not height or height <= 0 then return MIN_SCALE end
	local scale = (height / BASELINE_HEIGHT) ^ SCALE_EXPONENT
	if scale < MIN_SCALE then return MIN_SCALE end
	if scale > MAX_SCALE then return MAX_SCALE end
	return scale
end

-- AtlasLoot lists one display per distinct creature while an encounter's npc list also
-- carries the heroic copies, so the two do not line up.
function CreatureModelService.GetDisplayIds(encounterID)
	if not encounterID then return nil end
	local displayIds = displaysByEncounter[encounterID]
	if displayIds and #displayIds > 0 then return displayIds end
	return nil
end

function CreatureModelService.HasModels(encounterID)
	return CreatureModelService.GetDisplayIds(encounterID) ~= nil
end
