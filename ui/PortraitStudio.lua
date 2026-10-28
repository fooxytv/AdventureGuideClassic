--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

Developer rig for photographing a creature against a flat colour, so
tools/make_bossportrait.py can cut it out. Off by default and reachable only
through /agc portraits -- a tuning aid, not a user feature.

The repetitive half of making a portrait was never the model; it was staging the
shot. This covers the screen in a single colour the keyer can find, puts the model
on it as large as it will go, hides its own controls for the frame the shutter
fires on, and writes lossless screenshots so the edge survives to be keyed. What
comes out needs no retouching, only tools/make_bossportrait.py.

It walks the same worklist the tool does -- every encounter still carrying the
placeholder id -- and names each shot in chat as it takes it, so a folder of
timestamped screenshots can still be matched back to bosses afterwards.

Display ids are typed in rather than looked up. Forever's creatures are not in the
model data shipped here, and on an Era client the client itself has never heard of
them; what it does have is the vanilla model most of them are built from, which is
what the box is for.
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("PortraitStudio")

local components
local studio

-- The id every boss with no art of its own carries, and the one the tool reads.
local PLACEHOLDER_PORTRAIT = 521744

--[[
	Backdrop colours, and why there is a choice.

	The keyer separates model from backdrop by how far the backdrop's own channels
	are apart, so the colour has to be one the creature cannot contain. Magenta
	suits almost everything; green is here for the demons and felguards that are
	magenta's one blind spot.
]]
local CHROMA = {
	{ label = "Magenta", r = 1, g = 0, b = 1 },
	{ label = "Green", r = 0, g = 1, b = 0 },
}

local MODEL_SIZE = 512
local MIN_ZOOM, MAX_ZOOM = 0.1, 6

local function PlaceholderBosses()
	local found = { }
	for _, instance in ipairs(InstanceService.GetAllInstances() or { }) do
		for _, encounter in ipairs(instance) do
			if encounter.portrait == PLACEHOLDER_PORTRAIT then
				found[#found + 1] = {
					instance = instance.name,
					name = encounter.name,
					encounterID = encounter.encounterID,
				}
			end
		end
	end
	return found
end

local function CurrentBoss()
	return studio and studio.bosses[studio.index]
end

--[[
	A display id to start from, where one is known.

	The model data shipped with the addon covers the clients' own creatures, so a
	vanilla boss arrives with its model already chosen and only Forever's need
	typing in.
]]
local function SuggestedDisplay(boss)
	if not (boss and boss.encounterID) then return nil end
	local ok, ids = pcall(CreatureModelService.GetDisplayIds, boss.encounterID)
	if ok and type(ids) == "table" and ids[1] then return ids[1] end
	return nil
end

local function ApplyModel()
	if not (studio and studio.model) then return end
	local displayId = tonumber(studio.displayBox:GetText())
	if not displayId then
		studio.model:Hide()
		return
	end
	studio.model:Show()
	studio.model:ClearModel()
	studio.model:SetDisplayInfo(displayId)
	if studio.model.SetPortraitZoom then studio.model:SetPortraitZoom(0) end
	--[[
		The pose is the point: every portrait wants the creature at the same size
		and angle, and a kodo is not a gnome.

		CreatureModelService already knows how far to pull the camera back for a
		given display id, from the model heights measured for the journal's own
		viewer, so that does the per-creature part. What is left is one adjustment
		that applies to all of them -- which is what the buttons move, and why it
		is deliberately not reset when stepping to the next boss. Tune the pose
		once on the first model and the rest arrive wearing it.

		A display id with no recorded height gets the service's neutral scale, so
		Forever's creatures still need an eye on them.
	]]
	local fitted = 1
	local ok, scale = pcall(CreatureModelService.GetCameraScale, displayId)
	if ok and type(scale) == "number" and scale > 0 then fitted = scale end
	studio.fitted = fitted
	if studio.model.SetCamDistanceScale then
		studio.model:SetCamDistanceScale(fitted * studio.zoom)
	end
	if studio.model.SetRotation then studio.model:SetRotation(studio.facing) end
	if studio.model.SetPosition then
		studio.model:SetPosition(0, 0, studio.height)
	end
