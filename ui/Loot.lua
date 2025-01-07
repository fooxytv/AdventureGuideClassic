--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Loot")
local EquipMapping = GetEquipMapping()
local Colors = GetColorMapping()
local components
local lootContainer
local lootScrollBox

local function truncateText(text, maxLength)
	if #text > maxLength then
		return text:sub(1, maxLength - 3) .. "..."
	else
		return text
	end
end

function component.Init(components_)
	components = components_
    lootContainer = CreateFrame("Frame", nil, EncounterJournal.encounter.info)
	lootContainer:SetSize(345, 382)
	lootContainer:SetPoint("BOTTOMRIGHT", -5, 1)
	EncounterJournal.encounter.LootContainer = lootContainer
	lootScrollBox = CreateFrame("Frame", nil, lootContainer, "WowScrollBoxList")
	EncounterJournal.encounter.LootScrollBox = lootScrollBox
	lootScrollBox:SetSize(345, 382)
	lootScrollBox:SetPoint("BOTTOMRIGHT", -20, 1)
	local lootScrollBar = CreateFrame("EventFrame", nil, lootContainer, "MinimalScrollBar")
	EncounterJournal.encounter.LootScrollBar = lootScrollBar
	lootScrollBar:SetPoint("TOPLEFT", lootScrollBox, "TOPRIGHT", 5, -5)
	lootScrollBar:SetPoint("BOTTOMLEFT", lootScrollBox, "BOTTOMRIGHT", 5, 5)
	local function LootButtonInitalizer(button, lootItem)
		if not button.initialized then
			button.icon = button:CreateTexture()
			button.icon:SetSize(45, 45)
			button.icon:SetPoint("LEFT", 0, -5)
			button.icon:SetDrawLayer("BACKGROUND")
			button.iconBorder = button:CreateTexture()
			button.iconBorder:SetTexture("Interface/Common/WhiteIconFrame")
			button.iconBorder:SetSize(45, 45)
			button.iconBorder:SetDrawLayer("OVERLAY")
			button.iconBorder:SetPoint("TOPLEFT", button.icon, "TOPLEFT")
			button.iconOverlay = button:CreateTexture()
			button.iconOverlay:SetTexture("Interface/Common/WhiteIconFrame")
			button.iconOverlay:SetSize(45, 45)
			button.iconOverlay:SetDrawLayer("OVERLAY")
			button.iconOverlay:SetPoint("TOPLEFT", button.icon, "TOPLEFT")
			button.bosslessTexture = button:CreateTexture()
			button.bosslessTexture:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
			button.bosslessTexture:SetTexCoord(0.00195313, 0.62890625, 0.61816406, 0.66210938)
			button.bosslessTexture:SetSize(321, 45)
			button.bosslessTexture:SetPoint("LEFT", 0, -5)
			button.bosslessTexture:SetDrawLayer("BORDER")
			button.name = button:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
			button.name:SetJustifyH("LEFT")
			button.name:SetSize(250, 45)
			button.name:SetPoint("TOPLEFT", 55, 3)
			button.armorType = button:CreateFontString()
			button.armorType:SetJustifyH("LEFT")
			button.armorType:SetSize(0, 12)
			button.armorType:SetPoint("BOTTOMRIGHT", -25, 5)
			button.armorType:SetTextColor(0, 0, 0)
			button.armorType:SetFont("Fonts\\FRIZQT__.TTF", 10)
			button.slot = button:CreateFontString()
			button.slot:SetJustifyH("LEFT")
			button.slot:SetSize(0, 12)
			button.slot:SetPoint("BOTTOMLEFT", 55, 3)
			button.slot:SetTextColor(0, 0, 0)
			button.slot:SetFont("Fonts\\FRIZQT__.TTF", 10)
			button.headerText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
			button.headerText:SetPoint("LEFT", 5, -7)
			button.initialized = true
		end
		if lootItem.isHeader then
			button.headerText:SetText(lootItem.text)
			button.headerText:Show()
			button.icon:Hide()
			button.iconBorder:Hide()
			button.iconOverlay:Hide()
			button.bosslessTexture:Hide()
			button.name:Hide()
			button.armorType:Hide()
			button.slot:Hide()
			button:SetScript("OnEnter", nil)
			button:SetScript("OnLeave", nil)
			button:SetScript("OnClick", nil)
		else
			button.headerText:Hide()
			button.icon:SetTexture(lootItem.icon)
			button.icon:Show()
			button.iconBorder:Show()
			button.iconOverlay:Show()
			button.bosslessTexture:Show()
			local truncatedName = truncateText(lootItem.name, 31)
			button.name:SetText(truncatedName)
			button.name:Show()
			button.armorType:SetText(lootItem.armorType or "Unknown")
			button.armorType:Show()
			button.slot:SetText(lootItem.slot or "Unknown")
			button.slot:Show()
			local color = Colors[lootItem.quality] or Colors[0]
			button.name:SetTextColor(color.r, color.g, color.b)
			button.iconBorder:SetVertexColor(color.r, color.g, color.b)
			button.iconOverlay:SetVertexColor(color.r, color.g, color.b)
			button:SetScript("OnEnter", function(self)
				if lootItem.link then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetHyperlink(lootItem.link)
					GameTooltip:Show()
				end
			end)
			button:SetScript("OnLeave", GameTooltip_Hide)
			button:SetScript("OnClick", function(self, mouseButton)
				if mouseButton == "LeftButton" and IsControlKeyDown() then
					if lootItem.link then
						DressUpItemLink(lootItem.link)
					end
				elseif mouseButton == "LeftButton" then
					if lootItem.link then
						ChatEdit_InsertLink(lootItem.link)
					end
				end
			end)
		end
	end
	local lootView = CreateScrollBoxListLinearView()
	lootView:SetElementExtent(47)
	lootView:SetElementInitializer("Button", LootButtonInitalizer)
	ScrollUtil.InitScrollBoxListWithScrollBar(lootScrollBox, lootScrollBar, lootView)
