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

UI.Add(component)
