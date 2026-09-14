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

Drawn as the encounter overview is drawn, because that IS the addon's look: the journal
parchment behind everything, and on it one page of collapsible sections, each with the
overview's own paper-header art. A section is a storyline. Its header carries the name,
the level band, the count and a progress bar, so the page reads as a list of stories
and how far you are through each even with everything closed; opening one lays its
quests out on the overview's paper in quest-log ink, the reason a quest is blocked in a
column of its own on the right.

Earlier versions split the page into a list and a detail panel, first as inset panels
and then as the boss list beside the overview. Neither read well: the boss buttons
were the wrong shape for stories, and a detail column 320 wide cramped the text into
something hard to read. One wide page fixes both.

Built on a plain ScrollFrame, the pattern ui/DynamicContentScroller.lua already proves
on both clients. ScrollBox list views are the API that diverges between Era and BCC.
]]

local component = UI.CreateComponent("QuestChains")
local components

local EJ_TEXTURES = "Interface/EncounterJournal/UI-EncounterJournalTextures"

-- The encounter view's own palette, so this reads as the same journal.
local TITLE_COLOR = { 0.902, 0.788, 0.671 }   -- instance title over the parchment
local HEADER_TEXT = { 0.929, 0.788, 0.620 }   -- overview section headers
local INK = { 0.25, 0.1484375, 0.02 }         -- overview body text

-- Quest names are ink on paper, so status is shown as darker inks rather than the
-- quest log's bright colours, which vanish against parchment.
local STATUS_INK = {
	completed = { 0.16, 0.42, 0.14 },
	active    = { 0.60, 0.36, 0.02 },
	available = INK,
	blocked   = { 0.42, 0.36, 0.30 },
}

-- Textures rather than glyphs: a tick and a quest marker read instantly, where "v"
-- and ">" have to be decoded.
local STATUS_ICON = {
	completed = "Interface/RaidFrame/ReadyCheck-Ready",
	active    = "Interface/GossipFrame/ActiveQuestIcon",
	available = "Interface/GossipFrame/AvailableQuestIcon",
	blocked   = nil,
}

local PAGE_WIDTH = 710
local HEADER_HEIGHT = 34
local QUEST_ROW_HEIGHT = 22
local SECTION_GAP = 8
local PAPER_INSET = 6

local SINGLES = "__singles__"

local scroll
local rows, papers = { }, { }
local rowsUsed, papersUsed = 0, 0
local chains, standalone, currentZone
local expanded = { }      -- key -> true
local lastOpened          -- the storyline the nav bar names

-- Helpers ------------------------------------------------------------------------------

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

-- Section headers ---------------------------------------------------------------------------

