--[[
Copyright (C) 2023 FooxyTV
All rights reserved.
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("WishList")
local components
local scrollbox

function component.Init(components_)
    components = components_
    local wishListFrame = CreateFrame("Frame", EncounterJournal:GetName() .. "WishList", EncounterJournal)
    component.frame = wishListFrame
    EncounterJournal.wishListFrame = wishListFrame
    wishListFrame:SetPoint("TOPLEFT", EncounterJournal.inset, 0, -2)
    wishListFrame:SetPoint("BOTTOMRIGHT", EncounterJournal.inset, -3, 0)
    wishListFrame.bg = wishListFrame:CreateTexture(nil, "OVERLAY")
    wishListFrame.bg:SetTexture(I.UIEJWishListBackground)
    wishListFrame.bg:SetSize(1364, 663)
    wishListFrame.bg:SetPoint("TOPLEFT", -15, -38)
    wishListFrame.title = wishListFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge2")
    wishListFrame.title:SetJustifyH("LEFT")
    wishListFrame.title:SetPoint("TOPLEFT", 20, -15)
    wishListFrame.title:SetText("Wish List")
    scrollbox = CreateFrame("Frame", nil, wishListFrame, "WowScrollBoxList")
    scrollbox:SetSize(748, 379)
    scrollbox:SetPoint("TOPLEFT", 14, -47)
    local scrollbar = CreateFrame("EventFrame", nil, wishListFrame, "MinimalScrollBar")
    scrollbar:SetPoint("TOPLEFT", scrollbox, "TOPRIGHT", 12, -60)
    scrollbar:SetPoint("BOTTOMLEFT", scrollbox, "BOTTOMRIGHT", 12, 4)
    local function SetItemTexture(button, itemID)
        local itemName, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
        if icon then
            button.icon:SetTexture(icon)
        else
            button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            C_Timer.After(0.2, function()
                component.Show()
            end)
        end
        button.itemID = itemID
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(self.itemID)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    local function Initializer(rowFrame, rowData)
        if not rowFrame.initialized then
            rowFrame:SetSize(744, 47)
            rowFrame.bg = rowFrame:CreateTexture(nil, "BACKGROUND")
            rowFrame.bg:SetTexture(I.UIEJWishListLootFrame)
            rowFrame.bg:SetPoint("TOPLEFT", 0, -90)
            rowFrame.header = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            rowFrame.header:SetPoint("LEFT", 10, 0)
            rowFrame.header:SetTextColor(1, 0.82, 0)
            rowFrame.header:SetJustifyH("LEFT")
            rowFrame.itemButtons = {}
            rowFrame.initialized = true
        end
        rowFrame.header:SetText(rowData.slotName)
        rowFrame.header:SetPoint("LEFT", 100, -77)
        for _, btn in ipairs(rowFrame.itemButtons) do
            btn:Hide()
        end
        for i, item in ipairs(rowData.items) do
            local button = rowFrame.itemButtons[i]
            if not button then
                button = CreateFrame("Button", nil, rowFrame, "ItemButtonTemplate")
                button:SetSize(32, 32)
                button:SetPoint("LEFT", rowFrame, "LEFT", 360 + ((i - 1) * 40), 0)
                rowFrame.itemButtons[i] = button
            end
            SetItemTexture(button, item.itemID)
            button:Show()
        end
    end
    local view = CreateScrollBoxListLinearView()
    view:SetElementExtent(47)
    view:SetElementInitializer("Frame", Initializer)
    ScrollUtil.InitScrollBoxWithScrollBar(scrollbox, scrollbar, view)
    wishListFrame:Hide()
end

function component.Show()
    local dataProvider = CreateDataProvider()
    local wishlistData = {
        { slotName = "Head", items = {
            { itemID = 16731 },
            { itemID = 10504 },
        }},
        { slotName = "Neck", items = {
            { itemID = 1714 },
        }},
        -- { slotName = "Chest", items = {
        --     { itemID = 11726 },
        --     { itemID = 12905 },
        -- }},
    }
    for _, slot in ipairs(wishlistData) do
        dataProvider:Insert(slot)
    end
    scrollbox:SetDataProvider(dataProvider)
    components.EncounterJournal.SetCurrentView(component.frame)
    components.NavBar.Reset()
end

UI.Add(component)
