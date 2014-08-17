function OnStartTouch(key)

    print(key.activator) --The entity that triggered the event to happen
    print(key.caller) -- The entity that called for the event to happen

    killEntity(key.activator)

end

function killEntity(key)

    unitName = key:GetUnitName() -- Retrieves the name that the unit has, such as listed in "npc_units_custom.txt"

    print("Unit '" .. unitName .. "' has entered the killbox")

    if (key:IsOwnedByAnyPlayer() ) then -- Checks to see if the entity is a player controlled unit
            print("Is player owned - Ignore")

    else
        print("Is not owned by player - Terminate")
        key:ForceKill(true) -- Kills the unit
    end

end