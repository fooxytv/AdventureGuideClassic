--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
The Quests tab: a zone's storylines, and what each quest actually asks of you.

A zone's quests are not a list, they are a handful of stories. Elwynn has the defence
of Northshire, the trouble at the Fargodeep Mine, Marshal Dughan's problem with the
Riverpaw. Each is a chain. The tab presents those stories, in the order you would meet
them, and for every quest in one says three things a quest name alone cannot:

    what it asks of you   "Bring 12 Red Burlap Bandanas to Deputy Willem outside the
                           Northshire Abbey" -- shipped in data/Quests/
    what it opens up      "Leads to Wolves Across the Border" -- free, the prerequisite
                           edges read the other way round
    why you cannot yet    "after Kobold Camp Cleanup", "requires level 9"

Earlier versions showed quest names and little else, and no amount of restyling fixed
that: a name is a label, not information. The layout is storylines on the left, the
chosen one opened on the right, both on dark inset panels rather than the journal
parchment -- light text on a dark ground is what the quest log itself does, and it is
what finally made this readable at the size the page actually is.

Colours follow the quest log too: gold for a quest in your log, white for one you can
take, green for done, grey for one you cannot reach yet, and the body text a step down
from white so the names still lead.

Built on plain ScrollFrames, the pattern ui/DynamicContentScroller.lua already proves
on both clients. ScrollBox list views are the API that diverges between Era and BCC.
]]

local component = UI.CreateComponent("QuestChains")
local components

local EJ_TEXTURES = "Interface/EncounterJournal/UI-EncounterJournalTextures"

-- The quest log's own palette, which is what a player already reads quests in.
local GOLD      = { 1.00, 0.82, 0.00 }
local WHITE     = { 1.00, 1.00, 1.00 }
local GREEN     = { 0.25, 0.75, 0.25 }
local GREY      = { 0.55, 0.53, 0.50 }
local BODY      = { 0.82, 0.78, 0.72 }   -- the objective sentence: a step below white
local BODY_DIM  = { 0.58, 0.55, 0.51 }   -- the same, for a quest out of reach
local FAINT     = { 0.68, 0.60, 0.44 }   -- "leads to"
local META      = { 0.72, 0.66, 0.58 }   -- level bands, counts, level numbers
local TITLE     = { 0.902, 0.788, 0.671 }-- the journal's own bronze, for the zone

local STATUS_COLOR = {
	completed = GREEN, active = GOLD, available = WHITE, blocked = GREY,
}

-- Textures rather than glyphs: a tick and a quest marker read instantly.
local STATUS_ICON = {
	completed = "Interface/RaidFrame/ReadyCheck-Ready",
	active    = "Interface/GossipFrame/ActiveQuestIcon",
	available = "Interface/GossipFrame/AvailableQuestIcon",
	blocked   = nil,
}

--[[
InsetFrameTemplate is translucent, and over the journal parchment it lands at a warm
mid-brown -- which is what made white and gold text hard to read no matter how the type
was set. Lay a near-black fill inside each inset so the panels are actually dark, and
the quest log's colours do what they do in the quest log.

The fill is a texture on the inset itself, so it draws above the page's parchment (a
child frame always does) and below the inset's own border art.
]]
local function AddDarkGround(inset)
	local fill = inset:CreateTexture(nil, "BACKGROUND", nil, -6)
	fill:SetColorTexture(0.043, 0.035, 0.027, 0.92)
	fill:SetPoint("TOPLEFT", 3, -3)
	fill:SetPoint("BOTTOMRIGHT", -3, 3)
	return fill
end

local RAIL_WIDTH = 232
local RAIL_ROW_HEIGHT = 42
local PANEL_PAD = 14
local SINGLES = "__singles__"

local railScroll, panelScroll
local railRows, panelRows = { }, { }
local panelUsed = 0
local chains, standalone, currentZone, selectedKey

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

