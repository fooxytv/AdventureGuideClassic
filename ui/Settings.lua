--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Settings")
local components
local settingsPanel
local SETTINGS_LEFT_PADDING = 16
local SETTINGS_ROW_HEIGHT = 36
local SETTINGS_CHECKBOX_WIDTH = 300

local function SetSliderLabel(slider, suffix, text)
	local name = slider:GetName()
	local byGlobal = name and _G[name .. suffix]
	local byKey = slider[suffix]
	if byGlobal then byGlobal:SetText(text) end
	if byKey and byKey ~= byGlobal then byKey:SetText(text) end
end

local function CreateOptionsSlider(parent, name, label, description, rowIndex, minValue, maxValue, step, getValue, setValue)
	local SLIDER_ROW_HEIGHT = 56
	local row = CreateFrame("Frame", "AGCSettings" .. name .. "Row", parent)
	row:SetSize(360, SLIDER_ROW_HEIGHT)
	row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -rowIndex * SLIDER_ROW_HEIGHT)
	local labelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelText:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
	labelText:SetText(label)
	local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	valueText:SetPoint("LEFT", labelText, "RIGHT", 8, 0)
	local slider = CreateFrame("Slider", "AGCSettings" .. name .. "Slider", row, "OptionsSliderTemplate")
	slider:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -8)
	slider:SetWidth(220)
	slider:SetMinMaxValues(minValue, maxValue)
	slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(true)
	SetSliderLabel(slider, "Low", tostring(minValue))
	SetSliderLabel(slider, "High", tostring(maxValue))
	SetSliderLabel(slider, "Text", "")
	local descText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	descText:SetPoint("LEFT", slider, "RIGHT", 12, 0)
	descText:SetText(description)
	descText:SetTextColor(0.6, 0.6, 0.6)
	descText:SetJustifyH("LEFT")
	local function Refresh()
		local v = getValue()
		slider:SetValue(v)
		valueText:SetText(string.format("%.2fx", v))
	end
	slider:SetScript("OnValueChanged", function(self, value)
		valueText:SetText(string.format("%.2fx", value))
		setValue(value)
	end)
	Refresh()
	row.slider = slider
	row.Refresh = Refresh
	return row
end

local function CreateToastPositionRow(parent, name, label, toastType, rowIndex)
	local ROW_HEIGHT = 60
	local row = CreateFrame("Frame", "AGCSettings" .. name .. "PositionRow", parent)
	row:SetSize(500, ROW_HEIGHT)
	row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -rowIndex * ROW_HEIGHT)
	local labelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelText:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
	labelText:SetText(label)
	local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	valueText:SetPoint("LEFT", labelText, "RIGHT", 8, 0)
	local scaleMin, scaleMax = SettingsService.GetScaleBounds()
	local slider = CreateFrame("Slider", "AGCSettings" .. name .. "ScaleSlider", row, "OptionsSliderTemplate")
	slider:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -10)
	slider:SetWidth(180)
	slider:SetMinMaxValues(scaleMin, scaleMax)
	slider:SetValueStep(0.05)
	slider:SetObeyStepOnDrag(true)
	SetSliderLabel(slider, "Low", tostring(scaleMin))
	SetSliderLabel(slider, "High", tostring(scaleMax))
	SetSliderLabel(slider, "Text", "")
	local unlockBtn = CreateFrame("Button", "AGCSettings" .. name .. "UnlockBtn", row, "UIPanelButtonTemplate")
	unlockBtn:SetSize(120, 22)
	unlockBtn:SetPoint("LEFT", slider, "RIGHT", 16, 0)
	local resetBtn = CreateFrame("Button", "AGCSettings" .. name .. "ResetBtn", row, "UIPanelButtonTemplate")
	resetBtn:SetSize(70, 22)
	resetBtn:SetPoint("LEFT", unlockBtn, "RIGHT", 4, 0)
	resetBtn:SetText("Reset")
	local function RefreshUnlockText()
		if AdventureGuideClassicEventToastManager:IsPreviewing(toastType) then
			unlockBtn:SetText("Lock Position")
		else
			unlockBtn:SetText("Unlock Position")
		end
	end
	local function Refresh()
		local v = SettingsService.GetToastScale(toastType)
		slider:SetValue(v)
		valueText:SetText(string.format("%.2fx", v))
		RefreshUnlockText()
	end
	slider:SetScript("OnValueChanged", function(self, value)
		valueText:SetText(string.format("%.2fx", value))
		SettingsService.SetToastScale(toastType, value)
	end)
	unlockBtn:SetScript("OnClick", function(self)
		local mgr = AdventureGuideClassicEventToastManager
		if mgr:IsPreviewing(toastType) then
			mgr:StopPreview()
		else
			if mgr:IsPreviewing() then mgr:StopPreview() end
			mgr:StartPreview(toastType)
		end
		RefreshUnlockText()
	end)
	resetBtn:SetScript("OnClick", function()
		SettingsService.ResetToastPosition(toastType)
		if AdventureGuideClassicEventToastManager:IsPreviewing(toastType) then
			AdventureGuideClassicEventToastManager:StopPreview()
			AdventureGuideClassicEventToastManager:StartPreview(toastType)
			RefreshUnlockText()
		end
	end)
	Refresh()
	row.slider = slider
	row.unlockBtn = unlockBtn
	row.resetBtn = resetBtn
	row.toastType = toastType
	row.Refresh = Refresh
	return row
