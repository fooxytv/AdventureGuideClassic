--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
A small 3D model of a creature, shown beside the cursor.

The Quests tab turns the names inside a quest's objective sentence into links -- "Speak
with Marshal McBride", "Kill 10 Kobold Vermin" -- and hovering one shows what that
creature actually looks like. A player who has never been to Northshire learns more
from the model than from the name.

Positioned like a tooltip rather than anchored to the row: the rows are inside a scroll
frame and a fixed anchor would be clipped by it, so the preview lives on UIParent and
follows the cursor, flipping side and edge when it would run off screen.

Feature-detected throughout. PlayerModel and SetDisplayInfo are present on Era and BCC,
but if either is missing the component reports that it cannot show anything and the
Quests tab leaves the text plain rather than offering links that do nothing.
]]

local component = UI.CreateComponent("NpcPreview")

local FRAME_WIDTH, FRAME_HEIGHT = 190, 210
local CURSOR_GAP = 26

local frame, model, supported
local currentDisplay
local lastX, lastY

local function CreatePreview()
	frame = CreateFrame("Frame", "AdventureGuideClassicNpcPreview", UIParent, "BackdropTemplate")
	frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetClampedToScreen(true)
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
		model:SetPoint("TOPLEFT", 8, -26)
		model:SetPoint("BOTTOMRIGHT", -8, 8)
		supported = true
	else
		supported = false
	end
	return supported
end

--[[
Beside the cursor, on whichever side there is room for it.

GetCursorPosition reports in screen pixels, so it has to be divided by the effective
scale before it means anything to a frame anchored on UIParent -- a UI scale other than
1 otherwise puts the preview a long way from the pointer.
]]
local function FollowCursor()
	local scale = UIParent:GetEffectiveScale()
	if not scale or scale <= 0 then scale = 1 end
	local x, y = GetCursorPosition()
	x, y = x / scale, y / scale

	--[[
	Only move when the pointer has actually moved. Re-anchoring every frame is what a
	tooltip does, but this frame holds a model, and clearing and resetting its points
	sixty times a second makes the model jitter even while the cursor is still.
	]]
	if lastX and math.abs(x - lastX) < 0.5 and math.abs(y - lastY) < 0.5 then
		return
	end
	lastX, lastY = x, y

	local screenWidth = UIParent:GetWidth() or 0
	local left = x + CURSOR_GAP
	if left + FRAME_WIDTH > screenWidth then
		left = x - CURSOR_GAP - FRAME_WIDTH
	end
	local bottom = y - FRAME_HEIGHT / 2
	if bottom < 8 then bottom = 8 end

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
end

function component.Init()
	CreatePreview()
	if not frame then return end
	frame:SetScript("OnUpdate", function()
		if frame:IsShown() then FollowCursor() end
	end)
end

function component.IsSupported()
	return supported == true
end

--[[
Shows a creature. Returns whether anything was actually drawn, so a caller can decide
not to offer the link at all rather than open an empty box.
]]
function component.Show(npc)
	if not supported or not frame or not npc or not npc.display then return false end

	if npc.display ~= currentDisplay then
		currentDisplay = npc.display
		model:ClearModel()
		model:SetDisplayInfo(npc.display)
	end

	-- Pull the camera back for the big ones, using the heights the boss viewer already
	-- carries. Unknown heights come back as the minimum, which leaves the default
	-- framing alone -- right for the ordinary humanoids most quest givers are.
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
	lastX, lastY = nil, nil
	FollowCursor()
	frame:Show()
	return true
end

function component.Hide()
	if frame then frame:Hide() end
end

-- Debug helpers (see todo.md) -------------------------------------------------

_G.AGC_NpcPreview = function(displayId)
	if not component.IsSupported() then
		print("|cffff0000AGC|r npc preview is not supported on this client")
		return
	end
	component.Show({ name = "display " .. tostring(displayId), display = tonumber(displayId) })
end

UI.Add(component)
