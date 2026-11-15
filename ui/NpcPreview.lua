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

local frame, model, supported
local currentDisplay

local function CreatePreview()
	frame = CreateFrame("Frame", "AdventureGuideClassicNpcPreview", UIParent, "BackdropTemplate")
	frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetClampedToScreen(true)
	--[[
	The preview takes no mouse input at all. It sits at tooltip strata and follows the
	pointer, so anything it accepts is taken from whatever is underneath: the scroll
	wheel stopped reaching the quest list, and a scrollbar drag lost its mouse-up to
	this frame and carried on following the cursor.
	]]
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

--[[
Under the tooltip of whatever is being hovered, which is where the gear preview in the
loot tab puts itself.

It used to follow the cursor. That put it under the pointer, where it took the scroll
wheel from the list behind it, and it re-anchored every frame, which made the model
jitter. Hanging it off the tooltip instead means both previews appear in the same place
and neither is ever beneath the cursor.
]]
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
	AnchorToTooltip()
	frame:Show()
	return true
end

function component.Hide()
	if frame then frame:Hide() end
end

-- Debug helpers (see CLAUDE.md) -----------------------------------------------

_G.AGC_NpcPreview = function(displayId)
	if not component.IsSupported() then
		print("|cffff0000AGC|r npc preview is not supported on this client")
		return
	end
	component.Show({ name = "display " .. tostring(displayId), display = tonumber(displayId) })
end

--[[
The display behind each npc id, printed ready for HAND_PICKED in
tools/gen_creature_models.py. Each creature is shown as it is read, because a model
getter is only worth believing when the model on screen agrees with it.
]]
local READ_INTERVAL = 2

local function SelectedInstanceNpcs()
	local list = {}
	for _, encounter in ipairs(AdventureGuideNavigationService.GetInstance() or {}) do
		for _, npc in ipairs(encounter.npcs or {}) do
			list[#list + 1] = { npc = npc, key = encounter.encounterID, name = encounter.name }
		end
	end
	return list
end

-- One line per encounter, so a boss made of several creatures keeps them together.
local function PrintDisplays(list)
	local order, displays = {}, {}
	for _, entry in ipairs(list) do
		if not displays[entry.key] then
			displays[entry.key] = {}
			order[#order + 1] = entry
		end
		if entry.display then table.insert(displays[entry.key], entry.display) end
	end
	for _, entry in ipairs(order) do
		print(('    %d: ([%s], "%s"),'):format(entry.key,
			table.concat(displays[entry.key], ", "), entry.name))
	end
end

_G.AGC_NpcDisplays = function(...)
	if not component.IsSupported() or type(model.SetCreature) ~= "function"
		or type(model.GetDisplayInfo) ~= "function" then
		print("|cffff5555[AGC]|r this client cannot read a display from an npc id")
		return
	end
	local list = {}
	for i = 1, select("#", ...) do
		local npc = tonumber((select(i, ...)))
		if npc then list[#list + 1] = { npc = npc, key = npc, name = "npc " .. npc } end
	end
	if #list == 0 then list = SelectedInstanceNpcs() end
	if #list == 0 then
		print("|cffff5555[AGC]|r no npc ids: pass some, or open an instance whose bosses list them")
		return
	end
	for index, entry in ipairs(list) do
		C_Timer.After((index - 1) * READ_INTERVAL, function()
			currentDisplay = nil
			model:ClearModel()
			model:SetCreature(entry.npc)
			frame.title:SetText(("%s (npc %d)"):format(entry.name, entry.npc))
			AnchorToTooltip()
			frame:Show()
		end)
		-- Read late in the slot: an npc the client has not met is fetched first.
		C_Timer.After(index * READ_INTERVAL - 0.2, function()
			local display = model:GetDisplayInfo()
			if display and display > 0 then
				entry.display = display
			else
				print(("|cffff5555[AGC]|r npc %d (%s) gave no display"):format(entry.npc, entry.name))
			end
			if index == #list then PrintDisplays(list) end
		end)
	end
end

UI.Add(component)
