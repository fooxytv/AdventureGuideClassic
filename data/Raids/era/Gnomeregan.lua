--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "Gnomeregan",
	instanceID = 231,
	thumbnail = 608202,
	icon = 136336,
	splash = 608241,
	mapID = 90,
	season = true,
	overview = "Built deep within the mountains of Dun Morogh, the wondrous city of Gnomeregan was a testament to the gnomes' intelligence and industry. But when the capital was invaded by troggs, the gnomish high tinker was betrayed by his advisor Sicco Thermaplugg. As a result, Gnomeregan was irradiated, and most of its inhabitants slain. The surviving gnomes fled, vowing to return someday and retake their home.",
	{
		name = "Grubbis",
		defeated = 0,
		encounterID = 7361,
		portrait = 607628,
		loot = {
			{ id = 19445, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Grubbis is a vile trogg who has taken residence within the irradiated depths of Gnomeregan. He is notorious for his relentless pursuit of discarded technology and his propensity for causing havoc. Grubbis's presence within the irradiated tunnels is a grim reminder of the troggs' intrusion into the once-great gnome city.",
			{ heading = "Overview" },
			"Manage Grubbis and his pet, Chomper, while avoiding {spell:436059} and moving away during {spell:436027}. Throughout the fight, waves of trogg adds will spawn. Keep Grubbis away from poison clouds on the ground to prevent him from gaining a dangerous buff.",
			{
				role = DAMAGE,
				"Focus on Grubbis while managing adds. Melee DPS should attack from the side to avoid {spell:436059}. Exit melee range during {spell:436027}. Kill Chomper's {spell:436100} can be interrupted or dispelled. Both Grubbis and Chomper can be stunned or feared.",
			},
			{
				role = HEALER,
				"Heal through {spell:436027} damage and maintain the tank. Be ready to dispel {spell:436100} from the tank. Watch for spike damage when {spell:436074} is active.",
			},
			{
				role = TANK,
				"Tank Grubbis and Chomper. Position Grubbis away from poison clouds on the ground. If taking too much damage, consider having someone kite Chomper. Face Grubbis away from the raid to prevent {spell:436059} hitting melee DPS.",
			}
		},
		abilities = {
			{ id = 436059, name = "Radiation?", description = "A backwards frontal cone that deals damage and knocks back targets caught in its range. Melee DPS should attack from the side.", tank = true, dps = true },
			{ id = 436027, name = "Grubbis Mad!", description = "Repeatedly slams the ground, dealing AoE physical damage to all raid members regardless of range.", tank = true, healer = true, dps = true },
			{ id = 436074, name = "Trogg Rage", description = "Enrages, increasing attack speed by 50% and movement speed by 100%. Unable to focus on a single enemy.", tank = true, healer = true },
			{ id = 436100, name = "Petrify", description = "Chomper stuns an enemy for 8 seconds while increasing their armor by 30%. Can be dispelled or interrupted.", tank = true, healer = true },
		}
	},
	{
		name = "Viscous Fallout",
		defeated = 0,
		encounterID = 7079,
		portrait = 607808,
		loot = {
			{ id = 9454, seasonFilter = "all" },
			{ id = 9452, seasonFilter = "all" },
			{ id = 9453, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		overview = {
			"Viscous Fallout is a sentient and corrosive ooze that lurks within the depths of Gnomeregan. Its acidic nature and malevolence make it a hazardous inhabitant of the irradiated tunnels. Viscous Fallout's presence within Gnomeregan is a chilling testament to the dangers that have befallen the gnome city.",
			{ heading = "Overview" },
			"Kite Viscous Fallout around the arena to avoid {spell:434434} pools. Prioritize killing Irradiated Goo adds before they transform into Desiccated Fallouts. Interrupt {spell:433546} casts or cleanse the poison DoT immediately. Nature Protection Potions highly recommended.",
			{
				role = DAMAGE,
				"Immediately kill all three {spell:434358} adds within 10 seconds before they transform into Desiccated Fallouts. Interrupt {spell:433546} whenever possible. Stay out of {spell:434434} pools. Ranged DPS stay far from adds to avoid their aura damage.",
			},
			{
				role = HEALER,
				"Be ready to heal through or cleanse {spell:433546} if casts go through. Use Purify or Poison Cleansing Totem to remove the poison DoT. Heal melee DPS taking damage from add auras. Focus on the tank being kited.",
			},
			{
				role = TANK,
				"Continuously kite Viscous Fallout around the arena to prevent melee DPS from standing in {spell:434434} pools. Maintain high threat while moving.",
			}
		},
		abilities = {
			{ id = 434434, name = "Sludge", description = "Spawns a pool of toxic slime beneath the boss that inflicts 150 Nature damage every 1.5 seconds and slows players by 50%.", tank = true, dps = true },
			{ id = 434358, name = "Summon Irradiated Goo", description = "Summons three Irradiated Goo adds that pulse AoE nature damage. If not killed within 10 seconds, they transform into dangerous Desiccated Fallouts.", dps = true, healer = true },
			{ id = 433546, name = "Radiation Burn", description = "A 3-second cast that inflicts a massive poison DoT on the entire raid with stacking damage. Must be interrupted or immediately cleansed.", healer = true, dps = true },
		}
	},
	{
		name = "Electrocutioner 6000",
		defeated = 0,
		encounterID = 6235,
		portrait = 607594,
		loot = {
			{ id = 9447, seasonFilter = "all" },
			{ id = 9446, seasonFilter = "all" },
			{ id = 9448, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		overview = {
			"Electrocutioner 6000 is a formidable mechanical monstrosity designed for the purpose of security and defense within Gnomeregan. Its advanced electrical weaponry and ruthless efficiency have made it a significant obstacle for those seeking to reclaim the city. Electrocutioner 6000's presence within Gnomeregan highlights the advanced technology that once thrived in the gnome city.",
			{ heading = "Overview" },
			"Split ranged DPS into two groups of three who swap positions after being hit by {spell:433251}. Run out of the raid if affected by {spell:433359}. Spread out to minimize {spell:433398} impact.",
			{
				role = DAMAGE,
				"Ranged DPS form two groups of three. After your group is hit by {spell:433251}, swap positions with the other group. If you get {spell:433359}, immediately run away from all raid members to avoid pulling them in. Spread out to reduce {spell:433398} knockback chains.",
			},
			{
				role = HEALER,
				"Focus on healing players with {spell:433251} stacks - damage increases by 500% per stack. Heal raid members affected by {spell:433359}. Top off raid after {spell:433398}.",
			},
			{
				role = TANK,
				"Tank at maximum melee range. Be aware of {spell:433398} knockback and reposition quickly. Maintain threat while the raid handles mechanics.",
			}
		},
		abilities = {
			{ id = 433251, name = "Static Arc", description = "Chain lightning ability that hits 3 targets and applies a 20-second debuff that increases damage from Static Arc by 500%. Requires ranged groups to rotate positions.", dps = true, healer = true },
			{ id = 433359, name = "Magnetic Pulse", description = "Targets a player with a debuff that changes their polarity, causing them to inflict AoE damage and pull in players within 8 yards. Run away from the raid.", dps = true, healer = true },
			{ id = 433398, name = "Discombobulation Protocol", description = "AoE spell that deals damage and knocks players back. Spread out to minimize impact.", tank = true, dps = true, healer = true },
		}
	},
	{
		name = "Crowd Pummeler 9-60",
		defeated = 0,
		encounterID = 6229,
		portrait = 607572,
		loot = {
			{ id = 9449, seasonFilter = "all" },
			{ id = 9450, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		overview = {
			"Crowd Pummeler 9-60 is a remarkable piece of gnomish engineering, designed for the purpose of maintaining order and security within Gnomeregan. Its efficient crowd control abilities and relentless combat prowess have made it a significant challenge for those attempting to reclaim the city. Crowd Pummeler 9-60's presence within Gnomeregan underscores the ingenuity and technology that were once hallmarks of the gnome civilization.",
			{ heading = "Overview" },
			"Dodge {spell:431720} by watching the boss's feet for direction. Avoid {spell:431957} gears moving across the floor. At 30% health, healers focus burst healing on players grabbed by {spell:432062}. Keep boss centrally positioned for maximum maneuvering space.",
			{
				role = DAMAGE,
				"Watch the boss's feet to predict {spell:431720} direction and sidestep. Dodge {spell:431957} as they move linearly across the floor. Below 30% health, use immunities like Ice Block or Divine Shield if targeted by {spell:432062}.",
			},
			{
				role = HEALER,
				"Heal from maximum range to have more time to dodge abilities. Focus intense healing on anyone grabbed by {spell:432062} - they take massive damage and are CC'd for 10 seconds.",
			},
			{
				role = TANK,
				"Tank centrally to give ranged players more space to dodge. Watch the boss's feet to determine {spell:431720} facing direction. Players knocked off the platform will be teleported back and can be battle rezzed.",
			}
		},
		abilities = {
			{ id = 431720, name = "Gnomeregan Smash", description = "Frontal charge that knocks players off the platform if not dodged. Watch the boss's feet (not upper body) to determine facing direction.", tank = true, dps = true, healer = true },
			{ id = 431957, name = "Gear Toss", description = "Throws two gears that move linearly across the floor, knocking back and damaging players on contact.", dps = true, healer = true },
			{ id = 432062, name = "The Claw!", description = "Targets a random player at 30% health, charging and grabbing them for massive damage and 10-second CC. Can be avoided with immunities.", healer = true, dps = true },
		}
	},
	{
		name = "Dark Iron Ambassador",
		defeated = 0,
		encounterID = 6228,
		portrait = I.UIEJBossDarkIronAmbassador,
		loot = {
			{ id = 9456, seasonFilter = "all" },
			{ id = 9457, seasonFilter = "all" },
			{ id = 9455, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		overview = {
			"The Dark Iron Ambassador is an emissary of the Dark Iron dwarves who has established a presence within the depths of Gnomeregan. His diplomatic mission, shrouded in secrecy, hints at the complex interactions between the various factions within the city's depths. The Dark Iron Ambassador's presence within Gnomeregan signifies the intrigue and alliances that have developed in the city's underground.",
			{ heading = "Overview" },
			"This is a rare spawn boss. Interrupt {spell:9053} casts to minimize raid damage. Immediately kill {spell:10870} before they receive buffs. Tank should face the boss away from the raid and be prepared for knockbacks. Stack for AoE healing when needed.",
			{
				role = DAMAGE,
				"Immediately kill {spell:10870} adds before they can be buffed. Interrupt {spell:9053} and any fire-based casts. Be ready to dodge {spell:184} and {spell:2601} damage auras from buffed adds.",
			},
			{
				role = HEALER,
				"Heal from maximum range to avoid fire damage. Be ready to top off the raid after {spell:9053} or {spell:22425}. Focus on tank health during knockback recovery.",
			},
			{
				role = TANK,
				"Tank the Ambassador at distance from the raid to prevent fire damage spread. Pick up {spell:10870} adds quickly. Be prepared for knockback abilities and reposition efficiently.",
			}
		},
		abilities = {
			{ id = 9053, name = "Fireball", description = "Direct fire damage attack. Should be interrupted to minimize raid damage.", dps = true },
			{ id = 22425, name = "Fireball Volley", description = "Inflicts fire damage to nearby enemies in an area.", healer = true, dps = true },
			{ id = 10870, name = "Summon Burning Servant", description = "Summons Burning Servant fire elementals to aid in combat for 4 minutes. Kill immediately before they receive buffs.", dps = true },
			{ id = 184, name = "Fire Shield II", description = "Surrounds an ally with a shield of flame that inflicts 17 fire damage to nearby enemies every 3 seconds.", tank = true, dps = true },
			{ id = 2601, name = "Fire Shield III", description = "Enhanced fire shield dealing 34 fire damage to nearby enemies every 3 seconds.", tank = true, dps = true },
		}
	},
	{
		name = "Mekgineer Thermaplugg",
		defeated = 0,
		encounterID = 7800,
		portrait = 607714,
		loot = {
			{ id = 9458, seasonFilter = "all" },
			{ id = 9459, seasonFilter = "all" },
			{ id = 9461, seasonFilter = "all" },
			{ id = 9492, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		overview = {
			"Mekgineer Thermaplugg is a once-respected gnome engineer who has fallen from grace, seizing control of Gnomeregan's lower levels through a violent coup. His transformation into a cybernetic abomination and his tyrannical rule over the irradiated tunnels have made him a despised figure. Mekgineer Thermaplugg's presence within Gnomeregan symbolizes the tragic descent of a brilliant inventor into madness and tyranny.",
			{ heading = "Overview" },
			"Four-phase encounter with three minibosses (STX-96/FR, STX-97/IC, STX-98/PO) before the final phase (STX-99/XD). Each phase ends at 50% health except the final phase. Ranged DPS must kill bomb adds spawning at six dispensers. Press dispenser buttons when they glow red (30-second cooldown per player or die). Bring two tanks for forced tank swaps in each phase.",
			{
				role = DAMAGE,
				"Ranged DPS prioritize killing bomb adds at dispensers. In Phase 1, avoid fire patches from {spell:219110}. In Phase 2, help with {spell:219111} slows. In Phase 3, interrupt {spell:438732}. Phase 4 combines all mechanics. Press dispenser buttons when glowing red (only once per 30 seconds).",
			},
			{
				role = HEALER,
				"In Phase 1, heal through {spell:438710} stacks and raid damage from {spell:438715}. In Phase 2, dispel {spell:438720} before reaching 10 stacks and heal through {spell:438723}. In Phase 3, heal {spell:438727} debuff damage and remove disease debuffs. Phase 4 requires managing all previous mechanics.",
			},
			{
				role = TANK,
				"Two tanks required. Swap when debuff stacks get high. Face boss away from raid to avoid frontal cone attacks. In Phase 1, manage {spell:438710} stacks. In Phase 2, tank swap before {spell:438720} reaches 10 stacks. In Phase 3, tank swap to manage {spell:438727} stacks. Phase 4 combines all tank swap mechanics.",
			}
		},
		abilities = {
			{ id = 438710, name = "Sprocketfire", description = "Phase 1: Stacking DoT damage applied to the tank. Forces tank swap.", tank = true, healer = true },
			{ id = 438683, name = "Sprocketfire Punch", description = "Phase 1: Applies the Sprocketfire debuff to the tank.", tank = true },
			{ id = 438715, name = "Furnace Surge", description = "Phase 1: Frontal fire breath-like spell. Tank face away from raid.", tank = true, dps = true, healer = true },
			{ id = 219110, name = "Incendiary Bomb", description = "Phase 1: Bomb adds that leave ground fire effects when killed. Avoid fire patches.", dps = true },
			{ id = 438719, name = "Supercooled Smash", description = "Phase 2: Applies Freezing stacks to the tank.", tank = true },
			{ id = 438720, name = "Freezing", description = "Phase 2: Stacking slow that eventually causes Frozen Solid at 10 stacks. Must dispel before 10 stacks.", tank = true, healer = true },
			{ id = 438721, name = "Frozen Solid", description = "Phase 2: Freeze effect applied at 10 Freezing stacks. Forces tank swap.", tank = true },
			{ id = 438723, name = "Coolant Discharge", description = "Phase 2: Raid-wide AoE damage ability.", healer = true, dps = true },
			{ id = 219111, name = "Frost Bomb", description = "Phase 2: Bomb adds that slow players on explosion.", dps = true },
			{ id = 438726, name = "Hazardous Hammer", description = "Phase 3: Applies Radiation Sickness debuff, increasing nature damage taken.", tank = true },
			{ id = 438727, name = "Radiation Sickness", description = "Phase 3: Increases nature damage taken by 50%. Stacks for tank swap mechanic.", tank = true, healer = true },
			{ id = 438732, name = "Toxic Ventilation", description = "Phase 3: Interruptible AoE channel ability. Must interrupt.", dps = true },
			{ id = 219112, name = "Radioactive Bomb", description = "Phase 3: Bomb adds that apply disease debuffs.", dps = true, healer = true },
		}
	}
})