-- The plain-ScrollFrame recipe from DynamicContentScroller, in one place. Note what is
-- NOT here: ScrollFrameTemplate_OnMouseWheel. That is the legacy Slider handler and
-- MinimalScrollBar has no GetValue, so adding it throws on every wheel tick.
-- ScrollFrame_OnLoad already wires the wheel to the bar it creates.
local function CreateScroller(parent, childWidth)
	local scroll = CreateFrame("ScrollFrame", nil, parent)
	scroll.scrollBarX = -10
	scroll.scrollBarTopY = -4
	scroll.scrollBarBottomY = 4
	scroll.scrollBarTemplate = "MinimalScrollBar"
	scroll.child = CreateFrame("Frame", nil, scroll)
	scroll.child:SetSize(childWidth, 10)
	scroll.child:SetPoint("TOPLEFT")
	scroll:SetScrollChild(scroll.child)
	if ScrollFrame_OnLoad then pcall(ScrollFrame_OnLoad, scroll) end
	return scroll
end

-- Storyline rail ---------------------------------------------------------------------------

--[[
One storyline in the rail: name, level band, how much is done, and a bar. The bar is
what makes the rail readable at a glance -- the counts alone all look alike.
]]
local function CreateRailRow(parent)
	local row = CreateFrame("Button", nil, parent)
	row:SetHeight(RAIL_ROW_HEIGHT)

	row.highlight = row:CreateTexture(nil, "BACKGROUND")
	row.highlight:SetAllPoints()
	row.highlight:SetColorTexture(1, 0.82, 0, 0.07)
	row.highlight:Hide()
	row.selected = row:CreateTexture(nil, "BACKGROUND")
	row.selected:SetAllPoints()
	row.selected:SetColorTexture(1, 0.82, 0, 0.09)
	row.selected:Hide()
	-- A bright edge on the selected row, so the choice is legible without a border.
	row.edge = row:CreateTexture(nil, "ARTWORK")
	row.edge:SetColorTexture(1, 0.82, 0, 0.85)
	row.edge:SetWidth(2)
	row.edge:SetPoint("TOPLEFT")
	row.edge:SetPoint("BOTTOMLEFT")
	row.edge:Hide()

	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)
	row.name:SetPoint("TOPLEFT", 9, -6)
	row.name:SetPoint("RIGHT", -8, 0)

	row.detail = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.detail:SetJustifyH("LEFT")
	row.detail:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -3)
	SetColor(row.detail, META)

	row.count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.count:SetJustifyH("RIGHT")
	row.count:SetPoint("RIGHT", -9, 0)
	row.count:SetPoint("TOP", row.detail, "TOP", 0, 0)
	SetColor(row.count, META)

	row.barBg = row:CreateTexture(nil, "ARTWORK")
	row.barBg:SetColorTexture(0, 0, 0, 0.55)
	row.barBg:SetHeight(3)
	row.barBg:SetPoint("BOTTOMLEFT", 9, 6)
	row.barBg:SetPoint("BOTTOMRIGHT", -9, 6)
	row.bar = row:CreateTexture(nil, "OVERLAY")
	row.bar:SetHeight(3)
	row.bar:SetPoint("TOPLEFT", row.barBg, "TOPLEFT", 0, 0)

	row:SetScript("OnEnter", function(self) self.highlight:Show() end)
	row:SetScript("OnLeave", function(self) self.highlight:Hide() end)
	row:SetScript("OnClick", function(self)
		if self.key == selectedKey then return end
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
		component.Select(self.key)
	end)
	return row
end

local function AcquireRailRow(index)
	if not railRows[index] then
		railRows[index] = CreateRailRow(railScroll.child)
	end
	return railRows[index]
end

-- Briefing rows ------------------------------------------------------------------------------

