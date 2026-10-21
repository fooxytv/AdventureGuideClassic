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

	Blizzard's own layout for these themes is a surround -- their
	MonthlyActivitiesThemeContainerMixin hangs four pieces around this very frame
	-- but their anchors assume a window whose edges are decoration, and this one
	has a breadcrumb, a search box and a tab row on its edges. So the pieces are
	chosen and placed for this frame instead.
]]
--[[
	Cobwebs in the corners, and a hat on the portrait.

	The swag went through four positions and never settled, because the piece is
	the problem rather than the placement: a pumpkin the size of the title bar
	wants the top of the window to be decoration, and the top of this window is
	where the breadcrumb, the search and its results all live. Webs have no such
	demand. They sit in corners, which is what corners are for, and a corner is
	the one part of a frame nothing is ever drawn into.

	One piece used three times. Mirrored by swapping the horizontal coordinates
	for the left-hand corners, so a web always spins away from the edge it hangs
	off rather than into it.
]]
local WEB = { left = 0.105469, right = 0.216797, top = 0.520508, bottom = 0.613281 }

local HALLOWS_END = {
	{
		-- Top right, the biggest, under the close button.
		left = WEB.left, right = WEB.right, top = WEB.top, bottom = WEB.bottom,
		width = 124, height = 104,
		point = "TOPRIGHT", relativePoint = "TOPRIGHT", x = -2, y = -24,
	},
	{
		-- Top left, mirrored, kept clear of the portrait ring.
		left = WEB.right, right = WEB.left, top = WEB.top, bottom = WEB.bottom,
		width = 96, height = 80,
		point = "TOPLEFT", relativePoint = "TOPLEFT", x = 2, y = -46,
	},
	{
		-- Bottom right, smallest, so the eye is not pulled down to it.
		left = WEB.left, right = WEB.right, top = WEB.bottom, bottom = WEB.top,
		width = 84, height = 70,
		point = "BOTTOMRIGHT", relativePoint = "BOTTOMRIGHT", x = -2, y = 2,
	},
	{
		--[[
			The witch's hat, on the journal's own portrait.

			Cut from the right half of its piece on the sheet, x 770 to 891, which
			leaves behind the vines it trails off into -- those want a frame edge
			to lie along and there is none here.

			Mirrored, so the point falls away from the window rather than across
			it, and anchored by its bottom edge to the top of the portrait ring so
			it perches rather than covers. The ring is where it belongs: it is the
			one round thing on the frame, and a hat on a portrait is what Blizzard
			themselves do to characters for this fortnight.
		]]
		left = 0.870117, right = 0.751953, top = 0.191406, bottom = 0.263672,
		width = 78, height = 48,
		anchor = "portrait",
		point = "BOTTOM", relativePoint = "TOP", x = -4, y = -20,
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
		local anchor = piece.anchor and EncounterJournal[piece.anchor] or canvas
		texture:SetPoint(piece.point, anchor, piece.relativePoint, piece.x, piece.y)
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
		at DIALOG (the search results, the difficulty dropdown), and no level in
		the journal's own strata gets above those.

		So it goes to DIALOG, but at the bottom of it rather than the top. Being
		in that strata at all is what lifts it clear of the frame and its header;
		being at level 50 keeps it under everything there that is functional --
		the search results sit at 100, the difficulty dropdown at 100 -- so a list
		of results opens in front of the decoration rather than behind it.

		Not TOOLTIP either, for the same reason: the loot preview lives there, and
		a preview should cover the decoration rather than the other way round.

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
	canvas:SetFrameLevel(50)

	--[[
		Worked out once on load. The window is a date range rather than anything
		that changes while a session is running, so there is nothing to watch for;
		a player online across midnight on the last day sees it until they reload,
		which is not worth an event handler.
	]]
	component.Refresh()
end

UI.Add(component)
