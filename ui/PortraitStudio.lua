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

It walks every boss in every instance and names each shot in chat as it takes it,
so a folder of timestamped screenshots can still be matched back to bosses
afterwards. The Needs art button narrows that to the encounters still carrying the
placeholder id, which is the worklist tools/make_bossportrait.py shares; the list
starts wide because retaking a portrait and looking up what a boss looks like are
both jobs about bosses that already have one.

A display id is suggested where the addon knows one and typed in otherwise.
Forever's creatures are not in the model data shipped here, and on an Era client
the client itself has never heard of them; what it does have is the vanilla model
most of them are built from, which is what the box is for. A model the running
client does not ship cannot be photographed on it at all -- Harbinger of Sin is a
recoloured Marrowgar, so he needs a client that has Icecrown Citadel.
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

--[[
	The shape of a finished portrait, for the guide box.

	tools/make_bossportrait.py crops to the model's own outline and rescales it, so
	what it is shot at does not matter in the least -- only the proportions do. Two
	boxes say that better than a number:

	- OUTER is 128x61, the canvas. A model wider than this cannot be scaled to full
	  height without overflowing, so the tool scales it by width instead and it
	  lands short of the top.
	- INNER is 96x61, what retail's own 59 portraits actually fill. Match it and the
	  result sits with them.

	What goes *in* the box matters more than the box. A portrait is scaled to a
	fixed height whatever it was shot at, so a full-body pose spends that height on
	legs: measured against the shipped art, which fills a third to a half of its box
	with solid pixels, full-body shots of the same creature managed a tenth. Frame
	the head and ribcage. It also keeps the feet, and the glow they stand in, out of
	the picture -- that glow is additive, so it takes the backdrop's colour and keys
	as creature.

	The tool then stands the model on the bottom edge and centres it at x 59 of 128,
	which is why the centre tick is left of middle.
]]
local GUIDE_W, GUIDE_H = 128, 61
local GUIDE_INNER_W = 96
local GUIDE_CENTRE_X = 59
local GUIDE_SCALE = 3.6

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

