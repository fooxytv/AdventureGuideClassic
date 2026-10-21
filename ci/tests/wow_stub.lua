--[[
	A WoW client, in as little Lua as the addon's service and data layer needs.

	luacheck parses and check_globals approximates; this lets the addon actually run.
	It catches what neither can see -- load-order mistakes, indexing a nil table, an
	API branch never taken -- which otherwise surface only after a /reload in game.

	Deliberately small. It covers the roughly forty globals Compat.lua, services/ and
	data/ touch, taken from .luacheckrc's read_globals. The ui/ layer needs ScrollUtil,
	CreateDataProvider and CreateScrollBoxListLinearView on top of this; see the issue.

	__SetClient() is the point of the whole thing: the client's identity is four
	globals and one namespace, so one stub can present itself as Era, SoD, BCC or
	Forever and the addon can be loaded once per client. That is behaviour which
	otherwise needs four machines to check.
]]

--[[
	setfenv does not exist past Lua 5.1, and every addon file opens with
	SetupGlobalFacade(), whose whole body is setfenv(2, globalFacade).

	Rather than reimplement the facade, this captures it: the harness loads
	GlobalFacade.lua, calls the SetupGlobalFacade it exports, and takes the table
	handed to setfenv here. Every later file is then loaded with that table as its
	_ENV, which is what setfenv(2, ...) would have done. So the addon's own facade
	construction is under test, not a replica of it that could drift from it.
]]
_G.__CapturedFacade = nil
_G.setfenv = function(_, env)
	if env ~= nil then
		_G.__CapturedFacade = env
	end
end
_G.getfenv = function() return _G end

--------------------------------------------------------------------------------
-- Client identity
--------------------------------------------------------------------------------

--[[
	Forever reported WOW_PROJECT_MAINLINE until build 1.60.1.70205, which reports 18 --
	neither mainline nor classic. That change is what broke detection in 1.8.0 and is
	why "forever" and "forever_old" are both here: a fix has to satisfy both.
]]
local CLIENTS = {
	era = {
		version = "1.15.9", build = "60000", toc = 11509,
		projectID = 2, season = 0, tocFlavor = "vanilla", retailShaped = false,
	},
	sod = {
		version = "1.15.9", build = "60000", toc = 11509,
		projectID = 2, season = 2, tocFlavor = "vanilla", retailShaped = false,
	},
	tbc = {
		version = "2.5.4", build = "45000", toc = 20506,
		projectID = 2, season = 0, tocFlavor = "tbc", retailShaped = false,
	},
	forever = {
		version = "1.60.1", build = "70205", toc = 16001,
		projectID = 18, season = nil, tocFlavor = "camelot", retailShaped = true,
	},
	forever_old = {
		version = "1.60.1", build = "60000", toc = 16001,
		projectID = 1, season = nil, tocFlavor = "camelot", retailShaped = true,
	},
}

local client

function _G.__SetClient(name)
	client = assert(CLIENTS[name], "unknown client: " .. tostring(name))

	_G.WOW_PROJECT_MAINLINE = 1
	_G.WOW_PROJECT_CLASSIC = 2
	_G.WOW_PROJECT_ID = client.projectID

	_G.GetBuildInfo = function()
		return client.version, client.build, "Oct 2026", client.toc
	end

	-- C_Seasons is a Classic-line namespace and is simply absent on Forever, where
	-- reaching it unguarded is a hard error rather than a nil result. Leaving it nil
	-- is the whole point: it is what Compat.GetActiveSeason exists to survive.
	if client.season == nil then
		_G.C_Seasons = nil
	else
		_G.C_Seasons = {
			GetActiveSeason = function() return client.season end,
			HasActiveSeason = function() return client.season ~= 0 end,
		}
	end

	--[[
		Forever is mainline-derived, so its API surface is retail-shaped where the
		Classic line's is not. Presenting one shape to every client would leave half
		of every shim untested -- and the shim is the part most likely to be wrong.

		Only the three divergences this addon documents are modelled:

		- GetSpellInfo. The global is gone on the mainline family, Forever included,
		  where calling it is a nil-value error; C_Spell.GetSpellInfo replaces it and
		  returns a table rather than a list. Both Compat.GetSpellInfo branches are
		  therefore reachable, one per client.
		- C_Seasons, above.
		- The tab template. CharacterFrameTabButtonTemplate's defining file is gated
		  to the cata and mists game types, so on Forever it does not exist and the
		  mainline family's PanelTabButtonTemplate is what does.

		Deliberately not modelled: C_Item, C_KeyBindings and GetItemSubClassInfo. The
		addon guards all three, but which clients actually carry them is not recorded
		anywhere here, and a stub that guesses makes a test assert a fiction. They stay
		present everywhere until someone checks on a real client.
	]]
	if client.retailShaped then
		_G.GetSpellInfo = nil
		_G.C_Spell = {
			GetSpellInfo = function(spellID)
				if not spellID then return nil end
				return { name = "Spell " .. tostring(spellID), iconID = 1 }
			end,
			GetSpellTexture = function() return 1 end,
		}
		_G.PanelTabButtonTemplate = {}
		_G.CharacterFrameTabButtonTemplate = nil
	else
		-- The Classic global returns a list, and its third value is the icon.
		_G.GetSpellInfo = function(spellID)
			if not spellID then return nil end
			return "Spell " .. tostring(spellID), nil, 1
		end
		_G.C_Spell = nil
		_G.PanelTabButtonTemplate = nil
		_G.CharacterFrameTabButtonTemplate = {}
	end