--[[
A storyline's header: the overview's collapsible section header, with the paper-header
art and the +/- the player already knows from boss abilities. Taller than the
overview's, to carry the progress bar; the bar is what makes the closed page useful.
]]
local function CreateHeaderRow(parent)
	local row = CreateFrame("Button", nil, parent)
	row:SetHeight(HEADER_HEIGHT)

	-- Expanded art (e*) and collapsed art (c*), swapped as the section opens and closes,
	-- exactly as CollapsibleSectionWidgetTypeMixin does.
	row.eLeft = row:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-PaperHeader-SelectUp-Left")
	row.eLeft:ClearAllPoints()
	row.eLeft:SetPoint("LEFT", -1, 0)
	row.eRight = row:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-PaperHeader-SelectUp-Right")
	row.eRight:ClearAllPoints()
	row.eRight:SetPoint("RIGHT", 2, 0)
	row.eMid = row:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-PaperHeader-SelectUp-Mid")
	row.eMid:SetDrawLayer("BACKGROUND", -2)
	row.eMid:ClearAllPoints()
	row.eMid:SetPoint("LEFT", row.eLeft, "RIGHT", -32, 0)
	row.eMid:SetPoint("RIGHT", row.eRight, "LEFT", 32, 0)

	row.cLeft = row:CreateTexture(nil, "BACKGROUND")
	row.cLeft:SetTexture(EJ_TEXTURES)
	row.cLeft:SetSize(64, 29)
	row.cLeft:SetTexCoord(0.84960938, 0.97460938, 0.49023438, 0.51855469)
	row.cLeft:SetPoint("LEFT", -1, 0)
	row.cRight = row:CreateTexture(nil, "BACKGROUND")
	row.cRight:SetTexture(EJ_TEXTURES)
	row.cRight:SetSize(64, 29)
	row.cRight:SetTexCoord(0.72656250, 0.85156250, 0.52441406, 0.55273438)
	row.cRight:SetPoint("RIGHT", 2, 0)
	row.cMid = row:CreateTexture(nil, "BACKGROUND")
	row.cMid:SetTexture(EJ_TEXTURES .. "_Tile", "REPEAT", "REPEAT")
	row.cMid:SetSize(64, 29)
	row.cMid:SetTexCoord(0.0, 1.0, 0.34375000, 0.40039063)
	row.cMid:SetHorizTile(true)
	row.cMid:SetDrawLayer("BACKGROUND", -2)
	row.cMid:SetPoint("LEFT", row.cLeft, "RIGHT", -32, 0)
	row.cMid:SetPoint("RIGHT", row.cRight, "LEFT", 32, 0)

	local hLeft = row:CreateTexture(nil, "HIGHLIGHT")
	hLeft:SetTexture(EJ_TEXTURES)
	hLeft:SetTexCoord(0.74218750, 0.86718750, 0.15820313, 0.18652344)
	hLeft:SetSize(64, 29)
	hLeft:SetPoint("LEFT", -1, 0)
	local hRight = row:CreateTexture(nil, "HIGHLIGHT")
	hRight:SetTexture(EJ_TEXTURES)
	hRight:SetTexCoord(0.87109375, 0.99609375, 0.15820313, 0.18652344)
	hRight:SetSize(64, 29)
	hRight:SetPoint("RIGHT", 2, 0)
	local hMid = row:CreateTexture(nil, "HIGHLIGHT")
	hMid:SetTexture(EJ_TEXTURES .. "_Tile")
	hMid:SetTexCoord(0.00000000, 1.00000000, 0.46484375, 0.52148438)
	hMid:SetSize(64, 29)
	hMid:SetPoint("LEFT", hLeft, "RIGHT", -32, 0)
	hMid:SetPoint("RIGHT", hRight, "LEFT", 32, 0)

	row.toggle = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	row.toggle:SetSize(12, 12)
	row.toggle:SetPoint("LEFT", 8, 3)
	SetColor(row.toggle, HEADER_TEXT)

	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)
	row.name:SetPoint("TOPLEFT", 26, -7)
	SetColor(row.name, HEADER_TEXT)

	row.count = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	row.count:SetJustifyH("RIGHT")
	row.count:SetPoint("TOPRIGHT", -12, -8)
	SetColor(row.count, HEADER_TEXT)
	row.name:SetPoint("RIGHT", row.count, "LEFT", -12, 0)

	row.barBg = row:CreateTexture(nil, "ARTWORK")
	row.barBg:SetColorTexture(0, 0, 0, 0.45)
	row.barBg:SetHeight(4)
	row.barBg:SetPoint("BOTTOMLEFT", 26, 6)
	row.barBg:SetPoint("BOTTOMRIGHT", -12, 6)
	row.bar = row:CreateTexture(nil, "OVERLAY")
	row.bar:SetHeight(4)
	row.bar:SetPoint("TOPLEFT", row.barBg, "TOPLEFT", 0, 0)

	row:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		component.Toggle(self.key)
	end)
	return row
end

local function SetHeaderExpanded(row, isExpanded)
	row.toggle:SetText(isExpanded and "-" or "+")
	row.eLeft:SetShown(isExpanded)
	row.eMid:SetShown(isExpanded)
	row.eRight:SetShown(isExpanded)
	row.cLeft:SetShown(not isExpanded)
	row.cMid:SetShown(not isExpanded)
	row.cRight:SetShown(not isExpanded)
end

-- Quest rows ------------------------------------------------------------------------------

