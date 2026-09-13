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

Presentation: separate translucent panels floating on the world rather than one solid
window. A guide sits on screen for hours while you play, so it has to stay out of the
way -- an opaque frame the size of this one is a wall. Each panel carries the tooltip
backdrop at partial alpha with a tan border, so the world still reads through it.

	  (ring) [ title            < > cog ]     <- header, ring overhangs the left
	         [ progress bar               ]
	[ CURRENT STEP                        ]   <- its own panel
	[ upcoming steps, scrolled            ]   <- and another

Portrait layering matters and is easy to get wrong: portrait-ring-withbg has an OPAQUE
background, so the ring goes DOWN FIRST at BACKGROUND and the icon sits on top at
ARTWORK. Drawing the ring above the icon paints over the very thing it frames -- which
is exactly what an earlier version did, rendering a black disc.
ui/EncounterJournal.lua's version icon already uses this ordering correctly.

Behaviours: top-right by default, left-drag to move, right-click passes through so the
camera still turns, lockable to ignore the mouse entirely, its own scale, and
auto-hide inside instances unless the step itself is an instance step.
]]

GuideWindow = { }

local WIDTH = 300
local HEADER_HEIGHT = 40
local RING_SIZE, PORTRAIT_SIZE = 52, 34
local PANEL_GAP = 4
local LIST_HEIGHT = 210
local ROW_SPACING = 5
local MAX_UPCOMING = 40

local frame, header, currentPanel, listPanel, scrollFrame, rowPool
local isMoving
local initialised

local function IsLocked()
	return SettingsService.IsGuideLocked()
end

--[[
The translucent panel look. Uses Blizzard's shared constant where it exists and an
equivalent literal where it does not, so neither client is assumed.
]]
local panels = { }

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

-- Buttons -----------------------------------------------------------------------

local function CreateIconButton(parent, up, down, tooltip, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(20, 20)
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

-- Header --------------------------------------------------------------------------

local function CreateHeader(parent)
	local bar = CreatePanel(parent)
	bar:SetHeight(HEADER_HEIGHT)
	-- Inset from the left so the portrait ring can overhang into the gap.
	bar:SetPoint("TOPLEFT", parent, "TOPLEFT", RING_SIZE - 20, 0)
	bar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)

	-- Ring FIRST, at BACKGROUND: this atlas has an opaque background and would hide
	-- the portrait if drawn above it.
	bar.ring = parent:CreateTexture(nil, "BACKGROUND")
	bar.ring:SetTexture("Interface/Common/portrait-ring-withbg")
	bar.ring:SetSize(RING_SIZE, RING_SIZE)
	bar.ring:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 4)

	bar.portrait = parent:CreateTexture(nil, "ARTWORK")
	bar.portrait:SetTexture("Interface/EncounterJournal/UI-EJ-PortraitIcon")
	bar.portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
	bar.portrait:SetPoint("CENTER", bar.ring, "CENTER", 0, 0)
	local mask = parent:CreateMaskTexture()
	mask:SetAllPoints(bar.portrait)
	mask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask",
		"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	bar.portrait:AddMaskTexture(mask)

	bar.settings = CreateIconButton(bar, "Interface/GossipFrame/BinderGossipIcon", nil,
		"Guide options", function(self) GuideWindow.ShowMenu(self) end)
	bar.settings:SetPoint("RIGHT", -8, 2)

	bar.next = CreateIconButton(bar, "Interface/Buttons/UI-SpellbookIcon-NextPage-Up",
		"Interface/Buttons/UI-SpellbookIcon-NextPage-Down", "Next step",
		function() GuideService.NextStep() end)
	bar.next:SetPoint("RIGHT", bar.settings, "LEFT", -4, 0)

	bar.back = CreateIconButton(bar, "Interface/Buttons/UI-SpellbookIcon-PrevPage-Up",
		"Interface/Buttons/UI-SpellbookIcon-PrevPage-Down", "Previous step",
		function() GuideService.PreviousStep() end)
	bar.back:SetPoint("RIGHT", bar.next, "LEFT", -2, 0)

	bar.title = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	bar.title:SetPoint("LEFT", 14, 4)
	bar.title:SetPoint("RIGHT", bar.back, "LEFT", -6, 0)
	bar.title:SetJustifyH("LEFT")
	bar.title:SetWordWrap(false)

	-- A thin progress bar reading the whole guide, so you can see how far through the
	-- zone you are without counting steps.
	bar.progress = CreateFrame("StatusBar", nil, bar)
	bar.progress:SetHeight(5)
	bar.progress:SetPoint("BOTTOMLEFT", 12, 7)
	bar.progress:SetPoint("BOTTOMRIGHT", -12, 7)
	bar.progress:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
	bar.progress:SetStatusBarColor(0.25, 0.55, 0.85)
	bar.progress:SetMinMaxValues(0, 1)
	bar.progress:SetValue(0)
	bar.progress.bg = bar.progress:CreateTexture(nil, "BACKGROUND")
	bar.progress.bg:SetAllPoints()
	bar.progress.bg:SetColorTexture(0, 0, 0, 0.5)

	bar.stepText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bar.stepText:SetPoint("BOTTOMRIGHT", bar.progress, "TOPRIGHT", 0, 1)
	bar.stepText:SetTextColor(0.65, 0.85, 1)

	return bar
