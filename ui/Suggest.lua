--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Suggest")
local components
local suggest
local panes = { }
local offset = 0

--[[
	Blizzard's own Adventure Guide furniture, measured off
	Interface/EncounterJournal/AdventureGuide.blp -- a 512x512 sheet that holds
	nothing but this page's parts. The atlas names (adventureguide-pane-large and
	the rest) do not resolve on these clients, so the sheet ships in images/ and
	the coordinates live here, as ui/SeasonalDecor.lua does for its own sheet.
]]
local SHEET = I.AdventureGuide
local LARGE = { 0, 0.654297, 0.322266, 0.980469, width = 335, height = 337 }
local SMALL = { 0, 0.671875, 0, 0.314453, width = 344, height = 161 }
local RING = { 0.775391, 0.958984, 0.001953, 0.1875, width = 94, height = 95 }
local REWARD = { 0.677734, 0.771484, 0.001953, 0.095703, width = 48, height = 48 }

local HEADER_HEIGHT = 44
-- 335 + 30 + 344. Blizzard drew these for a narrower frame than ours, so the
-- group is centred rather than stretched -- the panes are art, not a layout.
local GROUP_WIDTH = LARGE.width + 30 + SMALL.width

--[[
	Portrait and ring, at the size the art was drawn for and the size Blizzard draws
	it at: a 94pt ring around a 64pt icon, on both panes.

	The ring was shrunk once to stop it dominating the small pane, which treated the
	symptom. Measured off the sheet, its opaque band runs from radius 29 to 34 of the
	94pt box, so the hole is 58 across -- and a square icon cannot both fill that
	hole and keep its corners behind the band: 58 across to fill it, 48 at most to
	hide them. That is why the portrait is masked round rather than inset, and why
	shrinking it put corners out past the band.

	What keeps a 94pt ring off a 161pt pane is the overhang, not the size. Retail
	hangs the small pane's portrait off its top-left corner, which is copied below.
]]
-- 91, not Blizzard's 64: the mask below rounds an icon to 0.703 of its size, so
-- 64 came out a 45pt circle in a 58pt hole. 91 gives 64, which clears the hole
-- and still sits inside the band's solid part.
local RING_SIZE, ICON_SIZE = 94, 91
--[[
	The badge keeps its 30. Its ring's hole is 18 across and the mask rounds 30 to
	21, so it already fills -- which matches its looking right while the big one
	did not. Only the nudge is new.
]]
local REWARD_ICON = 30

--[[
	The mask that actually rounds an icon on these clients.

	Interface\CharacterFrame\TempPortraitAlphaMask was the obvious choice and does
	not work: it draws the art in the top-left of a disc wider than the icon, so
	the picture sits small and off-centre inside the ring with black around it.
	Its 64pt sibling does the same, and so does a centred 64pt circle made for the
	job, which rules out the file's dimensions as the difference.

	This one is already shipped and already used -- ui/EncounterFrame.lua masks the
	instance button's icon with it, on the texture ui/Info.lua builds -- and
	photographed against the others at 32, 64 and 96 points it is the only one
	that gives a filled circle at every size. Why the client treats it differently
	is not known; that it does is measured.

	/agc icontest on the debug/icon-probe branch draws that comparison, if a mask
	ever needs choosing again. Do not swap this on reasoning alone.
]]
local PORTRAIT_MASK = I.InstanceButtonIconMask

