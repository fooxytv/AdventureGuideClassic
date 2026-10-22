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

--[[
    Hides the tab's disabled-state artwork. Only the Era and TBC template has these,
    and only that one exposes them as globals, so a miss here is expected rather than
    a fault.
]]
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
    --[[
        The two templates butt their tabs together differently.

        Era and TBC overlap by 16 so the wide edge art of one tab meets the next.
        The mainline template has no such allowance: PanelTemplates_AnchorTabs, which
        is how Blizzard spaces these, puts each tab 3pt right of the previous one's
        TOPRIGHT. Overlapping those by 16 sits them on top of each other, which is
        exactly what happened.

        Blizzard's own camelot XML still carries the old -16 between its
        PanelTabButtonTemplate tabs, but InspectFrame calls PanelTemplates_SetNumTabs
        on load and that re-anchors them, so the XML never takes effect. Reading it
        as the live layout is what sent me the wrong way the first time.
    ]]
    if (tabIdx == 1) then
        tab:SetPoint("TOPLEFT", EncounterJournal, "BOTTOMLEFT", 16, 2)
    elseif Compat.isForever then
        tab:SetPoint("TOPLEFT", tabs[tabIdx - 1], "TOPRIGHT", 3, 0)
    else
        tab:SetPoint("LEFT", tabs[tabIdx - 1], "RIGHT", -16, 0)
    end
    --[[
        The Era and TBC template's OnShow and OnEvent belong to CharacterFrame, not to
        a tab borrowed from it, so they are cleared there as they always were.

        The mainline template's are its layout. PanelTabButtonMixin resizes the tab on
        show and on DISPLAY_SIZE_CHANGED, because a font string does not report its
        width reliably before it is shown -- clearing them left every tab at the 36pt
        minimum, narrower than its own artwork, which is what made them overlap.
    ]]
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

--[[
    Light a tab without running its OnClick. Clicking a wishlist row navigates
    straight to one instance, so the tab has to follow the content without the
    instance list being thrown over the top of it.

    Takes the tab itself rather than its number. The numbers move every time a tab
    is added -- the suggested-content tab pushed dungeons from 1 to 2 -- and a
    stale constant lights the wrong tab without erroring, which is the kind of
    fault nobody goes looking for.
]]
function component.SelectTab(tab)
    if not tab then return end
    PanelTemplates_SetTab(EncounterJournal, tab:GetID())
end

function component.Init(components_)
    components = components_
    EncounterJournal.Tabs = tabs

    --[[
        PanelTabButtonMixin reads its sizing off the frame the tabs belong to, so the
        numbers passed to PanelTemplates_TabResize below have to live here too or a
        resize on show would undo them. Unread on Era and TBC.
    ]]
    EncounterJournal.tabPadding = 0
    EncounterJournal.minTabWidth = 36
    EncounterJournal.maxTabWidth = 300
    --[[
        First, as it is in retail, and the tab the journal opens on. It is the only
        view that answers "what now" rather than "what is in here", which is the
        question someone opening the journal usually has.
    ]]
    EncounterJournal.suggestTab = AddTab("Suggest", "Suggested Content", function()
        AdventureGuideNavigationService.Reset()
        components.Suggest.Show()
    end)
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
    --[[
        A top-level tab rather than one of the five beside Overview and Loot: the
        wishlist is per character and spans every instance, so it would show the same
        content whichever boss was lit.
    ]]
    EncounterJournal.wishlistTab = AddTab("Wishlist", "Wishlist", function()
        AdventureGuideNavigationService.Reset()
        components.Wishlist.Show()
    end)
end

--[[
    The landing view, chosen once the rest of the UI exists.

    This was the last line of Init, which was fine while the first tab was Dungeons:
    ui/InstanceSelect.lua is registered ahead of this file, so it had built its
    frames by then. Suggested Content is registered *after* it, so clicking it from
    Init called Suggest.Show() before Suggest.Init had made a single pane --
    "attempt to perform indexed assignment on local 'pane'". PostInit runs after
    every component's Init, whatever the order in ui/UI.xml.
]]
function component.PostInit()
    tabs[1]:GetScript("OnClick")()
end

UI.Add(component)
