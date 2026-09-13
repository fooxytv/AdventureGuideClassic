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
module that initialises itself rather than going through UI.Add.

Behaviours matched from the genre (rebuilt from Blizzard templates, nothing copied):
top-right by default, left-drag to move, right-click passes through so the camera
still turns, lockable to ignore the mouse entirely, its own scale, auto-hide inside
instances, and no title bar -- the header is the chrome.
]]

GuideWindow = { }

local NEWLINE = string.char(10)
local WIDTH = 242
local HEADER_HEIGHT = 44
local ROW_HEIGHT = 34
local VISIBLE_STEPS = 5
local PADDING = 10

local frame, header, rows
local isMoving
local initialised

local function IsLocked()
	return SettingsService.IsGuideLocked()
end

--[[
Whether the window should be on screen at all: the user's toggle, plus the
auto-hide-in-instances rule. An instance step is the exception -- if the guide is
telling you to run Deadmines, hiding it inside Deadmines is unhelpful.
]]
local function ShouldBeShown()
	if not SettingsService.IsGuideShown() then return false end
	-- Deliberately NOT conditional on a guide being selected. The picker lives in this
	-- window's cog menu, so hiding when no guide is chosen makes choosing one
	-- impossible -- the window has to be able to show its own empty state.
	if PlayerContextService.IsInInstance() then
		local step = GuideService.GetCurrentStep()
		if not (step and step.instance) then
			return false
		end
	end
	return true
end

-- Header ----------------------------------------------------------------------

local function CreateHeaderButton(parent, atlasUp, atlasDown, tooltip, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(20, 20)
	button:SetNormalTexture(atlasUp)
	button:SetPushedTexture(atlasDown or atlasUp)
	button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(tooltip)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return button
end

local function CreateHeader(parent)
	local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	bar:SetHeight(HEADER_HEIGHT)
	bar:SetPoint("TOPLEFT", 22, 0)
	bar:SetPoint("TOPRIGHT", 0, 0)
	bar.backdropInfo = BACKDROP_GLUE_TOOLTIP_16_16 or {
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileEdge = true, tileSize = 16, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	}
	if bar.OnBackdropLoaded then
		bar:OnBackdropLoaded()
		bar:SetBackdropBorderColor(0.78, 0.73, 0.56)
	end

	-- Portrait overhanging the left edge, masked the way the main window's is.
	bar.portrait = bar:CreateTexture(nil, "ARTWORK")
	bar.portrait:SetSize(38, 38)
	bar.portrait:SetPoint("RIGHT", bar, "LEFT", 14, 2)
	bar.portrait:SetTexture("Interface\\EncounterJournal\\UI-EJ-PortraitIcon")
	local mask = bar:CreateMaskTexture()
	mask:SetAllPoints(bar.portrait)
	mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask",
		"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	bar.portrait:AddMaskTexture(mask)

	bar.ring = bar:CreateTexture(nil, "OVERLAY")
	bar.ring:SetTexture("Interface\\Common\\portrait-ring-withbg")
	bar.ring:SetPoint("TOPLEFT", bar.portrait, -6, 6)
	bar.ring:SetPoint("BOTTOMRIGHT", bar.portrait, 6, -6)

	bar.title = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	bar.title:SetPoint("TOPLEFT", 26, -7)
	bar.title:SetPoint("RIGHT", -68, 0)
	bar.title:SetJustifyH("LEFT")
	bar.title:SetWordWrap(false)

	bar.step = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bar.step:SetPoint("TOPLEFT", bar.title, "BOTTOMLEFT", 0, -3)
	bar.step:SetJustifyH("LEFT")
	bar.step:SetTextColor(0.65, 0.85, 1)

	bar.settings = CreateHeaderButton(bar, "Interface\\GossipFrame\\BinderGossipIcon", nil,
		"Guide options", function(self) GuideWindow.ShowMenu(self) end)
	bar.settings:SetPoint("TOPRIGHT", -6, -4)

	bar.back = CreateHeaderButton(bar, "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up",
		"Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down", "Previous step",
		function() GuideService.PreviousStep() end)
	bar.back:SetPoint("BOTTOMRIGHT", -32, 5)

	bar.next = CreateHeaderButton(bar, "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up",
		"Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down", "Next step",
		function() GuideService.NextStep() end)
	bar.next:SetPoint("BOTTOMRIGHT", -8, 5)

	return bar
end

-- Step rows -------------------------------------------------------------------

local function CreateRow(parent, index)
	local row = CreateFrame("Button", nil, parent)
	row:SetSize(WIDTH - 24, ROW_HEIGHT)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(16, 16)
	row.icon:SetPoint("TOPLEFT", 2, -3)
	row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.text:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, 2)
	row.text:SetPoint("RIGHT", row, "RIGHT", -4, 0)
	row.text:SetJustifyH("LEFT")
	row.text:SetJustifyV("TOP")
	row.text:SetSpacing(2)
	row.highlight = row:CreateTexture(nil, "BACKGROUND")
	row.highlight:SetAllPoints()
	row.highlight:SetColorTexture(1, 0.82, 0, 0.08)
	row.highlight:Hide()

	-- Clicking a visible upcoming step jumps to it, so a skipped quest doesn't mean
	-- clicking Next repeatedly.
	row:SetScript("OnClick", function(self)
		if self.stepIndex then
			GuideService.SetStepIndex(self.stepIndex)
		end
	end)
	return row
