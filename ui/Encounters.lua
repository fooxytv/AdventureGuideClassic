--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("Encounters")
local components
local encountersScrollBox
local sharedHighlightFrame

local function EncounterButton_OnClick(self)
	AdventureGuideNavigationService.SetEncounter(self.encounter)
	EncounterJournal.encounter.info.encounterTitle:SetText("")
	if self.encounter then
		local encounterName = AdventureGuideNavigationService.GetEncounterName()
		EncounterJournal.encounter.info.encounterTitle:SetText(encounterName)
		components.NavBar.Refresh(encounterName)
	end
	sharedHighlightFrame:SetParent(self)
	sharedHighlightFrame:SetAllPoints(self)
	sharedHighlightFrame:Show()
	--todo: Switch to correct view
	local selectedTabName = components.InfoTabs.GetSelectedTabName()
	if selectedTabName == "Overview" then
		components.DynamicContentScroller.ShowOverview()
	elseif selectedTabName == "Loot" then
		components.Loot.Show()
	elseif selectedTabName == "Quest" then
		-- todo: implement
	elseif selectedTabName == "Abilities" then
		components.DynamicContentScroller.ShowAbilities()
	elseif selectedTabName == "Model" then
		-- todo: implement
	end
	-- components.DynamicContentScroller.ShowOverview()
	components.InfoTabs.Refresh()
end

function component.Init(components_)
	components = components_
	local info = EncounterJournal.encounter.info
	encountersScrollBox = CreateFrame("Frame", nil, info, "WowScrollBoxList")
	EncounterJournal.encounter.info.BossesScrollBox = encountersScrollBox
	encountersScrollBox:SetSize(338, 382)
	encountersScrollBox:SetPoint("BOTTOMLEFT", 25, 1)
	local encountersScrollBar = CreateFrame("EventFrame", nil, info, "MinimalScrollBar")
	EncounterJournal.encounter.info.BossesScrollBar = encountersScrollBar
	encountersScrollBar:SetPoint("TOPLEFT", encountersScrollBox, "TOPRIGHT", 5, -5)
	encountersScrollBar:SetPoint("BOTTOMLEFT", encountersScrollBox, "BOTTOMRIGHT", 5, 5)
	sharedHighlightFrame = CreateFrame("Frame", nil, encountersScrollBox)
	sharedHighlightFrame:Hide()
	local highlightTexture = sharedHighlightFrame:CreateTexture()
	highlightTexture:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
	highlightTexture:SetTexCoord(0.00195313, 0.63671875, 0.15820313, 0.21191406)
	highlightTexture:SetAllPoints(sharedHighlightFrame)
	local function BossButtonInitializer(button, encounter)
		button.encounter = encounter
		if (not button.initialized) then
			button:SetSize(325, 55)
			button.DefeatedOverlay = CreateFrame("Button", nil, button)
			button.DefeatedOverlay:SetSize(16, 16)
			button.DefeatedOverlay:SetFrameLevel(150)
			button.DefeatedOverlay:SetPoint("BOTTOMLEFT", 4, 0)
			button.DefeatedOverlay.Icon = button.DefeatedOverlay:CreateTexture(nil, "BACKGROUND")
			Atlas.SetAtlas(button.DefeatedOverlay.Icon, "Map-MarkedDefeated", true)
			button.DefeatedOverlay.Icon:SetPoint("CENTER")
			--todo: implement if API provides a means to do so
			--[[
				for button.DefeatedOverlay
				<Scripts>
					<OnEnter function="EncounterJournalBossButtonDefeatedOverlay_OnEnter"/>
					<OnLeave function="GameTooltip_Hide"/>
				</Scripts>
			]]
			-- anonymous frame
			local creatureFrame = CreateFrame("Frame", nil, button)
			creatureFrame:SetSize(1, 1)
			creatureFrame:SetPoint("TOPLEFT", -4, 13)
			button.bgImage = creatureFrame:CreateTexture()
			button.bgImage:SetDrawLayer("OVERLAY", 6)
			button.bgImage:SetTexture("Interface/EncounterJournal/UI-EJ-BOSS-Default")
			button.bgImage:SetSize(128, 64)
			button.bgImage:SetPoint("TOPLEFT")
			local normal = button:CreateTexture()
			normal:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
			normal:SetTexCoord(0.00195313, 0.63671875, 0.21386719, 0.26757813)
			button:SetNormalTexture(normal)
			local pushed = button:CreateTexture()
			pushed:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
			pushed:SetTexCoord(0.00195313, 0.63671875, 0.10253906, 0.15625000)
			button:SetPushedTexture(pushed)
			local highlight = button:CreateTexture()
			highlight:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
			highlight:SetTexCoord(0.00195313, 0.63671875, 0.15820313, 0.21191406)
			button:SetHighlightTexture(highlight)
			button.name = button:CreateFontString()
			button.name:SetJustifyH("LEFT")
			button.name:SetJustifyV("MIDDLE")
			button.name:SetTextColor(0.87, 0.659, 0.463)
			button.name:SetSize(160, 40)
			button.name:SetPoint("LEFT", 105, -3)
			button:SetFontString(button.name)
			button:SetNormalFontObject("GameFontNormalMed3")
			button:SetHighlightFontObject("GameFontNormalMed3")
			button:SetDisabledFontObject("GameFontHighlightMedium")
			button:SetScript("OnClick", EncounterButton_OnClick)
			button.initialized = true
		end
		if (encounter and encounter == AdventureGuideNavigationService.GetEncounter()) then
			sharedHighlightFrame:SetParent(button)
			sharedHighlightFrame:SetAllPoints(button)
			sharedHighlightFrame:Show()
		elseif (sharedHighlightFrame:GetParent() == button) then
			sharedHighlightFrame:Hide()
		end
		button.encounter = encounter
		button.name:SetText(encounter.name);
		button.bgImage:SetTexture(encounter.portrait);
		button.DefeatedOverlay:Hide()
	end
	local bossView = CreateScrollBoxListLinearView();
	bossView:SetElementExtent(55)
	bossView:SetElementInitializer("Button", BossButtonInitializer);
	bossView:SetPadding(10,0,0,20,15);
	ScrollUtil.InitScrollBoxListWithScrollBar(encountersScrollBox, encountersScrollBar, bossView);
end

function component.SetInstance(instance)
	local dataProvider = CreateDataProvider();
	encountersScrollBox:SetDataProvider(dataProvider);
	for _, encounter in ipairs(instance) do
		dataProvider:Insert(encounter)
	end
end

UI.Add(component)
