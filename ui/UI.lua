--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

UI = { }

local components = { }
local updateComponents = { }
local frame

function UI.Add(component)
    table.insert(components, component)
    if (component.name) then
        components[component.name] = component
    end
    if (component.Update) then
        table.insert(updateComponents, component)
    end
end

function UI.GetComponent(name)
    return components[name]
end

--[[
    Put an item link in the chat box, opening it first if it is shut.

    `ChatEdit_InsertLink` only ever fills an edit box that already has focus. With
    the chat bar closed it falls through every branch and returns false without
    saying anything, so a click on a loot row looked like it had done nothing and
    gave no clue why. Opening chat with the link already in it is what the bag and
    the character sheet do, and it is what makes the gesture work the first time
    rather than the second.

    The return value says whether the link went anywhere, so a caller can fall
    back to something else; nothing needs that yet.
]]
function UI.LinkItem(link)
    if (not link) then
        return false
    end
    if (ChatEdit_InsertLink(link)) then
        return true
    end
    if (ChatFrame_OpenChat) then
        ChatFrame_OpenChat(link)
        return true
    end
    return false
end

--[[
    Two passes, and the second one matters.

    `Init` runs in the order of the `<Script>` lines in `ui/UI.xml`, so a component
    that *acts on* another during its own `Init` can reach one that has not built
    its frames yet. That is not hypothetical: EncounterJournalTabs ends by clicking
    its first tab, and once that tab became Suggested Content -- registered five
    lines later -- the click ran `Suggest.Show()` against an empty pane table.

    So anything a component wants to do once the whole UI exists belongs in
    `PostInit`, which runs only after every `Init` has returned. Reordering
    `ui/UI.xml` would have fixed that one case and left the next one waiting.
]]
function UI.Init()
    frame = CreateFrame("Frame")
    for _, component in ipairs(components) do
        if (component.Init) then
            component.Init(components)
        end
    end
    for _, component in ipairs(components) do
        if (component.PostInit) then
            component.PostInit(components)
        end
    end
end