--[[
One quest on the paper. Quest-log ink for the name -- the size the quest log itself
uses, which is what "readable" means to a player -- and the reason it is blocked in a
column of its own on the right, so the names line up and the reasons line up.
]]
local function CreateQuestRow(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetHeight(QUEST_ROW_HEIGHT)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(14, 14)
	row.icon:SetPoint("LEFT", 0, 0)
	row.reason = row:CreateFontString(nil, "OVERLAY", "GameFontBlack")
	row.reason:SetJustifyH("RIGHT")
	row.reason:SetWordWrap(false)
	row.reason:SetPoint("RIGHT", -16, 0)
	SetColor(row.reason, STATUS_INK.blocked)
	row.name = row:CreateFontString(nil, "OVERLAY", "QuestFont")
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)
	row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
	row.name:SetPoint("RIGHT", row.reason, "LEFT", -12, 0)
	return row
end

local ROW_FACTORY = { header = CreateHeaderRow, quest = CreateQuestRow }

local function AcquireRow(kind)
	rowsUsed = rowsUsed + 1
	local entry = rows[rowsUsed]
	if not entry or entry.kind ~= kind then
		entry = { kind = kind, frame = ROW_FACTORY[kind](scroll.child) }
		rows[rowsUsed] = entry
	end
	entry.frame:Show()
	return entry.frame
end

-- The overview's paper, one sheet per open storyline.
local function AcquirePaper()
	papersUsed = papersUsed + 1
	local paper = papers[papersUsed]
	if not paper then
		local child = scroll.child
		paper = child:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-AbilityTextBG")
		paper:SetDrawLayer("BACKGROUND", -3)
		paper.bottom = child:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-AbilityTextBottomBorder")
		paper.bottom:SetDrawLayer("BACKGROUND", -3)
		paper.bottom:ClearAllPoints()
		paper.bottom:SetPoint("LEFT", paper, "BOTTOMLEFT")
		paper.bottom:SetPoint("RIGHT", paper, "BOTTOMRIGHT")
		papers[papersUsed] = paper
	end
	paper:Show()
	paper.bottom:Show()
	return paper
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

	-- The zone takes the instance's place in the header, in the same bronze.
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

	-- One page, the width of the boss list and the overview together.
	scroll = CreateFrame("ScrollFrame", nil, page)
	scroll:SetSize(740, 372)
	scroll:SetPoint("BOTTOMLEFT", 25, 1)
	scroll.scrollBarX = -15
	scroll.scrollBarTopY = -6
	scroll.scrollBarBottomY = 6
	scroll.scrollBarTemplate = "MinimalScrollBar"
	scroll.child = CreateFrame("Frame", nil, scroll)
	scroll.child:SetSize(PAGE_WIDTH, 10)
	scroll.child:SetPoint("TOPLEFT")
	scroll:SetScrollChild(scroll.child)
	-- ScrollFrame_OnLoad also wires the mouse wheel to the bar it creates. Do not
	-- add ScrollFrameTemplate_OnMouseWheel on top: that is the legacy Slider handler,
	-- and MinimalScrollBar is not a Slider -- it has no GetValue, so the wheel throws.
	if ScrollFrame_OnLoad then pcall(ScrollFrame_OnLoad, scroll) end

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

function component.Toggle(key)
	if expanded[key] then
		expanded[key] = nil
		if lastOpened == key then lastOpened = nil end
	else
		expanded[key] = true
		lastOpened = key
	end
	component.Refresh()
end

function component.CollapseAll()
	expanded = { }
	lastOpened = nil
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

--[[
What opens by itself on a fresh zone: the storyline you are in the middle of, or
failing that the first. A page with everything closed says nothing; a page with
everything open is the wall of names this design exists to avoid.
]]
local function DefaultExpansion(inLog)
	expanded = { }
	lastOpened = nil
	for index, chain in ipairs(chains) do
		if QuestChainService.Summarise(chain, inLog).active > 0 then
			expanded[index] = true
			lastOpened = index
			return
		end
	end
	if chains[1] then
		expanded[1] = true
		lastOpened = 1
	end
end

local function StoryName(key)
	if key == SINGLES then return "Other quests" end
	local chain = chains[key]
	return chain and (chain[1].name or "Storyline") or nil
end

