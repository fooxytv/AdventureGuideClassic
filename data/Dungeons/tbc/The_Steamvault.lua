--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "The Steamvault",
	instanceID = 545,
	thumbnail = 608199,
	icon = 136350,
	splash = 608238,
	mapID = 263,
	seasonFilter = "tbc",
	overview = "The Steamvault is the main pumping facility of Coilfang Reservoir, a massive network of underground pipes and chambers built by the naga. Here, enormous pumps work ceaselessly to drain the lakes of Zangarmarsh. The hydromancer Thespia has been corrupted by dark magic while overseeing operations.",
	{
		name = "Hydromancer Thespia",
		defeated = 0,
		encounterID = 17797,
		portrait = 607651,
		loot = {
			{ id = 27740, seasonFilter = "all" },
			{ id = 27741, seasonFilter = "all" },
			{ id = 27738, seasonFilter = "all" },
			{ id = 27742, seasonFilter = "all" },
			{ id = 27743, seasonFilter = "all" },
			{ id = 27806, seasonFilter = "all" },
			{ id = 27804, seasonFilter = "all" },
			{ id = 27805, seasonFilter = "all" }
		},
		sharedLoot = {
			{ id = 27514, seasonFilter = "all" },
			{ id = 27529, seasonFilter = "all" },
			{ id = 27531, seasonFilter = "all" },
			{ id = 27533, seasonFilter = "all" },
			{ id = 27534, seasonFilter = "all" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17797 },
		overview = {
			"Hydromancer Thespia is the first boss of The Steamvault. Once a skilled water mage overseeing the pumping operations, she has been corrupted by dark magic. She wields devastating water and frost abilities while summoning water elementals to aid her in combat. Her mastery over water makes her a dangerous opponent in the flooded chambers of Coilfang Reservoir.",
			{ heading = "Overview" },
			"Thespia uses powerful frost and water-based attacks. Her {spell:38235} hits the entire group for moderate frost damage and should be anticipated by healers. She summons Coilfang Waterelemental adds periodically that need to be controlled. The {spell:31481} ability creates water bolts that damage random party members. Tank positioning near the water's edge allows for easier add management.",
			{
				role = DAMAGE,
				"Focus on Hydromancer Thespia first while the tank maintains aggro on Coilfang Waterelementals.",
				"Switch to kill Coilfang Waterelementals when they become overwhelming or if specified by your group strategy.",
				"Use interrupts on {spell:38236} to reduce healing done to the boss.",
				"Position yourself to minimize movement when avoiding water attacks.",
				"On Heroic difficulty, add spawns are more frequent and {spell:38235} hits significantly harder, requiring defensive cooldowns."
			},
			{
				role = HEALER,
				"Be prepared for party-wide damage from {spell:38235} which hits all group members.",
				"Keep the tank topped off as they will be tanking multiple water elementals.",
				"Manage your mana carefully as this is a longer fight with sustained damage output.",
				"Pre-cast healing spells when you see Thespia begin casting her AoE abilities.",
				"On Heroic difficulty, {spell:38235} requires immediate group healing and possibly healing cooldowns.",
				"Dispel {spell:31486} if possible to reduce the damage over time on affected party members."
			},
			{
				role = TANK,
				"Maintain threat on Hydromancer Thespia while collecting Coilfang Waterelemental adds as they spawn.",
				"Position the adds away from the group to prevent cleave damage.",
				"Use area of effect threat abilities to hold multiple elementals effectively.",
				"Face Thespia away from the party to minimize damage from any frontal abilities.",
				"On Heroic difficulty, defensive cooldowns should be used when tanking multiple adds simultaneously.",
				"Consider positioning near the water to make add collection more efficient."
			}
		},
		abilities = {}
	},
	{
		name = "Mekgineer Steamrigger",
		defeated = 0,
		encounterID = 17796,
		portrait = 607713,
		loot = {
			{ id = 27790, seasonFilter = "all" },
			{ id = 27791, seasonFilter = "all" },
			{ id = 27792, seasonFilter = "all" },
			{ id = 27793, seasonFilter = "all" },
			{ id = 27794, seasonFilter = "all" },
			{ id = 27808, seasonFilter = "all" },
			{ id = 27784, seasonFilter = "all" },
			{ id = 27732, seasonFilter = "all" }
		},
		sharedLoot = {
			{ id = 27514, seasonFilter = "all" },
			{ id = 27529, seasonFilter = "all" },
			{ id = 27531, seasonFilter = "all" },
			{ id = 27533, seasonFilter = "all" },
			{ id = 27534, seasonFilter = "all" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17796, 17951 },
		overview = {
			"Mekgineer Steamrigger is a brilliant but twisted gnome engineer who controls three massive steam ragers in the pumping chamber. This encounter is one of the most mechanically complex in TBC dungeons, requiring careful positioning and add management. Steamrigger himself fights from a distance while his mechanical creations assault the party with devastating attacks.",
			{ heading = "Overview" },
			"This fight revolves around managing three Steamrigger Mechanic adds while dealing with the Mekgineer himself. The mechanics periodically use {spell:35311} which repairs the other mechanics for significant health. Breaking line of sight prevents the repair, making positioning critical. Steamrigger casts {spell:35009} on random party members which deals heavy nature damage. The mechanics also use {spell:35056} which fears nearby players. Kill order is typically: focus on one mechanic at a time while interrupting repairs.",
			{
				role = DAMAGE,
				"Focus fire on one Steamrigger Mechanic at a time to burn it down before repairs can save it.",
				"Interrupt or break line of sight on {spell:35311} casts to prevent mechanics from being healed.",
				"Use crowd control abilities on mechanics not currently being killed if your class has them available.",
				"Watch for {spell:35056} and position yourself to minimize its impact on the group.",
				"Ranged DPS should spread out to minimize {spell:35009} damage to multiple players.",
				"On Heroic difficulty, mechanics hit much harder and {spell:35009} can one-shot undergeared players. Defensive cooldowns are essential."
			},
			{
				role = HEALER,
				"Be ready for heavy burst damage from {spell:35009} on random party members.",
				"Tank will take sustained damage from one or more mechanics throughout the fight.",
				"Top priority is keeping targets of {spell:35009} alive through the burst damage.",
				"Manage mana carefully as this is a long fight with consistent damage output.",
				"Position yourself where you can heal all party members while being able to move if targeted by abilities.",
				"On Heroic difficulty, {spell:35009} requires immediate response and possibly healing cooldowns.",
				"Fear effects from {spell:35056} can disrupt healing, so position accordingly."
			},
			{
				role = TANK,
				"Tank one or two Steamrigger Mechanics away from Mekgineer Steamrigger to prevent repair line of sight.",
				"Position mechanics so that DPS can safely attack without pulling additional mobs.",
				"Use pillars and obstacles to break line of sight for {spell:35311} casts.",
				"Pick up and reposition mechanics as they are killed to maintain control of the remaining adds.",
				"Face mechanics away from the party to minimize cleave or frontal cone damage.",
				"On Heroic difficulty, mechanics deal significantly more damage. Use defensive cooldowns when tanking multiple mechanics.",
				"Be prepared to move mechanics quickly if repairs are going through despite positioning."
			}
		},
		abilities = {}
	},
	{
		name = "Warlord Kalithresh",
		defeated = 0,
		encounterID = 17798,
		portrait = 607815,
		loot = {
			{ id = 27795, seasonFilter = "all" },
			{ id = 27796, seasonFilter = "all" },
			{ id = 27797, seasonFilter = "all" },
			{ id = 27798, seasonFilter = "all" },
			{ id = 27799, seasonFilter = "all" },
			{ id = 27800, seasonFilter = "all" },
			{ id = 27801, seasonFilter = "all" },
			{ id = 27683, seasonFilter = "all" },
			{ id = 27807, seasonFilter = "all" }
		},
		sharedLoot = {
			{ id = 27514, seasonFilter = "all" },
			{ id = 27529, seasonFilter = "all" },
			{ id = 27531, seasonFilter = "all" },
			{ id = 27533, seasonFilter = "all" },
			{ id = 27534, seasonFilter = "all" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17798, 17917 },
		overview = {
			"Warlord Kalithresh is the final boss of The Steamvault and the naga commander overseeing Coilfang's pumping operations. This powerful warrior wields both physical might and water magic. His command over the reservoir's power makes him a formidable opponent, especially when he channels the waters to protect himself and devastate his enemies.",
			{ heading = "Overview" },
			"Kalithresh is a two-phase encounter with distinct mechanics. In Phase 1, he fights normally while periodically summoning Naga Distiller adds that channel beams at him with {spell:31534} which must be killed quickly or they will heal him. He casts {spell:35963} which deals moderate frost damage to random players. At 25% health, Phase 2 begins where Kalithresh channels {spell:31534}, creating a damage reflection shield that must be burned through quickly. The {spell:38166} ability deals heavy nature damage to nearby players. Interrupt his {spell:31481} casts when possible.",
			{
				role = DAMAGE,
				"Phase 1: Focus on killing Naga Distiller adds immediately when they spawn to prevent boss healing.",
				"Return focus to Warlord Kalithresh after adds are dead.",
				"Spread out to minimize {spell:35963} hitting multiple players if they are stacked.",
				"Interrupt {spell:31481} casts to reduce damage to the tank.",
				"Phase 2 at 25%: Burn through the {spell:31534} shield with maximum DPS. Use all cooldowns.",
				"Melee DPS should be aware of {spell:38166} and move away when necessary.",
				"On Heroic difficulty, Phase 2 reflection shield is much stronger and requires coordinated burst. {spell:35963} hits significantly harder."
			},
			{
				role = HEALER,
				"Phase 1: Keep the tank topped off as Kalithresh hits hard in melee.",
				"Be ready to heal party members hit by {spell:35963}.",
				"Quickly kill or have DPS kill the Naga Distiller adds to prevent massive healing on the boss.",
				"Manage mana carefully for the burn phase at 25%.",
				"Phase 2: Tank takes heavy damage during the shield phase. Use major healing cooldowns.",
				"On Heroic difficulty, {spell:35963} can one-shot players. Keep everyone topped off at all times.",
				"The reflection shield during {spell:31534} means healing must be even more intense as DPS will take reflected damage.",
				"{spell:38166} deals heavy AoE damage to the melee group in Heroic."
			},
			{
				role = TANK,
				"Phase 1: Maintain solid threat on Warlord Kalithresh and pick up Naga Distiller adds when they spawn.",
				"Tank the adds away from Kalithresh to prevent them from channeling beams at him.",
				"Position Kalithresh away from the party to minimize cleave or AoE damage.",
				"Face the boss away from your party members.",
				"Phase 2 at 25%: Use all defensive cooldowns during {spell:31534} as damage intake will spike dramatically.",
				"On Heroic difficulty, defensive cooldowns are essential for survival in Phase 2.",
				"Be mobile enough to pick up adds quickly but stable enough to keep the boss in position.",
				"Position to minimize {spell:38166} hitting the entire party."
			}
		},
		abilities = {}
	}
})
