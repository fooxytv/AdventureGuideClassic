--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
The Quests tab: a zone's storylines, and where this character stands in each.

What this shows the player, stated plainly: a zone's quests are not a list, they are a
handful of stories. Elwynn has the defence of Northshire, the trouble at the Fargodeep
Mine, Marshal Dughan's problem with the Riverpaw. Each is a chain of quests. The tab
presents those stories, in the order you would meet them, showing how far through each
you are and -- where you cannot continue -- why.

Drawn as the encounter view is drawn, because that IS the addon's look: the journal
parchment behind everything, storylines on the left as the boss list is (the same
button art, a "defeated" mark once the story is done), and the selected storyline on
the right on the overview's paper, in its ink, under one of its section headers.
Storylines have no portrait: there is no art for them, and the default boss disc
read as exactly that -- a placeholder. A player who has used the Dungeons tab already knows how to read
this one. The earlier version used inset panels and white text on the dark background,
which belonged to no part of the journal and was hard to read besides.

Built on plain ScrollFrames, the pattern ui/DynamicContentScroller.lua already proves
on both clients. ScrollBox list views are the API that diverges between Era and BCC.
]]

local component = UI.CreateComponent("QuestChains")
local components

local EJ_TEXTURES = "Interface/EncounterJournal/UI-EncounterJournalTextures"

-- The encounter view's own palette, so this reads as the same journal.
local TITLE_COLOR = { 0.902, 0.788, 0.671 }   -- instance title over the parchment
local BUTTON_TEXT = { 0.87, 0.659, 0.463 }    -- boss-button names
local HEADER_TEXT = { 0.929, 0.788, 0.620 }   -- overview section headers
local INK = { 0.25, 0.1484375, 0.02 }         -- overview body text

-- Quest names are ink on paper, so status is shown as darker inks rather than the
-- quest log's bright colours, which vanish against parchment.
local STATUS_INK = {
	completed = { 0.16, 0.42, 0.14 },
	active    = { 0.60, 0.36, 0.02 },
	available = INK,
	blocked   = { 0.45, 0.39, 0.33 },
}

-- Textures rather than glyphs: a tick and a quest marker read instantly, where "v"
-- and ">" have to be decoded.
local STATUS_ICON = {
	completed = "Interface/RaidFrame/ReadyCheck-Ready",
	active    = "Interface/GossipFrame/ActiveQuestIcon",
	available = "Interface/GossipFrame/AvailableQuestIcon",
	blocked   = nil,
}

local STORY_WIDTH, STORY_HEIGHT, STORY_SPACING = 325, 55, 8
local DETAIL_WIDTH = 320
local HEADING_HEIGHT = 30
local QUEST_ROW_HEIGHT = 20
local REASON_ROW_HEIGHT = 15

local SINGLES = "__singles__"

local listScroll, detailScroll, selectedHighlight
local storyButtons, detailRows = { }, { }
local detailUsed = 0
local chains, standalone, currentZone, selectedKey

-- Helpers ------------------------------------------------------------------------------

-- The plain-ScrollFrame recipe from DynamicContentScroller, in one place.
local function CreateScroller(parent, width, height, childWidth, scrollBarX)
	local scroll = CreateFrame("ScrollFrame", nil, parent)
	scroll:SetSize(width, height)
	scroll.scrollBarX = scrollBarX
	scroll.scrollBarTopY = -6
	scroll.scrollBarBottomY = 6
	scroll.scrollBarTemplate = "MinimalScrollBar"
	scroll.child = CreateFrame("Frame", nil, scroll)
	scroll.child:SetSize(childWidth, 10)
	scroll.child:SetPoint("TOPLEFT")
	scroll:SetScrollChild(scroll.child)
	-- ScrollFrame_OnLoad also wires the mouse wheel to the bar it creates. Do not
	-- add ScrollFrameTemplate_OnMouseWheel on top: that is the legacy Slider handler,
	-- and MinimalScrollBar is not a Slider -- it has no GetValue, so the wheel throws.
	if ScrollFrame_OnLoad then pcall(ScrollFrame_OnLoad, scroll) end
	return scroll
end

local function SetColor(fontString, color)
	fontString:SetTextColor(color[1], color[2], color[3])
end

