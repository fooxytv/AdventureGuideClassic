--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
The guide's options panel.

A translucent panel in the same visual language as the guide window itself, rather
than a UIDropDownMenu. A dropdown is fine for three items; this has guide selection,
five toggles and an opacity control, and at that size a dropdown reads as a wall of
menu rows with no grouping. A panel can use headings, checkboxes and spacing to make
the shape of the thing obvious at a glance.

Sections: the guide recommended for this character, every guide available to it, the
automation toggles, then window options.

Rebuilt from scratch on each open, so every tick and highlight reflects live state.
]]

GuideMenu = { }

local WIDTH = 240
local PAD = 14
local ROW_HEIGHT = 22
local SECTION_GAP = 10

local frame
local rows = { }
local rowCount = 0

local function ApplyPanelBackdrop(panel)
	panel.backdropInfo = BACKDROP_GLUE_TOOLTIP_16_16 or {
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileEdge = true, tileSize = 16, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	}
	if panel.OnBackdropLoaded then
		panel:OnBackdropLoaded()
		panel:SetBackdropColor(0.04, 0.04, 0.05, SettingsService.GetGuideOpacity())
		panel:SetBackdropBorderColor(0.78, 0.73, 0.56, 0.95)
	end
end

--[[
Rows are pooled and re-laid out on every open. Each is one of three shapes -- heading,
check, or clickable label -- kept as a single widget with parts shown or hidden,
because rebuilding a handful of frames is far simpler than tracking three pools.
]]
local function AcquireRow()
	rowCount = rowCount + 1
	local row = rows[rowCount]
	if row then
		row:Show()
		return row
	end

	row = CreateFrame("Button", nil, frame)
	row:SetHeight(ROW_HEIGHT)

	row.highlight = row:CreateTexture(nil, "BACKGROUND")
	row.highlight:SetAllPoints()
	row.highlight:SetColorTexture(1, 0.82, 0, 0.12)
	row.highlight:Hide()

	row.check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
	row.check:SetSize(20, 20)
	row.check:SetPoint("LEFT", 2, 0)

	row.tick = row:CreateTexture(nil, "ARTWORK")
	row.tick:SetSize(16, 16)
	row.tick:SetPoint("LEFT", 4, 0)
	row.tick:SetTexture("Interface/Buttons/UI-CheckBox-Check")

	row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.label:SetJustifyH("LEFT")

	row.arrow = row:CreateTexture(nil, "ARTWORK")
	row.arrow:SetSize(14, 14)
	row.arrow:SetPoint("RIGHT", -4, 0)
	row.arrow:SetTexture("Interface/ChatFrame/ChatFrameExpandArrow")

	rows[rowCount] = row
	return row
end

local function ResetRow(row)
	row.check:Hide()
	row.tick:Hide()
	row.arrow:Hide()
	row.highlight:Hide()
	row:SetScript("OnEnter", nil)
	row:SetScript("OnLeave", nil)
	row:SetScript("OnClick", nil)
	row:EnableMouse(false)
	row.label:ClearAllPoints()
	row.label:SetPoint("LEFT", PAD, 0)
	row.label:SetPoint("RIGHT", -PAD, 0)
end

local function MakeInteractive(row, onClick)
	row:EnableMouse(true)
	row:SetScript("OnEnter", function(self) self.highlight:Show() end)
	row:SetScript("OnLeave", function(self) self.highlight:Hide() end)
	row:SetScript("OnClick", function()
		onClick()
		GuideMenu.Refresh()
	end)
end

local function AddHeading(text)
	local row = AcquireRow()
	ResetRow(row)
	row:SetHeight(ROW_HEIGHT)
	row.label:SetFontObject("GameFontNormal")
	row.label:SetTextColor(1, 0.82, 0)
	row.label:SetText(text)
	return row
end

local function AddCheck(text, isChecked, onToggle)
	local row = AcquireRow()
	ResetRow(row)
	row.label:SetFontObject("GameFontHighlight")
	row.label:SetTextColor(1, 1, 1)
	row.label:SetText(text)
	row.label:ClearAllPoints()
	row.label:SetPoint("LEFT", 28, 0)
	row.label:SetPoint("RIGHT", -PAD, 0)
	row.check:Show()
	row.check:SetChecked(isChecked)
	row.check:SetScript("OnClick", function()
		onToggle()
		GuideMenu.Refresh()
	end)
	MakeInteractive(row, onToggle)
	return row
end

local function AddGuideRow(guide, isCurrent)
	local row = AcquireRow()
	ResetRow(row)
	row.label:SetFontObject("GameFontHighlight")
	row.label:SetTextColor(1, 1, 1)
	row.label:SetText(guide.title)
	row.label:ClearAllPoints()
	row.label:SetPoint("LEFT", 26, 0)
	row.label:SetPoint("RIGHT", -PAD, 0)
	row.tick:SetShown(isCurrent)
	MakeInteractive(row, function() GuideService.SetCurrentGuide(guide.id) end)
	return row
end

local function AddAction(text, onClick)
	local row = AcquireRow()
	ResetRow(row)
	row.label:SetFontObject("GameFontHighlight")
	row.label:SetTextColor(0.85, 0.85, 0.85)
	row.label:SetText(text)
	row.label:ClearAllPoints()
	row.label:SetPoint("LEFT", 26, 0)
	row.label:SetPoint("RIGHT", -PAD, 0)
	MakeInteractive(row, onClick)
	return row
end

