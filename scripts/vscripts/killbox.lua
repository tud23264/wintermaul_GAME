function OnStartTouch(key)
    killEntity(key.activator)
end

function killEntity(key)
    -- "Unit '" .. unitName .. "' has entered the killbox"
    unitName = key:GetUnitName() -- Retrieves the name that the unit has, such as listed in "npc_units_custom.txt"

    if (key:IsOwnedByAnyPlayer() ) then -- Checks to see if the entity is a player controlled unit
        -- Is player owned - Ignore

    else
        -- Is not owned by player - Terminate
        key:ForceKill(true) -- Kills the unit
        GameRules.CWintermaulGameMode:LifeLost()
    end

end