--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "The Temple of Atal'hakkar",
	instanceID = 237,
	thumbnail = 608217,
	icon = 136360,
	splash = 608256,
	mapID = 109,
	season = true,
	overview = "Thousands of years ago, the Gurubashi empire was plunged into a civil war by a powerful sect of priests, the Atal'ai, who sought to summon to Azeroth an avatar of their god of blood, Hakkar the Soulflayer. The Gurubashi people exiled the Atal'ai to the Swamp of Sorrows, where the priests built the Temple of Atal'Hakkar. Ysera, Aspect of the green dragonflight, sank the temple beneath the swamp and assigned wardens to ensure that the summoning rituals never be performed again.",
	{
		name = "Atal'alarion",
		encounterID = 8580,
		portrait = I.UIEJBossAtalalarion,
		loot = { 10798, 10800, 10799 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Atal'alarion is a powerful and vengeful spirit bound within The Temple of Atal'Hakkar. Once a guardian of the temple, he has been corrupted by dark forces and now seeks to defend it with a malevolent rage. Atal'alarion's presence within the temple signifies the tragic fall of an ancient protector.",
			{ heading = "Overview" },
			"Atal'alarion guards the Idol in the Sunken Temple of Atal'hakkar's Pit of Refuse. To summon him, activate the six shrines in the following order: South, North, Southwest, Southeast, Northwest, Northeast. This sequence not only summons Atal'alarion at the room's center but also avoids a curse. Approach the Pit from the same level as the entrance, going right from the portal, as jumping from above results in likely fatal fall damage.",
			{
				role = DAMAGE,
				"Melee damage dealers should attack once the tank secures aggro, and continue attacking through threat resets. Ranged damage dealers should maintain maximum distance to give the tank time to reestablish position after threat resets, reducing the risk of being hit by the boss's melee attacks.",
			},
			{
				role = HEALER,
				"Stay as far from the boss as possible while concentrating heals on the tank. Be ready for additional healing when party members are knocked airborne, potentially using shields to lessen fall damage.",
			},
			{
				role = TANK,
				"Engage Atal'alarion in the room's center and position him facing a wall to avoid his frontal cone attack, {spell:12887}, hitting other party members. Monitor which group members, especially the healer, are knocked into the air and kite the boss as needed to minimize damage when your healer is incapacitated.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Jammal'an the Prophet",
		encounterID = 5710,
		portrait = 607665,
		loot = { 10808, 10807, 10806,  },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Jammal'an the Prophet is a high-ranking Atal'ai priest within The Temple of Atal'Hakkar. His mastery of shadow magic and his devotion to the dark god Hakkar make him a formidable adversary. Jammal'an's presence in the temple highlights the Atal'ai trolls' commitment to serving the bloodthirsty deity.",
			{ heading = "Overview" },
			"Jammal'an is accessible in the Lair of the Chosen after defeating six Troll Mini Bosses. To reach his chamber, either return to the dungeon entrance and take the left path, or jump from the last defeated mini boss's platform onto a Dragonkin pack for immediate engagement. Clear the Pit of Sacrifice and all troll and Atal'ai Deathwalker mobs in the eastern passageway before facing Jammal'an, a level 54 Elite, alongside the level 53 Elite Ogom the Wretched.",
			{
				role = DAMAGE,
				"Initially target Ogom the Wretched due to his lower level and health. Strong melee damage dealers classes should consider off-tanking to quickly eliminate him. Maintain spacing to dodge {spell:12468} and reduce risks from {spell:12480}. Mages and Druids must actively decurse {spell:12741} from melee damage dealers and the tank.",
			},
			{
				role = HEALER,
				"Expect intense healing early on when both Ogom and Jammal'an are active. Keep everyone's health high to counteract damage from {spell:12468} and other attacks. Spread out to manage {spell:12480} effectively. Dispelling {spell:23952} and {spell:12741} from melee damage dealers and tanks is crucial.",
			},
			{
				role = TANK,
				"Assign a strong damage dealer class to off-tank Ogom, allowing the group to quickly reduce his threat. The main tank should isolate Jammal'an, establishing solid threat. Avoid clustering to dodge the {spell:12468} and spread out to minimize the impact of {spell:12480}, which transforms a player into a Berserker.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Weaver and Dreamscythe",
		encounterID = 5721,
		portrait = 608311,
		loot = { 12243, 10797, 12463, 10796, 10795, 12465, 12464, 12466 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Weaver and Dreamscythe is a malevolent entity that lurks within The Temple of Atal'Hakkar. A manifestation of the dark and twisted dreams that haunt the temple's depths, Dreamscythe embodies the surreal and nightmarish aspects of the Sunken Temple. Its presence serves as a reminder of the eerie and otherworldly forces at play.",
			{ heading = "Overview" },
			"Weaver and Dreamscythe, two drakes, spawn simultaneously in the Pit of Sacrifice after defeating Jammal'an the Prophet. They patrol the area on a similar path, making it crucial to engage only one at a time to avoid being overwhelmed.",
			{
				role = DAMAGE,
				"Both Melee and Ranged damage dealers should avoid the front of the drake to dodge its frontal cone attacks. Ensure the tank has established firm aggro before maximizing damage to maintain safe and effective combat.",
			},
			{
				role = HEALER,
				"Position yourself away from the drake's frontal area and focus your healing efforts on the Tank, as they will be receiving the majority of the damage. Other party members should ideally not be taking significant damage if positioned correctly.",
			},
			{
				role = TANK,
				"Engage the drakes one by one using a ranged pull to control the encounter. Pull the targeted drake into the hallway and position it against a wall facing away from the group. This positioning minimizes the knockback effects on the party and keeps members safe.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Hazzas and Morphaz",
		encounterID = 5722,
		portrait = 608311,
		loot = { 12243, 10797, 12463, 10796, 10795, 12465, 12464, 12466 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"Hazzas and Morphaz is a malevolent spirit bound to The Temple of Atal'Hakkar, cursed to protect the temple's secrets for all eternity. His tormented existence and spectral powers make him a formidable adversary. Hazzas's presence within the temple underscores the tragic fate of those who become ensnared by its dark forces.",
			{ heading = "Overview" },
			"Hazzas and Morphaz, the final two drake bosses in the Sunken Temple, share abilities and strategies with earlier drake bosses. They spawn simultaneously after the defeat of Dreamscythe and Weaver and patrol together, necessitating a joint engagement as they cannot be pulled separately.",
			{
				role = DAMAGE,
				"Both Melee and Ranged damage dealers should position themselves away from the bosses' fronts to avoid frontal cone attacks. Focus on maintaining high damage once the tank has securely established threat.",
			},
			{
				role = HEALER,
				"Position yourself to avoid the frontal attacks of the drakes and concentrate your healing on the Tank. Proper positioning by all party members should minimize any damage received outside of the tank.",
			},
			{
				role = TANK,
				"To manage the encounter, pull the drakes into the hallway and tank them against a wall facing away from the group. This position reduces the impact of the drakes' knockback abilities and shields other party members from harm.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Avatar of Hakkar",
		encounterID = 8443,
		portrait = 607548,
		loot = { 10846, 10843, 10842, 10845, 10838, 10844, 12462 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"The Avatar of Hakkar is a manifestation of the bloodthirsty god Hakkar the Soulflayer within The Temple of Atal'Hakkar. Its malevolent power and insatiable hunger for blood make it a terrifying foe. The Avatar's presence in the temple signifies the dark deity's influence over its chambers.",
			{ heading = "Overview" },
			"The Avatar of Hakkar encounter, requiring completion of the Ancient Egg questline from Tanaris, takes place in a smaller room on the western side of the Pit of Sacrifice. Start by killing adds and defeat four Hakkari Bloodkeepers to collect their Hakkari Blood, used to extinguish four braziers in the room. Before extinguishing the final brazier, have all group members stack against the wall to avoid proximity aggro from the boss, allowing time to recover, eat, drink, resurrect, or rebuff. Then, engage the Avatar of Hakkar.",
			{
				role = DAMAGE,
				"Maintain spacing and maximize damage output, ensuring the tank keeps the Hakkars attention. Use stuns or crowd control on any mind-controlled party members during {spell:12888} phases. Assist healers by dispelling {spell:10896} and decursing {spell:12889} from yourself and other casters.",
			},
			{
				role = HEALER,
				"The fight demands consistent attention to ensure everyone is fully healed, especially if mind-controlled by {spell:12888}. Focus on dispelling {spell:10896} and decursing {spell:12889} from yourself and casters to maintain effective spellcasting.",
			},
			{
				role = TANK,
				"Position the boss in the center of the room, maintaining threat throughout the encounter. Use stun or other crowd control techniques on any player affected by {spell:12888} to prevent them from harming the group.",
			}
		},
		abilities = {
			
		}
	},
	{
		name = "Shade of Eranikus",
		encounterID = 5709,
		portrait = 607768,
		loot = { 10836, 10837, 10833, 10828, 10835, 10829, 10847 },
		npcs = { 2135, 12456, 12314 },
		overview = {
			"The Shade of Eranikus is a corrupted green dragon who has fallen under the sway of the malevolent god Hakkar the Soulflayer within The Temple of Atal'Hakkar. Once a protector of nature, Eranikus's corruption has made him a formidable and tragic adversary. His presence in the temple highlights the destructive influence of Hakkar.",
			{ heading = "Overview" },
			"The Shade of Eranikus, can be found in the instance without a special summoning requirement. Ensure all dragonkin mobs in the instance are cleared before engaging this boss to prevent them from assisting Eranikus during the battle, which could lead to a group wipe. This boss presents a significant challenge, being tougher than other final bosses in similar 5-man content.",
			{
				role = DAMAGE,
				"Positioning is crucial in this fight. Ranged damage dealers should maintain maximum distance and avoid standing in front of Eranikus to dodge {spell:16740} and {spell:12533}. Utilize {spell:8177} to counteract {spell:12890}.",
			},
			{
				role = HEALER,
				"Prepare for a lengthy battle compared to other 5-man boss fights, managing your mana efficiently. Use {spell:8177} to negate {spell:12890} effects. Focus on keeping the tank well-healed, especially since they will be vulnerable during {spell:16740}, which prevents blocking.",
			},
			{
				role = TANK,
				"Engage Eranikus where he stands, positioning him to face away from the group to prevent {spell:12533} from hitting anyone else. Eranikus targets the highest threat player with {spell:12890}. Use a pet to tank initially until the first {spell:12890} cast, then switch to the primary tank. Alternatively, a secondary tank such as a Druid in Bear Form, Warrior, or Paladin using {spell:25780} can maintain the second highest threat to manage the boss while the primary tank recovers.",
			}
		},
		abilities = {
			
		}
	},
})
