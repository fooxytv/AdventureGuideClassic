--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

SpellsByLevelService = {}

local spellsByClass = {}

function SpellsByLevelService.Register(class, spellsByLevel)
	spellsByClass[class] = spellsByLevel
end

function SpellsByLevelService.GetNewSpells(level, class, faction)
	class = class or select(2, UnitClass("player"))
	faction = faction or UnitFactionGroup("player")

	local byLevel = spellsByClass[class]
	if not byLevel then return {} end
	local atLevel = byLevel[level]
	if not atLevel then return {} end

	local result = {}
	for _, spell in ipairs(atLevel) do
		if spell.requiredTalentId == nil and
			(spell.faction == nil or spell.faction == faction) then
			table.insert(result, spell)
		end
	end
	return result
end
