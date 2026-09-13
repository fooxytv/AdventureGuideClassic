--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
The levelling guide pop-out.

Parented to UIParent, NOT to the Adventure Guide frame, and initialised outside
UI.Init: you read this while questing, with the main window closed, so it cannot share
that window's lifetime. lib/TomCats/MinimapButton.lua sets the precedent for a UI
module that initialises itself.

Presentation: two translucent panels floating on the world, no enclosing frame. A
guide sits on screen for hours, so it has to stay out of the way -- an opaque window
this size is a wall, and the world should read through the gaps.

	            Step: 4 of 36              <- floats above the header
	  (ring) [ Elwynn Forest (1-10)  < > ]  <- ring overhangs the left, cog on the ring
	         [ ===progress=========      ]
	[ THE CURRENT STEP, and only that     ]

Deliberately shows ONE step. An upcoming list was tried and dropped: it filled most of
the frame with things the player cannot act on yet, and the arrows already cover
moving around. What is on screen is what to do now.

Portrait layering is easy to get wrong: the ring goes DOWN FIRST at BACKGROUND with
the icon above it at ARTWORK. portrait-ring-withbg (the fallback ring) has an opaque
background and will paint over the icon if drawn above it -- which an earlier version
did, rendering a black disc.

Behaviours: top-right by default, left-drag to move, right-click passes through so the
camera still turns, lockable to ignore the mouse entirely, its own scale and opacity,
and auto-hide inside instances unless the step itself is an instance step.
]]

GuideWindow = { }

local WIDTH = 300
local HEADER_HEIGHT = 44
local RING_SIZE, PORTRAIT_SIZE = 64, 42
-- The cog badge: a small framed icon echoing the portrait above it.
local BADGE_RING_SIZE, BADGE_ICON_SIZE = 30, 15
-- How far the ring reaches INTO the header panel, so the title and progress bar know
-- where they can start. The ring is centred 2px left of the panel's edge, so this is
-- half the ring less that offset -- keep the three in step if the ring is resized, or
-- the title will either collide with it or float away from it.
local RING_OVERHANG = (RING_SIZE / 2) - 2
local PANEL_GAP = 5

local frame, header, stepPanel
local isMoving
local initialised

local function IsLocked()
	return SettingsService.IsGuideLocked()
end

-- Panels --------------------------------------------------------------------------

local panels = { }

--[[
The translucent panel look. Uses Blizzard's shared backdrop constant where it exists
and an equivalent literal where it does not, so neither client is assumed.
]]
local function ApplyPanelBackdrop(panel, alpha)
	panel.alphaScale = alpha or 1
	panels[panel] = true
	panel.backdropInfo = BACKDROP_GLUE_TOOLTIP_16_16 or {
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileEdge = true, tileSize = 16, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	}
	if panel.OnBackdropLoaded then
		panel:OnBackdropLoaded()
		panel:SetBackdropColor(0.04, 0.04, 0.05,
			SettingsService.GetGuideOpacity() * panel.alphaScale)
		panel:SetBackdropBorderColor(0.78, 0.73, 0.56, 0.95)
	end
end

-- Re-tints every panel when the opacity setting moves.
local function ApplyOpacity()
	local opacity = SettingsService.GetGuideOpacity()
	for panel in pairs(panels) do
		if panel.SetBackdropColor then
			panel:SetBackdropColor(0.04, 0.04, 0.05, opacity * (panel.alphaScale or 1))
		end
	end
end

local function CreatePanel(parent, alpha)
	local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	ApplyPanelBackdrop(panel, alpha)
	return panel
end

--[[
Whether the window should be on screen at all: the user's toggle, plus the
auto-hide-in-instances rule. An instance step is the exception -- if the guide is
telling you to run Deadmines, hiding it inside Deadmines is unhelpful.

Deliberately NOT conditional on a guide being selected. The picker lives in the cog
menu, so hiding when no guide is chosen would make choosing one impossible.
]]
local function ShouldBeShown()
	if not SettingsService.IsGuideShown() then return false end
	if PlayerContextService.IsInInstance() then
		local step = GuideService.GetCurrentStep()
		if not (step and step.instance) then
			return false
		end
	end
	return true
end

local function SavePosition()
	SavedVariables.GuideWindowLocation = { frame:GetPoint() }
end

local function ApplyScale()
	if InCombatLockdown() then return end
	frame:SetScale(SettingsService.GetGuideScale())
end

-- Buttons ---------------------------------------------------------------------------

