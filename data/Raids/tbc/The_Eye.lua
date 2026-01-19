--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddRaid({
	name = "The Eye",
	instanceID = 550,
	thumbnail = 608218,
	icon = 136362,
	splash = 608257,
	mapID = 334,
	seasonFilter = "tbc",
	overview = "The Eye, also known as Tempest Keep, is the main fortress of the dimensional ship that once belonged to the naaru. Kael'thas Sunstrider and his blood elves have seized control of this mighty vessel, using its technology to further their alliance with Illidan. At its heart, Kael'thas plots to harness the energies of the fortress for his master's grand design.",
	{
		name = "Al'ar",
		encounterID = 19514,
		portrait = 1385712,
		loot = {
			{ id = 29376, seasonFilter = "tbc" }, -- Talisman of the Sun King
			{ id = 29352, seasonFilter = "tbc" }, -- Nethervoid Cloak
			{ id = 29279, seasonFilter = "tbc" }, -- Phoenix-Ring of Rebirth
			{ id = 29374, seasonFilter = "tbc" }, -- Nether Vortex
			{ id = 29317, seasonFilter = "tbc" }, -- Band of Al'ar
			{ id = 29355, seasonFilter = "tbc" }, -- Helm of the Fell Champion
			{ id = 29356, seasonFilter = "tbc" }, -- Helm of the Vanquished Champion
			{ id = 29359, seasonFilter = "tbc" }  -- Helm of the Vanquished Defender
		},
		sharedLoot = {
			{ id = 30236, seasonFilter = "tbc" }, -- Helm of the Fallen Champion
			{ id = 30237, seasonFilter = "tbc" }, -- Helm of the Fallen Defender
			{ id = 30238, seasonFilter = "tbc" }  -- Helm of the Fallen Hero
		},
		rareLoot = {
			{ id = 32458, seasonFilter = "tbc" }  -- Ashes of Al'ar (Mount)
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 19514 },
		overview = {
			"Al'ar is the legendary phoenix god worshipped by the blood elves, an immortal being of living flame bound to serve Kael'thas. This two-phase encounter begins with Al'ar flying between platforms while spawning ember adds, and transitions into a rebirth phase where the phoenix reforms at the center platform. The room progressively fills with fire patches from dead embers, making positioning increasingly difficult.",
			{ heading = "Overview" },
			"Phase 1: Al'ar flies between 4 platforms. Keep melee in range to prevent {spell:34121} raid wipes. When changing platforms, hide behind pillars to LoS {spell:34229}. Kill {spell:36723} adds but avoid standing near them when they die - they cast {spell:34341}. Phase 2: At 0%, Al'ar casts {spell:34342} and reforms at center with full health. Tanks swap for {spell:35410} stacks. Dodge {spell:35367}. Burn boss while managing {spell:36723} and fire on ground.",
			{
				role = DAMAGE,
				"Phase 1: Kill {spell:36723} adds quickly but move away before they die ({spell:34341} explosion).",
				"Hide behind pillars when Al'ar transitions to avoid {spell:34229} damage.",
				"Avoid standing in {spell:35383} patches left by dead ember adds.",
				"Phase 2: Move away from {spell:35367} dive bomb locations immediately.",
				"Continue killing {spell:36723} adds while maintaining DPS on Al'ar.",
				"Maximize DPS during this phase - it's a burn race as fire fills the room."
			},
			{
				role = HEALER,
				"Phase 1: Heavy tank damage - watch for melee dropping so boss doesn't spam {spell:34121}.",
				"Hide behind pillars during platform transitions or {spell:34229} will kill the raid.",
				"Heal raid members hit by {spell:34341} explosions from dying adds.",
				"Phase 2: Heal through {spell:35367} dive bomb damage split across nearby players.",
				"Phase 2: Tank damage spikes from {spell:35410} armor reduction - requires fast swaps.",
				"Mana conservation is critical - this is a long fight with constant damage."
			},
			{
				role = TANK,
				"Phase 1: Assign 2 tanks to rotate between platforms when Al'ar moves.",
				"CRITICAL: Keep melee range on Al'ar or {spell:34121} will spam the entire raid to death.",
				"Pick up {spell:36723} adds but move away before they die ({spell:34341}).",
				"Phase 2: Taunt swap when {spell:35410} is applied - it reduces armor by 80%.",
				"Phase 2: {spell:35367} spawns two additional {spell:36723} adds to pick up.",
				"Use defensive cooldowns during high {spell:35410} stacks."
			}
		},
		abilities = {}
	},
	{
		name = "Void Reaver",
		encounterID = 19516,
		portrait = 1385772,
		loot = {
			{ id = 29370, seasonFilter = "tbc" }, -- Void Star Talisman
			{ id = 29348, seasonFilter = "tbc" }, -- Fel-Steel Warhelm
			{ id = 29328, seasonFilter = "tbc" }, -- Girdle of Zaetar
			{ id = 29373, seasonFilter = "tbc" }, -- Band of Eternity
			{ id = 30619, seasonFilter = "tbc" }, -- Fel Reaver Piston
			{ id = 29346, seasonFilter = "tbc" }, -- Netherstrike Breastplate
			{ id = 29347, seasonFilter = "tbc" }  -- Translucent Spellthread Necklace
		},
		sharedLoot = {
			{ id = 30240, seasonFilter = "tbc" }, -- Gloves of the Fallen Champion
			{ id = 30241, seasonFilter = "tbc" }, -- Gloves of the Fallen Defender
			{ id = 30239, seasonFilter = "tbc" }  -- Gloves of the Fallen Hero
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 19516 },
		overview = {
			"Void Reaver is a massive arcane construct designed by the naaru, corrupted and repurposed by Kael'thas as a guardian of the Eye. Often called the 'loot reaver' due to its simplicity, this is considered the easiest raid boss in The Burning Crusade. The fight is a straightforward DPS race with minimal mechanics - just tank rotations and healing random arcane orb damage.",
			{ heading = "Overview" },
			"This is the simplest raid boss in TBC - a pure gear check. Tanks rotate for {spell:25778} knockback and threat reduction. {spell:34190} hits random ranged raid members with heavy arcane damage and silence. {spell:34162} channels AoE damage around the boss. Spread out to minimize {spell:34190} splash. DPS races to kill before 10-minute {spell:26662}. No complex mechanics - just execution and gear.",
			{
				role = DAMAGE,
				"Spread out in a loose formation to reduce {spell:34190} splash damage.",
				"This is a pure DPS burn - use all cooldowns and consumables.",
				"Melee DPS: Stay close to the boss but watch for {spell:34162} channeled AoE.",
				"Ranged DPS: Stay at range but spread 20+ yards apart - {spell:34190} silences.",
				"Goal is to kill before the 10-minute {spell:26662} timer.",
				"Focus on personal DPS optimization - there are no add or mechanic interruptions."
			},
			{
				role = HEALER,
				"Heal players targeted by {spell:34190} - it's random and unavoidable arcane damage.",
				"{spell:34190} also silences targets for 6 seconds - be ready to heal silenced healers.",
				"Moderate but consistent tank damage throughout the fight.",
				"Spread out with the raid to avoid taking {spell:34190} splash damage yourself.",
				"Mana should not be an issue if DPS is adequate - fight shouldn't last long.",
				"Keep HoTs on tanks for consistent damage intake from {spell:34162}."
			},
			{
				role = TANK,
				"Use 2-3 tanks rotating for {spell:25778} knockback and threat reduction.",
				"Stay close to the boss after knockback to minimize downtime.",
				"{spell:25778} deals 3-4k physical damage plus knockback - rotate tanks.",
				"Build extra threat when not tanking to prepare for taunt rotations.",
				"Use defensive cooldowns sparingly - damage is moderate and predictable.",
				"This is one of the easiest tank fights in TBC raiding."
			}
		},
		abilities = {}
	},
	{
		name = "High Astromancer Solarian",
		encounterID = 18805,
		portrait = 1385739,
		loot = {
			{ id = 29362, seasonFilter = "tbc" }, -- Solarian's Sapphire Pin
			{ id = 29344, seasonFilter = "tbc" }, -- Robes of the Astromancer
			{ id = 29337, seasonFilter = "tbc" }, -- Boots of the Nexus Warden
			{ id = 29366, seasonFilter = "tbc" }, -- Nether Vortex
			{ id = 29361, seasonFilter = "tbc" }, -- Wristbands of Divine Influence
			{ id = 29345, seasonFilter = "tbc" }, -- Vambraces of Ending
			{ id = 29350, seasonFilter = "tbc" }  -- Torc of the Sethekk Prophet
		},
		sharedLoot = {
			{ id = 30249, seasonFilter = "tbc" }, -- Shoulders of the Fallen Champion
			{ id = 30250, seasonFilter = "tbc" }, -- Shoulders of the Fallen Defender
			{ id = 30248, seasonFilter = "tbc" }  -- Shoulders of the Fallen Hero
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18805, 18806, 18925 },
		overview = {
			"High Astromancer Solarian is Kael'thas's chief astromancer who commands devastating arcane forces. This encounter alternates between boss phases and agent phases, requiring strong AoE damage and precise raid awareness. The fight culminates in a void phase where Solarian transforms and summons adds that must be killed before they reach her.",
			{ heading = "Overview" },
			"Fight alternates between boss phases (100-90%, 70-50%, 30-20%) and agent phases (90-70%, 50-30%). During boss phases, avoid {spell:39414} random missiles and {spell:33009} raid damage. Player marked with {spell:42783} must run away from raid immediately (20+ yards) before explosion. At 20%, she transforms and casts {spell:34322} fear. Focus adds before they reach her.",
			{
				role = DAMAGE,
				"Boss Phases: Burn down the 3 Solarian Agents that spawn, then DPS Solarian.",
				"If marked with {spell:42783}, run 20+ yards away from all raid members immediately.",
				"Avoid {spell:39414} targets - she channels missiles at random raid members.",
				"Agent Phases: Use heavy AoE on the 12 Solarian Agents. Kill Priests first.",
				"Solarian Priests heal - interrupt or kill them quickly.",
				"Void Phase (20%): AoE down all adds. {spell:34322} fears nearby players."
			},
			{
				role = HEALER,
				"If you get {spell:42783}, run away immediately - explodes for 5400-6600 AoE arcane damage.",
				"Players hit by {spell:42783} explosion are also knocked into the air.",
				"{spell:33009} deals 2280-2520 arcane damage to entire raid periodically.",
				"{spell:39414} channels 3 waves of 3000 arcane damage at random targets.",
				"Agent phases have moderate damage - focus on mana conservation.",
				"Void phase: {spell:34322} fears players in melee. {spell:39329} hits tank with shadow damage."
			},
			{
				role = TANK,
				"Main tank on Solarian throughout boss phases.",
				"Off-tanks pick up the 3 Solarian Agents that spawn with the boss.",
				"Interrupt or kill Solarian Priests immediately - they cast Great Heal.",
				"Agent phases: Tank all 12 agents together for AoE (spawns every 50 seconds).",
				"Void phase: Tank Solarian in void form. {spell:39329} deals shadow damage.",
				"Stay spread from raid to avoid {spell:42783} explosions."
			}
		},
		abilities = {}
	},
	{
		name = "Kael'thas Sunstrider",
		encounterID = 19622,
		portrait = 607669,
		loot = {
			{ id = 29992, seasonFilter = "tbc" }, -- Royal Cloak of the Sunstriders
			{ id = 29989, seasonFilter = "tbc" }, -- Sunshower Light Cloak
			{ id = 29990, seasonFilter = "tbc" }, -- Crown of the Sun
			{ id = 29991, seasonFilter = "tbc" }, -- Sunhawk Leggings
			{ id = 29993, seasonFilter = "tbc" }, -- Twinblade of the Phoenix
			{ id = 29994, seasonFilter = "tbc" }, -- The Nexus Key
			{ id = 30018, seasonFilter = "tbc" }  -- Hauberk of the War Bringer
		},
		sharedLoot = {
			{ id = 30245, seasonFilter = "tbc" }, -- Leggings of the Fallen Champion
			{ id = 30246, seasonFilter = "tbc" }, -- Leggings of the Fallen Defender
			{ id = 30247, seasonFilter = "tbc" }  -- Leggings of the Fallen Hero
		},
		rareLoot = {
			{ id = 29434, seasonFilter = "tbc" }  -- Verdant Sphere (Quest Item - Tier 6 Attunement)
		},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 19622, 20063, 20064, 20065, 20066 },
		overview = {
			"Kael'thas Sunstrider, the fallen prince of the blood elves, serves as the final boss of The Eye. This is one of the longest and most complex encounters in The Burning Crusade, featuring five distinct phases over 15-20 minutes. Players must defeat four advisors, collect legendary weapons, survive gravity lapses, and execute perfect coordination throughout.",
			{ heading = "Overview" },
			"Five-phase epic encounter. Phase 1: Kill advisors in order (Thaladred > Telonicus > Capernian > Sanguinar). Phase 2: Damage each advisor to exactly 50%, collect their legendary weapons. Phase 3: Burn Kael'thas, interrupt {spell:36805} and {spell:36819}. Kill Phoenix and Phoenix Eggs. Phase 4: {spell:35966} - collect exactly 3 {spell:35859} orbs for mana. Phase 5: Burn boss, interrupt {spell:36819}, break {spell:36797} mind control, dodge {spell:35873}.",
			{
				role = DAMAGE,
				"Phase 1: Kill advisors in assigned order. Kite Thaladred with ranged.",
				"Phase 2: Damage advisors to exactly 50% - DO NOT KILL. Collect legendary weapons.",
				"Phase 3: Interrupt {spell:36805} and {spell:36819}. Kill Phoenix adds and Phoenix Eggs fast.",
				"Phase 4: During {spell:35966}, touch exactly 3 {spell:35859} orbs for mana. 4+ deals damage.",
				"Phase 5: Maximum DPS burn. Interrupt {spell:36819}. Use weapons on {spell:36797} targets.",
				"Phase 5: Dodge {spell:35873} chain lightning - spreads between nearby players."
			},
			{
				role = HEALER,
				"Phase 1: Spread from raid for Conflagration from Capernian. Heavy tank healing needed.",
				"Phase 2: Moderate healing while DPS brings advisors to 50%. Grab Cosmic Infuser weapon.",
				"Phase 3: {spell:36819} deals 45k-55k fire damage. {spell:36805} hits tank for 25k.",
				"Phase 4: Touch 3 {spell:35859} orbs during {spell:35966}. Grants mana, 4th orb deals damage.",
				"Phase 5: {spell:36819} emergency heals. {spell:35873} bounces between nearby players.",
				"Manage mana carefully - this is a 15-20 minute fight."
			},
			{
				role = TANK,
				"Phase 1: Separate tanks for each advisor. Keep Thaladred away (he fixates ranged).",
				"Phase 2: Hold advisors at 50%. Main tank grabs Infinity Blade weapon.",
				"Phase 3: Tank Kael'thas. {spell:36815} absorbs 80k damage and prevents interrupts.",
				"Phase 3: Pick up Phoenix adds. Kill Phoenix Eggs before they hatch.",
				"Phase 4: No tanking during {spell:35966} - everyone floats and collects orbs.",
				"Phase 5: Heavy damage from {spell:36805}. Use all defensive cooldowns. Break {spell:36797}."
			}
		},
		abilities = {}
	}
})
