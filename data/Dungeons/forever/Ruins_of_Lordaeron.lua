--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Ruins of Lordaeron",
	thumbnail = I.UIEJDungeonButtonRuinsOfLordaeron,
	icon = 527422,
	splash = 527422,
	seasonFilter = "forever",
	overview = "The broken city above the Undercity, walked now by the dead of its own garrison. Six encounters spread across the alleys, the market and the overlook, two of them only appearing once something has been disturbed. Horde adventurers come up through the Undercity; the Alliance walk in from Southshore.",
	{
		name = "The Baron",
		defeated = 0,
		portrait = 521744,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"A skeletal lord holding court in the ruins with soldiers and mages still standing to attention around him.",
			{ heading = "Overview" },
			"A short fight with one spike in it. {spell:17307} takes close to half the tank's health and follows with a stun, so the tank wants to be near full whenever it is due.",
			{
				role = DAMAGE,
				"He can be stunned -- use what you have to cut the fight short. Clear the Skeletal Soldiers and Mages guarding him first.",
			},
			{
				role = HEALER,
				"Keep the tank topped off rather than reactive: {spell:17307} removes nearly half their health and then stuns them, so a late heal has nowhere to go.",
			},
			{
				role = TANK,
				"Stay high on health throughout. {spell:17307} is followed by a stun, and his ordinary swings are heavy as well.",
			}
		},
		abilities = {
			{ spell = 17307, heading = true }, -- Knockout
		}
	},
	{
		name = "Witherfang",
		defeated = 0,
		portrait = 521744,
		loot = {},
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
			{ spell = 3358, heading = true }, -- Leech Poison
		}
	},
	{
		name = "The Abandoned",
		defeated = 0,
		portrait = 521744,
		loot = {},
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
			{ spell = 1220855, heading = true }, -- Frost Nova
			{ spell = 1266011, heading = true }, -- Life Drain
		}
	},
	{
		name = "Bjork",
		defeated = 0,
		portrait = 521744,
		loot = {},
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
			{ spell = 1301635, heading = true }, -- Anti-Magic Shield
		}
	},
	{
		name = "Rath'mael",
		defeated = 0,
		portrait = 521744,
		loot = {},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"The last of the ruins' dead to still hold a position worth defending.",
			{ heading = "Overview" },
			"The final encounter, and not a hard one. {spell:1279983} puts fire on the ground and everything else is a matter of standing somewhere else.",
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
			{ spell = 1279983, heading = true }, -- Flamestrike
		}
	},
	{
		name = "Viktor the Vile",
		defeated = 0,
		portrait = 521744,
		loot = {},
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
			{ spell = 3358, heading = true }, -- Leech Poison
		}
	},
})
