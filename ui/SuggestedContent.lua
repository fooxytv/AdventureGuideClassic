--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
The Suggested Content tab: one large hero card for the leading suggestion, then a row
of smaller cards beneath it, mirroring how retail's Adventure Guide lays out its
Suggested tab.

Cards come from SuggestedContentService as plain data; deciding what a click does is
this component's job, keyed off card.type.

Deliberately built on a plain layout rather than WowScrollBoxList: the ScrollBox grid
APIs diverge between Era and BCC (SetElementExtent vs SetElementSize -- see
ui/InstanceSelect.lua), and with at most five cards there is nothing to scroll.
]]

local component = UI.CreateComponent("SuggestedContent")
local components

local HERO_HEIGHT = 132
local CARD_WIDTH, CARD_HEIGHT = 174, 96
local CARD_SPACING = 10
local MAX_CARDS = 4

local heroCard
local cards = { }

local EJ_TEXTURES = "Interface/EncounterJournal/UI-EncounterJournalTextures"

local function ApplyEJButtonTextures(button)
	local normal = button:CreateTexture()
	normal:SetTexture(EJ_TEXTURES)
	normal:SetTexCoord(0.00195313, 0.34179688, 0.42871094, 0.52246094)
	button:SetNormalTexture(normal)
	local pushed = button:CreateTexture()
	pushed:SetTexture(EJ_TEXTURES)
	pushed:SetTexCoord(0.00195313, 0.34179688, 0.33300781, 0.42675781)
	button:SetPushedTexture(pushed)
	local highlight = button:CreateTexture()
	highlight:SetTexture(EJ_TEXTURES)
	highlight:SetTexCoord(0.34570313, 0.68554688, 0.33300781, 0.42675781)
	button:SetHighlightTexture(highlight)
end

--[[
What clicking a card does. Zone cards open the world map on that zone; dungeon cards
navigate into the instance exactly as clicking it on the Dungeons tab would.
]]
local function Card_OnClick(self)
	local card = self.card
	if not card then return end

	if card.type == "dungeon" or card.type == "raid" then
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
		component.frame:Hide()
		AdventureGuideNavigationService.Reset()
		AdventureGuideNavigationService.SetInstance(card.instance)
		components.EncounterFrame.ShowInstanceInfo(card.instance)
	elseif card.type == "zone" and GuideService.GetGuideForZone(card.title) then
		-- Closes the loop: the zone card answers "where", the guide answers "what to
		-- do there". Falls through to the map below for zones we have no guide for.
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
		local guide = GuideService.GetGuideForZone(card.title)
		GuideService.SetCurrentGuide(guide.id)
		GuideWindow.Show()
	elseif card.type == "zone" or card.type == "event" then
		if not card.uiMapID then return end
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
		if C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(card.uiMapID) then
			if WorldMapFrame and not WorldMapFrame:IsShown() then
				ToggleWorldMap()
			end
			if WorldMapFrame and WorldMapFrame.SetMapID then
				WorldMapFrame:SetMapID(card.uiMapID)
			end
		end
	end
end

local function Card_OnEnter(self)
	local card = self.card
	if not card or not card.description then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(card.title, 1, 1, 1)
	if card.subtitle then
		GameTooltip:AddLine(card.subtitle, 0.65, 0.85, 1)
	end
	GameTooltip:AddLine(card.description, nil, nil, nil, true)
	GameTooltip:Show()
end

local function Card_OnLeave()
	GameTooltip:Hide()
end

-- Hero card -------------------------------------------------------------------

