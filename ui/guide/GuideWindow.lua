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
--[[
Header geometry. The template owns its own portrait socket and frame art, so all that
is left to place is where the progress hairline may start -- clear of that socket --
and how far the step card is inset from the header's width.
]]
local CONTENT_INSET = 62
local STEP_PANEL_INSET = 8
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
		if panel.SetBackdropColor and panel.backdropInfo then
			panel:SetBackdropColor(0.04, 0.04, 0.05, opacity * (panel.alphaScale or 1))
		elseif panel.DimChrome then
			-- A Blizzard template: dim its art rather than a backdrop it does not have.
			panel.DimChrome(opacity)
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

--[[
Clips a texture to a circle. Masks are not on every client, so this is a no-op where
CreateMaskTexture is missing rather than an error -- the icon simply keeps its corners.
]]
local function ApplyRoundMask(owner, texture)
	if type(owner.CreateMaskTexture) ~= "function" then return false end
	local ok, mask = pcall(owner.CreateMaskTexture, owner)
	if not (ok and mask) then return false end
	mask:SetAllPoints(texture)
	mask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask",
		"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	pcall(texture.AddMaskTexture, texture, mask)
	return true
end

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

--[[
Dims a Blizzard frame template's own chrome without touching its text or icons.

SetAlpha on the frame would fade the title and portrait with it. The background and
border pieces live on the BACKGROUND and BORDER layers while text and portrait sit on
ARTWORK and above, so walking the regions and dimming only the lower two leaves the
content crisp and lets the world through the frame.
]]
local function SetChromeAlpha(frame, alpha)
	for _, region in ipairs({ frame:GetRegions() }) do
		if type(region.GetObjectType) == "function"
			and region:GetObjectType() == "Texture"
			and type(region.GetDrawLayer) == "function" then
			local layer = region:GetDrawLayer()
			if layer == "BACKGROUND" or layer == "BORDER" then
				region:SetAlpha(alpha)
			end
		end
	end
end

