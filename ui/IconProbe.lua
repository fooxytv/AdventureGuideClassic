--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

Developer aid for seeing how a texture behaves under a mask. Off by default and
reachable only through /agc icontest [fileID].

It exists because the Suggested Content portraits do not fill their ring and three
rounds of measuring the art could not say why. A mask changes both what a texture
may be given -- it refuses tex coords once masked -- and, it appears, how it is
scaled, and neither is visible from outside the client.

So this draws one icon as a grid: every size down one side, every mask across the
top, each cell labelled. One screenshot then answers which combination fills,
instead of a /run per question with the state lost on every reload.
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("IconProbe")

local panel

local DEFAULT_ICON = 136325

local PORTRAIT_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"

--[[
	The two ways to mask a texture.

	SetMask takes a file path and does its own sizing, which is the problem: both
	mask files, at every icon size, draw the art in the top-left of a disc larger
	than the quad. Nothing about the icon or the mask file changes it.

	AddMaskTexture takes a MaskTexture that is anchored and sized like any other
	region, which fixed the offset: the art fills its quad again. It did not make
	a circle, though -- only the corners of a 96pt icon are touched and a 64pt one
	is untouched, which is what a 128pt circle over them would do.

	So the reading is that a mask draws at its file's own size whatever SetSize
	says, and the file has to match the icon. Both sizes are here to settle it. If
	that is right, the 64pt file gives a clean circle at 64pt, leaves 32pt square,
	and crops 96pt hard.
]]
local PORTRAIT_MASK_SMALL =
	"Interface\\CharacterFrame\\TempPortraitAlphaMaskSmall"

local MASKS = {
	{ label = "no mask" },
	{ label = "SetMask (now)", path = PORTRAIT_MASK },
	{ label = "AddMask 128", path = PORTRAIT_MASK, region = true },
	{ label = "AddMask 64", path = PORTRAIT_MASK_SMALL, region = true },
}

local SIZES = { 32, 64, 96 }

local CELL = 104
local LEFT, TOP = 70, 70

local function BuildCell(parent, column, row, mask, size)
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(CELL, CELL)
	holder:SetPoint("TOPLEFT", LEFT + (column - 1) * CELL, -(TOP + (row - 1) * CELL))

	-- A mid grey behind every cell, so a transparent corner and a black one are
	-- told apart. Against black they look the same, which is the whole question.
	local bg = holder:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(holder)
	bg:SetColorTexture(0.35, 0.35, 0.38, 1)

	local icon = holder:CreateTexture(nil, "ARTWORK")
	icon:SetSize(size, size)
	icon:SetPoint("CENTER")
	if mask.region then
		-- A mask that is a region: sized and anchored onto the icon exactly.
		if holder.CreateMaskTexture and icon.AddMaskTexture then
			local shape = holder:CreateMaskTexture()
			shape:SetTexture(mask.path, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
			shape:SetSize(size, size)
			shape:SetPoint("CENTER", icon, "CENTER")
			icon:AddMaskTexture(shape)
			holder.shape = shape
		else
			holder.unsupported = true
		end
	elseif mask.path and icon.SetMask then
		-- The order ui/Suggest.lua uses: mask first, texture second.
		icon:SetMask(mask.path)
	end
	icon:SetTexture(panel.iconID)
	if holder.unsupported then
		local note = holder:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
		note:SetPoint("TOP", 0, -4)
		note:SetText("unsupported")
	end

	local caption = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	caption:SetPoint("BOTTOM", 0, 2)
	caption:SetText(size .. "pt")
	holder.icon = icon
	return holder
end

local function Build()
	if panel then return panel end
	panel = CreateFrame("Frame", "AGCIconProbe", UIParent, "BackdropTemplate")
	panel:SetSize(LEFT + #MASKS * CELL + 20, TOP + #SIZES * CELL + 30)
	panel:SetPoint("CENTER")
	panel:SetFrameStrata("FULLSCREEN_DIALOG")
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
	panel:SetBackdropColor(0, 0, 0, 0.95)
	panel.iconID = DEFAULT_ICON

	panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	panel.title:SetPoint("TOPLEFT", 14, -12)

	panel.cells = { }
	for column, mask in ipairs(MASKS) do
		local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		heading:SetPoint("TOPLEFT", LEFT + (column - 1) * CELL, -(TOP - 16))
		heading:SetWidth(CELL)
		heading:SetJustifyH("CENTER")
		heading:SetText(mask.label)
		for row, size in ipairs(SIZES) do
			panel.cells[#panel.cells + 1] = BuildCell(panel, column, row, mask, size)
		end
	end

	local close = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	close:SetSize(70, 20)
	close:SetPoint("BOTTOMRIGHT", -12, 10)
	close:SetText("Close")
	close:SetScript("OnClick", function() panel:Hide() end)
	return panel
end

function component.Toggle(iconID)
	Build()
	if panel:IsShown() and not iconID then
		panel:Hide()
		return
	end
	panel.iconID = tonumber(iconID) or panel.iconID or DEFAULT_ICON
	for _, cell in ipairs(panel.cells) do
		cell.icon:SetTexture(panel.iconID)
	end
	panel.title:SetText(("Icon probe -- %s"):format(tostring(panel.iconID)))
	panel:Show()
	print(("|cff66ff66[AGC]|r icon probe showing %s; SetMask is %s"):format(
		tostring(panel.iconID),
		panel.cells[1].icon.SetMask and "available" or "MISSING on this client"))
end

function component.Init()
end

UI.Add(component)