--[[
	Where that mask's circle actually is, and how big it comes out.

	It is cut for the instance button, not for a ring: the circle spans (3, 1) to
	(48, 46) of the 64pt file, so it is 45pt across -- 0.703 of the file -- with
	its middle 6.5 left and 8.5 up of the file's. Masking an icon with it
	therefore rounds the picture smaller than the icon and off to one side, which
	is why the portrait sat small and high-left inside the ring.

	Both are fixed by placing rather than by redrawing: the icon is sized so the
	circle reaches the hole, and moved by the offset so it lands in the middle.
	The ring is positioned by the layout and the icon hangs off the ring, which is
	the opposite of how it was -- anchored the other way the icon would drag the
	ring along with it and nothing would move.

	A copy of the file with its circle recentred would have been tidier and does
	not work: it renders with a flat dark band across the bottom, on every icon
	tried. Two files measuring as identical circles behave differently and nothing
	here explains why, so the working one is left alone. /agc icontest on the
	debug/icon-probe branch photographs the comparison.
]]
local MASK_OFFSET_X, MASK_OFFSET_Y = 6.5, 8.5

local function MaskOffset(size)
	local scale = size / 64
	return MASK_OFFSET_X * scale, -MASK_OFFSET_Y * scale
end

--[[
	The levelling reminder's portrait. A map, because that pane is about a place
	and the client has no art for a zone. Checked against the client's own icon
	set rather than guessed: I is a path generator, so a name that does not exist
	is a blank ring instead of an error.
]]
local LEFT_OFF_ICON = "Interface\\Icons\\INV_Misc_Map_01"

--[[
	Blizzard's own ink and lettering for these panes, read off the retail frame: a
	black heading over a dark red body, in two faces that differ by more than their
	size so the two do not read as one block of text. Near-black over dark red, in
	one face, read as exactly that.

	QuestFont_Huge and SystemFont_Med1 are the parchment pair and are what retail
	uses here. Both exist on the classic line, but a client that lacks one gets a
	plainer face rather than no face: a font string built from a template that does
	not exist has no font at all and draws nothing.
]]
local TITLE_COLOUR = { 0, 0, 0 }
local BODY_COLOUR = { 0.2824, 0.0157, 0.0157 }

local function FirstFont(...)
	for index = 1, select("#", ...) do
		local name = select(index, ...)
		if _G[name] then return name end
	end
	return "GameFontNormal"
end

local TITLE_FONT = FirstFont("QuestFont_Huge", "GameFontNormalLarge")
local BODY_FONT = FirstFont("SystemFont_Med1", "GameFontNormal")

-- `size` overrides the piece's natural dimensions, for the square ring pieces.
local function ApplyPiece(texture, piece, size)
	texture:SetTexture(SHEET)
	texture:SetTexCoord(piece[1], piece[2], piece[3], piece[4])
	texture:SetSize(size or piece.width, size or piece.height)
end

--[[
	A round portrait, where the client can do it.

	SetMask is what Blizzard uses here, and the ring is a ring -- its middle is
	transparent -- so an unmasked square icon shows its corners through it. Where
	the method is missing the icon is inset instead, which trims the icon's own
	border and leaves the ring sitting on a slightly small square. Less pretty,
	never broken.
]]
local function MaskIcon(texture)
	if texture.SetMask then
		texture:SetMask(PORTRAIT_MASK)
	else
		texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	end
end

--[[
	Mask first, texture second, and both every time a pane is filled rather than
	once when it is built. That is the order Blizzard's own refresh uses, in both of
	its branches, and it is not decoration: a mask set on a texture that already
	carries its file does not reliably take, and an unmasked icon shows its corners
	past the ring -- the hole is wider than the band can cover.
]]
local function SetIcon(texture, icon)
	MaskIcon(texture)
	texture:SetTexture(icon or QUESTION_MARK_ICON or 134400)
end

--[[
	What to put in the ring for an instance.

	Every instance with no art of its own carries the same placeholder id in the
	data files, and it draws as a question mark. That is honest in a list and poor
	in a 94pt ring, which is the whole subject of the pane.

	Five of those instances did have a picture -- the dungeon art shipped in
	images/ -- which is now cropped square and pointed at by their icon field, so
	they arrive here needing nothing special. What is left over gets the journal's
	own generic creature portrait, which is what retail shows for a creature it
	has no art for.

	Cropping the art rather than the quad is not a preference: a texture carrying
	a mask cannot be given tex coords at all, and asking raises an error.
]]
local PLACEHOLDER_ICON = 527422
local GENERIC_ICON = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature"

