--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Settings")
local components
local settingsPanel

-- Constants for layout
local SETTINGS_LEFT_PADDING = 16
local SETTINGS_ROW_HEIGHT = 36
local SETTINGS_CHECKBOX_WIDTH = 300

-- Helper function to create a checkbox row with label on left, checkbox on right
local function CreateOptionsCheckbox(parent, name, label, description, rowIndex, getValue, setValue)
	-- Container frame for the row
	local row = CreateFrame("Frame", "AGCSettings" .. name .. "Row", parent)
	row:SetSize(SETTINGS_CHECKBOX_WIDTH, SETTINGS_ROW_HEIGHT)
	row:SetPoint("TOPLEFT", parent, "TOPLEFT", SETTINGS_LEFT_PADDING, -rowIndex * SETTINGS_ROW_HEIGHT)

	-- Label on the left
	local labelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelText:SetPoint("LEFT", row, "LEFT", 0, 4)
	labelText:SetText(label)

	-- Checkbox on the right of the label
	local checkbox = CreateFrame("CheckButton", "AGCSettings" .. name .. "Checkbox", row, "InterfaceOptionsCheckButtonTemplate")
	checkbox:SetPoint("LEFT", labelText, "RIGHT", 8, 0)

	-- Hide the default template text
	local templateText = _G[checkbox:GetName() .. "Text"]
	if templateText then
		templateText:SetText("")
	end

	-- Description text below the label
	local descText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	descText:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -2)
	descText:SetText(description)
	descText:SetTextColor(0.6, 0.6, 0.6)
	descText:SetJustifyH("LEFT")

	-- Set initial value
	checkbox:SetChecked(getValue())

	-- OnClick handler
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
	components = components_

	-- Create the settings panel for Blizzard's Interface Options
	settingsPanel = CreateFrame("Frame", "AdventureGuideClassicSettings", UIParent)
	settingsPanel.name = "Adventure Guide Classic"

	-- Title
	local title = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Adventure Guide Classic")

	-- Subtitle/Version
	local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Unknown"
	local subtitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
	subtitle:SetText("Version: " .. version)
	subtitle:SetTextColor(0.6, 0.6, 0.6)

	-- Section Header: Toast Notifications
	local toastHeader = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	toastHeader:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -24)
	toastHeader:SetText("Toast Notifications")
	toastHeader:SetTextColor(1, 0.82, 0)

	-- Section description
	local toastDesc = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	toastDesc:SetPoint("TOPLEFT", toastHeader, "BOTTOMLEFT", 0, -4)
	toastDesc:SetText("Configure which on-screen notifications are displayed.")
	toastDesc:SetTextColor(0.6, 0.6, 0.6)

	-- Create a container for toast options (for consistent alignment)
	local toastContainer = CreateFrame("Frame", "AGCSettingsToastContainer", settingsPanel)
	toastContainer:SetPoint("TOPLEFT", toastDesc, "BOTTOMLEFT", 0, -8)
	toastContainer:SetSize(400, 120)

	-- Level Up Toast checkbox (row 0)
	settingsPanel.levelUpRow = CreateOptionsCheckbox(
		toastContainer,
		"LevelUp",
		"Level Up Toast",
		"Show a notification when your character levels up",
		0,
		function() return SettingsService.GetToastEnabled("LevelUp") end,
		function(val) SettingsService.SetToastEnabled("LevelUp", val) end
	)

	-- Boss Defeated Toast checkbox (row 1)
	settingsPanel.bossDefeatedRow = CreateOptionsCheckbox(
		toastContainer,
		"BossDefeated",
		"Boss Defeated Toast",
		"Show a notification when a dungeon or raid boss is defeated",
		1,
		function() return SettingsService.GetToastEnabled("BossDefeated") end,
		function(val) SettingsService.SetToastEnabled("BossDefeated", val) end
	)

	-- Wishlist Item Toast checkbox (row 2)
	settingsPanel.wishlistRow = CreateOptionsCheckbox(
		toastContainer,
		"WishlistItem",
		"Wishlist Item Found Toast",
		"Show a notification when an item on your wishlist drops",
		2,
		function() return SettingsService.GetToastEnabled("WishlistItem") end,
		function(val) SettingsService.SetToastEnabled("WishlistItem", val) end
	)

	-- Refresh callback when panel is shown
	settingsPanel:SetScript("OnShow", function()
		settingsPanel.levelUpRow.checkbox:SetChecked(SettingsService.GetToastEnabled("LevelUp"))
		settingsPanel.bossDefeatedRow.checkbox:SetChecked(SettingsService.GetToastEnabled("BossDefeated"))
		settingsPanel.wishlistRow.checkbox:SetChecked(SettingsService.GetToastEnabled("WishlistItem"))
	end)

	-- Register with Blizzard Interface Options
	if Settings and Settings.RegisterCanvasLayoutCategory then
		-- Retail/Modern API
		local category = Settings.RegisterCanvasLayoutCategory(settingsPanel, settingsPanel.name)
		Settings.RegisterAddOnCategory(category)
		settingsPanel.category = category
	else
		-- Classic API
		InterfaceOptions_AddCategory(settingsPanel)
	end

	component.panel = settingsPanel
end

-- Open the settings panel directly
function component.Open()
	if Settings and Settings.OpenToCategory then
		-- Retail/Modern API
		Settings.OpenToCategory(settingsPanel.category or settingsPanel.name)
	else
		-- Classic API
		InterfaceOptionsFrame_OpenToCategory(settingsPanel)
		InterfaceOptionsFrame_OpenToCategory(settingsPanel) -- Called twice as workaround for Blizzard bug
	end
end

UI.Add(component)

-- Initialize settings on PLAYER_LOGIN so it registers with Blizzard options immediately
-- (don't wait for UI.Init which only happens when Encounter Journal is first opened)
local settingsInitFrame = CreateFrame("Frame")
settingsInitFrame:RegisterEvent("PLAYER_LOGIN")
settingsInitFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		component.Init({})
		self:UnregisterEvent("PLAYER_LOGIN")
	end
end)
