require('buildinghelper')

BUILD_TIME=1.0

function getBuildingPoint(keys)
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, keys.caster)
	if point ~= -1 then
		local tower = CreateUnitByName("battery", point, false, nil, nil, DOTA_TEAM_GOODGUYS)
		BuildingHelper:AddBuilding(tower)
		tower:UpdateHealth(BUILD_TIME,true,.85)
		tower:SetHullRadius(64)
		tower:SetControllableByPlayer( keys.caster:GetPlayerID(), true )
	else
		--Fire a game event here and use Actionscript to let the player know he can't place a building at this spot.
	end
end

function getHardtowerPoint(keys)
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 4, caster)
	if point == -1 then
		-- Refund the cost.
		caster:SetGold(caster:GetGold()+HARD_tower_COST, false)
		--Fire a game event here and use Actionscript to let the player know he can't place a building at this spot.
		return
	else
		caster:SetGold(caster:GetGold()-5, false)
		local tower = CreateUnitByName("npc_hard_tower", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(tower)
		tower:UpdateHealth(BUILD_TIME,true,.8)
		tower:SetHullRadius(128)
		tower:SetControllableByPlayer( caster:GetPlayerID(), true )
	end
end