--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddDungeon({
	name = "The Botanica",
	instanceID = 553,
	thumbnail = 608218,
	icon = 136350,
	splash = 608257,
	mapID = 266,
	seasonFilter = "tbc",
	overview = "The Botanica is a massive bio-dome satellite of Tempest Keep, where blood elf botanists conduct experiments to create a sustainable food source for their people. High Botanist Freywinn has used these facilities to mutate and weaponize the plant life, creating an army of aggressive botanical creatures.",
	{
		name = "Commander Sarannis",
		defeated = 0,
		encounterID = 17976,
		portrait = 607570,
		loot = {
			{ id = 28304, seasonFilter = "tbc" },
			{ id = 28311, seasonFilter = "tbc" },
			{ id = 28301, seasonFilter = "tbc" },
			{ id = 28306, seasonFilter = "tbc" },
			{ id = 28769, seasonFilter = "tbc" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17976 },
		overview = {
			"Commander Sarannis is a blood elf officer who oversees the Botanica's security forces. She summons waves of Bloodwarder and Sunseeker adds throughout the fight, testing your group's ability to manage multiple targets while maintaining damage on the boss. Her arcane powers and tactical command make her a challenging first encounter in this dungeon.",
			{ heading = "Overview" },
			"Commander Sarannis periodically summons Bloodwarder Protector and Sunseeker Chemist adds during the fight. The key is to control and kill adds quickly while maintaining steady DPS on the boss. She casts {spell:34697} on her current target dealing heavy arcane damage. Use crowd control abilities on adds when available. Tank should maintain threat on the boss while off-tank or DPS picks up adds immediately.",
			{
				role = DAMAGE,
				"Immediately switch to adds when they spawn and burn them down quickly.",
				"Sunseeker Chemist adds should be prioritized as they deal ranged damage.",
				"Use crowd control abilities on adds if your group composition allows it.",
				"Return focus to Commander Sarannis once all adds are dead.",
				"Interrupt {spell:34697} when possible to reduce tank damage.",
				"On Heroic difficulty, adds spawn more frequently and hit much harder."
			},
			{
				role = HEALER,
				"Tank damage increases significantly when adds are active.",
				"Be prepared to heal party members who may be hit by adds before they are controlled.",
				"{spell:34697} deals heavy arcane damage to the tank and requires attention.",
				"Manage your mana carefully as this fight can be lengthy with multiple add waves.",
				"On Heroic difficulty, the increased damage output requires constant attention and efficient healing."
			},
			{
				role = TANK,
				"Maintain solid threat on Commander Sarannis throughout the fight.",
				"Face the boss away from the party to minimize risk.",
				"Be prepared to pick up adds as they spawn or assign an off-tank to handle them.",
				"Use defensive cooldowns when multiple adds are active simultaneously.",
				"Position yourself near spawn points to make add pickup easier."
			}
		},
		abilities = {
			{ id = 34697, name = "Arcane Resonance", description = "Deals heavy arcane damage to the current target.", role = TANK },
			{ id = 34691, name = "Summon Reinforcements", description = "Summons Bloodwarder Protector and Sunseeker Chemist adds to assist in battle.", role = ALL }
		}
	},
	{
		name = "High Botanist Freywinn",
		defeated = 0,
		encounterID = 17975,
		portrait = 607641,
		loot = {
			{ id = 28316, seasonFilter = "tbc" },
			{ id = 28321, seasonFilter = "tbc" },
			{ id = 28317, seasonFilter = "tbc" },
			{ id = 28318, seasonFilter = "tbc" },
			{ id = 23617, seasonFilter = "tbc" },
			{ id = 28315, seasonFilter = "tbc" },
			{ id = 31744, seasonFilter = "tbc" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17975, 19953, 19949, 19920 },
		overview = {
			"High Botanist Freywinn is the mastermind behind the Botanica's twisted experiments. This brilliant but corrupt blood elf botanist surrounds himself with three different types of seedling adds that he summons throughout the encounter. Each type of seedling has unique abilities, from healing Freywinn to exploding on death. Managing these adds while dealing with Freywinn's nature magic is the key to victory.",
			{ heading = "Overview" },
			"Freywinn summons three types of seedlings: Frayer (melee damage), Saplings (heal Freywinn), and Tendril (roots players). The fight revolves around managing these adds efficiently. Frayers should be killed quickly but watch for their explosion on death. Saplings must be interrupted or killed immediately to prevent healing. Tendrils root random players and should be killed to free them. Freywinn casts {spell:34716} dealing heavy nature damage in an AoE around him. Ranged DPS should stay at maximum range while melee carefully manages their positioning.",
			{
				role = DAMAGE,
				"Kill priority: Saplings > Tendrils > Frayers > Freywinn.",
				"Immediately kill or interrupt Saplings to prevent them from healing the boss.",
				"Kill Tendrils to free rooted party members quickly.",
				"Frayers explode on death dealing AoE damage - melee should back away when they are low health.",
				"Maintain damage on Freywinn when no high-priority adds are present.",
				"Ranged DPS should stay at maximum range to avoid {spell:34716}.",
				"On Heroic difficulty, adds spawn more frequently and have significantly more health."
			},
			{
				role = HEALER,
				"Watch for {spell:34716} which deals heavy nature damage in a 15-yard radius around the boss.",
				"Players rooted by Tendrils are vulnerable and may need extra attention.",
				"Frayer explosions deal AoE damage to nearby players when they die.",
				"Nature resistance buffs can help mitigate some damage if available.",
				"Mana management is critical as this is a lengthy fight with sustained damage.",
				"On Heroic difficulty, the damage output is significantly higher requiring constant attention."
			},
			{
				role = TANK,
				"Position Freywinn away from the party to minimize the number of people in range of {spell:34716}.",
				"Be aware that melee DPS will need to move in and out due to plant attacks.",
				"Maintain threat on Freywinn while the party deals with adds.",
				"Use defensive cooldowns during intense add phases.",
				"Tank positioning should facilitate easy access for melee to kill Saplings quickly."
			}
		},
		abilities = {
			{ id = 34716, name = "Plant Attack", description = "Deals nature damage to all enemies within 15 yards.", role = ALL },
			{ id = 34761, name = "Summon Frayer", description = "Summons a Frayer seedling that explodes on death dealing AoE damage.", role = ALL },
			{ id = 34762, name = "Summon Seedling", description = "Summons a Sapling that heals High Botanist Freywinn.", role = ALL },
			{ id = 34763, name = "Summon Tendril", description = "Summons a Tendril that roots a random player in place.", role = ALL }
		}
	},
	{
		name = "Thorngrin the Tender",
		defeated = 0,
		encounterID = 17978,
		portrait = 607794,
		loot = {
			{ id = 28327, seasonFilter = "tbc" },
			{ id = 28325, seasonFilter = "tbc" },
			{ id = 28324, seasonFilter = "tbc" },
			{ id = 24310, seasonFilter = "tbc" },
			{ id = 28323, seasonFilter = "tbc" },
			{ id = 28322, seasonFilter = "tbc" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17978 },
		overview = {
			"Thorngrin the Tender is a massive bog beast who tends to the Botanica's most aggressive plant specimens. This straightforward encounter tests your group's ability to handle heavy melee damage and nature-based area effects. While mechanically simple, Thorngrin hits incredibly hard and his {spell:34670} ability can quickly overwhelm unprepared groups.",
			{ heading = "Overview" },
			"Thorngrin is primarily a tank and spank encounter with two key mechanics to watch. {spell:34670} sends vines that deal nature damage to random party members - spread out to minimize multiple targets being hit. {spell:34661} deals heavy nature damage over time to the current target and should be cleansed when possible. The boss hits very hard in melee, especially on Heroic difficulty. Keep the boss faced away from the party and maintain maximum spread to minimize vine damage.",
			{
				role = DAMAGE,
				"Maintain maximum DPS on Thorngrin throughout the fight.",
				"Spread out at least 10 yards apart to prevent {spell:34670} from hitting multiple players.",
				"No add management is required for this encounter.",
				"Continue DPS while moving to avoid vine effects.",
				"On Heroic difficulty, the increased melee damage may require brief DPS pauses for survival."
			},
			{
				role = HEALER,
				"Tank takes very heavy melee damage throughout the encounter.",
				"Dispel or cleanse {spell:34661} from the tank when possible to reduce damage.",
				"{spell:34670} deals nature damage to random party members - be ready for scattered raid damage.",
				"Nature resistance buffs can help mitigate damage if available.",
				"On Heroic difficulty, tank healing requires full attention and use of major cooldowns.",
				"Keep the entire party topped off as random nature damage can be significant."
			},
			{
				role = TANK,
				"This is a heavy tank damage encounter - use defensive cooldowns liberally.",
				"Position Thorngrin away from the party and keep him faced away to prevent cleaves.",
				"Request dispels for {spell:34661} to reduce incoming damage.",
				"Maintain solid threat as DPS will be going all-out on this simple encounter.",
				"On Heroic difficulty, coordinate major defensive cooldowns with healer cooldowns for survival."
			}
		},
		abilities = {
			{ id = 34670, name = "Hellfire", description = "Sends vines that deal nature damage to random party members.", role = ALL },
			{ id = 34661, name = "Poison", description = "Deals nature damage over time to the current target. Can be dispelled.", role = TANK }
		}
	},
	{
		name = "Laj",
		defeated = 0,
		encounterID = 17980,
		portrait = 607714,
		loot = {
			{ id = 28339, seasonFilter = "tbc" },
			{ id = 28338, seasonFilter = "tbc" },
			{ id = 27739, seasonFilter = "tbc" },
			{ id = 28340, seasonFilter = "tbc" },
			{ id = 28328, seasonFilter = "tbc" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17980, 19905 },
		overview = {
			"Laj is a unique plant creature that surrounds itself with Thorn Lasher adds and teleports around the room. This encounter combines add management with positioning awareness as Laj becomes immune to damage while protected by its Thorn Flayers. Learning to quickly clear the adds and reposition for Laj's teleports is essential for success.",
			{ heading = "Overview" },
			"Laj summons Thorn Lasher adds and periodically becomes immune to damage. When immune, Laj is protected by Thorn Flayers that must be killed to make the boss vulnerable again. {spell:34697} deals heavy arcane damage to Laj's current target. Laj also casts {spell:3242} which deals nature damage over time and can be dispelled. The boss teleports around the room throughout the fight requiring the tank to quickly pick up threat at new locations. Kill all Thorn Lashers and Flayers as they spawn to maintain DPS uptime on the boss.",
			{
				role = DAMAGE,
				"Kill Thorn Lasher adds as they spawn during the fight.",
				"When Laj becomes immune, immediately switch to kill the Thorn Flayer that is protecting him.",
				"Use AoE abilities when multiple Thorn Lashers are present.",
				"Be ready to reposition when Laj teleports to a new location.",
				"Return to full DPS on Laj once he becomes vulnerable again.",
				"On Heroic difficulty, adds have significantly more health and spawn more frequently."
			},
			{
				role = HEALER,
				"Dispel or cleanse {spell:3242} from affected party members to reduce nature damage.",
				"Tank damage increases when multiple Thorn Lashers are active.",
				"Be prepared to reposition quickly when Laj teleports.",
				"Watch for scattered damage on DPS who may pull threat on adds.",
				"On Heroic difficulty, the combination of boss and add damage requires constant attention."
			},
			{
				role = TANK,
				"Maintain threat on Laj while the party kills adds.",
				"When Laj becomes immune, help DPS kill the Thorn Flayer quickly.",
				"Immediately pick up threat on Laj at his new location after each teleport.",
				"Pick up Thorn Lasher adds to prevent them from attacking healers or DPS.",
				"Use defensive cooldowns during periods with multiple active adds."
			}
		},
		abilities = {
			{ id = 34697, name = "Arcane Bolt", description = "Deals heavy arcane damage to the current target.", role = TANK },
			{ id = 3242, name = "Ravage", description = "Deals nature damage over time. Can be dispelled.", role = ALL },
			{ id = 34710, name = "Summon Thorn Lasher", description = "Summons Thorn Lasher adds throughout the fight.", role = ALL },
			{ id = 34702, name = "Allergic Reaction", description = "Becomes immune to damage while protected by Thorn Flayers.", role = ALL }
		}
	},
	{
		name = "Warp Splinter",
		defeated = 0,
		encounterID = 17977,
		portrait = 607816,
		loot = {
			{ id = 24311, seasonFilter = "tbc" },
			{ id = 28370, seasonFilter = "tbc" },
			{ id = 28343, seasonFilter = "tbc" },
			{ id = 28371, seasonFilter = "tbc" },
			{ id = 28229, seasonFilter = "tbc" },
			{ id = 28342, seasonFilter = "tbc" },
			{ id = 28347, seasonFilter = "tbc" },
			{ id = 28348, seasonFilter = "tbc" },
			{ id = 28228, seasonFilter = "tbc" },
			{ id = 28349, seasonFilter = "tbc" },
			{ id = 28350, seasonFilter = "tbc" },
			{ id = 28341, seasonFilter = "tbc" },
			{ id = 28367, seasonFilter = "tbc" },
			{ id = 28345, seasonFilter = "tbc" },
			{ id = 31085, seasonFilter = "tbc" },
			{ id = 29258, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 29262, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 29359, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 32072, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 33859, seasonFilter = "tbc", difficulty = "heroic" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17977, 19920 },
		overview = {
			"Warp Splinter is an ancient treant that has been corrupted and warped by the blood elves' experiments. As the final boss of the Botanica, this massive treant combines heavy damage output with add management and powerful arcane magic. His signature {spell:34716} ability and periodic Treant summons make this an intense encounter that tests all aspects of your group's coordination.",
			{ heading = "Overview" },
			"Warp Splinter periodically summons Sapling adds throughout the fight that must be killed quickly. The key mechanic is {spell:34716} which deals massive arcane damage to random players - this should be interrupted whenever possible. {spell:34741} stomps the ground dealing nature damage to nearby players, forcing melee to briefly move away. At 50% health, Warp Splinter summons multiple Treants that must be AoE'd down quickly. The boss also casts {spell:34670} which immobilizes random players, requiring healer attention. This is a DPS race combined with precise add control.",
			{
				role = DAMAGE,
				"Interrupt {spell:34716} on cooldown - this is the highest priority.",
				"Kill Sapling adds immediately as they spawn to prevent them from healing the boss.",
				"Move out of melee range briefly when {spell:34741} is cast.",
				"At 50% health, use AoE abilities to quickly kill the large wave of Treants.",
				"Ranged DPS should maintain maximum distance while still being able to interrupt.",
				"On Heroic difficulty, add health is much higher and the 50% Treant wave can easily cause a wipe if not handled quickly."
			},
			{
				role = HEALER,
				"Watch for {spell:34670} which immobilizes random players and deals damage.",
				"{spell:34741} deals AoE nature damage to melee range players.",
				"If {spell:34716} is not interrupted, it deals massive damage and may one-shot players.",
				"The 50% Treant spawn creates intense party-wide damage - use major cooldowns.",
				"Nature resistance buffs help mitigate stomp damage if available.",
				"On Heroic difficulty, multiple missed interrupts will likely result in player deaths."
			},
			{
				role = TANK,
				"Position Warp Splinter away from the party to minimize {spell:34741} splash damage.",
				"Maintain threat while party members handle interrupt rotations.",
				"At 50% health, pick up all Treant adds and position them for AoE damage.",
				"Use major defensive cooldowns during the 50% Treant phase.",
				"Be prepared for increased damage when multiple adds are active."
			}
		},
		abilities = {
			{ id = 34716, name = "Arcane Volley", description = "Deals massive arcane damage to random players. Must be interrupted.", role = ALL },
			{ id = 34741, name = "Stomp", description = "Stomps the ground dealing nature damage to all nearby enemies.", role = MELEE },
			{ id = 34670, name = "Entangle", description = "Immobilizes random players with roots.", role = ALL },
			{ id = 34761, name = "Summon Saplings", description = "Summons Sapling adds that heal Warp Splinter.", role = ALL },
			{ id = 34730, name = "Summon Treants", description = "At 50% health, summons a large wave of Treant adds.", role = ALL }
		}
	}
})