--[[
Opacity as a row of percentages rather than a slider: five discrete values cover the
useful range, and they can be read and clicked at a glance without dragging.
]]
local function AddOpacityRow()
	local row = AcquireRow()
	ResetRow(row)
	row:SetHeight(ROW_HEIGHT + 2)
	row.label:SetFontObject("GameFontHighlight")
	row.label:SetTextColor(1, 1, 1)
	row.label:SetText("Opacity")
	row.label:ClearAllPoints()
	row.label:SetPoint("LEFT", 26, 0)
	row.label:SetWidth(64)

	row.buttons = row.buttons or { }
	local current = SettingsService.GetGuideOpacity()
	local values = { 0.4, 0.55, 0.7, 0.85, 1.0 }
	for index, value in ipairs(values) do
		local button = row.buttons[index]
		if not button then
			button = CreateFrame("Button", nil, row)
			button:SetSize(28, 18)
			button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			button.text:SetAllPoints()
			button:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
			row.buttons[index] = button
		end
		button:ClearAllPoints()
		button:SetPoint("LEFT", row, "LEFT", 84 + (index - 1) * 29, 0)
		button.text:SetText(("%d"):format(value * 100))
		if math.abs(current - value) < 0.01 then
			button.text:SetTextColor(1, 0.82, 0)
		else
			button.text:SetTextColor(0.6, 0.6, 0.6)
		end
		button:SetScript("OnClick", function()
			SettingsService.SetGuideOpacity(value)
			GuideMenu.Refresh()
		end)
		button:Show()
	end
	return row
end

local function AddSpacer(height)
	local row = AcquireRow()
	ResetRow(row)
	row:SetHeight(height or SECTION_GAP)
	row.label:SetText("")
	return row
end

-- Build -----------------------------------------------------------------------------

local function Create()
	frame = CreateFrame("Frame", addonName .. "_GuideMenuPanel", UIParent, "BackdropTemplate")
	frame:SetWidth(WIDTH)
	frame:SetFrameStrata("DIALOG")
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	ApplyPanelBackdrop(frame)

	frame.icon = frame:CreateTexture(nil, "ARTWORK")
	frame.icon:SetSize(22, 22)
	frame.icon:SetPoint("TOPLEFT", PAD, -12)
	frame.icon:SetTexture("Interface/EncounterJournal/UI-EJ-PortraitIcon")

	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.title:SetPoint("LEFT", frame.icon, "RIGHT", 8, 0)
	frame.title:SetText("Levelling Guides")

	-- Escape closes it, the way any panel should.
	table.insert(UISpecialFrames, frame:GetName())
	frame:Hide()
end

function GuideMenu.Refresh()
	if not frame or not frame:IsShown() then return end

	-- Hide every pooled row, then rebuild from scratch.
	for _, row in ipairs(rows) do
		row:Hide()
		if row.buttons then
			for _, button in ipairs(row.buttons) do button:Hide() end
		end
	end
	rowCount = 0

	ApplyPanelBackdrop(frame)

	local current = GuideService.GetCurrentGuide()
	local recommended = GuideService.GetGuideForLevel()
	local available = GuideService.GetGuidesForCharacter()

	AddSpacer(30)

	if recommended then
		AddHeading("Recommended for you")
		AddGuideRow(recommended, current and current.id == recommended.id)
		AddSpacer()
	end

	AddHeading("All guides")
	if #available == 0 then
		local row = AddAction("None available for this character", function() end)
		row:EnableMouse(false)
	else
		for _, guide in ipairs(available) do
			if not (recommended and guide.id == recommended.id) then
				AddGuideRow(guide, current and current.id == guide.id)
			end
		end
	end
	AddSpacer()

	AddHeading("Automation")
	AddCheck("Advance steps automatically",
		SettingsService.IsGuideAutoAdvanceEnabled(),
		function() SettingsService.SetGuideAutoAdvanceEnabled(
			not SettingsService.IsGuideAutoAdvanceEnabled()) end)
	AddCheck("Accept guide quests",
		SettingsService.IsGuideAutoAcceptEnabled(),
		function() SettingsService.SetGuideAutoAcceptEnabled(
			not SettingsService.IsGuideAutoAcceptEnabled()) end)
	AddCheck("Hand in guide quests",
		SettingsService.IsGuideAutoTurnInEnabled(),
		function() SettingsService.SetGuideAutoTurnInEnabled(
			not SettingsService.IsGuideAutoTurnInEnabled()) end)
	AddSpacer()

	AddHeading("Window")
	AddCheck("Lock window", SettingsService.IsGuideLocked(),
		function() SettingsService.SetGuideLocked(not SettingsService.IsGuideLocked()) end)
	AddOpacityRow()
	AddAction("Reset position", function() GuideWindow.ResetPosition() end)
	AddAction("Restart this guide", function() GuideService.ResetProgress() end)
	AddAction("Hide guide", function()
		GuideWindow.Hide()
		GuideMenu.Close()
	end)
	AddSpacer(6)

	-- Stack the rows and size the panel to whatever they came to.
	local offsetY = 0
	for index = 1, rowCount do
		local row = rows[index]
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -offsetY)
		row:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		offsetY = offsetY + row:GetHeight()
	end
	frame:SetHeight(offsetY + 8)
end

function GuideMenu.Open(anchorTo)
	if not frame then Create() end
	frame:ClearAllPoints()
	if anchorTo then
		frame:SetPoint("TOPLEFT", anchorTo, "BOTTOMRIGHT", 4, 0)
	else
		frame:SetPoint("CENTER")
	end
	frame:Show()
	GuideMenu.Refresh()
end

function GuideMenu.Close()
	if frame then frame:Hide() end
end

function GuideMenu.Toggle(anchorTo)
	if frame and frame:IsShown() then
		GuideMenu.Close()
	else
		GuideMenu.Open(anchorTo)
	end
end

function GuideMenu.IsShown()
	return frame ~= nil and frame:IsShown()
end
