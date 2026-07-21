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
	[522] = { scale = 1.00, y = 0.50, facing = -0.40 },
	[524] = { scale = 1.00, y = 0.50, facing = -0.10 },
	[1204] = { scale = 1.94, y = 0.50, z = 1.00 },
	[1269] = { scale = 2.33 },
	[2172] = { scale = 2.00, y = 0.50, z = 1.00 },
	[2606] = { scale = 1.41, z = -0.50 },
	[4203] = { scale = 2.23 },
	[5285] = { scale = 1.78, z = 0.50 },
	[5489] = { scale = 1.91, x = 4.50, facing = -0.00, pitch = -0.60 },
	[5781] = { scale = 0.78, y = 0.50, z = -26.50, facing = -0.10, pitch = -1.05 },
	[5988] = { scale = 3.12 },
	[6089] = { scale = 1.41, z = -1.50 },
	[6377] = { scale = 2.70, z = -1.00 },
	[7534] = { scale = 1.54 },
	[7864] = { scale = 1.88, y = -0.50, z = 0.50 },
	[7919] = { scale = 1.91 },
	[7970] = { scale = 1.44, y = 0.50 },
	[7971] = { scale = 1.76 },
	[8177] = { scale = 1.95 },
	[8329] = { scale = 1.51 },
	[8711] = { scale = 2.11, y = 1.00 },
	[9564] = { scale = 1.02 },
	[9732] = { scale = 0.84 },
	[9793] = { scale = 1.79 },
	[10115] = { scale = 2.54, y = 0.50, z = 0.50 },
	[10193] = { scale = 3.12, z = 0.50 },
	[10433] = { scale = 1.60, z = -0.50 },
	[10691] = { scale = 0.85, y = 0.50 },
	[10698] = { scale = 1.30, z = -0.50 },
	[10798] = { scale = 1.77 },
	[11069] = { scale = 1.20 },
	[11072] = { scale = 0.94 },
	[11172] = { scale = 1.41, z = -2.50, pitch = -0.55 },
	[11179] = { scale = 1.08, y = 0.50, facing = -0.50 },
	[11335] = { scale = 1.45, y = 0.50, facing = -0.30, pitch = -0.19 },
	[11380] = { scale = 3.89, z = 3.50, pitch = 0.75 },
	[11396] = { scale = 1.32, z = -0.50 },
	[11545] = { scale = 1.11 },
	[11561] = { scale = 1.12 },
	[11564] = { scale = 1.09 },
	[11565] = { scale = 1.05 },
	[11583] = { scale = 1.10 },
	[12073] = { scale = 1.17, y = 0.50, z = 0.50 },
	[12110] = { scale = 0.91, y = 0.50, z = -23.50, facing = -0.10, pitch = -1.10 },
	[12129] = { scale = 2.04, y = 0.50, z = 1.00, facing = -0.20 },
	[12162] = { scale = 4.19 },
	[12293] = { scale = 3.54 },
	[12334] = { scale = 1.45, y = 0.50 },
	[12350] = { scale = 1.82, y = -1.00 },
	[12389] = { scale = 1.72, y = 0.50, z = 0.50 },
	[12818] = { scale = 1.68, z = 0.50 },
	[13992] = { scale = 3.28, z = 5.50, pitch = 0.80 },
	[14173] = { scale = 3.19 },
	[14308] = { scale = 0.90 },
	[14367] = { scale = 0.85 },
	[14378] = { scale = 1.30 },
	[14383] = { scale = 3.82 },
	[14416] = { scale = 1.65, y = 0.50, facing = -0.30 },
	[15288] = { scale = 2.61, y = 1.00 },
	[15295] = { scale = 0.10, y = -5.00 },
	[15345] = { scale = 0.74 },
	[15392] = { scale = 2.41, y = 0.50, z = 0.50, facing = -0.20 },
	[15432] = { scale = 1.01 },
	[15509] = { scale = 0.76 },
	[15654] = { scale = 1.41 },
	[15686] = { scale = 0.98 },
	[15739] = { scale = 1.15, z = -1.00 },
	[15761] = { scale = 4.12, z = -1.00 },
	[15778] = { scale = 3.62, z = -1.00 },
	[15787] = { scale = 1.30 },
	[15945] = { scale = 1.64, z = 2.50 },
	[16033] = { scale = 4.07, z = 3.50, pitch = 0.65 },
	[16035] = { scale = 4.80, z = -1.50 },
	[16064] = { scale = 1.04 },
	[16137] = { scale = 1.08 },
	[16279] = { scale = 0.97 },
	[126697] = { scale = 0.29 },
	[129113] = { scale = 0.85, y = 0.50 },
})
