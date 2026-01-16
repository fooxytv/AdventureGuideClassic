--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

local widgetType = Mixin({
	name = "Role"
}, CollapsibleSectionWidgetTypeMixin)

-- Map role constants to icon indices in UIEJIcons.png sprite sheet
-- Sprite sheet is 256x64 with 32x32 icons (8 columns, 2 rows)
-- Row 1: Shield(Tank), Sword(Damage), Cross(Healer), Skull, Star, Magic, Lightning, Eye
local roleIconIndex = {
	["TANK"] = 0,      -- Blue shield
	["DAMAGER"] = 1,   -- Sword
	["HEALER"] = 2,    -- Cross/Plus
}

-- Helper to set texture coordinates for a specific icon index
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

	-- Hide all icons first
	for _, iconFrame in ipairs(widget.button.icons) do
		iconFrame:Hide()
	end

	-- Show the appropriate role icon
	-- contents.role is a WoW global constant (TANK, HEALER, DAMAGE/DAMAGER)
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
		local iconFrame = widget.button.icons[1]  -- Use first icon frame
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
