--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Hellfire Ramparts",
	instanceID = 543,
	thumbnail = 608207,
	icon = 608207,
	splash = 608246,
	mapID = 347,
	seasonFilter = "tbc",
	overview = "Hellfire Ramparts is the first wing of Hellfire Citadel, a massive fortress in the Hellfire Peninsula. Once a proud bastion of the draenei, it has been corrupted by the fel magic of the Burning Legion. Now the ramparts serve as a training ground for the Fel Horde's warriors. Adventurers must breach these defenses to weaken the Legion's hold on Outland.",
	{
		name = "Watchkeeper Gargolmar",
		defeated = 0,
		encounterID = 17306,
		portrait = 607817,
		loot = {
			{ id = 24024, seasonFilter = "all" },
			{ id = 24023, seasonFilter = "all" },
			{ id = 24025, seasonFilter = "all" },
			{ id = 23999, seasonFilter = "all" },
			{ id = 27448, seasonFilter = "all" },
			{ id = 27449, seasonFilter = "all" },
			{ id = 27450, seasonFilter = "all" },
			{ id = 27447, seasonFilter = "all" }
		},
		sharedLoot = {
			{ id = 23998, seasonFilter = "all" },
			{ id = 24000, seasonFilter = "all" },
			{ id = 24001, seasonFilter = "all" },
			{ id = 24073, seasonFilter = "all" },
			{ id = 24074, seasonFilter = "all" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17306, 17309 },
		overview = {
			"Watchkeeper Gargolmar is the first guardian of Hellfire Ramparts. This massive fel orc oversees the training grounds and commands hellhounds to aid him in battle. His ferocity and the burning rage of his hounds make him a dangerous foe for unprepared adventurers.",
			{ heading = "Overview" },
			"Gargolmar summons Hellfire Watcher adds throughout the fight. The key to this encounter is managing the adds while maintaining threat on the boss. Tank the boss away from the party to minimize cleave damage. DPS should prioritize killing adds quickly when they spawn. The {spell:30860} ability deals moderate fire damage and should be interrupted when possible.",
			{
				role = DAMAGE,
				"Switch to Hellfire Watcher adds immediately when they spawn and burn them down quickly.",
				"Use AoE abilities if multiple adds are present to expedite their death.",
				"Return focus to Gargolmar once all adds are dead.",
				"Interrupt {spell:30860} when possible to reduce party damage.",
				"On Heroic difficulty, be prepared for more frequent add spawns and higher damage output."
			},
			{
				role = HEALER,
				"Prepare for increased party-wide damage when hellhounds are active.",
				"Keep the tank topped off as they will be taking damage from both the boss and adds.",
				"Be ready to heal party members who may get caught by adds before the tank picks them up.",
				"Conserve mana early as this is the first boss of the instance.",
				"On Heroic difficulty, the damage output is significantly higher and requires more attention."
			},
			{
				role = TANK,
				"Maintain solid threat on Gargolmar while the group kills adds.",
				"Face the boss away from the party to avoid cleave damage hitting other group members.",
				"Pick up Hellfire Watcher adds as they spawn to prevent them from attacking healers or DPS.",
				"Use defensive cooldowns when multiple adds are active simultaneously.",
				"Position yourself to make add pickup easier when they spawn."
			}
		},
		abilities = {}
	},
	{
		name = "Omor the Unscarred",
		defeated = 0,
		encounterID = 17308,
		portrait = 607734,
		loot = {
			{ id = 24069, seasonFilter = "all" },
			{ id = 24094, seasonFilter = "all" },
			{ id = 24096, seasonFilter = "all" },
			{ id = 27463, seasonFilter = "all" },
			{ id = 27477, seasonFilter = "all" },
			{ id = 27895, seasonFilter = "all" },
			{ id = 27539, seasonFilter = "all" }
		},
		sharedLoot = {
			{ id = 23998, seasonFilter = "all" },
			{ id = 24000, seasonFilter = "all" },
			{ id = 24001, seasonFilter = "all" },
			{ id = 24073, seasonFilter = "all" },
			{ id = 24074, seasonFilter = "all" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17308 },
		overview = {
			"Omor the Unscarred is a powerful warlock who commands shadow magic and demonic forces. His dark sorcery can drain life from his enemies and summon fiends to overwhelm adventurers. Defeating him requires careful positioning and quick reactions to his shadow bolts and adds.",
			{ heading = "Overview" },
			"Omor casts {spell:30695} which deals heavy shadow damage and should be interrupted. He also summons Fiendish Hounds periodically that must be killed quickly. The {spell:30686} debuff deals shadow damage over time and should be dispelled when possible. Tank positioning is important to keep the boss away from the party while maintaining control of adds.",
			{
				role = DAMAGE,
				"Interrupt {spell:30695} on cooldown to prevent heavy shadow damage to the tank.",
				"Switch to Fiendish Hounds immediately when they spawn and kill them quickly.",
				"After adds are dead, return focus to Omor.",
				"Maintain spread positioning to minimize potential cleave or AoE damage.",
				"On Heroic difficulty, interrupts become even more critical as Shadow Bolt hits much harder."
			},
			{
				role = HEALER,
				"Dispel {spell:30686} from affected party members as quickly as possible.",
				"Be prepared for burst damage when Fiendish Hounds spawn.",
				"Keep shadow resistance buffs active if your class has them available.",
				"Tank will take heavy shadow damage if Shadow Bolt is not interrupted.",
				"On Heroic difficulty, damage output is significantly higher and mana efficiency is critical."
			},
			{
				role = TANK,
				"Position Omor away from the party to minimize risk to other group members.",
				"Pick up Fiendish Hounds immediately when they are summoned.",
				"Use defensive cooldowns during intense add phases or when healers are overwhelmed.",
				"Maintain solid threat on both the boss and adds.",
				"Face the boss away from the party."
			}
		},
		abilities = {}
	},
	{
		name = "Vazruden the Herald",
		defeated = 0,
		encounterID = 17537,
		portrait = 607812,
		loot = {
			{ id = 24044, seasonFilter = "all" },
			{ id = 24045, seasonFilter = "all" },
			{ id = 24046, seasonFilter = "all" },
			{ id = 27451, seasonFilter = "all" },
			{ id = 27452, seasonFilter = "all" },
			{ id = 27453, seasonFilter = "all" },
			{ id = 27454, seasonFilter = "all" },
			{ id = 27455, seasonFilter = "all" },
			{ id = 27456, seasonFilter = "all" }
		},
		sharedLoot = {
			{ id = 23998, seasonFilter = "all" },
			{ id = 24000, seasonFilter = "all" },
			{ id = 24001, seasonFilter = "all" },
			{ id = 24073, seasonFilter = "all" },
			{ id = 24074, seasonFilter = "all" }
		},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17537, 17536 },
		overview = {
			"Vazruden the Herald rides atop Nazan, a massive nether drake. This two-phase encounter begins with aerial assaults from the mounted duo before Vazruden dismounts for close combat. The combination of ranged fire attacks and melee strikes makes this the most challenging encounter in Hellfire Ramparts for groups new to Outland.",
			{ heading = "Overview" },
			"This encounter has two distinct phases. Phase 1: Nazan flies overhead while Vazruden throws {spell:30691} and Nazan uses {spell:30691} to create fire patches on the ground. Vazruden also summons Hellfire Sentries that must be killed. Phase 2 begins when Vazruden's health reaches 20%, at which point he dismounts and both he and Nazan fight on the ground. Focus fire on Vazruden first as he dies when Vazruden dies. Tank both bosses facing away from the party and watch for {spell:34653} cone breath.",
			{
				role = DAMAGE,
				"Phase 1: Use ranged attacks on Nazan if you have them. Kill Hellfire Sentries as they spawn.",
				"Avoid fire patches on the ground created by {spell:30691}.",
				"Phase 2: Focus all damage on Vazruden first. Nazan will die automatically when Vazruden dies.",
				"Watch for Nazan's {spell:34653} cone breath and stay out of the frontal area.",
				"Melee DPS should position behind both bosses to avoid the cone breath.",
				"On Heroic difficulty, fire damage is significantly higher and positioning is critical."
			},
			{
				role = HEALER,
				"Phase 1: Heal through consistent party damage from aerial fireball attacks.",
				"Keep party members topped off as fire patches can deal significant damage.",
				"Phase 2: Tank will take heavy damage from both bosses simultaneously.",
				"Prioritize tank healing while keeping the party topped off from residual damage.",
				"On Heroic difficulty, consider using major cooldowns during Phase 2 to keep the tank alive.",
				"Watch your positioning to avoid fire patches and cone breath."
			},
			{
				role = TANK,
				"Phase 1: Pick up Hellfire Sentry adds as they spawn and hold threat on them.",
				"Use ranged abilities or attacks to maintain threat on Nazan if possible.",
				"Phase 2: Tank both Vazruden and Nazan together, facing them away from the party.",
				"Position yourself so that {spell:34653} cone breath does not hit your party members.",
				"Use major defensive cooldowns when tanking both bosses as damage intake will be very high.",
				"Be aware that you will need to move out of fire patches while maintaining positioning."
			}
		},
		abilities = {}
	}
})
