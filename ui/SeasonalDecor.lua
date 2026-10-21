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

	Laid out the way Blizzard lays out a seasonal surround for this very frame.
	The Traveler's Log dresses the Encounter Journal with these themes, and its
	MonthlyActivitiesThemeContainerMixin anchors four pieces around the window --
	top, bottom, left and right -- each at its native size. So the art is not a
	swag for the top of the frame; it is a border for the whole of it.

	Three of the thirteen go up: their top and bottom pieces, and a cobweb for the
	corner the portrait leaves bare. The side pieces are left for now -- the frame
	is narrower than theirs and the sides are where that shows first.
]]
local HALLOWS_END = {
	{
		-- Pumpkin and vines, 584x127 on the sheet and drawn at that size.
		left = 0.138672, right = 0.708984, top = 0.035156, bottom = 0.159180,
		width = 584, height = 127,
		--[[
			Blizzard's own anchor for the top piece of a seasonal surround, from
			MonthlyActivitiesThemeContainerMixin: the piece's bottom edge against
			the frame's top, 133 below it. That hangs it down over the title bar
			rather than balancing it above the frame, which is what it is drawn to
			do -- the vines are meant to be read as lying on the window.

			The 45 to the right is ours. Blizzard centres it, but their title sits
			elsewhere and centred here the pumpkin covers the word "Guide".
		]]
		point = "BOTTOM", relativePoint = "TOP", x = 45, y = -133,
	},
	{
		-- The matching lower swag, 519x99, anchored as their bottom piece is.
		left = 0.222656, right = 0.729492, top = 0.331055, bottom = 0.427734,
		width = 519, height = 99,
		point = "TOP", relativePoint = "BOTTOM", x = 0, y = 7,
	},
	{
		-- A cobweb for the corner the portrait leaves free. Not one of Blizzard's
		-- four; the sheet carries it and the corner was bare.
		left = 0.105469, right = 0.216797, top = 0.520508, bottom = 0.613281,
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

		Textures put straight on EncounterJournal sit in its own layers, under every
		child frame it has, so the swag was behind the top of the window.

		Raising the level was not enough either, because strata is decided before
		level: the journal has pieces at HIGH (the lore text, the map button) and
		at DIALOG (the difficulty dropdown), and no level in the journal's own
		strata can get above those. So this goes to DIALOG and takes a level well
		clear of the dropdown's 100.

		Not TOOLTIP, deliberately -- the loot preview lives there, and a preview
		should cover the decoration rather than the other way round.

		The frame does not clip, so a piece can hang over the edge, which is what
		makes a swag look draped rather than pasted on.
	]]
	canvas = CreateFrame("Frame", nil, EncounterJournal)
	canvas:SetAllPoints(EncounterJournal)
	--[[
		Explicitly mouse-through. It covers the title bar and reaches the search
		box, and a frame at DIALOG that swallowed clicks would make the search
		unusable for a fortnight a year.
	]]
	canvas:EnableMouse(false)
	canvas:SetFrameStrata("DIALOG")
	canvas:SetFrameLevel(600)

	--[[
		Worked out once on load. The window is a date range rather than anything
		that changes while a session is running, so there is nothing to watch for;
		a player online across midnight on the last day sees it until they reload,
		which is not worth an event handler.
	]]
	component.Refresh()
end

UI.Add(component)
