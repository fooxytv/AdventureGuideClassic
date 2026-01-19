--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("InstanceOverview")
local components
local DungeonMap = _G.DungeonMap or {}
local MapNavBar = _G.MapNavBar or {}

function component.Init(components_)
	components = components_
	local instance = CreateFrame("Frame", nil, EncounterJournal.encounter)
	component.frame = instance
	EncounterJournal.encounter.instance = instance
	instance:SetSize(390, 425)
	instance:SetPoint("BOTTOMRIGHT", -1, 2)
	instance.loreBG = instance:CreateTexture()
	instance.loreBG:SetDrawLayer("BACKGROUND", 4)
	instance.loreBG:SetTexture("Interface/EncounterJournal/UI-EJ-LOREBG-Default")
	instance.loreBG:SetSize(390, 336)
	instance.loreBG:SetPoint("TOP", 3, -9)
	instance.loreBG:SetTexCoord(0, 0.7617187, 0, 0.65625)
	instance.title = instance:CreateFontString(nil, "OVERLAY", "QuestFont_Super_Huge")
	instance.title:SetJustifyH("CENTER")
	instance.title:SetJustifyV("BOTTOM")
	Mixin(instance.title, AutoScalingFontStringMixin)
	instance.title:SetSize(320, 35)
	instance.title:SetPoint("TOP", 0, -48)
	instance.titleBG = instance:CreateTexture(nil, "ARTWORK")
	instance.titleBG:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
	instance.titleBG:SetSize(256, 64)
	instance.titleBG:SetTexCoord(0.34570313, 0.84570313, 0.42871094, 0.49121094)
	instance.titleBG:SetPoint("TOP", instance.loreBG, 0, -38)
	instance.loreScrollingFont = CreateFrame("Frame", nil, instance, "AdventureGuideClassic_ScrollingFontTemplate_GameFontBlack")
	instance.loreScrollingFont:SetFrameStrata("HIGH")
	instance.loreScrollingFont:SetSize(315, 100)
	instance.loreScrollingFont:SetPoint("BOTTOMLEFT", 35, 5)
	instance.loreScrollBar = CreateFrame("EventFrame", nil, instance, "AdventureGuideClassic_MinimalScrollBar_NoTrack")
	instance.loreScrollBar:SetFrameStrata("HIGH")
	instance.loreScrollBar:SetPoint("TOPLEFT", instance.loreScrollingFont, "TOPRIGHT", 9, -33)
	instance.loreScrollBar:SetPoint("BOTTOMLEFT", instance.loreScrollingFont, "BOTTOMRIGHT", 9, 33)
	instance.loreScrollingFont:SetTextColor(CreateColor(.13, .07, .01));
	instance.mapButton = CreateFrame("Button", nil, instance, "UIPanelButtonTemplate")
	instance.mapButton:SetSize(40, 24)
	instance.mapButton:SetPoint("BOTTOMLEFT", 33, 126)
	instance.mapButton:SetFrameStrata("HIGH")
	instance.mapButton:SetFrameLevel(100)
	instance.mapButton:EnableMouse(true)
	instance.mapButton:RegisterForClicks("LeftButtonDown")
	instance.mapButton.shadow = instance.mapButton:CreateTexture(nil, "BACKGROUND")
	instance.mapButton.shadow:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
	instance.mapButton.shadow:SetTexCoord(0.00195313, 0.33593750, 0.85253906, 0.90136719)
	instance.mapButton.shadow:SetPoint("LEFT", -3, 5)
	instance.mapButton.shadow:SetSize(171, 50)
	instance.mapButton.texture = instance.mapButton:CreateTexture(nil, "ARTWORK")
	instance.mapButton.texture:SetTexture("Interface\\QuestFrame\\UI-QuestMap_Button")
	instance.mapButton.texture:SetSize(48, 32)
	instance.mapButton.texture:SetPoint("RIGHT", 2, 0)
	instance.mapButton.texture:SetTexCoord(0.125, 0.875, 0.0, 0.5)
	instance.mapButton.highlight = instance.mapButton:CreateTexture(nil, "HIGHLIGHT")
	instance.mapButton.highlight:SetTexture("Interface\\BUTTONS\\ButtonHilight-Square")
	instance.mapButton.highlight:SetBlendMode("ADD")
	instance.mapButton.highlight:SetSize(36, 25)
	instance.mapButton.highlight:SetPoint("CENTER")
	instance.mapButton.text = instance.mapButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    instance.mapButton.text:SetPoint("LEFT", instance.mapButton.texture, "RIGHT", 4, 0)
    instance.mapButton.text:SetJustifyH("LEFT")
    instance.mapButton.text:SetText("Show\nMap")
	instance.mapButton:SetScript("OnClick", function()
		local instanceName = component.frame.title:GetText()
		local dungeonInfo = DungeonMapService.GetDungeonMapByInstanceName(instanceName)
		if dungeonInfo and type(dungeonInfo.layers) == "table" and #dungeonInfo.layers > 0 then
			local defaultLayer = dungeonInfo.layers[1]
			local defaultMapID = defaultLayer.mapID
			if not DungeonMapFrame then
				DungeonMap:CreateDungeonMapFrame()
			end
			DungeonMap:LoadTiledMap(defaultMapID)
			MapNavBar.SetDungeonInfo(instanceName, dungeonInfo.location)
			DungeonMapFrame:Show()
		else
			print("ERROR: No map data found for instance ->", instanceName)
		end
	end)
	instance.mapButton:SetScript("OnMouseDown", function(self)
		self.texture:SetTexCoord(0.125, 0.875, 0.5, 1.0)
	end)
	instance.mapButton:SetScript("OnMouseUp", function(self)
		self.texture:SetTexCoord(0.125, 0.875, 0.0, 0.5)
	end)

	local scrollBox = instance.loreScrollingFont:GetScrollBox();
	ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, instance.loreScrollBar);
	instance:Hide()
end

function component.Show(instance)
	EncounterJournal.encounter.info.encounterTitle:SetText("")
	component.frame.title:SetText(instance.name)
	component.frame.loreBG:SetTexture(instance.splash)
	-- component.frame.infoButton:SetText(instance.info)
	component.frame.loreScrollingFont:SetText(instance.overview);
	component.frame.loreScrollBar:SetShown(component.frame.loreScrollingFont:HasScrollableExtent());
	components.EncounterFrame.SetCurrentView(component.frame)
end

UI.Add(component)