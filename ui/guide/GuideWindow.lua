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

Built on PortraitFrameTemplate, the same template as the main window
(ui/EncounterJournal.lua), so the portrait socket, gold frame, title bar and close
button all come from Blizzard rather than being assembled by hand. An earlier version
hand-built the portrait ring and drew portrait-ring-withbg over the icon -- that atlas
has an opaque background, so it painted over the very thing it was meant to frame.

Layout, following what the established guide addons all converge on:

	portrait | title
	         | step counter        [back] [next] [cog]
	+-----------------------------------------------+
	| CURRENT STEP, given room to breathe            |
	+-----------------------------------------------+
	| upcoming steps, scrolled                       |
	+-----------------------------------------------+

Behaviours: top-right by default, left-drag to move, right-click passes through so the
camera still turns, lockable to ignore the mouse entirely, its own scale, and
auto-hide inside instances unless the step itself is an instance step.
]]

GuideWindow = { }

local WIDTH, HEIGHT = 310, 400
local CURRENT_HEIGHT = 86
local ROW_SPACING = 4
local MAX_UPCOMING = 40

local frame, currentPanel, scrollFrame, rowPool
local isMoving
local initialised

local function IsLocked()
	return SettingsService.IsGuideLocked()
end

--[[
Whether the window should be on screen at all: the user's toggle, plus the
auto-hide-in-instances rule. An instance step is the exception -- if the guide is
telling you to run Deadmines, hiding it inside Deadmines is unhelpful.

Deliberately NOT conditional on a guide being selected. The picker lives in this
window's cog menu, so hiding when no guide is chosen would make choosing one
impossible.
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
	button:SetSize(22, 22)
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
	row.text:SetTextColor(0.78, 0.78, 0.78)
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
	local name = addonName .. "_GuideWindow"
	frame = CreateFrame("Frame", name, UIParent, "PortraitFrameTemplate")
	frame:SetSize(WIDTH, HEIGHT)
	frame:SetFrameStrata("MEDIUM")
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(not IsLocked())
	frame:RegisterForDrag("LeftButton")

	-- Let right-click through to the world so the camera still turns over the frame.
	-- Not on every client, hence the guard.
	if frame.SetPassThroughButtons then
		pcall(frame.SetPassThroughButtons, frame, "RightButton")
	end

	frame.title = _G[name .. "TitleText"]
	frame.portrait = _G[name .. "Portrait"]
	if frame.portrait then
		frame.portrait:SetTexture("Interface/EncounterJournal/UI-EJ-PortraitIcon")
		-- The same circular mask the main window uses, so a square icon sits properly
		-- in the template's round socket.
		local mask = frame:CreateMaskTexture()
		mask:SetAllPoints(frame.portrait)
		mask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask",
			"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		frame.portrait:AddMaskTexture(mask)
	end

	local closeButton = _G[name .. "CloseButton"]
	if closeButton then
		closeButton:SetScript("OnClick", function()
			GuideWindow.Hide()
		end)
	end

	local saved = SavedVariables and SavedVariables.GuideWindowLocation
	if saved then
		frame:ClearAllPoints()
		local ok = pcall(function() frame:SetPoint(unpack(saved)) end)
		if not ok then
			frame:ClearAllPoints()
			frame:SetPoint("TOPRIGHT", -40, -240)
		end
	else
		frame:SetPoint("TOPRIGHT", -40, -240)
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

	-- Step counter, tucked under the title bar next to the portrait.
	frame.stepText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	frame.stepText:SetPoint("TOPLEFT", 62, -30)
	frame.stepText:SetJustifyH("LEFT")
	frame.stepText:SetTextColor(0.65, 0.85, 1)

	frame.settings = CreateIconButton(frame, "Interface/GossipFrame/BinderGossipIcon", nil,
		"Guide options", function(self) GuideWindow.ShowMenu(self) end)
	frame.settings:SetPoint("TOPRIGHT", -32, -28)

	frame.next = CreateIconButton(frame, "Interface/Buttons/UI-SpellbookIcon-NextPage-Up",
		"Interface/Buttons/UI-SpellbookIcon-NextPage-Down", "Next step",
		function() GuideService.NextStep() end)
	frame.next:SetPoint("RIGHT", frame.settings, "LEFT", -4, 0)

	frame.back = CreateIconButton(frame, "Interface/Buttons/UI-SpellbookIcon-PrevPage-Up",
		"Interface/Buttons/UI-SpellbookIcon-PrevPage-Down", "Previous step",
		function() GuideService.PreviousStep() end)
	frame.back:SetPoint("RIGHT", frame.next, "LEFT", -2, 0)

	-- Current step gets its own panel, so the eye lands on it first.
	currentPanel = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	currentPanel:SetHeight(CURRENT_HEIGHT)
	currentPanel:SetPoint("TOPLEFT", 8, -56)
	currentPanel:SetPoint("TOPRIGHT", -8, -56)

	currentPanel.icon = currentPanel:CreateTexture(nil, "ARTWORK")
	currentPanel.icon:SetSize(20, 20)
	currentPanel.icon:SetPoint("TOPLEFT", 10, -10)

	currentPanel.text = currentPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	currentPanel.text:SetPoint("TOPLEFT", currentPanel.icon, "TOPRIGHT", 8, 3)
	currentPanel.text:SetPoint("RIGHT", currentPanel, "RIGHT", -10, 0)
	currentPanel.text:SetJustifyH("LEFT")
	currentPanel.text:SetJustifyV("TOP")
	currentPanel.text:SetSpacing(3)

	-- Upcoming steps, scrolled. Plain ScrollFrame with MinimalScrollBar, the pattern
	-- ui/DynamicContentScroller.lua already proves on both clients -- ScrollBox list
	-- views are the API that diverges between Era and BCC.
	local listInset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	listInset:SetPoint("TOPLEFT", currentPanel, "BOTTOMLEFT", 0, -6)
	listInset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
	frame.listInset = listInset

	scrollFrame = CreateFrame("ScrollFrame", nil, listInset)
	scrollFrame:SetPoint("TOPLEFT", 6, -6)
	scrollFrame:SetPoint("BOTTOMRIGHT", -22, 6)
	scrollFrame.scrollBarX = -12
	scrollFrame.scrollBarTopY = -6
	scrollFrame.scrollBarBottomY = 6
	scrollFrame.scrollBarTemplate = "MinimalScrollBar"
	scrollFrame.child = CreateFrame("Frame", nil, scrollFrame)
	scrollFrame.child:SetSize(WIDTH - 56, 10)
	scrollFrame.child:SetPoint("TOPLEFT")
	scrollFrame:SetScrollChild(scrollFrame.child)
	if ScrollFrame_OnLoad then
		pcall(ScrollFrame_OnLoad, scrollFrame)
	end

	frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	frame.empty:SetPoint("TOPLEFT", listInset, "TOPLEFT", 10, -10)
	frame.empty:SetPoint("RIGHT", listInset, "RIGHT", -10, 0)
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

function GuideWindow.Refresh()
	if not initialised then return end

	local guide = GuideService.GetCurrentGuide()

	if not guide then
		frame.title:SetText("Levelling Guide")
		frame.stepText:SetText("")
		frame.back:SetEnabled(false)
		frame.next:SetEnabled(false)
		currentPanel:Hide()
		frame.listInset:SetPoint("TOPLEFT", 8, -56)
		frame.empty:SetText("No guide selected." ..
			string.char(10) .. string.char(10) ..
			"Use the cog above to choose one.")
		frame.empty:Show()
		for _, row in pairs(rowPool) do row:Hide() end
		frame:SetShown(ShouldBeShown())
		return
	end

	frame.empty:Hide()
	currentPanel:Show()
	frame.listInset:SetPoint("TOPLEFT", currentPanel, "BOTTOMLEFT", 0, -6)

	local index = GuideService.GetStepIndex(guide)
	frame.title:SetText(guide.title)
	frame.stepText:SetText(("Step %d of %d"):format(index, #guide.steps))

	local current = guide.steps[index]
	if current then
		currentPanel.icon:SetTexture(GuideTaskTypes.GetIcon(current))
		currentPanel.text:SetText(GuideTaskTypes.GetText(current))
	end

	-- Upcoming steps below, reusing pooled rows.
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

	if #upcoming == 0 then
		frame.empty:SetText("Guide complete.")
		frame.empty:Show()
	end

	frame.back:SetEnabled(GuideService.HasPreviousStep())
	frame.next:SetEnabled(GuideService.HasNextStep() or (guide.next ~= nil))

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
	frame:SetPoint("TOPRIGHT", -40, -240)
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
			info.text = "Reset position"
			info.notCheckable = true
			info.func = function() GuideWindow.ResetPosition() end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.text = "Restart this guide"
			info.notCheckable = true
			info.func = function() GuideService.ResetProgress() end
			UIDropDownMenu_AddButton(info, level)
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
