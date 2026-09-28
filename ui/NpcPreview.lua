--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

-- PlayerModel and SetDisplayInfo are present on Era and BCC, but if either is missing the
-- component reports it can show nothing and the Quests tab leaves the text plain.

local component = UI.CreateComponent("NpcPreview")

local FRAME_WIDTH, FRAME_HEIGHT = 190, 210

local frame, model, supported
local currentDisplay

local function CreatePreview()
	frame = CreateFrame("Frame", "AdventureGuideClassicNpcPreview", UIParent, "BackdropTemplate")
	frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetClampedToScreen(true)
	-- Takes no mouse input. At tooltip strata anything it accepts is taken from underneath --
	-- the scroll wheel stopped reaching the list, and a scrollbar drag lost its mouse-up.
	frame:EnableMouse(false)
	frame:EnableMouseWheel(false)
	frame:Hide()

	if frame.SetBackdrop then
		frame:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true, tileSize = 16, edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		frame:SetBackdropColor(0.05, 0.05, 0.05, 0.94)
		frame:SetBackdropBorderColor(0.55, 0.45, 0.25, 1)
	end

	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.title:SetPoint("TOPLEFT", 8, -8)
	frame.title:SetPoint("TOPRIGHT", -8, -8)
	frame.title:SetJustifyH("CENTER")
	frame.title:SetWordWrap(true)

	local ok, created = pcall(CreateFrame, "PlayerModel", nil, frame)
	if ok and created and type(created.SetDisplayInfo) == "function" then
		model = created
		if type(model.EnableMouse) == "function" then model:EnableMouse(false) end
		if type(model.EnableMouseWheel) == "function" then model:EnableMouseWheel(false) end
		model:SetPoint("TOPLEFT", 8, -26)
		model:SetPoint("BOTTOMRIGHT", -8, 8)
		supported = true
	else
		supported = false
	end
	return supported
end

local function AnchorToTooltip()
	frame:ClearAllPoints()
	if GameTooltip and GameTooltip:IsShown() then
		frame:SetPoint("TOP", GameTooltip, "BOTTOM", 0, -5)
	else
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
end

function component.Init()
	CreatePreview()
end

function component.IsSupported()
	return supported == true
end

function component.Show(npc)
	if not supported or not frame or not npc or not npc.display then return false end

	if npc.display ~= currentDisplay then
		currentDisplay = npc.display
		model:ClearModel()
		model:SetDisplayInfo(npc.display)
	end

	-- Unknown heights come back as the minimum, leaving the default framing alone.
	if type(model.SetCamDistanceScale) == "function" then
		local scale = 1
		if CreatureModelService and CreatureModelService.GetCameraScale then
			scale = CreatureModelService.GetCameraScale(npc.display) or 1
		end
		model:SetCamDistanceScale(scale)
	end
	if type(model.SetFacing) == "function" then model:SetFacing(0.5) end
	if type(model.SetPortraitZoom) == "function" then model:SetPortraitZoom(0) end

	frame.title:SetText(npc.name or "")
	AnchorToTooltip()
	frame:Show()
	return true
end

function component.Hide()
	if frame then frame:Hide() end
end

_G.AGC_NpcPreview = function(displayId)
	if not component.IsSupported() then
		print("|cffff0000AGC|r npc preview is not supported on this client")
		return
	end
	component.Show({ name = "display " .. tostring(displayId), display = tonumber(displayId) })
end

UI.Add(component)
