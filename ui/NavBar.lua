--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("NavBar")
local components

local instance, encounterID
local searchBox, searchResults, searchResultsScrollBox
local searchDebounceTimer = nil
local MAX_SEARCH_RESULTS = 20

function component.Init(components_)
	components = components_
	local navBar = CreateFrame("Frame", EncounterJournal:GetName() .. "NavBar", EncounterJournal, "NavBarTemplate")
	component.frame = navBar
	EncounterJournal.navBar = navBar
	navBar:SetSize(730, 34)
	navBar:SetPoint("TOPLEFT", 61, -22)
	local insetBotLeftCorner = navBar:CreateTexture(nil, "BORDER", "UI-Frame-InnerBotLeftCorner")
	insetBotLeftCorner:ClearAllPoints()
	insetBotLeftCorner:SetPoint("BOTTOMLEFT", -3, -3)
	local insetBotRightCorner = navBar:CreateTexture(nil, "BORDER", "UI-Frame-InnerBotRight")
	insetBotRightCorner:ClearAllPoints()
	insetBotRightCorner:SetPoint("BOTTOMRIGHT", 3, -3)
	local insetBottomBorder = navBar:CreateTexture(nil, "BORDER", "_UI-Frame-InnerBotTile")
	insetBottomBorder:ClearAllPoints()
	insetBottomBorder:SetPoint("BOTTOMLEFT", insetBotLeftCorner, "BOTTOMRIGHT")
	insetBottomBorder:SetPoint("BOTTOMRIGHT", insetBotRightCorner, "BOTTOMLEFT")
	local insetLeftBorder = navBar:CreateTexture(nil, "BORDER", "!UI-Frame-InnerLeftTile")
	insetLeftBorder:ClearAllPoints()
	insetLeftBorder:SetPoint("TOPLEFT", -3, 0)
	insetLeftBorder:SetPoint("BOTTOMLEFT", insetBotLeftCorner, "TOPLEFT")
	local insetRightBorder = navBar:CreateTexture(nil, "BORDER", "!UI-Frame-InnerRightTile")
	insetRightBorder:ClearAllPoints()
	insetRightBorder:SetPoint("TOPRIGHT", 3, 0)
	insetRightBorder:SetPoint("BOTTOMRIGHT", insetBotRightCorner, "TOPRIGHT")
	navBar.button2 = CreateFrame("Button", navBar:GetName() .. "Button2", navBar, "NavButtonTemplate")
	local homeData = {
		name = "Home",
		OnClick = function()
			local currentInstance = AdventureGuideNavigationService.GetInstance()
			local isRaid = false
			if currentInstance then
				for _, raid  in ipairs(InstanceService.GetRaids() or {}) do
					if raid.name == currentInstance.name then
						isRaid = true
						break
					end
				end
			end
			if isRaid then
				AdventureGuideNavigationService.SetInstances(InstanceService.GetRaids())
			else
				AdventureGuideNavigationService.SetInstances(InstanceService.GetDungeons())
			end
			local instances = AdventureGuideNavigationService.GetInstances()
			if (instances) then
				components.InstanceSelect.Show()
			end
		end,
	}
	-- local homeData = {
	-- 	name = "Home",
	-- 	OnClick = function()
	-- 		AdventureGuideNavigationService.SetInstances(InstanceService.GetDungeons())
	-- 		local instances = AdventureGuideNavigationService.GetInstances()
	-- 		if (instances) then
	-- 			components.InstanceSelect.Show()
	-- 		end
	-- 	end,
	-- }
	NavBar_Initialize(navBar, "NavButtonTemplate", homeData, navBar.home, navBar.overflow);

	-- Create search EditBox on the right side of NavBar
	searchBox = CreateFrame("EditBox", navBar:GetName() .. "SearchBox", navBar, "SearchBoxTemplate")
	searchBox:SetSize(150, 20)
	searchBox:SetPoint("RIGHT", navBar, "RIGHT", -10, 0)
	searchBox:SetAutoFocus(false)
	navBar.searchBox = searchBox

	-- Fix for placeholder text - ensure instructions show/hide properly
	if searchBox.Instructions then
		searchBox.Instructions:SetText("Search")
	end

	-- Create search results dropdown (same width as search box, solid dark background)
	searchResults = CreateFrame("Frame", navBar:GetName() .. "SearchResults", navBar, "BackdropTemplate")
	searchResults:SetSize(150, 200)
	searchResults:SetPoint("TOPRIGHT", searchBox, "BOTTOMRIGHT", 0, 2)
	searchResults:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 8, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	searchResults:SetBackdropColor(0.1, 0.1, 0.1, 1)
	searchResults:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	searchResults:SetFrameStrata("DIALOG")
	searchResults:SetFrameLevel(100)
	searchResults:Hide()
	navBar.searchResults = searchResults

	-- Create ScrollBox for results
	searchResultsScrollBox = CreateFrame("Frame", nil, searchResults, "WowScrollBoxList")
	searchResultsScrollBox:SetSize(142, 180)
	searchResultsScrollBox:SetPoint("TOPLEFT", 4, -4)
	searchResultsScrollBox:SetPoint("BOTTOMRIGHT", -4, 4)

	local searchResultsScrollBar = CreateFrame("EventFrame", nil, searchResults, "MinimalScrollBar")
	searchResultsScrollBar:SetPoint("TOPLEFT", searchResultsScrollBox, "TOPRIGHT", 2, -5)
	searchResultsScrollBar:SetPoint("BOTTOMLEFT", searchResultsScrollBox, "BOTTOMRIGHT", 2, 5)
	searchResultsScrollBar:Hide()

	-- Initialize ScrollBox view
	local function SearchResultInitializer(button, result)
		if not button.initialized then
			button.icon = button:CreateTexture(nil, "ARTWORK")
			button.icon:SetSize(20, 20)
			button.icon:SetPoint("LEFT", 4, 0)

			button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			button.text:SetPoint("LEFT", button.icon, "RIGHT", 4, 2)
			button.text:SetPoint("RIGHT", -4, 0)
			button.text:SetJustifyH("LEFT")
			button.text:SetWordWrap(false)

			button.subText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			button.subText:SetPoint("TOPLEFT", button.text, "BOTTOMLEFT", 0, 0)
			button.subText:SetPoint("RIGHT", -4, 0)
			button.subText:SetJustifyH("LEFT")
			button.subText:SetTextColor(0.5, 0.5, 0.5)
			button.subText:SetWordWrap(false)

			button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

			button.initialized = true
		end

		button.result = result

		if result.isHeader then
			-- Header row
			button.icon:Hide()
			button.text:SetText(result.text)
			button.text:SetTextColor(1, 0.82, 0)
			button.text:ClearAllPoints()
			button.text:SetPoint("LEFT", 4, 0)
			button.text:SetPoint("RIGHT", -4, 0)
			button.subText:Hide()
			button:SetScript("OnClick", nil)
			button:SetScript("OnEnter", nil)
			button:SetScript("OnLeave", nil)
		elseif result.type == "instance" then
			-- Instance result
			button.icon:SetTexture(result.icon)
			button.icon:Show()
			button.text:SetText(result.name)
			button.text:SetTextColor(1, 1, 1)
			button.text:ClearAllPoints()
			button.text:SetPoint("LEFT", button.icon, "RIGHT", 4, 2)
			button.text:SetPoint("RIGHT", -4, 0)
			button.subText:SetText(result.isRaid and "Raid" or "Dungeon")
			button.subText:Show()
			button:SetScript("OnClick", function()
				component.OnSearchResultClick(result)
			end)
			button:SetScript("OnEnter", function(self)
				self:GetHighlightTexture():Show()
			end)
			button:SetScript("OnLeave", nil)
		elseif result.type == "loot" then
			-- Loot result
			button.icon:SetTexture(result.itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
			button.icon:Show()
			local qualityColor = ITEM_QUALITY_COLORS[result.itemQuality] or ITEM_QUALITY_COLORS[1]
			button.text:SetText(result.name)
			button.text:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
			button.text:ClearAllPoints()
			button.text:SetPoint("LEFT", button.icon, "RIGHT", 4, 2)
			button.text:SetPoint("RIGHT", -4, 0)
			button.subText:SetText(result.sourceName or "Unknown")
			button.subText:Show()
			button:SetScript("OnClick", function()
				component.OnSearchResultClick(result)
			end)
			button:SetScript("OnEnter", function(self)
				self:GetHighlightTexture():Show()
				if result.itemLink then
					GameTooltip:SetOwner(self, "ANCHOR_LEFT")
					GameTooltip:SetHyperlink(result.itemLink)
					GameTooltip:Show()
				end
			end)
			button:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
		end
	end

	local searchView = CreateScrollBoxListLinearView()
	searchView:SetElementExtent(32)
	searchView:SetElementInitializer("Button", SearchResultInitializer)
	ScrollUtil.InitScrollBoxListWithScrollBar(searchResultsScrollBox, searchResultsScrollBar, searchView)

	-- Search box event handlers
	searchBox:SetScript("OnTextChanged", function(self, userInput)
		local text = self:GetText()

		-- Handle placeholder text visibility
		if self.Instructions then
			if text ~= "" then
				self.Instructions:Hide()
			else
				self.Instructions:Show()
			end
		end

		-- Always check if text is empty to hide dropdown (handles X button click)
		if text == "" then
			component.HideSearchResults()
			SearchService.ClearSearch()
			return
		end

		-- Trigger search on user input
		if userInput then
			component.OnSearchTextChanged(text)
		end
	end)

	searchBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
		component.HideSearchResults()
	end)

	searchBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)

