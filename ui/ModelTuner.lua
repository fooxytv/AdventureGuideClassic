--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming

Developer panel for dialling in the model viewer camera. Off by default and
reachable only through /agc modeltune -- it is a tuning aid, not a user feature.
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("ModelTuner")

local components
local panel

-- Low enough that the camera can be brought right in. The previous 0.1 was
-- itself the wall Ragnaros and Hakkar hit: they bottom out there and are still
-- too small, so model scale is the lever for those, not camera distance.
local MIN_CAMERA_SCALE = 0.02
local ROW_HEIGHT = 22
local ROWS_TOP = 62      -- below the title edit box
local rowCount = 5       -- 6 when the client supports tilt
local STEPS = {
	scale  = 0.1,
	x      = 0.5,
	y      = 0.5,
	z      = 0.5,
	facing = 0.1,
	pitch  = 0.05,
	modelScale = 0.1,
}

local function CurrentDisplayId()
	return components.ModelFrame.GetDisplay()
end

local function Apply()
	local displayId = CurrentDisplayId()
	if not displayId then return end
	components.ModelFrame.ApplyPreset(panel.preset)
	component.Refresh()
end

local function AddRow(parent, index, field, label)
	local row = CreateFrame("Frame", nil, parent)
	row:SetSize(230, ROW_HEIGHT)
	row:SetPoint("TOPLEFT", 12, -ROWS_TOP - (index * ROW_HEIGHT))

	local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	name:SetPoint("LEFT", 0, 0)
	name:SetWidth(50)
	name:SetJustifyH("LEFT")
	name:SetText(label)

	local minus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	minus:SetSize(22, 18)
	minus:SetPoint("LEFT", 52, 0)
	minus:SetText("-")

	local value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	value:SetPoint("LEFT", minus, "RIGHT", 4, 0)
	value:SetWidth(52)
	value:SetJustifyH("CENTER")

	local plus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	plus:SetSize(22, 18)
	plus:SetPoint("LEFT", value, "RIGHT", 4, 0)
	plus:SetText("+")

	local function Nudge(direction)
		local step = STEPS[field] * direction
		-- Shift for coarse adjustment, since scale ranges over an order of
		-- magnitude while positions are usually a nudge or two.
		if IsShiftKeyDown() then step = step * 5 end
		panel.preset[field] = (panel.preset[field] or 0) + step
		if field == "scale" and panel.preset.scale < MIN_CAMERA_SCALE then
			panel.preset.scale = MIN_CAMERA_SCALE
		end
		if field == "modelScale" and panel.preset.modelScale < 0.1 then
			panel.preset.modelScale = 0.1
		end
		Apply()
	end
	minus:SetScript("OnClick", function() Nudge(-1) end)
	plus:SetScript("OnClick", function() Nudge(1) end)

	row.value = value
	row.field = field
	panel.rows[#panel.rows + 1] = row
	return row
end

local function CreatePanel()
	if panel then return panel end
	panel = CreateFrame("Frame", "AGCModelTuner", UIParent, "BackdropTemplate")
	panel:SetSize(254, 262)
	panel:SetPoint("CENTER", 300, 0)
	panel:SetFrameStrata("DIALOG")
	panel:SetMovable(true)
	panel:EnableMouse(true)
	panel:RegisterForDrag("LeftButton")
	panel:SetScript("OnDragStart", panel.StartMoving)
	panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
	panel:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	panel:SetBackdropColor(0, 0, 0, 0.9)
	panel.rows = {}
	panel.preset = { scale = 1, x = 0, y = 0, z = 0, facing = 0, pitch = 0, modelScale = 1 }

	panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	panel.title:SetPoint("TOPLEFT", 12, -10)
	panel.title:SetText("Model Tuner")

	panel.subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	panel.subtitle:SetPoint("TOPLEFT", 12, -26)
	panel.subtitle:SetWidth(230)
	panel.subtitle:SetJustifyH("LEFT")

	--[[
		Per-creature name. An encounter that shows several creatures labels them
		all with the encounter name, so this is how the individual ones get named.
		Left empty, the encounter name is used as before.
	]]
	local titleLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	titleLabel:SetPoint("TOPLEFT", 12, -42)
	titleLabel:SetText("Title")

	local titleBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	titleBox:SetSize(168, 18)
	titleBox:SetPoint("TOPLEFT", 68, -40)
	titleBox:SetAutoFocus(false)
	titleBox:SetScript("OnTextChanged", function(self, userInput)
		if not userInput then return end
		panel.preset.title = self:GetText()
		ModelPresetService.SaveTitle(CurrentDisplayId(),
			components.ModelFrame.GetEncounterId(), self:GetText())
		components.ModelFrame.ApplyPreset(panel.preset)
	end)
	titleBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	titleBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	panel.titleBox = titleBox

	AddRow(panel, 0, "scale", "Zoom")
	AddRow(panel, 1, "x", "Depth")
	AddRow(panel, 2, "y", "Side")
	AddRow(panel, 3, "z", "Height")
	AddRow(panel, 4, "facing", "Facing")
	-- Only offered where the client can actually tilt a model.
	if components.ModelFrame.SupportsTilt() then
		AddRow(panel, 5, "pitch", "Tilt")
		rowCount = 6
	end
	if components.ModelFrame.SupportsModelScale() then
		AddRow(panel, rowCount, "modelScale", "Size")
		rowCount = rowCount + 1
	end
	panel:SetHeight(ROWS_TOP + (rowCount * ROW_HEIGHT) + 70)

	local function AddButton(text, index, onClick)
		local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
		button:SetSize(74, 20)
		button:SetPoint("TOPLEFT", 12 + (index * 78), -ROWS_TOP - (rowCount * ROW_HEIGHT) - 8)
		button:SetText(text)
		button:SetScript("OnClick", onClick)
		return button
	end

	AddButton("Save", 0, function()
		local displayId = CurrentDisplayId()
		if displayId and ModelPresetService.Save(displayId, panel.preset) then
			print(("|cff00ff00[AGC]|r Saved preset for display %d"):format(displayId))
			component.Refresh()
		end
	end)
	AddButton("Reset", 1, function()
		local displayId = CurrentDisplayId()
		if not displayId then return end
		ModelPresetService.Clear(displayId)
		panel.preset = ModelPresetService.Get(displayId)
		Apply()
		print(("|cffff9900[AGC]|r Cleared preset for display %d"):format(displayId))
	end)
	AddButton("Export", 2, function()
		local text = ModelPresetService.Export()
		if not text then
			print("|cffff9900[AGC]|r No saved model presets.")
			return
		end
		component.ShowExport(text)
	end)

	panel.hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	panel.hint:SetPoint("TOPLEFT", 12, -ROWS_TOP - (rowCount * ROW_HEIGHT) - 34)
	panel.hint:SetWidth(230)
	panel.hint:SetJustifyH("LEFT")
	panel.hint:SetText("Hold Shift for larger steps. Title names one creature of "
		.. "a multi-creature encounter. Export prints pasteable Lua.")

	local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 0, 0)
	close:SetScript("OnClick", function() panel:Hide() end)

	panel:Hide()
	return panel
