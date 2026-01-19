--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddRaid({
	name = "Blackfathom Deeps",
	instanceID = 227,
	thumbnail = 608195,
	icon = 136325,
	splash = 608234,
	mapID = 48,
	season = true,
	overview = "Once dedicated to the night elves' goddess Elune, Blackfathom Deeps was thought to have been destroyed during the Sundering, lost beneath the ocean. Millennia later, members of the Twilight's Hammer cult were drawn to the temple by whispers and foul dreams. After sacrificing untold numbers of innocents, the cult was rewarded with a new task: to protect one of the Old Gods' most cherished creatures, a pet that is still in need of nurturing before he can unleash his dark powers on the world.",
	{
		name = "Ghamoo-Ra",
		encounterID = 4887,
		portrait = 607613,
		instance = "Blackfathom Deeps",
		loot = {
			{ id = 209436, seasonFilter = "all" },
			{ id = 209830, seasonFilter = "all" },
			{ id = 209418, seasonFilter = "all" },
			{ id = 209824, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Ghamoo-Ra is a massive and ancient turtle residing deep within Blackfathom Deeps. This aquatic behemoth is considered a guardian of the subterranean waters and the creatures that dwell within them. Ghamoo-Ra's immense size and formidable defenses make it a fearsome inhabitant of the underground aquatic realm.",
			{ heading = "Overview" },
			"Ghamoo-Ra is the second boss in Blackfathom Deeps. The fight centers around managing his {spell:414370} invulnerability phase and handling tank swaps due to {spell:407095} stacks.",
			{
				role = DAMAGE,
				"Attack Ghamoo-Ra's {spell:414370} bubble shield with 100 instances of damage to break it. When the shield breaks, it deals massive AoE damage via {spell:407014}. Be ready to heal after each shell break. Focus damage on the boss while managing threat during tank swaps.",
			},
			{
				role = HEALER,
				"Prepare for massive raid-wide damage when {spell:414370} breaks. Tank will take heavy damage from {spell:407077} especially with multiple {spell:407095} stacks. Keep the raid topped up during shell break phases.",
			},
			{
				role = TANK,
				"Tank swap at 2 stacks of {spell:407095} to avoid being one-shot by {spell:407077}. Use defensive cooldowns when you have high armor reduction stacks. Keep moving the boss to avoid areas saturated with water orbs.",
			},
		},
		abilities = {
			{
				spell = 414370,
				icons = { IMPORTANT },
				"A big bubble surrounds Ghamoo-Ra, making him invulnerable to damage until removed by inflicting 100 instances of damage.",
				{
					spell = 407014,
					"Upon the Aqua Shell bursting, deals large area of effect damage to everyone in the raid.",
				},
			},
			{
				spell = 407095,
				icons = { TANK },
				"Applies this debuff to his current target, removing 25% of the target's armor per stack.",
			},
			{
				spell = 407077,
				icons = { TANK },
				"Attacks his current target three times in quick succession for devastating damage.",
			}
		},
	},
	{
		name = "Lady Sarevess",
		encounterID = 4831,
		portrait = 607682,
		loot = {
			{ id = 888, seasonFilter = "all" },
			{ id = 11121, seasonFilter = "all" },
			{ id = 3078, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Lady Sarevess is a naga sorceress who has claimed Blackfathom Deeps as her lair. She is known for her mastery of water-based magic and her allegiance to the naga forces that seek to expand their dominion beneath the waves. Lady Sarevess's control over the aquatic environment and her cunning tactics make her a formidable adversary in the depths.",
			{ heading = "Overview" },
			"Lady Sarevess is the third boss encountered in Blackfathom Deeps, and is accompanied by a Blackfathom Elite. She uses {spell:407653} that chains to nearby players and {spell:407568} to create frost patches on the ground.",
			{
				role = DAMAGE,
				"Spread out to avoid chaining from {spell:407653}. Stay out of {spell:407568} frost patches or you will be frozen for 10 seconds. Focus damage on Lady Sarevess first as the Elite will despawn when she dies. Around 1 minute into the fight, a second Elite spawns requiring off-tank attention.",
			},
			{
				role = HEALER,
				"Spread out to avoid being hit with {spell:407653} chains. Be ready to heal both tanks as a second Elite spawns mid-fight. Maintain healing on the tank while avoiding frost zones.",
			},
			{
				role = TANK,
				"Position the boss away from the group to reduce {spell:407653} chain damage. Off-tank should pick up the Blackfathom Elite. A second Elite will spawn after about 1 minute. Use the frost zones as temporary crowd control for adds if needed.",
			},
		},
		abilities = {
			{
				spell = 407653,
				icons = { IMPORTANT },
				"Strikes her target with nature damage and chains to nearby players, applying the Forked Lightning debuff.",
			},
			{
				spell = 407568,
				icons = { IMPORTANT },
				"Drops a patch of frost on the ground that slows anyone standing in it.",
				{
					spell = 407546,
					"Anyone standing in the frost patch for longer than 5 seconds will be frozen solid for 10 seconds. This affects both enemies and allies.",
				},
			},
			{
				spell = 407819,
				icons = { INTERRUPT },
				"1.5 second cast that targets a random player. Deals Physical damage and applies a slowing debuff.",
			}
		},
	},
	{
		name = "Gelihast",
		encounterID = 6243,
		portrait = 607609,
		loot = {
			{ id = 6906, seasonFilter = "all" },
			{ id = 6905, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Gelihast is a fearsome murloc warrior who has established a stronghold within Blackfathom Deeps. He commands a tribe of murlocs and is known for his ruthless tactics and territorial nature. Gelihast's mastery of close combat and his control over his murloc followers make him a dangerous foe in the depths.",
			{ heading = "Overview" },
			"Gelihast is the fourth boss in Blackfathom Deeps, a complex multi-phase encounter. He applies {spell:412072} to tanks requiring swaps, casts {spell:411990} ground AoE, and at 10% HP runs to heal while spawning {spell:412466}. Bring a class that can remove {spell:411973}.",
			{
				role = DAMAGE,
				"Avoid {spell:411990} shadow pools on the ground. During the 10% HP intermission, dodge the March of Murlocs shadows as they run across the room in straight lines. In the final phase, prioritize killing Blackfathom Tendrils to prevent their Mind Flay casts.",
			},
			{
				role = HEALER,
				"Dispel {spell:411973} and {spell:411959} from affected players. Shadow Protection Potions are useful for surviving murloc phases. Healing increases when the boss has multiple {spell:412072} stacks on the tank.",
			},
			{
				role = TANK,
				"Tank swap at 2 stacks of {spell:412072} as damage escalates significantly beyond 3 stacks. Pull Gelihast to the middle of the room so players can spread out for {spell:411990}. Two tanks are required for this encounter.",
			}
		},
		abilities = {
			{
				spell = 411973,
				icons = { CURSE, DISPEL },
				"Ramping shadow damage curse that must be decursed by a class with curse removal ability.",
			},
			{
				spell = 412072,
				icons = { TANK },
				"Applies this debuff to his current target, increasing shadow damage taken per stack. Tank swap at 2 stacks.",
			},
			{
				spell = 411990,
				icons = { IMPORTANT },
				"Creates a purple reticle on the ground and throws an arcing shadowbolt at it, creating a shadowy pool that deals continuous damage.",
			},
			{
				spell = 411959,
				icons = { DISPEL },
				"Applies a fear to a random target, causing them to flee in fear. Lasts 4 seconds and is dispellable.",
			},
			{
				spell = 412466,
				icons = { IMPORTANT },
				"At 10% HP, Gelihast runs to the altar and summons an army of shadow murlocs that run in straight lines. These deal massive damage and must be avoided.",
			},
			{
				spell = 412528,
				icons = { IMPORTANT },
				"Summons a handful of Blackfathom Tendrils with low HP. They deal melee damage and cast Mind Flay. Kill them immediately.",
			}
		}
	},
	{
		name = "Baron Aquanis",
		encounterID = 12876,
		portrait = 607552,
		loot = {
			{ id = 209574, seasonFilter = "all" },
			{ id = 209825, seasonFilter = "all" },
			{ id = 209423, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Baron Aquanis is a powerful water elemental that has been summoned to Blackfathom Deeps by dark forces. This elemental entity serves as a guardian of the submerged tunnels and channels beneath the depths. Baron Aquanis's control over water magic and his formidable elemental form make him a formidable protector of the underground waters.",
			{ heading = "Overview" },
			"Baron Aquanis is the first boss in Blackfathom Deeps. The fight centers around avoiding {spell:404805} knockbacks, dodging {spell:405953} ground AoE, and avoiding the {spell:405998} beam.",
			{
				role = DAMAGE,
				"Spread out when {spell:405953} is active to avoid unnecessary damage. At 15 seconds, immediately jump in the water when {spell:404805} is cast to prevent knockbacks. At 30 seconds, move behind the boss when {spell:405998} begins channeling as it slowly turns clockwise.",
			},
			{
				role = HEALER,
				"Maintain healing on the tank and raid. Spread to avoid overlapping {spell:405953} damage. Watch for spike damage from {spell:404316} on the tank.",
			},
			{
				role = TANK,
				"Tank the boss on the platform. Position yourself to minimize {spell:405998} impact on melee DPS. Face the boss away from the raid. All melee should stand behind him at all times to avoid the beam knockback.",
			}
		},
		abilities = {
			{
				spell = 404316,
				icons = { TANK },
				"Inflicts 185 frost damage and slows the target by 40%.",
			},
			{
				spell = 405998,
				icons = { IMPORTANT },
				"10 second cast ability that knocks back anyone hit by it in front of Baron Aquanis. The boss slowly turns clockwise during the channel.",
			},
			{
				spell = 404805,
				icons = { IMPORTANT },
				"Debuff that once it expires inflicts 231 frost/arcane damage and knocks back anyone within close proximity.",
			},
			{
				spell = 405953,
				icons = { IMPORTANT },
				"Area of effect over a target that inflicts 115 damage every 2 seconds. Avoid standing in these zones.",
			}
		}
	},
	{
		name = "Twilight Lord Kelris",
		encounterID = 4832,
		portrait = 607800,
		loot = {
			{ id = 1155, seasonFilter = "all" },
			{ id = 6903, seasonFilter = "all" },
			{ id = 18425, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Twilight Lord Kelris is a high-ranking member of the Twilight's Hammer cult, which seeks to usher in the return of the malevolent Old Gods. Within Blackfathom Deeps, Kelris conducts dark rituals and schemes to further the cult's goals. His mastery of shadow magic and his allegiance to the Old Gods make him a formidable and sinister figure in the depths.",
			{ heading = "Overview" },
			"Twilight Lord Kelris is the sixth boss in Blackfathom Deeps and will be the hardest boss for many groups. Phase 1 requires interrupting {spell:425265}, avoiding {spell:426069} void zones, and handling {spell:423135}. At 35% HP he enrages and becomes uninterruptible.",
			{
				role = DAMAGE,
				"Interrupt every {spell:425265} cast in Phase 1 - it casts every 10 seconds so Rogues can Kick on cooldown. Avoid {spell:426069} void zones that grow over time. Two players closest to Kelris get sent to dream realm via {spell:423135} and must kill Phantasmal Priestesses to escape. Pop Shadow Protection Potion before Phase 2 at 35% and nuke him down.",
			},
			{
				role = HEALER,
				"Three healers are recommended for this encounter. Kelris deals massive tank damage with {spell:425233} so ensure at least one healer is dedicated to the tank. Magic dispel is required. Be prepared for increased raid damage in Phase 2 when Kelris becomes uninterruptible.",
			},
			{
				role = TANK,
				"Two tanks required for this encounter. Position the boss so ranged can avoid {spell:426069}. In Phase 2 starting at 35% HP, Kelris becomes uninterruptible and mobile while casting, dealing massive increased damage. Use defensive cooldowns heavily in Phase 2.",
			}
		},
		abilities = {
			{
				spell = 425233,
				icons = { TANK },
				"1.5 second cast shadow damage spell cast on the player closest to Kelris. Deals massive damage to the tank.",
			},
			{
				spell = 425265,
				icons = { INTERRUPT, IMPORTANT },
				"1.5 second cast shadow damage spell that chains to anyone nearby, applying a magic DoT effect. MUST be interrupted in Phase 1.",
			},
			{
				spell = 426069,
				icons = { IMPORTANT },
				"Lobs a shadow bolt at targeted player, dealing damage and leaving a large pool of damaging shadow that grows over time.",
			},
			{
				spell = 423135,
				icons = { IMPORTANT },
				"The two players closest to Twilight Lord Kelris get sent to the dream realm. They must kill Phantasmal Priestesses to spawn a portal back.",
			}
		}
	},
	-- Old Serra'kis is NOT a raid boss in Season of Discovery
	-- He appears only as a corpse used for crafting quests (Shard of the Void)
	-- {
	-- 	name = "Old Serra'kis",
	-- 	encounterID = 4830,
	-- 	portrait = 607733,
	-- 	loot = {
	-- 		{ id = 6901, seasonFilter = "all" },
	-- 		{ id = 6902, seasonFilter = "all" },
	-- 		{ id = 6904, seasonFilter = "all" },
	-- 	},
	-- 	sharedLoot = {},
	-- 	rareLoot = {},
	-- 	veryRareLoot = {},
	-- 	extremelyRareLoot = {},
	-- 	npcs = { 2135, 12456, 12314 },
	-- 	overview = {
	-- 		"Old Serra'kis is a massive and ancient hydra that dwells within the watery depths of Blackfathom Deeps. This colossal creature is a testament to the primal forces of nature that still exist deep underground. Old Serra'kis's multiple heads and devastating attacks make it a formidable and iconic inhabitant of the submerged realm.",
	-- 		{ heading = "Overview" },
	-- 		"Old Serra'kis is an optional boss in Blackfathom Deeps who will periodcally heal himself when attacking. The notable aspect of this boss is that you fight him underwater.",
	-- 		{
	-- 			role = DAMAGE,
	-- 			"maximize your damage output without overthrowing the tank from the primary threat position, or running out of breath.",
	-- 		},
	-- 		{
	-- 			role = HEALER,
	-- 			"Keep your party members up and heal the tank without running out of breath.",
	-- 		},
	-- 		{
	-- 			role = TANK,
	-- 			"Maintain threat on the boss without running out of breath.",
	-- 		}
	-- 	},
	-- 	abilities = {
	--
	-- 	}
	-- },
	{
		name = "Aku'mai",
		encounterID = 4829,
		portrait = 607614,
		loot = {
			{ id = 6910, seasonFilter = "all" },
			{ id = 6911, seasonFilter = "all" },
			{ id = 6909, seasonFilter = "all" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Aku'mai is an immense and malevolent creature known as the Deepstrider that lurks in the darkest depths of Blackfathom Deeps. Its origins are shrouded in mystery, but it is believed to be a primeval and nightmarish entity. Aku'mai's horrifying form and deadly attacks make it the ultimate challenge for adventurers who dare to explore the deepest reaches of the submerged caverns.",
			{ heading = "Overview" },
			"Aku'mai is the final boss of Blackfathom Deeps, a two-phase encounter. Phase 1 involves managing {spell:427625} stacks using {spell:427750}, avoiding {spell:429168}, and handling {spell:428724}. At 50% HP, Phase 2 begins with {spell:429541} converting all damage to shadow.",
			{
				role = DAMAGE,
				"Avoid {spell:429168} channeled beam. In Phase 1, help burn adds that spawn from corrupted Cleansing Pools. In Phase 2 after {spell:429541}, focus on killing Void Elementals that spawn while maintaining DPS on boss. The tank will accumulate {spell:429353} stacks rapidly in Phase 2.",
			},
			{
				role = HEALER,
				"Watch for {spell:428724} damage on the second-highest threat target. Tank needs to use {spell:427750} at 3-4 stacks of {spell:427625}. Healing requirements increase significantly in Phase 2 with {spell:429353} ramping shadow damage and Void Elementals spawning.",
			},
			{
				role = TANK,
				"Two tanks recommended. Form a circle around Aku'mai at spawn to minimize {spell:429168} impact. Move to {spell:427750} at 3-4 {spell:427625} stacks - pool becomes corrupted after use and spawns adds. In Phase 2, manage {spell:429353} stacks carefully and use defensive cooldowns as it reduces max HP by 10% per stack.",
			}
		},
		abilities = {
			{
				spell = 429168,
				icons = { IMPORTANT },
				"Aku'mai channels a Corrosive Blast in a direction towards where a random player was located. Move away from this direction to avoid damage.",
			},
			{
				spell = 427625,
				icons = { TANK },
				"Stacking corrosion debuff applied to the tank. Cleanse by moving to a Cleansing Pool at 3-4 stacks.",
				{
					spell = 427750,
					"Cleansing Pools positioned at room corners remove Corrosion stacks. After use, the pool becomes corrupted and spawns adds.",
				},
			},
			{
				spell = 428724,
				icons = { TANK },
				"Aku'mai turns and bites the target with the highest threat other than the current tank, dealing heavy damage.",
			},
			{
				spell = 429541,
				icons = { IMPORTANT },
				"At 50% HP, Aku'mai casts Dark Protection and becomes infused by the Void. All his abilities now deal Shadow damage instead of Nature damage.",
			},
			{
				spell = 429353,
				icons = { TANK },
				"Phase 2 ability: Every 5 seconds applies a stacking debuff to the main aggro target that reduces max HP by 10% and increases Shadow damage taken by 25% per stack.",
			},
			{
				spell = 429356,
				icons = { IMPORTANT },
				"Phase 2 version of Corrosive Blast, now dealing Shadow damage. Avoid being in the path of this channeled beam.",
			}
		}
	},
})