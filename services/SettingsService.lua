--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

SettingsService = { }

-- Default settings
local defaults = {
	Toasts = {
		LevelUp = true,
		BossDefeated = true,
		WishlistItem = true,
	}
}

-- Initialize settings with defaults if not set
local function EnsureSettings()
	if not SavedVariables.Settings then
		SavedVariables.Settings = {}
	end
	if not SavedVariables.Settings.Toasts then
		SavedVariables.Settings.Toasts = {}
	end
end

-- Get whether a specific toast type is enabled
function SettingsService.GetToastEnabled(toastType)
	EnsureSettings()
	local value = SavedVariables.Settings.Toasts[toastType]
	if value == nil then
		return defaults.Toasts[toastType] or true
	end
	return value
end

-- Set whether a specific toast type is enabled
function SettingsService.SetToastEnabled(toastType, enabled)
	EnsureSettings()
	SavedVariables.Settings.Toasts[toastType] = enabled
end

-- Convenience functions for each toast type
function SettingsService.IsLevelUpToastEnabled()
	return SettingsService.GetToastEnabled("LevelUp")
end

function SettingsService.IsBossDefeatedToastEnabled()
	return SettingsService.GetToastEnabled("BossDefeated")
end

function SettingsService.IsWishlistToastEnabled()
	return SettingsService.GetToastEnabled("WishlistItem")
end
