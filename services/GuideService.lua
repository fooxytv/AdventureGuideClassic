--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]
select(2, ...).SetupGlobalFacade()

--[[
Registry for levelling guides, and the per-character record of where the player has
got to.

Step granularity: a guide's `steps` is a FLAT list of individual tasks, not a list of
task groups. The window renders the current task plus the next few, and next/back move
one task at a time. Grouping would read marginally better but makes progress coarse,
and Phase 5's auto-advance needs to complete exactly one task in response to one game
event.

Quest identifiers: steps reference quests by NAME, not id. Hand-written ids would be
wrong silently, the same way hand-written uiMapIDs were (see ZoneService). The Questie
import in Phase 6 fills ids in from a real database.

Progress is stored per character, not per account -- two characters levelling at once
must not share a bookmark.
]]

GuideService = { }

local guides = { }
local guidesByID = { }
local listeners = { }

local function IsBurningCrusade()
	return select(4, GetBuildInfo()) >= 20000
end

local function PassesClientRules(guide)
	if guide.expansion == "tbc" and not IsBurningCrusade() then
		return false
	end
	return true
end

function GuideService.AddGuide(guide)
	guide.steps = guide.steps or { }
	table.insert(guides, guide)
	guidesByID[guide.id] = guide
end

function GuideService.GetGuide(guideID)
	return guidesByID[guideID]
end

function GuideService.GetAllGuides()
	local result = { }
	for _, guide in ipairs(guides) do
		if PassesClientRules(guide) then
			table.insert(result, guide)
		end
	end
	return result
end

--[[
Guides this character could actually follow, ordered by level band.
]]
function GuideService.GetGuidesForCharacter(faction, race)
	faction = faction or PlayerContextService.GetFaction()
	local result = { }
	for _, guide in ipairs(guides) do
		if PassesClientRules(guide) and (not guide.faction or guide.faction == faction) then
			table.insert(result, guide)
		end
	end
	table.sort(result, function(a, b)
		if a.levels.min ~= b.levels.min then return a.levels.min < b.levels.min end
		return a.title < b.title
	end)
	return result
end

--[[
The guide covering a given zone at a given level, if we ship one. Used by the
Suggested Content zone card: it should only open the guide that actually covers the
zone on the card, not merely any guide for the level.
]]
function GuideService.GetGuideForZone(zoneName, level, faction, race)
	level = level or PlayerContextService.GetLevel()
	for _, guide in ipairs(GuideService.GetGuidesForCharacter(faction, race)) do
		if guide.zone == zoneName
			and level >= guide.levels.min and level <= guide.levels.max then
			return guide
		end
	end
	return nil
end

function GuideService.GetGuideForLevel(level, faction, race)
	level = level or PlayerContextService.GetLevel()
	local best
	for _, guide in ipairs(GuideService.GetGuidesForCharacter(faction, race)) do
		if level >= guide.levels.min and level <= guide.levels.max then
			if not best or guide.levels.min > best.levels.min then
				best = guide
			end
		end
	end
	return best
end

-- Persistence -----------------------------------------------------------------

local function EnsureStore()
	SavedVariablesPerCharacter = SavedVariablesPerCharacter or { }
	SavedVariablesPerCharacter.Guide = SavedVariablesPerCharacter.Guide or { }
	local store = SavedVariablesPerCharacter.Guide
	store.steps = store.steps or { }
	return store
end

local function NotifyListeners()
	for _, listener in ipairs(listeners) do
		local ok, err = pcall(listener)
		if not ok and AdventureGuideClassic_Debug then
			print("|cffff0000AGC|r GuideService listener error: " .. tostring(err))
		end
	end
end

function GuideService.RegisterListener(callback)
	table.insert(listeners, callback)
end

function GuideService.GetCurrentGuide()
	local store = EnsureStore()
	local guide = store.current and guidesByID[store.current]
	if guide and PassesClientRules(guide) then
		return guide
	end
	return nil