--[[
	Every boss in every instance, in list order.

	It used to return only the encounters still carrying the placeholder, which is
	the right worklist for finishing the set but the wrong one for everything else:
	a portrait that came out badly cannot be retaken, and a model cannot be looked
	up for a boss that already has art. The placeholder set is still one button
	away -- see the Needs art toggle -- and `needsArt` marks them in the list.
]]
local function AllBosses()
	local found = { }
	for _, instance in ipairs(InstanceService.GetAllInstances() or { }) do
		for _, encounter in ipairs(instance) do
			local boss = {
				instance = instance.name,
				name = encounter.name,
				encounterID = encounter.encounterID,
				needsArt = encounter.portrait == PLACEHOLDER_PORTRAIT,
			}
			-- Whether data/CreatureModels.lua has a display for this encounter.
			-- Marked in the encounter list, because a boss the addon cannot put a
			-- model to is a gap in the data rather than a gap in the art.
			boss.hasModel = SuggestedDisplay(boss) ~= nil
			found[#found + 1] = boss
		end
	end
	return found
end

local function WorkList(onlyNeedingArt)
	local all = AllBosses()
	if not onlyNeedingArt then return all end
	local found = { }
	for _, boss in ipairs(all) do
		if boss.needsArt then found[#found + 1] = boss end
	end
	return found
end

local function CurrentBoss()
	return studio and studio.bosses[studio.index]
end

-- Defined below, because loading a model and framing one call each other.
local Frame

local function ApplyModel()
	if not (studio and studio.model) then return end
	local displayId = tonumber(studio.displayBox:GetText())
	if not displayId then
		studio.loadedDisplay = nil
		studio.model:Hide()
		return
	end
	studio.model:Show()
	if displayId ~= studio.loadedDisplay then
		studio.loadedDisplay = displayId
		studio.model:ClearModel()
		studio.model:SetDisplayInfo(displayId)
	end
	Frame()
end

--[[
	Point the camera at the creature.

	This is the whole reason a typed display id used to show nothing. The studio
	asked for the automatic camera and then multiplied it -- SetPortraitZoom plus
	SetCamDistanceScale -- which ModelFrame had already proved, with AGC_ModelPoke,
	puts the camera *inside* the model: a correctly loaded creature, an empty
	screen, and no amount of zooming or lifting brings it back, because nothing is
	misplaced except the camera. Skul was the model it was proved on, and he is the
	same model Karazhan Crypts' first boss uses.

	So the framing goes through ModelFrame.AimCameraAt, which aims a custom camera
	and is what the journal's own viewer uses. The buttons move that camera: zoom is
	its distance, lift its height, turn the model's facing. The pose is deliberately
	not reset between bosses -- tune it once and the rest arrive wearing it.

	Height comes from the measured model heights, so one zoom value frames a gnome
	and a kodo alike. Forever's creatures have no measured height and fall back to
	the neutral one, so they still need an eye on them.
]]
Frame = function()
	local model = studio and studio.model
	local displayId = studio and studio.loadedDisplay
	if not (model and displayId) then return end
	local preset = {
		scale = studio.zoom,
		z = studio.height,
		facing = studio.facing,
	}
	local height = CreatureModelService.GetHeight(displayId)
	studio.modelHeight = height
	local aimed = false
	if components and components.ModelFrame and components.ModelFrame.AimCameraAt then
		aimed = components.ModelFrame.AimCameraAt(model, height, preset)
	end
	if not aimed then
		-- No custom camera on this client. The automatic one is all there is, and
		-- its framing is the best that can be done here.
		if model.SetPortraitZoom then model:SetPortraitZoom(0) end
		if model.SetCamDistanceScale then model:SetCamDistanceScale(studio.zoom) end
		if model.SetPosition then model:SetPosition(0, 0, studio.height) end
	end
	if model.SetFacing then model:SetFacing(studio.facing) end
end

local function Status()
	local boss = CurrentBoss()
	if not boss then
		return studio.onlyNeedingArt and "nothing left on the placeholder"
			or "no bosses"
	end
	return ("%d/%d   %s  --  %s%s"):format(studio.index, #studio.bosses,
		boss.name, boss.instance, boss.needsArt and "   |cffffd100needs art|r" or "")
end

local function Refresh()
	if not studio then return end
	studio.status:SetText(Status())
	if studio.instanceDropdown then
		local boss = CurrentBoss()
		UIDropDownMenu_SetText(studio.instanceDropdown,
			boss and boss.instance or "--")
		UIDropDownMenu_SetText(studio.encounterDropdown, boss and boss.name or "--")
	end
	studio.readout:SetText(("pose: zoom %.2f   turn %.2f   lift %.2f   model height %s"):format(
		studio.zoom, studio.facing, studio.height,
		studio.modelHeight and ("%.2f"):format(studio.modelHeight) or "unmeasured"))
end

--[[
	Show whatever studio.index now points at.

	Shared by the arrows and the two dropdowns, so a boss reached either way
	arrives with its suggested display id already in the box.
]]
local function SelectCurrent()
	local boss = CurrentBoss()
	studio.displayBox:SetText(tostring(SuggestedDisplay(boss) or ""))
	ApplyModel()
	Refresh()
end

local function Step(delta)
	if #studio.bosses == 0 then return end
	studio.index = studio.index + delta
	if studio.index < 1 then studio.index = #studio.bosses end
	if studio.index > #studio.bosses then studio.index = 1 end
	SelectCurrent()
end

-- The instances represented in the current worklist, in list order.
local function InstanceNames()
	local seen, order = { }, { }
	for _, boss in ipairs(studio.bosses) do
		if not seen[boss.instance] then
			seen[boss.instance] = true
			order[#order + 1] = boss.instance
		end
	end
	return order
end

local function JumpToInstance(name)
	for i, boss in ipairs(studio.bosses) do
		if boss.instance == name then
			studio.index = i
			SelectCurrent()
			return
		end
	end
end

local function InitInstanceDropdown()
	local current = CurrentBoss()
	local info = UIDropDownMenu_CreateInfo()
	for _, name in ipairs(InstanceNames()) do
		info.text = name
		info.value = name
		info.checked = current ~= nil and current.instance == name
		info.func = function(button)
			JumpToInstance(button.value)
			CloseDropDownMenus()
		end
		UIDropDownMenu_AddButton(info)
	end
end

--[[
	The bosses of whichever instance is selected.

	A boss with no display id in data/CreatureModels.lua is marked rather than
	hidden: walking an instance and seeing which entries say "no model" is the
	quickest way to find holes in the data, which is half of what this panel is
	for now.
]]
local function InitEncounterDropdown()
	local current = CurrentBoss()
	if not current then return end
	local info = UIDropDownMenu_CreateInfo()
	for i, boss in ipairs(studio.bosses) do
		if boss.instance == current.instance then
			info.text = boss.name
				.. (boss.hasModel and "" or "   |cffff7f7fno model|r")
				.. (boss.needsArt and "   |cffffd100needs art|r" or "")
			info.value = i
			info.checked = (i == studio.index)
			info.func = function(button)
				studio.index = button.value
				SelectCurrent()
				CloseDropDownMenus()
			end
			UIDropDownMenu_AddButton(info)
		end
	end
end

--[[
	Take the shot.

	Everything that is not the creature is hidden first -- the panel and the guide
	both, since the keyer crops to the outline of whatever is not backdrop and a
	panel in shot becomes part of the model's bounding box. That is exactly what
	happened to the first Harbinger of Sin shot: a correct model, keyed against a
	panel 1500 pixels below it, came out as a speck in the corner.

	There are two waits here and both are needed, which is why the first attempt
	at this still photographed the panel.

	The first is before the shutter: Screenshot captures the frame already drawn,
	so firing immediately -- or on a timer at zero -- catches the frame that still
	had the panel in it.

	The second is after. Screenshot does not capture when it is called; it queues
	the capture for the end of the frame. Showing the controls again on the next
	line therefore puts them back *before* the picture is taken, which is exactly
	what it looked like: a panel hidden for no observable time at all.

	Era and Forever both have C_Timer; without it the shot is taken anyway and the
	panel is simply in it, which is better than silently doing nothing.
]]
local SHUTTER_DELAY = 0.1
local RESTORE_DELAY = 0.5

--[[
	Where the guide box sits, in the pixels the screenshot will have.

	Until this existed the white box was advice and nothing more. The tool crops
	to the outline of everything that is not backdrop, so a shot framed perfectly
	inside the box still handed it the legs and the ground glow below them, and
	the portrait's 61pt height was spent on those instead of on the head. The
	difference is not small: the same plate measures 18% solid cropped to the
	whole creature and 36% cropped to the box, which is the band retail's own art
	sits in.

	So the rectangle is printed beside the boss's name, in the same line the shot
	is already announced on, and make_bossportrait.py takes it as --crop. A folder
	of timestamped screenshots then carries its crops in the chat log with it.

	GetRect is UI units measured from the bottom left; a screenshot is pixels from
	the top left, so the scale goes on and the y axis flips.
]]
local function GuideCrop()
	if not (studio and studio.guide and GetPhysicalScreenSize) then return nil end
	local left, bottom, width, height = studio.guide:GetRect()
	if not (left and width and width > 0 and height and height > 0) then return nil end
	local scale = studio.guide:GetEffectiveScale()
	local _, screenHeight = GetPhysicalScreenSize()
	local function px(value) return math.floor(value + 0.5) end
	return ("%d,%d,%d,%d"):format(
		px(left * scale),
		px(screenHeight - (bottom + height) * scale),
		px(width * scale),
		px(height * scale))
end

local function Shoot()
	local boss = CurrentBoss()
	if boss then
		local crop = GuideCrop()
		print(("|cff66ff66[AGC]|r shooting %s (%s)%s"):format(
			boss.name, boss.instance,
			crop and ("  |cffffd100--crop " .. crop .. "|r") or ""))
	end
	local guideWasShown = studio.guide and studio.guide:IsShown()
	studio.controls:Hide()
	if studio.guide then studio.guide:Hide() end

	local function Restore()
		if not studio then return end
		studio.controls:Show()
		if guideWasShown and studio.guide then studio.guide:Show() end
	end

	local function Fire()
		if _G.Screenshot then _G.Screenshot() end
		if C_Timer and C_Timer.After then
			C_Timer.After(RESTORE_DELAY, Restore)
		else
			Restore()
		end
	end

	if C_Timer and C_Timer.After then
		C_Timer.After(SHUTTER_DELAY, Fire)
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

--[[
	An outlined rectangle, drawn as four one-pixel textures.

	Deliberately not a backdrop: a backdrop's edge file is art with a thickness of
	its own, and this has to read as a measuring line over a flat colour.
]]
local function AddOutline(parent, width, height, r, g, b, a)
	local box = CreateFrame("Frame", nil, parent)
	box:SetSize(width, height)
	local function Edge(point1, point2, w, h)
		local line = box:CreateTexture(nil, "OVERLAY")
		line:SetColorTexture(r, g, b, a)
		line:SetPoint(point1)
		line:SetPoint(point2)
		if w then line:SetWidth(w) end
		if h then line:SetHeight(h) end
		return line
	end
	Edge("TOPLEFT", "TOPRIGHT", nil, 1)
	Edge("BOTTOMLEFT", "BOTTOMRIGHT", nil, 1)
	Edge("TOPLEFT", "BOTTOMLEFT", 1, nil)
	Edge("TOPRIGHT", "BOTTOMRIGHT", 1, nil)
	return box
end

--[[
	The guide: the finished portrait's shape, laid over the model.

	It takes no mouse input and sits above the model, so it can be left on while
	posing. Shoot hides it with the controls -- a measuring line in the picture
	would be keyed as part of the creature.
]]
local function CreateGuide(parent)
	local guide = CreateFrame("Frame", nil, parent)
	guide:SetSize(GUIDE_W * GUIDE_SCALE, GUIDE_H * GUIDE_SCALE)
	guide:SetPoint("CENTER", 0, 40)
	guide:EnableMouse(false)

	local outer = AddOutline(guide, GUIDE_W * GUIDE_SCALE, GUIDE_H * GUIDE_SCALE,
		0, 0, 0, 0.55)
	outer:SetPoint("CENTER")

	local inner = AddOutline(guide, GUIDE_INNER_W * GUIDE_SCALE,
		GUIDE_H * GUIDE_SCALE, 1, 1, 1, 0.85)
	inner:SetPoint("CENTER")

	-- Where the tool centres the model: x 59 of 128, so left of middle.
	local tick = guide:CreateTexture(nil, "OVERLAY")
	tick:SetColorTexture(1, 1, 1, 0.5)
	tick:SetSize(1, 12)
	tick:SetPoint("BOTTOM", guide, "BOTTOMLEFT",
		GUIDE_CENTRE_X * GUIDE_SCALE, 0)

	local label = guide:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("BOTTOM", guide, "TOP", 0, 6)
	label:SetText("head and ribcage filling the white box -- not the whole model, "
		.. "and keep the feet and their glow out of shot")

	guide:Hide()
	return guide
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
	--[[
		The wheel zooms, which is how every other model view in the game behaves and
		the first thing a hand reaches for. Shift still means a bigger step, as it
		does on the buttons.
	]]
	studio:EnableMouseWheel(true)
	studio:SetScript("OnMouseWheel", function(_, delta) Nudge("zoom", delta) end)
	studio:Hide()
	--[[
		Escape closes it, as it does the journal and the map.

		It matters more here than there: the studio covers the whole screen and
		takes the mouse, so without this the only ways out are the Close button and
		running the command again.
	]]
	table.insert(UISpecialFrames, studio:GetName())
	--[[
		Put the screenshot format back however the studio closes.

		Escape goes straight to Hide without passing through the Close button, so
		restoring in the button's handler left the client writing 10MB lossless
		screenshots for the rest of the session. On hide covers every route out.
	]]
	studio:SetScript("OnHide", PopScreenshotFormat)
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
		-- SetDisplayInfo zeroes the transform and finishes a frame later, so the
		-- framing has to go on again once the model is actually there. Without
		-- this the camera is aimed at a creature that has not loaded yet.
		model:SetScript("OnModelLoaded", function() Frame() end)
	else
		studio.supported = false
	end

	local controls = CreateFrame("Frame", nil, studio, "BackdropTemplate")
	controls:SetSize(580, 172)
	controls:SetPoint("BOTTOM", 0, 40)
	--[[
		Drag the panel by its background.

		It sits over the model, and the pose that suits one creature hides another
		behind the controls. Moving the panel is far less disruptive than moving the
		model, which would change the shot.
	]]
	controls:EnableMouse(true)
	controls:SetMovable(true)
	controls:SetClampedToScreen(true)
	controls:RegisterForDrag("LeftButton")
	controls:SetScript("OnDragStart", function(self) self:StartMoving() end)
	controls:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
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
	studio.status:SetWidth(556)
	studio.status:SetJustifyH("LEFT")

	studio.readout = controls:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	studio.readout:SetPoint("TOPLEFT", 12, -28)

	--[[
		Pick an instance and a boss directly.

		Prev and Next are still here and still the right tool for sweeping a
		worklist, but 393 presses is not a way to reach one creature, and checking
		whether an instance's models are right means going to that instance.
	]]
	studio.instanceDropdown = CreateFrame("Frame", "AGCPortraitStudioInstance",
		controls, "UIDropDownMenuTemplate")
	studio.instanceDropdown:SetPoint("TOPLEFT", -4, -42)
	UIDropDownMenu_SetWidth(studio.instanceDropdown, 200)
	UIDropDownMenu_Initialize(studio.instanceDropdown, InitInstanceDropdown)

	studio.encounterDropdown = CreateFrame("Frame", "AGCPortraitStudioEncounter",
		controls, "UIDropDownMenuTemplate")
	studio.encounterDropdown:SetPoint("TOPLEFT", 272, -42)
	UIDropDownMenu_SetWidth(studio.encounterDropdown, 200)
	UIDropDownMenu_Initialize(studio.encounterDropdown, InitEncounterDropdown)

	local displayLabel = controls:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	displayLabel:SetPoint("TOPLEFT", 12, -92)
	displayLabel:SetText("Display id")

	local box = CreateFrame("EditBox", nil, controls, "InputBoxTemplate")
	box:SetSize(80, 18)
	box:SetPoint("TOPLEFT", 78, -90)
	box:SetAutoFocus(false)
	box:SetNumeric(true)
	box:SetScript("OnTextChanged", function(_, userInput)
		if userInput then ApplyModel() end
	end)
	box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	studio.displayBox = box

	AddButton(controls, "Prev", 48, "TOPLEFT", 172, -90, function() Step(-1) end)
	AddButton(controls, "Next", 48, "TOPLEFT", 222, -90, function() Step(1) end)
	AddButton(controls, "Shoot", 70, "TOPLEFT", 276, -90, Shoot)

	--[[
		Which bosses the Prev/Next pair walks. "All" is the default because the
		common jobs -- retaking a portrait that came out badly, or looking up what
		a boss actually looks like -- are about bosses that already have art.
		"Needs art" is the finishing worklist, and the one the tool shares.
	]]
	studio.scopeButton = AddButton(controls, "All bosses", 86, "TOPLEFT", 12, -142,
		function()
			studio.onlyNeedingArt = not studio.onlyNeedingArt
			component.Rebuild()
		end)

	studio.guide = CreateGuide(studio)
	studio.guideButton = AddButton(controls, "Guide off", 86, "TOPLEFT", 104, -142,
		function()
			studio.guide:SetShown(not studio.guide:IsShown())
			studio.guideButton:SetText(studio.guide:IsShown() and "Guide on"
				or "Guide off")
		end)

	studio.chromaButton = AddButton(controls, "Magenta", 76, "TOPLEFT", 350, -90,
		function()
			studio.chroma = (studio.chroma % #CHROMA) + 1
			local c = CHROMA[studio.chroma]
			studio.backdrop:SetColorTexture(c.r, c.g, c.b, 1)
			studio.chromaButton:SetText(c.label)
		end)

	AddButton(controls, "Close", 60, "TOPLEFT", 430, -90, function()
		component.Hide()
	end)

	AddButton(controls, "Zoom -", 56, "TOPLEFT", 12, -116,
		function() Nudge("zoom", -1) end)
	AddButton(controls, "Zoom +", 56, "TOPLEFT", 70, -116,
		function() Nudge("zoom", 1) end)
	AddButton(controls, "Turn -", 56, "TOPLEFT", 132, -116,
		function() Nudge("facing", -1) end)
	AddButton(controls, "Turn +", 56, "TOPLEFT", 190, -116,
		function() Nudge("facing", 1) end)
	AddButton(controls, "Lift -", 56, "TOPLEFT", 252, -116,
		function() Nudge("height", -1) end)
	AddButton(controls, "Lift +", 56, "TOPLEFT", 310, -116,
		function() Nudge("height", 1) end)

	local hint = controls:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("TOPLEFT", 372, -120)
	hint:SetWidth(176)
	hint:SetJustifyH("LEFT")
	hint:SetText("Wheel zooms, Shift for bigger steps. Shots are lossless "
		.. "while this is open.")

	return studio
end

function component.Hide()
	if not studio then return end
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
	component.Rebuild()
	PushScreenshotFormat()
	studio:Show()
end

--[[
	Rebuild the worklist for the current scope and show its first boss.

	Keeps the boss being looked at where it can: switching to "Needs art" from a
	boss that needs art should not throw away the place in the list.
]]
function component.Rebuild()
	if not studio then return end
	local wanted = CurrentBoss()
	studio.bosses = WorkList(studio.onlyNeedingArt)
	studio.scopeButton:SetText(studio.onlyNeedingArt and "Needs art" or "All bosses")
	studio.index = 1
	if wanted then
		for i, boss in ipairs(studio.bosses) do
			if boss.name == wanted.name and boss.instance == wanted.instance then
				studio.index = i
				break
			end
		end
	end
	if #studio.bosses == 0 and studio.onlyNeedingArt then
		print("|cff66ff66[AGC]|r every boss already has a portrait.")
	end
	local boss = CurrentBoss()
	studio.displayBox:SetText(tostring(SuggestedDisplay(boss) or ""))
	ApplyModel()
	Refresh()
end

function component.Init(components_)
	components = components_
end

--[[
	A reload or a logout with the studio still open tears the frame down without
	ever hiding it, so OnHide never runs and the lossless screenshot setting
	survives into the next session -- where nothing explains why every screenshot
	is suddenly a 10MB TGA. The CVar is restored here instead.
]]
local exitFrame = CreateFrame("Frame")
Compat.RegisterEvents(exitFrame, "PLAYER_LOGOUT")
exitFrame:SetScript("OnEvent", function()
	if studio and studio:IsShown() then PopScreenshotFormat() end
end)

UI.Add(component)
