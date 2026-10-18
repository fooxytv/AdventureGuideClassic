--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

InstanceService.AddDungeon({
	name = "City of Dalaran",
	icon = 527422,
	splash = 527422,
	mapID = 2959,
	seasonFilter = "forever",
	overview = "Dalaran as an instance, set down in the Alterac Mountains and entered through the northwest gate with the Dalaran Sewers Key. The run starts in the sewers and climbs into the city proper, where the Kirin Tor's work has got away from them -- loose arcane constructs, mana-starved horrors and a shade in the Purple Parlor.",
	{
		name = "Arcane Anomaly",
		defeated = 0,
		encounterID = 3298,
		portrait = 521744,
		loot = {
			{ id = 273031, filter = "forever" }, -- Runemender's Seal
			{ id = 273034, filter = "forever" }, -- Ephemeral Grips
			{ id = 273035, filter = "forever" }, -- Mana-Warped Chain Shirt
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"Raw magic that got loose on Krasus' Landing and never dispersed.",
			{ heading = "Overview" },
			"A two-ability fight with one thing to dodge. {spell:15230} lands for around 500 arcane on the tank and the boss hits hard physically besides. {spell:1241501} is a three-second channelled beam that sweeps round, clockwise or anticlockwise, and has to be walked out of.",
			{
				role = DAMAGE,
				"{spell:1241501} sweeps in one direction for three seconds -- move with it, not into it, and keep damaging the boss through it.",
			},
			{
				role = HEALER,
				"{spell:15230} is a hard spike for roughly 500 arcane, and {spell:1241501} adds damage on anyone slow to move.",
			},
			{
				role = TANK,
				"Heavy physical damage on top of {spell:15230}. Hold position where the group has room to walk out of the beam.",
			}
		},
		abilities = {
			{ spell = 15230 }, -- Arcane Bolt
			{ spell = 1241501 }, -- Focal Blast
		}
	},
	{
		name = "Fel Ancient",
		defeated = 0,
		encounterID = 3299,
		portrait = 521744,
		loot = {
			{ id = 273037, filter = "forever" }, -- Felbough Arm
			{ id = 273038, filter = "forever" }, -- Garb of Fallen Felbark
			{ id = 273039, filter = "forever" }, -- Blightleaf Rope
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"Barriered off in the centre of the city until Grindle Firespark is persuaded to drop them.",
			{ heading = "Overview" },
			"Unreachable until you talk to Grindle Firespark to bring the barriers down. Then it is a movement fight: {spell:1240706} leaves green pools that have to be left immediately, and {spell:22994} roots people in them.",
			{
				role = DAMAGE,
				"Leave the pools from {spell:1240706} the moment they appear. {spell:1044} clears the roots from {spell:22994} if anyone can cast it.",
			},
			{
				role = HEALER,
				"{spell:22994} roots for ten seconds and damages while it holds, so a rooted player standing in {spell:1240706} is the emergency to watch for.",
			},
			{
				role = TANK,
				"Keep the boss away from the pools so the group is not forced to choose between threat and footing.",
			}
		},
		abilities = {
			{ spell = 22994 }, -- Entangle
			{ spell = 1240706 }, -- Fel Timbers
			{ spell = 1044 }, -- Blessing of Freedom
		}
	},
	{
		name = "Mana Devourer",
		defeated = 0,
		encounterID = 3300,
		portrait = 521744,
		loot = {
			{ id = 273040, filter = "forever" }, -- Spine of the Devourer
			{ id = 273041, filter = "forever" }, -- Slitherwrap Girdle
			{ id = 273042, filter = "forever" }, -- Manascale Treads
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"A thing that feeds on magic, settled in near the Violet Hold where there is most of it to take.",
			{ heading = "Overview" },
			"A race against the group's own mana. {spell:1240750} takes 200 from everyone each time it goes out, so a slow kill becomes an impossible one. The whole room has to be cleared first -- anything left alive joins in.",
			{
				role = DAMAGE,
				"Clear the entire room before you start; anything still standing will join the fight. Then kill it before it has drained the group dry.",
			},
			{
				role = HEALER,
				"{spell:1240750} drains 200 mana from every player as well as damaging them, and {spell:1240738} is a sustained arcane bleed on the tank. Watch your own pool as closely as the group's health.",
			},
			{
				role = TANK,
				"{spell:1240738} lands on whoever holds threat and ticks arcane damage for the duration.",
			}
		},
		abilities = {
			{ spell = 1240738 }, -- Drain Vitality
			{ spell = 1240750 }, -- Debilitate
		}
	},
	{
		name = "Mana Elemental",
		defeated = 0,
		encounterID = 3301,
		portrait = 521744,
		loot = {
			{ id = 273043, filter = "forever" }, -- Wand of Mana Concentration
			{ id = 273044, filter = "forever" }, -- Violet Sorcerer's Robes
			{ id = 273045, filter = "forever" }, -- Drape of Shifting Energy
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
		name = "Unstable Sentinel",
		defeated = 0,
		encounterID = 3302,
		portrait = 521744,
		loot = {
			{ id = 273046, filter = "forever" }, -- Guardian's Dualblade
			{ id = 273047, filter = "forever" }, -- Unstable Crystalline Shoulderpads
			{ id = 273048, filter = "forever" }, -- Refractory Scaleguards
			{ id = 273099, filter = "forever" }, -- Blueprint: Spinning Wheel
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"One of the city's own guardians, left running in the trade district with nobody maintaining it.",
			{ heading = "Overview" },
			"Short and sharp. {spell:8374} is a frontal cleave, so the boss gets turned away from the group, and {spell:1241329} pulses out to twenty-five yards and has to be left. A stun landed before the cast stops it outright.",
			{
				role = DAMAGE,
				"Stay out of {spell:1241329} -- it pulses to twenty-five yards. Stunning the boss before the cast prevents it entirely.",
			},
			{
				role = HEALER,
				"Relatively hard hits on the tank, and not much else to track.",
			},
			{
				role = TANK,
				"{spell:8374} hits everything in front of you, so face it away from the group. It hits hard.",
			}
		},
		abilities = {
			{ spell = 8374 }, -- Arcing Smash
			{ spell = 1241329 }, -- Malfunction
		}
	},
	{
		name = "Shade of the Archmage",
		defeated = 0,
		encounterID = 3303,
		portrait = 521744,
		loot = {
			{ id = 273049, filter = "forever" }, -- Archmagister's Faceted Pendant
			{ id = 273051, filter = "forever" }, -- Violet Sorcerer's Mantle
			{ id = 273052, filter = "forever" }, -- Ponderous Orb
			{ id = 273103, filter = "forever" }, -- Blueprint: Arcane Salvager
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"Aran again, by the look of him, waiting in the Purple Parlor behind a portal that Archmage Modela opens near the keep.",
			{ heading = "Overview" },
			"A two-part loop. {spell:15230} hits the tank hard and {spell:1241515} sends a sphere travelling that nobody should be standing in front of, with {spell:28450} going out to twenty yards when it returns. At zero mana he casts {spell:1303598} on the group and then {spell:1303599} to refill, and the fight begins again when the polymorph breaks.",
			{
				role = DAMAGE,
				"Stay out of the sphere's path. When he empties his mana he will {spell:1303598} the group and {spell:1303599} back to full -- the fight restarts from there, so save nothing for a phase that is not coming.",
			},
			{
				role = HEALER,
				"{spell:28450} catches everyone within twenty yards once the sphere returns, and that is the window to heal hardest.",
			},
			{
				role = TANK,
				"{spell:15230} is intense arcane damage. Move him off wherever {spell:1241515} was cast rather than holding your ground.",
			}
		},
		abilities = {
			{ spell = 15230 }, -- Arcane Bolt
			{ spell = 1241515 }, -- Bounding Mana
			{ spell = 28450 }, -- Arcane Explosion
			{ spell = 1303598 }, -- Mass Polymorph
			{ spell = 1303599 }, -- Evocation
		}
	},
	{
		name = "Lyn the Ignored",
		defeated = 0,
		encounterID = 3310,
		portrait = 521744,
		loot = {
			{ id = 273053, filter = "forever" }, -- Tendonscraper Dagger
			{ id = 273054, filter = "forever" }, -- Cartilage Shapers
			{ id = 273055, filter = "forever" }, -- Bonepile Gaze
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"A secret, and summoned rather than found. The Tome of Dalaran is made by looting the Black Tome from Arugal's room in Shadowfang Keep and using it at the Ambermill ley line, and spent at a summoning circle in a side room before the Arcane Anomaly ramp.",
			{ heading = "Overview" },
			"Optional, and only reachable with the Tome of Dalaran in hand. {spell:1304473} punishes the tank for attacking, {spell:17228} hits the whole group, and {spell:1303266} adds bodies the group has to clear.",
			{
				role = DAMAGE,
				"Kill the adds from {spell:1303266} while keeping damage on the boss.",
			},
			{
				role = HEALER,
				"Decurse {spell:1304473} if you can. {spell:17228} lands on the whole group, so do not plan on single-target healing alone.",
			},
			{
				role = TANK,
				"{spell:1304473} damages you whenever you deal damage -- throttle your own output while it is up rather than pushing through it.",
			}
		},
		abilities = {
			{ spell = 1303266 }, -- Raise Dead
			{ spell = 17228 }, -- Shadow Bolt Volley
			{ spell = 1304473 }, -- Curse of Thorns
		}
	},
	{
		name = "Atrexis the Grave Knight",
		defeated = 0,
		encounterID = 3311,
		portrait = 521744,
		loot = {
			{ id = 273032, filter = "forever" }, -- Bonebinder's Signet
			{ id = 273033, filter = "forever" }, -- Gravespike Repeater
			{ id = 273036, filter = "forever" }, -- Graveweave Bindings
		},
		sharedLoot = {},
		rareLoot = {},
		veryRareLoot = {},
		extremelyRareLoot = {},
		npcs = {},
		overview = {
			"A death knight keeping the sewer approach, with three Kirin Tor Necromancers patrolling at his back raising whatever the city has left lying about.",
			{ heading = "Overview" },
			"The heaviest tank damage of the early dungeon. {spell:1303266} keeps producing adds for as long as the fight runs, so the group has to split attention. {spell:6713} strips the tank's weapon, and {spell:1303264} speeds him up on top of it.",
			{
				role = DAMAGE,
				"Kill the first few adds, then commit to the boss. Clear a couple of the three Kirin Tor Necromancers patrolling with him before you pull.",
			},
			{
				role = HEALER,
				"Heavy, constant tank damage, and the adds from {spell:1303266} will overwhelm the group if they are ignored. Expect to be busy throughout.",
			},
			{
				role = TANK,
				"Expect to take a lot. {spell:6713} targets whoever holds threat, so it is coming for you, and {spell:1303264} makes the rest of the fight faster.",
			}
		},
		abilities = {
			{ spell = 6713 }, -- Disarm
			{ spell = 1303266 }, -- Raise Dead
			{ spell = 3391 }, -- Thrash
			{ spell = 12057 }, -- Strike
			{ spell = 1303264 }, -- Unholy Frenzy
		}
	},
	{
		name = "Mana Wraith",
		defeated = 0,
		encounterID = 3312,
		portrait = 521744,
		loot = {},
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
})
