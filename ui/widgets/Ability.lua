--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

--[[
	A boss ability written in the data as { id, name, description }.

	Spell.lua covers { spell = <id>, <body lines> }, which is the shape the instance
	overviews use. This covers the other shape the encounter data grew: an id, a name
	written out by hand rather than read from the client, and a single description in
	place of body lines.

	Nothing claimed it before. Root.lua calls SetContents on whatever
	Widgets.GetTypeForContent hands back without checking it found anything, so an
	Abilities tab raised an error for every boss recorded this way -- 49 of them.

	The name comes from the data rather than the client because it is authored, and
	because a spell id does not necessarily resolve on the flavour being run: the TBC
	dungeon abilities read cold on Era. The icon can only come from the client, so it
	is simply absent when the lookup fails.
]]

local widgetType = Mixin({
	name = "Ability"
}, CollapsibleSectionWidgetTypeMixin)

function widgetType:IsTypeFor(content)
	-- Deliberately leaves content.spell to Spell.lua, which already renders it
	-- wherever it appears today.
	if (content.spell) then return false end
	return (content.id and (content.name or content.description)) and true or false
end

function widgetType:SetContents(widget, contents)
	local clientName, icon = Compat.GetSpellInfo(contents.id)
	widget.button.title:SetText(contents.name or clientName or tostring(contents.id))
	CollapsibleSectionWidgetTypeMixin.SetAbilityIcon(self, widget, icon)

	--[[
		The mixin takes its children from the array part, and this shape has none --
		the body is one description string. Hand it a throwaway list rather than
		writing into the data table, which is shared and walked again on every redraw.
	]]
	local body = contents
	if (contents.description) then
		body = { contents.description }
	end
	CollapsibleSectionWidgetTypeMixin.SetContents(self, widget, body)
end

Widgets.RegisterType(widgetType)