local function CreateIconButton(parent, size, up, down, tooltip, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(size, size)
	button:SetNormalTexture(up)
	button:SetPushedTexture(down or up)
	button:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(tooltip)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return button
end

local ARTIFACT_BORDER = "auctionhouse-itemicon-border-artifact"

--[[
Applies the artifact item border, reporting whether it took.

Asks the texture itself rather than asking C_Texture whether the atlas exists. That
lookup API is not present on every client, and gating on it meant a client that
supports the atlas perfectly well still fell through to the fallback ring whenever
C_Texture.GetAtlasInfo happened to be missing -- which is exactly what left a blue
disc where the gold border should have been.

SetAtlas on a missing atlas simply draws nothing, so the optimistic order is safe:
apply it, then confirm via GetAtlas where that exists. Where it does not, trust it --
the reference addons call SetAtlas unconditionally on these clients.
]]
local function ApplyArtifactBorder(texture)
	if type(texture.SetAtlas) ~= "function" then return false end
	local ok = pcall(texture.SetAtlas, texture, ARTIFACT_BORDER)
	if not ok then return false end
	if type(texture.GetAtlas) == "function" then
		local gotOk, atlas = pcall(texture.GetAtlas, texture)
		if gotOk then
			return atlas == ARTIFACT_BORDER
		end
	end
	return true
end

-- Header ----------------------------------------------------------------------------

local function CreateHeader(parent)
	local bar = CreatePanel(parent)
	bar:SetHeight(HEADER_HEIGHT)
	-- Inset from the left so the portrait ring can overhang into the gap.
	bar:SetPoint("TOPLEFT", parent, "TOPLEFT", RING_SIZE - RING_OVERHANG, 0)
	bar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)

	-- Step label floats above the header rather than inside it, keeping the header
	-- itself down to the title and controls.
	bar.stepText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	bar.stepText:SetPoint("BOTTOM", bar, "TOP", 0, 2)
	bar.stepText:SetTextScale(0.95)

	-- Icon first, border over the top.
	--
	-- The artifact item border has a TRANSPARENT centre, so it frames the icon when
	-- drawn above it. This is the opposite of portrait-ring-withbg, whose centre is
	-- opaque and which therefore has to go underneath; conflating the two is what
	-- produced a black disc in earlier attempts.
	--
	-- Everything here hangs off the HEADER PANEL, not the container. A child frame
	-- draws above its parent's textures whatever draw layer they claim, so a ring
	-- parented to the container was always going to be cut in half by the header's
	-- backdrop. On the header, ARTWORK and OVERLAY sit in front of that backdrop and
	-- the overhang to the left simply hangs outside it.
	--
	-- The icon is static -- the addon's own Encounter Journal mark, as used by the
	-- minimap button. A live SetPortraitTexture portrait was tried and abandoned: it
	-- silently does nothing when the unit is not ready, and there is no dependable way
	-- to tell whether it worked, so it fails blank rather than falling back.
	bar.portrait = bar:CreateTexture(nil, "ARTWORK")
	bar.portrait:SetTexture("Interface/EncounterJournal/UI-EJ-PortraitIcon")
	bar.portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
	bar.portrait:SetPoint("CENTER", bar, "LEFT", -2, 0)

	bar.ring = bar:CreateTexture(nil, "OVERLAY")
	if ApplyArtifactBorder(bar.ring) then
		bar.ring:SetSize(RING_SIZE, RING_SIZE)
		bar.ring:SetPoint("CENTER", bar.portrait, "CENTER", 0, 0)
	else
		-- No atlas on this client: the circular ring has an opaque centre, so it must
		-- sit under the icon, and the icon needs masking to a circle to suit it.
		bar.ring:SetDrawLayer("BACKGROUND")
		bar.ring:SetTexture("Interface/Common/portrait-ring-withbg")
		bar.ring:SetSize(RING_SIZE, RING_SIZE)
		bar.ring:SetPoint("CENTER", bar.portrait, "CENTER", 0, 0)
		local mask = bar:CreateMaskTexture()
		mask:SetAllPoints(bar.portrait)
		mask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask",
			"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		bar.portrait:AddMaskTexture(mask)
	end

	bar.next = CreateIconButton(bar, 22, "Interface/Buttons/UI-SpellbookIcon-NextPage-Up",
		"Interface/Buttons/UI-SpellbookIcon-NextPage-Down", "Next step",
		function() GuideService.NextStep() end)
	bar.next:SetPoint("TOPRIGHT", -8, -5)

	bar.back = CreateIconButton(bar, 22, "Interface/Buttons/UI-SpellbookIcon-PrevPage-Up",
		"Interface/Buttons/UI-SpellbookIcon-PrevPage-Down", "Previous step",
		function() GuideService.PreviousStep() end)
	bar.back:SetPoint("RIGHT", bar.next, "LEFT", -2, 0)

	-- Cog goes where the player frame puts the level badge, framed by a ring of its
	-- own so it matches the portrait rather than looking like a stray icon dropped on
	-- the corner.
	bar.settings = CreateIconButton(bar, BADGE_ICON_SIZE,
		"Interface/GossipFrame/BinderGossipIcon", nil,
		"Guide options", function() GuideWindow.ShowMenu() end)
	bar.settings:SetPoint("CENTER", bar.portrait, "BOTTOMLEFT", 4, 4)

	bar.settingsRing = bar:CreateTexture(nil, "OVERLAY")
	if not ApplyArtifactBorder(bar.settingsRing) then
		bar.settingsRing:SetDrawLayer("BACKGROUND")
		bar.settingsRing:SetTexture("Interface/Common/portrait-ring-withbg")
	end
	bar.settingsRing:SetSize(BADGE_RING_SIZE, BADGE_RING_SIZE)
	bar.settingsRing:SetPoint("CENTER", bar.settings, "CENTER", 0, 0)

	bar.title = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	bar.title:SetTextScale(0.85)
	bar.title:SetPoint("TOPLEFT", RING_OVERHANG, -8)
	bar.title:SetPoint("RIGHT", bar.back, "LEFT", -6, 0)
	bar.title:SetJustifyH("LEFT")
	bar.title:SetWordWrap(false)

	-- Progress across the whole guide, so you can see how far through a zone you are
	-- without counting steps.
	bar.progress = CreateFrame("StatusBar", nil, bar)
	bar.progress:SetHeight(6)
	-- Clear of the ring, which overhangs this panel's left edge.
	bar.progress:SetPoint("BOTTOMLEFT", RING_OVERHANG, 8)
	bar.progress:SetPoint("BOTTOMRIGHT", -12, 8)
	bar.progress:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
	bar.progress:SetStatusBarColor(0.20, 0.50, 0.90)
	bar.progress:SetMinMaxValues(0, 1)
	bar.progress:SetValue(0)
	bar.progress.bg = bar.progress:CreateTexture(nil, "BACKGROUND")
	bar.progress.bg:SetAllPoints()
	bar.progress.bg:SetColorTexture(0, 0, 0, 0.55)

	return bar