--[[
One quest, briefed: the marker and name on the first line with the level to the right,
then what it asks of you, then what it leads to. Every part below the name is optional,
so the row measures itself once the text is set.
]]
local function CreateQuestRow(parent)
	local row = CreateFrame("Frame", nil, parent)

	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(14, 14)
	row.icon:SetPoint("TOPLEFT", 0, -2)

	row.level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.level:SetJustifyH("RIGHT")
	row.level:SetPoint("TOPRIGHT", -4, -3)
	SetColor(row.level, META)

	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)
	row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, 1)
	row.name:SetPoint("RIGHT", row.level, "LEFT", -8, 0)

	-- The sentence. Wraps, and is what the row's height is mostly made of.
	row.says = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.says:SetJustifyH("LEFT")
	row.says:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -3)
	row.says:SetPoint("RIGHT", -2, 0)

	row.leads = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.leads:SetJustifyH("LEFT")
	row.leads:SetPoint("TOPLEFT", row.says, "BOTTOMLEFT", 0, -2)
	row.leads:SetPoint("RIGHT", -2, 0)

	row.rule = row:CreateTexture(nil, "ARTWORK")
	row.rule:SetColorTexture(1, 1, 1, 0.07)
	row.rule:SetHeight(1)
	row.rule:SetPoint("BOTTOMLEFT", 0, 0)
	row.rule:SetPoint("BOTTOMRIGHT", 0, 0)
	return row
end

-- The storyline's own heading, at the top of the briefing.
local function CreateHeadingRow(parent)
	local row = CreateFrame("Frame", nil, parent)

	row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	row.title:SetJustifyH("LEFT")
	row.title:SetWordWrap(false)
	row.title:SetPoint("TOPLEFT", 0, -1)
	row.title:SetPoint("RIGHT", 0, 0)

	row.sub = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.sub:SetJustifyH("LEFT")
	row.sub:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -5)
	SetColor(row.sub, META)

	row.barBg = row:CreateTexture(nil, "ARTWORK")
	row.barBg:SetColorTexture(0, 0, 0, 0.55)
	row.barBg:SetHeight(3)
	row.barBg:SetPoint("TOPLEFT", row.sub, "BOTTOMLEFT", 0, -5)
	row.barBg:SetWidth(120)
	row.bar = row:CreateTexture(nil, "OVERLAY")
	row.bar:SetHeight(3)
	row.bar:SetPoint("TOPLEFT", row.barBg, "TOPLEFT", 0, 0)

	row.rule = row:CreateTexture(nil, "ARTWORK")
	row.rule:SetColorTexture(1, 0.82, 0, 0.22)
	row.rule:SetHeight(1)
	row.rule:SetPoint("BOTTOMLEFT", 0, 0)
	row.rule:SetPoint("BOTTOMRIGHT", 0, 0)
	return row
end

local ROW_FACTORY = { heading = CreateHeadingRow, quest = CreateQuestRow }

local function AcquirePanelRow(kind)
	panelUsed = panelUsed + 1
	local entry = panelRows[panelUsed]
	if not entry or entry.kind ~= kind then
		entry = { kind = kind, frame = ROW_FACTORY[kind](panelScroll.child) }
		panelRows[panelUsed] = entry
	end
	entry.frame:Show()
	return entry.frame
end

-- Component --------------------------------------------------------------------------------

