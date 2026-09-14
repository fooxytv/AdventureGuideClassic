--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
The Quests tab: a zone's storylines, and where this character stands in each.

What this shows the player, stated plainly, because the first version did not have an
answer: a zone's quests are not a list, they are a handful of stories. Elwynn has the
defence of Northshire, the trouble at the Fargodeep Mine, Marshal Dughan's problem
with the Riverpaw. Each is a chain of quests. The tab presents those stories, in the
order you would meet them, showing how far through each you are and -- where you
cannot continue -- why.

Laid out as list-then-detail, the same shape as Dungeons: storylines down the left,
the selected one opened out on the right. The previous version rendered the whole
graph as one indented block, which showed the data faithfully and was unreadable. A
storyline at a time is the unit a player actually thinks in.

Built on plain ScrollFrames, the pattern ui/DynamicContentScroller.lua already proves
on both clients. ScrollBox list views are the API that diverges between Era and BCC.
]]

local component = UI.CreateComponent("QuestChains")
local components

local LIST_WIDTH = 216
local LIST_ROW_HEIGHT = 40
local QUEST_ROW_HEIGHT = 22
local REASON_ROW_HEIGHT = 16

local listScroll, detailScroll
local listRows, detailRows
local chains, standalone, currentZone, selectedIndex

-- Green for done, quest-log gold for in progress, white for takeable, grey for not.
local STATUS_COLOR = {
	completed = { 0.42, 0.70, 0.42 },
	active    = { 1.00, 0.82, 0.00 },
	available = { 1.00, 1.00, 1.00 },
	blocked   = { 0.52, 0.52, 0.52 },
}

-- Textures rather than glyphs: a tick and a quest marker read instantly, where "v"
-- and ">" have to be decoded.
local STATUS_ICON = {
	completed = "Interface/RaidFrame/ReadyCheck-Ready",
	active    = "Interface/GossipFrame/ActiveQuestIcon",
	available = "Interface/GossipFrame/AvailableQuestIcon",
	blocked   = nil,
}

local SINGLES = "__singles__"

-- Storyline list ------------------------------------------------------------------

local function CreateListRow(parent, index)
	local row = CreateFrame("Button", nil, parent)
	row:SetHeight(LIST_ROW_HEIGHT)

	row.highlight = row:CreateTexture(nil, "BACKGROUND")
	row.highlight:SetAllPoints()
	row.highlight:SetColorTexture(1, 0.82, 0, 0.10)
	row.highlight:Hide()

	row.selected = row:CreateTexture(nil, "BACKGROUND")
	row.selected:SetAllPoints()
	row.selected:SetColorTexture(1, 0.82, 0, 0.18)
	row.selected:Hide()

	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.name:SetPoint("TOPLEFT", 8, -6)
	row.name:SetPoint("RIGHT", -8, 0)
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)

	row.detail = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.detail:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
	row.detail:SetJustifyH("LEFT")

	-- A bar rather than a number alone: progress across a zone is glanced at, not read.
	row.barBg = row:CreateTexture(nil, "ARTWORK")
	row.barBg:SetColorTexture(0, 0, 0, 0.45)
	row.barBg:SetHeight(3)
	row.barBg:SetPoint("BOTTOMLEFT", 8, 5)
	row.barBg:SetPoint("BOTTOMRIGHT", -8, 5)

	row.bar = row:CreateTexture(nil, "OVERLAY")
	row.bar:SetColorTexture(0.25, 0.55, 0.85)
	row.bar:SetHeight(3)
	row.bar:SetPoint("BOTTOMLEFT", row.barBg, "BOTTOMLEFT", 0, 0)

	row:SetScript("OnEnter", function(self) self.highlight:Show() end)
	row:SetScript("OnLeave", function(self) self.highlight:Hide() end)
	row:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
		component.Select(self.key)
	end)
	return row
end

local function AcquireListRow(index)
	if not listRows[index] then
		listRows[index] = CreateListRow(listScroll.child, index)
	end
	return listRows[index]
end

-- Quest detail ---------------------------------------------------------------------

local function CreateQuestRow(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetHeight(QUEST_ROW_HEIGHT)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(14, 14)
	row.icon:SetPoint("TOPLEFT", 0, -3)
	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, 1)
	row.name:SetJustifyH("LEFT")
	row.level = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.level:SetPoint("LEFT", row.name, "RIGHT", 6, 0)
	row.level:SetJustifyH("LEFT")
	return row
end

