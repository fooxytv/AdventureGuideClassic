--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Mana-Tombs",
	instanceID = 557,
	thumbnail = 608193,
	icon = 136350,
	splash = 608232,
	mapID = 272,
	seasonFilter = "tbc",
	overview = "The Mana-Tombs are the burial grounds for the exiled Ethereals who were killed during the destruction of Outland. Now the Shadow Council has invaded, using the site to siphon arcane energy from the remains of the fallen ethereals.",
	{
		name = "Pandemonius",
		defeated = 0,
		encounterID = 18341,
		portrait = 607738,
		loot = {
			{ id = 25939, seasonFilter = "tbc" }, -- Voidfire Wand
			{ id = 25940, seasonFilter = "tbc" }, -- Idol of the Claw
			{ id = 25941, seasonFilter = "tbc" }, -- Boots of the Outlander
			{ id = 25942, seasonFilter = "tbc" }, -- Faith Bearer's Gauntlets
			{ id = 25943, seasonFilter = "tbc" }, -- Creepjacker
			{ id = 28166, seasonFilter = "tbc" }, -- Shield of the Void
			{ id = 27813, seasonFilter = "tbc" }, -- Boots of the Colossus (Heroic)
			{ id = 27814, seasonFilter = "tbc" }, -- Twinblade of Mastery (Heroic)
			{ id = 27815, seasonFilter = "tbc" }, -- Totem of the Astral Winds (Heroic)
			{ id = 27816, seasonFilter = "tbc" }, -- Mindrage Pauldrons (Heroic)
			{ id = 27817, seasonFilter = "tbc" }, -- Starbolt Longbow (Heroic)
			{ id = 27818, seasonFilter = "tbc" }  -- Starry Robes of the Crescent (Heroic)
		},
		sharedLoot = {
			{ id = 28558, seasonFilter = "tbc" }, -- Spirit Shard
			{ id = 29434, seasonFilter = "tbc" }, -- Badge of Justice
			{ id = 29460, seasonFilter = "tbc" }  -- Ethereum Prison Key
		},
		rareLoot = {
			{ id = 30583, seasonFilter = "tbc" }, -- Timeless Chrysoprase
			{ id = 30584, seasonFilter = "tbc" }, -- Enscribed Fire Opal
			{ id = 30585, seasonFilter = "tbc" }  -- Glistening Fire Opal
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18341 },
		overview = {
			"Pandemonius is a massive armor-plated void lord and the first boss encountered in the Mana-Tombs. This encounter tests the group's ability to manage shadow damage output and handle spell reflection mechanics. All of Pandemonius's attacks deal shadow damage rather than physical, making shadow resistance valuable for tanks.",
			{ heading = "Overview" },
			"Stop all damage when {spell:32358} is active to avoid reflected spells and melee damage. Ranged damage dealers should stay at maximum range to avoid {spell:32325} knockback. Tanks should position themselves against a wall during {spell:32325} to maintain melee range despite knockback effects.",
			{
				role = TANK,
				"Position Pandemonius against a wall to minimize movement from {spell:32325} knockback.",
				"Use shadow protection potions and buffs as all damage from this boss is shadow-based.",
				"Be aware that melee attacks during {spell:32358} will reflect 750 shadow damage back to you on Normal, 1500 on Heroic.",
				"Maintain threat after each {spell:32325} cast as players may gain threat during the knockback phase."
			},
			{
				role = HEALER,
				"Prepare for heavy tank damage as Pandemonius hits for 650-900 shadow damage per melee on Normal, 3500-5000 on Heroic.",
				"Stop all spell casting when {spell:32358} is active to avoid having spells reflected back.",
				"Use wands during {spell:32358} as wand attacks are not reflected.",
				"Be ready for raid-wide damage from {spell:32325} which deals 1663-2137 shadow damage per tick for 5 seconds on Normal, or 2700-3000 per tick on Heroic."
			},
			{
				role = DAMAGE,
				"Hunters can continue DPS during {spell:32358} as ranged physical attacks are not reflected.",
				"All casters must stop casting and use wands during {spell:32358} to avoid spell reflection.",
				"Melee DPS should cease attacks during {spell:32358} to avoid taking 750 shadow damage per swing on Normal, 1500 on Heroic.",
				"Stay at maximum range if ranged to avoid unnecessary damage from {spell:32325}.",
				"Ranged DPS can outrange the {spell:32325} knockback effect entirely at 40+ yards."
			}
		},
		abilities = {
			{ spell = 32325, heroicSpell = 38760 }, -- Void Blast
			{ spell = 32358, heroicSpell = 38759 }  -- Dark Shell
		}
	},
	{
		name = "Tavarok",
		defeated = 0,
		encounterID = 18343,
		portrait = 607782,
		loot = {
			{ id = 25944, seasonFilter = "tbc" }, -- Shaarde the Greater
			{ id = 25950, seasonFilter = "tbc" }, -- Staff of Polarities
			{ id = 25952, seasonFilter = "tbc" }, -- Scimitar of the Nexus-Stalkers
			{ id = 25945, seasonFilter = "tbc" }, -- Cloak of Revival
			{ id = 25946, seasonFilter = "tbc" }, -- Nethershade Boots
			{ id = 25947, seasonFilter = "tbc" }, -- Lightning-Rod Pauldrons
			{ id = 27821, seasonFilter = "tbc" }, -- Extravagant Boots of Malice (Heroic)
			{ id = 27822, seasonFilter = "tbc" }, -- Crystal Band of Valor (Heroic)
			{ id = 27823, seasonFilter = "tbc" }, -- Shard Encrusted Breastplate (Heroic)
			{ id = 27824, seasonFilter = "tbc" }, -- Robe of the Great Dark Beyond (Heroic)
			{ id = 27825, seasonFilter = "tbc" }, -- Predatory Gloves (Heroic)
			{ id = 27826, seasonFilter = "tbc" }  -- Mantle of the Sea Wolf (Heroic)
		},
		sharedLoot = {
			{ id = 28558, seasonFilter = "tbc" }, -- Spirit Shard
			{ id = 29434, seasonFilter = "tbc" }, -- Badge of Justice
			{ id = 22447, seasonFilter = "tbc" }  -- Lesser Planar Essence
		},
		rareLoot = {
			{ id = 30583, seasonFilter = "tbc" }, -- Timeless Chrysoprase
			{ id = 30584, seasonFilter = "tbc" }, -- Enscribed Fire Opal
			{ id = 30585, seasonFilter = "tbc" }  -- Glistening Fire Opal
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18343 },
		overview = {
			"Tavarok is a massive colossus who serves as the second boss in the Mana-Tombs. This encounter emphasizes positioning awareness and interrupting deadly mechanics. The fight features periodic stuns, single-target imprisonment, and on Heroic difficulty, a devastating frontal cleave that can deal over 11,000 damage.",
			{ heading = "Overview" },
			"Ranged players should stay at maximum range to avoid {spell:33919} which can be outranged beyond 35 yards. Be ready to quickly heal players trapped in {spell:32361}. On Heroic difficulty, melee must attack from behind to avoid the lethal {spell:38761} frontal cone attack.",
			{
				role = TANK,
				"Tank Tavarok facing away from the group to protect melee DPS from {spell:8374} on Normal or {spell:38761} on Heroic.",
				"Position the boss so ranged players can move beyond 35 yards to completely avoid {spell:33919}.",
				"Be prepared for {spell:33919} stuns every 6 seconds which deal 919-1181 damage per tick for 3 seconds on Normal, or 1456 damage per tick on Heroic.",
				"You cannot avoid {spell:32361} when targeted, but healers should be ready to compensate for the 10% max health damage per second."
			},
			{
				role = HEALER,
				"Priority healing on players affected by {spell:32361} as it deals 10% of maximum health per second for 5 seconds.",
				"Prepare for {spell:33919} stuns that affect all players within 35 yards every 6 seconds.",
				"Position yourself at maximum range to avoid {spell:33919} while maintaining healing range.",
				"On Heroic, be ready for potential tank one-shots from {spell:38761} if positioning fails."
			},
			{
				role = DAMAGE,
				"Ranged DPS should position at 35+ yards to completely avoid {spell:33919} damage and stuns.",
				"Melee must attack from behind on Heroic to avoid {spell:38761} which can hit for over 11,000 damage.",
				"Mages trapped in {spell:32361} can use {spell:1953} to escape early.",
				"Continue damage on Tavarok during {spell:33919} if you are positioned outside the 35-yard range.",
				"Watch threat during stun phases as the tank cannot generate threat while stunned by {spell:33919}."
			}
		},
		abilities = {
			{ spell = 33919 }, -- Earthquake
			{ spell = 32361 }, -- Crystal Prison
			{ spell = 8374, heroicSpell = 38761 } -- Arcing Smash
		}
	},
	{
		name = "Nexus-Prince Shaffar",
		defeated = 0,
		encounterID = 18344,
		portrait = 607726,
		loot = {
			{ id = 25953, seasonFilter = "tbc" }, -- Ethereal Warp-Bow
			{ id = 25954, seasonFilter = "tbc" }, -- Sigil of Shaffar
			{ id = 25955, seasonFilter = "tbc" }, -- Mask of the Howling Storm
			{ id = 25956, seasonFilter = "tbc" }, -- Nexus-Bracers of Vigor
			{ id = 25957, seasonFilter = "tbc" }, -- Ethereal Boots of the Skystrider
			{ id = 25962, seasonFilter = "tbc" }, -- Longstrider's Loop
			{ id = 28490, seasonFilter = "tbc" }, -- Shaffar's Wrappings
			{ id = 27798, seasonFilter = "tbc" }, -- Gauntlets of Vindication (Heroic)
			{ id = 27827, seasonFilter = "tbc" }, -- Lucid Dream Bracers (Heroic)
			{ id = 27828, seasonFilter = "tbc" }, -- Warp-Scarab Brooch (Heroic)
			{ id = 27829, seasonFilter = "tbc" }, -- Axe of the Nexus-Kings (Heroic)
			{ id = 27831, seasonFilter = "tbc" }, -- Mantle of the Unforgiven (Heroic)
			{ id = 27835, seasonFilter = "tbc" }, -- Stillwater Girdle (Heroic)
			{ id = 27837, seasonFilter = "tbc" }, -- Wastewalker Leggings (Heroic)
			{ id = 27840, seasonFilter = "tbc" }, -- Scepter of Sha'tar (Heroic)
			{ id = 27842, seasonFilter = "tbc" }, -- Grand Scepter of the Nexus-Kings (Heroic)
			{ id = 27843, seasonFilter = "tbc" }, -- Glyph-Lined Sash (Heroic)
			{ id = 27844, seasonFilter = "tbc" }, -- Pauldrons of Swift Retribution (Heroic)
			{ id = 28400, seasonFilter = "tbc" }, -- Warp-Storm Warblade (Heroic)
			{ id = 32082, seasonFilter = "tbc" }, -- The Fel Barrier (Heroic)
			{ id = 29240, seasonFilter = "tbc" }, -- Bands of Negation (Heroic)
			{ id = 29352, seasonFilter = "tbc" }, -- Cobalt Band of Tyrigosa (Heroic)
			{ id = 30535, seasonFilter = "tbc" }, -- Forestwalker Kilt (Heroic)
			{ id = 33835, seasonFilter = "tbc" }  -- Shaffar's Wondrous Amulet (Heroic)
		},
		sharedLoot = {
			{ id = 28558, seasonFilter = "tbc" }, -- Spirit Shard
			{ id = 29434, seasonFilter = "tbc" }  -- Badge of Justice
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18344, 18431 }, -- Nexus-Prince Shaffar, Ethereal Beacon
		overview = {
			"Nexus-Prince Shaffar is the final boss of the Mana-Tombs and leader of a rogue faction of ethereals. This encounter is a DPS race centered around add control, requiring the group to quickly destroy Ethereal Beacons before they spawn dangerous Ethereal Apprentices. The fight combines direct elemental damage from the prince with overwhelming add pressure if beacons are not managed properly.",
			{ heading = "Overview" },
			"The key to this encounter is killing Ethereal Beacons immediately as they spawn approximately every 10 seconds. If beacons are left alive, they will transform into Ethereal Apprentices that cast {spell:32363} and {spell:32364}. Focus all DPS on beacons the moment they appear, then return to damaging Shaffar.",
			{
				role = TANK,
				"Tank Shaffar in the center of the room to allow DPS easy access to beacons that spawn around the perimeter.",
				"Maintain threat on Shaffar throughout the fight, but allow DPS to switch to beacons immediately when they spawn.",
				"Be aware of {spell:34605} which will cause Shaffar to teleport short distances but does not clear threat.",
				"Gather any Ethereal Apprentices that spawn from neglected beacons and tank them with Shaffar.",
				"On Heroic, each beacon has 6,986 HP and must be killed within approximately 10 seconds."
			},
			{
				role = HEALER,
				"Prepare for damage from {spell:32364} which deals 1475-1925 on Heroic and slows movement.",
				"Watch for {spell:32365} which affects all players within 10 yards, dealing frost damage and rooting for 5 seconds.",
				"Help DPS beacons when healing is not critical as this is a DPS race encounter.",
				"If Ethereal Apprentices spawn, they will cast {spell:32363} for 1150-1550 and {spell:32364} for 975-1325 on Heroic.",
				"Position spread out to minimize players affected by {spell:32365}."
			},
			{
				role = DAMAGE,
				"Immediately switch to Ethereal Beacons when they spawn and kill them before they transform into Ethereal Apprentices.",
				"Beacons have approximately 2,600 HP on Normal and 6,986 HP on Heroic.",
				"If beacons transform, Ethereal Apprentices have 8,616 HP on Heroic and must be killed quickly.",
				"Use AoE abilities if multiple Ethereal Apprentices are active, but prioritize new beacons over existing apprentices.",
				"Stay spread at least 10 yards apart to minimize the impact of {spell:32365}.",
				"The fight becomes exponentially harder with each beacon that transforms, making this a strict DPS check."
			}
		},
		abilities = {
			{ spell = 32363 }, -- Fireball
			{ spell = 32364 }, -- Frostbolt
			{ spell = 32365 }, -- Frost Nova
			{ spell = 34605 }  -- Blink
		}
	}
})