end

-- A selectable edit box is the only reliable way to get text out of the client.
function component.ShowExport(text)
	if not panel.exportFrame then
		local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
		frame:SetSize(460, 300)
		frame:SetPoint("CENTER")
		frame:SetFrameStrata("FULLSCREEN_DIALOG")
		frame:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 16, edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		frame:SetBackdropColor(0, 0, 0, 0.95)
		local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
		scroll:SetPoint("TOPLEFT", 12, -12)
		scroll:SetPoint("BOTTOMRIGHT", -30, 12)
		local edit = CreateFrame("EditBox", nil, scroll)
		edit:SetMultiLine(true)
		edit:SetFontObject("GameFontHighlightSmall")
		edit:SetWidth(410)
		edit:SetAutoFocus(false)
		edit:SetScript("OnEscapePressed", function() frame:Hide() end)
		scroll:SetScrollChild(edit)
		local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", 0, 0)
		close:SetScript("OnClick", function() frame:Hide() end)
		frame.edit = edit
		panel.exportFrame = frame
	end
	panel.exportFrame:Show()
	panel.exportFrame.edit:SetText(text)
	panel.exportFrame.edit:HighlightText()
	panel.exportFrame.edit:SetFocus()
end

function component.Refresh()
	if not panel or not panel:IsShown() then return end
	local displayId = CurrentDisplayId()
	if not displayId then
		panel.subtitle:SetText("|cffff5555Open a boss on the Model tab.|r")
	else
		local height = CreatureModelService.GetHeight(displayId)
		panel.subtitle:SetText(("Display %d  |cffaaaaaa(height %s%s)|r"):format(
			displayId,
			height and ("%.1f"):format(height) or "?",
			ModelPresetService.HasOverride(displayId) and ", saved" or ""))
	end
	for _, row in ipairs(panel.rows) do
		row.value:SetText(("%.2f"):format(panel.preset[row.field] or 0))
	end
	-- Only write the box when it is not being typed into, or the caret jumps.
	if not panel.titleBox:HasFocus() then
		panel.titleBox:SetText(ModelPresetService.GetTitle(displayId,
			components.ModelFrame.GetEncounterId()) or "")
	end
end

-- Called when the viewer changes creature, so the panel tracks what is on screen.
function component.OnDisplayChanged(displayId)
	if not panel or not panel:IsShown() then return end
	-- Share the viewer's table rather than taking a copy, so wheel and drag
	-- changes are part of what Save writes.
	panel.preset = components.ModelFrame.GetPreset() or ModelPresetService.Get(displayId)
	component.Refresh()
end

function component.Toggle()
	CreatePanel()
	if panel:IsShown() then
		panel:Hide()
		return
	end
	panel:Show()
	local displayId = CurrentDisplayId()
	panel.preset = (displayId and components.ModelFrame.GetPreset())
		or (displayId and ModelPresetService.Get(displayId))
		or { scale = 1, x = 0, y = 0, z = 0, facing = 0, pitch = 0, modelScale = 1 }
	component.Refresh()
end

function component.Init(components_)
	components = components_
end

UI.Add(component)
