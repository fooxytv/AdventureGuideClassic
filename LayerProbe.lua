--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
	Layer / shard probe, `/agc layer`.

	No client exposes a layer API, so the only signal is the zoneUID buried in a
	world object's GUID -- `Creature-0-serverID-instanceID-zoneUID-npcID-spawnUID`,
	the same layout `Probe.lua` reads npcIDs out of. Every creature on one layer
	reports the same zoneUID and a different one once the player has been moved to
	another, which is what every layer addon keys on.

	A player's own GUID carries none of it (`Player-serverID-playerUID`), so this
	needs a creature to read: the target, the mouseover, a visible nameplate, or a
	group member's target. It looks only when asked -- no events, no frames, nothing
	running when it is not in use.

	Diagnostic only. Nothing in the addon reads a layer and no view shows one.
]]
LayerProbe = { }

local function Header(text)
	print("|cffff9900[AGC]|r |cffffffff" .. text .. "|r")
end

local function Line(label, value)
	print("  |cffffd100" .. label .. ":|r", tostring(value))
end

local function Warn(text)
	print("  |cffff5555" .. text .. "|r")
end

-- The GUID types that carry a zoneUID. A player's does not.
local WORLD_OBJECT = {
	Creature = true,
	Vehicle = true,
	Pet = true,
	GameObject = true,
}

-- zoneUID, instanceID, serverID and the GUID for a unit, or nil when it has none
-- to give. A zoneUID of 0 is the client saying it does not know one yet.
local function ReadUnit(unit)
	local guid = UnitGUID(unit)
	if (not guid) then
		return
	end
	local kind, _, serverID, instanceID, zoneUID = strsplit("-", guid)
	if (not WORLD_OBJECT[kind]) then
		return
	end
	zoneUID = tonumber(zoneUID)
	if (not zoneUID or zoneUID == 0) then
		return
	end
	return zoneUID, tonumber(instanceID), tonumber(serverID), guid
end

--[[
	Deliberate selections first, then whatever happens to be on screen, then the
	group's. The last one is for standing in a city with nameplates off and nothing
	selected, which is exactly where a layer matters and where there is least to read.
]]
local function Scan()
	for _, unit in ipairs({ "target", "mouseover", "npc", "focus" }) do
		local zoneUID, instanceID, serverID, guid = ReadUnit(unit)
		if (zoneUID) then
			return zoneUID, instanceID, serverID, guid, unit
		end
	end

	if (C_NamePlate and C_NamePlate.GetNamePlates) then
		for _, plate in ipairs(C_NamePlate.GetNamePlates() or { }) do
			local unit = plate and plate.namePlateUnitToken
			if (unit) then
				local zoneUID, instanceID, serverID, guid = ReadUnit(unit)
				if (zoneUID) then
					return zoneUID, instanceID, serverID, guid, unit
				end
			end
		end
	end

	local prefix = IsInRaid() and "raid" or "party"
	for index = 1, (GetNumGroupMembers() or 0) do
		local unit = prefix .. index .. "target"
		local zoneUID, instanceID, serverID, guid = ReadUnit(unit)
		if (zoneUID) then
			return zoneUID, instanceID, serverID, guid, unit
		end
	end
end

-- Every zoneUID seen this session, so a layer change shows up as a second entry.
local seen = { }

local function Record(zoneUID, zone)
	local entry = seen[zoneUID]
	if (not entry) then
		entry = { reads = 0, first = date("%H:%M:%S") }
		seen[zoneUID] = entry
	end
	entry.reads = entry.reads + 1
	entry.last = date("%H:%M:%S")
	entry.zone = zone or entry.zone
	return entry
end

local function SortedIds()
	local ids = { }
	for id in pairs(seen) do
		ids[#ids + 1] = id
	end
	table.sort(ids)
	return ids
end

--[[
	A layer *number* is a local convention, not something the server tells anyone:
	addons sort the zoneUIDs they have seen and count from one. So this answers
	"which of the layers this session has met", and two players' numbers only agree
	once they have met the same set. The zoneUID is the part that is comparable.
]]
local function IndexOf(zoneUID)
	local ids = SortedIds()
	for index, id in ipairs(ids) do
		if (id == zoneUID) then
			return index, #ids
		end
	end
	return nil, #ids
end

function LayerProbe.Report()
	Header("Layer probe")

	local zoneUID, instanceID, serverID, guid, source = Scan()
	if (not zoneUID) then
		Warn("Nothing in range carries a layer id.")
		print("  Target a creature, mouse over one, or let a nameplate show, then run it again.")
		return
	end

	local zone = GetRealZoneText() or GetZoneText()
	Record(zoneUID, zone)
	local index, total = IndexOf(zoneUID)

	Line("Layer", string.format("%d of %d seen this session", index, total))
	Line("zoneUID", zoneUID)
	Line("Zone", zone)
	Line("Read from", source .. " (" .. tostring(UnitName(source) or "?") .. ")")
	Line("instanceID", instanceID)
	Line("serverID", serverID)
	Line("GUID", guid)

	if (IsInInstance()) then
		Warn("Inside an instance: that id is this instance's own, not a world layer.")
	end

	if (total > 1) then
		Header("Seen this session")
		for position, id in ipairs(SortedIds()) do
			local entry = seen[id]
			print(string.format("    |cff00ff00%d|r  zoneUID %s  %s  first %s, last %s  (%d reads)",
				position, tostring(id), tostring(entry.zone or "?"),
				tostring(entry.first), tostring(entry.last), entry.reads))
		end
	end
end

_G.AGC_Layer = LayerProbe.Report
