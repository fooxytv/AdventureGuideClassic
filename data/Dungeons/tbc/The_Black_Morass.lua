--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddDungeon({
	name = "The Black Morass",
	instanceID = 269,
	thumbnail = 608198,
	icon = 136350,
	splash = 608237,
	mapID = 273,
	seasonFilter = "tbc",
	overview = "The Black Morass is a Caverns of Time instance depicting the opening of the Dark Portal by Medivh. Players must defend the portal's opening against the infinite dragonflight, who seek to prevent this pivotal moment in history. The encounter is a time-based gauntlet where players defend against waves of enemies attempting to disrupt the timeline while Medivh channels his ritual.",
	{
		name = "Chrono Lord Deja",
		defeated = 0,
		encounterID = 17879,
		portrait = 607566,
		loot = {
			{ id = 29675, seasonFilter = "tbc" },
			{ id = 27996, seasonFilter = "tbc" },
			{ id = 27994, seasonFilter = "tbc" },
			{ id = 27993, seasonFilter = "tbc" },
			{ id = 27987, seasonFilter = "tbc" },
			{ id = 27995, seasonFilter = "tbc" },
			{ id = 27988, seasonFilter = "tbc" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17879 },
		overview = {
			"Chrono Lord Deja is the first boss encounter in The Black Morass, appearing after defending several time rifts. As a member of the infinite dragonflight, Deja attempts to disrupt the opening of the Dark Portal through time manipulation abilities and summoned assistance.",
			{ heading = "Overview" },
			"Chrono Lord Deja combines direct damage abilities with time manipulation and adds. The encounter requires managing Aeonus Rifts that spawn additional enemies, dispelling the Time Lapse debuff, and handling Arcane Discharge damage. Players must balance DPS on the boss with controlling the summoned adds from rifts.",
			{
				role = DAMAGE,
				"Focus primary damage on Chrono Lord Deja while being aware of adds spawning from {spell:31467}.",
				"Assign specific players to quickly kill Infinite Chronomancers and Assassins when they spawn from rifts.",
				"Ensure Mages or Druids are available to dispel {spell:31467} from affected players immediately.",
				"Ranged DPS should spread out to minimize splash damage from {spell:31457}.",
				"Interrupt or focus fire on Infinite Chronomancers to prevent their time-based casting.",
				"On Heroic difficulty, expect significantly higher damage from all abilities - prioritize add control."
			},
			{
				role = HEALER,
				"Players affected by {spell:31467} will need immediate dispels - this is highest priority.",
				"Be prepared for periodic raid-wide damage from {spell:31457} - use group healing abilities.",
				"Tank damage will spike when multiple adds are active - communicate with tanks about add counts.",
				"Maintain high mana efficiency as this is the first of three consecutive boss encounters.",
				"Position to have clear line of sight to all raid members for efficient dispelling.",
				"On Heroic difficulty, assign dedicated healers to curse/debuff removal duties."
			},
			{
				role = TANK,
				"Main tank should hold Chrono Lord Deja while off-tank or DPS pick up spawning adds.",
				"Position Deja away from active rifts to prevent pulling additional rift spawns prematurely.",
				"Be aware that {spell:31467} affects threat generation - call for dispels when affected.",
				"Maintain threat on both boss and adds if necessary - use AoE threat abilities.",
				"Face Deja away from the raid to avoid cleave damage hitting other players.",
				"Communicate with DPS about when to burn boss versus controlling adds."
			}
		},
		abilities = {
			{ spell = 31457, description = "Arcane Discharge - Deals arcane damage to all nearby enemies. Regular periodic damage that affects the entire raid." },
			{ spell = 31467, description = "Time Lapse - Curses a random player, slowing their attack and casting speed. Must be removed by Mages or Druids." },
			{ spell = 31472, description = "Magnetic Pull - Pulls all nearby enemies toward Chrono Lord Deja. Can disrupt positioning." },
			{ spell = 33561, description = "Rift - Summons a rift that spawns Infinite Assassins and Chronomancers. These adds must be controlled and killed quickly." },
		}
	},
	{
		name = "Temporus",
		defeated = 0,
		encounterID = 17880,
		portrait = 607784,
		loot = {
			{ id = 28033, seasonFilter = "tbc" },
			{ id = 28185, seasonFilter = "tbc" },
			{ id = 28186, seasonFilter = "tbc" },
			{ id = 28034, seasonFilter = "tbc" },
			{ id = 28184, seasonFilter = "tbc" },
			{ id = 28187, seasonFilter = "tbc" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17880 },
		overview = {
			"Temporus appears after successfully defending additional time rifts. As another agent of the infinite dragonflight, this dragonkin employs powerful haste and slow effects that dramatically alter the pace of combat, creating a unique tempo-based encounter.",
			{ heading = "Overview" },
			"Temporus is a dragonkin encounter centered around haste and slow mechanics. The boss alternates between speeding himself up with Hasten and slowing the raid with Mortal Wound and Spell Reflection. The encounter requires careful cooldown management and awareness of the boss's current speed state.",
			{
				role = DAMAGE,
				"Be extremely cautious when casting spells - {spell:31556} will reflect spells back at you and silence you.",
				"Melee DPS should watch for {spell:31458} applications on themselves - this severely reduces attack speed.",
				"When Temporus casts {spell:31458} on himself, expect a significant damage increase - prepare defensive cooldowns.",
				"Physical damage dealers are preferred for this encounter due to frequent {spell:31556} casts.",
				"Focus fire should remain on Temporus - there are no add phases in this encounter.",
				"On Heroic difficulty, {spell:31458} and {spell:31556} occur more frequently - adjust strategy accordingly."
			},
			{
				role = HEALER,
				"Tank damage will spike dramatically when Temporus has {spell:31458} active - be ready with fast heals.",
				"Dispel {spell:31458} from affected raid members when possible to restore their combat effectiveness.",
				"During {spell:31556} phases, rely on instant-cast heals to avoid having your healing reflected.",
				"Use healing-over-time effects during reflection phases to maintain throughput without risk.",
				"Coordinate with other healers to ensure tank coverage during high-speed Hasten phases.",
				"On Heroic difficulty, assign dedicated healers to tank healing during Hasten periods."
			},
			{
				role = TANK,
				"Main threat concern is during {spell:31458} on Temporus - his increased attack speed may break threat.",
				"Use defensive cooldowns when Temporus casts {spell:31458} on himself - incoming damage increases substantially.",
				"Face Temporus away from the raid to avoid cleave damage during his high-speed attack phases.",
				"Communicate with healers before {spell:31458} phases so they can prepare for damage spikes.",
				"Maintain high threat generation to compensate for reduced attack speed when affected by {spell:31458}.",
				"Keep Temporus positioned consistently to help ranged maintain optimal positioning."
			}
		},
		abilities = {
			{ spell = 31458, description = "Hasten - Increases attack and movement speed by 150% when cast on self. When cast on enemies, reduces their attack and casting speed by 50%." },
			{ spell = 31556, description = "Spell Reflection - Reflects the next spell cast at Temporus back at the caster and silences them. Casters should stop casting during this buff." },
			{ spell = 31464, description = "Frenzy (Heroic) - Increases Temporus's attack speed by 50% and physical damage by 100%. Stacks with Hasten for devastating damage output." },
			{ spell = 38592, description = "Mortal Wound - Reduces healing received by the affected target by 10% per stack. Stacks up to 99 times." },
		}
	},
	{
		name = "Aeonus",
		defeated = 0,
		encounterID = 17881,
		portrait = 607529,
		loot = {
			{ id = 28188, seasonFilter = "tbc" },
			{ id = 28206, seasonFilter = "tbc" },
			{ id = 27509, seasonFilter = "tbc" },
			{ id = 28192, seasonFilter = "tbc" },
			{ id = 28189, seasonFilter = "tbc" },
			{ id = 27977, seasonFilter = "tbc" },
			{ id = 27839, seasonFilter = "tbc" },
			{ id = 28193, seasonFilter = "tbc" },
			{ id = 27873, seasonFilter = "tbc" },
			{ id = 28207, seasonFilter = "tbc" },
			{ id = 28194, seasonFilter = "tbc" },
			{ id = 28190, seasonFilter = "tbc" },
			{ id = 30531, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 29253, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 29247, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 29356, seasonFilter = "tbc", difficulty = "heroic" },
			{ id = 33858, seasonFilter = "tbc", difficulty = "heroic" },
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17881 },
		overview = {
			"Aeonus is the final boss of The Black Morass and leader of the infinite dragonflight assault on this timeline. This climactic encounter represents the last desperate attempt to prevent the Dark Portal's opening. Aeonus combines powerful dragonkin abilities with time manipulation and summoned allies.",
			{ heading = "Overview" },
			"Aeonus is a complex multi-phase dragonkin encounter featuring Sand Breath frontal cone attacks, Time Stop freezes, and waves of summoned infinite adds. The fight requires precise positioning, add management, and curse dispelling. Players must balance damage on Aeonus with controlling the spawning infinite dragonkin while managing the Time Stop mechanic.",
			{
				role = DAMAGE,
				"Never stand in front of Aeonus to avoid the devastating {spell:31473} breath attack.",
				"Ensure Mages and Druids are ready to dispel {spell:31467} immediately when it is applied.",
				"Assign specific DPS to focus on Infinite Assassins and Chronomancers when they spawn.",
				"During {spell:31422}, prepare to resume full damage output once the time stop effect ends.",
				"Interrupt Infinite Chronomancer casts when possible to reduce raid-wide pressure.",
				"On Heroic difficulty, add waves are more frequent - maintain strict kill priority on dangerous adds.",
				"Melee DPS must position behind and to the sides of Aeonus at all times."
			},
			{
				role = HEALER,
				"Immediately dispel {spell:31467} from affected players - this is the highest priority action.",
				"During {spell:31422}, use the pause to top off raid health and regenerate mana.",
				"Be prepared for heavy tank damage if they accidentally get clipped by {spell:31473}.",
				"Watch for players who may get hit by {spell:31473} despite positioning - they need emergency healing.",
				"Assign healers to focus on tank healing versus raid healing based on add spawn timing.",
				"Maintain clear line of sight to all players for quick curse dispelling.",
				"On Heroic difficulty, coordinate defensive cooldowns for periods of heavy add pressure."
			},
			{
				role = TANK,
				"Position Aeonus facing away from the raid at all times to protect them from {spell:31473}.",
				"Maintain threat during {spell:31422} even though no damage can be dealt during the freeze.",
				"Off-tank or high-threat DPS should immediately pick up spawning Infinite adds.",
				"Use defensive cooldowns during periods of high add count to survive burst damage.",
				"Keep Aeonus in a central position to maximize space for raid spreading and add kiting.",
				"Communicate add spawn counts to the raid so DPS know when to switch targets.",
				"Be prepared for threat spikes when affected by {spell:31467} - call for immediate dispels."
			}
		},
		abilities = {
			{ spell = 31473, description = "Sand Breath - Frontal cone breath attack dealing massive nature damage. Only affects players standing in front of Aeonus. Always position behind the boss." },
			{ spell = 31422, description = "Time Stop - Aeonus freezes time, stunning all players and becoming immune to damage for several seconds. Use this time to prepare for the next phase." },
			{ spell = 31467, description = "Time Lapse - Curses a random player, reducing attack and casting speed by 70%. Must be dispelled immediately by Mages or Druids." },
			{ spell = 37605, description = "Frenzy (Heroic) - Increases Aeonus's attack speed by 60% and physical damage by 50%. Tank must use defensive cooldowns during this phase." },
			{ spell = 33834, description = "Summon Infinite Dragonkin - Periodically summons Infinite Assassins and Chronomancers to assist. These adds must be controlled and killed quickly." },
		}
	}
})
