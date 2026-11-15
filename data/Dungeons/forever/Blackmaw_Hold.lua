--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Blackmaw Hold",
	icon = 527422,
	splash = 527422,
	mapID = 2974,
	seasonFilter = "forever",
	overview = "Behind the sealed furbolg gates of northern Azshara lies the city of the Blackmaw, a clan apart from the Timbermaw of the forests to the west. A corruption has taken root in its depths, satyrs of the Legashi now contest the tunnels, and demons walk the halls the furbolg built. The deepest passages run on towards the Barrow Deeps.",
	{
		name = "Withermaw",
		defeated = 0,
		encounterID = 3315,
		portrait = 521744,
		loot = {
			{ id = 249697, filter = "forever" }, -- Claws of the Great Bear
			{ id = 280062, filter = "forever" }, -- Cloak of the Fleshborer
			{ id = 280063, filter = "forever" }, -- Bloodfur Bulwark
			{ id = 280064, filter = "forever" }, -- Withering Grips
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 247195 },
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
	{
		name = "Impaan the Imprisoner",
		defeated = 0,
		encounterID = 3316,
		portrait = 521744,
		loot = {
			{ id = 280056, filter = "forever" }, -- Flameslash Crescent
			{ id = 280057, filter = "forever" }, -- Robes of Dark Summons
			{ id = 280058, filter = "forever" }, -- Impish Chain Hood
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 247206 },
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
	{
		name = "Elder Shaman Bloodmane",
		defeated = 0,
		encounterID = 3327,
		portrait = 521744,
		loot = {
			{ id = 276893, filter = "forever" }, -- Blackmaw Ritual Totem
			{ id = 280068, filter = "forever" }, -- Bloody Claws of Attack
			{ id = 280069, filter = "forever" }, -- Shamanic Wristguards
			{ id = 280070, filter = "forever" }, -- Veilpiercer Girdle
			{ id = 286415, filter = "forever" }, -- Reliquary of Tyr
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 247209 },
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
	{
		name = "Bonesnout the Unbroken",
		defeated = 0,
		encounterID = 3322,
		portrait = 521744,
		loot = {
			{ id = 249696, filter = "forever" }, -- Tusks of the Unbroken
			{ id = 280059, filter = "forever" }, -- Tuskblade Halberd
			{ id = 280060, filter = "forever" }, -- Lucky Shovelnose Tuft
			{ id = 280061, filter = "forever" }, -- Spike Crested Bracers
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 247198 },
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
	{
		name = "Varrox Bleakhoof",
		defeated = 0,
		encounterID = 3334,
		portrait = 521744,
		loot = {
			{ id = 249692, filter = "forever" }, -- Head of Varrox Bleakhoof
			{ id = 272027, filter = "forever" }, -- Mark of Xavius
			{ id = 280074, filter = "forever" }, -- Scalding Flamehoof
			{ id = 280075, filter = "forever" }, -- Bleak Eye Shoulderplates
			{ id = 280076, filter = "forever" }, -- Horns of Varrox
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 247234 },
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
	{
		name = "Blackmaw Behemoth",
		defeated = 0,
		encounterID = 3323,
		portrait = 521744,
		loot = {
			{ id = 280065, filter = "forever" }, -- Behemoth Bones
			{ id = 280066, filter = "forever" }, -- Trousers of the Ebon Giant
			{ id = 280067, filter = "forever" }, -- Blackmaw Chain Belt
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 247207 },
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
	{
		name = "Unbound Spirit",
		defeated = 0,
		encounterID = 3336,
		portrait = 521744,
		loot = {
			{ id = 280071, filter = "forever" }, -- Flamebreak Talisman
			{ id = 280072, filter = "forever" }, -- Cowl of Dark Ambition
			{ id = 280073, filter = "forever" }, -- Burnished Pridescales
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 247231 },
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
})
