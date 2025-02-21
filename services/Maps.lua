select(2, ...).SetupGlobalFacade()

local dungeonMaps = { }
DungeonMapService = { }

-- function DungeonMapService.AddTiles(dungeonMap)
--     table.insert(dungeonMaps, dungeonMap)
-- end

function DungeonMapService.AddTiles(dungeonMap)
    if not dungeonMap.layers or type(dungeonMap.layers) ~= "table" then
        return
    end
    for index, layer in ipairs(dungeonMap.layers) do
        if not layer.mapID then
        end
    end
    table.insert(dungeonMaps, dungeonMap)
end

function DungeonMapService.GetDungeonMapByInstanceName(instanceName)
    for _, map in ipairs(dungeonMaps) do
        if map.instanceName == instanceName then
            return map
        end
    end
    return nil
end

function DungeonMapService.GetLayerByInstanceName(instanceName, layerIndex)
    local dungeonMap = DungeonMapService.GetDungeonMapByInstanceName(instanceName)
    if dungeonMap and dungeonMap.layers and dungeonMap.layers[layerIndex] then
        return dungeonMap.layers[layerIndex]
    end
    return nil
end

function DungeonMapService.GetAllDungeonMaps()
    return dungeonMaps
end