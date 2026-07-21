--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

 InstanceService.AddDungeon({
	name = "Old Hillsbrad Foothills",
	instanceID = 560,
	thumbnail = 608198,
	icon = 136350,
	splash = 608237,
	mapID = 267,
	seasonFilter = "tbc",
	overview = "Old Hillsbrad Foothills is a Caverns of Time instance that takes players back in time to Durnholde Keep before the First War. Here, the orc Thrall is held prisoner by Aedelas Blackmoore. The infinite dragonflight seeks to prevent Thrall's escape, which would alter the course of history. Players must escort Thrall through Durnholde Keep and Tarren Mill while defending the timeline from temporal sabotage.",
	{
		name = "Lieutenant Drake",
		defeated = 0,
		encounterID = 17848,
		portrait = 607689,
		loot = {
			{ id = 27423, seasonFilter = "tbc" },
			{ id = 27418, seasonFilter = "tbc" },
			{ id = 27417, seasonFilter = "tbc" },
			{ id = 27420, seasonFilter = "tbc" },
			{ id = 27436, seasonFilter = "tbc" },
			{ id = 28212, seasonFilter = "tbc" },
			{ id = 28214, seasonFilter = "tbc" },
			{ id = 28215, seasonFilter = "tbc" },
			{ id = 28211, seasonFilter = "tbc" },
			{ id = 28213, seasonFilter = "tbc" },
			{ id = 28210, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17848 },
		overview = {
			"Lieutenant Drake is the first boss encounter in Old Hillsbrad Foothills. As a veteran officer of Durnholde Keep's garrison, he leads the defense against intruders. This straightforward encounter serves as an introduction to the instance's mechanics.",
			{ heading = "Overview" },
			"Lieutenant Drake is a simple tank and spank encounter with moderate melee damage and periodic whirlwind attacks. The fight takes place in the initial courtyard area. Ranged players should maintain distance during Whirlwind, while melee need to temporarily disengage.",
			{
				role = DAMAGE,
				"Ranged DPS should maintain maximum distance to avoid {spell:33500} damage.",
				"Melee DPS must move away when Drake begins casting {spell:33500}, then resume attacking once it ends.",
				"Focus all damage on Lieutenant Drake - there are no adds or target switches in this encounter.",
				"Interrupt {spell:33511} when possible to reduce tank damage intake."
			},
			{
				role = HEALER,
				"Main healing focus should be on the tank, who will take consistent melee damage.",
				"During {spell:33500}, prepare for increased raid-wide damage if any melee fail to move out.",
				"Watch for {spell:33511} applications on the tank and increase healing output accordingly.",
				"Mana efficiency is important - this is the first of three boss encounters."
			},
			{
				role = TANK,
				"Tank Drake in the center of the courtyard, facing him away from the group.",
				"Hold position during {spell:33500} - you will take increased damage but must maintain threat.",
				"Use defensive cooldowns if needed during {spell:33500} to mitigate the damage spike.",
				"Be aware that {spell:33511} will reduce your armor - communicate with healers when this is active."
			}
		},
		abilities = {
			{ spell = 33500, description = "Whirlwind - Drake spins rapidly, dealing physical damage to all nearby enemies. Melee should move out of range during this ability." },
			{ spell = 33511, description = "Sunder Armor - Reduces the tank's armor by a significant amount, stacking up to 5 times. Increases physical damage taken." },
			{ spell = 33481, description = "Exploding Shot (Heroic) - Fires an explosive projectile at a random ranged player, dealing fire damage in a small area." },
		}
	},
	{
		name = "Captain Skarloc",
		defeated = 0,
		encounterID = 17862,
		portrait = 607561,
		loot = {
			{ id = 27428, seasonFilter = "tbc" },
			{ id = 27430, seasonFilter = "tbc" },
			{ id = 27427, seasonFilter = "tbc" },
			{ id = 27424, seasonFilter = "tbc" },
			{ id = 27426, seasonFilter = "tbc" },
			{ id = 21524, seasonFilter = "tbc" },
			{ id = 28218, seasonFilter = "tbc" },
			{ id = 28220, seasonFilter = "tbc" },
			{ id = 28219, seasonFilter = "tbc" },
			{ id = 28221, seasonFilter = "tbc" },
			{ id = 28217, seasonFilter = "tbc" },
			{ id = 28216, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 17862 },
		overview = {
			"Captain Skarloc is encountered after escorting Thrall through Durnholde Keep's burning barracks. As the mounted captain of Durnholde's cavalry, Skarloc presents a mounted combat challenge with both magical and physical abilities.",
			{ heading = "Overview" },
			"Captain Skarloc is a mounted encounter featuring flame-based attacks and high mobility. He remains mounted throughout the fight, using charges and flame-based abilities. The encounter requires tank positioning awareness and raid members must avoid standing in front of Skarloc during his charge ability.",
			{
				role = DAMAGE,
				"Maintain spread positioning to minimize {spell:33813} splash damage to multiple players.",
				"Move away from the tank's position to avoid being caught in {spell:33546} charges.",
				"Ranged DPS should position at maximum range to have time to react to incoming charges.",
				"Interrupt or dispel {spell:33801} when possible to reduce raid-wide fire damage.",
				"On Heroic difficulty, be prepared for increased fire damage from all flame-based abilities."
			},
			{
				role = HEALER,
				"The tank will require steady healing due to consistent melee damage plus {spell:33813} applications.",
				"Watch for {spell:33546} charge targets - they will need immediate healing after the impact.",
				"Prepare for periodic raid-wide damage from {spell:33801} - use group healing abilities.",
				"Have dispels ready for any flame-based debuffs that may be applied to raid members.",
				"On Heroic difficulty, assign dedicated healers to both tank and charge targets."
			},
			{
				role = TANK,
				"Position Skarloc facing away from the raid to avoid {spell:33546} hitting multiple players.",
				"Remain mobile and maintain threat while Skarloc repositions after charge abilities.",
				"Use defensive cooldowns during high damage periods, especially when {spell:33813} stacks are high.",
				"Be prepared to quickly re-establish threat after Skarloc charges random raid members.",
				"Keep Skarloc positioned near the center of the area to give raid members maximum space to spread."
			}
		},
		abilities = {
			{ spell = 33546, description = "Dismounting Blast - Charges a random player, dealing physical damage and knocking them back. Creates temporary threat issues." },
			{ spell = 33813, description = "Flame Shock - Deals immediate fire damage to the current target and applies a fire DoT that lasts several seconds." },
			{ spell = 33801, description = "Flame Buffet (Heroic) - Periodic AoE fire damage to all raid members. Damage increases over time." },
			{ spell = 33671, description = "Holy Light - Skarloc will attempt to heal himself. This can be interrupted by players." },
			{ spell = 33487, description = "Cleave - Frontal cone attack dealing increased physical damage. Affects the tank and anyone in front of Skarloc." },
		}
	},
	{
		name = "Epoch Hunter",
		defeated = 0,
		encounterID = 18096,
		portrait = 607596,
		loot = {
			{ id = 24173, seasonFilter = "tbc" },
			{ id = 27433, seasonFilter = "tbc" },
			{ id = 27434, seasonFilter = "tbc" },
			{ id = 27440, seasonFilter = "tbc" },
			{ id = 27432, seasonFilter = "tbc" },
			{ id = 27431, seasonFilter = "tbc" },
			{ id = 29250, seasonFilter = "tbc" },
			{ id = 29246, seasonFilter = "tbc" },
			{ id = 30534, seasonFilter = "tbc" },
			{ id = 30536, seasonFilter = "tbc" },
			{ id = 27911, seasonFilter = "tbc" },
			{ id = 28344, seasonFilter = "tbc" },
			{ id = 28233, seasonFilter = "tbc" },
			{ id = 27904, seasonFilter = "tbc" },
			{ id = 28227, seasonFilter = "tbc" },
			{ id = 28223, seasonFilter = "tbc" },
			{ id = 28226, seasonFilter = "tbc" },
			{ id = 28222, seasonFilter = "tbc" },
			{ id = 28191, seasonFilter = "tbc" },
			{ id = 28224, seasonFilter = "tbc" },
			{ id = 28401, seasonFilter = "tbc" },
			{ id = 28225, seasonFilter = "tbc" }
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 18096 },
		overview = {
			"Epoch Hunter is the final boss of Old Hillsbrad Foothills, representing the infinite dragonflight's attempt to alter the timeline. This dragonkin encounter is the most mechanically complex fight in the instance, featuring time manipulation abilities and curse effects.",
			{ heading = "Overview" },
			"Epoch Hunter is a dragonkin boss with time-manipulation abilities including periodic time stops and curse effects. The encounter requires curse removal capabilities and coordination during time-based mechanics. Players must manage the Time Lapse debuff carefully and be prepared for the Sand Breath cone attack.",
			{
				role = DAMAGE,
				"Ensure your group has multiple classes capable of removing {spell:33332} - Mages and Druids are essential.",
				"Do not stand in front of Epoch Hunter to avoid being hit by {spell:31914}.",
				"When affected by {spell:33332}, stop all damage dealing until it is removed to avoid additional curse applications.",
				"During {spell:31422}, continue dealing damage but be aware that Epoch is immune to damage briefly.",
				"On Heroic difficulty, {spell:31914} deals significantly more damage - position carefully to avoid it entirely.",
				"Melee DPS should position behind and to the sides of Epoch Hunter at all times."
			},
			{
				role = HEALER,
				"Assign dedicated healers to dispel {spell:33332} immediately - this is the highest priority mechanic.",
				"Players affected by {spell:33332} will take increasing damage over time - dispel quickly.",
				"Be prepared for heavy tank damage from {spell:31914} if the tank gets clipped by the cone.",
				"During {spell:31422}, use the brief pause to top off the raid and prepare for the next phase.",
				"Maintain high mana efficiency - this is a longer encounter with sustained healing requirements.",
				"On Heroic difficulty, assign at least 2-3 healers capable of curse removal."
			},
			{
				role = TANK,
				"Position Epoch Hunter facing away from the raid at all times to protect them from {spell:31914}.",
				"Maintain threat during {spell:31422} even though you cannot damage him during this phase.",
				"If you are affected by {spell:33332}, call out for immediate dispels as it will reduce your effectiveness.",
				"Keep Epoch in a central position to allow maximum space for ranged and healers to spread.",
				"Use defensive cooldowns during high-damage periods, especially after {spell:31422} ends.",
				"Be prepared for threat fluctuations if you get cursed - have a backup tank ready if needed."
			}
		},
		abilities = {
			{ spell = 31422, description = "Time Stop - Epoch briefly stops time, becoming immune to damage and preventing all actions. Lasts a few seconds." },
			{ spell = 31914, description = "Sand Breath - Frontal cone breath attack dealing nature damage. Only affects players standing in front of Epoch Hunter." },
			{ spell = 33332, description = "Time Lapse - Curses a random player, increasing the time between their actions and reducing attack/cast speed. Must be removed by Mages or Druids." },
			{ spell = 52772, description = "Magic Disruption Aura (Heroic) - Reduces casting speed of all nearby enemies. Affects the entire raid throughout the encounter." },
			{ spell = 34942, description = "Wing Buffet (Heroic) - Knocks back all nearby enemies and reduces their threat. Requires tanks to quickly re-establish aggro." },
		}
	}
})
