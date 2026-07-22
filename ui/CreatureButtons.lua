--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("CreatureButtons")

local components
local creatureButtons
local selectedButton
local SIZE_SELECTED, ICON_SELECTED = 64, 61
local SIZE_UNSELECTED, ICON_UNSELECTED = 50, 49

local function SelectButton(button)
	if selectedButton and selectedButton ~= button then
		selectedButton:Enable()
	end
	selectedButton = button
	button:Disable()
	components.ModelFrame.SetDisplay(button.displayId, button.creatureName)
end

local function ButtonOnClick(self)
	if self.displayId then
		SelectButton(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end
end

local function ButtonOnEnter(self)
	local name = ModelPresetService.GetTitle(self.displayId, components.ModelFrame.GetEncounterId())
		or self.creatureName
	if not name then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(name, 1, 1, 1)
	GameTooltip:Show()
end

local function ButtonOnLeave()
	GameTooltip:Hide()
end

local function CreateCreatureButton()
	local model = EncounterJournal.encounter.info.model
	local button = CreateFrame("Button", nil, model.overlay or model)
	button:SetMotionScriptsWhileDisabled(true)
	button:SetSize(SIZE_UNSELECTED, ICON_UNSELECTED)
	button.creature = button:CreateTexture()
	button.creature:SetDrawLayer("BACKGROUND", 6)
	button.creature:SetSize(30, 30)
	button.creature:SetPoint("CENTER")
	local creatureButtonBorder = button:CreateTexture()
	creatureButtonBorder:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
	creatureButtonBorder:SetTexCoord(0.50585938, 0.63085938, 0.02246094, 0.08203125)
	button:SetNormalTexture(creatureButtonBorder)
	local creatureButtonBorderHighlight = button:CreateTexture()
	creatureButtonBorderHighlight:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
	creatureButtonBorderHighlight:SetTexCoord(0.50585938, 0.63085938, 0.02246094, 0.08203125)
	button:SetHighlightTexture(creatureButtonBorderHighlight, "ADD")
	local lastIndex = #creatureButtons
	if lastIndex == 0 then
		button:SetPoint("TOPLEFT", model, "TOPLEFT", 3, -35)
	else
		button:SetPoint("TOPLEFT", creatureButtons[lastIndex], "BOTTOMLEFT", 0, 8)
	end
	button:SetScript("OnShow", function(self)
		self:SetFrameLevel(self:GetParent():GetFrameLevel() + 2)
	end)
	button:SetScript("OnDisable", function(self)
		self:SetSize(SIZE_SELECTED, ICON_SELECTED)
		self.creature:SetSize(40, 40)
	end)
	button:SetScript("OnEnable", function(self)
		self:SetSize(SIZE_UNSELECTED, ICON_UNSELECTED)
		self.creature:SetSize(30, 30)
	end)
	button:SetScript("OnClick", ButtonOnClick)
	button:SetScript("OnEnter", ButtonOnEnter)
	button:SetScript("OnLeave", ButtonOnLeave)
	button:Hide()
	creatureButtons[lastIndex + 1] = button
	return button
end

function component.SetCreatures(displayIds, encounterName)
	selectedButton = nil
	local wanted = (#displayIds > 1) and #displayIds or 0
	for index = 1, math.max(wanted, #creatureButtons) do
		local button = creatureButtons[index]
		if index <= wanted then
			button.displayId = displayIds[index]
			button.creatureName = encounterName
			SetPortraitTextureFromCreatureDisplayID(button.creature, displayIds[index])
			button:Enable()
			button:Show()
		elseif button then
			button.displayId = nil
			button.creatureName = nil
			button:Hide()
		end
	end
	if wanted > 0 then
		SelectButton(creatureButtons[1])
	end
end

function component.Init(components_)
	components = components_
	creatureButtons = { }
	setmetatable(creatureButtons, {
		__index = function(t, k)
			for _ = #creatureButtons + 1, k do
				CreateCreatureButton()
			end
			return rawget(t, k)
		end
	})
	EncounterJournal.encounter.info.creatureButtons = creatureButtons
end

UI.Add(component)