end

-- Frame -----------------------------------------------------------------------------

local function CreateWindow()
	-- The container is invisible: the panels are the visible parts, so the world shows
	-- through the gaps between them.
	frame = CreateFrame("Frame", addonName .. "_GuideWindow", UIParent)
	frame:SetSize(WIDTH, 120)
	frame:SetFrameStrata("MEDIUM")
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(not IsLocked())
	frame:RegisterForDrag("LeftButton")

	-- Let right-click through to the world so the camera still turns over the frame.
	-- Not on every client, hence the guard.
	if frame.SetPassThroughButtons then
		pcall(frame.SetPassThroughButtons, frame, "RightButton")
	end

	local saved = SavedVariables and SavedVariables.GuideWindowLocation
	if saved then
		frame:ClearAllPoints()
		local ok = pcall(function() frame:SetPoint(unpack(saved)) end)
		if not ok then
			frame:ClearAllPoints()
			frame:SetPoint("TOPRIGHT", -30, -240)
		end
	else
		frame:SetPoint("TOPRIGHT", -30, -240)
	end

	frame:SetScript("OnDragStart", function(self)
		if IsLocked() then return end
		self:StartMoving()
		isMoving = true
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		isMoving = false
		SavePosition()
	end)

	header = CreateHeader(frame)
	-- Only now is the `header` local set, which UpdatePortrait needs.
	GuideWindow.UpdatePortrait()

	-- The current step, and only the current step.
	stepPanel = CreatePanel(frame)
	stepPanel:SetPoint("TOPLEFT", header, "BOTTOMLEFT", -(RING_SIZE - RING_OVERHANG), -PANEL_GAP)
	stepPanel:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -PANEL_GAP)
	stepPanel:SetHeight(52)

	stepPanel.icon = stepPanel:CreateTexture(nil, "ARTWORK")
	stepPanel.icon:SetSize(18, 18)
	stepPanel.icon:SetPoint("TOPLEFT", 14, -14)

	stepPanel.text = stepPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	stepPanel.text:SetPoint("TOPLEFT", stepPanel.icon, "TOPRIGHT", 8, 2)
	stepPanel.text:SetPoint("RIGHT", stepPanel, "RIGHT", -14, 0)
	stepPanel.text:SetJustifyH("LEFT")
	stepPanel.text:SetJustifyV("TOP")
	stepPanel.text:SetSpacing(3)

	-- Live objective lines for the step's quest, created on demand.
	stepPanel.objectives = { }

	ApplyScale()
	frame:Hide()
