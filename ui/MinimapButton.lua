--[[ See license.txt for license and copyright information ]]
select(2, ...).SetupGlobalFacade()

--[[
	The minimap button, through LibDBIcon rather than by hand.

	It used to be a `Button` of our own, parented to `Minimap` and positioned from
	`Minimap:GetWidth()/2 + 10`. Two things were wrong with that, and only the
	second was ever about the maths:

	* **Nothing else could find it.** The collectors and hider addons
	  (MinimapButtonFrame, MinimapButtonBag, SexyMap) work by walking
	  LibDBIcon's registry, so a hand-rolled button is invisible to them. Ours
	  stayed put while every other addon's tucked away, which is what made it
	  the odd one out on a dressed-up UI.
	* **It clamped itself against UIParent.** `UpdatePosition` compared
	  `self:GetRight()` with `UIParent:GetRight()` and subtracted the overshoot.
	  Those two are in different coordinate spaces the moment the button's
	  effective scale is not UIParent's -- which on Forever is the normal case,
	  because `MinimapCluster` carries Edit Mode's size setting as a scale
	  (`EditModeMinimapSystemMixin:UpdateSystemSettingSize` calls
	  `SetEditModeScale`, off a 50-200% slider). So the clamp fired when nothing
	  was off screen and shifted the button inward, off the ring. The disabled
	  `--* scale` on both of those lines says it had been half-noticed.

	Its `OnUpdate` also re-pinned the button to `Minimap` whenever the map's
	shape or size changed, which actively undid anything a collector had done
	with it.

	LibDBIcon anchors to `Minimap`'s centre too, so the radius premise is the
	same one -- the difference is that it does not second-guess the result, and
	that every other button on the minimap is placed by the same code.
]]

MinimapButton = { }

-- LibDBIcon keys its registry by name, and the same string names the LDB object.
local LDB_NAME = "AdventureGuideClassic"

-- Where the hand-rolled button kept its state: its own frame name, at the top
-- level of SavedVariables.
local LEGACY_KEY = "AdventureGuideClassic-MinimapButton"

local dbIcon

--[[
	LibDBIcon writes the angle straight into this table as the button is dragged,
	so it has to be the one that is saved rather than a copy handed over at
	registration.
]]
local function Store()
	if (not SavedVariables) then return nil end
	SavedVariables.MinimapButton = SavedVariables.MinimapButton or { }
	return SavedVariables.MinimapButton
end

--[[
	Carry a player's existing button over.

	Two things differ: the old table held `position` in radians, LibDBIcon holds
	`minimapPos` in degrees; and `hidden` is spelled `hide`. Radians come from
	`atan2`, so they can be negative -- hence the modulo, which maps -2.888 (the
	old default) onto 194.5 rather than leaving it below zero where LibDBIcon
	would read it as most of a turn the other way.

	The old key is read and left alone. It costs nothing, and it means the
	migration cannot run twice: it only fires while the new table is still empty.
]]
local function Migrate(db)
	if (db.minimapPos or db.hide ~= nil) then return end
	local legacy = SavedVariables and SavedVariables[LEGACY_KEY]
	if (type(legacy) ~= "table") then return end
	if (type(legacy.position) == "number") then
		db.minimapPos = math.deg(legacy.position) % 360
	end
	if (legacy.hidden) then
		db.hide = true
	end
end

local function BuildDataObject(ldb)
	local existing = ldb:GetDataObjectByName(LDB_NAME)
	if (existing) then return existing end
	return ldb:NewDataObject(LDB_NAME, {
		type = "launcher",
		icon = "Interface\\EncounterJournal\\UI-EJ-PortraitIcon",
		OnClick = function()
			UI.ToggleEncounterJournal()
		end,
		--[[
			LibDBIcon owns the tooltip and has already pointed it at the button, so
			this adds lines and does not call Show.
		]]
		OnTooltipShow = function(tooltip)
			if (not tooltip) then return end
			--todo: Localize
			tooltip:AddLine("Adventure Guide")
			local bindingKey = GetBindingKey("TOGGLE_ADVENTUREGUIDECLASSIC")
			--todo: Localize
			if (bindingKey) then
				tooltip:AddLine(string.format("Press %s to toggle", bindingKey), 1, 1, 1)
			end
		end,
	})
end

--[[
	Called from Main.lua on ADDON_LOADED, which is the first moment
	SavedVariables exists. Missing libraries leave the journal working with no
	minimap button rather than erroring at load: `/agc` and the keybind are the
	other two ways in.
]]
function MinimapButton.Init()
	if (dbIcon) then return end
	if (not LibStub) then return end
	local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
	local icon = LibStub:GetLibrary("LibDBIcon-1.0", true)
	local db = Store()
	if (not (ldb and icon and db)) then return end
	Migrate(db)
	icon:Register(LDB_NAME, BuildDataObject(ldb), db)
	dbIcon = icon
end

--[[
	Whether there is a button at all. False only where the addon was repackaged
	without `lib/`, in which case the setting below it would be a live checkbox
	that does nothing.
]]
function MinimapButton.IsAvailable()
	return dbIcon ~= nil
end

function MinimapButton.IsShown()
	local db = Store()
	return not (db and db.hide)
end

function MinimapButton.SetShown(shown)
	local db = Store()
	if (not db) then return end
	db.hide = (not shown) or nil
	if (not dbIcon) then return end
	if (shown) then
		dbIcon:Show(LDB_NAME)
	else
		dbIcon:Hide(LDB_NAME)
	end
end

function MinimapButton.Toggle()
	MinimapButton.SetShown(not MinimapButton.IsShown())
end