end

-- Step rows ----------------------------------------------------------------------

--[[
One upcoming step. Clicking it jumps straight there, so a quest done out of order does
not mean clicking Next repeatedly.
]]
local function CreateRow(parent)
	local row = CreateFrame("Button", nil, parent)
	row:SetHeight(20)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(14, 14)
	row.icon:SetPoint("TOPLEFT", 0, -2)
	row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.text:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, 2)
	row.text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
	row.text:SetJustifyH("LEFT")
	row.text:SetJustifyV("TOP")
	row.text:SetSpacing(2)
	row.text:SetTextColor(0.80, 0.80, 0.80)
	row.highlight = row:CreateTexture(nil, "BACKGROUND")
	row.highlight:SetAllPoints()
	row.highlight:SetColorTexture(1, 0.82, 0, 0.10)
	row.highlight:Hide()
	row:SetScript("OnEnter", function(self) self.highlight:Show() end)
	row:SetScript("OnLeave", function(self) self.highlight:Hide() end)
	row:SetScript("OnClick", function(self)
		if self.stepIndex then
			GuideService.SetStepIndex(self.stepIndex)
		end
	end)
	return row
end

local function AcquireRow(index)
	if not rowPool[index] then
		rowPool[index] = CreateRow(scrollFrame.child)
	end
	return rowPool[index]
end

-- Frame --------------------------------------------------------------------------

local function CreateWindow()
	-- The container itself is invisible: the panels below are the visible parts, so
	-- the world shows through the gaps between them.
	frame = CreateFrame("Frame", addonName .. "_GuideWindow", UIParent)
	frame:SetSize(WIDTH, 240)
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

	-- Current step, its own panel so the eye lands on it first.
	currentPanel = CreatePanel(frame, 0.85)
	currentPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -(HEADER_HEIGHT + PANEL_GAP))
	currentPanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -(HEADER_HEIGHT + PANEL_GAP))
	currentPanel:SetHeight(50)

	currentPanel.icon = currentPanel:CreateTexture(nil, "ARTWORK")
	currentPanel.icon:SetSize(18, 18)
	currentPanel.icon:SetPoint("TOPLEFT", 12, -12)

	currentPanel.text = currentPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	currentPanel.text:SetPoint("TOPLEFT", currentPanel.icon, "TOPRIGHT", 8, 2)
	currentPanel.text:SetPoint("RIGHT", currentPanel, "RIGHT", -12, 0)
	currentPanel.text:SetJustifyH("LEFT")
	currentPanel.text:SetJustifyV("TOP")
	currentPanel.text:SetSpacing(3)

	-- Upcoming steps in a panel of their own.
	listPanel = CreatePanel(frame)
	listPanel:SetPoint("TOPLEFT", currentPanel, "BOTTOMLEFT", 0, -PANEL_GAP)
	listPanel:SetPoint("TOPRIGHT", currentPanel, "BOTTOMRIGHT", 0, -PANEL_GAP)
	listPanel:SetHeight(LIST_HEIGHT)

	-- Plain ScrollFrame with MinimalScrollBar, the pattern
	-- ui/DynamicContentScroller.lua already proves on both clients -- ScrollBox list
	-- views are the API that diverges between Era and BCC.
	scrollFrame = CreateFrame("ScrollFrame", nil, listPanel)
	scrollFrame:SetPoint("TOPLEFT", 12, -10)
	scrollFrame:SetPoint("BOTTOMRIGHT", -24, 10)
	scrollFrame.scrollBarX = -10
	scrollFrame.scrollBarTopY = -4
	scrollFrame.scrollBarBottomY = 4
	scrollFrame.scrollBarTemplate = "MinimalScrollBar"
	scrollFrame.child = CreateFrame("Frame", nil, scrollFrame)
	scrollFrame.child:SetSize(WIDTH - 40, 10)
	scrollFrame.child:SetPoint("TOPLEFT")
	scrollFrame:SetScrollChild(scrollFrame.child)
	if ScrollFrame_OnLoad then
		pcall(ScrollFrame_OnLoad, scrollFrame)
	end

	frame.empty = listPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	frame.empty:SetPoint("TOPLEFT", 14, -14)
	frame.empty:SetPoint("RIGHT", listPanel, "RIGHT", -14, 0)
	frame.empty:SetJustifyH("LEFT")
	frame.empty:Hide()

	rowPool = { }
	ApplyScale()
	frame:Hide()