local function CreateHeroCard(parent)
	local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
	button:SetSize(1, HERO_HEIGHT)
	-- Don't assume the shared backdrop constant exists on both clients; fall back to
	-- an equivalent literal rather than erroring out of Init and losing the whole tab.
	button.backdropInfo = BACKDROP_GLUE_TOOLTIP_16_16 or {
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileEdge = true, tileSize = 16, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	}
	if button.OnBackdropLoaded then
		button:OnBackdropLoaded()
		button:SetBackdropBorderColor(0.78, 0.73, 0.56)
	end

	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetSize(96, 96)
	button.icon:SetPoint("LEFT", 16, 0)
	button.icon:SetTexCoord(0.07, 0.62, 0.06, 0.70)

	button.iconBorder = button:CreateTexture(nil, "OVERLAY")
	button.iconBorder:SetTexture(EJ_TEXTURES)
	button.iconBorder:SetTexCoord(0.00195313, 0.34179688, 0.42871094, 0.52246094)
	button.iconBorder:SetPoint("TOPLEFT", button.icon, -6, 6)
	button.iconBorder:SetPoint("BOTTOMRIGHT", button.icon, 6, -6)
	button.iconBorder:SetAlpha(0.35)

	button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	button.label:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 18, -4)
	button.label:SetTextColor(0.6, 0.6, 0.6)

	button.title = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")
	button.title:SetPoint("TOPLEFT", button.label, "BOTTOMLEFT", 0, -4)
	button.title:SetJustifyH("LEFT")

	button.subtitle = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.subtitle:SetPoint("TOPLEFT", button.title, "BOTTOMLEFT", 0, -4)
	button.subtitle:SetTextColor(0.65, 0.85, 1)

	button.description = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	button.description:SetPoint("TOPLEFT", button.subtitle, "BOTTOMLEFT", 0, -8)
	button.description:SetPoint("RIGHT", button, "RIGHT", -20, 0)
	button.description:SetJustifyH("LEFT")
	button.description:SetJustifyV("TOP")
	button.description:SetHeight(44)

	button:SetScript("OnClick", Card_OnClick)
	button:SetScript("OnEnter", function(self)
		self:SetBackdropBorderColor(1, 0.82, 0)
	end)
	button:SetScript("OnLeave", function(self)
		self:SetBackdropBorderColor(0.78, 0.73, 0.56)
	end)
	return button
end

local HERO_LABELS = {
	zone = "SUGGESTED ZONE",
	dungeon = "SUGGESTED DUNGEON",
	raid = "SUGGESTED RAID",
	event = "LIVE EVENT",
}

local function SetHeroCard(card)
	if not card then
		heroCard:Hide()
		return
	end
	heroCard.card = card
	heroCard.label:SetText(HERO_LABELS[card.type] or "SUGGESTED")
	heroCard.title:SetText(card.title)
	heroCard.subtitle:SetText(card.subtitle or "")
	heroCard.description:SetText(card.description or "")

	if card.thumbnail then
		heroCard.icon:SetTexture(card.thumbnail)
		heroCard.icon:Show()
		heroCard.iconBorder:Show()
		heroCard.label:SetPoint("TOPLEFT", heroCard.icon, "TOPRIGHT", 18, -4)
	else
		-- Zones have no art of their own, so the text simply takes the full width.
		heroCard.icon:Hide()
		heroCard.iconBorder:Hide()
		heroCard.label:SetPoint("TOPLEFT", heroCard, "TOPLEFT", 20, -16)
	end
	heroCard:Show()
end

-- Secondary cards -------------------------------------------------------------

local function CreateCard(parent)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(CARD_WIDTH, CARD_HEIGHT)
	button.bgImage = button:CreateTexture(nil, "BACKGROUND")
	button.bgImage:SetTexCoord(0, 0.68359375, 0, 0.7421875)
	button.bgImage:SetAllPoints()
	button.title = button:CreateFontString(nil, "OVERLAY", "QuestTitleFontBlackShadow")
	button.title:SetSize(150, 0)
	button.title:SetPoint("TOP", 0, -15)
	button.range = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.range:SetSize(140, 12)
	button.range:SetPoint("BOTTOMLEFT", 7, 7)
	button.range:SetJustifyH("LEFT")
	ApplyEJButtonTextures(button)
	button:SetScript("OnClick", Card_OnClick)
	button:SetScript("OnEnter", Card_OnEnter)
	button:SetScript("OnLeave", Card_OnLeave)
	return button
end

