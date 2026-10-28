--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV

Developer aid for choosing an icon's mask and size against the ring it has to
fill. Off by default and reachable only through /agc icontest [fileID].

It exists because the Suggested Content portraits do not fill their ring and the
cause was reasoned out wrongly four times from measurements of the art. A mask
changes what a texture may be given, how it is scaled, and -- as it turned out --
behaves differently from one mask file to the next for reasons not visible from
outside the client. So this photographs it instead.

Each cell draws the icon under a mask with the real ring over it, at the size its
row says. The question is only ever which cell fills its ring, which is a thing
to look at rather than to calculate.

What earlier rounds settled, so none of it is retried here:

- TempPortraitAlphaMask draws the art in the top-left of a disc wider than the
  icon. Its 64pt sibling does the same, and so does a centred circle generated to
  fill a 64pt file, so the mask's own dimensions are not the difference.
- InstanceButtonIconMask fills a circle at every size, which is why Suggest now
  uses it. Its circle is only 45 of its 64 points though, and cut off-centre for
  the instance button's anchor, so it rounds the icon smaller than the ring's
  hole and sits up and to the left of it.
- UIEJPortraitRingMask is that same file with the circle moved to the middle,
  which is what this round is for.
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("IconProbe")

local panel

local DEFAULT_ICON = 136325

-- The ring from ui/Suggest.lua, at the size it is drawn there.
local SHEET = I.AdventureGuide
local RING = { 0.775391, 0.958984, 0.001953, 0.1875 }
local RING_SIZE = 94

--[[
	InstanceButtonIconMask's circle is cut off-centre: it spans (3, 1) to (48, 46)
	of a 64pt file, so its middle sits 6.5 left and 8.5 up of the file's. Moving
	the icon by that much, scaled to whatever size the icon is drawn at, puts the
	circle in the middle of the ring while leaving the mask itself alone -- the
	same crop of the art, just placed where it belongs.
]]
local MASK_OFFSET_X, MASK_OFFSET_Y = 6.5, 8.5

local MASKS = {
	{ label = "InstanceButton", path = I.InstanceButtonIconMask },
	{ label = "InstanceButton centred", path = I.InstanceButtonIconMask,
	  compensate = true },
	{ label = "RingMask centred", path = I.UIEJPortraitRingMask },
}

-- 64 is what ships. The rest follow from the mask's circle being 0.703 of its
-- file: about 83 to reach the 58pt hole, about 91 to sit mid-band.
local SIZES = { 64, 83, 91, 96 }

local CELL = 108
local LEFT, TOP = 56, 70

local function BuildCell(parent, column, row, mask, size)
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(CELL, CELL)
	holder:SetPoint("TOPLEFT", LEFT + (column - 1) * CELL, -(TOP + (row - 1) * CELL))

	-- Mid grey, so a transparent gap and a black one are told apart.
	local bg = holder:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(holder)
	bg:SetColorTexture(0.35, 0.35, 0.38, 1)

	-- The ring is placed by the layout, not by the icon, exactly as in Suggest --
	-- otherwise moving the icon to centre its circle would move the ring with it
	-- and nothing would change.
	local ring = holder:CreateTexture(nil, "OVERLAY")
	ring:SetTexture(SHEET)
	ring:SetTexCoord(RING[1], RING[2], RING[3], RING[4])
	ring:SetSize(RING_SIZE, RING_SIZE)
	ring:SetPoint("CENTER", 0, 6)

	local scale = size / 64
	local dx = mask.compensate and MASK_OFFSET_X * scale or 0
	local dy = mask.compensate and MASK_OFFSET_Y * scale or 0
	local icon = holder:CreateTexture(nil, "ARTWORK")
	icon:SetSize(size, size)
	icon:SetPoint("CENTER", dx, 6 - dy)
	if mask.path and icon.SetMask then icon:SetMask(mask.path) end
	icon:SetTexture(panel.iconID)

	local caption = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	caption:SetPoint("BOTTOM", 0, 1)
	caption:SetText(size .. "pt")
	holder.icon = icon
	return holder
end

local function Build()
	if panel then return panel end
	panel = CreateFrame("Frame", "AGCIconProbe", UIParent, "BackdropTemplate")
	panel:SetSize(LEFT + #MASKS * CELL + 20, TOP + #SIZES * CELL + 34)
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

	panel.hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	panel.hint:SetPoint("TOPLEFT", 14, -32)
	panel.hint:SetText("Which cell fills its ring, with the picture centred in it?")

	panel.cells = { }
	for column, mask in ipairs(MASKS) do
		local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		heading:SetPoint("TOPLEFT", LEFT + (column - 1) * CELL, -(TOP - 14))
		heading:SetWidth(CELL)
		heading:SetJustifyH("CENTER")
		heading:SetText(mask.label)
		for row, size in ipairs(SIZES) do
			panel.cells[#panel.cells + 1] = BuildCell(panel, column, row, mask, size)
		end
	end

	local close = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	close:SetSize(70, 20)
	close:SetPoint("BOTTOMRIGHT", -12, 8)
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
end

function component.Init()
end

UI.Add(component)