end

-- Frame -----------------------------------------------------------------------

local function ApplyScale()
	if InCombatLockdown() then return end
	frame:SetScale(SettingsService.GetGuideScale())
end

local function SavePosition()
	SavedVariables.GuideWindowLocation = { frame:GetPoint() }
end

local function CreateWindow()
	frame = CreateFrame("Frame", "AdventureGuideClassic_GuideWindow", UIParent)
	frame:SetSize(WIDTH, HEADER_HEIGHT + 40)
	frame:SetFrameStrata("MEDIUM")
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(not IsLocked())
	frame:RegisterForDrag("LeftButton")

	-- Let right-click through to the world so the camera still turns over the frame.
	-- Not present on every client, hence the guard.
	if frame.SetPassThroughButtons then
		pcall(frame.SetPassThroughButtons, frame, "RightButton")
	end

	local saved = SavedVariables and SavedVariables.GuideWindowLocation
	if saved then
		frame:ClearAllPoints()
		local ok = pcall(function() frame:SetPoint(unpack(saved)) end)
		if not ok then
			frame:ClearAllPoints()
			frame:SetPoint("TOPRIGHT", -15, -330)
		end
	else
		frame:SetPoint("TOPRIGHT", -15, -330)
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

	rows = { }
	for index = 1, VISIBLE_STEPS do
		local row = CreateRow(frame, index)
		if index == 1 then
			row:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 4, -PADDING)
		else
			row:SetPoint("TOPLEFT", rows[index - 1], "BOTTOMLEFT", 0, -2)
		end
		rows[index] = row
	end

	frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	frame.empty:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 6, -PADDING)
	frame.empty:SetPoint("RIGHT", frame, "RIGHT", -6, 0)
	frame.empty:SetJustifyH("LEFT")
	frame.empty:SetText("No guide selected." .. NEWLINE .. NEWLINE .. "Click the button above to choose one.")
	frame.empty:Hide()

	ApplyScale()
	frame:Hide()
end

-- Public ----------------------------------------------------------------------

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
		header.title:SetText("Levelling Guide")
		header.step:SetText("")
		header.back:SetEnabled(false)
		header.next:SetEnabled(false)
		for _, row in ipairs(rows) do row:Hide() end
		frame.empty:Show()
		frame:SetHeight(HEADER_HEIGHT + 56)
		frame:SetShown(ShouldBeShown())
		return
	end

	frame.empty:Hide()
	local index = GuideService.GetStepIndex(guide)
	header.title:SetText(guide.title)
	header.step:SetText(("Step %d of %d"):format(index, #guide.steps))

	local steps = GuideService.GetSteps(index, VISIBLE_STEPS)
	local used = 0
	for position, row in ipairs(rows) do
		local entry = steps[position]
		if entry then
			used = used + 1
			row.stepIndex = entry.index
			row.icon:SetTexture(GuideTaskTypes.GetIcon(entry.task))
			row.text:SetText(GuideTaskTypes.GetText(entry.task))
			-- The current step reads at full strength; what follows is context.
			local isCurrent = (position == 1)
			row.text:SetTextColor(isCurrent and 1 or 0.65, isCurrent and 1 or 0.65, isCurrent and 1 or 0.65)
			row.icon:SetAlpha(isCurrent and 1 or 0.6)
			row.highlight:SetShown(isCurrent)
			row:SetHeight(math.max(ROW_HEIGHT, row.text:GetStringHeight() + 10))
			row:Show()
		else
			row:Hide()
		end
	end

	local height = HEADER_HEIGHT + PADDING * 2
	for position = 1, used do
		height = height + rows[position]:GetHeight() + 2
	end
	frame:SetHeight(height)

	header.back:SetEnabled(GuideService.HasPreviousStep())
	header.next:SetEnabled(GuideService.HasNextStep() or (guide.next ~= nil))

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
	frame:SetPoint("TOPRIGHT", -15, -330)
	SavePosition()
end

--[[
Right-click / cog menu: pick a guide, lock, reset. Built with the classic
UIDropDownMenu API, which is what the rest of the addon uses (ui/InstanceSelect.lua).
]]
local menuFrame

function GuideWindow.ShowMenu(anchor)
	if not menuFrame then
		menuFrame = CreateFrame("Frame", "AdventureGuideClassic_GuideMenu", UIParent, "UIDropDownMenuTemplate")
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
			info.text = "Lock window"
			info.checked = SettingsService.IsGuideLocked()
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

			info = UIDropDownMenu_CreateInfo()
			info.text = "Hide guide"
			info.notCheckable = true
			info.func = function() GuideWindow.Hide() end
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
_G.AGC_ResetGuidePosition = function() GuideWindow.ResetPosition() end
