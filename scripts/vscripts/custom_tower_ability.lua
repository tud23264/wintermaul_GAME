require('buildinghelper')

BUILD_TIME=1.0

function getBuildingPoint(keys)
    local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, keys.caster)
    local towerToSpawnName = tostring(keys.Tower)
    local playerOwnerHandle = keys.caster
    if point ~= -1 then
        local tower = CreateUnitByName(towerToSpawnName, point, false, playerOwnerHandle, playerOwnerHandle, DOTA_TEAM_GOODGUYS)
        BuildingHelper:AddBuilding(tower)
        tower:UpdateHealth(BUILD_TIME,true,.85)
        tower:SetHullRadius(64)
        tower:SetControllableByPlayer( keys.caster:GetPlayerID(), true )
    else
        --Fire a game event here and use Actionscript to let the player know he can't place a building at this spot.
    end
end
