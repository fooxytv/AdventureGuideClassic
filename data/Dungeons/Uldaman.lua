--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Uldaman",
	instanceID = 239,
	thumbnail = 608225,
	icon = 136363,
	splash = 608264,
	mapID = 70,
	season = false,
	overview = "Uldaman is an ancient titan vault buried deep within the earth. It is said the titans sealed away a failed experiment there and then moved on to a new project, related to the genesis of the dwarves. Tales of a fabled treasure containing great knowledge have enticed would-be treasure hunters to dig deeper into the secrets of Uldaman, a task made perilous by the presence of stone defenders, savage troggs, Dark Iron invaders, and other dangers lurking in the lost city.",
	{
		name = "The Lost Dwarves",
		encounterID = 6906,
		portrait = 607550,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"In the depths of Uldaman, an ancient Titan vault, the Lost Dwarves—Baelog, Olaf, and Eric—stand as relics of a bygone era. Originally members of the renowned Stormpike Expedition, they delved too deep into the hidden secrets of the dungeon. Stranded and forgotten, these intrepid explorers now guard Uldaman's mysteries with unmatched tenacity, embodying the resilience and courage of their kind. Their presence is a testament to the dangers lurking within the ancient halls and the unyielding spirit of the dwarves who dare to uncover Azeroth's deepest secrets.",
			{ heading = "Overview" },
			"Damage dealers should focus on Eric first, as the tank can't hold his aggro during {spell:20252}, and use crowd control on Baelog, following the kill order: Eric, Olaf, Baelog. Healers should stay at maximum range, continuously heal the tank and damage dealers, and use bubbles and heal-over-time spells on all party members due to {spell:20252}. Tanks need to focus on Olaf to ensure his {spell:20252} targets them, initially generating threat on Eric to protect the healer and damage dealers from unnecessary damage.",
			{
				role = DAMAGE,
				"Focus on Eric first, as the tank can't hold his aggro during {spell:20252}. Use crowd control on Baelog. Kill order: Eric, Olaf, Baelog.",
			},
			{
				role = HEALER,
				"Stay at maximum range and keep healing spells on the tank and damage dealers. Due to {spell:20252}, use bubbles and stack heal over time spells on all party members.",
			},
			{
				role = TANK,
				"Focus on Olaf to ensure his {spell:20252} targets you. Initially, get threat on Eric to protect the healer and damage dealers from unnecessary damage.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Revelosh",
		encounterID = 6910,
		portrait = 607757,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Revelosh is an ancient and enigmatic stone golem that guards the depths of Uldaman. Crafted by the titans in ages past, he stands as a sentinel over the secrets hidden within the ancient vaults. Revelosh's presence in Uldaman signifies the enduring power of the titans' creations.",
			{ heading = "Overview" },
			"Revelosh, a Trogg boss, is encountered alongside two non-elite Trogg adds. Quickly eliminating him is crucial due to his potent [Chain Lightning] ability. Successfully defeating Revelosh provides The Shaft of Tsol, essential for summoning Ironaya. The strategy involves prioritizing Revelosh while managing his adds and interrupting his damaging spells to ensure a smooth battle.",

			{
				role = DAMAGE,
				"Prioritize dealing damage to Revelosh to avoid taking damage from {spell:16033}. Use any interrupt abilities to kick his {spell:16033} casts.",
			},
			{
				role = HEALER,
				"Maintain max range to avoid taking damage from {spell:16033}. Be prepared to heal through the damage from {spell:16033}.",
			},
			{
				role = TANK,
				"Generate initial threat on Revelosh to prevent him from attacking other players. Use any interrupt abilities to kick his {spell:16033} casts.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Ironaya",
		encounterID = 7228,
		portrait = 607664,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Ironaya is a fearsome stone golem that dwells deep within Uldaman. Created by the titans, she guards the inner chambers of the ancient complex. Ironaya's presence in Uldaman symbolizes the titans' dedication to safeguarding their creations.",
			{ heading = "Overview" },
			"Ranged damage dealers should spread out behind Ironaya and use direct damage spells, avoiding damage over time spells as Ironaya is immune. Melee should also spread out and avoid {spell:8374}. Healers need to focus on keeping the tank healed, spreading out with the ranged damage dealers, and prioritizing the tank while damage dealers should take minimal damage if correctly positioned. The tank should pick up Ironaya and face her away from the damage dealers and healer to avoid {spell:8374}.",
			{
				role = DAMAGE,
				"Ranged damage dealers spread out behind the boss and use direct damage spells. Avoid damage over time spells; Ironaya is immune. Melee spread out and avoid {spell:8374}.",
			},
			{
				role = HEALER,
				"Focus on keeping the tank healed. Spread out with ranged damage dealers and prioritize healing the tank. Damage dealers should take minimal damage if positioned correctly.",
			},
			{
				role = TANK,
				"The Tank needs to pick up Ironaya and face her away from damage dealers and the healer to avoid {spell:8374}.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Obsidian Sentinel",
		encounterID = 7023,
		portrait = 607729,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"The Obsidian Sentinel is an imposing construct that watches over Uldaman's inner chambers. Crafted from obsidian and enchanted by the titans, it stands as an unyielding guardian. The Obsidian Sentinel's presence underscores the enduring power of the titans' creations.",
			{ heading = "Overview" },
			"Damage dealers should focus on the boss when no adds are present and prioritize killing Obsidian Shards when they are summoned, allowing the tank a moment to generate threat on the adds before attacking. Healers should stay away from the rest of the group and keep heals on the tank. The tank needs to face the boss away from the group to allow melee to attack from behind, pick up adds as they spawn, and maintain threat on the adds when they appear.",
			{
				role = DAMAGE,
				"Focus on the boss when no adds are present. When Obsidian Shards are summoned, prioritize killing them, then return to the boss. Allow the tank a moment to generate threat on the adds before attacking.",
			},
			{
				role = HEALER,
				"Healer should remain away from the other members of the group and keep heals up on the tank.",
			},
			{
				role = TANK,
				"Tank only needs to take the boss and face him away from the group to allow melee to attack from behind. Pick up adds as they spawn. Do your best to maintain threat on the adds when they spawn.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Ancient Stone Keeper",
		encounterID = 7206,
		portrait = 607538,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"The Ancient Stone Keeper is a sentinel crafted by the titans to protect the secrets within Uldaman. Its ancient and weathered form stands as a testament to the passage of time. The presence of the Ancient Stone Keeper in Uldaman signifies the enduring legacy of the titans.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"Ranged DPS need to stay at max range in order to avoid being affected by the silence component of [Sand Storms].",
			},
			{
				role = HEALER,
				"Stay at max range to avoid the silence effect of [Sand Storms] and focus healing on the tank during this fight.",
			},
			{
				role = TANK,
				"Tanking this fight is straightforward: simply maintain threat.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Galgann Firehammer",
		encounterID = 7291,
		portrait = 607606,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Galgann Firehammer is a formidable Dark Iron dwarf who has taken up residence within Uldaman. His allegiance to the Dark Iron clan and his mastery of fire magic make him a formidable adversary. Galgann's presence within Uldaman adds an element of danger to the ancient chambers.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Grimlok",
		encounterID = 4854,
		portrait = 607626,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Grimlok is a powerful and brutish trogg chieftain who has claimed a portion of Uldaman as his domain. His physical strength and leadership over the troggs make him a formidable adversary. Grimlok's presence in Uldaman signifies the diverse inhabitants that have carved out territories within the ancient complex.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Archaedas",
		encounterID = 2748,
		portrait = 607546,
		loot = { },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Archaedas is a colossal and ancient stone golem that guards the deepest chambers of Uldaman. Crafted by the titans themselves, he stands as a sentinel over the most sacred secrets of the complex. Archaedas's presence in Uldaman signifies the pinnacle of the titans' creations.",
			{ heading = "Overview" },
			"information goes here..",
			{
				role = DAMAGE,
				"",
			},
			{
				role = HEALER,
				"",
			},
			{
				role = TANK,
				"",
			}
		},
		abilities = {
			
		}
	},
})
