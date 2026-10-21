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

	Two of the thirteen go up, and their anchors are ours rather than Blizzard's,
	because this frame is not laid out like the one those numbers were written
	for. Their bottom piece was tried and dropped: below this window there is the
	tab row and then the world, and nothing for a swag to sit against.
]]
local HALLOWS_END = {
	{
		-- Pumpkin and vines, 584x127 on the sheet and drawn at that size.
		left = 0.138672, right = 0.708984, top = 0.035156, bottom = 0.159180,
		width = 584, height = 127,
		--[[
			Resting on the frame rather than hanging into it or floating over it,
			which are the two it has already been.

			Blizzard hang theirs 133 into the window, which is fine when the top of
			the window is decoration. Ours is not -- breadcrumb on the left, search
			on the right, and a result list that drops down from the search -- so
			that put the pumpkin on all three.

			Anchoring the bottom edge just above the frame cleared them but left it
			looking stuck on rather than draped. Forty five is the middle: the
			vines lie along the title bar, which is the only part of the top strip
			nothing is drawn into, while the pumpkin sits above the window where it
			covers nothing at all.
		]]
		point = "BOTTOM", relativePoint = "TOP", x = 0, y = -45,
	},
	{
		--[[
			A cobweb in the top right, which is where it looked best. Not one of
			Blizzard's pieces; the sheet carries it and the corner is bare.

			It reaches the search results when they are open, but a web is mostly
			holes -- it reads as something behind them rather than something in the
			way, which the pumpkin did not.
		]]
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
