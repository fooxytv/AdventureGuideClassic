--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

ModelPresetService = {}

--[[
	Per-creature camera overrides for the model viewer.

	Height alone gets most models into frame but not all of them: a long serpent
	and a tall giant of the same height need different framing, and some models
	sit well off their own origin. Rather than keep guessing at a formula, this
	lets a preset be dialled in against the real model and saved.

	An override is stored per creature display id and wins over the computed
	default. Anything not overridden keeps using the height-derived camera, so
	saving one preset never disturbs another model.
]]

local function Store()
	if not SavedVariables then return nil end
	SavedVariables.ModelPresets = SavedVariables.ModelPresets or {}
	return SavedVariables.ModelPresets
end

-- Baked-in presets, for values worth shipping rather than leaving in one
-- person's saved variables. Overrides saved in game take precedence.
local defaults = {}

function ModelPresetService.Register(presets)
	for displayId, preset in pairs(presets) do
		defaults[displayId] = preset
	end
end

function ModelPresetService.HasOverride(displayId)
	local store = Store()
	return (store and store[displayId]) ~= nil
end

--[[
	The camera settings for a display id. Never returns nil: an unknown creature
	falls back to the height-derived scale at the model's own origin.
]]
function ModelPresetService.Get(displayId)
	local store = Store()
	local saved = (store and store[displayId]) or defaults[displayId]
	if saved then
		return {
			scale = saved.scale or CreatureModelService.GetCameraScale(displayId),
			x = saved.x or 0,
			y = saved.y or 0,
			z = saved.z or 0,
			facing = saved.facing or 0,
		}
	end
	return {
		scale = CreatureModelService.GetCameraScale(displayId),
		x = 0, y = 0, z = 0, facing = 0,
	}
end

function ModelPresetService.Save(displayId, preset)
	local store = Store()
	if not store or not displayId then return false end
	store[displayId] = {
		scale = preset.scale,
		x = preset.x ~= 0 and preset.x or nil,
		y = preset.y ~= 0 and preset.y or nil,
		z = preset.z ~= 0 and preset.z or nil,
		facing = preset.facing ~= 0 and preset.facing or nil,
	}
	return true
end

function ModelPresetService.Clear(displayId)
	local store = Store()
	if store then store[displayId] = nil end
end

function ModelPresetService.ClearAll()
	local store = Store()
	if store then wipe(store) end
end

--[[
	Every saved override as pasteable Lua, so a preset dialled in on one
	character can be committed to the addon rather than living in SavedVariables.
]]
function ModelPresetService.Export()
	local store = Store()
	if not store or not next(store) then return nil end

	local ids = {}
	for displayId in pairs(store) do table.insert(ids, displayId) end
	table.sort(ids)

	local lines = { "ModelPresetService.Register({" }
	for _, displayId in ipairs(ids) do
		local p = store[displayId]
		local parts = {}
		if p.scale then table.insert(parts, ("scale = %.2f"):format(p.scale)) end
		if p.x then table.insert(parts, ("x = %.2f"):format(p.x)) end
		if p.y then table.insert(parts, ("y = %.2f"):format(p.y)) end
		if p.z then table.insert(parts, ("z = %.2f"):format(p.z)) end
		if p.facing then table.insert(parts, ("facing = %.2f"):format(p.facing)) end
		table.insert(lines, ("\t[%d] = { %s },"):format(displayId, table.concat(parts, ", ")))
	end
	table.insert(lines, "})")
	return table.concat(lines, "\n")
end
