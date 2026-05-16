select(2, ...).SetupGlobalFacade()

MicroButton = { }

local button

local function CreateMicroButton()
    local btn = CreateFrame("Button", "AdventureGuideClassicMicroButton", UIParent)
    btn:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-EJ-Up")
    btn:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-EJ-Down")
    btn:SetDisabledTexture("Interface\\Buttons\\UI-MicroButton-EJ-Disabled")
    btn:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
    local hl = btn:GetHighlightTexture()
    if hl then hl:SetBlendMode("ADD") end

    btn:SetScript("OnClick", function()
        UI.ToggleEncounterJournal()
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Adventure Guide")
        local bindingKey = GetBindingKey("TOGGLE_ADVENTUREGUIDECLASSIC")
        if bindingKey then
            GameTooltip:AddLine(string.format("Press %s to toggle", bindingKey), 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return btn
end

local function Anchor()
    if not button then return end
    local anchor = QuestLogMicroButton
    if not anchor then return end

    button:SetParent(anchor:GetParent() or UIParent)
    button:SetFrameStrata(anchor:GetFrameStrata())
    button:SetFrameLevel(anchor:GetFrameLevel())
    button:SetSize(anchor:GetSize())
    button:ClearAllPoints()
    button:SetPoint("LEFT", anchor, "RIGHT", -3, 0)

    -- Blizzard chain-anchors microbuttons (each anchored to its predecessor),
    -- so re-anchoring just the immediate next button to ours pulls the rest along.
    if type(MICRO_BUTTONS) ~= "table" then return end
    local foundQuest = false
    for _, name in ipairs(MICRO_BUTTONS) do
        if foundQuest then
            local next = _G[name]
            if next then
                next:ClearAllPoints()
                next:SetPoint("LEFT", button, "RIGHT", -3, 0)
                break
            end
        elseif name == "QuestLogMicroButton" then
            foundQuest = true
        end
    end
end

function MicroButton.Init()
    if button then return end
    button = CreateMicroButton()
    Anchor()
    if type(_G.UpdateMicroButtons) == "function" then
        hooksecurefunc("UpdateMicroButtons", Anchor)
    end
end
