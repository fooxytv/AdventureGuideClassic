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
local lastSetDisplayAt

local function EnforcePreset()
	enforceUntil = GetTime() + ENFORCE_SECONDS
end

local function ReleasePreset()
	enforceUntil = 0
end

function component.SetDisplay(displayId, title)
	if not creatureModel or not displayId then return end
	currentDisplayId = displayId
	lastSetDisplayAt = GetTime()
	currentPreset = ModelPresetService.Get(displayId)
	creatureModel:SetDisplayInfo(displayId)
	--[[
		Once per display, before anything is positioned, and never from ApplyPreset.
		SetPortraitZoom reframes the camera and drops the model back to the origin,
		and it does so a frame later -- so calling it on every apply undid the
		SetPosition that followed it. Dragging looked right because it sets the
		position directly without going through here.
	]]
	if type(creatureModel.SetPortraitZoom) == "function" then
		creatureModel:SetPortraitZoom(currentPreset.portraitZoom or 0)
	end
	component.ApplyPreset(currentPreset)
	EnforcePreset()
	local displayTitle = ModelPresetService.GetTitle(displayId, currentEncounterId) or title
	if displayTitle then
		modelContainer.imageTitle:SetText(displayTitle)
	end
	modelContainer.modelDisplayId:SetText(tostring(displayId))
	if components and components.ModelTuner then
		components.ModelTuner.OnDisplayChanged(displayId)
	end
	--[[
		With debug on, report the model twice per display change: once now, and once
		after the enforcement window has closed and any late load has landed. Reading
		it by hand needs the command run in the half-second it goes wrong, which is
		how three captures in a row came from the wrong moment.
	]]
	if AdventureGuideClassic_DebugEvents then
		--[[
			Sample the position repeatedly rather than once. A single snapshot cannot
			show a reset that lands after it, which is the one thing none of the
			readings so far could have caught.
		]]
		local want = currentPreset
		for _, delay in ipairs({ 0, 0.1, 0.3, 0.6, 1.0, 2.5, 4.0 }) do
			C_Timer.After(delay, function()
				if currentDisplayId ~= displayId or not creatureModel then return end
				local ok, x, y, z = pcall(creatureModel.GetPosition, creatureModel)
				local okf, facing = pcall(creatureModel.GetFacing, creatureModel)
				print(("|cffff9900[AGC]|r t+%.1fs  model %s  facing %s  want %.2f/%.2f/%.2f  enforcing %s")
					:format(delay,
						ok and ("%.3f/%.3f/%.3f"):format(x or 0, y or 0, z or 0) or "unreadable",
						okf and ("%.3f"):format(facing or 0) or "?",
						want.x or 0, want.y or 0, want.z or 0,
						tostring(enforceUntil > GetTime())))
			end)
		end
	end
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
	--[[
		Portrait zoom is camera state on a frame reused for every creature, and
		SetDisplayInfo resets it. Setting it only for unscaled models left a scaled
		one showing with whatever the previous creature happened to leave behind, so
		the same preset framed differently depending on what you looked at before --
		and with a height offset that put the model outside the frame entirely.
	]]
	baseZoom = preset.scale or 1
	zoom = baseZoom
	creatureModel:SetCamDistanceScale(zoom)
	creatureModel:SetPosition(preset.x or 0, preset.y or 0, preset.z or 0)
	creatureModel:SetFacing(preset.facing or 0)
	if creatureModel.SetPitch then
		creatureModel:SetPitch(preset.pitch or 0)
	end
end

--[[
	Changing the framing from the tuner. Reframing drops the model to the origin a
	frame later, so the preset goes back on after that has happened rather than
	before it, which is the whole reason this is not part of ApplyPreset.
]]
function component.ApplyFraming(value)
	if not creatureModel or type(creatureModel.SetPortraitZoom) ~= "function" then
		return
	end
	creatureModel:SetPortraitZoom(value or 0)
	C_Timer.After(0, function()
		if currentPreset then component.ApplyPreset(currentPreset) end
	end)
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
		self:SetCamDistanceScale(zoom)
		if currentPreset then currentPreset.scale = zoom end
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
	model:SetScript("OnModelLoaded", function(self)
		if AdventureGuideClassic_DebugEvents then
			local ok, x, y, z = pcall(self.GetPosition, self)
			print(("|cffff9900[AGC]|r OnModelLoaded fired %.2fs after SetDisplay, position %s")
				:format(GetTime() - (lastSetDisplayAt or GetTime()),
					ok and ("%.3f/%.3f/%.3f"):format(x or 0, y or 0, z or 0) or "unreadable"))
		end
		if currentPreset then component.ApplyPreset(currentPreset) end
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
			self:SetPosition(currentPreset.x or 0, currentPreset.y, currentPreset.z)
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

-- What the model reports right now, for comparing against what a save is about to
-- write. Also whether the caller's table is the one driving the model.
function component.DescribeLive(theirPreset)
	if not creatureModel then return "no model" end
	local ok, x, y, z = pcall(creatureModel.GetPosition, creatureModel)
	return ("model %s, same table as preset: %s"):format(
		ok and ("%.2f/%.2f/%.2f"):format(x or 0, y or 0, z or 0) or "unreadable",
		tostring(theirPreset == currentPreset))
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
	print(("  zoom     baseZoom %.2f  zoom %.2f"):format(baseZoom or 0, zoom or 0))
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

	components.CreatureButtons.SetCreatures(displayIds, encounter.name)
	component.SetDisplay(displayIds[1], encounter.name)
	components.EncounterFrame.SetCurrentView(modelContainer)
	return true
end

UI.Add(component)
