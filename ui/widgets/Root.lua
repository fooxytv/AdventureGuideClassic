--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local widgetType = Mixin({
	name = "Root",
}, WidgetTypeMixin)

function widgetType:Construct(parent)
	local frame = WidgetTypeMixin.ConstructDefault(widgetType, "Frame", nil, parent)

	function frame:SetContents(contents)
		for idx, contentPart in ipairs(contents) do
			if (type(contentPart) == "string") then
				-- todo: replace tokens and convert into a table
				contentPart = { text = contentPart}
				contents[idx] = contentPart
			end
			-- GetTypeForContent returns nothing when no widget type claims the
			-- entry, and this indexed it regardless. A mistyped key in the data
			-- should leave a gap in the panel, not raise a Lua error in the
			-- journal. CollapsibleSectionWidgetTypeMixin already skips these.
			local type = Widgets.GetTypeForContent(contentPart)
			if (type) then
				type:SetContents(type:Acquire(frame), contentPart)
			end
		end
	end
	return frame
end

Widgets.RegisterType(widgetType)
