--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "The Shaper's Terrace",
	icon = 527422,
	splash = 527422,
	mapID = 3001,
	seasonFilter = "forever",
	overview = "High in the northern hills of Un'Goro, above Marshal's Refuge, the titans left a workshop where new life was shaped and studied. Its keepers are long gone, and the beasts it bred now roam the terraces and tar pits freely, while the consoles that drive the place still answer to anyone carrying the crater's power crystals.",
	{
		name = "Titanosaur",
		defeated = 0,
		encounterID = 3498,
		portrait = 521744,
		loot = {
			{ id = 280009, filter = "forever" }, -- Titanosaur Scale Pendant
			{ id = 280010, filter = "forever" }, -- Gargantuan Wristguards
			{ id = 280011, filter = "forever" }, -- Deeproar Cord
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 253201 },
		overview = {
			"A towering saurian grazing just inside the entrance, grown far past anything the crater outside produces.",
			{ heading = "Overview" },
			"The Titanosaur sweeps its tail at anyone behind it and lets out a roar that sends the party running. Keep everyone off its back end and have a way to break or shrug off the fear ready.",
			{
				role = DAMAGE,
				"Attack from the flanks, never from behind, so the tail sweep does not throw you into the rest of the room.",
			},
			{
				role = HEALER,
				"Expect the fear to scatter the group; keep the tank topped up while they are running.",
			},
			{
				role = TANK,
				"Hold it facing away from the party and stay ready to pick it back up after a fear.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Ravasaur Hunters",
		defeated = 0,
		encounterID = 3499,
		portrait = 521744,
		loot = {
			{ id = 280012, filter = "forever" }, -- Talon of Tor'Rel
			{ id = 280013, filter = "forever" }, -- Frostfang Mail Vest
			{ id = 280014, filter = "forever" }, -- Raptorscale Bulwark
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 253218, 261811 },
		overview = {
			"Izha'Rel and Tor'Rel, a pair of trolls who came up to the terrace to hunt the ravasaurs and have no intention of sharing the ground.",
			{ heading = "Overview" },
			"The two hunters are fought together. Neither is especially tough alone, and both can be crowd controlled, so lock one down and kill the other.",
			{
				role = DAMAGE,
				"Follow a single marked target and leave the controlled hunter alone until the first is dead.",
			},
			{
				role = HEALER,
				"Damage is light while one hunter is controlled; it doubles if the control breaks early.",
			},
			{
				role = TANK,
				"Pick up whichever hunter is not controlled and be ready to grab the second if it breaks free.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Thunderhoof",
		defeated = 0,
		encounterID = 3500,
		portrait = 521744,
		loot = {
			{ id = 280018, filter = "forever" }, -- Hammer of Thundering Hooves
			{ id = 280019, filter = "forever" }, -- Dinofrill Casque
			{ id = 280020, filter = "forever" }, -- Deep Jungle Rifle
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 261812 },
		overview = {
			"A storm-charged beast whose stamping carries the crackle of lightning across the terrace.",
			{ heading = "Overview" },
			"Thunderhoof casts a lightning bolt that can be interrupted and stamps out a thunderclap around itself. Kicking the cast is what keeps the fight under control.",
			{
				role = DAMAGE,
				"Set an interrupt order with a backup, so the lightning cast never goes off because one kick was on cooldown.",
			},
			{
				role = HEALER,
				"Stay out of the thunderclap's reach and heal through whatever lightning casts get past the interrupts.",
			},
			{
				role = TANK,
				"The thunderclap hits everyone close by, so keep the boss turned away from anyone not in melee.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Venomridge",
		defeated = 0,
		encounterID = 3501,
		portrait = 521744,
		loot = {
			{ id = 280015, filter = "forever" }, -- Venomvessel Ring
			{ id = 280016, filter = "forever" }, -- Spiderchitin Wrap
			{ id = 280017, filter = "forever" }, -- Octoclaw Chain Boots
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 261813 },
		overview = {
			"A spined, venomous raptor that has made the terrace its hunting ground.",
			{ heading = "Overview" },
			"Venomridge sprays a volley of poison over the group and stomps the ground around it. Give the tank room, and remove the poison as it lands.",
			{
				role = DAMAGE,
				"Do not crowd the tank; the stomp punishes anyone standing close.",
			},
			{
				role = HEALER,
				"Cure the poison from the volley wherever you can, and a shaman's poison cleansing totem helps.",
			},
			{
				role = TANK,
				"Hold it in open space with the group spread around you rather than stacked on top of you.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Direhorn Matriarch",
		defeated = 0,
		encounterID = 3507,
		portrait = 521744,
		loot = {
			{ id = 280021, filter = "forever" }, -- Tooth of the Matriarch
			{ id = 280022, filter = "forever" }, -- Scaleguard Scimitar
			{ id = 280045, filter = "forever" }, -- Regal Direhorn Drape
			{ id = 285951, filter = "forever" }, -- Direhorn Matriarch's Heart
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 262127 },
		overview = {
			"The head of the terrace's direhorn herd, heavily armoured and quick to defend her ground.",
			{ heading = "Overview" },
			"The Matriarch gores the tank with a bleeding puncture, lashes her tail at anyone behind her and charges at distant players. It is a healing fight more than a positioning one.",
			{
				role = DAMAGE,
				"Stay at her flanks to avoid the tail lash, and expect a charge if you hang back at range.",
			},
			{
				role = HEALER,
				"The bleed on the tank is the main pressure; keep healing it rather than reacting late.",
			},
			{
				role = TANK,
				"Keep her facing away from the group and use cooldowns while the bleed is stacked on you.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Cinder",
		defeated = 0,
		encounterID = 3503,
		portrait = 521744,
		loot = {
			{ id = 280028, filter = "forever" }, -- Heartflame Gauntlets
			{ id = 280029, filter = "forever" }, -- Cinderedge Crescent
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 261974 },
		overview = {
			"A raptor wreathed in flame, released from the terrace's archive when the red console is powered.",
			{ heading = "Overview" },
			"Cinder appears only after the Archival Panel at the red console is fed Red Power Crystals. Clear the area around the panel before using it, as the raptor arrives straight away and deals fire damage.",
			{
				role = DAMAGE,
				"Make sure the space around the Archival Panel is empty before anyone touches it.",
			},
			{
				role = HEALER,
				"Expect steady fire damage across the fight, mostly on the tank.",
			},
			{
				role = TANK,
				"Be at the console when the panel is used so you can pick Cinder up the moment it appears.",
			}
		},
		abilities = {
		}
	},
	{
		name = "King Op",
		defeated = 0,
		encounterID = 3504,
		portrait = 521744,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 261993 },
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
	{
		name = "Snowtalon",
		defeated = 0,
		encounterID = 3597,
		portrait = 521744,
		loot = {
			{ id = 280026, filter = "forever" }, -- Albinofur Grips
			{ id = 280027, filter = "forever" }, -- Crownroar Chestplate
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 262297 },
		overview = {
			"A pale, frost-touched raptor kept behind the waterfall, woken by power fed into the blue console.",
			{ heading = "Overview" },
			"Snowtalon is reached through a cave behind the left-hand waterfall and is called up with Blue Power Crystals. It sprays frost in a cone in front of it and freezes nearby players in place. The large blue crystals in its room silence anyone standing next to them, so fight it away from them.",
			{
				role = DAMAGE,
				"Stay out of the frost cone in front of it and keep clear of the blue crystals.",
			},
			{
				role = HEALER,
				"Keep your distance from the big blue crystals; being silenced beside one stops your healing entirely.",
			},
			{
				role = TANK,
				"Drag Snowtalon away from the crystals and keep its frost cone pointed away from the group.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Bolt",
		defeated = 0,
		encounterID = 3505,
		portrait = 521744,
		loot = {
			{ id = 280031, filter = "forever" }, -- Sparklance Wand
			{ id = 280032, filter = "forever" }, -- Bolt's Charged Eyeball
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 262081 },
		overview = {
			"A raptor crackling with stored lightning, summoned at the yellow console.",
			{ heading = "Overview" },
			"Bolt is called up with Yellow Power Crystals. It throws chain lightning that jumps between players standing close together, and it is immune to Nature damage.",
			{
				role = DAMAGE,
				"Spread out to stop the chain lightning jumping, and switch away from Nature damage if you rely on it.",
			},
			{
				role = HEALER,
				"Chain lightning hits several players at once when the group is bunched; stand apart and heal the spread damage.",
			},
			{
				role = TANK,
				"Hold Bolt where the group can spread around you without standing near each other.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Vitrix",
		defeated = 0,
		encounterID = 3600,
		portrait = 521744,
		loot = {
			{ id = 280027, filter = "forever" }, -- Crownroar Chestplate
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 272561 },
		overview = {
			"A beast bound to the last of the four consoles, most likely the green one.",
			{ heading = "Overview" },
			"Vitrix punishes melee with poison shocks but can be stunned, which gives melee a way to cut down on the damage.",
			{
				role = DAMAGE,
				"Melee take the poison; ranged have an easier time. Use stuns to buy breathing room.",
			},
			{
				role = HEALER,
				"Watch the melee rather than only the tank, and cure poison where you can.",
			},
			{
				role = TANK,
				"Stuns are a free mitigation tool here; ask for them when the damage climbs.",
			}
		},
		abilities = {
		}
	},
	{
		name = "Nanaya",
		defeated = 0,
		encounterID = 3502,
		portrait = 521744,
		loot = {
			{ id = 273128, filter = "forever" }, -- Maker's Spark
			{ id = 280023, filter = "forever" }, -- Nanaya's Control Spire
			{ id = 280024, filter = "forever" }, -- Legplates of Reinforced Crystal
			{ id = 280025, filter = "forever" }, -- Leggings of Curation
			{ id = 272028, filter = "forever" }, -- Freya's Sigil
			{ id = 285952, filter = "forever" }, -- Stone Heart of the Watcher
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 261809 },
		overview = {
			"The giant who keeps the terrace, called down to the Pillar of Assimilation once the four console guardians have fallen.",
			{ heading = "Overview" },
			"Nanaya only appears after the beasts of all four consoles are dead. She takes on a new element each time she loses a quarter of her health, so the damage type changes through the fight, and {spell:1290463} stuns everyone within 15 yards of her.",
			{
				role = DAMAGE,
				"Ranged should stand outside 15 yards so {spell:1290463} only catches melee.",
			},
			{
				role = HEALER,
				"Stay out of slam range, and be ready for a new kind of damage each time she crosses a quarter of her health.",
			},
			{
				role = TANK,
				"You will be stunned by {spell:1290463} regularly; keep defensives up rather than relying on reacting.",
			}
		},
		abilities = {
			{ spell = 1290463 }, -- Powerful Slam
		}
	},
})
