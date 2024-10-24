--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local widgetType = Mixin({
	name = "Spell"
}, CollapsibleSectionWidgetTypeMixin)

function widgetType:IsTypeFor(content)
	return content.spell and true or false
end

function widgetType:SetContents(widget, contents)
	local spellName = GetSpellInfo(contents.spell)
	widget.button.title:SetText(spellName)
	CollapsibleSectionWidgetTypeMixin.SetContents(self, widget, contents)
end

Widgets.RegisterType(widgetType)
