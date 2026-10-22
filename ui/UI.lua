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
