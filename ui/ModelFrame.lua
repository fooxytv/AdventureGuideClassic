--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("ModelFrame")

local components
local modelContainer, creatureModel, currentDisplayId, currentPreset, currentEncounterId
local MIN_ZOOM, MAX_ZOOM, ZOOM_RATE = 0.02, 24.0, 0.12
local ROTATION_SPEED = 0.02
local TILT_SPEED, MAX_TILT = 0.012, 1.2
local PAN_SPEED = 0.02
local baseZoom, zoom = 1.0, 1.0
local BACKGROUND_ALPHA = 0.25

local function PositionScale(displayId)
	local height = displayId and CreatureModelService.GetHeight(displayId)
	if height and height > 6 then return height / 6 end
	return 1
end

local function NotifyTuner()
	if components and components.ModelTuner then
		components.ModelTuner.Refresh()
	end
end

local ENFORCE_SECONDS = 2.0
local enforceUntil = 0

local function EnforcePreset()
	enforceUntil = GetTime() + ENFORCE_SECONDS
end

local function ReleasePreset()
	enforceUntil = 0
end

function component.SetDisplay(displayId, title)
	if not creatureModel or not displayId then return end
	currentDisplayId = displayId
	currentPreset = ModelPresetService.Get(displayId)
	creatureModel:SetDisplayInfo(displayId)
	component.Reframe(currentPreset)
	EnforcePreset()
	local displayTitle = ModelPresetService.GetTitle(displayId, currentEncounterId) or title
	if displayTitle then
		modelContainer.imageTitle:SetText(displayTitle)
	end
	modelContainer.modelDisplayId:SetText(tostring(displayId))
	if components and components.ModelTuner then
		components.ModelTuner.OnDisplayChanged(displayId)
	end
end

--[[
	Everything that frames the model, run both when a display is chosen and again
	once it has loaded, because SetDisplayInfo zeroes the transform.

	The portrait zoom below is only touched on a client with no custom camera, and
	there it is deliberately what it has always been. Where we can aim the camera
	ourselves, AimCamera owns the framing and a portrait zoom would fight it.
]]
--[[
	Aim the camera ourselves rather than asking the client to frame the model.

	AGC_ModelPoke proved this in game. RefreshCamera and SetCamera(0) both mean "go
	back to the automatic camera", and both put the camera inside Skul's head.
	SetCamDistanceScale and SetPortraitZoom are multipliers on that base, so the
	preset's 1.41 showed an empty frame and no amount of repositioning helped -- the
	model was never misplaced, the camera was inside it. A custom camera framed him
	correctly and, alone among everything tried, stayed framed across a reload.
	Blizzard's own Model_ApplyUICamera takes the same route for the same reason.

	Distance is multiplied by the model's height so one preset value means the same
	framing for a gnome and a giant. That is what SetCamDistanceScale used to do for
	us through the automatic camera, so the 80 shipped presets keep roughly what
	they meant.
]]
local CAMERA_DISTANCE_FACTOR = 1.2
local CAMERA_EYE_FACTOR = 0.35
local DEFAULT_HEIGHT = 2

local function CanAimCamera()
	return creatureModel ~= nil
		and type(creatureModel.MakeCurrentCameraCustom) == "function"
		and type(creatureModel.SetCameraPosition) == "function"
		and type(creatureModel.SetCameraTarget) == "function"
end

local function AimCamera(preset)
	if not CanAimCamera() then return false end
	local height = currentDisplayId
		and CreatureModelService.GetHeight(currentDisplayId)
	if not height or height <= 0 then height = DEFAULT_HEIGHT end
	-- z raises the framing, y shifts it sideways, x adds distance. Moving the
	-- camera and its target together pans rather than swings.
	local eye = height * CAMERA_EYE_FACTOR + (preset.z or 0)
	local side = preset.y or 0
	local distance = (preset.scale or 1) * height * CAMERA_DISTANCE_FACTOR
		+ (preset.x or 0)
	creatureModel:MakeCurrentCameraCustom()
	creatureModel:SetCameraPosition(distance, side, eye)
	creatureModel:SetCameraTarget(0, side, eye)
	return true
end

function component.Reframe(preset)
	if not creatureModel or not preset then return end
	currentPreset = preset
	--[[
		Era and BCC reach this, and nothing here may change what they already do.

		So the portrait zoom stays conditional on the preset being unscaled, exactly
		as it was: SetPortraitZoom and SetModelScale frame the model in two different
		ways, and the one scaled preset we ship -- Ragnaros, display 11121, at 3.20 --
		is framed by the scale. Zooming him as well moved him.
	]]
	if not CanAimCamera() then
		if (preset.modelScale or 1) == 1
			and type(creatureModel.SetPortraitZoom) == "function" then
			creatureModel:SetPortraitZoom(preset.portraitZoom or 0)
		end
	end
	component.ApplyPreset(preset)
	-- Reframing lands a frame later and drops the model to the origin, so the preset
	-- goes on again after that has happened as well as before it.
	C_Timer.After(0, function()
		if currentPreset == preset then component.ApplyPreset(preset) end
	end)
