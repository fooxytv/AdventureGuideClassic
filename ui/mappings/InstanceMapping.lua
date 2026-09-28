--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]


-- nil, not 0, for no active season: the caller branches on `if activeSeasonID then`, and
-- 0 is truthy in Lua, so Compat.GetActiveSeason's 0 would take the wrong branch.
local function GetActiveSeasonID()
    if not Compat.HasActiveSeason() then
        return nil
    end
    return Compat.GetActiveSeason()
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