--[[
The header is a real PortraitFrameTemplate -- the same template the main Adventure
Guide window is built from -- cut down to banner height so only its top chrome shows.

That is the identity this addon already has: Blizzard's gold frame with the journal
mark in the portrait socket. Building the header from a plain backdrop instead meant
borrowing an identity rather than using our own, and the template hands us the
portrait socket, the title and the frame art for free.

Its chrome is dimmed so the world reads through it, which is the part worth keeping
from the flat-panel version.
]]
local function CreateHeader(parent)
	local name = parent:GetName() .. "Header"
	local bar = CreateFrame("Frame", name, parent, "PortraitFrameTemplate")
	bar:SetHeight(HEADER_HEIGHT)
	bar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	bar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
	panels[bar] = true
	bar.alphaScale = 1
	bar.DimChrome = function(alpha) SetChromeAlpha(bar, alpha) end
	bar.DimChrome(SettingsService.GetGuideOpacity())

	-- The template's own portrait socket, carrying the addon's journal mark. Build our
	-- own if the template did not provide one, so the socket is never simply absent.
	local portrait = _G[name .. "Portrait"]
	if not portrait then
		portrait = bar:CreateTexture(nil, "ARTWORK")
		portrait:SetSize(HEADER_HEIGHT - 8, HEADER_HEIGHT - 8)
		portrait:SetPoint("LEFT", 6, 0)
	end
	portrait:SetTexture("Interface/EncounterJournal/UI-EJ-PortraitIcon")
	portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	ApplyRoundMask(bar, portrait)
	bar.portrait = portrait

	--[[
	The title is ours, not the template's.

	The template's TitleText is centred for a full-width window and is not guaranteed
	to exist under the name we would have to look it up by. Depending on it meant
	Refresh threw the moment it was missing, which left the chrome drawn and every
	piece of text blank -- a window that looks broken rather than one that reports a
	problem. Owning the font string costs one line and removes both risks.
	]]
	local templateTitle = _G[name .. "TitleText"]
	if templateTitle then templateTitle:Hide() end

	bar.title = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	bar.title:SetPoint("TOPLEFT", CONTENT_INSET, -8)
	bar.title:SetJustifyH("LEFT")
	bar.title:SetWordWrap(false)

	-- The template's close button hides the guide, which is what a close button on it
	-- should do.
	local closeButton = _G[name .. "CloseButton"]
	if closeButton then
		closeButton:SetScript("OnClick", function() GuideWindow.Hide() end)
		closeButton:SetScale(0.8)
	end

	-- Step label floats above the frame, clear of its chrome.
	bar.stepText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	bar.stepText:SetPoint("BOTTOM", bar, "TOP", 0, 0)
	bar.stepText:SetTextScale(0.95)

	bar.next = CreateIconButton(bar, 20, "Interface/Buttons/UI-SpellbookIcon-NextPage-Up",
		"Interface/Buttons/UI-SpellbookIcon-NextPage-Down", "Next step",
		function() GuideService.NextStep() end)
	bar.next:SetPoint("RIGHT", closeButton or bar, closeButton and "LEFT" or "RIGHT", -2, 0)

	bar.back = CreateIconButton(bar, 20, "Interface/Buttons/UI-SpellbookIcon-PrevPage-Up",
		"Interface/Buttons/UI-SpellbookIcon-PrevPage-Down", "Previous step",
		function() GuideService.PreviousStep() end)
	bar.back:SetPoint("RIGHT", bar.next, "LEFT", -2, 0)

	bar.settings = CreateIconButton(bar, 18, "Interface/Icons/INV_Misc_Gear_01", nil,
		"Guide options", function() GuideWindow.ShowMenu() end)
	bar.settings:SetPoint("RIGHT", bar.back, "LEFT", -4, 0)
	bar.title:SetPoint("RIGHT", bar.settings, "LEFT", -6, 0)
	-- Crop the gear's baked-in border. GetNormalTexture can return nothing, so this is
	-- guarded rather than chained.
	local gear = bar.settings:GetNormalTexture()
	if gear and type(gear.SetTexCoord) == "function" then
		gear:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	end

	-- Progress hairline along the bottom of the frame, inside its border.
	bar.progressTrack = bar:CreateTexture(nil, "ARTWORK")
	bar.progressTrack:SetColorTexture(PROGRESS_COLOR[1], PROGRESS_COLOR[2], PROGRESS_COLOR[3])
	bar.progressTrack:SetAlpha(0.25)
	bar.progressTrack:SetHeight(PROGRESS_HEIGHT)
	bar.progressTrack:SetPoint("BOTTOMLEFT", CONTENT_INSET, 6)
	bar.progressTrack:SetPoint("BOTTOMRIGHT", -12, 6)

	bar.progressFill = bar:CreateTexture(nil, "OVERLAY")
	bar.progressFill:SetColorTexture(PROGRESS_COLOR[1], PROGRESS_COLOR[2], PROGRESS_COLOR[3])
	bar.progressFill:SetHeight(PROGRESS_HEIGHT)
	bar.progressFill:SetPoint("BOTTOMLEFT", bar.progressTrack, "BOTTOMLEFT", 0, 0)
	bar.progressFill:SetWidth(1)

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
	stepPanel:SetPoint("TOPLEFT", header, "BOTTOMLEFT", STEP_PANEL_INSET, -PANEL_GAP)
	stepPanel:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -STEP_PANEL_INSET, -PANEL_GAP)
	stepPanel:SetHeight(52)

	stepPanel.icon = stepPanel:CreateTexture(nil, "ARTWORK")
	stepPanel.icon:SetSize(18, 18)
	stepPanel.icon:SetPoint("TOPLEFT", 14, -14)

	-- Highlight, not Normal: Normal is the gold face, and a whole paragraph of gold is
	-- tiring. White body text with the names picked out in gold reads far faster.
	stepPanel.text = stepPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	-- TOPLEFT is re-anchored in Refresh depending on whether the step has an icon.
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
-- The template supplies the portrait socket, so there is no separate ring texture to
-- expose. Kept returning nil rather than removed, so callers need not care which
-- header style is in use.
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
			line:SetTextColor(0.45, 0.68, 0.45)
		else
			line:SetTextColor(0.80, 0.80, 0.80)
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
		header.progressFill:Hide()
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
	local progress = total > 0 and (index / total) or 0
	local trackWidth = header.progressTrack:GetWidth()
	-- GetWidth returns nothing useful before the frame has been laid out.
	if type(trackWidth) == "number" and trackWidth > 0 and progress > 0 then
		header.progressFill:SetWidth(math.max(1, trackWidth * progress))
		header.progressFill:Show()
	else
		header.progressFill:Hide()
	end

	local current = guide.steps[index]
	if current then
		-- Most steps have no icon now. Close the gap rather than leaving a hole where
		-- one would have been, so text starts at the same place either way.
		local icon = GuideTaskTypes.GetIcon(current)
		stepPanel.icon:SetShown(icon ~= nil)
		if icon then
			stepPanel.icon:SetTexture(icon)
			stepPanel.text:SetPoint("TOPLEFT", stepPanel.icon, "TOPRIGHT", 8, 2)
		else
			stepPanel.text:SetPoint("TOPLEFT", stepPanel, "TOPLEFT", 14, -12)
		end
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
