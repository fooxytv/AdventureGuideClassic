--[[
Copyright (C) 2023 FooxyTV (simon@fooxy.tv)
Licensed under the GNU General Public License v3.0. See LICENSE.

Programming by: FooxyTV
]]

function GetSeasons()
    return {
        [1] = 'Classic Era',
        [2] = 'Season of Discovery'
    }
end

select(2, ...).SetupGlobalFacade("GetSeasons", GetSeasons)