end

function component.SetInstance(instance_)
	instance = instance_
end

function component.SetEncounter(encounterID_)
	encounterID = encounterID_
end

function component.Refresh(encounterName)
	NavBar_Reset(component.frame)
	if (instance) then
		NavBar_AddButton(component.frame, {
			name = instance.name,
			OnClick = function()
				AdventureGuideNavigationService.Reset()
				AdventureGuideNavigationService.SetInstance(instance)
				components.EncounterFrame.ShowInstanceInfo(instance)
			end,
			listFunc = nop
		})
		if encounterName then
			NavBar_AddButton(component.frame, {
				name = encounterName,
				OnClick = nop,
				listFunc = nop
			})
		end
	end
end

function component.Reset()
	instance = nil
	encounterID = nil
	NavBar_Reset(component.frame)
end

-- Search functionality
function component.OnSearchTextChanged(text)
	-- Cancel any pending debounce timer
	if searchDebounceTimer then
		searchDebounceTimer:Cancel()
		searchDebounceTimer = nil
	end

	if not text or text == "" or #text < 2 then
		component.HideSearchResults()
		SearchService.ClearSearch()
		return
	end

	-- Short debounce (100ms) to avoid excessive searches while typing quickly
	searchDebounceTimer = C_Timer.NewTimer(0.1, function()
		component.ExecuteSearch(text)
	end)