end

function _G.__ClientName()
	return client and client.tocFlavor or nil
end

--------------------------------------------------------------------------------
-- Widgets
--------------------------------------------------------------------------------

--[[
	Any method not spelled out is a no-op returning nil, and every call is counted so
	a test can assert something was invoked.

	An unknown PascalCase key is treated as a method the stub has not bothered to
	implement; anything else stays nil. That distinction matters: a lower-case key is
	what the addon hangs its own child widgets off, and nil is exactly what an absent
	child looks like in the real client -- which is what the addon's `if frame.x then`
	guards are there to test.
]]
local calls = {}

local function record(name)
	calls[name] = (calls[name] or 0) + 1
end

function _G.__CallCount(name)
	return calls[name] or 0
end

local Widget = {}
Widget.__index = function(self, key)
	local method = rawget(Widget, key)
	if method then return method end
	if type(key) == "string" and key:match("^%u") then
		return function(...)
			record(key)
			return nil
		end
	end
	return nil
end

function Widget:SetScript(script, handler)
	self.__scripts = self.__scripts or {}
	self.__scripts[script] = handler
end

function Widget:GetScript(script)
	return self.__scripts and self.__scripts[script]
end

function Widget:HookScript(script, handler)
	self:SetScript(script, handler)
end

function Widget:RegisterEvent(event)
	self.__events = self.__events or {}
	self.__events[event] = true
end

function Widget:UnregisterEvent(event)
	if self.__events then self.__events[event] = nil end
end

function Widget:UnregisterAllEvents()
	self.__events = {}
end

function Widget:IsEventRegistered(event)
	return (self.__events and self.__events[event]) == true
end

function Widget:GetName() return self.__name end
function Widget:GetParent() return self.__parent end
function Widget:GetObjectType() return self.__kind end
function Widget:GetWidth() return 100 end
function Widget:GetHeight() return 100 end
function Widget:GetFrameLevel() return 1 end
function Widget:IsShown() return self.__shown == true end
function Widget:IsVisible() return self.__shown == true end
function Widget:Show() self.__shown = true; record("Show") end
function Widget:Hide() self.__shown = false; record("Hide") end
function Widget:SetShown(shown) self.__shown = shown and true or false end

local frames = {}

local function NewWidget(kind, name, parent)
	local frame = setmetatable({
		__kind = kind or "Frame",
		__name = name,
		__parent = parent,
		__shown = false,
	}, Widget)
	table.insert(frames, frame)
	if name then _G[name] = frame end
	return frame
end

-- Every frame ever created, so a test can reach one the addon keeps to itself. The
-- services' event frames are file-locals with no name, and the events they register
-- are the seam the restricted-event bugs hid in.
function _G.__Frames()
	return frames
end

function _G.__FireEvent(event, ...)
	local fired = 0
	for _, frame in ipairs(frames) do
		if frame.__events and frame.__events[event] then
			local handler = frame.__scripts and frame.__scripts.OnEvent
			if handler then
				handler(frame, event, ...)
				fired = fired + 1
			end
		end
	end
	return fired
end

_G.CreateFrame = function(kind, name, parent, template)
	record("CreateFrame")
	return NewWidget(kind, name, parent)
end

_G.UIParent = NewWidget("Frame", "UIParent")
_G.GameTooltip = NewWidget("GameTooltip", "GameTooltip")

--------------------------------------------------------------------------------
-- C_* namespaces
--------------------------------------------------------------------------------

_G.C_AddOns = {
	-- The loaded .toc is the client's own answer about what it is, and the only
	-- reliable Forever signal once the project id started moving between builds.
	GetAddOnMetadata = function(_, field)
		if field == "X-TocFlavor" then return client and client.tocFlavor end
		if field == "Version" then return "0.0.0-test" end
		return nil
	end,
	GetAddOnInfo = function(name)
		return name, name, "", true, nil
	end,
	IsAddOnLoaded = function() return false end,
}

local timers = {}

_G.C_Timer = {
	After = function(delay, callback)
		table.insert(timers, { delay = delay, callback = callback })
	end,
	NewTicker = function() return { Cancel = function() end } end,
}

-- Timers are queued rather than run, so a test decides when deferred work happens.
function _G.__RunTimers()
	local queued = timers
	timers = {}
	for _, timer in ipairs(queued) do
		timer.callback()
	end
	return #queued
