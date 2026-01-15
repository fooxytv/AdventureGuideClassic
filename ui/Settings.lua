--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Settings")
local components
local settingsPanel

-- Helper function to create a checkbox for Interface Options
local function CreateOptionsCheckbox(parent, name, label, description, anchorTo, yOffset, getValue, setValue)
	local checkbox = CreateFrame("CheckButton", "AGCSettings" .. name .. "Checkbox", parent, "InterfaceOptionsCheckButtonTemplate")

	if anchorTo then
		checkbox:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, yOffset)
	else
		checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, yOffset)
	end

	-- Label text
	local labelText = _G[checkbox:GetName() .. "Text"]
	if labelText then
		labelText:SetText(label)
	else
		labelText = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		labelText:SetPoint("LEFT", checkbox, "RIGHT", 0, 0)
		labelText:SetText(label)
	end

	-- Description text below
	local descText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	descText:SetPoint("TOPLEFT", checkbox, "BOTTOMLEFT", 26, 2)
	descText:SetText(description)
	descText:SetTextColor(0.6, 0.6, 0.6)
	descText:SetJustifyH("LEFT")
	checkbox.description = descText

	-- Set initial value
	checkbox:SetChecked(getValue())

	-- OnClick handler
	checkbox:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		setValue(checked)
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end)

	checkbox.getValue = getValue
	checkbox.setValue = setValue

	return checkbox
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

	-- Level Up Toast checkbox
	settingsPanel.levelUpCheckbox = CreateOptionsCheckbox(
		settingsPanel,
		"LevelUp",
		"Level Up Toast",
		"Show a notification when your character levels up",
		toastDesc,
		-16,
		function() return SettingsService.GetToastEnabled("LevelUp") end,
		function(val) SettingsService.SetToastEnabled("LevelUp", val) end
	)

	-- Boss Defeated Toast checkbox
	settingsPanel.bossDefeatedCheckbox = CreateOptionsCheckbox(
		settingsPanel,
		"BossDefeated",
		"Boss Defeated Toast",
		"Show a notification when a dungeon or raid boss is defeated",
		settingsPanel.levelUpCheckbox.description,
		-12,
		function() return SettingsService.GetToastEnabled("BossDefeated") end,
		function(val) SettingsService.SetToastEnabled("BossDefeated", val) end
	)

	-- Wishlist Item Toast checkbox
	settingsPanel.wishlistCheckbox = CreateOptionsCheckbox(
		settingsPanel,
		"WishlistItem",
		"Wishlist Item Found Toast",
		"Show a notification when an item on your wishlist drops",
		settingsPanel.bossDefeatedCheckbox.description,
		-12,
		function() return SettingsService.GetToastEnabled("WishlistItem") end,
		function(val) SettingsService.SetToastEnabled("WishlistItem", val) end
	)

	-- Refresh callback when panel is shown
	settingsPanel:SetScript("OnShow", function()
		settingsPanel.levelUpCheckbox:SetChecked(SettingsService.GetToastEnabled("LevelUp"))
		settingsPanel.bossDefeatedCheckbox:SetChecked(SettingsService.GetToastEnabled("BossDefeated"))
		settingsPanel.wishlistCheckbox:SetChecked(SettingsService.GetToastEnabled("WishlistItem"))
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
