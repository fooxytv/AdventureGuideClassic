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
	local spellName, icon = Compat.GetSpellInfo(contents.spell)
	widget.button.title:SetText(spellName or tostring(contents.spell))
	CollapsibleSectionWidgetTypeMixin.SetAbilityIcon(self, widget, icon)

	--[[
		Most abilities are recorded as a bare { spell = <id> } and have nothing to
		show when expanded. The client holds the spell's description just as it holds
		its name, so fall back to that rather than authoring 400-odd of them.

		Written body lines win: they are tactical, where the client's text is the
		mechanical tooltip. Build a throwaway list rather than writing into the data
		table, which is shared and walked again on every redraw.
	]]
	local body = contents
	if (#contents == 0) then
		local description = Compat.GetSpellDescription(contents.spell)
		if (description) then
			body = { description }
		else
			-- Not cached yet. The scroller redraws on SPELL_DATA_LOAD_RESULT.
			Compat.RequestSpellData(contents.spell)
		end
	end
	CollapsibleSectionWidgetTypeMixin.SetContents(self, widget, body)
end

Widgets.RegisterType(widgetType)
