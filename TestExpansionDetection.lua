-- Quick test to check expansion detection
select(2, ...).SetupGlobalFacade()

local function TestExpansionDetection()
	local version, build, date, tocversion = GetBuildInfo()
	local isTBC = tocversion >= 20000

	print("=== Expansion Detection Test ===")
	print("TOC Version: " .. tostring(tocversion))
	print("Is TBC Client: " .. tostring(isTBC))
	print("Current Filter: " .. tostring(InstanceService.GetExpansionFilter()))

	-- Count dungeons
	local dungeons = InstanceService.GetDungeons()
	local classicCount = 0
	local tbcCount = 0

	for _, dungeon in ipairs(dungeons) do
		local filter = dungeon.seasonFilter or "all"
		if filter == "tbc" then
			tbcCount = tbcCount + 1
		else
			classicCount = classicCount + 1
		end
	end

	print("Classic Dungeons: " .. classicCount)
	print("TBC Dungeons: " .. tbcCount)
	print("Total Showing: " .. #dungeons)
	print("================================")
end

-- Register slash command
SLASH_AGCTEST1 = "/agctest"
SlashCmdList["AGCTEST"] = TestExpansionDetection
