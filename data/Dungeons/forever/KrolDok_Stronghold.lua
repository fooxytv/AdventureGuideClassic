--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "Krol'dok Stronghold",
	icon = 527422,
	splash = 527422,
	mapID = 3039,
	seasonFilter = "forever",
	overview = "Travellers have been going missing across the Riverglades, and the trail ends at an ogre fortress on the hill above the river. The Krol'dok clan holds the walls, but Twilight's Hammer cultists have moved in beside them, and the chanting heard from inside after dark is theirs.",
	{
		name = "Slavecrusher Grox",
		defeated = 0,
		encounterID = 3450,
		portrait = 521744,
		loot = {
			{ id = 273101, filter = "forever" }, -- Blueprint: Expert Campfire
			{ id = 274995, filter = "forever" }, -- Slavecrusher Scepter
			{ id = 274996, filter = "forever" }, -- Resistance Breaker Spaulder
			{ id = 274997, filter = "forever" }, -- Chain of Binding
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 258966 },
		overview = {
			"The overseer of the ogre quarry, who keeps the stronghold's captives working at the end of a club.",
			{ heading = "Overview" },
			"Grox walks a patrol through the quarry, so wait for him to move off and clear a space before pulling. Once engaged he uses {spell:1280081} to drag the Redridge Prisoners nearby into the fight on his side.",
			{
				role = DAMAGE,
				"Clear the area around his patrol first. When {spell:1280081} brings prisoners in, deal with them quickly and return to Grox.",
			},
			{
				role = HEALER,
				"Expect extra damage on the tank whenever prisoners join the fight.",
			},
			{
				role = TANK,
				"Pull Grox into the space you cleared, and pick up the prisoners that {spell:1280081} calls in so they do not reach the healer.",
			}
		},
		abilities = {
			{ spell = 1280081 }, -- Force Compliance
		}
	},
	{
		name = "Twilight Commander Zarmok",
		defeated = 0,
		encounterID = 3452,
		portrait = 521744,
		loot = {
			{ id = 274998, filter = "forever" }, -- Shadowlight Athame
			{ id = 274999, filter = "forever" }, -- Shadecaster's Leggings
			{ id = 275000, filter = "forever" }, -- Zarmok's Plated Signet
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 258972 },
		overview = {
			"The officer in charge of the Twilight's Hammer force inside the walls, guarding the great gate that leads deeper into the fortress.",
			{ heading = "Overview" },
			"Zarmok patrols the compound in front of the gate; pull him once he has drifted away from the other cultists. {spell:1280011} hits everyone close to him and leaves a bleed behind, so melee will take steady damage for the whole fight. Killing him opens the gate.",
			{
				role = DAMAGE,
				"Melee will be caught by {spell:1280011}; ranged should keep their distance from him. Remove the bleed if your class can.",
			},
			{
				role = HEALER,
				"{spell:1280011} puts a bleed on everyone in range, on top of the tank's damage. Remove it where you can.",
			},
			{
				role = TANK,
				"Pull him against the wall away from the other cultists, and keep him turned away from the group.",
			}
		},
		abilities = {
			{ spell = 1280011 }, -- Rending Whirl
		}
	},
	{
		name = "Handler Ashka",
		defeated = 0,
		encounterID = 3453,
		portrait = 521744,
		loot = {
			{ id = 275001, filter = "forever" }, -- Bloodied Gutslicer
			{ id = 275002, filter = "forever" }, -- War Handler's Gaze
			{ id = 275003, filter = "forever" }, -- Worgbinder's Treads
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 259281 },
		overview = {
			"The keeper of the stronghold's wolf pens, who fights alongside her two war wolves, Snarlfang and Terrorhowl.",
			{ heading = "Overview" },
			"Ashka is never alone: Snarlfang and Terrorhowl join the fight with her. {spell:1282076} sends both wolves after a random player for a few seconds, so killing the wolves first takes the danger out of the encounter.",
			{
				role = DAMAGE,
				"Kill Snarlfang and Terrorhowl before Ashka. If {spell:1282076} sends them at you, move towards the tank.",
			},
			{
				role = HEALER,
				"{spell:1282076} puts both wolves on someone who is not the tank; be ready to heal whoever they chase.",
			},
			{
				role = TANK,
				"Hold Ashka and both wolves, and take the wolves back as soon as {spell:1282076} ends.",
			}
		},
		abilities = {
			{ spell = 1282076 }, -- Command: Kill!
		}
	},
	{
		name = "Nar'gurk",
		defeated = 0,
		encounterID = 3449,
		portrait = 521744,
		loot = {
			{ id = 267104, filter = "forever" }, -- Tome of Twilight
			{ id = 275004, filter = "forever" }, -- Chain of the Corruptor
			{ id = 275005, filter = "forever" }, -- Krol'dok Warplate Chest
			{ id = 275006, filter = "forever" }, -- Krol'dok Warplate Helmet
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 258964 },
		overview = {
			"An ogre magi who has thrown in with the Twilight's Hammer, working their magic from a summoning circle at the top of the main path.",
			{ heading = "Overview" },
			"Nar'gurk is joined by Twilight Warlocks and Shadowhide Curseweavers, whose damage over time adds up fast; control or kill them first. {spell:1280259} takes control of a player until they drop to half health, and {spell:1280262} adds Shadow damage to his melee.",
			{
				role = DAMAGE,
				"Deal with the casters first. If {spell:1280259} takes a party member, crowd control them or bring them down to half health to free them.",
			},
			{
				role = HEALER,
				"The adds spread magic damage across the group. A player under {spell:1280259} only breaks free at half health, so let them drop that far before healing them.",
			},
			{
				role = TANK,
				"{spell:1280262} makes his melee hit harder; use cooldowns while it is active, and keep a charmed player away from the healer.",
			}
		},
		abilities = {
			{ spell = 1280259 }, -- Convert
			{ spell = 1280262 }, -- Shadow Infusion
		}
	},
	{
		name = "Overseer Mugg",
		defeated = 0,
		encounterID = 3451,
		portrait = 521744,
		loot = {
			{ id = 267086, filter = "forever" }, -- Eye of Mugg
			{ id = 271721, filter = "forever" }, -- Krol'dok Ogre Key
			{ id = 275007, filter = "forever" }, -- Mugg's Jabber
			{ id = 275008, filter = "forever" }, -- Mugg's Crosser
			{ id = 275009, filter = "forever" }, -- Emblem of Slamming
			{ id = 275010, filter = "forever" }, -- Strongly Scented Hood
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = { 258968 },
		overview = {
			"The ogre who rules the stronghold, waiting in the great house at the top of the hill with two Krol'dok Centurions at his side.",
			{ heading = "Overview" },
			"Crowd control or kill the two Centurions first. Mugg fights with a weapon in each hand and changes them as the fight goes on: {spell:1282393} and then {spell:1282394} each raise his melee damage, and {spell:1282386} speeds up his attacks until his next change. He also leaps onto players, so the group should spread out.",
			{
				role = DAMAGE,
				"Deal with the Centurions first, then burn Mugg before his later weapon sets make him too much for the tank. Stay spread out.",
			},
			{
				role = HEALER,
				"Tank damage climbs with each weapon change; {spell:1282394} is the dangerous one. His leaps damage whoever he lands near.",
			},
			{
				role = TANK,
				"Save your cooldowns for {spell:1282394}, and expect {spell:1282386} to build up between weapon changes.",
			}
		},
		abilities = {
			{ spell = 1282386 }, -- Mugg's Fury
			{ spell = 1282393 }, -- Set of Maces
			{ spell = 1282394 }, -- Set of Mauls
		}
	},
})