end

-- Public -------------------------------------------------------------------------

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
		elseif key == "Locked" then
			frame:EnableMouse(not IsLocked())
		end
		GuideWindow.Refresh()
	end)
	PlayerContextService.RegisterListener(function(_, changed)
		if changed.inInstance or changed.level then
			GuideWindow.Refresh()
		end
	end)
end

--[[
Sizes the container to whatever the panels ended up needing, so the invisible frame
matches its visible contents and dragging picks up where you expect.
]]
local function ResizeToContents()
	local height = HEADER_HEIGHT + PANEL_GAP + currentPanel:GetHeight()
	if listPanel:IsShown() then
		height = height + PANEL_GAP + listPanel:GetHeight()
	end
	frame:SetHeight(height)
end

function GuideWindow.Refresh()
	if not initialised then return end

	local guide = GuideService.GetCurrentGuide()

	if not guide then
		header.title:SetText("Levelling Guide")
		header.stepText:SetText("")
		header.progress:SetValue(0)
		header.back:SetEnabled(false)
		header.next:SetEnabled(false)
		currentPanel:Hide()
		listPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -(HEADER_HEIGHT + PANEL_GAP))
		listPanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -(HEADER_HEIGHT + PANEL_GAP))
		listPanel:SetHeight(70)
		listPanel:Show()
		frame.empty:SetText("No guide selected." ..
			string.char(10) .. string.char(10) ..
			"Use the cog above to choose one.")
		frame.empty:Show()
		for _, row in pairs(rowPool) do row:Hide() end
		frame:SetHeight(HEADER_HEIGHT + PANEL_GAP + 70)
		frame:SetShown(ShouldBeShown())
		return
	end

	frame.empty:Hide()
	currentPanel:Show()
	listPanel:ClearAllPoints()
	listPanel:SetPoint("TOPLEFT", currentPanel, "BOTTOMLEFT", 0, -PANEL_GAP)
	listPanel:SetPoint("TOPRIGHT", currentPanel, "BOTTOMRIGHT", 0, -PANEL_GAP)
	listPanel:SetHeight(LIST_HEIGHT)

	local index = GuideService.GetStepIndex(guide)
	local total = #guide.steps
	header.title:SetText(guide.title)
	header.stepText:SetText(("%d / %d"):format(index, total))
	header.progress:SetValue(total > 0 and (index / total) or 0)

	local current = guide.steps[index]
	if current then
		currentPanel.icon:SetTexture(GuideTaskTypes.GetIcon(current))
		currentPanel.text:SetText(GuideTaskTypes.GetText(current))
		-- Grow to the text rather than clipping a step that carries a note.
		currentPanel:SetHeight(math.max(46, currentPanel.text:GetStringHeight() + 28))
	end

	local upcoming = GuideService.GetSteps(index + 1, MAX_UPCOMING)
	local offsetY = 0
	for position, entry in ipairs(upcoming) do
		local row = AcquireRow(position)
		row.stepIndex = entry.index
		row.icon:SetTexture(GuideTaskTypes.GetIcon(entry.task))
		row.text:SetText(GuideTaskTypes.GetText(entry.task))
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", scrollFrame.child, "TOPLEFT", 0, -offsetY)
		row:SetPoint("RIGHT", scrollFrame.child, "RIGHT", 0, 0)
		local height = math.max(20, row.text:GetStringHeight() + 6)
		row:SetHeight(height)
		row:Show()
		offsetY = offsetY + height + ROW_SPACING
	end
	for position = #upcoming + 1, #rowPool do
		rowPool[position]:Hide()
	end
	scrollFrame.child:SetHeight(math.max(10, offsetY))

	-- Shrink the list panel when there is little left, rather than leaving dead space.
	listPanel:SetHeight(math.min(LIST_HEIGHT, math.max(40, offsetY + 20)))
	listPanel:SetShown(#upcoming > 0)

	if #upcoming == 0 then
		frame.empty:SetText("Guide complete.")
		frame.empty:Show()
		listPanel:SetHeight(46)
		listPanel:Show()
	end

	header.back:SetEnabled(GuideService.HasPreviousStep())
	header.next:SetEnabled(GuideService.HasNextStep() or (guide.next ~= nil))

	ResizeToContents()
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
Cog menu: guide selection, the automation toggles and window options. Rebuilt every
time it opens so the ticks reflect the current settings rather than whatever was true
when the menu was first created.
]]
local menuFrame

