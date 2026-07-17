--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local widgetType = Mixin({
	name = "Role"
}, CollapsibleSectionWidgetTypeMixin)


local roleIconIndex = {
	["TANK"] = 0,
	["DAMAGER"] = 1,
	["HEALER"] = 2,
}

local function SetIconTexCoord(texture, index)
	local iconSize = 32
	local columns = 256 / iconSize  -- 8
	local rows = 64 / iconSize      -- 2
	local l = (index % columns) / columns
	local r = l + (1 / columns)
	local t = math.floor(index / columns) / rows
	local b = t + (1 / rows)
	texture:SetTexCoord(l, r, t, b)
end

function widgetType:IsTypeFor(content)
	return content.role and true or false
end

function widgetType:SetContents(widget, contents)
	widget.button.title:SetText(contents.role)

	for _, iconFrame in ipairs(widget.button.icons) do
		iconFrame:Hide()
	end

	local roleKey = nil
	if contents.role == TANK then
		roleKey = "TANK"
	elseif contents.role == HEALER then
		roleKey = "HEALER"
	elseif contents.role == DAMAGE or contents.role == DAMAGER then
		roleKey = "DAMAGER"
	end

	if roleKey and roleIconIndex[roleKey] then
		local iconIndex = roleIconIndex[roleKey]
		local iconFrame = widget.button.icons[1]
		if iconFrame then
			iconFrame.icon:SetTexture(I.UIEJIcons)
			SetIconTexCoord(iconFrame.icon, iconIndex)
			iconFrame:SetPoint("RIGHT", -5, 0)
			iconFrame:Show()
		end
	end

	CollapsibleSectionWidgetTypeMixin.SetContents(self, widget, contents, true)
end

Widgets.RegisterType(widgetType)
