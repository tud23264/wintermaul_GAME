function CustomGameMode:FilterExecuteOrder( filterTable )
    --[[
    print("-----------------------------------------")
    for k, v in pairs( filterTable ) do
        print("Order: " .. k .. " " .. tostring(v) )
    end
    ]]

    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]
    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]
    local queue = tobool(filterTable["queue"])
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)

    -- Skip Prevents order loops
    local unit = EntIndexToHScript(units["0"])
    if unit and unit.skip then
        unit.skip = false
        return true
    end

    if units then
        for n,unit_index in pairs(units) do
            local unit = EntIndexToHScript(unit_index)
            if unit and IsValidEntity(unit) then
                if not unit:IsBuilding() and not IsCustomBuilding(unit) then

                    -- Set hold position
                    if order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
                        unit.bHold = true
                    end
                end
            end
        end
    end

    ------------------------------------------------
    --           Ability Multi Order              --
    ------------------------------------------------
    if abilityIndex and abilityIndex ~= 0 and IsMultiOrderAbility(EntIndexToHScript(abilityIndex)) then
        print("Multi Order Ability")

        local ability = EntIndexToHScript(abilityIndex) 
        local abilityName = ability:GetAbilityName()
        local entityList = GetSelectedEntities(unit:GetPlayerOwnerID())
        for _,entityIndex in pairs(entityList) do
            local caster = EntIndexToHScript(entityIndex)
            -- Make sure the original caster unit doesn't cast twice
            if caster and caster ~= unit and caster:HasAbility(abilityName) then
                
                local abil = caster:FindAbilityByName(abilityName)
                if abil and abil:IsFullyCastable() then

                    caster.skip = true
                    if order_type == DOTA_UNIT_ORDER_CAST_POSITION then
                        ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, Position = point, AbilityIndex = abil:GetEntityIndex(), Queue = queue})

                    elseif order_type == DOTA_UNIT_ORDER_CAST_TARGET then
                        ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, TargetIndex = targetIndex, AbilityIndex = abil:GetEntityIndex(), Queue = queue})

                    else --order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET or order_type == DOTA_UNIT_ORDER_CAST_TOGGLE or order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
                        ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, AbilityIndex = abil:GetEntityIndex(), Queue = queue})
                    end
                end
            end
        end
        return true

    ------------------------------------------------
    --              ClearQueue Order              --
    ------------------------------------------------
    -- Cancel queue on Stop and Hold
    elseif order_type == DOTA_UNIT_ORDER_STOP or order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
        for n, unit_index in pairs(units) do 
            local unit = EntIndexToHScript(unit_index)
            if IsBuilder(unit) then
                BuildingHelper:ClearQueue(unit)
            end
        end
        return true

    -- Cancel builder queue when casting non building abilities
    elseif (abilityIndex and abilityIndex ~= 0) and IsBuilder(unit) then
        local ability = EntIndexToHScript(abilityIndex)
        print("ORDER FILTER",ability:GetAbilityName(), IsBuildingAbility(ability))
        if not IsBuildingAbility(ability) then
            BuildingHelper:ClearQueue(unit)
        end
        return true
    end

    return true
end

------------------------------------------------
--             Repair Right-Click             --
------------------------------------------------
function CustomGameMode:RepairOrder( event )
    local pID = event.pID
    local entityIndex = event.mainSelected
    local targetIndex = event.targetIndex
    local building = EntIndexToHScript(targetIndex)
    local selectedEntities = GetSelectedEntities(pID)
    local queue = tobool(event.queue)

    local unit = EntIndexToHScript(entityIndex)
    local repair_ability = unit:FindAbilityByName("repair")

    -- Repair
    if repair_ability and repair_ability:IsFullyCastable() and not repair_ability:IsHidden() then
        ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = DOTA_UNIT_ORDER_CAST_TARGET, TargetIndex = targetIndex, AbilityIndex = repair_ability:GetEntityIndex(), Queue = queue})
    end
end

ORDERS = {
    [0] = "DOTA_UNIT_ORDER_NONE",
    [1] = "DOTA_UNIT_ORDER_MOVE_TO_POSITION",
    [2] = "DOTA_UNIT_ORDER_MOVE_TO_TARGET",
    [3] = "DOTA_UNIT_ORDER_ATTACK_MOVE",
    [4] = "DOTA_UNIT_ORDER_ATTACK_TARGET",
    [5] = "DOTA_UNIT_ORDER_CAST_POSITION",
    [6] = "DOTA_UNIT_ORDER_CAST_TARGET",
    [7] = "DOTA_UNIT_ORDER_CAST_TARGET_TREE",
    [8] = "DOTA_UNIT_ORDER_CAST_NO_TARGET",
    [9] = "DOTA_UNIT_ORDER_CAST_TOGGLE",
    [10] = "DOTA_UNIT_ORDER_HOLD_POSITION",
    [11] = "DOTA_UNIT_ORDER_TRAIN_ABILITY",
    [12] = "DOTA_UNIT_ORDER_DROP_ITEM",
    [13] = "DOTA_UNIT_ORDER_GIVE_ITEM",
    [14] = "DOTA_UNIT_ORDER_PICKUP_ITEM",
    [15] = "DOTA_UNIT_ORDER_PICKUP_RUNE",
    [16] = "DOTA_UNIT_ORDER_PURCHASE_ITEM",
    [17] = "DOTA_UNIT_ORDER_SELL_ITEM",
    [18] = "DOTA_UNIT_ORDER_DISASSEMBLE_ITEM",
    [19] = "DOTA_UNIT_ORDER_MOVE_ITEM",
    [20] = "DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO",
    [21] = "DOTA_UNIT_ORDER_STOP",
    [22] = "DOTA_UNIT_ORDER_TAUNT",
    [23] = "DOTA_UNIT_ORDER_BUYBACK",
    [24] = "DOTA_UNIT_ORDER_GLYPH",
    [25] = "DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH",
    [26] = "DOTA_UNIT_ORDER_CAST_RUNE",
    [27] = "DOTA_UNIT_ORDER_PING_ABILITY",
    [28] = "DOTA_UNIT_ORDER_MOVE_TO_DIRECTION",
}