function GuideWindow.ShowMenu(anchor)
	if not menuFrame then
		menuFrame = CreateFrame("Frame", addonName .. "_GuideMenu", UIParent, "UIDropDownMenuTemplate")
	end
	local function Initialize(_, level)
		if level == 1 then
			local info = UIDropDownMenu_CreateInfo()
			info.isTitle, info.notCheckable = true, true
			info.text = "Levelling Guide"
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.text = "Choose guide"
			info.notCheckable = true
			info.hasArrow = true
			info.value = "guides"
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.isTitle, info.notCheckable = true, true
			info.text = "Automation"
			UIDropDownMenu_AddButton(info, level)

			local toggles = {
				{ "Advance steps automatically",
					SettingsService.IsGuideAutoAdvanceEnabled,
					SettingsService.SetGuideAutoAdvanceEnabled },
				{ "Accept guide quests automatically",
					SettingsService.IsGuideAutoAcceptEnabled,
					SettingsService.SetGuideAutoAcceptEnabled },
				{ "Hand in guide quests automatically",
					SettingsService.IsGuideAutoTurnInEnabled,
					SettingsService.SetGuideAutoTurnInEnabled },
			}
			for _, toggle in ipairs(toggles) do
				local label, get, set = toggle[1], toggle[2], toggle[3]
				info = UIDropDownMenu_CreateInfo()
				info.text = label
				info.checked = get()
				info.keepShownOnClick = true
				info.func = function() set(not get()) end
				UIDropDownMenu_AddButton(info, level)
			end

			info = UIDropDownMenu_CreateInfo()
			info.isTitle, info.notCheckable = true, true
			info.text = "Window"
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.text = "Lock window"
			info.checked = SettingsService.IsGuideLocked()
			info.keepShownOnClick = true
			info.func = function()
				SettingsService.SetGuideLocked(not SettingsService.IsGuideLocked())
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.text = "Opacity"
			info.notCheckable = true
			info.hasArrow = true
			info.value = "opacity"
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.text = "Reset position"
			info.notCheckable = true
			info.func = function() GuideWindow.ResetPosition() end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.text = "Restart this guide"
			info.notCheckable = true
			info.func = function() GuideService.ResetProgress() end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.text = "Hide guide"
			info.notCheckable = true
			info.func = function() GuideWindow.Hide() end
			UIDropDownMenu_AddButton(info, level)
		elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "opacity" then
			local current = SettingsService.GetGuideOpacity()
			for _, value in ipairs({ 0.4, 0.55, 0.7, 0.85, 1.0 }) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = ("%d%%"):format(value * 100)
				info.checked = math.abs(current - value) < 0.01
				info.func = function() SettingsService.SetGuideOpacity(value) end
				UIDropDownMenu_AddButton(info, level)
			end
		elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "guides" then
			local current = GuideService.GetCurrentGuide()
			for _, guide in ipairs(GuideService.GetGuidesForCharacter()) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = ("%s (%d-%d)"):format(guide.title, guide.levels.min, guide.levels.max)
				info.checked = current and current.id == guide.id
				info.func = function() GuideService.SetCurrentGuide(guide.id) end
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end
	UIDropDownMenu_Initialize(menuFrame, Initialize, "MENU")
	ToggleDropDownMenu(1, nil, menuFrame, anchor or "cursor", 0, 0)
end

-- Initialise once the character is known; the window must be able to appear with the
-- main Adventure Guide window never having been opened.
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function()
	GuideWindow.EnsureCreated()
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
		print(("  anchor:         %s %.0f,%.0f  scale %.2f"):format(
			tostring(point), x or 0, y or 0, frame:GetScale()))
	end
end