end

local function OnItemDataLoadResult(event, itemId, success)
	if success then
		component.Show()
	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	OnItemDataLoadResult(event, ...)
end)

function component.Show()
    if lootScrollBox then
        local encounterLoot = AdventureGuideNavigationService.GetEncounterLoot()
        local dataProvider = CreateDataProvider()
        lootScrollBox:SetDataProvider(dataProvider)
        for _, itemId in ipairs(encounterLoot.loot or {}) do
            local itemName, itemLink, itemQuality, _, _, itemType, itemSubType, _, itemEquipLoc, itemIcon = C_Item.GetItemInfo(itemId)
            if itemName then
                local lootItem = {
                    isHeader = false,
                    name = itemName,
                    link = itemLink,
                    quality = itemQuality,
                    icon = itemIcon,
                    armorType = itemSubType,
                    slot = EquipMapping[itemEquipLoc] or itemEquipLoc,
                }
                dataProvider:Insert(lootItem)
            else
                C_Item.RequestLoadItemDataByID(itemId)
            end
        end
        local lootCategories = {
			{ loot = encounterLoot.sharedLoot or {}, headerTitle = "Shared Loot" },
            { loot = encounterLoot.rareLoot or {}, headerTitle = "Rare Loot" },
            { loot = encounterLoot.veryRareLoot or {}, headerTitle = "Very Rare" },
			{ loot = encounterLoot.extremelyRareLoot or {}, headerTitle = "Extremely Rare" },
        }
        for _, category in ipairs(lootCategories) do
            if #category.loot > 0 then
                dataProvider:Insert({ isHeader = true, text = category.headerTitle })
                for _, itemId in ipairs(category.loot) do
                    local itemName, itemLink, itemQuality, _, _, itemType, itemSubType, _, itemEquipLoc, itemIcon = C_Item.GetItemInfo(itemId)
                    if itemName then
                        local lootItem = {
                            isHeader = false,
                            name = itemName,
                            link = itemLink,
                            quality = itemQuality,
                            icon = itemIcon,
                            armorType = itemSubType,
                            slot = EquipMapping[itemEquipLoc] or itemEquipLoc,
                        }
                        dataProvider:Insert(lootItem)
                    else
                        C_Item.RequestLoadItemDataByID(itemId)
                    end
                end
            end
        end

        components.EncounterFrame.SetCurrentView(lootContainer)
    end
end

UI.Add(component)