end

function component.ExecuteSearch(text)
	local instanceResults, lootResults = SearchService.Search(text, function(searchText)
		-- Callback for when async items finish loading - re-run search
		if searchBox:GetText() == searchText then
			component.ExecuteSearch(searchText)
		end
	end)

	component.DisplaySearchResults(instanceResults, lootResults)
end

function component.DisplaySearchResults(instanceResults, lootResults)
	local dataProvider = CreateDataProvider()
	local count = 0
	local totalItems = 0

	-- Add instance results with header
	if #instanceResults > 0 then
		dataProvider:Insert({ isHeader = true, text = "Instances" })
		totalItems = totalItems + 1
		for _, result in ipairs(instanceResults) do
			if count < MAX_SEARCH_RESULTS then
				dataProvider:Insert(result)
				count = count + 1
				totalItems = totalItems + 1
			end
		end
	end

	-- Add loot results with header
	if #lootResults > 0 and count < MAX_SEARCH_RESULTS then
		dataProvider:Insert({ isHeader = true, text = "Loot" })
		totalItems = totalItems + 1
		for _, result in ipairs(lootResults) do
			if count < MAX_SEARCH_RESULTS then
				dataProvider:Insert(result)
				count = count + 1
				totalItems = totalItems + 1
			end
		end
	end

	if count > 0 then
		-- Dynamically size the dropdown based on number of items
		local itemHeight = 32
		local padding = 8
		local maxHeight = 300
		local calculatedHeight = (totalItems * itemHeight) + padding
		local finalHeight = math.min(calculatedHeight, maxHeight)

		searchResults:SetHeight(finalHeight)
		searchResultsScrollBox:SetDataProvider(dataProvider)
		searchResults:Show()
	else
		component.HideSearchResults()
	end
end

function component.HideSearchResults()
	if searchResults then
		searchResults:Hide()
	end
end

function component.OnSearchResultClick(result)
	if result.type == "instance" then
		-- Navigate to instance
		AdventureGuideNavigationService.Reset()
		AdventureGuideNavigationService.SetInstance(result.instance)
		components.EncounterFrame.ShowInstanceInfo(result.instance)
	elseif result.type == "loot" then
		-- Navigate to the instance and encounter with that loot
		AdventureGuideNavigationService.Reset()
		AdventureGuideNavigationService.SetInstance(result.instance)
		AdventureGuideNavigationService.SetEncounter(result.encounter)
		components.EncounterFrame.ShowInstanceInfo(result.instance)

		-- Set NavBar to show the encounter
		component.SetInstance(result.instance)
		component.SetEncounter(result.encounter.encounterID)
		component.Refresh(result.encounter.name)

		-- Show the loot view
		if components.Loot and components.Loot.Show then
			components.Loot.Show()
		end
	end

	-- Clear search and hide results
	if searchBox then
		searchBox:SetText("")
		searchBox:ClearFocus()
	end
	component.HideSearchResults()
	SearchService.ClearSearch()
end

UI.Add(component)