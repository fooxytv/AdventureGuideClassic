--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

SeasonalService = {}

--[[
	Which world event is running, by the dates it runs on.

	The calendar would be the better source -- it knows the real window, including
	the events that move from year to year -- but C_Calendar only exists on
	Forever, and an event that decorates four clients out of five is worse than
	one that decorates none. So every client reads this table, Forever included,
	and the calendar stays an improvement to make rather than a dependency.

	Dates are inclusive at both ends and are month-day pairs, which is what makes
	a window comparable without caring about the year.
]]
local EVENTS = {
	-- Ends after the 2nd, so the 3rd of November is the first day without it.
	{ id = "hallowsend", from = { 10, 18 }, to = { 11, 2 } },
}

local function InRange(month, day, from, to)
	local value = month * 100 + day
	local first = from[1] * 100 + from[2]
	local last = to[1] * 100 + to[2]
	if first <= last then
		return value >= first and value <= last
	end
	-- A window that crosses the new year, which Winter Veil will when it is added.
	return value >= first or value <= last
end

--[[
	Separate from GetActiveEvent so the rule can be asked about a date rather than
	only about today, which is the only way the boundaries are checkable.
]]
function SeasonalService.GetEventFor(month, day)
	if not (month and day) then return nil end
	for _, event in ipairs(EVENTS) do
		if InRange(month, day, event.from, event.to) then
			return event.id
		end
	end
	return nil
end

function SeasonalService.GetActiveEvent()
	if not date then return nil end
	local now = date("*t")
	if not now then return nil end
	return SeasonalService.GetEventFor(now.month, now.day)
end