local function RefreshPage(inLog)
	for _, entry in pairs(rows) do entry.frame:Hide() end
	for _, paper in pairs(papers) do paper:Hide() paper.bottom:Hide() end
	rowsUsed, papersUsed = 0, 0
	local child = scroll.child

	local offsetY = 6
	local function AddSection(key, quests)
		local summary = QuestChainService.Summarise(quests, inLog)
		local isOpen = expanded[key] and true or false

		local header = AcquireRow("header")
		header.key = key
		header.name:SetText(StoryName(key))
		local band = LevelBand(summary)
		header.count:SetText(("%s%s%d of %d"):format(
			band, band ~= "" and "  ·  " or "", summary.done, summary.total))
		local finished = summary.total > 0 and summary.done == summary.total
		local fraction = summary.total > 0 and (summary.done / summary.total) or 0
		header.bar:SetWidth(math.max(1, (PAGE_WIDTH - 38) * fraction))
		header.bar:SetShown(fraction > 0)
		if finished then
			header.bar:SetColorTexture(0.35, 0.70, 0.30)
		else
			header.bar:SetColorTexture(1, 0.82, 0)
		end
		SetHeaderExpanded(header, isOpen)
		header:ClearAllPoints()
		header:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -offsetY)
		header:SetPoint("RIGHT", child, "RIGHT", 0, 0)
		offsetY = offsetY + HEADER_HEIGHT

		if isOpen then
			local paper = AcquirePaper()
			local paperTop = offsetY
			offsetY = offsetY + 8
			for _, quest in ipairs(quests) do
				local status, _, detail = QuestChainService.GetStatus(quest, inLog)
				local row = AcquireRow("quest")
				local icon = STATUS_ICON[status]
				row.icon:SetShown(icon ~= nil)
				if icon then row.icon:SetTexture(icon) end
				local name = quest.name or ("Quest " .. tostring(quest.id))
				if quest.level then name = ("%s  (%d)"):format(name, quest.level) end
				row.name:SetText(name)
				SetColor(row.name, STATUS_INK[status] or INK)
				row.reason:SetText(detail or "")
				-- Indent by depth so a branch reads as a branch, only where it branches.
				local indent = 22 + (summary.linear and 0 or ((quest.depth or 0) * 14))
				row:ClearAllPoints()
				row:SetPoint("TOPLEFT", child, "TOPLEFT", indent, -offsetY)
				row:SetPoint("RIGHT", child, "RIGHT", 0, 0)
				offsetY = offsetY + QUEST_ROW_HEIGHT
			end
			offsetY = offsetY + 6
			paper:ClearAllPoints()
			paper:SetPoint("TOPLEFT", child, "TOPLEFT", PAPER_INSET, -paperTop)
			paper:SetPoint("BOTTOMRIGHT", child, "TOPLEFT", PAGE_WIDTH - PAPER_INSET, -offsetY)
			offsetY = offsetY + 4
		end
		offsetY = offsetY + SECTION_GAP
	end

	for index, chain in ipairs(chains) do AddSection(index, chain) end
	if #standalone > 0 then AddSection(SINGLES, standalone) end

	child:SetHeight(math.max(10, offsetY + 6))
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

	local zoneName
	if C_Map and C_Map.GetMapInfo then
		local info = C_Map.GetMapInfo(uiMapID)
		zoneName = info and info.name
	end
	page.title:SetText(zoneName or "Quests")

	chains, standalone = QuestChainService.GetChains(uiMapID)
	local inLog = QuestLogService.GetQuestLogState()

	if uiMapID ~= currentZone then
		currentZone = uiMapID
		DefaultExpansion(inLog)
	end

	local done, total = 0, 0
	for _, list in ipairs({ chains, { standalone } }) do
		for _, group in ipairs(list) do
			local summary = QuestChainService.Summarise(group, inLog)
			done = done + summary.done
			total = total + summary.total
		end
	end
	page.summary:SetText(("%d of %d quests complete"):format(done, total))

	RefreshPage(inLog)

	-- Home > Elwynn Forest > A Threat Within: the storyline most recently opened.
	local path = { { name = zoneName or "Quests", onClick = component.CollapseAll } }
	local storyName = lastOpened and expanded[lastOpened] and StoryName(lastOpened)
	if storyName then table.insert(path, { name = storyName }) end
	components.NavBar.SetPath(path)
end

function component.Show()
	components.EncounterJournal.SetCurrentView(component.frame)
	components.NavBar.Reset()
	component.Refresh()
end

UI.Add(component)
