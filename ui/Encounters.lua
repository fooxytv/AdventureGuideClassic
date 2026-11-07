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

--[[
	The boss behind the portrait, in the shape of a unit tooltip: the name, then a
	level line.

	It is anchored where the player keeps their tooltip rather than beside the
	button, since for most people that is the bottom right corner and a tooltip
	appearing over the boss list would cover the thing being pointed at.

	The second line reads the way the game writes a unit's: "Level 19 Humanoid
	Elite". Each part is dropped when the data has none rather than written as a
	placeholder, so a boss with a level but no type reads "Level 19" instead of
	"Level 19 ?? ??". Forever's own bosses have neither and get no line at all --
	tools/gen_npc_meta.py has the sources and what they do not cover.

	The name is taken from the button rather than from the encounter, so whatever
	the list is willing to show is what the tooltip shows. That matters for the
	discovery mode, where an unmet boss reads ??? -- and there the line is left
	off entirely, since a level and a creature type would give away the thing the
	mode exists to withhold.
]]
local function BossDetailLine(encounter)
	if not encounter.level then return nil end
	local parts = { ("Level %s"):format(encounter.level) }
	if encounter.creatureType then parts[#parts + 1] = encounter.creatureType end
	if encounter.classification then parts[#parts + 1] = encounter.classification end
	return table.concat(parts, " ")
end

local function BossOnEnter(self)
	if not self.encounter then return end
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	if GameTooltip_SetDefaultAnchor then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	else
		GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -30, 80)
	end
	local name = self.name:GetText() or ""
	GameTooltip:SetText(name)
	if name ~= DiscoveryService.UNKNOWN_NAME then
		local detail = BossDetailLine(self.encounter)
		if detail then GameTooltip:AddLine(detail, 1, 1, 1) end
	end
	GameTooltip:Show()
end

local function BossOnLeave()
	GameTooltip_Hide()
end

local function EncounterButton_OnClick(self)
	local currentEncounter = AdventureGuideNavigationService.GetEncounter()
	-- Compare the encounter tables, not their encounterIDs. Forever's bosses carry
	-- no encounterID yet, so ID equality made every one of them look like the
	-- selected boss -- nil == nil -- and the list refused to change selection.
	-- SetEncounter stores the reference it is given, so identity is exact and is
	-- a stronger test than the ID was.
	if currentEncounter and currentEncounter == self.encounter then
		return
	end

	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
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

	local selectedTabName = components.InfoTabs.GetSelectedTabName()
	if selectedTabName == "Overview" then
		local lootContainer = EncounterJournal.encounter.LootContainer
		if lootContainer then
			lootContainer:SetAlpha(0)
		end
		components.Loot.Show()
		C_Timer.After(0.001, function()
			if lootContainer then
				lootContainer:SetAlpha(1)
			end
			components.DynamicContentScroller.ShowOverview()
			components.InfoTabs.Refresh()
		end)
	elseif selectedTabName == "Loot" then
		components.Loot.Show()
		components.InfoTabs.Refresh()
	elseif selectedTabName == "Quest" then
		--[[
			Quests belong to the instance, so an encounter has none of its own. The tab
			only refreshed itself here, which left its now-disabled view on screen
			showing the instance's list with no way back. Fall back to the encounter's
			overview, the same way Model does when a boss has no model.
		]]
		components.DynamicContentScroller.ShowOverview()
		components.InfoTabs.SelectOverview()
		components.InfoTabs.Refresh()
	elseif selectedTabName == "Abilities" then
		--[[
			Most bosses have no abilities recorded, and the tab is disabled for those,
			so switching to one would otherwise leave the previous boss's abilities on
			screen under the new boss's name. Fall back to the overview, the same way
			Quest and Model already do.
		]]
		if (#AdventureGuideNavigationService.GetEncounterAbilities() > 0) then
			components.DynamicContentScroller.ShowAbilities()
		else
			components.DynamicContentScroller.ShowOverview()
			components.InfoTabs.SelectOverview()
		end
		components.InfoTabs.Refresh()
	elseif selectedTabName == "Model" then
		if not components.ModelFrame.Show() then
			components.DynamicContentScroller.ShowOverview()
			components.InfoTabs.SelectOverview()
		end
		components.InfoTabs.Refresh()
	end
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
			button:SetScript("OnEnter", BossOnEnter)
			button:SetScript("OnLeave", BossOnLeave)
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
		-- A boss this character has not met shows as an unnamed silhouette while the
		-- discovery mode is on. IsDiscovered is always true while it is off.
		local instance = AdventureGuideNavigationService.GetInstance()
		local discovered = DiscoveryService.IsDiscovered(instance and instance.name, encounter)
		button.name:SetText(discovered and encounter.name or DiscoveryService.UNKNOWN_NAME);
		-- These buttons are recycled by the scroll box, so a boss with no portrait
		-- must be given the default explicitly: the one set when the button was
		-- created has long since been overwritten by whichever boss used it last.
		-- Same fallback as ModelFrame does for a missing instance splash.
		button.bgImage:SetTexture((discovered and encounter.portrait)
			or "Interface/EncounterJournal/UI-EJ-BOSS-Default");
		if (encounter.defeated == 1) then
			button.DefeatedOverlay:Show()
		else
			button.DefeatedOverlay:Hide()
		end
	end
	local bossView = CreateScrollBoxListLinearView();
	bossView:SetElementExtent(55)
	bossView:SetElementInitializer("Button", BossButtonInitializer);
	bossView:SetPadding(10,0,0,20,15);
	ScrollUtil.InitScrollBoxListWithScrollBar(encountersScrollBox, encountersScrollBar, bossView);
end

function component.SetInstance(instance, dungeonName)
	if not encountersScrollBox then
		return
	end
	local dataProvider = CreateDataProvider();
	encountersScrollBox:SetDataProvider(dataProvider);
	for _, encounter in ipairs(instance) do
		encounter.dungeonName = dungeonName
		dataProvider:Insert(encounter)
	end
end

function component.RefreshEncounters()
	local currentInstance = AdventureGuideNavigationService.GetInstance()

	if currentInstance and currentInstance.name then
		component.SetInstance(currentInstance, currentInstance.name)
	else
		local instanceName = GetInstanceInfo()
		if instanceName and instanceName ~= "" then
			local dungeons = InstanceService.GetDungeons()
			for _, dungeon in ipairs(dungeons) do
				if dungeon.name == instanceName then
					component.SetInstance(dungeon, instanceName)
					return
				end
			end

			local raids = InstanceService.GetRaids()
			for _, raid in ipairs(raids) do
				if raid.name == instanceName then
					component.SetInstance(raid, instanceName)
					return
				end
			end
		end
	end
end

local function CheckLegacyRefreshFlag()
	if _G.AdventureGuideClassic_UI_Encounters_Refresh then
		_G.AdventureGuideClassic_UI_Encounters_Refresh = false
		component.RefreshEncounters()
	end
end

C_Timer.NewTicker(0.5, CheckLegacyRefreshFlag)

UI.Add(component)
