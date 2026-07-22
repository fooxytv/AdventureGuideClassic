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

--[[
	Titles are keyed by encounter AND display, not by display alone.

	A creature model is often reused: display 6377 is Ebonroc, Firemaw and
	Flamegor, 11561 is all three Dire Maul guards, and 5781 is both Garr and Lord
	Roccor. Naming per display would label every one of them with whichever name
	was saved last. Camera settings are still per display, since the same model
	does want the same framing wherever it appears.
]]
local titles = {}

function ModelPresetService.Register(presets)
	for displayId, preset in pairs(presets) do
		defaults[displayId] = preset
	end
end

function ModelPresetService.RegisterTitles(byEncounter)
	for encounterId, byDisplay in pairs(byEncounter) do
		titles[encounterId] = titles[encounterId] or {}
		for displayId, title in pairs(byDisplay) do
			titles[encounterId][displayId] = title
		end
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
			pitch = saved.pitch or 0,
			modelScale = saved.modelScale or 1,
		}
	end
	return {
		scale = CreatureModelService.GetCameraScale(displayId),
		x = 0, y = 0, z = 0, facing = 0, pitch = 0, modelScale = 1,
	}
end

--[[
	The name to show for a creature, or nil to fall back to the encounter name.

	An encounter that shows several creatures labels them all with the encounter
	name, so Majordomo Executus' three models all read "Majordomo Executus". A
	title override names them individually.
]]
function ModelPresetService.GetTitle(displayId, encounterId)
	if not displayId or not encounterId then return nil end
	local store = Store()
	local saved = store and store.titles and store.titles[encounterId]
	local title = (saved and saved[displayId])
		or (titles[encounterId] and titles[encounterId][displayId])
	if title and title ~= "" then return title end
	return nil
end

function ModelPresetService.SaveTitle(displayId, encounterId, title)
	local store = Store()
	if not store or not displayId or not encounterId then return false end
	store.titles = store.titles or {}
	store.titles[encounterId] = store.titles[encounterId] or {}
	store.titles[encounterId][displayId] = (title and title ~= "") and title or nil
	return true
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
		pitch = (preset.pitch or 0) ~= 0 and preset.pitch or nil,
		modelScale = (preset.modelScale or 1) ~= 1 and preset.modelScale or nil,
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
	if not store then return nil end

	local ids = {}
	for key in pairs(store) do
		-- The store also holds `titles`, keyed by name rather than display id.
		if type(key) == "number" then table.insert(ids, key) end
	end
	table.sort(ids)

	local lines = {}
	if #ids > 0 then
		table.insert(lines, "ModelPresetService.Register({")
		for _, displayId in ipairs(ids) do
			local p = store[displayId]
			local parts = {}
			if p.scale then table.insert(parts, ("scale = %.2f"):format(p.scale)) end
			if p.x then table.insert(parts, ("x = %.2f"):format(p.x)) end
			if p.y then table.insert(parts, ("y = %.2f"):format(p.y)) end
			if p.z then table.insert(parts, ("z = %.2f"):format(p.z)) end
			if p.facing then table.insert(parts, ("facing = %.2f"):format(p.facing)) end
			if p.pitch then table.insert(parts, ("pitch = %.2f"):format(p.pitch)) end
			if p.modelScale then table.insert(parts, ("modelScale = %.2f"):format(p.modelScale)) end
			table.insert(lines, ("\t[%d] = { %s },"):format(displayId, table.concat(parts, ", ")))
		end
		table.insert(lines, "})")
	end

	-- Titles go out as their own call, keyed by encounter, so a model shared by
	-- several bosses keeps a separate name under each of them.
	local encounters = {}
	for encounterId in pairs(store.titles or {}) do table.insert(encounters, encounterId) end
	table.sort(encounters)
	if #encounters > 0 then
		if #lines > 0 then table.insert(lines, "") end
		table.insert(lines, "ModelPresetService.RegisterTitles({")
		for _, encounterId in ipairs(encounters) do
			local displays, parts = {}, {}
			for displayId in pairs(store.titles[encounterId]) do
				table.insert(displays, displayId)
			end
			table.sort(displays)
			for _, displayId in ipairs(displays) do
				table.insert(parts,
					("[%d] = %q"):format(displayId, store.titles[encounterId][displayId]))
			end
			if #parts > 0 then
				table.insert(lines,
					("\t[%d] = { %s },"):format(encounterId, table.concat(parts, ", ")))
			end
		end
		table.insert(lines, "})")
	end

	if #lines == 0 then return nil end
	return table.concat(lines, "\n")
end
