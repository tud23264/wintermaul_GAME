	

    function OnStartTouch(trigger)
     
            print(trigger.activator)
            print(trigger.caller)
            if trigger.activator then
            trigger.activator:AddNewModifier(trigger.activator, nil, "modifier_invulnerable", nil)
            end
           
    end
     
    function OnEndTouch(trigger)
     
            print(trigger.activator)
            print(trigger.caller)
            if trigger.activator then
            trigger.activator:RemoveModifierByName("modifier_invulnerable")
            end
           
    end

