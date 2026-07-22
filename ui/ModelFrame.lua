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
end

function component.ApplyPreset(preset)
	if not creatureModel or not preset then return end
	currentPreset = preset
	if preset.title and preset.title ~= "" then
		modelContainer.imageTitle:SetText(preset.title)
	end
	local sized = (preset.modelScale or 1) ~= 1
	if creatureModel.SetModelScale then
		creatureModel:SetModelScale(preset.modelScale or 1)
	end
	if not sized then
		creatureModel:SetPortraitZoom(0)
	end
	baseZoom = preset.scale or 1
	zoom = baseZoom
	creatureModel:SetCamDistanceScale(zoom)
	creatureModel:SetPosition(preset.x or 0, preset.y or 0, preset.z or 0)
	creatureModel:SetFacing(preset.facing or 0)
	if creatureModel.SetPitch then
		creatureModel:SetPitch(preset.pitch or 0)
	end
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
	model:SetScript("OnModelLoaded", function()
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
