--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
All rights reserved.

Programming by: FooxyTV
]]

function GetSeasons()
    return {
        [1] = 'Classic Era',
        [2] = 'Season of Discovery'
    }
end

select(2, ...).SetupGlobalFacade("GetSeasons", GetSeasons)