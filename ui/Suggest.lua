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
	Portrait sizes, per pane, because the ring art is mostly band.

	Measured off the sheet: the ring's transparent middle is 0.53 of the texture it
	is drawn at, so the portrait only ever shows at about half the ring's size and
	shrinking one shrinks the other. At the sheet's own 94 the ring took most of the
	height of a 161pt small pane and read as the subject rather than the frame.

	The icon is kept a little wider than the hole so the band lands on its rim
	instead of on bare parchment.
]]
local LARGE_RING, LARGE_ICON = 78, 50
local SMALL_RING, SMALL_ICON = 66, 42
local PORTRAIT_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"

-- Blizzard's ink: near-black for a heading, a dark red-brown for the body.
local TITLE_COLOUR = { 0.1, 0.07, 0.04 }
local BODY_COLOUR = { 0.2824, 0.0157, 0.0157 }

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

local function SetIcon(texture, icon)
	texture:SetTexture(icon or QUESTION_MARK_ICON or 134400)
	MaskIcon(texture)
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
	return table.concat(lines, "\n")
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

local function RewardOnEnter(self)
	if not self.itemLink then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink(self.itemLink)
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
	pane.reward.icon:SetSize(30, 30)
	pane.reward.icon:SetPoint("CENTER")
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

	pane.icon = pane:CreateTexture(nil, "ARTWORK")
	pane.icon:SetSize(large and LARGE_ICON or SMALL_ICON,
			large and LARGE_ICON or SMALL_ICON)
	pane.ring = pane:CreateTexture(nil, "OVERLAY")
	ApplyPiece(pane.ring, RING, large and LARGE_RING or SMALL_RING)
	pane.ring:SetPoint("CENTER", pane.icon, "CENTER")

	pane.title = pane:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	pane.title:SetTextColor(unpack(TITLE_COLOUR))
	pane.description = pane:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	pane.description:SetTextColor(unpack(BODY_COLOUR))
	pane.description:SetSpacing(2)

	pane.button = CreateFrame("Button", nil, pane, "UIPanelButtonTemplate")
	pane.button:SetScript("OnClick", function(self)
		GoTo(self:GetParent().suggestion)
	end)

	BuildReward(pane)
	if large then
		--[[
			Anchored by its centre rather than its top edge, so the ring can be
			resized without dragging the portrait up the page with it. The point is
			where a 64pt icon hung 2pt below the top edge put it, which is what
			leaves the ring overhanging the page the way Blizzard's does.
		]]
		pane.icon:SetPoint("CENTER", pane, "TOP", 0, -34)
		--[[
			The text block sits low rather than under the portrait. Composited at
			-78 it left a hand's width of blank parchment between the description
			and the button, with the reward ring stranded in the middle of it.
		]]
		pane.title:SetPoint("TOP", 0, -118)
		pane.title:SetWidth(264)
		pane.title:SetJustifyH("CENTER")
		pane.description:SetPoint("TOP", pane.title, "BOTTOM", 0, -12)
		pane.description:SetWidth(252)
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
		-- Centred where the old 64pt icon sat, for the same reason as above.
		pane.icon:SetPoint("CENTER", pane, "TOPLEFT", 54, -46)
		pane.title:SetPoint("TOPLEFT", 96, -22)
		pane.title:SetWidth(232)
		pane.title:SetJustifyH("LEFT")
		pane.description:SetPoint("TOPLEFT", pane.title, "BOTTOMLEFT", 0, -6)
		pane.description:SetWidth(232)
		pane.description:SetJustifyH("LEFT")
		pane.button:SetSize(116, 26)
		pane.button:SetPoint("TOPLEFT", 96, -108)
		-- On the portrait's corner, which is where the small pane carries it.
		pane.reward:SetPoint("CENTER", pane.icon, "BOTTOMRIGHT", -2, 6)
	end
	return pane
end

local function FillPane(pane, suggestion)
	pane.suggestion = suggestion
	if not suggestion then
		pane:Hide()
		return
	end
	pane:Show()
	SetIcon(pane.icon, suggestion.instance.icon)
	pane.title:SetText(suggestion.name)
	pane.description:SetText(Describe(suggestion))
	pane.button:SetText(suggestion.kind == "cleared" and "Revisit" or "Open")
	local item = suggestion.kind == "wishlist" and suggestion.wantedItem
	if item then
		pane.reward.itemLink = item.itemLink
		local icon = GetItemIcon and GetItemIcon(item.itemID)
		pane.reward.icon:SetTexture(icon or QUESTION_MARK_ICON or 134400)
		MaskIcon(pane.reward.icon)
		pane.reward:Show()
	else
		pane.reward:Hide()
	end
end

local function Step(by)
	local ranked = SuggestionService.GetRanked()
	-- The last page is the one that still fills the big pane; paging past it
	-- would leave all three blank with the arrows still lit.
	local limit = math.max(#ranked - 1, 0)
	local wanted = math.min(math.max(offset + by, 0), limit)
	if wanted == offset then return end
	offset = wanted
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN)
	component.Refresh()
end

function component.Refresh()
	local ranked = SuggestionService.GetRanked()
	if offset > math.max(#ranked - 1, 0) then offset = 0 end
	FillPane(panes.primary, ranked[offset + 1])
	FillPane(panes.secondary, ranked[offset + 2])
	FillPane(panes.tertiary, ranked[offset + 3])
	suggest.empty:SetShown(#ranked == 0)
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
		The arrows page the whole list by one, which is what the big pane's two
		buttons do in retail. Stepping by three would make the thing it is best at
		-- "here is the one place to go" -- the hardest reading to get back to.
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
