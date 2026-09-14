--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
The Quests tab: a zone's quest chains, and where this character stands on each.

Presented as chains first and one-off quests after, because the chains are the part
worth reading. A flat alphabetical list of a zone's quests is what every other tool
already gives you, and it is exactly what makes long chains impossible to follow.

Each quest shows its status, and where it is blocked, WHY -- "after A Threat Within",
"requires level 22". Saying only that something is unavailable is no more use than
hiding it.

Built on a plain ScrollFrame, the pattern ui/DynamicContentScroller.lua already proves
on both clients. ScrollBox list views are the API that diverges between Era and BCC.
]]

local component = UI.CreateComponent("QuestChains")
local components

local ROW_HEIGHT = 18
local INDENT = 14
local MAX_ROWS = 250

local scrollFrame, rowPool
local currentZone

-- White for what you can do, grey for what you cannot, green for done. Active quests
-- take the quest-log yellow so they read as "you are on this".
local STATUS_COLOR = {
	completed = { 0.45, 0.68, 0.45 },
	active    = { 1.00, 0.82, 0.00 },
	available = { 1.00, 1.00, 1.00 },
	blocked   = { 0.55, 0.55, 0.55 },
}

local STATUS_MARK = {
	completed = "|cff73c373v|r",
	active    = "|cffffd100>|r",
	available = "|cffffffff+|r",
	blocked   = "|cff8a8a8a-|r",
}

local function AcquireRow(index)
	if not rowPool[index] then
		local row = CreateFrame("Frame", nil, scrollFrame.child)
		row:SetHeight(ROW_HEIGHT)
		row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.text:SetPoint("LEFT")
		row.text:SetPoint("RIGHT")
		row.text:SetJustifyH("LEFT")
		rowPool[index] = row
	end
	return rowPool[index]
end

local used = 0

local function AddRow(text, color, indent)
	used = used + 1
	local row = AcquireRow(used)
	row.text:SetText(text)
	if color then row.text:SetTextColor(color[1], color[2], color[3]) end
	row:ClearAllPoints()
	row:SetPoint("TOPLEFT", scrollFrame.child, "TOPLEFT", indent or 0, -((used - 1) * ROW_HEIGHT))
	row:SetPoint("RIGHT", scrollFrame.child, "RIGHT", 0, 0)
	row:Show()
	return row
end

local function FormatQuest(quest, inLog, showStep, stepIndex, stepTotal)
	local status, _, detail = QuestChainService.GetStatus(quest, inLog)
	local color = STATUS_COLOR[status] or STATUS_COLOR.available

	local label = quest.name or ("quest " .. tostring(quest.id))
	if quest.level then
		label = ("%s |cff9d9d9d(%d)|r"):format(label, quest.level)
	end
	if showStep then
		label = ("%s %d/%d  %s"):format(STATUS_MARK[status] or "", stepIndex, stepTotal, label)
	else
		label = ("%s %s"):format(STATUS_MARK[status] or "", label)
	end
	-- The reason is the whole point; it is never dropped for space.
	if detail then
		label = ("%s |cff8a8a8a- %s|r"):format(label, detail)
	end
	return label, color