local function LevelBand(summary)
	if not summary.minLevel then return "" end
	if summary.maxLevel and summary.maxLevel ~= summary.minLevel then
		return ("Levels %d-%d"):format(summary.minLevel, summary.maxLevel)
	end
	return ("Level %d"):format(summary.minLevel)
end

-- Storyline buttons ------------------------------------------------------------------------

--[[
One storyline, drawn as a boss is drawn in the encounter view: the same button art,
the name in the same bronze, the same "defeated" mark once it is finished. Where the
boss has a portrait, the storyline has its state -- waiting, underway or done -- as a
quest marker. Below the name, what a boss never needs: the level band, the count, and
a progress bar -- keeping track is the point of the tab.
]]
local function CreateStoryButton(parent)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(STORY_WIDTH, STORY_HEIGHT)

	local normal = button:CreateTexture()
	normal:SetTexture(EJ_TEXTURES)
	normal:SetTexCoord(0.00195313, 0.63671875, 0.21386719, 0.26757813)
	button:SetNormalTexture(normal)
	local pushed = button:CreateTexture()
	pushed:SetTexture(EJ_TEXTURES)
	pushed:SetTexCoord(0.00195313, 0.63671875, 0.10253906, 0.15625000)
	button:SetPushedTexture(pushed)
	local highlight = button:CreateTexture()
	highlight:SetTexture(EJ_TEXTURES)
	highlight:SetTexCoord(0.00195313, 0.63671875, 0.15820313, 0.21191406)
	button:SetHighlightTexture(highlight)

	-- Sits where the boss portrait would, centred on the recess in the button art.
	button.status = button:CreateTexture(nil, "OVERLAY", nil, 6)
	button.status:SetSize(30, 30)
	button.status:SetPoint("CENTER", button, "TOPLEFT", 30, -22)

	button.done = CreateFrame("Frame", nil, button)
	button.done:SetSize(16, 16)
	button.done:SetFrameLevel(button:GetFrameLevel() + 5)
	button.done:SetPoint("BOTTOMLEFT", 4, 0)
	button.done.icon = button.done:CreateTexture(nil, "BACKGROUND")
	Atlas.SetAtlas(button.done.icon, "Map-MarkedDefeated", true)
	button.done.icon:SetPoint("CENTER")

	button.name = button:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
	button.name:SetSize(246, 16)
	button.name:SetJustifyH("LEFT")
	button.name:SetWordWrap(false)
	button.name:SetPoint("TOPLEFT", 64, -8)
	SetColor(button.name, BUTTON_TEXT)

	button.detail = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	button.detail:SetJustifyH("LEFT")
	button.detail:SetPoint("TOPLEFT", button.name, "BOTTOMLEFT", 0, -1)
	button.detail:SetTextColor(BUTTON_TEXT[1], BUTTON_TEXT[2], BUTTON_TEXT[3], 0.85)

	button.barBg = button:CreateTexture(nil, "OVERLAY", nil, 1)
	button.barBg:SetColorTexture(0, 0, 0, 0.55)
	button.barBg:SetSize(230, 4)
	button.barBg:SetPoint("TOPLEFT", button.detail, "BOTTOMLEFT", 0, -4)
	button.bar = button:CreateTexture(nil, "OVERLAY", nil, 2)
	button.bar:SetHeight(4)
	button.bar:SetPoint("TOPLEFT", button.barBg, "TOPLEFT", 0, 0)

	button:SetScript("OnClick", function(self)
		if self.key == selectedKey then return end
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
		component.Select(self.key)
	end)
	return button
end

local function AcquireStoryButton(index)
	if not storyButtons[index] then
		storyButtons[index] = CreateStoryButton(listScroll.child)
	end
	return storyButtons[index]
end

-- Detail rows ------------------------------------------------------------------------------

