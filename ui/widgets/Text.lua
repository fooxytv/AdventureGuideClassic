--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local widgetType = Mixin({
	name = "Text"
}, WidgetTypeMixin)

function widgetType:Construct(parent)
	local frame = WidgetTypeMixin.ConstructDefault(widgetType, "Frame", nil, parent)
	frame:SetSize(1,1)
	frame.bullet = frame:CreateTexture(nil, "ARTWORK", "UI-PaperOverlay-Bullet")
	frame.bullet:ClearAllPoints()
	frame.bullet:SetPoint("TOPLEFT", 2, -8)
	frame.bullet:Hide()
	frame.text = frame:CreateFontString(nil, "ARTWORK", "GameFontBlack")
	frame.text:SetJustifyH("LEFT")
	frame.text:SetPoint("TOPLEFT", 2, -8)
	frame.text:SetPoint("RIGHT", -12, -8)
	frame.text:SetTextColor(0.25, 0.1484375, 0.02, 1)
	frame.text:SetWordWrap(true)
	frame.textBG = frame:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-AbilityTextBG")
	frame.textBG:SetDrawLayer("BACKGROUND", -3)
	frame.textBG:SetSize(12, 12)
	frame.textBG:Hide()
	frame.textBGBottom = frame:CreateTexture(nil, "BACKGROUND", "UI-PaperOverlay-AbilityTextBottomBorder")
	frame.textBGBottom:SetDrawLayer("BACKGROUND", -3)
	frame.textBGBottom:ClearAllPoints()
	frame.textBGBottom:SetPoint("LEFT", frame.textBG, "BOTTOMLEFT")
	frame.textBGBottom:SetPoint("RIGHT", frame.textBG, "BOTTOMRIGHT")
	frame.textBGBottom:Hide()
	return frame
end
function widgetType:IsTypeFor(content)
	return content.text and true or false
end

function widgetType:SetContents(widget, contents, bulleted)
	bulleted = bulleted or false
	local offset = 0
	if (bulleted) then
		offset = 18
	end
	widget.textBG:Hide()
	widget.textBGBottom:Hide()
	if (widget:GetParent().widgetType.name ~= "Root") then
		local bgWidget = widget:GetParent().widgets[1]
		bgWidget.textBG:ClearAllPoints()
		bgWidget.textBG:SetPoint("TOPLEFT", bgWidget.text, "TOPLEFT", -(9+offset), 12)
		bgWidget.textBG:SetPoint("BOTTOMRIGHT", widget.text, "BOTTOMRIGHT", 9, -11)
		bgWidget.textBG:Show()
		bgWidget.textBGBottom:Show()
	end
	widget.text:SetPoint("TOPLEFT", 2 + offset, -8)
	widget.bullet:SetShown(bulleted)
	self:SetAnchors(widget)
	widget.text:SetText(TokenizedTextService.ReplaceTokens(contents.text))
	widget:SetHeight(widget.text:GetStringHeight() + 12)
	widget:Show()
end

Widgets.RegisterType(widgetType)