end

local function Status()
	local boss = CurrentBoss()
	if not boss then return "nothing left on the placeholder" end
	return ("%d/%d   %s  --  %s"):format(studio.index, #studio.bosses,
		boss.name, boss.instance)
end

local function Refresh()
	if not studio then return end
	studio.status:SetText(Status())
	studio.readout:SetText(("pose: zoom %.2f x fit %.2f   turn %.2f   lift %.2f"):format(
		studio.zoom, studio.fitted or 1, studio.facing, studio.height))
end

local function Step(delta)
	if #studio.bosses == 0 then return end
	studio.index = studio.index + delta
	if studio.index < 1 then studio.index = #studio.bosses end
	if studio.index > #studio.bosses then studio.index = 1 end
	local boss = CurrentBoss()
	studio.displayBox:SetText(tostring(SuggestedDisplay(boss) or ""))
	ApplyModel()
	Refresh()
end

--[[
	Take the shot.

	The controls are hidden first and the shutter fires on the next frame, because
	hiding a frame does not take effect until the client draws again -- fire in the
	same call and the panel is in the picture. Era and Forever both have C_Timer;
	without it the shot is taken anyway and the controls are simply in it, which is
	better than silently doing nothing.
]]
local function Shoot()
	local boss = CurrentBoss()
	if boss then
		print(("|cff66ff66[AGC]|r shooting %s (%s)"):format(boss.name, boss.instance))
	end
	studio.controls:Hide()
	local function Fire()
		if _G.Screenshot then _G.Screenshot() end
		if studio then studio.controls:Show() end
	end
	if C_Timer and C_Timer.After then
		C_Timer.After(0, Fire)
	else
		Fire()
	end
end

--[[
	Lossless screenshots while the studio is open.

	The client writes JPEG by default, and JPEG rings around a hard colour edge --
	exactly the edge the keyer has to find. The setting is put back on the way out
	so this does not quietly change how the rest of the game screenshots.
]]
local function PushScreenshotFormat()
	if not (GetCVar and SetCVar) then return end
	studio.oldFormat = GetCVar("screenshotFormat")
	studio.oldQuality = GetCVar("screenshotQuality")
	pcall(SetCVar, "screenshotFormat", "tga")
	pcall(SetCVar, "screenshotQuality", "10")
end

local function PopScreenshotFormat()
	if not (SetCVar and studio and studio.oldFormat) then return end
	pcall(SetCVar, "screenshotFormat", studio.oldFormat)
	if studio.oldQuality then
		pcall(SetCVar, "screenshotQuality", studio.oldQuality)
	end
	studio.oldFormat, studio.oldQuality = nil, nil
end

local function AddButton(parent, text, width, point, x, y, onClick)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width, 20)
	button:SetPoint(point, x, y)
	button:SetText(text)
	button:SetScript("OnClick", onClick)
	return button
end

local function Nudge(field, delta)
	local step = IsShiftKeyDown() and 5 or 1
	if field == "zoom" then
		studio.zoom = math.max(MIN_ZOOM, math.min(MAX_ZOOM,
			studio.zoom + 0.1 * delta * step))
	elseif field == "facing" then
		studio.facing = studio.facing + 0.1 * delta * step
	else
		studio.height = studio.height + 0.1 * delta * step
	end
	ApplyModel()
	Refresh()
end