function component.Init(components_)
	components = components_
	local page = CreateFrame("Frame", EncounterJournal:GetName() .. "QuestChains", EncounterJournal)
	component.frame = page
	EncounterJournal.questChains = page
	page:SetPoint("TOPLEFT", EncounterJournal.inset, 0, -2)
	page:SetPoint("BOTTOMRIGHT", EncounterJournal.inset, -3, 0)

	-- The journal parchment stays as the page: it is the Adventure Guide's look, and the
	-- two dark panels sit on it the way the boss list and overview sit on the encounter
	-- page. The text lives on the panels, not on the parchment.
	page.bg = page:CreateTexture(nil, "BACKGROUND")
	page.bg:SetTexture("Interface/EncounterJournal/UI-EJ-Classic")
	page.bg:SetAllPoints()
	page.bg:SetPoint("TOPLEFT", 3, -1)

	page.title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	page.title:SetJustifyH("LEFT")
	page.title:SetWordWrap(false)
	page.title:SetPoint("TOPLEFT", 20, -16)
	SetColor(page.title, TITLE)

	page.summary = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	page.summary:SetJustifyH("RIGHT")
	page.summary:SetPoint("TOPRIGHT", -20, -18)
	SetColor(page.summary, TITLE)

	-- Storylines, left.
	local railInset = CreateFrame("Frame", nil, page, "InsetFrameTemplate")
	railInset:SetWidth(RAIL_WIDTH)
	railInset:SetPoint("TOPLEFT", 14, -44)
	railInset:SetPoint("BOTTOMLEFT", 14, 10)
	AddDarkGround(railInset)
	railScroll = CreateScroller(railInset, RAIL_WIDTH - 26)
	railScroll:SetPoint("TOPLEFT", 4, -5)
	railScroll:SetPoint("BOTTOMRIGHT", -20, 5)

	-- The briefing, right.
	local panelInset = CreateFrame("Frame", nil, page, "InsetFrameTemplate")
	panelInset:SetPoint("TOPLEFT", railInset, "TOPRIGHT", 8, 0)
	panelInset:SetPoint("BOTTOMRIGHT", -14, 10)
	AddDarkGround(panelInset)
	panelScroll = CreateScroller(panelInset, 10)
	panelScroll:SetPoint("TOPLEFT", PANEL_PAD, -10)
	-- Wide enough on the right that the scroll bar gets its own lane: the level numbers
	-- were being drawn underneath it.
	panelScroll:SetPoint("BOTTOMRIGHT", -28, 8)
	-- The child has to be told its width before anything wraps against it, and the inset
	-- has no size until the frame is laid out, so take it on the first draw instead.
	panelScroll:SetScript("OnSizeChanged", function(self, width)
		if width and width > 0 then self.child:SetWidth(width) end
	end)

	page.empty = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	page.empty:SetPoint("CENTER", 0, 10)
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

--[[
Which storyline opens first in a fresh zone: the one you are in the middle of, else the
first. Landing on a storyline you have already finished would be the least useful
choice available.
]]
local function DefaultSelection(inLog)
	for index, chain in ipairs(chains) do
		if QuestChainService.Summarise(chain, inLog).active > 0 then return index end
	end
	for index, chain in ipairs(chains) do
		local summary = QuestChainService.Summarise(chain, inLog)
		if summary.done < summary.total then return index end
	end
	return chains[1] and 1 or SINGLES
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

local function RefreshRail(inLog)
	for _, row in pairs(railRows) do row:Hide() end

	local offsetY, index = 2, 0
	local function AddEntry(key, name, summary)
		index = index + 1
		local row = AcquireRailRow(index)
		row.key = key
		row.name:SetText(name)
		row.detail:SetText(LevelBand(summary))
		row.count:SetText(("%d/%d"):format(summary.done, summary.total))

		local finished = summary.total > 0 and summary.done == summary.total
		local fraction = summary.total > 0 and (summary.done / summary.total) or 0
		row.bar:SetWidth(math.max(1, (RAIL_WIDTH - 44) * fraction))
		row.bar:SetShown(fraction > 0)
		row.bar:SetColorTexture(finished and 0.25 or 1, finished and 0.75 or 0.82,
			finished and 0.25 or 0, 1)
		-- Finished stops shouting; the one you are on is picked out in quest gold.
		if finished then
			SetColor(row.name, GREEN)
		elseif summary.active > 0 then
			SetColor(row.name, GOLD)
		else
			SetColor(row.name, WHITE)
		end

		row.selected:SetShown(key == selectedKey)
		row.edge:SetShown(key == selectedKey)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", railScroll.child, "TOPLEFT", 0, -offsetY)
		row:SetPoint("RIGHT", railScroll.child, "RIGHT", 0, 0)
		row:Show()
		offsetY = offsetY + RAIL_ROW_HEIGHT
	end

	for chainIndex, chain in ipairs(chains) do
		AddEntry(chainIndex, chain[1].name or "Storyline",
			QuestChainService.Summarise(chain, inLog))
	end
	if #standalone > 0 then
		AddEntry(SINGLES, "Other quests", QuestChainService.Summarise(standalone, inLog))
	end

	railScroll.child:SetHeight(math.max(10, offsetY + 2))
end