end

-- Public -------------------------------------------------------------------------

--[[
The header icon. Static, so there is nothing to go wrong or arrive late; kept as a
function because the login hook calls it and a future class- or faction-specific mark
would slot in here.
]]
function GuideWindow.UpdatePortrait()
	if not (header and header.portrait) then return end
	header.portrait:SetTexture("Interface/EncounterJournal/UI-EJ-PortraitIcon")
end

-- Read-only accessor, so the portrait fallback chain can be asserted rather than
-- eyeballed. It has been wrong twice.
-- Exposed alongside GetPortrait so the icon/border layering can be asserted.
function GuideWindow.GetRing()
	return header and header.ring
end

function GuideWindow.GetPortrait()
	return header and header.portrait
end

-- The options panel anchors beside this frame rather than over it.
function GuideWindow.GetFrame()
	return frame
end

function GuideWindow.EnsureCreated()
	if initialised then return end
	initialised = true
	CreateWindow()

	GuideService.RegisterListener(function() GuideWindow.Refresh() end)
	SettingsService.RegisterGuideListener(function(key)
		if not initialised then return end
		if key == "Scale" then
			ApplyScale()
		elseif key == "Opacity" then
			ApplyOpacity()
			if GuideMenu and GuideMenu.Refresh then GuideMenu.Refresh() end
		elseif key == "Locked" then
			frame:EnableMouse(not IsLocked())
		end
		GuideWindow.Refresh()
	end)
	PlayerContextService.RegisterListener(function(_, changed)
		GuideWindow.UpdatePortrait()
		if changed.inInstance or changed.level then
			GuideWindow.Refresh()
		end
	end)
	-- Objective counts change constantly; the scan is already debounced, so following
	-- it directly is cheap.
	if GuideProgressService and GuideProgressService.RegisterListener then
		GuideProgressService.RegisterListener(function() GuideWindow.Refresh() end)
	end
end

--[[
Live objectives for whatever quest the current step belongs to, so you can watch
"4/10" tick up without opening the quest log. Kill and collect steps rarely name their
quest, so GuideProgressService resolves it from the turn-in ahead of them.

Nothing is shown when the quest is not in the log yet -- before accepting it there is
no progress to report, and an empty block would just pad the panel.
]]
local function HideObjectives()
	for _, line in ipairs(stepPanel.objectives) do
		line:Hide()
	end
end

local function ShowObjectives(guide, index)
	HideObjectives()
	if not GuideProgressService then return 0 end

	local quest = GuideProgressService.GetQuestForStep(guide, index)
	if not quest then return 0 end

	local objectives = GuideProgressService.GetObjectives(quest)
	if #objectives == 0 then return 0 end

	local height = 6
	for position, objective in ipairs(objectives) do
		local line = stepPanel.objectives[position]
		if not line then
			line = stepPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			line:SetJustifyH("LEFT")
			line:SetJustifyV("TOP")
			stepPanel.objectives[position] = line
		end
		line:ClearAllPoints()
		line:SetPoint("TOPLEFT", stepPanel.text, "BOTTOMLEFT", 0, -height + 2)
		line:SetPoint("RIGHT", stepPanel, "RIGHT", -14, 0)
		line:SetText(objective.text)
		-- Finished objectives dim out of the way; outstanding ones stay legible.
		if objective.done then
			line:SetTextColor(0.45, 0.62, 0.45)
		else
			line:SetTextColor(0.95, 0.82, 0.35)
		end
		line:Show()
		height = height + line:GetStringHeight() + 2
	end
	return height
end