local function CreateReasonRow(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetHeight(REASON_ROW_HEIGHT)
	row.text = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.text:SetPoint("TOPLEFT", 20, -1)
	row.text:SetPoint("RIGHT", -8, 0)
	row.text:SetJustifyH("LEFT")
	return row
end

local detailUsed = 0

local function AcquireDetailRow(kind)
	detailUsed = detailUsed + 1
	local entry = detailRows[detailUsed]
	if not entry or entry.kind ~= kind then
		local frame = (kind == "quest")
			and CreateQuestRow(detailScroll.child)
			or CreateReasonRow(detailScroll.child)
		entry = { kind = kind, frame = frame }
		detailRows[detailUsed] = entry
	end
	entry.frame:Show()
	return entry.frame
end

-- Component --------------------------------------------------------------------------

function component.Init(components_)
	components = components_
	local frame = CreateFrame("Frame", EncounterJournal:GetName() .. "QuestChains", EncounterJournal)
	component.frame = frame
	EncounterJournal.questChains = frame
	frame:SetPoint("TOPLEFT", EncounterJournal.inset, 0, -2)
	frame:SetPoint("BOTTOMRIGHT", EncounterJournal.inset, -3, 0)

	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetTexture("Interface/EncounterJournal/UI-EJ-Classic")
	frame.bg:SetAllPoints()
	frame.bg:SetPoint("TOPLEFT", 3, -1)

	frame.title = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge2")
	frame.title:SetJustifyH("LEFT")
	frame.title:SetPoint("TOPLEFT", 20, -15)

	frame.summary = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	frame.summary:SetJustifyH("RIGHT")
	frame.summary:SetPoint("TOPRIGHT", -20, -18)
	frame.summary:SetTextColor(0.65, 0.85, 1)

	-- Storylines, left.
	local listInset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	listInset:SetWidth(LIST_WIDTH)
	listInset:SetPoint("TOPLEFT", 14, -46)
	listInset:SetPoint("BOTTOMLEFT", 14, 10)

	listScroll = CreateFrame("ScrollFrame", nil, listInset)
	listScroll:SetPoint("TOPLEFT", 6, -6)
	listScroll:SetPoint("BOTTOMRIGHT", -24, 6)
	listScroll.scrollBarX = -12
	listScroll.scrollBarTopY = -6
	listScroll.scrollBarBottomY = 6
	listScroll.scrollBarTemplate = "MinimalScrollBar"
	listScroll.child = CreateFrame("Frame", nil, listScroll)
	listScroll.child:SetSize(LIST_WIDTH - 34, 10)
	listScroll.child:SetPoint("TOPLEFT")
	listScroll:SetScrollChild(listScroll.child)
	if ScrollFrame_OnLoad then pcall(ScrollFrame_OnLoad, listScroll) end

	-- The selected storyline, right.
	local detailInset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	detailInset:SetPoint("TOPLEFT", listInset, "TOPRIGHT", 8, 0)
	detailInset:SetPoint("BOTTOMRIGHT", -14, 10)

	frame.detailTitle = detailInset:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.detailTitle:SetTextScale(0.9)
	frame.detailTitle:SetPoint("TOPLEFT", 14, -12)
	frame.detailTitle:SetPoint("RIGHT", -14, 0)
	frame.detailTitle:SetJustifyH("LEFT")
	frame.detailTitle:SetWordWrap(false)

	frame.detailSub = detailInset:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	frame.detailSub:SetPoint("TOPLEFT", frame.detailTitle, "BOTTOMLEFT", 0, -4)
	frame.detailSub:SetJustifyH("LEFT")

	detailScroll = CreateFrame("ScrollFrame", nil, detailInset)
	detailScroll:SetPoint("TOPLEFT", 14, -52)
	detailScroll:SetPoint("BOTTOMRIGHT", -26, 8)
	detailScroll.scrollBarX = -12
	detailScroll.scrollBarTopY = -6
	detailScroll.scrollBarBottomY = 6
	detailScroll.scrollBarTemplate = "MinimalScrollBar"
	detailScroll.child = CreateFrame("Frame", nil, detailScroll)
	detailScroll.child:SetSize(440, 10)
	detailScroll.child:SetPoint("TOPLEFT")
	detailScroll:SetScrollChild(detailScroll.child)
	if ScrollFrame_OnLoad then pcall(ScrollFrame_OnLoad, detailScroll) end

	frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableLarge")
	frame.empty:SetPoint("CENTER", 0, 10)
	frame.empty:Hide()

	listRows, detailRows = { }, { }

	-- Follow the quest log, so a hand-in moves the quest to completed and unlocks
	-- whatever it gated without the tab being reopened.
	QuestLogService.RegisterListener(function()
		if frame:IsShown() then component.Refresh() end
	end)
	PlayerContextService.RegisterListener(function(_, changed)
		if not frame:IsShown() then return end
		if changed.level or changed.zone then component.Refresh() end
	end)

	frame:Hide()
end

function component.Select(key)
	selectedIndex = key
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

local function LevelBand(summary)
	if not summary.minLevel then return "" end
	if summary.maxLevel and summary.maxLevel ~= summary.minLevel then
		return ("Levels %d-%d"):format(summary.minLevel, summary.maxLevel)
	end
	return ("Level %d"):format(summary.minLevel)
end

local function RefreshList(inLog)
	for _, row in pairs(listRows) do row:Hide() end

	local offsetY, index = 0, 0
	local function AddEntry(key, name, summary)
		index = index + 1
		local row = AcquireListRow(index)
		row.key = key
		row.name:SetText(name)
		local band = LevelBand(summary)
		row.detail:SetText(("%s%s%d of %d"):format(
			band, band ~= "" and "  ·  " or "", summary.done, summary.total))
		local fraction = summary.total > 0 and (summary.done / summary.total) or 0
		local width = math.max(1, (LIST_WIDTH - 50) * fraction)
		row.bar:SetWidth(width)
		row.bar:SetShown(fraction > 0)
		-- A finished storyline stops shouting; one in progress is picked out.
		if summary.done == summary.total then
			row.name:SetTextColor(0.42, 0.70, 0.42)
		elseif summary.active > 0 then
			row.name:SetTextColor(1, 0.82, 0)
		else
			row.name:SetTextColor(1, 1, 1)
		end
		row.selected:SetShown(key == selectedIndex)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", listScroll.child, "TOPLEFT", 0, -offsetY)
		row:SetPoint("RIGHT", listScroll.child, "RIGHT", 0, 0)
		row:Show()
		offsetY = offsetY + LIST_ROW_HEIGHT
	end

	for chainIndex, chain in ipairs(chains) do
		AddEntry(chainIndex, chain[1].name or "Storyline",
			QuestChainService.Summarise(chain, inLog))
	end
	if #standalone > 0 then
		AddEntry(SINGLES, "Other quests", QuestChainService.Summarise(standalone, inLog))
	end

	listScroll.child:SetHeight(math.max(10, offsetY))
end

local function RefreshDetail(inLog)
	for _, entry in pairs(detailRows) do entry.frame:Hide() end
	detailUsed = 0

	local quests, title, summary
	if selectedIndex == SINGLES then
		quests, title = standalone, "Other quests"
		summary = QuestChainService.Summarise(standalone, inLog)
	elseif chains[selectedIndex] then
		local chain = chains[selectedIndex]
		quests, title = chain, chain[1].name or "Storyline"
		summary = QuestChainService.Summarise(chain, inLog)
	end

	if not quests then
		component.frame.detailTitle:SetText("")
		component.frame.detailSub:SetText("")
		detailScroll.child:SetHeight(10)
		return
	end

	component.frame.detailTitle:SetText(title)
	local band = LevelBand(summary)
	local shape = summary.linear and "" or "  ·  branches"
	component.frame.detailSub:SetText(("%s%s%d of %d complete%s"):format(
		band, band ~= "" and "  ·  " or "", summary.done, summary.total, shape))

	local offsetY = 0
	for _, quest in ipairs(quests) do
		local status, _, detail = QuestChainService.GetStatus(quest, inLog)
		local color = STATUS_COLOR[status] or STATUS_COLOR.available

		local row = AcquireDetailRow("quest")
		local icon = STATUS_ICON[status]
		row.icon:SetShown(icon ~= nil)
		if icon then row.icon:SetTexture(icon) end
		row.name:SetText(quest.name or ("Quest " .. tostring(quest.id)))
		row.name:SetTextColor(color[1], color[2], color[3])
		row.level:SetText(quest.level and ("(" .. quest.level .. ")") or "")
		-- Indent by depth so a branch reads as a branch, only where it branches.
		local indent = summary.linear and 0 or ((quest.depth or 0) * 12)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", detailScroll.child, "TOPLEFT", indent, -offsetY)
		row:SetPoint("RIGHT", detailScroll.child, "RIGHT", 0, 0)
		offsetY = offsetY + QUEST_ROW_HEIGHT

		-- The reason gets its own line. Appended to the name it was unreadable, and it
		-- is the one thing here that nothing else tells you.
		if detail then
			local reason = AcquireDetailRow("reason")
			reason.text:SetText(detail)
			reason:ClearAllPoints()
			reason:SetPoint("TOPLEFT", detailScroll.child, "TOPLEFT", indent, -offsetY)
			reason:SetPoint("RIGHT", detailScroll.child, "RIGHT", 0, 0)
			offsetY = offsetY + REASON_ROW_HEIGHT
		end
	end

	detailScroll.child:SetHeight(math.max(10, offsetY))
end

function component.Refresh()
	local uiMapID = ResolveZone()
	if not uiMapID then
		component.frame.title:SetText("Quests")
		component.frame.summary:SetText("")
		component.frame.empty:SetText("No quest data for this zone yet.")
		component.frame.empty:Show()
		return
	end
	component.frame.empty:Hide()

	if uiMapID ~= currentZone then
		currentZone = uiMapID
		selectedIndex = 1
	end

	local zoneName
	if C_Map and C_Map.GetMapInfo then
		local info = C_Map.GetMapInfo(uiMapID)
		zoneName = info and info.name
	end
	component.frame.title:SetText(zoneName or "Quests")

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
	component.frame.summary:SetText(("%d of %d quests complete"):format(done, total))

	if selectedIndex == nil then selectedIndex = 1 end
	RefreshList(inLog)
	RefreshDetail(inLog)
end

function component.Show()
	component.Refresh()
	components.EncounterJournal.SetCurrentView(component.frame)
	components.NavBar.Reset()
end

UI.Add(component)