-- The overview's section header: the storyline's name on the parchment band.
local function CreateHeadingRow(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetHeight(HEADING_HEIGHT)
	row.band = row:CreateTexture(nil, "ARTWORK")
	row.band:SetTexture(EJ_TEXTURES)
	row.band:SetTexCoord(0.359375, 0.99609375, 0.8525390625, 0.880859375)
	row.band:SetAllPoints()
	row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.text:SetJustifyH("LEFT")
	row.text:SetWordWrap(false)
	row.text:SetPoint("LEFT", 8, -1)
	row.text:SetPoint("RIGHT", -8, -1)
	SetColor(row.text, HEADER_TEXT)
	return row
end

local function CreateQuestRow(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetHeight(QUEST_ROW_HEIGHT)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(14, 14)
	row.icon:SetPoint("TOPLEFT", 2, -3)
	row.text = row:CreateFontString(nil, "OVERLAY", "GameFontBlack")
	row.text:SetJustifyH("LEFT")
	row.text:SetWordWrap(false)
	row.text:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, 0)
	row.text:SetPoint("RIGHT", -8, 0)
	return row
end

-- Small ink, and inset under the quest, so the reason reads as belonging to it.
local function CreateSmallRow(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetHeight(REASON_ROW_HEIGHT)
	row.text = row:CreateFontString(nil, "OVERLAY", "GameFontBlackSmall")
	row.text:SetJustifyH("LEFT")
	row.text:SetWordWrap(false)
	row.text:SetPoint("TOPLEFT", 2, -1)
	row.text:SetPoint("RIGHT", -8, 0)
	return row
end

local ROW_FACTORY = { heading = CreateHeadingRow, quest = CreateQuestRow, small = CreateSmallRow }

local function AcquireDetailRow(kind)
	detailUsed = detailUsed + 1
	local entry = detailRows[detailUsed]
	if not entry or entry.kind ~= kind then
		entry = { kind = kind, frame = ROW_FACTORY[kind](detailScroll.child) }
		detailRows[detailUsed] = entry
	end
	entry.frame:Show()
	return entry.frame
end

-- Component --------------------------------------------------------------------------------

function component.Init(components_)
	components = components_
	-- Same page as the encounter view: sized and placed exactly as its info panel.
	local page = CreateFrame("Frame", EncounterJournal:GetName() .. "QuestChains", EncounterJournal)
	component.frame = page
	EncounterJournal.questChains = page
	page:SetSize(785, 425)
	page:SetPoint("BOTTOMRIGHT", EncounterJournal.inset, "BOTTOMRIGHT", -4, 2)

	page.bg = page:CreateTexture(nil, "BACKGROUND", nil, 1)
	page.bg:SetTexture("Interface/EncounterJournal/UI-EJ-JournalBG")
	page.bg:SetTexCoord(0, 0.766601562, 0, 0.830078125)
	page.bg:SetAllPoints()
	page.leftShadow = page:CreateTexture(nil, "BACKGROUND", nil, 3)
	page.leftShadow:SetTexture(EJ_TEXTURES)
	page.leftShadow:SetTexCoord(0, 0.755859375, 0.9599609375, 1)
	page.leftShadow:SetSize(386, 39)
	page.leftShadow:SetPoint("TOPLEFT", 0, -11)
	page.rightShadow = page:CreateTexture(nil, "BACKGROUND", nil, 3)
	page.rightShadow:SetTexture(EJ_TEXTURES)
	page.rightShadow:SetTexCoord(0.755859375, 0, 0.9599609375, 1)
	page.rightShadow:SetSize(386, 39)
	page.rightShadow:SetPoint("TOPRIGHT", 0, -11)

	-- The zone takes the instance's place in the header, in the same bronze. No icon:
	-- zones have no art of their own here, and a stand-in in the bordered frame was
	-- more conspicuous than nothing.
	page.title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	page.title:SetJustifyH("LEFT")
	page.title:SetWordWrap(false)
	page.title:SetSize(330, 16)
	page.title:SetPoint("TOPLEFT", 26, -20)
	SetColor(page.title, TITLE_COLOR)

	page.summary = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page.summary:SetJustifyH("RIGHT")
	page.summary:SetPoint("TOPRIGHT", -24, -22)
	SetColor(page.summary, TITLE_COLOR)

	-- Storylines, left, in the boss list's place.
	listScroll = CreateScroller(page, 345, 382, STORY_WIDTH, -6)
	listScroll:SetPoint("BOTTOMLEFT", 25, 1)

	selectedHighlight = CreateFrame("Frame", nil, listScroll.child)
	selectedHighlight:Hide()
	local selectedTexture = selectedHighlight:CreateTexture()
	selectedTexture:SetTexture(EJ_TEXTURES)
	selectedTexture:SetTexCoord(0.00195313, 0.63671875, 0.15820313, 0.21191406)
	selectedTexture:SetAllPoints()

	-- The selected storyline, right, in the overview's place. The quests sit on the
	-- same paper the overview puts under ability text: ink on the bare journal
	-- background is hard to read, and this is what the encounter view does about it.
	detailScroll = CreateScroller(page, 350, 383, DETAIL_WIDTH, -15)
	detailScroll:SetPoint("BOTTOMRIGHT", -5, 1)
	local child = detailScroll.child
	child.paper = child:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-AbilityTextBG")
	child.paper:SetDrawLayer("BACKGROUND", -3)
	child.paperBottom = child:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-AbilityTextBottomBorder")
	child.paperBottom:SetDrawLayer("BACKGROUND", -3)
	child.paperBottom:ClearAllPoints()
	child.paperBottom:SetPoint("LEFT", child.paper, "BOTTOMLEFT")
	child.paperBottom:SetPoint("RIGHT", child.paper, "BOTTOMRIGHT")

	page.empty = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	page.empty:SetPoint("CENTER", 0, 10)
	SetColor(page.empty, INK)
	page.empty:Hide()

	-- Follow the quest log, so a hand-in moves the quest to completed and unlocks
	-- whatever it gated without the tab being reopened.
	QuestLogService.RegisterListener(function()
		if page:IsShown() then component.Refresh() end
	end)
	PlayerContextService.RegisterListener(function(_, changed)
		if not page:IsShown() then return end
		if changed.level or changed.zone then component.Refresh() end
	end)

	page:Hide()
end

function component.Select(key)
	selectedKey = key
	component.Refresh()
end

--[[
The zone to show: the one the player is standing in when there is data for it,
otherwise whatever is already selected. Following the player is right far more often
than not.
]]
local function ResolveZone()
	local available = QuestChainService.GetZones()
	if #available == 0 then return nil end
	local here = PlayerContextService.GetZone()
	for _, zone in ipairs(available) do
		if zone.uiMapID == here then return here end
	end
	return currentZone or available[1].uiMapID
end

local function SelectedQuests(inLog)
	if selectedKey == SINGLES then
		return standalone, "Other quests", QuestChainService.Summarise(standalone, inLog)
	end
	local chain = chains[selectedKey]
	if chain then
		return chain, chain[1].name or "Storyline", QuestChainService.Summarise(chain, inLog)
	end
	return nil
end

local function RefreshList(inLog)
	for _, button in pairs(storyButtons) do button:Hide() end
	selectedHighlight:Hide()

	local offsetY, index = 10, 0
	local function AddEntry(key, name, summary)
		index = index + 1
		local button = AcquireStoryButton(index)
		button.key = key
		button.name:SetText(name)
		local band = LevelBand(summary)
		button.detail:SetText(("%s%s%d of %d"):format(
			band, band ~= "" and "  ·  " or "", summary.done, summary.total))

		local finished = summary.total > 0 and summary.done == summary.total
		local fraction = summary.total > 0 and (summary.done / summary.total) or 0
		button.bar:SetWidth(math.max(1, 230 * fraction))
		button.bar:SetShown(fraction > 0)
		if finished then
			button.bar:SetColorTexture(0.35, 0.70, 0.30)
		else
			button.bar:SetColorTexture(1, 0.82, 0)
		end
		button.done:SetShown(finished)

		-- The marker says where the story stands: done, underway, or waiting.
		local icon = STATUS_ICON.available
		if finished then
			icon = STATUS_ICON.completed
		elseif summary.active > 0 then
			icon = STATUS_ICON.active
		end
		button.status:SetTexture(icon)

		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", listScroll.child, "TOPLEFT", 0, -offsetY)
		button:Show()
		if key == selectedKey then
			selectedHighlight:SetParent(button)
			selectedHighlight:SetAllPoints(button)
			selectedHighlight:Show()
		end
		offsetY = offsetY + STORY_HEIGHT + STORY_SPACING
	end

	for chainIndex, chain in ipairs(chains) do
		AddEntry(chainIndex, chain[1].name or "Storyline",
			QuestChainService.Summarise(chain, inLog))
	end
	if #standalone > 0 then
		AddEntry(SINGLES, "Other quests", QuestChainService.Summarise(standalone, inLog))
	end

	listScroll.child:SetHeight(math.max(10, offsetY + 10))
end

local function RefreshDetail(inLog)
	for _, entry in pairs(detailRows) do entry.frame:Hide() end
	detailUsed = 0

	local child = detailScroll.child
	local quests, title, summary = SelectedQuests(inLog)
	if not quests then
		child.paper:Hide()
		child.paperBottom:Hide()
		child:SetHeight(10)
		return
	end

	local offsetY = 0
	local function Place(row, indent)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", detailScroll.child, "TOPLEFT", indent or 0, -offsetY)
		row:SetPoint("RIGHT", detailScroll.child, "RIGHT", 0, 0)
		offsetY = offsetY + row:GetHeight()
	end

	local heading = AcquireDetailRow("heading")
	heading.text:SetText(title)
	Place(heading)
	offsetY = offsetY + 8

	-- Everything from here down is on the paper.
	local paperTop = offsetY
	offsetY = offsetY + 8

	local band = LevelBand(summary)
	-- Only a real chain has a shape; the one-off quests are neither linear nor branching.
	local shape = summary.linear == false and "  ·  branches" or ""
	local sub = AcquireDetailRow("small")
	sub.text:SetText(("%s%s%d of %d complete%s"):format(
		band, band ~= "" and "  ·  " or "", summary.done, summary.total, shape))
	SetColor(sub.text, INK)
	Place(sub, 12)
	offsetY = offsetY + 6

	for _, quest in ipairs(quests) do
		local status, _, detail = QuestChainService.GetStatus(quest, inLog)
		local ink = STATUS_INK[status] or INK
		-- Indent by depth so a branch reads as a branch, only where it branches.
		local indent = 12 + (summary.linear and 0 or ((quest.depth or 0) * 12))

		local row = AcquireDetailRow("quest")
		local icon = STATUS_ICON[status]
		row.icon:SetShown(icon ~= nil)
		if icon then row.icon:SetTexture(icon) end
		local name = quest.name or ("Quest " .. tostring(quest.id))
		if quest.level then name = ("%s  (%d)"):format(name, quest.level) end
		row.text:SetText(name)
		SetColor(row.text, ink)
		Place(row, indent)

		-- The reason gets its own line. Appended to the name it was unreadable, and it
		-- is the one thing here that nothing else tells you.
		if detail then
			local reason = AcquireDetailRow("small")
			reason.text:SetText(detail)
			SetColor(reason.text, STATUS_INK.blocked)
			Place(reason, indent + 22)
		end
	end

	offsetY = offsetY + 8
	child.paper:ClearAllPoints()
	child.paper:SetPoint("TOPLEFT", child, "TOPLEFT", 2, -paperTop)
	child.paper:SetPoint("BOTTOMRIGHT", child, "TOPLEFT", DETAIL_WIDTH - 6, -offsetY)
	child.paper:Show()
	child.paperBottom:Show()

	child:SetHeight(math.max(10, offsetY + 14))
end

function component.Refresh()
	local page = component.frame
	local uiMapID = ResolveZone()
	if not uiMapID then
		page.title:SetText("Quests")
		page.summary:SetText("")
		page.empty:SetText("No quest data for this zone yet.")
		page.empty:Show()
		return
	end
	page.empty:Hide()

	if uiMapID ~= currentZone then
		currentZone = uiMapID
		selectedKey = 1
	end

	local zoneName
	if C_Map and C_Map.GetMapInfo then
		local info = C_Map.GetMapInfo(uiMapID)
		zoneName = info and info.name
	end
	page.title:SetText(zoneName or "Quests")

	chains, standalone = QuestChainService.GetChains(uiMapID)
	local inLog = QuestLogService.GetQuestLogState()

	local done, total = 0, 0
	for _, list in ipairs({ chains, { standalone } }) do
		for _, group in ipairs(list) do
			local summary = QuestChainService.Summarise(group, inLog)
			done = done + summary.done
			total = total + summary.total
		end
	end
	page.summary:SetText(("%d of %d quests complete"):format(done, total))

	if selectedKey == nil then selectedKey = 1 end
	RefreshList(inLog)
	RefreshDetail(inLog)

	-- Home > Elwynn Forest > A Threat Within, as the encounter view does for a boss.
	local _, storyTitle = SelectedQuests(inLog)
	local path = { { name = zoneName or "Quests", onClick = function() component.Select(1) end } }
	if storyTitle then table.insert(path, { name = storyTitle }) end
	components.NavBar.SetPath(path)
end

function component.Show()
	components.EncounterJournal.SetCurrentView(component.frame)
	components.NavBar.Reset()
	component.Refresh()
end

UI.Add(component)
