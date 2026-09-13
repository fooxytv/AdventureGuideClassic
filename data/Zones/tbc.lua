--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

--[[
Levelling zones added by The Burning Crusade: the blood elf and draenei starting
zones, Outland, and the Isle of Quel'Danas.

ZoneService filters these out on an Era client, so they can be registered
unconditionally. See data/Zones/era.lua for the field documentation.
]]

local function Zone(zone)
	zone.expansion = "tbc"
	ZoneService.AddZone(zone)
end

-- Starting zones --------------------------------------------------------------

Zone({
	name = "Eversong Woods", levelRange = { min = 1, max = 10 }, rec = 5,
	faction = "Horde", continent = "Eastern Kingdoms", races = { "BloodElf" },
	overview = "The golden forest around Silvermoon, where blood elves begin.",
})
Zone({
	name = "Azuremyst Isle", levelRange = { min = 1, max = 10 }, rec = 5,
	faction = "Alliance", continent = "Kalimdor", races = { "Draenei" },
	overview = "The crash site of the Exodar, and the draenei starting ground.",
})
Zone({
	name = "Ghostlands", levelRange = { min = 10, max = 20 }, rec = 15,
	faction = "Horde", continent = "Eastern Kingdoms", races = { "BloodElf" },
	overview = "Scourge-scarred woodland south of Eversong, held by the Farstriders.",
})
Zone({
	name = "Bloodmyst Isle", levelRange = { min = 10, max = 20 }, rec = 15,
	faction = "Alliance", continent = "Kalimdor", races = { "Draenei" },
	overview = "Crimson-blighted isle north of Azuremyst, warped by the Exodar's crash.",
})

-- Outland ---------------------------------------------------------------------

Zone({
	name = "Hellfire Peninsula", levelRange = { min = 58, max = 63 }, rec = 60,
	faction = nil, continent = "Outland",
	overview = "The shattered red plain beyond the Dark Portal, and Outland's front door.",
})
Zone({
	name = "Zangarmarsh", levelRange = { min = 60, max = 64 }, rec = 62,
	faction = nil, continent = "Outland",
	overview = "Bioluminescent fungal wetland held by naga and the Cenarion Expedition.",
})
Zone({
	name = "Terokkar Forest", levelRange = { min = 62, max = 65 }, rec = 63,
	faction = nil, continent = "Outland",
	overview = "Bone-strewn woods surrounding Shattrath City and the Auchindoun crypts.",
})
Zone({
	name = "Nagrand", levelRange = { min = 64, max = 67 }, rec = 65,
	faction = nil, continent = "Outland",
	overview = "Floating islands over open orcish savannah, the last unspoiled part of Draenor.",
})
Zone({
	name = "Blade's Edge Mountains", levelRange = { min = 65, max = 68 }, rec = 66,
	faction = nil, continent = "Outland",
	overview = "Jagged ridges impaled with dragon bones, fought over by ogres and gronn.",
})
Zone({
	name = "Netherstorm", levelRange = { min = 67, max = 70 }, rec = 68,
	faction = nil, continent = "Outland",
	overview = "Arcane-torn fragments of Draenor, dominated by Kael'thas's Tempest Keep.",
})
Zone({
	name = "Shadowmoon Valley", levelRange = { min = 67, max = 70 }, rec = 69,
	faction = nil, continent = "Outland",
	overview = "Volcanic waste beneath the Black Temple, where Illidan's forces muster.",
})
Zone({
	name = "Isle of Quel'Danas", levelRange = { min = 70, max = 70 }, rec = 70,
	faction = nil, continent = "Eastern Kingdoms",
	overview = "The Sunwell's island, a max-level daily hub before the Sunwell Plateau.",
})
