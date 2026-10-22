--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Excavation Site: Wetlands",
	thumbnail = I.UIEJDungeonButtonExcavationSiteWetlands,
	icon = I.UIEJDungeonPortraitExcavationSiteWetlands,
	splash = 527422,
	mapID = 2998,
	seasonFilter = "forever",
	overview = "A Titan dig site opened up in the Wetlands marshes, and everything living in that country has moved into it -- crocolisks off the lake, raptors along the ridges, spiders in the tall grass, and a Dragonmaw camp working the edges. What the diggers were trying to reach is still sealed, and still guarded.",
	{
		name = "Saltspine",
		defeated = 0,
		encounterID = 3480,
		portrait = 521744,
		loot = {
			{ id = 273022, filter = "forever" }, -- Supple Bellyskin Leggings
			{ id = 273023, filter = "forever" }, -- Saltscale Girdle
			{ id = 273024, filter = "forever" }, -- Glinteye Slippers
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"A crocolisk grown old and enormous on the lake shore, walking the waterline as though the dig had never happened.",
			{ heading = "Overview" },
			"Saltspine patrols the edge of the crocolisk lake, and pulling him with anything else alive nearby is how this fight goes wrong. {spell:1316382} is the mechanic that matters: it cuts the tank's threat generation hard, so the whole group has to hold back rather than open at full speed.",
			{
				role = DAMAGE,
				"Open carefully. {spell:1316382} leaves the tank struggling for threat, so a fast start pulls the boss straight onto the damage dealers.",
			},
			{
				role = HEALER,
				"Nothing targeted to dispel, but a threat swing off {spell:1316382} can put the boss on someone who cannot take {spell:16495}.",
			},
			{
				role = TANK,
				"{spell:1316382} greatly reduces your threat generation -- watch it the whole fight. Pull him clear of the lake shore so none of the surrounding crocolisks come with him.",
			}
		},
		abilities = {
			{ spell = 1316382 }, -- Dust Storm
			{ spell = 16495 }, -- Fatal Bite
			{ spell = 3604 }, -- Tendon Rip
		}
	},
	{
		name = "Shadetooth",
		defeated = 0,
		encounterID = 3481,
		portrait = 521744,
		loot = {
			{ id = 273025, filter = "forever" }, -- Raptorclaw Greaves
			{ id = 273026, filter = "forever" }, -- Garb of Florid Feathers
			{ id = 273027, filter = "forever" }, -- Raptor's Gaze
			{ id = 273106, filter = "forever" }, -- Blueprint: Greenhouse
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"The raptor that owns the pathway, hunting it with a pair of Thicket Hunters at its flanks.",
			{ heading = "Overview" },
			"The danger here is the terrain. {spell:14100} throws people out of the fight and the tall grass around the path hides trash, so a fear with no protection up turns one pull into several. {spell:13445} ticks hard on the tank throughout, and he enrages at twenty per cent.",
			{
				role = DAMAGE,
				"If nobody can cover the fear, clear the trash hidden in the tall grass before pulling. Two Thicket Hunters come with him. Save burst for after {spell:1284435}, or avoid it by killing him before it lands.",
			},
			{
				role = HEALER,
				"{spell:13445} ticks for around 77 physical every three seconds on the tank, and {spell:1284435} at twenty per cent adds thirty per cent attack speed on top of it.",
			},
			{
				role = TANK,
				"{spell:14100} can fear you into the packs hidden in the grass, so bring {spell:8143} or {spell:6346} if you have access to either.",
			}
		},
		abilities = {
			{ spell = 14100 }, -- Terrifying Roar
			{ spell = 13445 }, -- Rend
			{ spell = 1284435 }, -- Enrage
		}
	},
	{
		name = "Highland Horror",
		defeated = 0,
		encounterID = 3644,
		portrait = 521744,
		loot = {
			{ id = 270180, filter = "forever" }, -- Horrible Rootcore
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"An overgrown thing squatting in the marsh with a ring of slimes around it, wanted by the Alliance for a dig-site errand and of no interest to anyone else.",
			{ heading = "Overview" },
			"An Alliance quest boss that drops nothing, so it is an optional stop unless somebody needs the objective. {spell:1316480} pins people in place and {spell:9616} undoes slow damage, which together make a drawn-out fight worse than a short one.",
			{
				role = DAMAGE,
				"Kill it quickly and take the quest item. Do not clip the slimes standing around it on the way in.",
			},
			{
				role = HEALER,
				"{spell:1316480} roots whoever it lands on and keeps damaging them -- they will need healing where they stand.",
			},
			{
				role = TANK,
				"Straightforward to hold. Pull it off the slimes before the group commits.",
			}
		},
		abilities = {
			{ spell = 1316480 }, -- Entangling Roots
			{ spell = 9616 }, -- Wild Regeneration
		}
	},
	{
		name = "Relic Guardian",
		defeated = 0,
		encounterID = 3482,
		portrait = 521744,
		loot = {
			{ id = 273028, filter = "forever" }, -- Reliquary Mantle
			{ id = 273029, filter = "forever" }, -- Golemsight Long Gun
			{ id = 273030, filter = "forever" }, -- Ring of Power Regulation
			{ id = 270865, filter = "forever" }, -- Titan Relic
			{ id = 273097, filter = "forever" }, -- Blueprint: Rock Garden
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"What the excavation was always going to wake: a Titan construct that does not stir until somebody works the control panel beside it.",
			{ heading = "Overview" },
			"The last fight, and a level above the rest of the dungeon, which makes threat genuinely unreliable -- expect misses and dodges. {spell:8374} is a frontal cleave, {spell:11876} knocks back and stuns at range, and {spell:10101} strips threat off whoever it hits. It has to be started from the Titan Control Panel next to it.",
			{
				role = DAMAGE,
				"Ranged should stay well out for {spell:11876}'s knockback and stun. If it gets away from you it can be stunned and slowed -- {spell:5116} or {spell:2484} will kite it.",
			},
			{
				role = HEALER,
				"{spell:8078} slows the attack speed of everyone standing near it, which stretches the fight out. Expect the tank's threat to be shaky at a level disadvantage.",
			},
			{
				role = TANK,
				"Face it away from the group for {spell:8374}. {spell:10101} reduces threat on whoever it lands on, and the level gap means more of your swings miss than usual.",
			}
		},
		abilities = {
			{ spell = 8078 }, -- Thunderclap
			{ spell = 8374 }, -- Arcing Smash
			{ spell = 10101 }, -- Knock Away
			{ spell = 11876 }, -- War Stomp
		}
	},
})
