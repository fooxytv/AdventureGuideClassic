--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("EncounterJournalTabs")

local components
local tabs = { }
local tabNameFormat = "%s_%sTab"
local tabDisabledTextureFormat = "%s_%sTab%sDisabled"

-- Only the Era and TBC template has disabled-state artwork, and only it exposes globals.
local function HideDisabledTextures(name)
    for _, side in ipairs({ "Left", "Middle", "Right" }) do
        local texture = _G[string.format(tabDisabledTextureFormat, addonName, name, side)]
        if texture then texture:Hide() end
    end
end

local function AddTab(name, label, onclickFunc)
    local tabIdx = #tabs + 1
    local tab = CreateFrame("Button", string.format(tabNameFormat, addonName, name),
            EncounterJournal, Compat.TabButtonTemplate)
    -- PanelTemplates_Tab_OnClick selects by the button's id, so it has to have one.
    tab:SetID(tabIdx)
    tab:SetText(label)
-- Era and TBC overlap tabs by 16 so the wide edge art meets. PanelTemplates_AnchorTabs puts
-- each mainline tab 3pt right of the previous TOPRIGHT, so that overlap stacks them.
-- Blizzard's camelot XML still carries the -16, but InspectFrame re-anchors on load.
    if (tabIdx == 1) then
        tab:SetPoint("TOPLEFT", EncounterJournal, "BOTTOMLEFT", 16, 2)
    elseif Compat.isForever then
        tab:SetPoint("TOPLEFT", tabs[tabIdx - 1], "TOPRIGHT", 3, 0)
    else
        tab:SetPoint("LEFT", tabs[tabIdx - 1], "RIGHT", -16, 0)
    end
-- The Era and TBC template's OnShow and OnEvent belong to CharacterFrame. The mainline
-- template's are its layout: PanelTabButtonMixin resizes on show and DISPLAY_SIZE_CHANGED,
-- and clearing them strands every tab at its 36pt minimum, narrower than its own artwork.
    if not Compat.isForever then
        tab:SetScript("OnEvent", nil)
        tab:SetScript("OnShow", nil)
    end
    tab:SetScript("OnClick", function()
        tab.onclickFunc()
        PanelTemplates_Tab_OnClick(tab, EncounterJournal)
        PanelTemplates_SetTab(EncounterJournal, tabIdx)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end)
    HideDisabledTextures(name)
    tabs[tabIdx] = tab
    PanelTemplates_TabResize(tab, 0, nil, 36, 300);
    EncounterJournal.numTabs = #tabs
    _G.EncounterJournalTabs = tabs
    tab.onclickFunc = onclickFunc
    tab:Show()
    return tab
end

function component.GetTab(idx)
    return tabs[idx]
end

function component.Init(components_)
    components = components_
    EncounterJournal.Tabs = tabs

-- PanelTabButtonMixin reads its sizing off the frame the tabs belong to, so these numbers
-- have to live here too or a resize on show would undo them. Unread on Era and TBC.
    EncounterJournal.tabPadding = 0
    EncounterJournal.minTabWidth = 36
    EncounterJournal.maxTabWidth = 300
    EncounterJournal.dungeonsTab = AddTab("Dungeon", "Dungeons", function()
        AdventureGuideNavigationService.Reset()
        AdventureGuideNavigationService.SetInstances(InstanceService.GetDungeons())
        components.InstanceSelect.SetTitle(DUNGEONS)
        components.InstanceSelect.Show()
    end)
    EncounterJournal.raidsTab = AddTab("Raid", "Raids", function()
        AdventureGuideNavigationService.Reset()
        AdventureGuideNavigationService.SetInstances(InstanceService.GetRaids())
        components.InstanceSelect.SetTitle(RAIDS)
        components.InstanceSelect.Show()
    end)
    EncounterJournal.Tabs[1]:GetScript("OnClick")()
end

UI.Add(component)
