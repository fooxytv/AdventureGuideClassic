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
})