end

function component.ApplyPreset(preset)
	if not creatureModel or not preset then return end
	currentPreset = preset
	if preset.title and preset.title ~= "" then
		modelContainer.imageTitle:SetText(preset.title)
	end
	if creatureModel.SetModelScale then
		creatureModel:SetModelScale(preset.modelScale or 1)
	end
	baseZoom = preset.scale or 1
	zoom = baseZoom
	if not AimCamera(preset) then
		-- No custom camera on this client, so the automatic one is all there is.
		creatureModel:SetCamDistanceScale(zoom)
		creatureModel:SetPosition(preset.x or 0, preset.y or 0, preset.z or 0)
	end
	creatureModel:SetFacing(preset.facing or 0)
	if creatureModel.SetPitch then
		creatureModel:SetPitch(preset.pitch or 0)
	end
end

-- Changing the framing from the tuner.
function component.ApplyFraming(value)
	if not currentPreset then return end
	currentPreset.portraitZoom = value or 0
	component.Reframe(currentPreset)
end

function component.GetAppliedModelScale()
	if creatureModel and creatureModel.GetModelScale then
		return creatureModel:GetModelScale()
	end
	return nil
end

function component.SupportsModelScale()
	return creatureModel ~= nil and creatureModel.SetModelScale ~= nil
end

function component.SupportsTilt()
	return creatureModel ~= nil and creatureModel.SetPitch ~= nil
end

local function SetupModelControls(model)
	model:EnableMouse(true)
	model:EnableMouseWheel(true)
	model:SetScript("OnMouseWheel", function(self, delta)
		zoom = math.max(MIN_ZOOM, math.min(MAX_ZOOM, zoom * (1 - delta * ZOOM_RATE)))
		if currentPreset then currentPreset.scale = zoom end
		if not AimCamera(currentPreset) then self:SetCamDistanceScale(zoom) end
		ReleasePreset()
		NotifyTuner()
	end)
	model:SetScript("OnMouseDown", function(self, button)
		local cursorX, cursorY = GetCursorPosition()
		if button == "LeftButton" then self.leftDown = true end
		if button == "RightButton" then self.rightDown = true end
		ReleasePreset()
		if self.leftDown and self.rightDown then
			self.isRotating, self.isTilting = false, false
			self.isPanning = true
			self.panStartX, self.panStartY = cursorX, cursorY
			self.panSide = currentPreset and currentPreset.y or 0
			self.panHeight = currentPreset and currentPreset.z or 0
		elseif button == "LeftButton" then
			self.isRotating = true
			self.rotateStartX = cursorX
			self.rotateStartFacing = self:GetFacing()
		elseif button == "RightButton" and component.SupportsTilt() then
			self.isTilting = true
			self.tiltStartY = cursorY
			self.tiltStartPitch = currentPreset and currentPreset.pitch or 0
		end
	end)
	model:SetScript("OnHide", function(self)
		self.isRotating = false
		self.isTilting = false
	end)
	model:SetScript("OnModelLoaded", function()
		-- SetDisplayInfo zeroes the transform and this fires after it, so the preset
		-- has to go on again here, not only when the display is chosen.
		if currentPreset then component.Reframe(currentPreset) end
	end)
	model:SetScript("OnUpdate", function(self)
		if enforceUntil > 0 and currentPreset then
			if GetTime() < enforceUntil then
				component.ApplyPreset(currentPreset)
			else
				enforceUntil = 0
			end
		end
		if self.isPanning and currentPreset then
			local cursorX, cursorY = GetCursorPosition()
			local speed = PAN_SPEED * PositionScale(currentDisplayId)
			currentPreset.y = self.panSide - (cursorX - self.panStartX) * speed
			currentPreset.z = self.panHeight + (cursorY - self.panStartY) * speed
			if not AimCamera(currentPreset) then
				self:SetPosition(currentPreset.x or 0, currentPreset.y, currentPreset.z)
			end
		elseif self.isRotating then
			local x = GetCursorPosition()
			local facing = self.rotateStartFacing + (x - self.rotateStartX) * ROTATION_SPEED
			self:SetFacing(facing)
			if currentPreset then currentPreset.facing = facing end
		elseif self.isTilting then
			local _, y = GetCursorPosition()
			local pitch = self.tiltStartPitch + (y - self.tiltStartY) * TILT_SPEED
			pitch = math.max(-MAX_TILT, math.min(MAX_TILT, pitch))
			if currentPreset then currentPreset.pitch = pitch end
			self:SetPitch(pitch)
		end
	end)
	model:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then self.leftDown = false end
		if button == "RightButton" then self.rightDown = false end
		if not (self.leftDown and self.rightDown) then self.isPanning = false end
		if not self.leftDown then self.isRotating = false end
		if not self.rightDown then self.isTilting = false end
		NotifyTuner()
	end)
