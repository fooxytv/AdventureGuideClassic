--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "The Drowned City",
	icon = 527422,
	splash = 527422,
	mapID = 2970,
	seasonFilter = "forever",
	overview = "I'lalai was a troll city that the sea swallowed long ago, and it has now risen again off the coast of Stranglethorn on Gillijim's Isle. Brinescale naga, Saltseer pirates and trolls who refused to stay dead are all fighting over its flooded streets, and whatever kept its old priests alive is waiting at the bottom of it.",
	{
		name = "Zul'Alai",
		defeated = 0,
		encounterID = 3474,
		portrait = 521744,
		loot = {
			{ id = 274598, filter = "forever" }, -- Bloodslash Axe
			{ id = 274599, filter = "forever" }, -- Oathbound Bracers
			{ id = 274600, filter = "forever" }, -- Berserker Shackles
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 258905 },
		overview = {
			"A troll warrior of I'lalai who came back up with the city and still holds the way in, sworn to it past his own death.",
			{ heading = "Overview" },
			"A damage race with a hard finish. {spell:1282504} stuns everyone near him after a short cast, {spell:1282519} slows whoever it hits, and at 30% health {spell:1282511} makes him regenerate and swing faster, so save cooldowns for the last third.",
			{
				role = DAMAGE,
				"Ranged should keep their distance from {spell:1282504}; melee step out when the cast starts. Spend everything once {spell:1282511} goes up.",
			},
			{
				role = HEALER,
				"Dispel {spell:1282519} and expect the tank's damage to climb sharply after {spell:1282511}.",
			},
			{
				role = TANK,
				"Use a defensive cooldown for the final 30%, when {spell:1282511} speeds up his attacks and starts healing him.",
			}
		},
		abilities = {
			{ spell = 1282504 }, -- Monstrous Slam
			{ spell = 1282519 }, -- Rotted Strike
			{ spell = 1282511 }, -- Undying Oath
		}
	},
	{
		name = "Var'Taka",
		defeated = 0,
		encounterID = 3475,
		portrait = 521744,
		loot = {
			{ id = 274601, filter = "forever" }, -- Harpoon of Command
			{ id = 274602, filter = "forever" }, -- Brinebelly Leggings
			{ id = 274613, filter = "forever" }, -- Priestess Cloak
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 258924 },
		overview = {
			"The Brinescale naga leader who has claimed the ruins, kept standing by the two priestesses at its side.",
			{ heading = "Overview" },
			"Two Brinescale Priestesses heal Var'Taka throughout, so deal with them before anything else. Var'Taka cleaves in front, and {spell:1282615} drags a player straight in, often into that cleave.",
			{
				role = DAMAGE,
				"Interrupt or crowd control the Brinescale Priestesses, or kill them first. If {spell:1282615} pulls you in, get out of the cleave straight away.",
			},
			{
				role = HEALER,
				"Watch for whoever {spell:1282615} lands on; a player pulled into the cleave takes a lot of damage at once.",
			},
			{
				role = TANK,
				"Keep Var'Taka turned away from the group so only you take the cleave.",
			}
		},
		abilities = {
			{ spell = 1282615 }, -- Harpoon
		}
	},
	{
		name = "Captain Dreadrise",
		defeated = 0,
		encounterID = 3476,
		portrait = 521744,
		loot = {
			{ id = 274603, filter = "forever" }, -- Dreadfrost Saber
			{ id = 274604, filter = "forever" }, -- Frosty Blunderbuss
			{ id = 274605, filter = "forever" }, -- Briny Sash
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 260042 },
		overview = {
			"Captain of the Saltseer pirates, walking the edge of the central pool while his crew strips the city of anything worth selling.",
			{ heading = "Overview" },
			"Dreadrise patrols the north side of the central pool. {spell:1282842} seals a random player in a drowning bubble that has to be broken from outside, and {spell:1282860} hits the whole group unless it is interrupted.",
			{
				role = DAMAGE,
				"Switch to the bubble as soon as {spell:1282842} traps someone, then go back to the captain. Keep an interrupt ready for {spell:1282860}.",
			},
			{
				role = HEALER,
				"The player inside {spell:1282842} keeps taking damage until the bubble breaks, and an uninterrupted {spell:1282860} hits everyone.",
			},
			{
				role = TANK,
				"Watch his patrol and pull him clear of the pirates around the pool.",
			}
		},
		abilities = {
			{ spell = 1282842 }, -- Embrine
			{ spell = 1282860 }, -- Waterbolt Volley
		}
	},
	{
		name = "Deathless Guardians",
		defeated = 0,
		encounterID = 3478,
		portrait = 521744,
		loot = {
			{ id = 274606, filter = "forever" }, -- Bloodspine Staff
			{ id = 274607, filter = "forever" }, -- Viscera Spaulders
			{ id = 274614, filter = "forever" }, -- Knucklebone Ring
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 260202, 260213, 268478 },
		overview = {
			"The Deathless Guardians gather around Deathless Marrow, a thing of blood and bone raised at the western altar, with the undying servants of the old city answering its call.",
			{ heading = "Overview" },
			"Deathless Marrow has a very large health pool and calls in waves of three: a Deathless Guardian, a Deathless Sorcerer and a Deathless Watcher. Each add killed raises the group's damage against the boss by 20%, so build stacks on the waves before burning it, while {spell:1283034} keeps hitting the whole group.",
			{
				role = DAMAGE,
				"Kill the Deathless Guardian first in each wave, since it can stun. Turn the stacks from the adds into damage on Deathless Marrow before the next wave arrives.",
			},
			{
				role = HEALER,
				"{spell:1283034} is steady group damage for the whole fight. Pace your mana; this is a long encounter.",
			},
			{
				role = TANK,
				"Pick up each wave as it arrives and keep the adds together so they can be cleaved or crowd controlled.",
			}
		},
		abilities = {
			{ spell = 1283034 }, -- Bloodbolt
		}
	},
	{
		name = "Primeval Elemental",
		defeated = 0,
		encounterID = 3511,
		portrait = 521744,
		loot = {
			{ id = 274611, filter = "forever" }, -- Robe of the Drowned
			{ id = 274612, filter = "forever" }, -- Waterlogged Burial Shroud
			{ id = 274615, filter = "forever" }, -- Heart of the Primeval
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 263886, 273738 },
		overview = {
			"An ancient water elemental lying dormant in the flooded chambers beneath the city, surrounded by the trolls who were given to it.",
			{ heading = "Overview" },
			"An optional boss, reached by swimming down into the pool in the southern part of the city. It wakes once the Undying Offering trolls in the round chamber below are dead. {spell:1290978} hits the tank and can be interrupted, and {spell:1290980} slows the whole group.",
			{
				role = DAMAGE,
				"Interrupt {spell:1290978}. The fight is underwater, so water breathing helps everyone.",
			},
			{
				role = HEALER,
				"{spell:1290980} is channeled damage on the group with a slow; keep the party topped up through it.",
			},
			{
				role = TANK,
				"Clear the Undying Offering trolls to bring the boss out, then hold it where the group can reach it while swimming.",
			}
		},
		abilities = {
			{ spell = 1290978 }, -- Waterbolt
			{ spell = 1290980 }, -- Freeze Water
		}
	},
	{
		name = "Min'loth the Serpent",
		defeated = 0,
		encounterID = 3479,
		portrait = 521744,
		loot = {
			{ id = 274608, filter = "forever" }, -- Maw of Min'loth
			{ id = 274609, filter = "forever" }, -- Serpentbane Crown
			{ id = 274610, filter = "forever" }, -- Ritual-Binder's Gloves
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 260243, 260274 },
		overview = {
			"The troll at the far west end of the city, last of what holds I'lalai, who sheds his troll shape for a serpent's form once pressed.",
			{ heading = "Overview" },
			"A two-phase fight. Min'loth starts in troll form with a heavy hit on the tank and some damage on the group. When that form is beaten he becomes a serpent, poisoning the whole party with a bolt volley and fearing players.",
			{
				role = DAMAGE,
				"The first phase is the easy one; save cooldowns for the serpent, and keep away from other packs in case a fear sends you into them.",
			},
			{
				role = HEALER,
				"In the serpent phase, cleanse the poison or heal through it with group healing, and be ready for players to be feared out of range.",
			},
			{
				role = TANK,
				"Expect heavy hits in troll form, and pick the serpent back up quickly after each fear.",
			}
		},
		abilities = {
		}
	},
})
