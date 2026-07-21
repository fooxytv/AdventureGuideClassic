--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: TomCat / TomCat's Gaming

Hand-tuned camera presets for the model viewer, for creatures the height-derived
default does not frame well. Height gets most models into frame, but a long
serpent and a tall giant of the same height want different framing, and some
models sit well off their own origin.

To add one: open the boss on the Model tab, run /agc modeltune, dial it in, hit
Save, then Export and paste the result here. Values saved in game live in
SavedVariables and take precedence over anything in this file, so clear the
saved copy (Reset) once a preset has been committed here.

	scale  camera distance; larger pulls back
	x      depth
	y      side to side
	z      up and down
	facing rotation in radians
]]
select(2, ...).SetupGlobalFacade()

ModelPresetService.Register({
	[522] = { scale = 1.00, y = 0.50, facing = -0.40, title = "Odo the Blindwatcher" },
	[524] = { scale = 1.00, y = 0.50, facing = -0.10, title = "Rethilgore" },
	[1204] = { scale = 1.94, y = 0.50, z = 1.00, title = "Lord Incendius" },
	[1269] = { scale = 2.33, title = "Sneed's Shredder" },
	[2172] = { scale = 2.00, y = 0.50, z = 1.00, title = "Pyroguard Emberseer" },
	[2606] = { scale = 1.41, z = -0.50, title = "Vectus" },
	[4203] = { scale = 2.23, title = "Skum" },
	[5285] = { scale = 1.78, z = 0.50, title = "Obsidian Sentinel" },
	[5489] = { scale = 1.91, x = 4.50, facing = -0.00, pitch = -0.60, title = "Hydrospawn" },
	[5781] = { scale = 0.88, y = 0.50, z = -24.00, facing = -0.10, pitch = -1.05, title = "Lord Roccor" },
	[5988] = { scale = 3.12, title = "Archaedas" },
	[6089] = { scale = 1.41, z = -1.50, title = "Ironaya" },
	[6377] = { scale = 2.70, z = -1.00, title = "Firemaw" },
	[7534] = { scale = 1.54, title = "Kirtonos the Herald" },
	[7864] = { scale = 1.88, y = -0.50, z = 0.50, title = "Glutton" },
	[7919] = { scale = 1.91, title = "Ras Frostwhisper" },
	[7970] = { scale = 1.44, y = 0.50, title = "Taragaman the Hungerer" },
	[7971] = { scale = 1.76, title = "Amnennar the Coldbringer" },
	[8177] = { scale = 1.95, title = "Phalanx" },
	[8329] = { scale = 1.51, title = "Ambassador Flamelash" },
	[8711] = { scale = 2.11, y = 1.00, title = "Overlord Wyrmthalak" },
	[9564] = { scale = 1.02, title = "Gizrul the Slavener" },
	[9732] = { scale = 0.84, title = "Shadow Hunter Vosh'gajin" },
	[9793] = { scale = 1.79, title = "Nerub'enkan" },
	[10115] = { scale = 2.54, y = 0.50, z = 0.50, title = "General Drakkisath" },
	[10193] = { scale = 3.12, z = 0.50, title = "The Beast" },
	[10433] = { scale = 1.60, z = -0.50, title = "The Ravenian" },
	[10691] = { scale = 0.85, y = 0.50, title = "Balnazzar" },
	[10698] = { scale = 1.30, z = -0.50, title = "Baroness Anastari" },
	[10798] = { scale = 1.77, title = "Ancient Stone Keeper" },
	[11069] = { scale = 1.20, title = "Instructor Malicia" },
	[11072] = { scale = 0.94, title = "Lord Alexei Barov" },
	[11172] = { scale = 1.41, z = -2.50, pitch = -0.55, title = "Noxxion" },
	[11179] = { scale = 1.08, y = 0.50, facing = -0.50, title = "Wolf Master Nandos" },
	[11335] = { scale = 1.45, y = 0.50, facing = -0.30, pitch = -0.19, title = "Zevrim Thornhoof" },
	[11380] = { scale = 3.89, z = 3.50, pitch = 0.75, title = "Nefarian" },
	[11396] = { scale = 1.32, z = -0.50, title = "Bloodmage Thalnos" },
	[11545] = { scale = 1.11, title = "Stomper Kreeg" },
	[11561] = { scale = 1.12, title = "Guard Mol'dar" },
	[11564] = { scale = 1.09, title = "Captain Kromcrush" },
	[11565] = { scale = 1.05, title = "Highlord Omokk" },
	[11583] = { scale = 1.10, title = "Urok Doomhowl" },
	[12073] = { scale = 1.17, y = 0.50, z = 0.50, title = "Rattlegore" },
	[12162] = { scale = 4.19, title = "Bael'Gar" },
	[12293] = { scale = 3.54, title = "Landslide" },
	[12334] = { scale = 1.45, y = 0.50, title = "Lord Vyletongue" },
	[12350] = { scale = 1.82, y = -1.00, title = "Celebras the Cursed" },
	[12389] = { scale = 1.72, y = 0.50, z = 0.50, title = "Razorlash" },
	[12818] = { scale = 1.68, z = 0.50, title = "Ramstein the Gorger" },
	[13992] = { scale = 3.28, z = 5.50, pitch = 0.80, title = "Vaelastrasz the Corrupt" },
	[14173] = { scale = 3.19, title = "Immol'thar" },
	[14308] = { scale = 0.90, title = "Broodlord Lashlayer" },
	[14367] = { scale = 0.85, title = "Chromaggus" },
	[14378] = { scale = 1.30, title = "Lethtendris" },
	[14383] = { scale = 3.82, title = "Tendris Warpwood" },
	[14416] = { scale = 1.65, y = 0.50, facing = -0.30, title = "Alzzin the Wildshaper" },
})
