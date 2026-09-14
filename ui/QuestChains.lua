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
	-- A quest you cannot take yet has no quest-giver marker in the world, so there is
	-- no obvious icon for it. It still gets something: with the slot left empty, runs
	-- of blocked quests lost their left edge and read as one block of text.
	blocked   = "Interface/COMMON/Indicator-Gray",
}
local BLOCKED_ICON_ALPHA = 0.5

--[[
A flat colour behind each panel, rather than a texture.

InsetFrameTemplate brings a translucent background of its own, and over the journal
parchment that lands at a warm mid-brown -- white and gold text on mid-orange, which is
what made this page hard to read however the type was set. A texture cannot be relied
on here: whatever is behind it shows through.

So hide the template's background where the client gives us one, and paint a solid,
fully opaque colour inside the border instead. Near-black, biased warm so it belongs to
the journal rather than reading as a grey box dropped onto it.

Two details that matter. The fill sits high within BACKGROUND, above the template's own
background at sublevel 0 -- put it below and the translucent texture simply draws over
the top, which is the bug this replaces. And it need not be below the content: the rows
are child frames, and a child frame always draws above its parent's textures.
]]
local GROUND = { 0.09, 0.075, 0.06 }

local function AddDarkGround(inset)
	for _, key in ipairs({ "Bg", "bg", "InsetBg" }) do
		local texture = rawget(inset, key)
		if type(texture) == "table" and type(texture.Hide) == "function" then
			texture:Hide()
		end
	end
	local fill = inset:CreateTexture(nil, "BACKGROUND", nil, 7)
	fill:SetColorTexture(GROUND[1], GROUND[2], GROUND[3], 1)
	fill:SetPoint("TOPLEFT", 3, -3)
	fill:SetPoint("BOTTOMRIGHT", -3, 3)
	return fill
end

local RAIL_WIDTH = 232
local PANEL_PAD = 14
local SINGLES = "__singles__"

--[[
One rhythm for the whole page, stated once.

Every vertical gap on both sides comes from these, and every block measures itself from
them rather than carrying a height of its own. The heading used to be a hardcoded 54,
which is how it drifted out of step with the quest rows beneath it -- a block with a
literal height stops matching the moment anything around it changes.
]]
--[[
Progress is two textures, not one.

A single coloured line cannot say what it is a fraction of: at 12 of 12 it looked like a
short green dash that stopped before the edge of the panel, with nothing to say the dash
was the whole of it. The trough shows everything there is to do and the fill shows how
much is done, so the empty part is as visible as the full part.

UI-StatusBar is the plain gradient Blizzard fills its own bars with, tinted per use. The
outline behind the trough is what separates it from the panel it sits on -- without it
the dark trough simply disappeared into the dark ground.
]]
local STATUS_BAR = "Interface/TargetingFrame/UI-StatusBar"
local TROUGH_COLOR = { 0.26, 0.21, 0.16 }
local BAR_GOLD  = { 0.95, 0.75, 0.12 }
local BAR_GREEN = { 0.32, 0.70, 0.28 }

local GAP_TIGHT   = 3     -- a line and the line that explains it
local GAP_LOOSE   = 8     -- a block and the next thing along
local PAD_BOTTOM  = 9     -- last line of a row to its rule
local BAR_HEIGHT  = 6

local RAIL_ROW_HEIGHT = 47   -- tall enough to hold the bar clear of the level band
local ICON_SIZE = 14
local ICON_GAP = 6           -- icon to name, and so the left edge of the wrapped text

--[[
The page's margins. The right is wider than the left because the page frame itself
already sits 3px inside the journal inset on that side, and because the panel should
line up with the seam in the journal art rather than run past it.
]]
--[[
Creature names inside the objective sentence become links, so hovering "Marshal
McBride" or "Kobold Vermin" shows what they look like.

A FontString renders |H...|h escape sequences, and the frame around it raises
OnHyperlinkEnter for them once hyperlinks are switched on -- so the sentence stays one
wrapped paragraph and the names inside it are still individually hoverable. Both the
escape handling and the model viewer are feature-detected: where either is missing the
text is left plain rather than offering a link that does nothing.
]]
local LINK_PREFIX = "agcnpc"
local LINK_COLOR = "ffffd100"

