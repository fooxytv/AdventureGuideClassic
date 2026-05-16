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
    local rightmost = HelpMicroButton or MainMenuMicroButton or CharacterMicroButton
    if not rightmost then return end
    button:SetParent(rightmost:GetParent() or UIParent)
    button:SetFrameStrata(rightmost:GetFrameStrata())
    button:SetFrameLevel(rightmost:GetFrameLevel())
    button:SetSize(rightmost:GetSize())
    button:ClearAllPoints()
    button:SetPoint("LEFT", rightmost, "RIGHT", -3, 0)
end

function MicroButton.Init()
    if button then return end
    button = CreateMicroButton()
    Anchor()
    if type(_G.UpdateMicroButtons) == "function" then
        hooksecurefunc("UpdateMicroButtons", Anchor)
    end
end
