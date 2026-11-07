--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

local component = UI.CreateComponent("EllesmereUISkin")

--[[
	EllesmereUI paints our frames in whatever theme the player has chosen and keeps
	them in sync when they change it, through the public API it documents as
	SKINNING_API.md. We hand it frames; it owns the look, and we never read its
	textures, fonts or settings.

	Forever only, and that is their gate rather than ours: EllesmereUI_ClientGate.lua
	allows an interface of 16000-19999 or 120100+ and blocks the suite on anything
	else, so on Era and BCC the `EllesmereUI` global is absent and every call here
	is skipped. There is nothing for Compat.lua to decide.
]]
local S

--[[
	Registration happens at load, but the callback fires at PLAYER_LOGIN -- and we
	have no frames at all by then, because `UI.Init()` is called from the first
	`/agc` rather than from ADDON_LOADED. So the callback only captures the facade
	and `PostInit` does the work, which is the moment the two-pass registry already
	defines as "every component's frames exist".

	Registered unconditionally, as the API asks: if the player has turned skinning
	off for us the callback simply never runs, so there is nothing to gate on.
]]
if (EllesmereUI and EllesmereUI.RegisterSkin) then
	EllesmereUI.RegisterSkin(addonName, function(facade)
		S = facade
	end)
end

--[[
	One guarded call for every primitive.

	The facade grows by version -- `SetTabSelection` arrived in api 2, `ItemButton`
	in 4 -- so a primitive missing on an older EllesmereUI is expected rather than
	an error, and so is a frame we have not built. Checking both here is what keeps
	the call sites to one line.

	Every primitive is idempotent by contract, so calling this again on an
	already-skinned frame costs one table lookup. That is what makes it safe to
	call from a refresh or creation path rather than only once.
]]
function component.Apply(primitive, frame, opts)
	if (not S or not frame) then
		return
	end
	local fn = S[primitive]
	if (fn) then
		fn(frame, opts)
	end
end

--[[
	Whether a skin is live, for a caller deciding whether to build something of
	its own instead. False when EllesmereUI is absent or the player has turned
	skinning off for us.
]]
function component.IsSkinned()
	return S ~= nil
end

local function SkinJournal()
	local journal = EncounterJournal
	if (not journal) then
		return
	end
	--[[
		`Shell` fades the template's own art and paints the theme backdrop over it
		rather than replacing the template, which is why PortraitFrameTemplate can
		stay exactly as it is.
	]]
	component.Apply("Shell", journal)
	component.Apply("Inset", journal.inset)
	component.Apply("Font", journal.title)
	-- PortraitFrameTemplate names its close button off the frame rather than
	-- exposing it as a field on every client, so try both.
	component.Apply("CloseButton", journal.CloseButton or _G[journal:GetName() .. "CloseButton"])
end

local function SkinTabs(components)
	local tabs = components.EncounterJournalTabs
	if (not tabs or not tabs.GetTab) then
		return
	end
	--[[
		`GetTab` returning nil past the end is the only count available -- the tab
		list is local to its own component. Capped so a change there cannot turn
		this into a spin.
	]]
	for index = 1, 16 do
		local tab = tabs.GetTab(index)
		if (not tab) then
			break
		end
		component.Apply("Tab", tab)
	end
end

local function SkinNavBar(components)
	local navBar = components.NavBar and components.NavBar.frame
	if (not navBar) then
		return
	end
	--[[
		`padInput` is ignored on a box that has not been anchored yet. The nav bar
		anchors its search box during its own `Init`, so by here it has a seat.
	]]
	component.Apply("EditBox", navBar.searchBox, { padInput = true })
end

local function SkinLootFilters()
	-- Named globals, so these are reachable without the Loot component exposing them.
	component.Apply("Dropdown", _G.AGCLootClassFilter)
	component.Apply("Dropdown", _G.AGCLootArmorFilter)
end

--[[
	Runs once every component's `Init` has returned, so the journal and the views
	built alongside it are real.

	Three things are deliberately not here because they do not exist yet: the
	dungeon map window, the item preview panel and the pooled loot rows are all
	built on first use. Each should call `component.Apply` from its own creation
	code, which is what keeping the facade is for, and is the natural next step
	rather than something this file can reach.
]]
function component.PostInit(components)
	if (not S) then
		return
	end
	SkinJournal()
	SkinTabs(components)
	SkinNavBar(components)
	SkinLootFilters()
end

UI.Add(component)