local function InstanceIcon(instance)
	local icon = instance.icon
	if not icon or icon == PLACEHOLDER_ICON then return GENERIC_ICON end
	return icon
end

--[[
	What to say about an instance, from what the service decided is true of it.

	The service picks which of the four cases holds; the words are here, because
	they are the part that is cosmetic. The level line is added separately so an
	instance with no range -- Forever's -- simply has one line fewer rather than a
	sentence with a hole in it.
]]
local function Describe(suggestion)
	local lines = { }
	if suggestion.kind == "wishlist" then
		local count = suggestion.wanted
		lines[1] = count == 1
				and "An item you are still hunting drops here."
				or ("%d items you are still hunting drop here."):format(count)
	elseif suggestion.kind == "locked" then
		-- The door, which is the one thing the other three panes never mention:
		-- they only ever show what can be entered today.
		lines[1] = ("Opens at level %d."):format(suggestion.unlockLevel or 0)
	elseif suggestion.kind == "unvisited" then
		lines[1] = "You have never set foot in here."
	elseif suggestion.kind == "partial" then
		lines[1] = ("%d of %d bosses defeated."):format(suggestion.defeated, suggestion.total)
	else
		lines[1] = ("All %d bosses defeated."):format(suggestion.total)
	end
	local range = suggestion.levelRange
	if range then
		lines[#lines + 1] = range[1] == range[2]
				and ("Level %d."):format(range[1])
				or ("Levels %d to %d."):format(range[1], range[2])
	end
	--[[
		The quests, named when there is one of them. A single quest's name is the
		useful thing to say and fits the pane; nine names would be the pane's whole
		contents, so those are counted instead.
	]]
	local quests = suggestion.quests or 0
	if quests == 1 and suggestion.questName then
		lines[#lines + 1] = ("Quest to pick up: %s."):format(suggestion.questName)
	elseif quests == 1 then
		lines[#lines + 1] = "One quest here is still open."
	elseif quests > 1 then
		lines[#lines + 1] = ("%d quests here are still open."):format(quests)
	end
	return table.concat(lines, "\n")
end

--[[
	What the pane's button offers.

	A locked instance reads as a look rather than as a trip: the journal shows its
	bosses and its loot at any level, which is the point of offering it four levels
	early, but the player cannot walk in yet and the button should not imply they
	can.
]]
local function ButtonLabel(suggestion)
	if suggestion.kind == "locked" then return "Preview" end
	if suggestion.kind == "cleared" then return "Revisit" end
	return "Open"
end

-- How long ago, in words. Past a month the number stops being the useful part.
local function AgePhrase(days)
	if not days then return nil end
	if days == 0 then return "today" end
	if days == 1 then return "yesterday" end
	if days <= 30 then return ("%d days ago"):format(days) end
	return "a while back"
end

--[[
	The bottom-right pane: where this character was levelling.

	A card rather than a suggestion. It is not an instance and there is nowhere to
	send anyone -- the client will not open the world map to a zone by name -- so
	the pane hides its button rather than offering a trip it cannot make.

	The service decides which of the two cases holds and the words are here, as
	they are for the instances. A remembered zone is stated; a zone worked out
	from the quest log is worded as the deduction it is.
]]
--[[
	The quest badge's icon, and how many quests the tooltip names before it stops
	counting them out. Ten is already more than the pane could ever say.
]]
local QUEST_ICON = "Interface\\Icons\\INV_Misc_Note_01"
local MAX_TOOLTIP_QUESTS = 10

local function QuestBadge(state)
	local titles = state.questTitles
	if not (titles and #titles > 0) then return nil end
	local lines = { }
	for index = 1, math.min(#titles, MAX_TOOLTIP_QUESTS) do
		lines[index] = titles[index]
	end
	if #titles > MAX_TOOLTIP_QUESTS then
		lines[#lines + 1] = ("...and %d more."):format(#titles - MAX_TOOLTIP_QUESTS)
	end
	return { icon = QUEST_ICON, title = state.zone, lines = lines }
end

local function LeftOffCard()
	local state = LevellingService and LevellingService.GetWhereYouLeftOff()
	if not (state and state.zone) then return nil end

	local lines = { }
	if state.remembered then
		local age = AgePhrase(state.days)
		lines[1] = age and ("You left off here, %s."):format(age)
				or "This is where you left off."
		if state.level then
			lines[#lines + 1] = ("You were level %d."):format(state.level)
		end
	else
		lines[1] = "Where your open quests are."
	end

	local quests = state.quests or 0
	if quests == 1 then
		lines[#lines + 1] = "One quest still open."
	elseif quests > 1 then
		lines[#lines + 1] = ("%d quests still open."):format(quests)
	end

	return {
		title = state.zone,
		description = table.concat(lines, "\n"),
		icon = LEFT_OFF_ICON,
		badge = QuestBadge(state),
	}
end

local function GoTo(suggestion)
	local instance = suggestion and suggestion.instance
	if not instance then return end
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
	AdventureGuideNavigationService.Reset()
	--[[
		Clicking through leaves the journal showing a dungeon or a raid, so the lit
		tab has to agree with that rather than still claiming this one. Worked out
		from the raid list rather than stored, the way ui/Wishlist.lua does it.
	]]
	local isRaid = false
	for _, raid in ipairs(InstanceService.GetRaids() or { }) do
		if raid.name == instance.name then
			isRaid = true
			break
		end
	end
	AdventureGuideNavigationService.SetInstances(
			isRaid and InstanceService.GetRaids() or InstanceService.GetDungeons())
	components.InstanceSelect.SetTitle(isRaid and RAIDS or DUNGEONS)
	components.EncounterJournalTabs.SelectTab(
			isRaid and EncounterJournal.raidsTab or EncounterJournal.dungeonsTab)
	AdventureGuideNavigationService.SetInstance(instance)
	components.EncounterFrame.ShowInstanceInfo(instance)
	components.NavBar.SetInstance(instance)
end

--[[
	The small ring carries either an item or a list, so the tooltip does both. An
	item is the client's own tooltip; a list is a heading and its lines, which is
	what a card hangs there when it has more to say than three lines of pane hold.
]]
local function RewardOnEnter(self)
	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
		return
	end
	if not self.tooltipTitle then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltipTitle)
	for _, line in ipairs(self.tooltipLines or { }) do
		GameTooltip:AddLine(line, 1, 0.82, 0)
	end
	GameTooltip:Show()
end

local function RewardOnLeave()
	GameTooltip_Hide()
end

--[[
	The reward corner: the one wishlist item that pulled this instance up.

	Shown only for a wishlist suggestion, because on any other kind the ring would
	be making a promise the ranking never made.
]]
local function BuildReward(pane)
	pane.reward = CreateFrame("Frame", nil, pane)
	pane.reward:SetSize(48, 48)
	pane.reward:EnableMouse(true)
	pane.reward.icon = pane.reward:CreateTexture(nil, "ARTWORK")
	pane.reward.icon:SetSize(REWARD_ICON, REWARD_ICON)
	-- The badge is masked by the same file, so it needs the same nudge, scaled.
	pane.reward.icon:SetPoint("CENTER", pane.reward, "CENTER", MaskOffset(REWARD_ICON))
	pane.reward.ring = pane.reward:CreateTexture(nil, "OVERLAY")
	ApplyPiece(pane.reward.ring, REWARD)
	pane.reward.ring:SetPoint("CENTER")
	pane.reward:SetScript("OnEnter", RewardOnEnter)
	pane.reward:SetScript("OnLeave", RewardOnLeave)
	pane.reward:Hide()
end

local function BuildPane(parent, large)
	local pane = CreateFrame("Frame", nil, parent)
	local piece = large and LARGE or SMALL
	pane:SetSize(piece.width, piece.height)

	pane.bg = pane:CreateTexture(nil, "BACKGROUND")
	ApplyPiece(pane.bg, piece)
	pane.bg:SetAllPoints(pane)

	pane.ring = pane:CreateTexture(nil, "OVERLAY")
	ApplyPiece(pane.ring, RING, RING_SIZE)
	pane.icon = pane:CreateTexture(nil, "ARTWORK")
	pane.icon:SetSize(ICON_SIZE, ICON_SIZE)
	pane.icon:SetPoint("CENTER", pane.ring, "CENTER", MaskOffset(ICON_SIZE))

	pane.title = pane:CreateFontString(nil, "ARTWORK", TITLE_FONT)
	pane.title:SetTextColor(unpack(TITLE_COLOUR))
	pane.description = pane:CreateFontString(nil, "ARTWORK", BODY_FONT)
	pane.description:SetTextColor(unpack(BODY_COLOUR))
	pane.description:SetSpacing(2)

	pane.button = CreateFrame("Button", nil, pane, "UIPanelButtonTemplate")
	pane.button:SetScript("OnClick", function(self)
		GoTo(self:GetParent().entry)
	end)

	BuildReward(pane)
	if large then
		--[[
			Anchored by its centre rather than its top edge, so the ring can be
			resized without dragging the portrait up the page with it. The point is
			where a 64pt icon hung 2pt below the top edge put it, which is what
			leaves the ring overhanging the page the way Blizzard's does.
		]]
		pane.ring:SetPoint("CENTER", pane, "TOP", 0, -34)
		--[[
			The text block sits low rather than under the portrait. Composited at
			-78 it left a hand's width of blank parchment between the description
			and the button, with the reward ring stranded in the middle of it.
		]]
		pane.title:SetPoint("TOP", 0, -118)
		pane.title:SetWidth(264)
		pane.title:SetJustifyH("CENTER")
		pane.description:SetPoint("TOP", pane.title, "BOTTOM", 0, -12)
		pane.description:SetWidth(264)
		pane.description:SetJustifyH("CENTER")
		pane.button:SetSize(140, 30)
		pane.button:SetPoint("BOTTOM", 0, 34)
		-- Labelled, or the ring reads as an ornament rather than as the item.
		pane.reward:SetPoint("CENTER", pane, "BOTTOM", 34, 84)
		-- On the reward frame, not on the pane, so it hides with it. A frame does
		-- not clip its children, so anchoring it outside costs nothing.
		pane.reward.label = pane.reward:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		pane.reward.label:SetTextColor(unpack(BODY_COLOUR))
		pane.reward.label:SetJustifyH("RIGHT")
		pane.reward.label:SetPoint("RIGHT", pane.reward, "LEFT", -8, 0)
		pane.reward.label:SetText("Still wanted")
	else
		--[[
			Retail's own offsets. The portrait hangs off the pane's top-left corner --
			a 64pt icon anchored at (-10, -2) from it, which is this centre -- so the
			ring overhangs the parchment instead of sitting on it, and the text starts
			at 70, just clear of the ring's edge at 69.
		]]
		pane.ring:SetPoint("CENTER", pane, "TOPLEFT", 22, -34)
		pane.title:SetPoint("TOPLEFT", 70, -20)
		pane.title:SetWidth(260)
		pane.title:SetJustifyH("LEFT")
		--[[
			-14, not -6. QuestFont_Huge sits high in its own line, so a gap that
			measures evenly leaves the text looking stuck to the title's feet.
		]]
		pane.description:SetPoint("TOPLEFT", pane.title, "BOTTOMLEFT", 0, -14)
		pane.description:SetWidth(240)
		pane.description:SetJustifyH("LEFT")
		pane.button:SetSize(116, 24)
		pane.button:SetPoint("TOPLEFT", 70, -108)
		-- Tucked into the portrait's lower right, where retail carries it.
		--[[
			Off the ring rather than off the icon, which has grown and moved. The
			icon's old corner was the ring's centre plus (32, -32), and this sat
			(-11, 6) from that, so the same spot is (-26, 21) from the ring's own
			corner -- the badge has not moved.
		]]
		pane.reward:SetPoint("CENTER", pane.ring, "BOTTOMRIGHT", -26, 21)
	end
	return pane
end

--[[
	A pane holds either a suggested instance or a card, told apart by whether it
	carries one. Everything the art provides is shared; what differs is that a card
	brings its own words and has no trip to offer.
]]
--[[
	The smaller ring on the portrait's shoulder. Retail hangs the reward item there;
	a card hangs a badge, which is the same ring carrying a tooltip instead of a
	trip. Both fields are cleared on every fill, or a pane that held one would keep
	showing its tooltip under the next thing put in it.
]]
local function ShowBadge(pane, badge)
	pane.reward.itemLink = nil
	pane.reward.tooltipTitle = nil
	pane.reward.tooltipLines = nil
	if not badge then
		pane.reward:Hide()
		return
	end
	SetIcon(pane.reward.icon, badge.icon)
	pane.reward.itemLink = badge.itemLink
	pane.reward.tooltipTitle = badge.title
	pane.reward.tooltipLines = badge.lines
	pane.reward:Show()
end

local function FillPane(pane, entry)
	pane.entry = entry
	if not entry then
		pane:Hide()
		return
	end
	pane:Show()

	if not entry.instance then
		SetIcon(pane.icon, entry.icon)
		pane.title:SetText(entry.title)
		pane.description:SetText(entry.description)
		pane.button:Hide()
		ShowBadge(pane, entry.badge)
		return
	end

	SetIcon(pane.icon, InstanceIcon(entry.instance))
	pane.title:SetText(entry.name)
	pane.description:SetText(Describe(entry))
	pane.button:SetText(ButtonLabel(entry))
	pane.button:Show()
	local item = entry.kind == "wishlist" and entry.wantedItem
	ShowBadge(pane, item and {
		icon = GetItemIcon and GetItemIcon(item.itemID),
		itemLink = item.itemLink,
	} or nil)
end

local function Step(by)
	local ranked = SuggestionService.GetRanked()
	-- The last suggestion is the last page: paging past it would blank the big
	-- pane while the arrow stayed lit.
	local limit = math.max(#ranked - 1, 0)
	local wanted = math.min(math.max(offset + by, 0), limit)
	if wanted == offset then return end
	offset = wanted
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN)
	component.Refresh()
end

--[[
	The three panes, each answering its own question.

	Only the big one is a page of the ranking, and the offset is none of the other
	two's business -- retail's own frame calls it the *primary* offset for that
	reason, and fills its Suggestion2 and Suggestion3 from elsewhere entirely.

	So: what to do now, what opens up next, and where this character left off.
	Each side pane falls back to the ranking when it has nothing of its own to
	say, because an empty pane is a hole in the artwork rather than a blank space.
]]
function component.Refresh()
	local ranked = SuggestionService.GetRanked()
	if #ranked == 0 then
		FillPane(panes.primary, nil)
		FillPane(panes.secondary, nil)
		FillPane(panes.tertiary, nil)
		suggest.empty:Show()
		suggest.prev:SetEnabled(false)
		suggest.next:SetEnabled(false)
		return
	end

	suggest.empty:Hide()
	if offset > #ranked - 1 then offset = 0 end
	FillPane(panes.primary, ranked[offset + 1])
	FillPane(panes.secondary, SuggestionService.GetCompanion(ranked))
	FillPane(panes.tertiary, LeftOffCard() or ranked[3])
	suggest.prev:SetEnabled(offset > 0)
	suggest.next:SetEnabled(offset + 1 < #ranked)
end

function component.Show()
	component.Refresh()
	components.EncounterJournal.SetCurrentView(suggest)
	components.NavBar.Reset()
end

function component.Init(components_)
	components = components_
	suggest = CreateFrame("Frame", EncounterJournal:GetName() .. "Suggest", EncounterJournal)
	component.frame = suggest
	EncounterJournal.suggest = suggest
	suggest:SetPoint("TOPLEFT", EncounterJournal.inset, 0, -2)
	suggest:SetPoint("BOTTOMRIGHT", EncounterJournal.inset, -3, 0)

	-- The same dark band the wishlist and the loot tab carry their title on.
	suggest.header = suggest:CreateTexture(nil, "BACKGROUND")
	suggest.header:SetColorTexture(0.102, 0.094, 0.086, 1)
	suggest.header:SetPoint("TOPLEFT", 3, -1)
	suggest.header:SetPoint("TOPRIGHT", -2, -1)
	suggest.header:SetHeight(HEADER_HEIGHT)

	suggest.title = suggest:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge2")
	suggest.title:SetJustifyH("LEFT")
	suggest.title:SetPoint("TOPLEFT", 20, -14)
	suggest.title:SetText("Suggested Content")

	local left = math.floor((EncounterJournal:GetWidth() - GROUP_WIDTH) / 2) - 4
	panes.primary = BuildPane(suggest, true)
	panes.primary:SetPoint("TOPLEFT", left, -(HEADER_HEIGHT + 14))
	panes.secondary = BuildPane(suggest, false)
	panes.secondary:SetPoint("TOPLEFT", panes.primary, "TOPRIGHT", 30, 0)
	panes.tertiary = BuildPane(suggest, false)
	panes.tertiary:SetPoint("TOPLEFT", panes.secondary, "BOTTOMLEFT", 0, -11)

	--[[
		The arrows move the big pane alone, one suggestion at a time, as the two
		buttons on retail's own primary pane do. They sit on that pane rather than
		on the page for the same reason: what they page is the thing they are drawn
		on, and a reader should not have to find that out by pressing one.
	]]
	suggest.prev = CreateFrame("Button", nil, panes.primary)
	suggest.prev:SetSize(32, 32)
	suggest.prev:SetPoint("BOTTOMLEFT", 14, 10)
	suggest.prev:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	suggest.prev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	suggest.prev:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	suggest.prev:SetScript("OnClick", function() Step(-1) end)

	suggest.next = CreateFrame("Button", nil, panes.primary)
	suggest.next:SetSize(32, 32)
	suggest.next:SetPoint("BOTTOMRIGHT", -14, 10)
	suggest.next:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	suggest.next:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	suggest.next:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	suggest.next:SetScript("OnClick", function() Step(1) end)

	suggest:EnableMouseWheel(true)
	suggest:SetScript("OnMouseWheel", function(_, delta) Step(delta > 0 and -1 or 1) end)

	--[[
		Nothing to suggest happens on a client whose whole instance list is behind
		the player's level -- a level 1 character on BCC, say -- so it reads as a
		sentence rather than as three blank sheets of parchment.
	]]
	suggest.empty = suggest:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	suggest.empty:SetPoint("CENTER", 0, 20)
	suggest.empty:SetSize(460, 40)
	suggest.empty:SetText("Nothing to suggest yet. Come back a few levels from now.")
	suggest.empty:Hide()

	--[[
		The ranking reads the wishlist, so adding or removing an item while this is
		open should move the panes. ui/Loot.lua owns the single OnWishlistChanged
		slot, which is why this registers rather than assigns.
	]]
	WishlistService.RegisterChangeListener(function()
		if suggest:IsShown() then component.Refresh() end
	end)

	suggest:Hide()
end

UI.Add(component)