end

function component.GetDisplay()
	return currentDisplayId
end

function component.GetEncounterId()
	return currentEncounterId
end

function component.GetEncounterName()
	local encounter = AdventureGuideNavigationService.GetEncounter()
	return encounter and encounter.name or nil
end

function component.GetPreset()
	return currentPreset
end

--[[
	What the preset asks for next to what the model reports back, so a setting that
	is saved correctly but does not take can be told apart from one that never
	arrived. See CLAUDE.md.
]]
_G.AGC_ModelDump = function()
	if not creatureModel then
		print("|cffff5555[AGC]|r no model frame; open a boss on the Model tab")
		return
	end
	local function ask(name, ...)
		local fn = creatureModel[name]
		if type(fn) ~= "function" then return "unsupported" end
		local ok, a, b, c = pcall(fn, creatureModel, ...)
		if not ok then return "error" end
		if b ~= nil then
			return ("%.3f, %.3f, %.3f"):format(a or 0, b or 0, c or 0)
		end
		return a ~= nil and tostring(a) or "nil"
	end
	local p = currentPreset or {}
	print(("|cff00ff00[AGC]|r display %s, saved override: %s, enforcing: %s")
		:format(tostring(currentDisplayId),
			tostring(currentDisplayId and ModelPresetService.HasOverride(currentDisplayId)),
			tostring(enforceUntil > GetTime())))
	print(("  preset   scale %.2f  pos %.2f/%.2f/%.2f  facing %.2f  pitch %.2f  size %.2f  framing %.2f")
		:format(p.scale or 0, p.x or 0, p.y or 0, p.z or 0, p.facing or 0,
			p.pitch or 0, p.modelScale or 1, p.portraitZoom or 0))
	print(("  model    facing %s  size %s  position %s")
		:format(ask("GetFacing"), ask("GetModelScale"), ask("GetPosition")))
	print(("  zoom     baseZoom %.2f  zoom %.2f  aiming the camera ourselves: %s")
		:format(baseZoom or 0, zoom or 0, tostring(CanAimCamera())))
	print(("  camera   pos %s  target %s  distance %s")
		:format(ask("GetCameraPosition"), ask("GetCameraTarget"),
			ask("GetCameraDistance")))
	print(("  camera   custom %s  transforms about model centre %s")
		:format(ask("HasCustomCamera"), ask("IsUsingModelCenterToTransform")))
	--[[
		What is stored for this display, read fresh. If this disagrees with the
		preset line then the saved values are not reaching the model; if it agrees
		and the model line does not, the client is refusing the calls.
	]]
	local stored = currentDisplayId and ModelPresetService.Get(currentDisplayId)
	if stored then
		print(("  stored   scale %.2f  pos %.2f/%.2f/%.2f  facing %.2f  pitch %.2f  size %.2f  framing %.2f")
			:format(stored.scale or 0, stored.x or 0, stored.y or 0, stored.z or 0,
				stored.facing or 0, stored.pitch or 0, stored.modelScale or 1,
				stored.portraitZoom or 0))
	end
end