local MARGIN_LEFT = 14
local MARGIN_RIGHT = 20
local MARGIN_BOTTOM = 10

local railScroll, panelScroll
local linksSupported
local railRows, panelRows = { }, { }
local panelUsed = 0
local chains, standalone, currentZone, selectedKey

-- Helpers ------------------------------------------------------------------------------

local function SetColor(fontString, color)
	fontString:SetTextColor(color[1], color[2], color[3])
end

-- Lua patterns treat most punctuation as syntax, and creature names carry plenty of it
-- -- "Hogger", "Ma Stonefield", "Sea Wolf MacKinley". Escape before matching.
local function EscapePattern(text)
	return (text:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"))
end

--[[
Wraps each creature's name in the sentence with a link to its model.

Done in two passes. Every name is first swapped for a placeholder, longest name first,
so a shorter creature can never be matched inside a longer one that shares its opening
words ("Kobold Vermin" inside "Kobold Vermin Leader"), nor inside the escape sequence of
a name already linked. The placeholders then expand to the real links.

Each name is linked once. A sentence that names the same creature twice reads better
with one link than with the same word lit up in two places.
]]
local function Linkify(text, quest)
	if not text or not linksSupported then return text end
	local npcs = QuestChainService.GetQuestNpcs(quest)
	if not npcs then return text end

	local slots = { }
	for _, npc in ipairs(npcs) do
		if npc.name and npc.name ~= "" and npc.display then
			local pattern = EscapePattern(npc.name)
			if text:find(pattern) then
				slots[#slots + 1] = npc
				text = text:gsub(pattern, ("\1%d\2"):format(#slots), 1)
			end
		end
	end
	for index, npc in ipairs(slots) do
		local link = ("|H%s:%d|h|c%s%s|r|h"):format(LINK_PREFIX, npc.id, LINK_COLOR, npc.name)
		text = text:gsub("\1" .. index .. "\2", (link:gsub("%%", "%%%%")), 1)
	end
	return text
end

--[[
The trough is anchored by the caller, left and right, so it spans whatever it is in.
Everything else hangs off it.
]]
local function CreateProgressBar(parent)
	local bar = { }
	bar.outline = parent:CreateTexture(nil, "BACKGROUND", nil, 3)
	bar.outline:SetColorTexture(0, 0, 0, 0.9)
	bar.trough = parent:CreateTexture(nil, "ARTWORK")
	bar.trough:SetTexture(STATUS_BAR)
	bar.trough:SetVertexColor(TROUGH_COLOR[1], TROUGH_COLOR[2], TROUGH_COLOR[3], 1)
	bar.trough:SetHeight(BAR_HEIGHT)
	bar.fill = parent:CreateTexture(nil, "OVERLAY")
	bar.fill:SetTexture(STATUS_BAR)
	bar.fill:SetHeight(BAR_HEIGHT)
	bar.outline:SetPoint("TOPLEFT", bar.trough, "TOPLEFT", -1, 1)
	bar.outline:SetPoint("BOTTOMRIGHT", bar.trough, "BOTTOMRIGHT", 1, -1)
	bar.fill:SetPoint("TOPLEFT", bar.trough, "TOPLEFT", 0, 0)
	return bar
end

--[[
How full the bar is. The width is passed rather than measured: the trough takes its size
from anchors that are not resolved until the frame is laid out, and this runs before
that -- the same trap that made the quest rows too short for their own text.
]]
local function SetProgress(bar, width, done, total)
	local fraction = (total and total > 0) and (done / total) or 0
	local finished = total and total > 0 and done >= total
	local color = finished and BAR_GREEN or BAR_GOLD
	bar.fill:SetVertexColor(color[1], color[2], color[3], 1)
	bar.fill:SetWidth(math.max(1, (width or 0) * fraction))
	bar.fill:SetShown(fraction > 0)
end

local function LevelBand(summary)
	if not summary.minLevel then return "" end
	if summary.maxLevel and summary.maxLevel ~= summary.minLevel then
		return ("Levels %d-%d"):format(summary.minLevel, summary.maxLevel)
	end
	return ("Level %d"):format(summary.minLevel)
end

--[[
The scroll bar hangs inside the scroll frame's right edge, and the content stops short
by enough to leave it a lane of its own. That is the pattern the rest of the addon uses
-- DynamicContentScroller is 350 wide with a 320 child, and the bar lives in the slack.

Getting this wrong is what put the bars in the middle of the panels: the scroll frames
were already inset from the panel edge and then scrollBarX pulled the bar a further 10
left of that, so it sat well short of the border with content underneath it. Run the
scroll frame out to the edge instead and take the lane out of the child.

Note what is NOT here: ScrollFrameTemplate_OnMouseWheel. That is the legacy Slider
handler and MinimalScrollBar has no GetValue, so adding it throws on every wheel tick.
ScrollFrame_OnLoad already wires the wheel to the bar it creates.
]]
local SCROLL_BAR_X = -13        -- the bar, relative to the scroll frame's right edge
local SCROLL_BAR_LANE = 22      -- how much narrower the content is, to clear it

local function ContentWidth(scroll)
	local width = scroll:GetWidth() or 0
	return math.max(10, width - SCROLL_BAR_LANE)
end

local function CreateScroller(parent, initialWidth)
	local scroll = CreateFrame("ScrollFrame", nil, parent)
	scroll.scrollBarX = SCROLL_BAR_X
	scroll.scrollBarTopY = -4
	scroll.scrollBarBottomY = 4
	scroll.scrollBarTemplate = "MinimalScrollBar"
	scroll.child = CreateFrame("Frame", nil, scroll)
	scroll.child:SetSize(initialWidth or 10, 10)
	scroll.child:SetPoint("TOPLEFT")
	scroll:SetScrollChild(scroll.child)
	if ScrollFrame_OnLoad then pcall(ScrollFrame_OnLoad, scroll) end
	-- The frame has no width until it is laid out, so the child takes its own then.
	scroll:SetScript("OnSizeChanged", function(self, width)
		if width and width > 0 then self.child:SetWidth(ContentWidth(self)) end
	end)
	return scroll
end

-- Storyline rail ---------------------------------------------------------------------------

--[[
One storyline in the rail: name, level band, how much is done, and a bar. The bar is
what makes the rail readable at a glance -- the counts alone all look alike.
]]
--[[
A storyline in the rail. Hover and selection are carried by a real bordered panel rather
than a wash of colour: the tint alone was doing two jobs badly, colouring the text it sat
behind while still not reading as a frame around the row.

The border is the tooltip edge -- the addon's own furniture, it scales to any row height
without stretching, and the gold on it is the gold the journal uses everywhere else.
Where the client has no backdrop support the row falls back to the tint, which is worse
but is never nothing.
]]
local function CreateRailRow(parent)
	local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
	row:SetHeight(RAIL_ROW_HEIGHT)

	row.hasBackdrop = type(row.SetBackdrop) == "function"
	if row.hasBackdrop then
		row:SetBackdrop({
			bgFile = "Interface/Buttons/WHITE8X8",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true, tileSize = 8, edgeSize = 12,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		})
	end

	row.highlight = row:CreateTexture(nil, "BACKGROUND")
	row.highlight:SetAllPoints()
	row.highlight:SetColorTexture(1, 0.82, 0, 0.07)
	row.highlight:Hide()
	row.selected = row:CreateTexture(nil, "BACKGROUND")
	row.selected:SetAllPoints()
	row.selected:SetColorTexture(1, 0.82, 0, 0.09)
	row.selected:Hide()

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

	row.progress = CreateProgressBar(row)
	row.progress.trough:SetPoint("BOTTOMLEFT", 10, GAP_LOOSE)
	row.progress.trough:SetPoint("BOTTOMRIGHT", -10, GAP_LOOSE)

	row:SetScript("OnEnter", function(self)
		self.hovered = true
		component.ApplyRowState(self)
	end)
	row:SetScript("OnLeave", function(self)
		self.hovered = false
		component.ApplyRowState(self)
	end)
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

	--[[
	Hyperlinks inside the wrapped sentence. The frame has to be told to raise the
	events and has to take mouse input for them to fire at all; without both, the
	names render coloured but nothing happens on hover.
	]]
	if linksSupported then
		row:EnableMouse(true)
		row:SetHyperlinksEnabled(true)
		row:SetScript("OnHyperlinkEnter", function(_, link)
			local npcID = tonumber(link:match("^" .. LINK_PREFIX .. ":(%d+)$"))
			local npc = npcID and QuestChainService.GetNpc(npcID)
			if npc then components.NpcPreview.Show(npc) end
		end)
		row:SetScript("OnHyperlinkLeave", function()
			components.NpcPreview.Hide()
		end)
		-- Leaving the row entirely does not always raise OnHyperlinkLeave, notably when
		-- the pointer jumps straight out of the panel.
		row:SetScript("OnLeave", function()
			components.NpcPreview.Hide()
		end)
	end

	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(ICON_SIZE, ICON_SIZE)
	row.icon:SetPoint("TOPLEFT", 0, -2)

	row.level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.level:SetJustifyH("RIGHT")
	row.level:SetPoint("TOPRIGHT", -4, -3)
	SetColor(row.level, META)

	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)
	row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", ICON_GAP, 1)
	row.name:SetPoint("RIGHT", row.level, "LEFT", -8, 0)

	--[[
	The sentence, which is most of the row's height.

	Its width is set explicitly on every draw rather than taken from a RIGHT anchor on
	the row. The row has no width until it is anchored, and the height has to be known
	before that -- so a freshly created row measured its sentence against a width of
	zero, reported a single line, and came out too short for two. That is what ran
	consecutive blocked quests together: their text is the longest on the page, because
	it carries the reason as well as the objective.
	]]
	row.says = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.says:SetJustifyH("LEFT")
	row.says:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -GAP_TIGHT)

	row.leads = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.leads:SetJustifyH("LEFT")
	row.leads:SetPoint("TOPLEFT", row.says, "BOTTOMLEFT", 0, -GAP_TIGHT)

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
	row.sub:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -GAP_TIGHT)
	SetColor(row.sub, META)

	-- Spans the panel: the storyline's progress is the headline figure on this page, so
	-- it gets the full width rather than a token 120px.
	row.progress = CreateProgressBar(row)
	row.progress.trough:SetPoint("TOPLEFT", row.sub, "BOTTOMLEFT", 0, -GAP_LOOSE)
	row.progress.trough:SetPoint("RIGHT", row, "RIGHT", -2, 0)

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

	--[[
	Links are only offered where they can actually do something: the client has to
	raise hyperlink events on a plain frame, and the preview has to be able to draw a
	model. Where either is missing the sentence stays plain text -- a coloured name
	that does nothing on hover is worse than no link at all.
	]]
	local probe = CreateFrame("Frame")
	linksSupported = type(probe.SetHyperlinksEnabled) == "function"
		and components.NpcPreview ~= nil
		and components.NpcPreview.IsSupported()

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
	railInset:SetPoint("TOPLEFT", MARGIN_LEFT, -44)
	railInset:SetPoint("BOTTOMLEFT", MARGIN_LEFT, MARGIN_BOTTOM)
	AddDarkGround(railInset)
	railScroll = CreateScroller(railInset, RAIL_WIDTH - 31)
	railScroll:SetPoint("TOPLEFT", 4, -5)
	railScroll:SetPoint("BOTTOMRIGHT", -5, 5)

	-- The briefing, right.
	local panelInset = CreateFrame("Frame", nil, page, "InsetFrameTemplate")
	panelInset:SetPoint("TOPLEFT", railInset, "TOPRIGHT", 8, 0)
	panelInset:SetPoint("BOTTOMRIGHT", -MARGIN_RIGHT, MARGIN_BOTTOM)
	AddDarkGround(panelInset)
	panelScroll = CreateScroller(panelInset)
	panelScroll:SetPoint("TOPLEFT", PANEL_PAD, -10)
	panelScroll:SetPoint("BOTTOMRIGHT", -6, 8)

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

	page:SetScript("OnHide", function()
		if components.NpcPreview then components.NpcPreview.Hide() end
	end)

	page:Hide()
end

--[[
Three states, one place: at rest, under the pointer, and chosen. Kept together because
they have to stay consistent -- a hovered row that is also the selected one must read as
selected, not as a brighter hover.
]]
function component.ApplyRowState(row)
	local selected, hovered = row.isSelected, row.hovered
	if row.hasBackdrop then
		if selected then
			row:SetBackdropColor(1, 0.82, 0, 0.10)
			row:SetBackdropBorderColor(1, 0.82, 0, 0.95)
		elseif hovered then
			row:SetBackdropColor(1, 0.82, 0, 0.05)
			row:SetBackdropBorderColor(0.72, 0.60, 0.34, 0.85)
		else
			row:SetBackdropColor(0, 0, 0, 0)
			row:SetBackdropBorderColor(0, 0, 0, 0)
		end
		row.highlight:Hide()
		row.selected:Hide()
	else
		row.selected:SetShown(selected)
		row.highlight:SetShown(hovered and not selected)
	end
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
		SetProgress(row.progress, railScroll.child:GetWidth() - 20,
			summary.done, summary.total)
		-- Finished stops shouting; the one you are on is picked out in quest gold.
		if finished then
			SetColor(row.name, GREEN)
		elseif summary.active > 0 then
			SetColor(row.name, GOLD)
		else
			SetColor(row.name, WHITE)
		end

		row.isSelected = key == selectedKey
		component.ApplyRowState(row)
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

	-- Re-take the width here as well as on resize: the first draw can land before the
	-- frame has ever been sized, and everything below wraps against it.
	local child = panelScroll.child
	if (panelScroll:GetWidth() or 0) > 0 then child:SetWidth(ContentWidth(panelScroll)) end

	local quests, title, summary = SelectedQuests(inLog)
	if not quests then
		child:SetHeight(10)
		return
	end

	-- The lane the wrapped text runs in: the row, less the icon and the gap after it.
	local textWidth = math.max(60, child:GetWidth() - ICON_SIZE - ICON_GAP - 2)

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
	SetProgress(heading.progress, child:GetWidth() - 2, summary.done, summary.total)
	-- Measured, like every quest row below it, so the two stay in step.
	Place(heading, 1 + math.max(16, heading.title:GetStringHeight())
		+ GAP_TIGHT + math.max(11, heading.sub:GetStringHeight())
		+ GAP_LOOSE + BAR_HEIGHT + PAD_BOTTOM)
	offsetY = offsetY + GAP_LOOSE

	for _, quest in ipairs(quests) do
		local status, _, detail = QuestChainService.GetStatus(quest, inLog)
		local blocked = status == "blocked"
		local row = AcquirePanelRow("quest")

		local icon = STATUS_ICON[status]
		row.icon:SetShown(icon ~= nil)
		if icon then
			row.icon:SetTexture(icon)
			row.icon:SetAlpha(blocked and BLOCKED_ICON_ALPHA or 1)
		end
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
		row.says:SetText(says and Linkify(says, quest) or "")
		SetColor(row.says, blocked and BODY_DIM or BODY)
		row.says:SetShown(says ~= nil)

		local leads = quest.unlocks and #quest.unlocks > 0
			and ("Leads to " .. table.concat(quest.unlocks, ", ")) or nil
		row.leads:SetText(leads or "")
		SetColor(row.leads, FAINT)
		row.leads:SetShown(leads ~= nil)

		-- Size the wrapped text before asking it how tall it is.
		row.says:SetWidth(textWidth)
		row.leads:SetWidth(textWidth)

		-- Measure rather than assume: the sentence wraps to one line or three depending
		-- on the quest and the panel's width, and a fixed row height would either clip
		-- the long ones or leave a gap under every short one.
		local height = 18
		if says then height = height + GAP_TIGHT + math.max(11, row.says:GetStringHeight()) end
		if leads then height = height + GAP_TIGHT + math.max(10, row.leads:GetStringHeight()) end
		Place(row, height + PAD_BOTTOM)
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