local function RefreshPanel(inLog)
	for _, entry in pairs(panelRows) do entry.frame:Hide() end
	panelUsed = 0

	local child = panelScroll.child
	local width = panelScroll:GetWidth()
	if width and width > 0 then child:SetWidth(width) end
	width = child:GetWidth()

	local quests, title, summary = SelectedQuests(inLog)
	if not quests then
		child:SetHeight(10)
		return
	end

	local offsetY = 0
	local function Place(row, height)
		row:SetHeight(height)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -offsetY)
		row:SetPoint("RIGHT", child, "RIGHT", 0, 0)
		offsetY = offsetY + height
	end

	local heading = AcquirePanelRow("heading")
	heading.title:SetText(title)
	SetColor(heading.title, TITLE)
	local band = LevelBand(summary)
	local shape = summary.linear == false and "  |  branches" or ""
	heading.sub:SetText(("%s%s%d of %d complete%s"):format(
		band, band ~= "" and "  |  " or "", summary.done, summary.total, shape))
	local hFraction = summary.total > 0 and (summary.done / summary.total) or 0
	local hDone = summary.total > 0 and summary.done == summary.total
	heading.bar:SetWidth(math.max(1, 120 * hFraction))
	heading.bar:SetShown(hFraction > 0)
	heading.bar:SetColorTexture(hDone and 0.25 or 1, hDone and 0.75 or 0.82, hDone and 0.25 or 0, 1)
	Place(heading, 54)
	offsetY = offsetY + 8

	for _, quest in ipairs(quests) do
		local status, _, detail = QuestChainService.GetStatus(quest, inLog)
		local blocked = status == "blocked"
		local row = AcquirePanelRow("quest")

		local icon = STATUS_ICON[status]
		row.icon:SetShown(icon ~= nil)
		if icon then row.icon:SetTexture(icon) end
		row.name:SetText(quest.name or ("Quest " .. tostring(quest.id)))
		SetColor(row.name, STATUS_COLOR[status] or WHITE)
		row.level:SetText(quest.level and quest.level > 0 and tostring(quest.level) or "")

		--[[
		The sentence, or the reason there isn't one to act on yet. A blocked quest leads
		with why it is blocked, because that is the thing the player needs; the sentence
		still follows, so they can see whether it is worth unblocking.
		]]
		local says = quest.text
		if blocked and detail then
			says = says and (detail .. "  --  " .. says) or detail
		end
		row.says:SetText(says or "")
		SetColor(row.says, blocked and BODY_DIM or BODY)
		row.says:SetShown(says ~= nil)

		local leads = quest.unlocks and #quest.unlocks > 0
			and ("Leads to " .. table.concat(quest.unlocks, ", ")) or nil
		row.leads:SetText(leads or "")
		SetColor(row.leads, FAINT)
		row.leads:SetShown(leads ~= nil)

		-- Measure rather than assume: the sentence wraps to one line or three depending
		-- on the quest and the panel's width, and a fixed row height would either clip
		-- the long ones or leave a gap under every short one.
		local height = 18
		if says then height = height + math.max(11, row.says:GetStringHeight()) + 3 end
		if leads then height = height + math.max(10, row.leads:GetStringHeight()) + 2 end
		Place(row, height + 9)
	end

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
		selectedKey = DefaultSelection(inLog)
	end
	if selectedKey == nil then selectedKey = DefaultSelection(inLog) end

	local done, total = 0, 0
	for _, list in ipairs({ chains, { standalone } }) do
		for _, group in ipairs(list) do
			local summary = QuestChainService.Summarise(group, inLog)
			done = done + summary.done
			total = total + summary.total
		end
	end
	page.summary:SetText(("%d of %d quests complete"):format(done, total))

	RefreshRail(inLog)
	RefreshPanel(inLog)

	-- Home > Elwynn Forest > A Threat Within, as the encounter view does for a boss.
	local _, storyTitle = SelectedQuests(inLog)
	local path = { { name = zoneName or "Quests" } }
	if storyTitle then table.insert(path, { name = storyTitle }) end
	components.NavBar.SetPath(path)
end

function component.Show()
	components.EncounterJournal.SetCurrentView(component.frame)
	components.NavBar.Reset()
	component.Refresh()
end

UI.Add(component)
