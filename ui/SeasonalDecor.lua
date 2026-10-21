--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("SeasonalDecor")
local decor = { }
local canvas

--[[
	Blizzard's own Hallow's End trim, measured off the sheet. Every piece is cut
	from one 1024x1024 file that holds them on transparency, so the coordinates
	are the whole of the layout work.

	Only two go up. The sheet carries thirteen pieces and hanging them all would
	bury the journal rather than dress it: a swag over the top edge reads as
	decoration, a second one somewhere else reads as clutter.
]]
local HALLOWS_END = {
	{
		-- Pumpkin and vines, the widest piece on the sheet at 584x127.
		left = 0.138672, right = 0.708984, top = 0.035156, bottom = 0.159180,
		-- 584x127 on the sheet, kept to that ratio so the vines do not stretch.
		width = 560, height = 122,
		point = "TOP", relativePoint = "TOP", x = 0, y = 34,
	},
	{
		-- A cobweb, for the corner the portrait does not already fill.
		left = 0.105469, right = 0.216797, top = 0.520508, bottom = 0.613281,
		-- 114x95 on the sheet. Tucked just inside the corner rather than over it,
		-- so it does not sit on the close button.
		width = 132, height = 110,
		point = "TOPRIGHT", relativePoint = "TOPRIGHT", x = -2, y = -26,
	},
}

local SHEETS = { hallowsend = { texture = "SeasonalHallowsEnd", pieces = HALLOWS_END } }

local function Build(sheet)
	for index, piece in ipairs(sheet.pieces) do
		local texture = decor[index]
		if not texture then
			texture = canvas:CreateTexture(nil, "OVERLAY")
			decor[index] = texture
		end
		texture:SetTexture(I[sheet.texture])
		texture:SetTexCoord(piece.left, piece.right, piece.top, piece.bottom)
		texture:SetSize(piece.width, piece.height)
		texture:ClearAllPoints()
		texture:SetPoint(piece.point, canvas, piece.relativePoint, piece.x, piece.y)
		texture:Show()
	end
end

function component.Refresh()
	local event = SeasonalService and SeasonalService.GetActiveEvent()
	local sheet = event and SHEETS[event]
	if not sheet then
		for _, texture in ipairs(decor) do texture:Hide() end
		return
	end
	Build(sheet)
end

function component.Init()
	--[[
		A frame of its own, well above the journal's children.

		Textures put straight on EncounterJournal sit in its own layers, which is
		under every child frame it has -- the inset, the title bar, the portrait --
		so the swag was almost entirely behind the top of the window. Two hundred
		levels clears those, including the defeat overlay, which sets 150 itself.

		It is not clipped to the frame, so a piece can hang over the edge, which is
		what makes a swag look draped rather than pasted on.
	]]
	canvas = CreateFrame("Frame", nil, EncounterJournal)
	canvas:SetAllPoints(EncounterJournal)
	canvas:SetFrameLevel(EncounterJournal:GetFrameLevel() + 200)

	--[[
		Worked out once on load. The window is a date range rather than anything
		that changes while a session is running, so there is nothing to watch for;
		a player online across midnight on the last day sees it until they reload,
		which is not worth an event handler.
	]]
	component.Refresh()
end

UI.Add(component)
