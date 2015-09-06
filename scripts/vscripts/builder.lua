------------------------------------------
--             Build Scripts
------------------------------------------

-- A build ability is used (not yet confirmed)
function Build( event )
	local caster = event.caster
	local ability = event.ability
	local ability_name = ability:GetAbilityName()
	local AbilityKV = GameRules.AbilityKV
	local UnitKV = GameRules.UnitKV

    -- Hold needs an Interrupt
	if caster.bHold then
		caster.bHold = false
		caster:Interrupt()
	end

	-- Handle the name for item-ability build
	local building_name
	if event.ItemUnitName then
		building_name = event.ItemUnitName --Directly passed through the runscript
	else
		building_name = AbilityKV[ability_name].UnitName --Building Helper value
	end

	-- Checks if there is enough custom resources to start the building, else stop.
	local unit_table = UnitKV[building_name]
	local build_time = ability:GetSpecialValueFor("build_time")
	local gold_cost = ability:GetSpecialValueFor("gold_cost")
	local lumber_cost = ability:GetSpecialValueFor("lumber_cost")

	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local playerID = hero:GetPlayerID()
	local player = PlayerResource:GetPlayer(playerID)	

	-- If the ability has an AbilityGoldCost, it's impossible to not have enough gold the first time it's cast
	-- Always refund the gold here, as the building hasn't been placed yet
	hero:ModifyGold(gold_cost, false, 0)

	if not PlayerHasEnoughLumber( player, lumber_cost ) then
		return
	end

    -- Makes a building dummy and starts panorama ghosting
	BuildingHelper:AddBuilding(event)

	-- Additional checks to confirm a valid building position can be performed here
	event:OnPreConstruction(function(vPos)

       	-- Blight check
       	if string.match(building_name, "undead") and building_name ~= "undead_necropolis" then
       		local bHasBlight = HasBlight(vPos)
       		DebugPrint("[BH] Blight check for "..building_name..":", bHasBlight)
       		if not bHasBlight then
       			SendErrorMessage(caster:GetPlayerOwnerID(), "#error_must_build_on_blight")
       			return false
       		end
       	end

       	-- If not enough resources to queue, stop
		if not PlayerHasEnoughGold( player, gold_cost ) then
       		SendErrorMessage(caster:GetPlayerOwnerID(), "#error_not_enough_gold")
			return false
		end

       	if not PlayerHasEnoughLumber( player, lumber_cost ) then
       		SendErrorMessage(caster:GetPlayerOwnerID(), "#error_not_enough_lumber")
			return false
		end

		return true
    end)

	-- Position for a building was confirmed and valid
    event:OnBuildingPosChosen(function(vPos)
		
    	-- Spend resources
    	hero:ModifyGold(-gold_cost, false, 0)
    	ModifyLumber( player, -lumber_cost)

    	-- Play a sound
    	EmitSoundOnClient("DOTA_Item.ObserverWard.Activate", player)

    	-- Move the units away from the building place
	

	end)

    -- The construction failed and was never confirmed due to the gridnav being blocked in the attempted area
	event:OnConstructionFailed(function()
		local name = player.activeBuilding
		DebugPrint("[BH] Failed placement of " .. name)
		SendErrorMessage(caster:GetPlayerOwnerID(), "#error_invalid_build_position")
	end)

	-- Cancelled due to ClearQueue
	event:OnConstructionCancelled(function(work)
		local name = work.name
		DebugPrint("[BH] Cancelled construction of " .. name)

		-- Refund resources for this cancelled work
		if work.refund then
			hero:ModifyGold(gold_cost, false, 0)
    		ModifyLumber( player, lumber_cost)
    	end
	end)

	-- A building unit was created
	event:OnConstructionStarted(function(unit)
		DebugPrint("[BH] Started construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
		-- Play construction sound

		-- Store the Build Time, Gold Cost and secondary resource the building 
	    -- This is necessary for repair to know what was the cost of the building and use resources periodically
	    unit.GoldCost = gold_cost
	    unit.LumberCost = lumber_cost
	    unit.BuildTime = build_time

		-- Give item to cancel
		local item = CreateItem("item_building_cancel", playersHero, playersHero)
		unit:AddItem(item)

		-- FindClearSpace for the builder
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		caster:AddNewModifier(caster, nil, "modifier_phased", {duration=0.03})

    	-- Remove invulnerability on npc_dota_building baseclass (not required as the baseclass should be npc_dota_creature)
    	-- unit:RemoveModifierByName("modifier_invulnerable")

    	-- Particle effect
    	ApplyModifier(unit, "modifier_construction")

    	-- Check the abilities of this building, disabling those that don't meet the requirements
    	CheckAbilityRequirements( unit, player )

		-- Add the building handle to the list of structures
		table.insert(player.structures, unit)
	end)

	-- A building finished construction
	event:OnConstructionCompleted(function(unit)
		DebugPrint("[BH] Completed construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
		
		-- Play construction complete sound

		-- Let the building cast abilities
		unit:RemoveModifierByName("modifier_construction")
		
		-- Add the invulnerability modifier
		unit:AddNewModifier(unit, nil, "modifier_invulnerable", nil) 
		
		-- Remove item_building_cancel
        for i=0,5 do
            local item = unit:GetItemInSlot(i)
            if item then
            	if item:GetAbilityName() == "item_building_cancel" then
            		item:RemoveSelf()
                end
            end
        end

		local building_name = unit:GetUnitName()
		local builders = {}
		if unit.builder then
			table.insert(builders, unit.builder)
		elseif unit.units_repairing then
			builders = unit.units_repairing
		end

		-- Add 1 to the player building tracking table for that name
		if not player.buildings[building_name] then
			player.buildings[building_name] = 1
		else
			player.buildings[building_name] = player.buildings[building_name] + 1
		end

		-- Update the abilities of the builders and buildings
    	for k,units in pairs(player.units) do
    		CheckAbilityRequirements( units, player )
    	end

    	for k,structure in pairs(player.structures) do
    		CheckAbilityRequirements( structure, player )
    	end

	end)

	-- These callbacks will only fire when the state between below half health/above half health changes.
	-- i.e. it won't fire multiple times unnecessarily.
	event:OnBelowHalfHealth(function(unit)
		DebugPrint("[BH] " .. unit:GetUnitName() .. " is below half health.")
				
		local item = CreateItem("item_apply_modifiers", nil, nil)
    	item:ApplyDataDrivenModifier(unit, unit, "modifier_onfire", {})
    	item = nil

	end)

	event:OnAboveHalfHealth(function(unit)
		DebugPrint("[BH] " ..unit:GetUnitName().. " is above half health.")

		unit:RemoveModifierByName("modifier_onfire")
		
	end)
end

-- Called when the move_to_point ability starts
function StartBuilding( keys )
	BuildingHelper:StartBuilding(keys)
end

-- Called when the Cancel ability-item is used
function CancelBuilding( keys )
	BuildingHelper:CancelBuilding(keys)
end

--------------------------------
--       Repair Scripts       --
--------------------------------

-- Start moving to repair
function RepairStart( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local target_class = target:GetClassname()

	caster:Interrupt() -- Stops any instance of Hold/Stop the builder might have

	-- Possible states
		-- moving_to_repair
		-- moving_to_build (set on Building Helper when a build queue advances)
		-- repairing
		-- idle

	-- Repair Building / Siege
	if target_class == "npc_dota_creature" then
		if IsCustomBuilding(target) and target:GetHealthDeficit() > 0 then

			caster.repair_target = target

			local target_pos = target:GetAbsOrigin()
			
			ability.cancelled = false
			caster.state = "moving_to_repair"

			-- Destroy any old move timer
			if caster.moving_timer then
				Timers:RemoveTimer(caster.moving_timer)
			end

			-- Fake toggle the ability, cancel if any other order is given
			if ability:GetToggleState() == false then
				ability:ToggleAbility()
			end

			-- Recieving another order will cancel this
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_on_order_cancel_repair", {})

			local collision_size = GetCollisionSize(target)*2 + 64

			caster.moving_timer = Timers:CreateTimer(function()

				-- End if killed
				if not (caster and IsValidEntity(caster) and caster:IsAlive()) then
					return
				end

				-- Move towards the target until close range
				if not ability.cancelled and caster.state == "moving_to_repair" then
					if caster.repair_target and IsValidEntity(caster.repair_target) then
						local distance = (target_pos - caster:GetAbsOrigin()):Length()
						
						if distance > collision_size then
							caster:MoveToNPC(target)
							return 0.1 --THINK_INTERVAL
						else
                            --print("Reached target, starting the Repair process")
                            -- Must refresh the modifier to make sure the OnCreated is executed
                            if caster:HasModifier("modifier_builder_repairing") then
                                caster:RemoveModifierByName("modifier_builder_repairing")
                            end
                            Timers:CreateTimer(function()
								ability:ApplyDataDrivenModifier(caster, caster, "modifier_builder_repairing", {})
							end)
							return
						end
					else
						print("Building was killed in the way of a builder to repair it")
						caster:RemoveModifierByName("modifier_on_order_cancel_repair")
						CancelGather(event)
					end
				else
					return
				end
			end)
		else
			print("Not a valid repairable unit or already on full health")
		end
	else
		print("Not a valid target for this ability")
		caster:Stop()
	end
end

-- Toggles Off Move to Repair
function CancelRepair( event )
	local caster = event.caster
	local ability = event.ability

	local ability_order = event.event_ability
	if ability_order then
		local order_name = ability_order:GetAbilityName()
		--print("CancelGather Order: "..order_name)
		if string.match(order_name,"build_") then
			--print(" return")
			return
		end
	end

	ability.cancelled = true
	caster.state = "idle"
	
	ToggleOff(ability)
end

-- Repair Ratios
-- Repair Cost Ratio = 0.35 - Takes 105g to fully repair a building that costs 300. Also applies to lumber
-- Repair Time Ratio = 1.5 - Takes 150 seconds to fully repair a building that took 100seconds to build
-- Builders can assist the construction with multiple peasants
-- In that case, extra resources are consumed, and they add up for every extra builder repairing the same building
-- Powerbuild Rate = 0.60 - Fastens the ratio by 60%
function Repair( event )
	local caster = event.caster -- The builder
	local ability = event.ability
	local building = event.target -- The building to repair

	local player = caster:GetPlayerOwner()
	local hero = player:GetAssignedHero()
	local pID = hero:GetPlayerID()

	local building_name = building:GetUnitName()
	local gold_cost = building.GoldCost
	local lumber_cost = building.LumberCost
	local build_time = building.BuildTime

	local state = building.state -- "completed" or "building"
	local health_deficit = building:GetHealthDeficit()

	ToggleOn(ability)

	-- If its an unfinished building, keep track of how much does it require to mark as finished
	if not building.constructionCompleted and not building.health_deficit then
		building.missingHealthToComplete = health_deficit
	end

	-- Scale costs/time according to the stack count of builders reparing this
	if health_deficit > 0 then
		-- Initialize the tracking
		if not building.health_deficit then
			building.health_deficit = health_deficit
			building.gold_used = 0
			building.lumber_used = 0
			building.HPAdjustment = 0
			building.GoldAdjustment = 0
			building.time_started = GameRules:GetGameTime()
		end
		
		local stack_count = building:GetModifierStackCount( "modifier_repairing_building", ability )

		-- HP
		local health_per_second = building:GetMaxHealth() /  ( build_time * 1.5 ) * stack_count
		local health_float = health_per_second - math.floor(health_per_second) -- floating point component
		health_per_second = math.floor(health_per_second) -- round down

		-- Don't expend resources for the first peasant repairing the building if its a construction
		if not building.constructionCompleted then
			stack_count = stack_count - 1
		end

		-- Gold
		local gold_per_second = gold_cost / ( build_time * 1.5 ) * 0.35 * stack_count
		local gold_float = gold_per_second - math.floor(gold_per_second) -- floating point component
		gold_per_second = math.floor(gold_per_second) -- round down

		-- Lumber takes floats just fine
		local lumber_per_second = lumber_cost / ( build_time * 1.5 ) * 0.35 * stack_count

		--[[print("Building is repaired for "..health_per_second)
		if gold_per_second > 0 then
			print("Cost is "..gold_per_second.." gold and "..lumber_per_second.." lumber per second")
		else
			print("Cost is "..gold_float.." gold and "..lumber_per_second.." lumber per second")
		end]]
			
		local healthGain = 0
		if PlayerHasEnoughGold( player, math.ceil(gold_per_second+gold_float) ) and PlayerHasEnoughLumber( player, lumber_per_second ) then
			-- Health
			building.HPAdjustment = building.HPAdjustment + health_float
			if building.HPAdjustment > 1 then
				healthGain = health_per_second + 1
				building:SetHealth(building:GetHealth() + healthGain)
				building.HPAdjustment = building.HPAdjustment - 1
			else
				healthGain = health_per_second
				building:SetHealth(building:GetHealth() + health_per_second)
			end
			
			-- Consume Resources
			building.GoldAdjustment = building.GoldAdjustment + gold_float
			if building.GoldAdjustment > 1 then
				hero:ModifyGold( -gold_per_second - 1, false, 0)
				building.GoldAdjustment = building.GoldAdjustment - 1
				building.gold_used = building.gold_used + gold_per_second + 1
			else
				hero:ModifyGold( -gold_per_second, false, 0)
				building.gold_used = building.gold_used + gold_per_second
			end
			
			ModifyLumber( player, -lumber_per_second )
			building.lumber_used = building.lumber_used + lumber_per_second
		else
			-- Remove the modifiers on the building and the builders
			building:RemoveModifierByName("modifier_repairing_building")
			for _,builder in pairs(building.units_repairing) do
				if builder and IsValidEntity(builder) then
					builder:RemoveModifierByName("modifier_builder_repairing")
				end
			end
			print("Repair Ended, not enough resources!")
			building.health_deficit = nil
			building.missingHealthToComplete = nil

			-- Toggle off
			ToggleOff(ability)
		end

		-- Decrease the health left to finish construction and mark building as complete
		if building.missingHealthToComplete then
			building.missingHealthToComplete = building.missingHealthToComplete - healthGain
		end

	-- Building Fully Healed
	else
		-- Remove the modifiers on the building and the builders
		building:RemoveModifierByName("modifier_repairing_building")
		for _,builder in pairs(building.units_repairing) do
			if builder and IsValidEntity(builder) then
				builder:RemoveModifierByName("modifier_builder_repairing")
				builder.state = "idle"

				--This should only be done to the additional assisting builders, not the main one that started the construction
				if not builder.work then
                	BuildingHelper:AdvanceQueue(builder)
                end
			end
		end
		-- Toggle off
		ToggleOff(ability)

		print("Repair End")
		-- If tracking information was initialised
		if building.health_deficit then
		   print("Start HP/Gold/Lumber/Time: ", building.health_deficit, gold_cost, lumber_cost, build_time)
		   print("Final HP/Gold/Lumber/Time: ", building:GetHealth(), building.gold_used, math.floor(building.lumber_used), GameRules:GetGameTime() - building.time_started)
		   building.health_deficit = nil
		end
	end

	-- Construction Ended
	if building.missingHealthToComplete and building.missingHealthToComplete <= 0 then
		building.missingHealthToComplete = nil
		building.constructionCompleted = true -- BuildingHelper will track this and know the building ended
	else
		--print("Missing Health to Complete building: ",building.missingHealthToComplete)
	end
end

function BuilderRepairing( event )
	local caster = event.caster
	local ability = event.ability
	local target = caster.repair_target

    print("Builder Repairing ",target:GetUnitName())
	
	caster.state = "repairing"

	-- Apply a modifier stack to the building, to show how many peasants are working on it (and scale the Powerbuild costs)
	local modifierName = "modifier_repairing_building"
	if target:HasModifier(modifierName) then
		target:SetModifierStackCount( modifierName, ability, target:GetModifierStackCount( modifierName, ability ) + 1 )
	else
		ability:ApplyDataDrivenModifier( caster, target, modifierName, { Duration = duration } )
		target:SetModifierStackCount( modifierName, ability, 1 )
	end

	-- Keep a list of the units repairing this building
	if not target.units_repairing then
		target.units_repairing = {}
		table.insert(target.units_repairing, caster)
	else
		table.insert(target.units_repairing, caster)
	end
end

function BuilderStopRepairing( event )
	local caster = event.caster
	local ability = event.ability
	local building = caster.repair_target

	local ability_order = event.event_ability
	if ability_order then
		local order_name = ability_order:GetAbilityName()
		if string.match(order_name,"build_") then
			return
		end
	end
	
	caster:RemoveModifierByName("modifier_on_order_cancel_repair")
	caster:RemoveModifierByName("modifier_builder_repairing")
	caster:RemoveGesture(ACT_DOTA_ATTACK)

	caster.state = "idle"

	-- Apply a modifier stack to the building, to show how many builders are working on it (and scale the Powerbuild costs)
	local modifierName = "modifier_repairing_building"
	if building and IsValidEntity(building) and building:HasModifier(modifierName) then
		local current_stack = building:GetModifierStackCount( modifierName, ability )
		if current_stack > 1 then
			building:SetModifierStackCount( modifierName, ability, current_stack - 1 )
		else
			building:RemoveModifierByName( modifierName )
		end
	end

	-- Remove the builder from the list of units repairing the building
	local builder = getIndex(building.units_repairing, caster)
	if builder and builder ~= -1 then
		table.remove(building.units_repairing, builder)
	end
end

function RepairAnimation( event )
	local caster = event.caster
	caster:StartGesture(ACT_DOTA_ATTACK)
end