end

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
	frame.title:SetText("Quests")

	frame.subtitle = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	frame.subtitle:SetJustifyH("RIGHT")
	frame.subtitle:SetPoint("TOPRIGHT", -20, -18)
	frame.subtitle:SetTextColor(0.65, 0.85, 1)

	local inset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	inset:SetPoint("TOPLEFT", 14, -46)
	inset:SetPoint("BOTTOMRIGHT", -14, 10)

	scrollFrame = CreateFrame("ScrollFrame", nil, inset)
	scrollFrame:SetPoint("TOPLEFT", 8, -8)
	scrollFrame:SetPoint("BOTTOMRIGHT", -26, 8)
	scrollFrame.scrollBarX = -14
	scrollFrame.scrollBarTopY = -6
	scrollFrame.scrollBarBottomY = 6
	scrollFrame.scrollBarTemplate = "MinimalScrollBar"
	scrollFrame.child = CreateFrame("Frame", nil, scrollFrame)
	scrollFrame.child:SetSize(700, 10)
	scrollFrame.child:SetPoint("TOPLEFT")
	scrollFrame:SetScrollChild(scrollFrame.child)
	if ScrollFrame_OnLoad then
		pcall(ScrollFrame_OnLoad, scrollFrame)
	end

	frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableLarge")
	frame.empty:SetPoint("CENTER", 0, 10)
	frame.empty:Hide()

	rowPool = { }

	-- Follow the quest log, so handing something in moves it to completed and unlocks
	-- whatever it gated without needing the tab reopened.
	QuestLogService.RegisterListener(function()
		if frame:IsShown() then component.Refresh() end
	end)
	PlayerContextService.RegisterListener(function(_, changed)
		if not frame:IsShown() then return end
		if changed.level or changed.zone then component.Refresh() end
	end)

	frame:Hide()
end

--[[
Picks the zone to show: the one the player is standing in when we have data for it,
otherwise the first we do have. Following the player is right far more often than not,
and saves a zone picker doing nothing useful while only one zone is generated.
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

function component.SetZone(uiMapID)
	currentZone = uiMapID
	component.Refresh()
end

function component.Refresh()
	for _, row in pairs(rowPool) do row:Hide() end
	used = 0

	local uiMapID = ResolveZone()
	if not uiMapID then
		component.frame.subtitle:SetText("")
		component.frame.empty:SetText("No quest data for this client yet.")
		component.frame.empty:Show()
		scrollFrame.child:SetHeight(10)
		return
	end
	component.frame.empty:Hide()
	currentZone = uiMapID

	local zoneName
	if C_Map and C_Map.GetMapInfo then
		local info = C_Map.GetMapInfo(uiMapID)
		zoneName = info and info.name
	end
	component.frame.title:SetText(zoneName or "Quests")

	local chains, standalone = QuestChainService.GetChains(uiMapID)
	local inLog = QuestLogService.GetQuestLogState()

	local done, total = 0, 0
	local function Count(quest)
		total = total + 1
		if QuestChainService.GetStatus(quest, inLog) == "completed" then done = done + 1 end
	end

	for _, chain in ipairs(chains) do
		if used >= MAX_ROWS then break end
		-- Only a straight-line chain has steps to number. A branching one says how many
		-- quests it holds and lets the nesting show the shape, rather than inventing an
		-- order that does not exist.
		AddRow(("|cffffd100%s|r  |cff9d9d9d%d %s|r"):format(
			chain[1].name or "Chain", #chain,
			chain.linear and "steps" or "quests, branching"), { 1, 0.82, 0 }, 0)
		for step, quest in ipairs(chain) do
			Count(quest)
			if used < MAX_ROWS then
				local label, color = FormatQuest(quest, inLog, chain.linear, step, #chain)
				AddRow(label, color, INDENT + (quest.depth or 0) * 10)
			end
		end
		AddRow(" ", nil, 0)
	end

	if #standalone > 0 and used < MAX_ROWS then
		AddRow("|cffffd100Single quests|r", { 1, 0.82, 0 }, 0)
		for _, quest in ipairs(standalone) do
			Count(quest)
			if used < MAX_ROWS then
				local label, color = FormatQuest(quest, inLog, false)
				AddRow(label, color, INDENT)
			end
		end
	end

	component.frame.subtitle:SetText(("%d of %d completed"):format(done, total))
	scrollFrame.child:SetHeight(math.max(10, used * ROW_HEIGHT))
end

function component.Show()
	component.Refresh()
	components.EncounterJournal.SetCurrentView(component.frame)
	components.NavBar.Reset()
end

UI.Add(component)
