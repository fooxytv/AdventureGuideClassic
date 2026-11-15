--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("DynamicContentScroller")

local components
local showing

function component.Init(components_)
	components = components_
	local scrollFrameWrapper = CreateFrame("Frame", nil, EncounterJournal.encounter.info)
	scrollFrameWrapper:SetSize(350, 383)
	scrollFrameWrapper:SetPoint("BOTTOMRIGHT", -5, 1)
	local scrollFrame = CreateFrame("ScrollFrame", nil, scrollFrameWrapper)
	component.frame = scrollFrameWrapper
	scrollFrame:SetSize(350, 383)
	scrollFrame.scrollBarX = -15
	scrollFrame.scrollBarTopY = -6
	scrollFrame.scrollBarBottomY = 6
	scrollFrame:SetPoint("BOTTOMRIGHT")
	scrollFrame.scrollBarTemplate = "MinimalScrollBar"
	scrollFrame.child = Widgets.AcquireRoot(scrollFrame)
	scrollFrame.child:SetPoint("TOPLEFT")
	scrollFrame.child:SetSize(320, 100)
	scrollFrame:SetScrollChild(scrollFrame.child)
	ScrollFrame_OnLoad(scrollFrame)
	scrollFrameWrapper:Hide()
	scrollFrameWrapper:SetScript("OnHide", function()
		scrollFrame.child.widgetType:Release(scrollFrame.child)
		scrollFrame.child = Widgets.AcquireRoot(scrollFrame)
		scrollFrame.child:SetPoint("TOPLEFT")
		scrollFrame.child:SetSize(320, 100)
		scrollFrame:SetScrollChild(scrollFrame.child)
	end)
	component.scrollFrame = scrollFrame
end

function component.ShowOverview()
	showing = component.ShowOverview
	components.EncounterFrame.SetCurrentView(component.frame)
	component.scrollFrame.child:SetContents(AdventureGuideNavigationService.GetEncounterContent())
end

function component.ShowAbilities()
	showing = component.ShowAbilities
	components.EncounterFrame.SetCurrentView(component.frame)
	component.scrollFrame.child:SetContents(AdventureGuideNavigationService.GetEncounterAbilities())
end

--[[
	A spell the client had not cached draws without its description, and the data
	arrives later. Redraw once when it does, rather than per spell: a boss asks for
	several at once and they land one event each.
]]
local spellDataFrame = CreateFrame("Frame")
local redrawQueued = false
spellDataFrame:SetScript("OnEvent", function()
	if redrawQueued or not showing then return end
	if not (component.frame and component.frame:IsShown()) then return end
	redrawQueued = true
	C_Timer.After(0, function()
		redrawQueued = false
		if showing and component.frame and component.frame:IsShown() then
			showing()
		end
	end)
end)
Compat.RegisterEvents(spellDataFrame, "SPELL_DATA_LOAD_RESULT")

--[[
	/run AGC_TextDump() while overview text shows as one "..." line. An instrument, not
	a fix: it prints what each widget's box resolved to, so the clipped one shows itself.
]]
local function Size(region)
	local top, bottom = region:GetTop(), region:GetBottom()
	local box = (top and bottom) and string.format("%.0f", top - bottom) or "unresolved"
	return string.format("h=%.0f box=%s w=%.0f", region:GetHeight(), box, region:GetWidth())
end

local function Points(region)
	local names = { }
	for i = 1, region:GetNumPoints() do
		local point, _, relativePoint = region:GetPoint(i)
		table.insert(names, point .. ">" .. relativePoint)
	end
	return table.concat(names, " ")
end

local function DumpWidget(widget, depth)
	local pad = string.rep("  ", depth)
	local name = widget.widgetType and widget.widgetType.name or "?"
	print(string.format("%s%s #%s %s [%s]", pad, name, tostring(widget.idx), Size(widget), Points(widget)))
	if widget.text then
		local text = widget.text
		print(string.format("%s  text %s string=%.0f truncated=%s lines=%s [%s] %q", pad, Size(text),
			text:GetStringHeight(), tostring(text.IsTruncated and text:IsTruncated()),
			tostring(text.GetNumLines and text:GetNumLines()), Points(text),
			(text:GetText() or ""):sub(1, 24)))
	end
	for _, child in ipairs(widget.widgets or { }) do
		DumpWidget(child, depth + 1)
	end
end

_G.AGC_TextDump = function()
	local scrollFrame = component.scrollFrame
	if not scrollFrame then return end
	local encounter = AdventureGuideNavigationService.GetEncounter()
	print("|cffff9900[AGC]|r TextDump: " .. tostring(encounter and encounter.name)
		.. ", shown=" .. tostring(component.frame:IsShown()))
	DumpWidget(scrollFrame.child, 0)
end

UI.Add(component)
