--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

CollapsibleSectionWidgetTypeMixin = Mixin({
	type = "Button"
}, WidgetTypeMixin)

local function AbilityIcon_OnShow(self)
	local parent = self:GetParent()
	parent.title:ClearAllPoints()
	parent.title:SetPoint("LEFT", parent.abilityIcon, "RIGHT", 5, 0.5)
	parent.title:SetPoint("RIGHT")
end

local function AbilityIcon_OnHide(self)
	local parent = self:GetParent()
	parent.title:ClearAllPoints()
	parent.title:SetPoint("LEFT", parent.expandedIcon, "RIGHT", 5, 0.5)
	parent.title:SetPoint("RIGHT")
end

local function SetIcon(texture, index)
	local iconSize = 32;
	local columns = 256/iconSize;
	local rows = 64/iconSize;
	local l = mod(index, columns) / columns;
	local r = l + (1/columns);
	local t = floor(index/columns) / rows;
	local b = t + (1/rows);
	texture:SetTexCoord(l,r,t,b);
end

function CollapsibleSectionWidgetTypeMixin:Construct(parent)
	local frame = WidgetTypeMixin.ConstructDefault(self, "Frame", nil, parent)
	frame:SetSize(200, 24)
	local button = CreateFrame("Button", nil, frame)
	frame.button = button
	button:SetSize(200,24)
	button:SetPoint("TOPLEFT")
	button:SetPoint("RIGHT")
	button.expandedIcon = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	button.expandedIcon:SetSize(12, 12)
	button.expandedIcon:SetPoint("LEFT", 5, 0)
	button.expandedIcon:SetText("-")
	button.expandedIcon:SetTextColor(0.929, 0.788, 0.620, 1)
	button.title = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	button.title:SetSize(1, 10)
	button.title:SetJustifyH("LEFT")
	button.title:SetTextColor(0.929, 0.788, 0.620, 1)
	button.abilityIcon = button:CreateTexture(nil, "OVERLAY")
	button.abilityIcon:SetSize(18, 18)
	button.abilityIcon:SetPoint("LEFT", button.expandedIcon, "RIGHT", 5, 0)
	button.abilityIcon:Hide()
	button.abilityIcon:SetScript("OnShow", AbilityIcon_OnShow)
	button.abilityIcon:SetScript("OnHide", AbilityIcon_OnHide)
	AbilityIcon_OnHide(button.abilityIcon)
	button.icons = { }
	for i = 1, 4 do
		local iconFrame = CreateFrame("Frame", nil, button)
		table.insert(button.icons, iconFrame)
		iconFrame:SetSize(32, 32)
		iconFrame.icon = iconFrame:CreateTexture(nil, "OVERLAY")
		-- iconFrame.icon:SetTexture(I.UIEJIcons)
		iconFrame.icon:SetPoint("CENTER")
		iconFrame.icon:SetSize(32, 32)
		iconFrame:SetScript("OnEnter", function(self)
			if self.tooltipTitle then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				GameTooltip:SetText(self.tooltipTitle,1,1,1);
				GameTooltip:AddLine(self.tooltipText, nil, nil, nil, true);
				GameTooltip:Show();
			end
		end)
		iconFrame:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		if (i == 1) then
			iconFrame:SetPoint("RIGHT", 5, 0)
		else
			iconFrame:SetPoint("RIGHT", button.icons[i-1], "LEFT", 10, 0)
		end
		SetIcon(iconFrame.icon, i)
	end
	button.leftHighlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.leftHighlight:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
	button.leftHighlight:SetTexCoord(0.74218750, 0.86718750, 0.15820313, 0.18652344)
	button.leftHighlight:SetSize(64, 29)
	button.leftHighlight:ClearAllPoints()
	button.leftHighlight:SetPoint("LEFT", -1, -1)
	button.rightHighlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.rightHighlight:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures")
	button.rightHighlight:SetTexCoord(0.87109375, 0.99609375, 0.15820313, 0.18652344)
	button.rightHighlight:SetSize(64, 29)
	button.rightHighlight:ClearAllPoints()
	button.rightHighlight:SetPoint("RIGHT", 2, -1)
	button.middleHighlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.middleHighlight:SetTexture("Interface/EncounterJournal/UI-EncounterJournalTextures_Tile")
	button.middleHighlight:SetTexCoord(0.00000000, 1.00000000, 0.46484375, 0.52148438)
	button.middleHighlight:SetSize(64, 29)
	button.middleHighlight:ClearAllPoints()
	button.middleHighlight:SetPoint("LEFT", button.leftHighlight, "RIGHT", -32, 0)
	button.middleHighlight:SetPoint("RIGHT", button.rightHighlight, "LEFT", 32, 0)
	-- Expanded state textures (SelectUp)
	button.eLeft = button:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-PaperHeader-SelectUp-Left")
	button.eLeft:ClearAllPoints()
	button.eLeft:SetPoint("LEFT", -1, -1)
	button.eRight = button:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-PaperHeader-SelectUp-Right")
	button.eRight:ClearAllPoints()
	button.eRight:SetPoint("RIGHT", 2, -1)
	button.eMid = button:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-PaperHeader-SelectUp-Mid")
	button.eMid:SetDrawLayer("BACKGROUND", -2)
	button.eMid:ClearAllPoints()
	button.eMid:SetPoint("LEFT", button.eLeft, "RIGHT", -32, 0)
	button.eMid:SetPoint("RIGHT", button.eRight, "LEFT", 32, 0)

	-- Collapsed state textures (UnSelectUp) - created manually with texcoords
	button.cLeft = button:CreateTexture(nil, "BACKGROUND")
	button.cLeft:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	button.cLeft:SetSize(64, 29)
	button.cLeft:SetTexCoord(0.84960938, 0.97460938, 0.49023438, 0.51855469)
	button.cLeft:ClearAllPoints()
	button.cLeft:SetPoint("LEFT", -1, -1)
	button.cLeft:Hide()
	button.cRight = button:CreateTexture(nil, "BACKGROUND")
	button.cRight:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	button.cRight:SetSize(64, 29)
	button.cRight:SetTexCoord(0.72656250, 0.85156250, 0.52441406, 0.55273438)
	button.cRight:ClearAllPoints()
	button.cRight:SetPoint("RIGHT", 2, -1)
	button.cRight:Hide()
	button.cMid = button:CreateTexture(nil, "BACKGROUND")
	button.cMid:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures_Tile", "REPEAT", "REPEAT")
	button.cMid:SetSize(64, 29)
	button.cMid:SetTexCoord(0.0, 1.0, 0.34375000, 0.40039063)
	button.cMid:SetHorizTile(true)
	button.cMid:SetDrawLayer("BACKGROUND", -2)
	button.cMid:ClearAllPoints()
	button.cMid:SetPoint("LEFT", button.eLeft, "RIGHT", -32, 0)
	button.cMid:SetPoint("RIGHT", button.eRight, "LEFT", 32, 0)
	button.cMid:Hide()

	-- Initialize expanded state
	frame.isExpanded = true

	-- Add click handler to toggle expand/collapse
	button:SetScript("OnClick", function(self)
		local parentFrame = self:GetParent()
		parentFrame.isExpanded = not parentFrame.isExpanded
		CollapsibleSectionWidgetTypeMixin:UpdateExpandedState(parentFrame)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	--frame.text = frame:CreateFontString(nil, "ARTWORK", "GameFontBlack")
	--frame.text:SetJustifyH("LEFT")
	--frame.text:SetPoint("TOPLEFT", 2, -8)
	--frame.text:SetPoint("RIGHT", -12, -8)
	--frame.text:SetTextColor(0.25, 0.1484375, 0.02, 1)
	--frame.text:SetWordWrap(true)
	return frame
end

function CollapsibleSectionWidgetTypeMixin:SetContents(widget, contents, bulleted)
	self:SetAnchors(widget)
	--local height = 32
	for idx, contentPart in ipairs(contents) do
		if (type(contentPart) == "string") then
			-- todo: replace tokens and convert into a table
			contentPart = { text = contentPart}
			contents[idx] = contentPart
		end
		local type = Widgets.GetTypeForContent(contentPart)
		if (not type) then
		else
			local child = type:Acquire(widget)
			type:SetContents(child, contentPart, bulleted)
			--height = height + child:GetHeight()
		end
	end
	local height = widget:GetTop() - widget.widgets[#widget.widgets]:GetBottom()
	widget:SetHeight(height)
	widget:Show()
end

-- Override Acquire to reset expanded state when getting widget from pool
function CollapsibleSectionWidgetTypeMixin:Acquire(parent)
	local widget = WidgetTypeMixin.Acquire(self, parent)
	widget.isExpanded = true
	widget.button.expandedIcon:SetText("-")
	return widget
end

-- Update the visual state and height when expanding/collapsing
function CollapsibleSectionWidgetTypeMixin:UpdateExpandedState(widget)
	if widget.isExpanded then
		widget.button.expandedIcon:SetText("-")
		-- Show expanded textures, hide collapsed textures
		widget.button.eLeft:Show()
		widget.button.eMid:Show()
		widget.button.eRight:Show()
		widget.button.cLeft:Hide()
		widget.button.cMid:Hide()
		widget.button.cRight:Hide()
		-- Show children
		for _, child in ipairs(widget.widgets) do
			child:Show()
		end
		-- Recalculate height based on children
		if #widget.widgets > 0 then
			local height = widget:GetTop() - widget.widgets[#widget.widgets]:GetBottom()
			widget:SetHeight(height)
		end
	else
		widget.button.expandedIcon:SetText("+")
		-- Show collapsed textures, hide expanded textures
		widget.button.eLeft:Hide()
		widget.button.eMid:Hide()
		widget.button.eRight:Hide()
		widget.button.cLeft:Show()
		widget.button.cMid:Show()
		widget.button.cRight:Show()
		-- Hide children
		for _, child in ipairs(widget.widgets) do
			child:Hide()
		end
		-- Set height to just the button (24px)
		widget:SetHeight(24)
	end

	-- Trigger parent height recalculation
	CollapsibleSectionWidgetTypeMixin:UpdateParentHeights(widget)
end

-- Cascade height updates to parent widgets
function CollapsibleSectionWidgetTypeMixin:UpdateParentHeights(widget)
	local parent = widget:GetParent()
	if parent and parent.widgets and #parent.widgets > 0 then
		-- Find the last visible widget
		local lastVisible = nil
		for i = #parent.widgets, 1, -1 do
			if parent.widgets[i]:IsShown() then
				lastVisible = parent.widgets[i]
				break
			end
		end

		if lastVisible and parent.type and parent.type.name ~= "Root" then
			local height = parent:GetTop() - lastVisible:GetBottom()
			parent:SetHeight(height)
			-- Recursively update grandparent
			CollapsibleSectionWidgetTypeMixin:UpdateParentHeights(parent)
		end
	end
end