end

_G.C_Seasons = nil   -- set by __SetClient

_G.C_Item = {
	DoesItemExistByID = function() return true end,
	IsItemDataCachedByID = function() return true end,
	RequestLoadItemDataByID = function() end,
	GetItemInfo = function() return nil end,
}

_G.C_Map = {
	GetMapInfo = function(mapID)
		if not mapID then return nil end
		return { mapID = mapID, name = "Zone " .. tostring(mapID), mapType = 3 }
	end,
	GetBestMapForUnit = function() return 1 end,
}

--[[
	The Encounter Journal, cold.

	Blizzard's UI calls C_EncounterJournal.OnOpen() when its frame is shown, and that
	UI does not load on Forever, so a first read genuinely reports nothing. Returning
	empty is therefore the honest default and the case ForeverContentService's
	"unknown beats hidden" rule is written for. __SetJournal() fills it when a test
	wants the other branch.
]]
local journal = {}

function _G.__SetJournal(instanceIDs)
	journal = instanceIDs or {}
end

_G.C_EncounterJournal = {
	InstanceHasLoot = function() return false end,
}

_G.EJ_GetNumTiers = function() return #journal > 0 and 1 or 0 end

_G.EJ_GetInstanceByIndex = function(index, isRaid)
	if isRaid then return nil end
	local id = journal[index]
	if not id then return nil end
	return id, "Journal instance " .. tostring(id)
end

_G.EJ_GetEncounterInfoByIndex = function() return nil end

_G.C_QuestLog = {
	IsQuestFlaggedCompleted = function() return false end,
	GetNumQuestLogEntries = function() return 0 end,
	GetInfo = function() return nil end,
	GetQuestIDForLogIndex = function() return nil end,
}

_G.C_CombatLog = {
	GetCurrentEventInfo = function() return nil end,
}

--------------------------------------------------------------------------------
-- Loose globals
--------------------------------------------------------------------------------

_G.GetInstanceInfo = function() return "Test Instance", "party", 1, "Normal", 5 end
_G.GetRealmName = function() return "TestRealm" end
_G.UnitName = function() return "Tester" end
--[[
	The player's class and level are settable, because what a class can wear and
	wield is exactly the kind of rule worth checking as more than one character.
	A test sets AGC_TEST_CLASS / AGC_TEST_LEVEL and the defaults stand otherwise.
]]
_G.AGC_TEST_CLASS = "WARRIOR"
_G.AGC_TEST_LEVEL = 60
_G.UnitClass = function()
	local token = _G.AGC_TEST_CLASS or "WARRIOR"
	return token:sub(1, 1) .. token:sub(2):lower(), token, 1
end
_G.UnitLevel = function() return _G.AGC_TEST_LEVEL or 60 end
_G.UnitFactionGroup = function() return "Alliance", "Alliance" end
_G.UnitGUID = function() return "Player-1-00000001" end
_G.GetInventoryItemID = function() return nil end
_G.GetItemInfo = function() return nil end
_G.GetItemInfoInstant = function() return nil end
_G.GetNumLootItems = function() return 0 end
_G.GetLootSlotLink = function() return nil end
_G.GetNumSavedInstances = function() return 0 end
_G.GetSavedInstanceInfo = function() return nil end
_G.CombatLogGetCurrentEventInfo = function() return nil end
_G.PlaySoundFile = function() end
_G.GetTime = function() return 1000.0 end
_G.INSTANCE_RESET_SUCCESS = "%s has been reset."
_G.RAID_CLASS_COLORS = setmetatable({}, {
	__index = function() return { r = 1, g = 1, b = 1, colorStr = "ffffffff" } end,
})
_G.Settings = {
	RegisterAddOnCategory = function() end,
	RegisterVerticalLayoutCategory = function() return {} end,
	CreateCheckbox = function() end,
	RegisterAddOnSetting = function() return {} end,
}
_G.SlashCmdList = {}

-- Blizzard's own, verbatim in behaviour: the widget types are built with it, so a
-- stub that merged differently would test a different inheritance chain.
_G.Mixin = function(object, ...)
	for i = 1, select("#", ...) do
		for key, value in pairs((select(i, ...))) do
			object[key] = value
		end
	end
	return object
end

_G.strsplit = function(sep, text)
	local out = {}
	for piece in tostring(text):gmatch("([^" .. sep .. "]+)") do
		table.insert(out, piece)
	end
	return table.unpack(out)
end

_G.wipe = function(t)
	for key in pairs(t) do t[key] = nil end
	return t
end

_G.time = os.time
_G.date = os.date

-- WoW's string metatable carries these; Lua's does not.
local stringMeta = getmetatable("")
stringMeta.__index.trim = function(self)
	return (self:gsub("^%s+", ""):gsub("%s+$", ""))
end

_G.__SetClient("era")