function GuideWindow.Refresh()
	if not initialised then return end

	local guide = GuideService.GetCurrentGuide()

	if not guide then
		HideObjectives()
		header.title:SetText("Levelling Guide")
		header.stepText:SetText("")
		header.progress:SetValue(0)
		header.back:SetEnabled(false)
		header.next:SetEnabled(false)
		stepPanel.icon:SetTexture("Interface/GossipFrame/GossipGossipIcon")
		stepPanel.text:SetText("No guide selected. Use the cog to choose one.")
		stepPanel:SetHeight(math.max(46, stepPanel.text:GetStringHeight() + 30))
		frame:SetHeight(HEADER_HEIGHT + PANEL_GAP + stepPanel:GetHeight())
		frame:SetShown(ShouldBeShown())
		return
	end

	local index = GuideService.GetStepIndex(guide)
	local total = #guide.steps
	header.title:SetText(guide.title)
	header.stepText:SetText(("Step: %d of %d"):format(index, total))
	header.progress:SetValue(total > 0 and (index / total) or 0)

	local current = guide.steps[index]
	if current then
		stepPanel.icon:SetTexture(GuideTaskTypes.GetIcon(current))
		stepPanel.text:SetText(GuideTaskTypes.GetText(current))
	end

	local objectiveHeight = ShowObjectives(guide, index)

	-- Grow to the text rather than clipping a step that carries a note.
	stepPanel:SetHeight(math.max(46, stepPanel.text:GetStringHeight() + objectiveHeight + 30))

	header.back:SetEnabled(GuideService.HasPreviousStep())
	header.next:SetEnabled(GuideService.HasNextStep() or (guide.next ~= nil))

	frame:SetHeight(HEADER_HEIGHT + PANEL_GAP + stepPanel:GetHeight())
	frame:SetShown(ShouldBeShown())
end

function GuideWindow.Show()
	GuideWindow.EnsureCreated()
	SettingsService.SetGuideShown(true)
	-- First open: pick the guide matching this character rather than showing an empty
	-- frame and making the user hunt through the cog menu.
	if not GuideService.GetCurrentGuide() then
		GuideService.StartGuideForLevel()
	end
	GuideWindow.Refresh()
end

function GuideWindow.Hide()
	SettingsService.SetGuideShown(false)
	if initialised then GuideWindow.Refresh() end
end

function GuideWindow.Toggle()
	GuideWindow.EnsureCreated()
	if GuideWindow.IsShown() then
		GuideWindow.Hide()
	else
		GuideWindow.Show()
	end
end

function GuideWindow.IsShown()
	return initialised and frame:IsShown()
end

function GuideWindow.ResetPosition()
	GuideWindow.EnsureCreated()
	frame:ClearAllPoints()
	frame:SetPoint("TOPRIGHT", -30, -240)
	SavePosition()
end

--[[
The options panel lives in ui/guide/GuideMenu.lua -- a styled translucent panel rather
than a UIDropDownMenu, matching the window itself. See that file for why.
]]
function GuideWindow.ShowMenu()
	GuideMenu.Toggle()
end

-- Initialise once the character is known; the window must be able to appear with the
-- main Adventure Guide window never having been opened.
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loginFrame:SetScript("OnEvent", function()
	GuideWindow.EnsureCreated()
	GuideWindow.UpdatePortrait()
	GuideWindow.Refresh()
end)

-- Debug helpers (see todo.md) -------------------------------------------------

_G.AGC_ToggleGuide = function() GuideWindow.Toggle() end
_G.AGC_ResetGuidePosition = function() GuideWindow.ResetPosition() end

-- Explains why the window is or isn't on screen.
_G.AGC_GuideStatus = function()
	local guide = GuideService.GetCurrentGuide()
	print("|cff33ff99[AGC]|r guide window status:")
	print(("  created:        %s"):format(tostring(initialised)))
	print(("  setting 'show': %s"):format(tostring(SettingsService.IsGuideShown())))
	print(("  in instance:    %s"):format(tostring(PlayerContextService.IsInInstance())))
	print(("  current guide:  %s"):format(guide and guide.id or "none"))
	print(("  guides for you: %d"):format(#GuideService.GetGuidesForCharacter()))
	print(("  should show:    %s"):format(tostring(ShouldBeShown())))
	print(("  actually shown: %s"):format(tostring(GuideWindow.IsShown())))
	if initialised then
		local point, _, _, x, y = frame:GetPoint()
		print(("  anchor:         %s %.0f,%.0f  scale %.2f  opacity %.2f"):format(
			tostring(point), x or 0, y or 0, frame:GetScale(),
			SettingsService.GetGuideOpacity()))
	end
end
