--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

Developer panel for making the journal believe it is on another client, and that
the player is another level. Off by default and reachable only through
/agc clienttune -- a tuning aid, not a user feature.

It exists because content cannot otherwise be reached: Forever's dungeons only
appear on a Forever client, and when that beta is closed there is no way in. The
flags it changes live in Compat, which is also where the reason this works at all
is written down.

The instance counts on the panel are the proof the switch took: they are read back
from InstanceService after every change, so a flavour that did not take shows the
same numbers rather than silently doing nothing.
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("ClientTuner")

local components
local panel

local FLAVOURS = {
	{ key = nil,       label = "Actual" },
	{ key = "era",     label = "Era" },
	{ key = "sod",     label = "SoD" },
	{ key = "tbc",     label = "TBC" },
	{ key = "forever", label = "Forever" },
}

local MIN_LEVEL, MAX_LEVEL = 1, 70

--[[
	Redraw whatever the journal is showing.

	Each call is guarded: this is a developer panel, and a view that cannot repaint
	should say so rather than throw an error over the top of the game. Reopening the
	journal always works as a fallback.
]]
local function Repaint()
	local failed = { }
	local function Try(name, fn, ...)
		if type(fn) ~= "function" then return end
		local ok = pcall(fn, ...)
		if not ok then failed[#failed + 1] = name end
	end
	Try("suggestions", components.Suggest and components.Suggest.Refresh)
	Try("instance list", components.InstanceSelect and components.InstanceSelect.Show)
	if #failed > 0 then
		print("|cffff5555[AGC]|r could not repaint: " .. table.concat(failed, ", ")
			.. " -- reopen the journal")
	end
end

local function Counts()
	local dungeons = InstanceService.GetDungeons() or { }
	local raids = InstanceService.GetRaids() or { }
	return #dungeons, #raids
end

local function SetFlavour(key)
	if not Compat.SetPretend(key) then
		print("|cffff5555[AGC]|r unknown client: " .. tostring(key))
		return
	end
	component.Refresh()
	Repaint()
end

local function NudgeLevel(direction)
	local step = IsShiftKeyDown() and 5 or 1
	local current = Compat.GetPlayerLevel()
	local level = math.max(MIN_LEVEL, math.min(MAX_LEVEL, current + step * direction))
	Compat.SetPretendLevel(level)
	component.Refresh()
	Repaint()
end

local function ClearLevel()
	Compat.SetPretendLevel(nil)
	component.Refresh()
	Repaint()
end

local function CreatePanel()
	if panel then return panel end
	panel = CreateFrame("Frame", "AGCClientTuner", UIParent, "BackdropTemplate")
	panel:SetSize(268, 196)
	panel:SetPoint("CENTER", -300, 0)
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

	panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	panel.title:SetPoint("TOPLEFT", 12, -10)
	panel.title:SetText("Client Tuner")

	panel.state = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	panel.state:SetPoint("TOPLEFT", 12, -28)
	panel.state:SetWidth(244)
	panel.state:SetJustifyH("LEFT")

	local clientLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	clientLabel:SetPoint("TOPLEFT", 12, -62)
	clientLabel:SetText("Client")

	panel.flavourButtons = { }
	local x = 12
	for _, flavour in ipairs(FLAVOURS) do
		local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
		local width = (flavour.key == nil) and 48 or 48
		button:SetSize(width, 20)
		button:SetPoint("TOPLEFT", x, -78)
		button:SetText(flavour.label)
		button:SetScript("OnClick", function() SetFlavour(flavour.key) end)
		button.flavourKey = flavour.key
		panel.flavourButtons[#panel.flavourButtons + 1] = button
		x = x + width + 2
	end

	local levelLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	levelLabel:SetPoint("TOPLEFT", 12, -110)
	levelLabel:SetText("Level")

	local minus = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	minus:SetSize(22, 20)
	minus:SetPoint("TOPLEFT", 56, -106)
	minus:SetText("-")
	minus:SetScript("OnClick", function() NudgeLevel(-1) end)

	panel.levelValue = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	panel.levelValue:SetPoint("LEFT", minus, "RIGHT", 4, 0)
	panel.levelValue:SetWidth(40)
	panel.levelValue:SetJustifyH("CENTER")

	local plus = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	plus:SetSize(22, 20)
	plus:SetPoint("LEFT", panel.levelValue, "RIGHT", 4, 0)
	plus:SetText("+")
	plus:SetScript("OnClick", function() NudgeLevel(1) end)

	local clear = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	clear:SetSize(56, 20)
	clear:SetPoint("LEFT", plus, "RIGHT", 8, 0)
	clear:SetText("Real")
	clear:SetScript("OnClick", ClearLevel)

	panel.hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	panel.hint:SetPoint("TOPLEFT", 12, -138)
	panel.hint:SetWidth(244)
	panel.hint:SetJustifyH("LEFT")
	panel.hint:SetText("Shift for 5 levels at a time. Nothing here is saved -- a "
		.. "reload puts the real client back.")

	local close = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	close:SetSize(70, 20)
	close:SetPoint("BOTTOMRIGHT", -12, 10)
	close:SetText("Close")
	close:SetScript("OnClick", function() panel:Hide() end)

	return panel
end

function component.Refresh()
	if not panel then return end
	local dungeons, raids = Counts()
	local pretending = Compat.pretending
	local level = Compat.GetPlayerLevel()
	local pretendLevel = Compat.GetPretendLevel()

	panel.state:SetText(("%s%s  |  %d dungeons, %d raids"):format(
		pretending and ("|cffffd100" .. pretending .. "|r") or Compat.flavor,
		pretending and " (pretending)" or " (real)",
		dungeons, raids))

	panel.levelValue:SetText(pretendLevel
		and ("|cffffd100" .. level .. "|r") or tostring(level))

	for _, button in ipairs(panel.flavourButtons) do
		local selected = (button.flavourKey == pretending)
		button:SetEnabled(not selected)
	end
end

function component.Toggle()
	CreatePanel()
	if panel:IsShown() then
		panel:Hide()
		return
	end
	panel:Show()
	component.Refresh()
end

function component.Init(components_)
	components = components_
end

UI.Add(component)
