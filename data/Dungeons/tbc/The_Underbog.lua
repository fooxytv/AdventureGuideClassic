--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddDungeon({
	name = "The Underbog",
	instanceID = 546,
	thumbnail = 608199,
	icon = 136350,
	splash = 608238,
	mapID = 262,
	seasonFilter = "tbc",
	overview = "The Underbog is a festering marsh beneath Coilfang Reservoir, where the naga's drainage operations have exposed ancient bog creatures to the surface. The once-peaceful marsh has become a breeding ground for aggressive fungi and beasts, all corrupted by the naga's dark influence.",
	{
		name = "Hungarfen",
		defeated = 0,
		encounterID = 17770,
		portrait = 607649,
		loot = {
			{ id = 24387, seasonFilter = "tbc" }, -- Bone Chain Necklace
			{ id = 24388, seasonFilter = "tbc" }, -- Moonglade Cowl
			{ id = 24389, seasonFilter = "tbc" }, -- Gauntlets of Desolation
			{ id = 24390, seasonFilter = "tbc" }, -- Hungarhide Gauntlets
			{ id = 24391, seasonFilter = "tbc" }, -- Manaspark Gloves
			{ id = 27736, seasonFilter = "tbc" }, -- Hangman's Noose (Heroic)
			{ id = 27737, seasonFilter = "tbc" }, -- Starlight Diadem (Heroic)
			{ id = 27738, seasonFilter = "tbc" }, -- Shoulderpads of Assassination (Heroic)
			{ id = 27739, seasonFilter = "tbc" }, -- Spore-Soaked Vaneer (Heroic)
			{ id = 27740, seasonFilter = "tbc" }  -- Band of Frigid Elements (Heroic)
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17770 },
		overview = {
			"Hungarfen is a massive bog giant composed of fungus and plant matter, corrupted by the naga's influence in Coilfang Reservoir. As the first boss of The Underbog, Hungarfen presents a straightforward encounter focused on managing poison damage and dealing with spawning mushroom adds.",
			{ heading = "Overview" },
			"This encounter revolves around managing Hungarfen's spawning Underbog Mushroom adds and avoiding their toxic spore clouds. Hungarfen periodically spawns several mushrooms around the room that must be killed quickly before they release {spell:31673}, a damaging cloud that also buffs Hungarfen. Tank Hungarfen in the center of the room and kill mushroom adds immediately when they spawn. On Heroic difficulty, the encounter has tighter timing requirements and higher damage output, making mushroom control even more critical.",
			{
				role = DAMAGE,
				"Focus on Hungarfen until Underbog Mushrooms spawn, then immediately switch to kill them.",
				"Kill mushrooms before they release {spell:31673} - this cloud damages players and buffs Hungarfen significantly.",
				"Avoid standing in the red spore clouds left by dead mushrooms as they deal heavy Nature damage.",
				"Use AoE abilities to quickly eliminate multiple mushrooms when they spawn in groups.",
				"On Heroic difficulty, mushrooms spawn more frequently and must be killed even faster.",
				"Ranged DPS should maintain maximum range to avoid {spell:31428} damage."
			},
			{
				role = HEALER,
				"Prepare for steady damage from {spell:31429} applied to the tank and melee.",
				"Dispel or cleanse poison effects when possible to reduce healing pressure.",
				"Watch for players standing in {spell:31673} clouds - they need immediate healing.",
				"On Heroic difficulty, {spell:31428} hits harder and may target multiple players.",
				"Manage mana carefully as the fight length depends on how well DPS handles mushroom adds.",
				"Position to avoid mushroom spawn locations while maintaining healing range."
			},
			{
				role = TANK,
				"Tank Hungarfen in the center of the room to allow easy access to mushroom spawns.",
				"Maintain aggro on Hungarfen while DPS switches to kill mushroom adds.",
				"Move out of {spell:31673} spore clouds immediately to avoid taking unnecessary damage.",
				"Use poison resistance if available to mitigate {spell:31429} damage over time.",
				"On Heroic difficulty, defensive cooldowns help survive burst damage from multiple sources.",
				"Keep Hungarfen facing away from the group to prevent melee from taking {spell:31428} damage."
			}
		},
		abilities = {
			{
				id = 31428,
				name = "Foul Spores",
				description = "Hungarfen releases spores in a cone in front of him, dealing Nature damage to all players in the area. On Heroic difficulty ({spell:34168}), damage is significantly increased. Tank should face Hungarfen away from the group."
			},
			{
				id = 31429,
				name = "Spore Cloud",
				description = "Applies a poison effect to nearby players, dealing Nature damage every 3 seconds. Can stack multiple times. Dispellable by poison removal abilities."
			},
			{
				id = 31673,
				name = "Mushroom Spores",
				description = "When Underbog Mushrooms are allowed to mature, they release a cloud of spores that damages all nearby players and increases Hungarfen's size and damage by 20% per cloud. Stack multiple times. Prevent by killing mushrooms quickly."
			},
			{
				id = 0,
				name = "Underbog Mushroom",
				description = "Hungarfen periodically spawns Underbog Mushroom adds around the room. These mushrooms grow larger over time and eventually release {spell:31673} if not killed. Must be eliminated quickly to prevent Hungarfen from becoming overwhelmingly powerful."
			}
		}
	},
	{
		name = "Ghaz'an",
		defeated = 0,
		encounterID = 18105,
		portrait = 607614,
		loot = {
			{ id = 24392, seasonFilter = "tbc" }, -- Mage-Fury Girdle
			{ id = 24393, seasonFilter = "tbc" }, -- Helm of the Claw
			{ id = 24394, seasonFilter = "tbc" }, -- Savage Frog Skin Vest
			{ id = 24395, seasonFilter = "tbc" }, -- Mindfire Waistband
			{ id = 24396, seasonFilter = "tbc" }, -- Vestia's Pauldrons of Inner Grace
			{ id = 27741, seasonFilter = "tbc" }, -- Hydromancer's Headwrap (Heroic)
			{ id = 27742, seasonFilter = "tbc" }, -- Hateful Strike Greaves (Heroic)
			{ id = 27743, seasonFilter = "tbc" }, -- Talisman of Tenacity (Heroic)
			{ id = 27744, seasonFilter = "tbc" }, -- Totem of Spontaneous Regrowth (Heroic)
			{ id = 27745, seasonFilter = "tbc" }  -- Fiend Slayer Boots (Heroic)
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18105 },
		overview = {
			"Ghaz'an is a massive hydra lurking in the murky waters of The Underbog. This beast has adapted to the toxic environment, using acid and poison to overwhelm its prey. The encounter tests your group's ability to manage a soft enrage mechanic through add control.",
			{ heading = "Overview" },
			"Ghaz'an begins underwater and must be lured out by killing nearby adds to draw him to the surface. Once engaged, the fight focuses on managing {spell:34290} which periodically summons Spore Striders adds. These adds don't need to be tanked but should be killed to prevent the fight from becoming overwhelming. Ghaz'an uses {spell:18969} as a frontal cone attack and {spell:31747} which increases his damage output over time. On Heroic difficulty, Ghaz'an hits significantly harder and spawns adds more frequently, making add control essential to prevent a soft enrage situation.",
			{
				role = DAMAGE,
				"Cleave down Spore Strider adds as they spawn - don't let them accumulate.",
				"Focus single-target damage on Ghaz'an while using AoE to manage adds.",
				"Avoid standing in front of Ghaz'an to prevent being hit by {spell:18969}.",
				"Kill adds quickly to prevent being overwhelmed - this is a soft enrage mechanic.",
				"On Heroic difficulty, prioritize add control even more aggressively.",
				"Interrupt or reduce healing on yourself when affected by {spell:31747} if possible."
			},
			{
				role = HEALER,
				"Prepare for increasing healing requirements as {spell:31747} stacks on players.",
				"The longer the fight goes, the more damage the tank takes - manage mana accordingly.",
				"Dispel or cleanse Nature-based debuffs when possible.",
				"On Heroic difficulty, healing throughput requirements are significantly higher.",
				"Watch for multiple Spore Striders targeting cloth wearers and heal accordingly.",
				"Position behind Ghaz'an to avoid {spell:18969} damage."
			},
			{
				role = TANK,
				"Pull Ghaz'an to the surface by killing nearby adds until he emerges.",
				"Tank Ghaz'an with his back to the water, facing away from the group.",
				"Maintain aggro on Ghaz'an while DPS handles Spore Strider adds.",
				"Use defensive cooldowns as {spell:31747} stacks increase your damage taken.",
				"On Heroic difficulty, coordinate major cooldowns with your healers for high stack counts.",
				"Keep Ghaz'an stationary to allow melee to avoid {spell:18969} easily."
			}
		},
		abilities = {
			{
				id = 18969,
				name = "Acid Spit",
				description = "Ghaz'an spits acid in a frontal cone, dealing heavy Nature damage to all players in front of him. On Heroic difficulty ({spell:34268}), damage is significantly increased. Tank should face Ghaz'an away from the group at all times."
			},
			{
				id = 31747,
				name = "Acid Breath",
				description = "Ghaz'an breathes acid on his current target, dealing Nature damage and reducing their armor. Stacks over time, increasing damage taken. Cannot be avoided but can be mitigated with Nature resistance."
			},
			{
				id = 34290,
				name = "Tail Sweep",
				description = "Ghaz'an sweeps his tail in a cone behind him, knocking back players and dealing physical damage. Melee should position on Ghaz'an's sides to avoid this ability."
			},
			{
				id = 0,
				name = "Spore Strider",
				description = "Ghaz'an periodically summons Spore Strider adds throughout the fight. These adds have low health and should be AoE'd down quickly. If too many accumulate, they create a soft enrage situation. On Heroic, they spawn more frequently."
			}
		}
	},
	{
		name = "Swamplord Musel'ek",
		defeated = 0,
		encounterID = 17826,
		portrait = 607779,
		loot = {
			{ id = 24397, seasonFilter = "tbc" }, -- Collar of Edus
			{ id = 24398, seasonFilter = "tbc" }, -- Robe of Hateful Echoes
			{ id = 24399, seasonFilter = "tbc" }, -- Thunderbringer's Guard
			{ id = 24400, seasonFilter = "tbc" }, -- Ironscale War Cloak
			{ id = 24401, seasonFilter = "tbc" }, -- Musel'ek's Throwing Axes
			{ id = 27746, seasonFilter = "tbc" }, -- Creeping Vines (Heroic)
			{ id = 27747, seasonFilter = "tbc" }, -- Earthsoul Britches (Heroic)
			{ id = 27748, seasonFilter = "tbc" }, -- Steam-Hinge Chain of Valor (Heroic)
			{ id = 27749, seasonFilter = "tbc" }, -- Arch-Protector's Band (Heroic)
			{ id = 27750, seasonFilter = "tbc" }  -- Swamplight Lantern (Heroic)
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17826, 17827 },
		overview = {
			"Swamplord Musel'ek is a broken draenei who has fallen under the corruption of the naga. He fights alongside his loyal pet bear, Claw. This encounter is a two-target fight requiring careful management of both Musel'ek and his companion.",
			{ heading = "Overview" },
			"Swamplord Musel'ek is accompanied by his pet bear Claw, making this a two-target encounter similar to a hunter with their pet. Musel'ek uses ranged attacks including {spell:31567} and {spell:34173}, while Claw uses melee attacks and {spell:31429}. The key mechanic is {spell:31623}, where Musel'ek throws a net that roots and silences a player. Musel'ek will also use {spell:31429} periodically. Both Musel'ek and Claw must be defeated to complete the encounter. On Heroic difficulty, damage output is higher and {spell:31623} is cast more frequently, requiring better dispel coordination.",
			{
				role = DAMAGE,
				"Decide on a kill priority: typically kill Claw first to reduce incoming damage.",
				"Alternative strategy: Burn Musel'ek while off-tank holds Claw.",
				"Players affected by {spell:31623} should call out for dispels immediately.",
				"Avoid standing in {spell:34173} which creates a damage zone.",
				"On Heroic difficulty, {spell:31567} hits much harder - interrupt when possible.",
				"Spread out to minimize the impact of {spell:31623} on the raid."
			},
			{
				role = HEALER,
				"Dispel {spell:31623} immediately - the rooted player cannot act until freed.",
				"Both tanks will take steady damage throughout the fight - split healing accordingly.",
				"Watch for {spell:31567} cast damage spikes on random players.",
				"Cleanse or dispel poison effects from {spell:31429} when possible.",
				"On Heroic difficulty, maintain high health pools on all players due to burst damage.",
				"Position to avoid {spell:34173} while maintaining healing range on both tanks."
			},
			{
				role = TANK,
				"Main tank takes Musel'ek, off-tank takes Claw - keep them separated.",
				"Face both mobs away from the group to prevent cleave damage.",
				"If affected by {spell:31623}, call for dispels and trust your healers to keep you alive.",
				"Maintain aggro when DPS switches between targets.",
				"On Heroic difficulty, use defensive cooldowns during high damage moments.",
				"Position Claw away from Musel'ek to allow DPS to focus one target at a time.",
				"Be prepared to pick up whichever target survives if using a burn-one strategy."
			}
		},
		abilities = {
			{
				id = 31567,
				name = "Multi-Shot",
				description = "Swamplord Musel'ek fires arrows at up to 3 nearby enemies, dealing Physical damage to each. On Heroic difficulty ({spell:38370}), damage is significantly increased. Spread out to minimize the number of targets hit."
			},
			{
				id = 31623,
				name = "Throw Freezing Trap",
				description = "Musel'ek throws a freezing trap at a random player, rooting and silencing them for up to 10 seconds. Dispellable - high priority for removal. On Heroic difficulty ({spell:38389}), cast more frequently."
			},
			{
				id = 34173,
				name = "Knock Away",
				description = "Musel'ek knocks back his current target, dealing damage and creating threat. Forces tank to rebuild aggro after each cast."
			},
			{
				id = 31429,
				name = "Bear Bite (Claw)",
				description = "Claw bites his current target, applying a poison effect that deals Nature damage over time. Stacks if not dispelled. Can be removed with poison cleansing abilities."
			},
			{
				id = 31403,
				name = "Maul (Claw)",
				description = "Claw mauls his current target for heavy Physical damage. Standard melee attack that hits harder than normal auto-attacks."
			},
			{
				id = 0,
				name = "Claw (Pet)",
				description = "Swamplord Musel'ek's companion bear. Functions as a separate enemy with his own health pool and abilities. Both Musel'ek and Claw must be defeated to complete the encounter. Can be crowd controlled independently from Musel'ek."
			}
		}
	},
	{
		name = "The Black Stalker",
		defeated = 0,
		encounterID = 17882,
		portrait = 607788,
		loot = {
			{ id = 24402, seasonFilter = "tbc" }, -- Bone Stinger
			{ id = 24403, seasonFilter = "tbc" }, -- Verdant Gloves
			{ id = 24404, seasonFilter = "tbc" }, -- Bone Scale Leggings
			{ id = 24405, seasonFilter = "tbc" }, -- Nightstalker's Wristguards
			{ id = 24406, seasonFilter = "tbc" }, -- Idol of the Emerald Queen
			{ id = 27751, seasonFilter = "tbc" }, -- Doomplate Gauntlets (Heroic)
			{ id = 27752, seasonFilter = "tbc" }, -- Cloak of Healing Rays (Heroic)
			{ id = 27753, seasonFilter = "tbc" }, -- Thoughtblighter Robe (Heroic)
			{ id = 27754, seasonFilter = "tbc" }, -- Umberhowl's Collar (Heroic)
			{ id = 27755, seasonFilter = "tbc" }, -- Incanter's Band (Heroic)
			{ id = 27756, seasonFilter = "tbc" }  -- Crystal Band of Valor (Heroic)
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17882 },
		overview = {
			"The Black Stalker is a massive sporebat that has grown to monstrous proportions feeding on the corrupted ecology of The Underbog. As the final boss of the dungeon, this encounter features unique levitation mechanics and spawning adds that must be managed carefully.",
			{ heading = "Overview" },
			"The Black Stalker levitates all players at the start of combat with {spell:31704}, suspending them in mid-air throughout the entire fight. This prevents players from jumping or using abilities that require being on the ground. The boss periodically spawns Spore Strider adds that must be killed to prevent being overwhelmed. His primary damaging abilities include {spell:31704} which deals damage to all nearby enemies, {spell:31566} which chains between targets, and {spell:31717} which summons add spawns. On Heroic difficulty, The Black Stalker gains {spell:38238} which silences all players in line of sight, making positioning critical.",
			{
				role = DAMAGE,
				"Kill Spore Strider adds as they spawn - don't let them accumulate.",
				"Focus single-target damage on The Black Stalker between add spawns.",
				"Spread out to minimize chain bounces from {spell:31566}.",
				"On Heroic difficulty, break line of sight behind mushrooms before {spell:38238} casts.",
				"Use ranged attacks if possible to maintain damage while moving for mechanics.",
				"Avoid standing too close to other players to prevent {spell:31704} hitting multiple targets."
			},
			{
				role = HEALER,
				"Prepare for constant raid-wide damage from {spell:31704} aura.",
				"Watch for {spell:31566} chain lightning damage on multiple players.",
				"Keep the tank topped off as they take both melee damage and magical damage.",
				"On Heroic difficulty, position behind mushrooms before {spell:38238} to continue casting.",
				"Manage mana carefully as this is a sustained damage fight with add management.",
				"Heal through Spore Strider damage on DPS while they eliminate adds."
			},
			{
				role = TANK,
				"Tank The Black Stalker in the center of the room for optimal raid positioning.",
				"Maintain aggro while DPS switches to kill Spore Strider adds.",
				"Face The Black Stalker away from the group to prevent frontal cone abilities.",
				"On Heroic difficulty, position near mushrooms to break line of sight for {spell:38238}.",
				"Use defensive cooldowns during periods when multiple adds are active.",
				"Keep The Black Stalker stationary to allow ranged to optimize their positioning."
			}
		},
		abilities = {
			{
				id = 31704,
				name = "Levitate",
				description = "The Black Stalker levitates all players at the start of combat, suspending them slightly above the ground. This effect lasts the entire fight and prevents jumping or ground-based movement abilities. Players can still move normally but cannot jump."
			},
			{
				id = 31566,
				name = "Static Charge",
				description = "The Black Stalker strikes a random player with a bolt of electricity that chains to up to 5 nearby targets, dealing Nature damage to each. On Heroic difficulty ({spell:38280}), damage is significantly increased. Spread out to minimize chain bounces."
			},
			{
				id = 31717,
				name = "Summon Spore Strider",
				description = "Periodically summons Spore Strider adds that attack random players. These adds have low health but deal steady damage. Must be killed to prevent being overwhelmed. Spawn rate increases as the fight progresses."
			},
			{
				id = 31715,
				name = "Chain Lightning",
				description = "Hurls a lightning bolt at an enemy, dealing Nature damage and then jumping to additional nearby enemies. Each jump reduces the damage dealt. Similar to {spell:31566} but with different targeting. Spread reduces effectiveness."
			},
			{
				id = 38238,
				name = "Magnetic Pull (Heroic)",
				description = "Heroic difficulty only. The Black Stalker pulls all players to his location and silences them for 5 seconds. Players must break line of sight by hiding behind the large mushrooms in the room before this cast completes to avoid the silence effect."
			},
			{
				id = 0,
				name = "Spore Strider",
				description = "The Black Stalker periodically summons these adds throughout the fight. They have low health but deal steady melee damage to their targets. If allowed to accumulate, they can overwhelm the group. Use AoE abilities to eliminate them quickly."
			}
		}
	}
})