--[[
	Step the model through one camera call at a time and watch which one moves it.

	Position is not the problem and the log says so: with debug on, the samples hold
	the preset's values steady for four seconds while the model is not on screen at
	all. That leaves the camera, and its getters cannot be trusted here --
	GetCameraDistance reads -1.8e-32 while the camera is plainly 2.5 units from its
	target. So rather than read state, this drives each control in turn and prints
	what it just did. The answer is which number the model appears on.
]]
_G.AGC_ModelPoke = function()
	if not creatureModel then
		print("|cffff5555[AGC]|r no model frame; open a boss on the Model tab")
		return
	end
	-- Otherwise the enforcement window reapplies the preset over every step.
	ReleasePreset()
	-- Long enough to look at the model and read the label under it.
	local STEP_SECONDS = 2.5
	--[[
		Each step photographs itself. The label under the model names the step, so
		the files identify themselves and arrive in order, which beats trying to
		catch the right moment by hand across a dozen of them.
	]]
	local SHOT_DELAY = 0.6
	local function Capture()
		if type(Screenshot) == "function" then Screenshot() end
	end
	local m = creatureModel
	local function has(name) return type(m[name]) == "function" end
	local steps = {
		{ "cam distance scale 1", function() m:SetCamDistanceScale(1) end },
		{ "cam distance scale 2", function() m:SetCamDistanceScale(2) end },
		{ "cam distance scale 4", function() m:SetCamDistanceScale(4) end },
		{ "portrait zoom 0", function()
			if not has("SetPortraitZoom") then return "unsupported" end
			m:SetPortraitZoom(0)
		end },
		{ "portrait zoom 0.5", function()
			if not has("SetPortraitZoom") then return "unsupported" end
			m:SetPortraitZoom(0.5)
		end },
		{ "portrait zoom 1", function()
			if not has("SetPortraitZoom") then return "unsupported" end
			m:SetPortraitZoom(1)
		end },
		{ "position 0/0/0", function() m:SetPosition(0, 0, 0) end },
		{ "RefreshCamera", function()
			if not has("RefreshCamera") then return "unsupported" end
			m:RefreshCamera()
		end },
		{ "SetCamera(0)", function()
			if not has("SetCamera") then return "unsupported" end
			m:SetCamera(0)
		end },
		{ "custom camera 4/0/0 -> 0/0/0", function()
			if not (has("MakeCurrentCameraCustom") and has("SetCameraPosition")) then
				return "unsupported"
			end
			m:MakeCurrentCameraCustom()
			m:SetCameraPosition(4, 0, 0)
			m:SetCameraTarget(0, 0, 0)
		end },
		{ "custom camera 8/0/1 -> 0/0/1", function()
			if not has("SetCameraPosition") then return "unsupported" end
			m:SetCameraPosition(8, 0, 1)
			m:SetCameraTarget(0, 0, 1)
		end },
		--[[
			The candidate fix. Blizzard's own Model_ApplyUICamera makes the camera
			custom before aiming it, because an automatic camera is the engine's to
			recompute whenever the model changes. Aimed from the preset's scale and
			the model's recorded height so it means the same thing for every
			creature, rather than from bounds that are not known until the geometry
			has streamed in.
		]]
		{ "candidate: custom camera from preset scale and model height", function()
			if not (has("MakeCurrentCameraCustom") and has("SetCameraPosition")) then
				return "unsupported"
			end
			local preset = currentPreset or { }
			local height = (currentDisplayId
				and CreatureModelService.GetHeight(currentDisplayId)) or 2
			local eye = height / 2
			local distance = 2.5 * (preset.scale or 1)
			m:SetPosition(0, 0, 0)
			m:MakeCurrentCameraCustom()
			m:SetCameraPosition(distance, 0, eye)
			m:SetCameraTarget(0, 0, eye)
			return ("height %.2f, eye %.2f, distance %.2f"):format(height, eye, distance)
		end },
	}
	local restoreTitle = modelContainer.imageTitle:GetText()
	print(("|cff00ff00[AGC]|r poking display %s -- the step shows under the model")
		:format(tostring(currentDisplayId)))
	for index, step in ipairs(steps) do
		C_Timer.After(index * STEP_SECONDS, function()
			if not creatureModel then return end
			local note = step[2]()
			modelContainer.imageTitle:SetText(("%d  %s"):format(index, step[1]))
			print(("|cffff9900[AGC]|r %2d  %s%s")
				:format(index, step[1], note and (" -- " .. note) or ""))
			-- A beat for the change to reach the screen before capturing it.
			C_Timer.After(SHOT_DELAY, Capture)
		end)
	end
	C_Timer.After((#steps + 1) * STEP_SECONDS, function()
		if currentPreset then component.Reframe(currentPreset) end
		modelContainer.imageTitle:SetText(("%d  preset restored"):format(#steps + 1))
		print("|cff00ff00[AGC]|r poke done, preset restored")
		C_Timer.After(SHOT_DELAY, function()
			Capture()
			modelContainer.imageTitle:SetText(restoreTitle or "")
		end)
	end)
end

function component.Init(components_)
	components = components_
	local model = CreateFrame("Frame", nil, EncounterJournal.encounter.info)
	modelContainer = model
	EncounterJournal.encounter.info.model = model
	model:SetSize(390, 423)
	model:SetPoint("BOTTOMRIGHT", -3, 1)
	model:Hide()
	model.dungeonBG = model:CreateTexture()
	model.dungeonBG:SetDrawLayer("BACKGROUND", 1)
	model.dungeonBG:SetSize(394, 425)
	model.dungeonBG:SetPoint("BOTTOMLEFT", 0, -2)
	model.dungeonBG:SetTexCoord(0.76953125, 0, 0, 0.830078125)
	model.dungeonBG:SetAlpha(BACKGROUND_ALPHA)
	creatureModel = CreateFrame("PlayerModel", nil, model)
	creatureModel:SetPoint("TOPLEFT", 8, -8)
	creatureModel:SetPoint("BOTTOMRIGHT", -8, 8)
	creatureModel:SetFrameLevel(model:GetFrameLevel() + 1)
	SetupModelControls(creatureModel)
	local overlay = CreateFrame("Frame", nil, model)
	overlay:SetAllPoints()
	overlay:SetFrameLevel(model:GetFrameLevel() + 6)
	model.overlay = overlay
	local shadow = overlay:CreateTexture(nil, "OVERLAY")
	shadow:SetTexture("Interface/EncounterJournal/UI-EJ-BossModelPaperFrame")
	shadow:SetSize(393, 424)
	shadow:SetPoint("BOTTOMRIGHT", 3, 0)
	shadow:SetTexCoord(0.767578125, 0, 0, 0.828125)
	local titleBG = overlay:CreateTexture()
	titleBG:SetSize(395, 63)
	titleBG:SetDrawLayer("OVERLAY", 1)
	titleBG:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
	titleBG:SetTexCoord(0.00195313, 0.77343750, 0.26953125, 0.33105469)
	titleBG:SetPoint("BOTTOM", 0, 0)
	model.imageTitle = overlay:CreateFontString()
	model.imageTitle:SetDrawLayer("OVERLAY", 2)
	model.imageTitle:SetFontObject("QuestTitleFontBlackShadow")
	model.imageTitle:SetJustifyH("CENTER")
	model.imageTitle:SetSize(380, 10)
	model.imageTitle:SetPoint("BOTTOM", 0, 6)
	model.modelDisplayIdLabel = overlay:CreateFontString()
	model.modelDisplayIdLabel:SetDrawLayer("OVERLAY", 2)
	model.modelDisplayIdLabel:SetFontObject("GameFontNormalSmall")
	model.modelDisplayIdLabel:SetJustifyH("LEFT")
	model.modelDisplayIdLabel:SetSize(60, 0)
	model.modelDisplayIdLabel:SetPoint("BOTTOMLEFT", model.imageTitle, "TOPLEFT", 30, 6)
	model.modelDisplayIdLabel:SetText("Display ID:")
	model.modelDisplayIdLabel:Hide()
	model.modelDisplayId = overlay:CreateFontString()
	model.modelDisplayId:SetDrawLayer("OVERLAY", 2)
	model.modelDisplayId:SetFontObject("GameFontHighlightSmall")
	model.modelDisplayId:SetJustifyH("LEFT")
	model.modelDisplayId:SetWordWrap(true)
	model.modelDisplayId:SetSize(320, 0)
	model.modelDisplayId:SetPoint("LEFT", model.modelDisplayIdLabel, "RIGHT", 2, 0)
	model.modelDisplayId:Hide()
	EncounterJournal.encounter.info.imageTitle = model.imageTitle
	model:SetScript("OnShow", function()
		local info = EncounterJournal.encounter.info
		if info.encounterTitle then info.encounterTitle:Hide() end
		if info.rightShadow then info.rightShadow:Hide() end
		if info.difficultyDropdown then info.difficultyDropdown:Hide() end
	end)
	model:SetScript("OnHide", function()
		local info = EncounterJournal.encounter.info
		if info.encounterTitle then info.encounterTitle:Show() end
		if info.rightShadow then info.rightShadow:Show() end
	end)
end

function component.Show()
	local encounter = AdventureGuideNavigationService.GetEncounter()
	if not encounter then return false end
	local displayIds = CreatureModelService.GetDisplayIds(encounter.encounterID)
	if not displayIds then return false end
	currentEncounterId = encounter.encounterID
	local instance = AdventureGuideNavigationService.GetInstance()
	modelContainer.dungeonBG:SetTexture((instance and instance.splash)
		or "Interface\\EncounterJournal\\UI-EJ-BACKGROUND-Default")

	-- Through the service, not encounter.name: this caption and the creature
	-- tooltips are two more places the discovery mode must not reveal a boss.
	local shownName = AdventureGuideNavigationService.GetEncounterName()
	components.CreatureButtons.SetCreatures(displayIds, shownName)
	component.SetDisplay(displayIds[1], shownName)
	components.EncounterFrame.SetCurrentView(modelContainer)
	return true
end

UI.Add(component)