local function CreateStudio()
	if studio then return studio end
	studio = CreateFrame("Frame", "AGCPortraitStudio", UIParent)
	studio:SetAllPoints(UIParent)
	studio:SetFrameStrata("FULLSCREEN_DIALOG")
	studio:EnableMouse(true)
	studio:Hide()
	studio.zoom, studio.facing, studio.height = 1, 0, 0
	studio.fitted = 1
	studio.chroma = 1
	studio.bosses = { }
	studio.index = 1

	studio.backdrop = studio:CreateTexture(nil, "BACKGROUND")
	studio.backdrop:SetAllPoints(studio)
	studio.backdrop:SetColorTexture(1, 0, 1, 1)

	local ok, model = pcall(CreateFrame, "PlayerModel", nil, studio)
	if ok and model and type(model.SetDisplayInfo) == "function" then
		studio.model = model
		model:SetSize(MODEL_SIZE, MODEL_SIZE)
		model:SetPoint("CENTER", 0, 40)
		model:EnableMouse(false)
	else
		studio.supported = false
	end

	local controls = CreateFrame("Frame", nil, studio, "BackdropTemplate")
	controls:SetSize(560, 104)
	controls:SetPoint("BOTTOM", 0, 40)
	controls:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	controls:SetBackdropColor(0, 0, 0, 0.92)
	studio.controls = controls

	studio.status = controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	studio.status:SetPoint("TOPLEFT", 12, -10)
	studio.status:SetWidth(536)
	studio.status:SetJustifyH("LEFT")

	studio.readout = controls:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	studio.readout:SetPoint("TOPLEFT", 12, -28)

	local displayLabel = controls:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	displayLabel:SetPoint("TOPLEFT", 12, -48)
	displayLabel:SetText("Display id")

	local box = CreateFrame("EditBox", nil, controls, "InputBoxTemplate")
	box:SetSize(80, 18)
	box:SetPoint("TOPLEFT", 78, -46)
	box:SetAutoFocus(false)
	box:SetNumeric(true)
	box:SetScript("OnTextChanged", function(_, userInput)
		if userInput then ApplyModel() end
	end)
	box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	studio.displayBox = box

	AddButton(controls, "Prev", 48, "TOPLEFT", 172, -46, function() Step(-1) end)
	AddButton(controls, "Next", 48, "TOPLEFT", 222, -46, function() Step(1) end)
	AddButton(controls, "Shoot", 70, "TOPLEFT", 276, -46, Shoot)

	studio.chromaButton = AddButton(controls, "Magenta", 76, "TOPLEFT", 350, -46,
		function()
			studio.chroma = (studio.chroma % #CHROMA) + 1
			local c = CHROMA[studio.chroma]
			studio.backdrop:SetColorTexture(c.r, c.g, c.b, 1)
			studio.chromaButton:SetText(c.label)
		end)

	AddButton(controls, "Close", 60, "TOPLEFT", 430, -46, function()
		component.Hide()
	end)

	AddButton(controls, "Zoom -", 56, "TOPLEFT", 12, -72,
		function() Nudge("zoom", -1) end)
	AddButton(controls, "Zoom +", 56, "TOPLEFT", 70, -72,
		function() Nudge("zoom", 1) end)
	AddButton(controls, "Turn -", 56, "TOPLEFT", 132, -72,
		function() Nudge("facing", -1) end)
	AddButton(controls, "Turn +", 56, "TOPLEFT", 190, -72,
		function() Nudge("facing", 1) end)
	AddButton(controls, "Lift -", 56, "TOPLEFT", 252, -72,
		function() Nudge("height", -1) end)
	AddButton(controls, "Lift +", 56, "TOPLEFT", 310, -72,
		function() Nudge("height", 1) end)

	local hint = controls:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("TOPLEFT", 372, -76)
	hint:SetWidth(176)
	hint:SetJustifyH("LEFT")
	hint:SetText("Shift for bigger steps. Shots are lossless while this is open.")

	return studio
end

function component.Hide()
	if not studio then return end
	PopScreenshotFormat()
	studio:Hide()
end

function component.Toggle()
	CreateStudio()
	if studio:IsShown() then
		component.Hide()
		return
	end
	if studio.supported == false then
		print("|cffff5555[AGC]|r this client cannot show creature models.")
		return
	end
	studio.bosses = PlaceholderBosses()
	studio.index = 1
	if #studio.bosses == 0 then
		print("|cff66ff66[AGC]|r every boss already has a portrait.")
	end
	PushScreenshotFormat()
	studio:Show()
	local boss = CurrentBoss()
	studio.displayBox:SetText(tostring(SuggestedDisplay(boss) or ""))
	ApplyModel()
	Refresh()
end

function component.Init(components_)
	components = components_
end

UI.Add(component)
