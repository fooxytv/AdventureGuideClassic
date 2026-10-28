--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Ruins of Lordaeron",
	thumbnail = I.UIEJDungeonButtonRuinsOfLordaeron,
	icon = I.UIEJDungeonPortraitRuinsOfLordaeron,
	splash = I.UIEJLoreBGRuinsOfLordaeron,
	mapID = 2999,
	seasonFilter = "forever",
	overview = "The broken city above the Undercity, walked now by the dead of its own garrison. Seven encounters spread across the alleys, the market and the overlook, several of them only appearing once something has been disturbed. Horde adventurers come up through the Undercity; the Alliance walk in from Southshore.",
	{
		name = "Witherfang",
		defeated = 0,
		encounterID = 3353,
		portrait = 521744,
		loot = {
			{ id = 271201, filter = "forever" }, -- Atrophic Girdle
			{ id = 271202, filter = "forever" }, -- Witherbite Bracers
			{ id = 271203, filter = "forever" }, -- Segmented Spider Leg
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"Something that was a hound once, still running its circuit of Kings Alley with two of its kind behind it.",
			{ heading = "Overview" },
			"A patrol pull before it is a fight. Clear his route first and there is only {spell:3358} on the tank to manage.",
			{
				role = DAMAGE,
				"Kill Witherfang before his two adds -- they are the easier half.",
			},
			{
				role = HEALER,
				"Light work. {spell:3358} on the tank is the only sustained damage.",
			},
			{
				role = TANK,
				"He patrols Kings Alley; clear the mobs along that route before pulling or they arrive mid-fight.",
			}
		},
		abilities = {
			{ spell = 3358 }, -- Leech Poison
		}
	},
	{
		name = "The Abandoned",
		defeated = 0,
		encounterID = 3357,
		portrait = 521744,
		loot = {
			{ id = 271207, filter = "forever" }, -- Rotmender's Leggings
			{ id = 271208, filter = "forever" }, -- Grip of Fear
			{ id = 271216, filter = "forever" }, -- Scepter of the Abandoned
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"Called up out of the Market Square statue, which shakes before he arrives, and preceded by three waves of the dead.",
			{ heading = "Overview" },
			"Three waves of adds come first, then the boss. {spell:1266011} is the fight: a cast on the tank that can simply be stopped. {spell:1220855} freezes the group in place, and melee are chilled for striking him.",
			{
				role = DAMAGE,
				"Stun him as {spell:1266011} begins casting and it never lands. Melee will be chilled for hitting him -- that is unavoidable, not a mistake.",
			},
			{
				role = HEALER,
				"{spell:1266011} is sustained damage on the tank whenever it gets through, so the fight is much easier if the group lands its interrupts.",
			},
			{
				role = TANK,
				"Hold through {spell:1266011} and expect {spell:1220855} to lock the group up briefly.",
			}
		},
		abilities = {
			{ spell = 1220855 }, -- Frost Nova
			{ spell = 1266011 }, -- Life Drain
		}
	},
	{
		name = "The Butcher",
		defeated = 0,
		encounterID = 3355,
		portrait = 521744,
		loot = {
			{ id = 271204, filter = "forever" }, -- Meathook Slicer
			{ id = 271205, filter = "forever" }, -- Abomination Bones
			{ id = 271206, filter = "forever" }, -- Leftover Abomination Skin
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
	{
		name = "Rath'mael",
		defeated = 0,
		encounterID = 3354,
		portrait = 521744,
		loot = {
			{ id = 271213, filter = "forever" }, -- Mirror of Rath'mael
			{ id = 271214, filter = "forever" }, -- Rotmender's Treads
			{ id = 271215, filter = "forever" }, -- Coldspire Staff
			{ id = 273085, filter = "forever" }, -- Blueprint: Fermenter
			{ id = 273103, filter = "forever" }, -- Blueprint: Arcane Salvager
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"The last of the ruins' dead to still hold a position worth defending.",
			{ heading = "Overview" },
			"Not a hard fight. {spell:1279983} puts fire on the ground and everything else is a matter of standing somewhere else.",
			{
				role = DAMAGE,
				"Move out of {spell:1279983}. He can be stunned to cut his casts short entirely.",
			},
			{
				role = HEALER,
				"Low sustained damage if the group moves out of {spell:1279983} -- most of what you heal here is avoidable.",
			},
			{
				role = TANK,
				"Straightforward to hold; keep him out of his own {spell:1279983}.",
			}
		},
		abilities = {
			{ spell = 1279983 }, -- Flamestrike
		}
	},
	{
		name = "Lordaeron Captain",
		defeated = 0,
		encounterID = 3408,
		portrait = 521744,
		loot = {
			{ id = 6641, filter = "forever" }, -- Haunting Blade
			{ id = 6642, filter = "forever" }, -- Phantom Armor
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"Encounter details for this boss are not yet recorded. The client lists it, but no tactics have been confirmed for it.",
		},
		abilities = {
		}
	},
	{
		name = "Viktor the Vile",
		defeated = 0,
		encounterID = 3411,
		portrait = 521744,
		loot = {
			{ id = 271211, filter = "forever" }, -- Vilewalkers
			{ id = 271212, filter = "forever" }, -- Bloodied Chestwraps
			{ id = 271218, filter = "forever" }, -- Vileblood Scimitar
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"Summoned rather than found: someone has to climb the chimney of the house southwest of Lordamere Overlook, and then survive five waves before he turns up on the sixth.",
			{ heading = "Overview" },
			"Optional, and easy once reached -- the cost is the five waves of adds in front of him. Mana and health are tight by the time he arrives, which is the real reason groups skip him. {spell:3358} is his only trick.",
			{
				role = DAMAGE,
				"Skippable. If you want him, click the chimney of the house southwest of Lordamere Overlook and hold through five waves; he arrives on the sixth.",
			},
			{
				role = HEALER,
				"Conserve mana through the waves. There is no pause before the boss, so whatever you spend getting there is gone.",
			},
			{
				role = TANK,
				"Build threat quickly when Viktor spawns -- he hits hard, and he arrives into a group that has just fought five waves.",
			}
		},
		abilities = {
			{ spell = 3358 }, -- Leech Poison
		}
	},
	{
		name = "Bjork",
		defeated = 0,
		encounterID = 3412,
		portrait = 521744,
		loot = {
			{ id = 271209, filter = "forever" }, -- Bonerust Leggings
			{ id = 271210, filter = "forever" }, -- Tuskwrap Belt
			{ id = 271217, filter = "forever" }, -- Corpse Chopper
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"A patrolling horror working the centre of the ruins, with the deadly ghoul packs for company.",
			{ heading = "Overview" },
			"Barely a fight once the pull is clean. {spell:1301635} only holds for three seconds, so the answer is to wait it out rather than to burn through it.",
			{
				role = DAMAGE,
				"Let {spell:1301635} fade -- three seconds -- then burn him down. Keep him off the nearby trash, the ghouls especially.",
			},
			{
				role = HEALER,
				"Little to manage.",
			},
			{
				role = TANK,
				"Pull him away from the ghoul packs patrolling the centre; they are the real threat here.",
			}
		},
		abilities = {
			{ spell = 1301635 }, -- Anti-Magic Shield
		}
	},
})
