--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

SettingsService = { }


local defaults = {
	Toasts = {
		LevelUp = true,
		BossDefeated = true,
		WishlistItem = true,
	},
	Scale = 1.0,
	ToastScale = 1.0,
	ToastPosition = { anchor = "TOP", relativeAnchor = "TOP", x = 0, y = -120 },
	-- Learnable-spell row on the level-up toast. Off by default while the data is
	-- still being validated; opt-in from the settings panel.
	LevelUpSpells = false,
}
local SCALE_MIN = 0.5
local SCALE_MAX = 1.5
local TOAST_TYPES = { "LevelUp", "BossDefeated", "WishlistItem" }


local function EnsureSettings()
	if not SavedVariables.Settings then
		SavedVariables.Settings = {}
	end
	if not SavedVariables.Settings.Toasts then
		SavedVariables.Settings.Toasts = {}
	end
	if not SavedVariables.Settings.ToastScales then
		SavedVariables.Settings.ToastScales = {}
	end
	if not SavedVariables.Settings.ToastPositions then
		SavedVariables.Settings.ToastPositions = {}
	end
end

local function CopyPosition(pos)
	return {
		anchor = pos.anchor,
		relativeAnchor = pos.relativeAnchor,
		x = pos.x,
		y = pos.y,
	}
end

local function ClampScale(value)
	if type(value) ~= "number" then return defaults.Scale end
	if value < SCALE_MIN then return SCALE_MIN end
	if value > SCALE_MAX then return SCALE_MAX end
	return value
end

function SettingsService.GetToastEnabled(toastType)
	EnsureSettings()
	local value = SavedVariables.Settings.Toasts[toastType]
	if value == nil then
		return defaults.Toasts[toastType] or true
	end
	return value
end

function SettingsService.SetToastEnabled(toastType, enabled)
	EnsureSettings()
	SavedVariables.Settings.Toasts[toastType] = enabled
end

function SettingsService.GetLevelUpSpellsEnabled()
	EnsureSettings()
	local value = SavedVariables.Settings.LevelUpSpells
	if value == nil then return defaults.LevelUpSpells end
	return value
end

function SettingsService.SetLevelUpSpellsEnabled(enabled)
	EnsureSettings()
	SavedVariables.Settings.LevelUpSpells = enabled
end

function SettingsService.IsLevelUpToastEnabled()
	return SettingsService.GetToastEnabled("LevelUp")
end

function SettingsService.IsBossDefeatedToastEnabled()
	return SettingsService.GetToastEnabled("BossDefeated")
end

function SettingsService.IsWishlistToastEnabled()
	return SettingsService.GetToastEnabled("WishlistItem")
end

local scaleListeners = {}

function SettingsService.GetScale()
	EnsureSettings()
	local value = SavedVariables.Settings.Scale
	if value == nil then return defaults.Scale end
	return ClampScale(value)
end

function SettingsService.SetScale(value)
	EnsureSettings()
	value = ClampScale(value)
	SavedVariables.Settings.Scale = value
	for _, listener in ipairs(scaleListeners) do
		listener(value)
	end
end

function SettingsService.GetScaleBounds()
	return SCALE_MIN, SCALE_MAX
end

function SettingsService.RegisterScaleListener(callback)
	table.insert(scaleListeners, callback)
end

local toastListeners = {}

local function NotifyToastListeners(toastType)
	for _, listener in ipairs(toastListeners) do
		listener(toastType)
	end
end

function SettingsService.GetToastTypes()
	return TOAST_TYPES
end

function SettingsService.GetToastScale(toastType)
	EnsureSettings()
	local value = SavedVariables.Settings.ToastScales[toastType]
	if value == nil then return defaults.ToastScale end
	return ClampScale(value)
end

function SettingsService.SetToastScale(toastType, value)
	EnsureSettings()
	value = ClampScale(value)
	SavedVariables.Settings.ToastScales[toastType] = value
	NotifyToastListeners(toastType)
end

function SettingsService.GetToastPosition(toastType)
	EnsureSettings()
	local saved = SavedVariables.Settings.ToastPositions[toastType]
	if not saved then return CopyPosition(defaults.ToastPosition) end
	return {
		anchor = saved.anchor or defaults.ToastPosition.anchor,
		relativeAnchor = saved.relativeAnchor or defaults.ToastPosition.relativeAnchor,
		x = saved.x or defaults.ToastPosition.x,
		y = saved.y or defaults.ToastPosition.y,
	}
end

function SettingsService.SetToastPosition(toastType, position)
	EnsureSettings()
	SavedVariables.Settings.ToastPositions[toastType] = {
		anchor = position.anchor,
		relativeAnchor = position.relativeAnchor,
		x = position.x,
		y = position.y,
	}
	NotifyToastListeners(toastType)
end

function SettingsService.ResetToastPosition(toastType)
	EnsureSettings()
	SavedVariables.Settings.ToastPositions[toastType] = nil
	NotifyToastListeners(toastType)
end

function SettingsService.RegisterToastListener(callback)
	table.insert(toastListeners, callback)
end