end

function GuideService.SetCurrentGuide(guideID)
	local store = EnsureStore()
	store.current = guideID
	NotifyListeners()
end

function GuideService.GetStepIndex(guide)
	guide = guide or GuideService.GetCurrentGuide()
	if not guide then return 1 end
	local store = EnsureStore()
	local index = store.steps[guide.id] or 1
	-- Clamp on read: a guide's steps can change between addon versions, and a stale
	-- bookmark must not leave the window blank.
	if index < 1 then return 1 end
	if index > #guide.steps then return #guide.steps end
	return index
end

function GuideService.SetStepIndex(index, guide)
	guide = guide or GuideService.GetCurrentGuide()
	if not guide then return end
	local store = EnsureStore()
	if index < 1 then index = 1 end
	if index > #guide.steps then index = #guide.steps end
	store.steps[guide.id] = index
	NotifyListeners()
end

function GuideService.GetCurrentStep()
	local guide = GuideService.GetCurrentGuide()
	if not guide then return nil end
	return guide.steps[GuideService.GetStepIndex(guide)]
end

function GuideService.GetSteps(fromIndex, count)
	local guide = GuideService.GetCurrentGuide()
	if not guide then return { } end
	local result = { }
	for offset = 0, count - 1 do
		local step = guide.steps[fromIndex + offset]
		if not step then break end
		table.insert(result, { index = fromIndex + offset, task = step })
	end
	return result
end

function GuideService.HasNextStep()
	local guide = GuideService.GetCurrentGuide()
	if not guide then return false end
	return GuideService.GetStepIndex(guide) < #guide.steps
end

function GuideService.HasPreviousStep()
	local guide = GuideService.GetCurrentGuide()
	if not guide then return false end
	return GuideService.GetStepIndex(guide) > 1
end

function GuideService.NextStep()
	local guide = GuideService.GetCurrentGuide()
	if not guide then return end
	local index = GuideService.GetStepIndex(guide)
	if index < #guide.steps then
		GuideService.SetStepIndex(index + 1, guide)
	elseif guide.next and guidesByID[guide.next] then
		-- Roll onto the following guide rather than stalling on the last step.
		GuideService.SetCurrentGuide(guide.next)
	end
end

function GuideService.PreviousStep()
	local guide = GuideService.GetCurrentGuide()
	if not guide then return end
	GuideService.SetStepIndex(GuideService.GetStepIndex(guide) - 1, guide)
end

function GuideService.ResetProgress(guideID)
	local store = EnsureStore()
	guideID = guideID or (GuideService.GetCurrentGuide() and GuideService.GetCurrentGuide().id)
	if guideID then
		store.steps[guideID] = 1
		NotifyListeners()
	end
end

--[[
Picks and opens the guide appropriate to a level, leaving an existing bookmark alone
if the player is already following that guide. This is what the Suggested Content zone
card calls.
]]
function GuideService.StartGuideForLevel(level, faction, race)
	local guide = GuideService.GetGuideForLevel(level, faction, race)
	if not guide then return nil end
	if not (GuideService.GetCurrentGuide() and GuideService.GetCurrentGuide().id == guide.id) then
		GuideService.SetCurrentGuide(guide.id)
	end
	return guide
end

-- Debug helpers (see todo.md) -------------------------------------------------

_G.AGC_ListGuides = function()
	local all = GuideService.GetAllGuides()
	print(("|cff33ff99[AGC]|r %d guide(s) loaded:"):format(#all))
	for _, guide in ipairs(all) do
		print(("  %-34s %s %d-%d, %d steps"):format(
			guide.id, tostring(guide.faction or "any"),
			guide.levels.min, guide.levels.max, #guide.steps))
	end
	local current = GuideService.GetCurrentGuide()
	print(("  current: %s (step %d)"):format(
		current and current.id or "none", GuideService.GetStepIndex()))
end