end

local function CreateOptionsCheckbox(parent, name, label, description, rowIndex, getValue, setValue)
	local row = CreateFrame("Frame", "AGCSettings" .. name .. "Row", parent)
	row:SetSize(SETTINGS_CHECKBOX_WIDTH, SETTINGS_ROW_HEIGHT)
	row:SetPoint("TOPLEFT", parent, "TOPLEFT", SETTINGS_LEFT_PADDING, -rowIndex * SETTINGS_ROW_HEIGHT)

	local labelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelText:SetPoint("LEFT", row, "LEFT", 0, 4)
	labelText:SetText(label)

	local checkbox = CreateFrame("CheckButton", "AGCSettings" .. name .. "Checkbox", row, "InterfaceOptionsCheckButtonTemplate")
	checkbox:SetPoint("LEFT", labelText, "RIGHT", 8, 0)

	local templateText = _G[checkbox:GetName() .. "Text"]
	if templateText then
		templateText:SetText("")
	end

	local descText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	descText:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -2)
	descText:SetText(description)
	descText:SetTextColor(0.6, 0.6, 0.6)
	descText:SetJustifyH("LEFT")
	checkbox:SetChecked(getValue())
	checkbox:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		setValue(checked)
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end)
	row.checkbox = checkbox
	row.getValue = getValue
	row.setValue = setValue
	return row
end