local function SetCard(button, card)
	button.card = card
	button.title:SetText(card.title)
	button.range:SetText(card.shortSubtitle or card.subtitle or "")
	if card.thumbnail then
		button.bgImage:SetTexture(card.thumbnail)
		button.bgImage:Show()
	else
		button.bgImage:Hide()
	end
	button:Show()
end

-- Component -------------------------------------------------------------------

function component.Init(components_)
	components = components_
	local frame = CreateFrame("Frame", EncounterJournal:GetName() .. "SuggestedContent", EncounterJournal)
	component.frame = frame
	EncounterJournal.suggestedContent = frame
	frame:SetPoint("TOPLEFT", EncounterJournal.inset, 0, -2)
	frame:SetPoint("BOTTOMRIGHT", EncounterJournal.inset, -3, 0)

	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetTexture("Interface/EncounterJournal/UI-EJ-Classic")
	frame.bg:SetAllPoints()
	frame.bg:SetPoint("TOPLEFT", 3, -1)

	frame.title = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge2")
	frame.title:SetJustifyH("LEFT")
	frame.title:SetPoint("TOPLEFT", 20, -15)
	frame.title:SetText("Suggested Content")

	frame.playerLevel = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	frame.playerLevel:SetJustifyH("RIGHT")
	frame.playerLevel:SetPoint("TOPRIGHT", -20, -18)
	frame.playerLevel:SetTextColor(0.65, 0.85, 1)

	heroCard = CreateHeroCard(frame)
	heroCard:SetPoint("TOPLEFT", 20, -48)
	heroCard:SetPoint("TOPRIGHT", -20, -48)

	frame.cardsHeading = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	frame.cardsHeading:SetJustifyH("LEFT")
	frame.cardsHeading:SetPoint("TOPLEFT", heroCard, "BOTTOMLEFT", 0, -14)

	for index = 1, MAX_CARDS do
		local button = CreateCard(frame)
		if index == 1 then
			button:SetPoint("TOPLEFT", frame.cardsHeading, "BOTTOMLEFT", 0, -8)
		else
			button:SetPoint("TOPLEFT", cards[index - 1], "TOPRIGHT", CARD_SPACING, 0)
		end
		cards[index] = button
	end

	frame.emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableLarge")
	frame.emptyText:SetPoint("CENTER", 0, 20)
	frame.emptyText:SetText("No suggestions available.")
	frame.emptyText:Hide()

	-- Rebuild whenever the character's level or faction moves, so the tab is never
	-- stale when reopened after dinging.
	PlayerContextService.RegisterListener(function(_, changed)
		if (changed.level or changed.maxLevel or changed.faction) and frame:IsShown() then
			component.Refresh()
		end
	end)

	frame:Hide()
end

function component.Refresh()
	local level = PlayerContextService.GetLevel()
	local faction = PlayerContextService.GetFaction()
	local suggestions = SuggestedContentService.GetSuggestions(level, faction)

	component.frame.playerLevel:SetText(("Level %d %s"):format(level, tostring(faction or "")))

	SetHeroCard(suggestions[1])

	local shown, allDungeons = 0, true
	for index = 1, MAX_CARDS do
		local card = suggestions[index + 1]
		if card then
			SetCard(cards[index], card)
			shown = shown + 1
			if card.type ~= "dungeon" then allDungeons = false end
		else
			cards[index]:Hide()
		end
	end

	-- Only claim the row is dungeons when it actually is. A live event takes the hero
	-- slot and pushes the zone card down here, which would otherwise be mislabelled.
	local secondaryHeading = "Also available"
	if allDungeons and not PlayerContextService.IsMaxLevel() then
		secondaryHeading = "Dungeons for your level"
	end

	if shown > 0 then
		component.frame.cardsHeading:SetText(secondaryHeading)
		component.frame.cardsHeading:Show()
	else
		component.frame.cardsHeading:Hide()
	end

	component.frame.emptyText:SetShown(#suggestions == 0)
end

function component.Show()
	component.Refresh()
	components.EncounterJournal.SetCurrentView(component.frame)
	components.NavBar.Reset()
end

UI.Add(component)
