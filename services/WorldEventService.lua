--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
Answers "which world events are live right now?" against the static table in
data/WorldEvents.lua.

No calendar API is used -- C_Calendar shipped with 3.0 and does not exist on Era or
BCC. See the header of data/WorldEvents.lua for the data contract.

Every public function takes an optional `today` so the date logic can be exercised
against arbitrary dates rather than only whatever day it happens to be. `today` is
{ year, month, day, weekday } with weekday 1 = Sunday, matching both Blizzard's
calendar tables and Lua's date("*t").wday.
]]

WorldEventService = { }

local events = { }

function WorldEventService.AddEvent(event)
	table.insert(events, event)
end

local function IsBurningCrusade()
	return select(4, GetBuildInfo()) >= 20000
end

--[[
Today's date, preferring the client's own clock. C_DateAndTime's shape has changed
across versions, so try the known accessors before falling back to Lua's date(), which
reads the local machine instead of the realm but is never wrong about the calendar.
]]
function WorldEventService.GetToday()
	if C_DateAndTime then
		local info
		if C_DateAndTime.GetCurrentCalendarTime then
			info = C_DateAndTime.GetCurrentCalendarTime()
		elseif C_DateAndTime.GetTodaysDate then
			info = C_DateAndTime.GetTodaysDate()
		end
		-- Require actual numbers, not merely present fields: a malformed or stubbed
		-- table would otherwise reach time() and throw.
		if info and type(info.year) == "number"
			and type(info.month) == "number"
			and type(info.monthDay) == "number" then
			-- Derive the weekday from the date rather than trusting info.weekday to be
			-- present. Defaulting it would silently shift the Darkmoon Faire by days.
			return WorldEventService.MakeDate(info.year, info.month, info.monthDay)
		end
	end
	local t = date("*t")
	return { year = t.year, month = t.month, day = t.day, weekday = t.wday }
end

-- Builds a normalised date table, computing the weekday from the calendar so callers
-- never have to supply one. Exposed so tests and debug helpers can build any date.
function WorldEventService.MakeDate(year, month, day)
	local t = date("*t", time({ year = year, month = month, day = day, hour = 12 }))
	return { year = t.year, month = t.month, day = t.day, weekday = t.wday }
end

-- Whole days since the epoch. Built from time() so month and year boundaries take
-- care of themselves; midday avoids any daylight-saving edge at midnight.
local function DayNumber(year, month, day)
	local stamp = time({ year = year, month = month, day = day, hour = 12 })
	if not stamp then return nil end
	return math.floor(stamp / 86400)
end

local function MonthDay(month, day)
	return month * 100 + day
end

--[[
The day of the month on which the first Monday falls.

Derived from today's weekday rather than a calendar lookup: stepping back
(day - 1) days from today gives the weekday of the 1st, and Monday is weekday 2.
Lua's % is floored, so the negative intermediate wraps correctly.
]]
local function FirstMondayOfMonth(today)
	local weekdayOfFirst = ((today.weekday - 1 - (today.day - 1)) % 7) + 1
	return 1 + ((2 - weekdayOfFirst) % 7)
end

local function PassesClientRules(entry)
	if entry.expansion == "tbc" and not IsBurningCrusade() then
		return false
	end
	return true
end

--[[
Locations valid on this client. For a rotating event the month picks which one is
current; for everything else they all apply.
]]
function WorldEventService.GetLocations(event, today)
	local valid = { }
	for _, location in ipairs(event.locations or { }) do
		if PassesClientRules(location) then
			table.insert(valid, location)
		end
	end
	if event.rule ~= "firstMondayOfMonth" or #valid == 0 then
		return valid
	end

	today = today or WorldEventService.GetToday()
	local months = today.year * 12 + today.month + (event.rotationOffset or 0)
	local index = (months % #valid) + 1
	return { valid[index] }
end

--[[
Start and end as day numbers for the occurrence relevant to `today`, or nil if the
event is not running. Ranges that wrap the year end (Winter Veil) resolve to whichever
side of the boundary today sits on.
]]
local function GetOccurrence(event, today)
	if event.rule == "firstMondayOfMonth" then
		local firstMonday = FirstMondayOfMonth(today)
		local duration = event.duration or 7
		if today.day < firstMonday or today.day >= firstMonday + duration then
			return nil
		end
		local startDay = DayNumber(today.year, today.month, firstMonday)
		return startDay, startDay + duration - 1
	end

	local starts, ends = event.starts, event.ends
	if not (starts and ends) then return nil end

	local todayMD = MonthDay(today.month, today.day)
	local startMD = MonthDay(starts.month, starts.day)
	local endMD = MonthDay(ends.month, ends.day)

	if startMD <= endMD then
		if todayMD < startMD or todayMD > endMD then return nil end
		return DayNumber(today.year, starts.month, starts.day),
			DayNumber(today.year, ends.month, ends.day)
	end

	-- Wraps the year end: active from the start date through to the end date in the
	-- following year.
	if todayMD >= startMD then
		return DayNumber(today.year, starts.month, starts.day),
			DayNumber(today.year + 1, ends.month, ends.day)
	elseif todayMD <= endMD then
		return DayNumber(today.year - 1, starts.month, starts.day),
			DayNumber(today.year, ends.month, ends.day)
	end
	return nil
end

function WorldEventService.IsActive(event, today)
	if not PassesClientRules(event) then return false end
	today = today or WorldEventService.GetToday()
	return GetOccurrence(event, today) ~= nil
end

--[[
Whole days until the event ends, counting today. An event ending today returns 1, so
callers can say "ends today" without special-casing zero.
]]
function WorldEventService.GetDaysRemaining(event, today)
	today = today or WorldEventService.GetToday()
	local _, endDay = GetOccurrence(event, today)
	if not endDay then return nil end
	local todayDay = DayNumber(today.year, today.month, today.day)
	if not todayDay then return nil end
	return math.max(0, endDay - todayDay) + 1
end

function WorldEventService.GetActiveEvents(today)
	today = today or WorldEventService.GetToday()
	local active = { }
	for _, event in ipairs(events) do
		if PassesClientRules(event) and GetOccurrence(event, today) then
			table.insert(active, event)
		end
	end
	-- Soonest to finish first: the one about to end is the one worth acting on.
	table.sort(active, function(a, b)
		local aLeft = WorldEventService.GetDaysRemaining(a, today) or 9999
		local bLeft = WorldEventService.GetDaysRemaining(b, today) or 9999
		if aLeft ~= bLeft then return aLeft < bLeft end
		return a.name < b.name
	end)
	return active
end

function WorldEventService.GetAllEvents()
	return events
end

-- Debug helpers (see todo.md) -------------------------------------------------

_G.AGC_ActiveEvents = function(year, month, day)
	local today
	if year and month and day then
		today = WorldEventService.MakeDate(year, month, day)
	else
		today = WorldEventService.GetToday()
	end
	local active = WorldEventService.GetActiveEvents(today)
	print(("|cff33ff99[AGC]|r %04d-%02d-%02d: %d active event(s)"):format(
		today.year, today.month, today.day, #active))
	for _, event in ipairs(active) do
		local locations = { }
		for _, location in ipairs(WorldEventService.GetLocations(event, today)) do
			table.insert(locations, location.name)
		end
		print(("  %s -- %s, %d day(s) left"):format(
			event.name,
			table.concat(locations, ", "),
			WorldEventService.GetDaysRemaining(event, today) or -1))
	end
end
