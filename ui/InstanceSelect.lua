--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("InstanceSelect")
local components
local scrollbox

-- Shared OnClick handler for instance buttons
local function InstanceButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
	EncounterJournal.instanceSelect:Hide()
	AdventureGuideNavigationService.Reset()
	AdventureGuideNavigationService.SetInstance(self.instance)
	components.EncounterFrame.ShowInstanceInfo(self.instance)
end

function component.Init(components_)
	components = components_
	local instanceSelect = CreateFrame("Frame", EncounterJournal:GetName() .. "InstanceSelect", EncounterJournal)
	component.frame = instanceSelect
	EncounterJournal.instanceSelect = instanceSelect
	instanceSelect:SetPoint("TOPLEFT", EncounterJournal.inset, 0, -2)
	instanceSelect:SetPoint("BOTTOMRIGHT", EncounterJournal.inset, -3, 0)
	instanceSelect.bg = instanceSelect:CreateTexture(nil, "BACKGROUND")
	instanceSelect.bg:SetTexture("Interface/EncounterJournal/UI-EJ-Classic")
	instanceSelect.bg:SetAllPoints()
	instanceSelect.bg:SetPoint("TOPLEFT", 3, -1)
	instanceSelect.title = instanceSelect:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge2")
	instanceSelect.title:SetJustifyH("LEFT")
	instanceSelect.title:SetPoint("TOPLEFT", 20, -15)

	-- Create expansion filter dropdown
	instanceSelect.filterDropdown = CreateFrame("Frame", instanceSelect:GetName() .. "FilterDropdown", instanceSelect, "UIDropDownMenuTemplate")
	instanceSelect.filterDropdown:SetPoint("TOPRIGHT", instanceSelect, "TOPRIGHT", -20, -8)

	-- Check if we're on a TBC client
	local isTBC = select(4, GetBuildInfo()) >= 20000

	-- Hide dropdown on Classic Era clients (only one option available)
	if not isTBC then
		instanceSelect.filterDropdown:Hide()
	end

	-- Initialize dropdown
	UIDropDownMenu_SetWidth(instanceSelect.filterDropdown, 150)
	UIDropDownMenu_SetText(instanceSelect.filterDropdown, "Classic")

	local function OnFilterClick(self)
		InstanceService.SetExpansionFilter(self.value)
		UIDropDownMenu_SetText(instanceSelect.filterDropdown, self:GetText())
		CloseDropDownMenus()

		-- Determine if we're viewing dungeons or raids by checking current instances
		local currentInstances = AdventureGuideNavigationService.GetInstances()
		local isViewingRaids = false

		if currentInstances and #currentInstances > 0 then
			-- Check if the first instance is a raid by looking for it in the raids list
			local firstInstance = currentInstances[1]
			for _, raid in ipairs(InstanceService.GetRaids()) do
				if raid.instanceID == firstInstance.instanceID then
					isViewingRaids = true
					break
				end
			end
		end

		-- Re-fetch instances based on current view with new filter applied
		if isViewingRaids then
			AdventureGuideNavigationService.SetInstances(InstanceService.GetRaids())
		else
			AdventureGuideNavigationService.SetInstances(InstanceService.GetDungeons())
		end

		-- Refresh the instance list
		component.Show()
	end

	local function InitializeFilterDropdown(self, level)
		local info = UIDropDownMenu_CreateInfo()
		local currentFilter = InstanceService.GetExpansionFilter()
		local isTBC = select(4, GetBuildInfo()) >= 20000

		-- Classic option
		info.text = "Classic"
		info.value = "classic"
		info.func = OnFilterClick
		info.checked = (currentFilter == "classic" or currentFilter == "all")
		UIDropDownMenu_AddButton(info)

		-- Burning Crusade option (only show if running TBC client)
		if isTBC then
			info.text = "Burning Crusade"
			info.value = "tbc"
			info.func = OnFilterClick
			info.checked = (currentFilter == "tbc")
			UIDropDownMenu_AddButton(info)
		end
	end

	UIDropDownMenu_Initialize(instanceSelect.filterDropdown, InitializeFilterDropdown)

	-- Update dropdown text based on saved filter
	local function UpdateDropdownText()
		local filter = InstanceService.GetExpansionFilter()
		if filter == "all" or filter == "classic" then
			UIDropDownMenu_SetText(instanceSelect.filterDropdown, "Classic")
		elseif filter == "tbc" then
			UIDropDownMenu_SetText(instanceSelect.filterDropdown, "Burning Crusade")
		end
	end
	UpdateDropdownText()

	scrollbox = CreateFrame("Frame", nil, instanceSelect, "WowScrollBoxList")
	scrollbox:SetSize(748, 379)
	scrollbox:SetPoint("TOPLEFT", 14, -47)
	local scrollbar = CreateFrame("EventFrame", nil, instanceSelect, "MinimalScrollBar")
	scrollbar:SetPoint("TOPLEFT", scrollbox, "TOPRIGHT", 12, -6)
	scrollbar:SetPoint("BOTTOMLEFT", scrollbox, "BOTTOMRIGHT", 12, 4)
	local function Initializer(button, instance)
		if (not button.initialized) then
			button:SetSize(174, 96)
			button.bgImage = button:CreateTexture(nil, "BACKGROUND")
			button.bgImage:SetTexCoord(0, 0.68359375, 0, 0.7421875)
			button.bgImage:SetAllPoints()
			button.name = button:CreateFontString(nil, "OVERLAY", "QuestTitleFontBlackShadow")
			button.name:SetSize(150, 0)
			button.name:SetPoint("TOP", 0, -15)
			button.range = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			button.range:SetSize(100, 12)
			button.range:SetPoint("BOTTOMLEFT", 7, 7)
			local normal = button:CreateTexture()
			normal:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
			normal:SetTexCoord(0.00195313, 0.34179688, 0.42871094, 0.52246094)
			button:SetNormalTexture(normal)
			local pushed = button:CreateTexture()
			pushed:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
			pushed:SetTexCoord(0.00195313, 0.34179688, 0.33300781, 0.42675781)
			button:SetPushedTexture(pushed)
			local highlight = button:CreateTexture()
			highlight:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
			highlight:SetTexCoord(0.34570313, 0.68554688, 0.33300781, 0.42675781)
			button:SetHighlightTexture(highlight)
			button:SetScript("OnClick", InstanceButton_OnClick)
			button.initialized = true
		end
		button.instance = instance
		button.instanceID = instance.instanceID
		button.name:SetText(instance.name);
		button.bgImage:SetTexture(instance.thumbnail);
		button:Show()
	end
	local view = CreateScrollBoxListGridView(4, 4, 0, 0, 0, 15, 15)
	view:SetElementExtent(96)

	view:SetElementInitializer("AdventureGuideInstanceButtonTemplate", Initializer)
	view:SetElementResetter(function(button) button:Hide() end)

	ScrollUtil.InitScrollBoxWithScrollBar(scrollbox, scrollbar, view)
	instanceSelect:Hide()
end

function component.SetTitle(title)
	component.frame.title:SetText(title)
end

function component.Show()
	-- Update dropdown text to reflect current filter
	local filter = InstanceService.GetExpansionFilter()
	local isTBC = select(4, GetBuildInfo()) >= 20000

	if filter == "all" or filter == "classic" then
		UIDropDownMenu_SetText(component.frame.filterDropdown, "Classic")
		-- Set Classic background texture
		component.frame.bg:SetTexture("Interface/EncounterJournal/UI-EJ-Classic")
	elseif filter == "tbc" then
		UIDropDownMenu_SetText(component.frame.filterDropdown, "Burning Crusade")
		-- Set Burning Crusade background texture
		component.frame.bg:SetTexture("Interface/EncounterJournal/UI-EJ-BurningCrusade")
	end

	local dataProvider = CreateDataProvider()
	for _, instance in ipairs(AdventureGuideNavigationService.GetInstances()) do
		dataProvider:Insert(instance)
	end
	scrollbox:SetDataProvider(dataProvider)
	components.EncounterJournal.SetCurrentView(component.frame)
	components.NavBar.Reset()
end

UI.Add(component)