function component.Init(components_)
	if settingsPanel then return end
	components = components_

	settingsPanel = CreateFrame("Frame", "AdventureGuideClassicSettings", UIParent)
	settingsPanel.name = "Adventure Guide Classic"

	local title = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Adventure Guide Classic")

	local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Unknown"
	local subtitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
	subtitle:SetText("Version: " .. version)
	subtitle:SetTextColor(0.6, 0.6, 0.6)

	local toastHeader = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	toastHeader:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -24)
	toastHeader:SetText("Toast Notifications")
	toastHeader:SetTextColor(1, 0.82, 0)

	local toastDesc = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	toastDesc:SetPoint("TOPLEFT", toastHeader, "BOTTOMLEFT", 0, -4)
	toastDesc:SetText("Configure which on-screen notifications are displayed.")
	toastDesc:SetTextColor(0.6, 0.6, 0.6)

	local toastContainer = CreateFrame("Frame", "AGCSettingsToastContainer", settingsPanel)
	toastContainer:SetPoint("TOPLEFT", toastDesc, "BOTTOMLEFT", 0, -8)
	toastContainer:SetSize(400, 156)

	settingsPanel.levelUpRow = CreateOptionsCheckbox(
		toastContainer,
		"LevelUp",
		"Level Up Toast",
		"Show a notification when your character levels up",
		0,
		function() return SettingsService.GetToastEnabled("LevelUp") end,
		function(val) SettingsService.SetToastEnabled("LevelUp", val) end
	)

	settingsPanel.levelUpSpellsRow = CreateOptionsCheckbox(
		toastContainer,
		"LevelUpSpells",
		"Show Learnable Spells",
		"On level up, also show the abilities you can now train (Classic Era only)",
		1,
		function() return SettingsService.GetLevelUpSpellsEnabled() end,
		function(val) SettingsService.SetLevelUpSpellsEnabled(val) end
	)

	settingsPanel.bossDefeatedRow = CreateOptionsCheckbox(
		toastContainer,
		"BossDefeated",
		"Boss Defeated Toast",
		"Show a notification when a dungeon or raid boss is defeated",
		2,
		function() return SettingsService.GetToastEnabled("BossDefeated") end,
		function(val) SettingsService.SetToastEnabled("BossDefeated", val) end
	)

	settingsPanel.wishlistRow = CreateOptionsCheckbox(
		toastContainer,
		"WishlistItem",
		"Wishlist Item Found Toast",
		"Show a notification when an item on your wishlist drops",
		3,
		function() return SettingsService.GetToastEnabled("WishlistItem") end,
		function(val) SettingsService.SetToastEnabled("WishlistItem", val) end
	)

	local appearanceHeader = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	appearanceHeader:SetPoint("TOPLEFT", toastContainer, "BOTTOMLEFT", 0, -8)
	appearanceHeader:SetText("Appearance")
	appearanceHeader:SetTextColor(1, 0.82, 0)

	local appearanceDesc = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	appearanceDesc:SetPoint("TOPLEFT", appearanceHeader, "BOTTOMLEFT", 0, -4)
	appearanceDesc:SetText("Adjust how the Adventure Guide window is displayed.")
	appearanceDesc:SetTextColor(0.6, 0.6, 0.6)

	local appearanceContainer = CreateFrame("Frame", "AGCSettingsAppearanceContainer", settingsPanel)
	appearanceContainer:SetPoint("TOPLEFT", appearanceDesc, "BOTTOMLEFT", 0, -8)
	appearanceContainer:SetSize(400, 80)

	local scaleMin, scaleMax = SettingsService.GetScaleBounds()
	settingsPanel.scaleRow = CreateOptionsSlider(
		appearanceContainer,
		"Scale",
		"Window Scale",
		"Resize the Adventure Guide window. Useful if text is being clipped.",
		0,
		scaleMin,
		scaleMax,
		0.05,
		function() return SettingsService.GetScale() end,
		function(val) SettingsService.SetScale(val) end
	)

	local toastPosHeader = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	toastPosHeader:SetPoint("TOPLEFT", appearanceContainer, "BOTTOMLEFT", 0, -8)
	toastPosHeader:SetText("Toast Position & Scale")
	toastPosHeader:SetTextColor(1, 0.82, 0)

	local toastPosDesc = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	toastPosDesc:SetPoint("TOPLEFT", toastPosHeader, "BOTTOMLEFT", 0, -4)
	toastPosDesc:SetText("Scale each toast and drag it to where you want on the screen.")
	toastPosDesc:SetTextColor(0.6, 0.6, 0.6)

	local toastPosContainer = CreateFrame("Frame", "AGCSettingsToastPositionContainer", settingsPanel)
	toastPosContainer:SetPoint("TOPLEFT", toastPosDesc, "BOTTOMLEFT", 0, -8)
	toastPosContainer:SetSize(500, 200)

	settingsPanel.levelUpPositionRow = CreateToastPositionRow(toastPosContainer, "LevelUp", "Level Up", "LevelUp", 0)
	settingsPanel.bossDefeatedPositionRow = CreateToastPositionRow(toastPosContainer, "BossDefeated", "Boss Defeated", "BossDefeated", 1)
	settingsPanel.wishlistPositionRow = CreateToastPositionRow(toastPosContainer, "WishlistItem", "Wishlist Item", "WishlistItem", 2)

	settingsPanel:SetScript("OnShow", function()
		settingsPanel.levelUpRow.checkbox:SetChecked(SettingsService.GetToastEnabled("LevelUp"))
		settingsPanel.levelUpSpellsRow.checkbox:SetChecked(SettingsService.GetLevelUpSpellsEnabled())
		settingsPanel.bossDefeatedRow.checkbox:SetChecked(SettingsService.GetToastEnabled("BossDefeated"))
		settingsPanel.wishlistRow.checkbox:SetChecked(SettingsService.GetToastEnabled("WishlistItem"))
		settingsPanel.scaleRow.Refresh()
		settingsPanel.levelUpPositionRow.Refresh()
		settingsPanel.bossDefeatedPositionRow.Refresh()
		settingsPanel.wishlistPositionRow.Refresh()
	end)

	settingsPanel:SetScript("OnHide", function()
		if AdventureGuideClassicEventToastManager:IsPreviewing() then
			AdventureGuideClassicEventToastManager:StopPreview()
			settingsPanel.levelUpPositionRow.Refresh()
			settingsPanel.bossDefeatedPositionRow.Refresh()
			settingsPanel.wishlistPositionRow.Refresh()
		end
	end)

	if Settings and Settings.RegisterCanvasLayoutCategory then
		local category = Settings.RegisterCanvasLayoutCategory(settingsPanel, settingsPanel.name)
		Settings.RegisterAddOnCategory(category)
		settingsPanel.category = category
	else
		InterfaceOptions_AddCategory(settingsPanel)
	end

	component.panel = settingsPanel
end

function component.Open()
	if Settings and Settings.OpenToCategory then
		Settings.OpenToCategory(settingsPanel.category or settingsPanel.name)
	else
		InterfaceOptionsFrame_OpenToCategory(settingsPanel)
		InterfaceOptionsFrame_OpenToCategory(settingsPanel) -- Called twice as workaround for Blizzard bug
	end
end

UI.Add(component)

local settingsInitFrame = CreateFrame("Frame")
settingsInitFrame:RegisterEvent("PLAYER_LOGIN")
settingsInitFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		component.Init({})
		self:UnregisterEvent("PLAYER_LOGIN")
	end
end)
