--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("ModelFrame")

local components
local modelContainer, creatureModel, currentDisplayId

-- The wheel adjusts the camera around whatever preset the creature's size gives
-- it, so the bounds are relative to that rather than absolute.
local MIN_ZOOM_FACTOR, MAX_ZOOM_FACTOR, ZOOM_STEP = 0.35, 3.0, 0.12
local ROTATION_SPEED = 0.02
local baseZoom, zoom = 1.0, 1.0

--[[
	Shows a creature by its display id.

	PlayerModel/SetDisplayInfo is what AtlasLoot uses on these clients; a
	ModelScene actor would need the retail uiModelSceneID, which carries the
	camera framing and only comes from real EJ data we do not have.

	SetPortraitZoom(0) frames the creature against its own bounds rather than its
	native camera, and on top of that the camera is pulled back in proportion to
	the model's real height, which CreatureModelService knows from the game's own
	model data. Without that the big ones -- Supremus, Ragnaros, the Lurker Below
	-- overflow the frame, since creature heights span roughly 0.9 to 66.
]]
function component.SetDisplay(displayId, title)
	if not creatureModel or not displayId then return end
	currentDisplayId = displayId
	baseZoom = CreatureModelService.GetCameraScale(displayId)
	zoom = baseZoom
	creatureModel:SetDisplayInfo(displayId)
	creatureModel:SetPortraitZoom(0)
	creatureModel:SetCamDistanceScale(zoom)
	creatureModel:SetPosition(0, 0, 0)
	creatureModel:SetFacing(0)
	if title then
		modelContainer.imageTitle:SetText(title)
	end
	modelContainer.modelDisplayId:SetText(tostring(displayId))
end

-- Creature sizes vary far too much for one framing to suit all of them, so the
-- wheel zooms and dragging turns the model, as the dressing room does.
local function SetupModelControls(model)
	model:EnableMouse(true)
	model:EnableMouseWheel(true)
	model:SetScript("OnMouseWheel", function(self, delta)
		local step = baseZoom * ZOOM_STEP
		zoom = math.max(baseZoom * MIN_ZOOM_FACTOR,
			math.min(baseZoom * MAX_ZOOM_FACTOR, zoom - delta * step))
		self:SetCamDistanceScale(zoom)
	end)
	model:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			self.isRotating = true
			self.rotateStartX = GetCursorPosition()
			self.rotateStartFacing = self:GetFacing()
		end
	end)
	model:SetScript("OnMouseUp", function(self)
		self.isRotating = false
	end)
	model:SetScript("OnHide", function(self)
		self.isRotating = false
	end)
	-- The camera can be set before the model has finished streaming in, which
	-- leaves the framing at the creature's native scale. Re-apply once it lands.
	model:SetScript("OnModelLoaded", function(self)
		self:SetPortraitZoom(0)
		self:SetCamDistanceScale(zoom)
		self:SetPosition(0, 0, 0)
	end)
	model:SetScript("OnUpdate", function(self)
		if not self.isRotating then return end
		local x = GetCursorPosition()
		self:SetFacing(self.rotateStartFacing + (x - self.rotateStartX) * ROTATION_SPEED)
	end)
end

function component.GetDisplay()
	return currentDisplayId
end

function component.Init(components_)
	components = components_
	-- A plain frame holds the art; the model is a child so the paper frame and
	-- title can be layered over it rather than behind it.
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

	creatureModel = CreateFrame("PlayerModel", nil, model)
	creatureModel:SetPoint("TOPLEFT", 8, -8)
	creatureModel:SetPoint("BOTTOMRIGHT", -8, 8)
	creatureModel:SetFrameLevel(model:GetFrameLevel() + 1)
	SetupModelControls(creatureModel)

	-- Everything from here on sits above the model.
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

	-- Ported from the XML this frame used to carry: the model takes over the
	-- panel, so the encounter heading and its shadow would otherwise show through.
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

--[[
	Displays the creatures for the current encounter. Returns false when we have
	no display ids for it, so the caller can leave the tab alone rather than
	swapping to an empty frame.
]]
function component.Show()
	local encounter = AdventureGuideNavigationService.GetEncounter()
	if not encounter then return false end
	local displayIds = CreatureModelService.GetDisplayIds(encounter.encounterID)
	if not displayIds then return false end

	components.CreatureButtons.SetCreatures(displayIds, encounter.name)
	component.SetDisplay(displayIds[1], encounter.name)
	components.EncounterFrame.SetCurrentView(modelContainer)
	return true
end

UI.Add(component)
