--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("ModelFrame")

local components
local modelContainer, creatureModel, currentDisplayId, currentPreset, currentEncounterId

--[[
	Wheel zoom bounds.

	Absolute, and multiplicative per notch. Bounding them relative to the preset
	meant a model that started badly framed could not be wheeled out of it: at
	Ragnaros' computed 5.96 the old 0.35x floor stopped at 2.1, nowhere near
	close enough to see him. A fixed step is no good either across a range this
	wide, since 0.12 is a crawl at 6.0 and a leap at 0.05.
]]
local MIN_ZOOM, MAX_ZOOM, ZOOM_RATE = 0.02, 24.0, 0.12
local ROTATION_SPEED = 0.02
-- Tilt is clamped short of straight up or down, past which the model is edge-on
-- and there is nothing useful to see.
local TILT_SPEED, MAX_TILT = 0.012, 1.2
local baseZoom, zoom = 1.0, 1.0

--[[
	How strongly the instance art shows behind the model.

	Blizzard's journal gets two separate images from EJ_GetInstanceInfo: bgImage
	for behind the model and loreImage for the lore page. bgImage is a dim,
	purpose-made backdrop, which is why their XML sets no alpha on it. Our data
	carries only the one image, the vivid splash the instance overview shows
	behind its lore text, so it is faded here to sit back behind the creature
	rather than compete with it.
]]
local BACKGROUND_ALPHA = 0.25

local function NotifyTuner()
	if components and components.ModelTuner then
		components.ModelTuner.Refresh()
	end
end

--[[
	Re-applies the preset a moment after the model is set.

	Camera and transform calls made straight after SetDisplayInfo are dropped
	while the model is still streaming in, which left the model showing something
	other than the numbers the preset actually holds -- so a saved preset looked
	like it had not taken, and tuning it again started from the wrong picture.
	OnModelLoaded covers the streaming case but does not fire for a model the
	client already has cached, so a short settle is needed as well. The loot
	preview waits 0.15s before TryOn for the same reason.
]]
--[[
	How long the preset keeps being re-asserted after a creature is shown.

	Fixed delays were the wrong shape for this. A model's camera is not ready
	until it has streamed in, and how long that takes depends on the model: the
	small ones were settled within a frame or two while Ragnaros, one of the
	largest, was still loading after every attempt had already fired, so his
	native camera won afterwards. Re-asserting each frame for a couple of seconds
	does not care how long the model takes.
]]
local ENFORCE_SECONDS = 2.0
local enforceUntil = 0

local function EnforcePreset()
	enforceUntil = GetTime() + ENFORCE_SECONDS
end

-- The moment the viewer is touched it is no longer ours to override.
local function ReleasePreset()
	enforceUntil = 0
end


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
	currentPreset = ModelPresetService.Get(displayId)
	creatureModel:SetDisplayInfo(displayId)
	component.ApplyPreset(currentPreset)
	EnforcePreset()
	-- A per-creature title wins over the encounter name, so the several models
	-- of one encounter can be named individually.
	local displayTitle = ModelPresetService.GetTitle(displayId, currentEncounterId) or title
	if displayTitle then
		modelContainer.imageTitle:SetText(displayTitle)
	end
	modelContainer.modelDisplayId:SetText(tostring(displayId))
	if components and components.ModelTuner then
		components.ModelTuner.OnDisplayChanged(displayId)
	end
end

-- Applies camera settings without reloading the model, so the tuner can nudge
-- values and see the result immediately.
function component.ApplyPreset(preset)
	if not creatureModel or not preset then return end
	currentPreset = preset
	if preset.title and preset.title ~= "" then
		modelContainer.imageTitle:SetText(preset.title)
	end
	-- Size first. It scales the model rather than the camera, and the camera
	-- framing is derived from the model's size, so setting it afterwards leaves
	-- the camera positioned for the model at its old size.
	local sized = (preset.modelScale or 1) ~= 1
	if creatureModel.SetModelScale then
		creatureModel:SetModelScale(preset.modelScale or 1)
	end
	--[[
		SetPortraitZoom re-frames the camera against the model's own bounds, which
		undoes a deliberate Size: scaling the model up only makes the bounds it
		fits to bigger, so the creature comes back the same size on screen. It is
		skipped once a Size is set, which is also why Size appeared to work until
		the model settled and this ran again.

		Kept for everything else, since every preset tuned so far was tuned with it
		active and none of them set a Size.
	]]
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

--[[
	The size the model actually has, as opposed to the one we asked for.

	Reading it back is the only way to tell a setting that did not take from one
	that was overwritten afterwards; the tuner shows it alongside the requested
	value so the two can be compared directly.
]]
function component.GetAppliedModelScale()
	if creatureModel and creatureModel.GetModelScale then
		return creatureModel:GetModelScale()
	end
	return nil
end

function component.SupportsModelScale()
	return creatureModel ~= nil and creatureModel.SetModelScale ~= nil
end

--[[
	Whether this client can tilt a model.

	SetPitch is a model transform like SetFacing, so it composes with the framing
	we already apply, but Blizzard only ships the Lua that uses it on retail. Ask
	the frame rather than assume, so the tuner can leave the control out on a
	client that has no such method instead of erroring on click.
]]
function component.SupportsTilt()
	return creatureModel ~= nil and creatureModel.SetPitch ~= nil
end

-- Creature sizes vary far too much for one framing to suit all of them, so the
-- wheel zooms and dragging turns the model, as the dressing room does.
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
		local _, y = GetCursorPosition()
		if button == "LeftButton" then
			self.isRotating = true
			ReleasePreset()
			self.rotateStartX = GetCursorPosition()
			self.rotateStartFacing = self:GetFacing()
		elseif button == "RightButton" and component.SupportsTilt() then
			self.isTilting = true
			ReleasePreset()
			self.tiltStartY = y
			self.tiltStartPitch = currentPreset and currentPreset.pitch or 0
		end
	end)
	model:SetScript("OnHide", function(self)
		self.isRotating = false
		self.isTilting = false
	end)
	-- The camera can be set before the model has finished streaming in, which
	-- leaves the framing at the creature's native scale. Re-apply once it lands.
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
		if self.isRotating then
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
	model:SetScript("OnMouseUp", function(self)
		if self.isRotating or self.isTilting then NotifyTuner() end
		self.isRotating = false
		self.isTilting = false
	end)
end

function component.GetDisplay()
	return currentDisplayId
end

function component.GetEncounterId()
	return currentEncounterId
end

--[[
	The live preset table.

	The tuner works on this object directly rather than a copy, so that wheel
	zoom and drag-tilt land in the same place as its own controls. Saving used to
	write whatever the buttons last set, discarding anything done with the mouse.
]]
function component.GetPreset()
	return currentPreset
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
	model.dungeonBG:SetAlpha(BACKGROUND_ALPHA)

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
	currentEncounterId = encounter.encounterID

	-- The instance art behind the model, as the retail journal shows. Faded, see
	-- BACKGROUND_ALPHA. Falls back to the journal's own default backdrop, which
	-- is what Blizzard's XML starts from, when an instance has no art.
	local instance = AdventureGuideNavigationService.GetInstance()
	modelContainer.dungeonBG:SetTexture((instance and instance.splash)
		or "Interface\\EncounterJournal\\UI-EJ-BACKGROUND-Default")

	components.CreatureButtons.SetCreatures(displayIds, encounter.name)
	component.SetDisplay(displayIds[1], encounter.name)
	components.EncounterFrame.SetCurrentView(modelContainer)
	return true
end

UI.Add(component)
