--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]


-- C_Seasons is absent on Forever, where reaching it unguarded is a hard error.
local function GetActiveSeasonID()
    if not (C_Seasons and C_Seasons.HasActiveSeason and C_Seasons.GetActiveSeason) then
        return nil
    end
    if not C_Seasons.HasActiveSeason() then
        return nil
    end
    return C_Seasons.GetActiveSeason()
end

function GetDungeonInstanceMapping()
    local activeSeasonID = GetActiveSeasonID()
    if activeSeasonID then
        if activeSeasonID == 2 then
            return {
                [227] = false,
                [228] = true,
                [229] = true,
                [230] = true,
                [231] = false,
                [232] = true,
                [226] = true,
                [233] = true,
                [234] = true,
                [316] = true,
                [246] = true,
                [64]  = true,
                [236] = true,
                [63]  = true,
                [238] = true,
                [237] = false,
                [239] = true,
                [240] = true,
                [241] = true
            }
        else
            return {
                [227] = true,
                [228] = true,
                [229] = true,
                [230] = true,
                [231] = true,
                [232] = true,
                [226] = true,
                [233] = true,
                [234] = true,
                [316] = true,
                [246] = true,
                [64]  = true,
                [236] = true,
                [63]  = true,
                [238] = true,
                [237] = true,
                [239] = true,
                [240] = true,
                [241] = true
            }
        end
    else
        -- placeholder
    end
end

select(2, ...).SetupGlobalFacade("GetDungeonInstanceMapping", GetDungeonInstanceMapping)