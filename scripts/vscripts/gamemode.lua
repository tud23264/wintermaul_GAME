
DEBUG_SPEW = 1

function CWintermaulGameMode:InitGameMode()

	self._nRoundNumber = 1
	self._currentRound = nil
	self._flLastThinkGameTime = nil
	self._nCurrentSpawnerID = 1
	self.CreepsAreAttacking = false
	print("id: %d", self._nCurrentSpawnerID)
	self:_ReadGameConfiguration()
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetPreGameTime( 10.0 )
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 60.0 )

	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,9)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,0)
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:GetGameModeEntity():SetFogOfWarDisabled ( true )
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 1 )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels ( true )

	ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( CWintermaulGameMode, "OnPlayerPicked" ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CWintermaulGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent('entity_killed', Dynamic_Wrap(CWintermaulGameMode, 'OnEntityKilled'), self)
	
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 0.25 )

	-- Gamemode stuff

	GameRules:GetGameModeEntity():SetHUDVisible(6, false)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1300)

	-- DebugPrint
	Convars:RegisterConvar('debug_spew', tostring(DEBUG_SPEW), 'Set to 1 to start spewing debug info. Set to 0 to disable.', 1)

	-- Register Listeners
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap(CWintermaulGameMode, "onNPCSpawn"), self)

	-- Full units file to get the custom values
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  	GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  	GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  	GameRules.Requirements = LoadKeyValues("scripts/kv/tech_tree.kv")

  	-- Store and update selected units of each pID
	GameRules.SELECTED_UNITS = {}
	print( "Wintermaul is loaded." )
end

-- assign invincibility to the heroes
function CWintermaulGameMode:onNPCSpawn( keys )

	local spawnedUnit = EntIndexToHScript( keys.entindex )

	if (spawnedUnit:GetUnitName() == "npc_dota_hero_crystal_maiden")
		or (spawnedUnit:GetUnitName() == "npc_dota_hero_enchantress")
		or (spawnedUnit:GetUnitName() == "npc_dota_hero_razor")
		or (spawnedUnit:GetUnitName() == "npc_dota_hero_lina")
		then
		-- add the invulnerable modifier to the hero
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_invulnerable", nil)
	end
end

-- Read and assign configurable keyvalues if applicable
function CWintermaulGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues( "scripts/maps/wintermaul_map_config.txt" )
	kv = kv or {} -- Handle the case where there is not keyvalues file

	self._flPrepTimeBetweenRounds = tonumber( kv.PrepTimeBetweenRounds or 0 )

	self:_ReadSpawnsConfiguration( kv["Spawns"] )
	self:_ReadRoundConfigurations( kv["Waves"])
end


-- Verify valid spawns are defined and build a table with them from the keyvalues file
function CWintermaulGameMode:_ReadSpawnsConfiguration( kvSpawns )
	self._vSpawnsList = {}
	if type( kvSpawns ) ~= "table" then
		return
	end
	for _,sp in pairs( kvSpawns ) do			-- Note "_" used as a shortcut to create a temporary throwaway variable
		table.insert( self._vSpawnsList, {
			szSpawnerName = sp.SpawnerName or "",
			szFirstWaypoint = sp.Waypoint or ""
		} )
	end
	for k,v in pairs( self._vSpawnsList ) do
		print("key: ", k, "val: ", v.szSpawnerName, v.szFirstWaypoint)
	end
end

-- Set number of rounds without requiring index in text file
function CWintermaulGameMode:_ReadRoundConfigurations( kv )
	self._vRounds = {}
	while true do
		local szRoundName = string.format("Wave%d", #self._vRounds + 1 )
		local kvRoundData = kv[ szRoundName ]
		if kvRoundData == nil then
			return
		end
		local roundObj = CWintermaulGameRound()
		roundObj:ReadConfiguration( kvRoundData, self, #self._vRounds + 1 )
		table.insert( self._vRounds, roundObj )
	end
end

-- When game state changes set state in script
function CWintermaulGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	end
end

-- sets ability points to 0 and sets skills to lvl1 at start.
function CWintermaulGameMode:OnPlayerPicked( keys )

	local player = EntIndexToHScript(keys.player)

	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		PlayerResource:SetGold(nPlayerID, 500, false)
		if (PlayerResource:IsValidPlayer( nPlayerID ) ) then
			for e=0,15 do
				if (PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(e)==nil) then
					break
				else
					PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(e):SetLevel(1)
					PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():SetAbilityPoints(0)
				end
			end
		end
	end
end


function CWintermaulGameMode:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd then
		self._flPrepTimeEnd = nil
		if self._entPrepTimeQuest then
			UTIL_RemoveImmediate( self._entPrepTimeQuest )
			self._entPrepTimeQuest = nil
		end

		if self._nRoundNumber > #self._vRounds then
			GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
			return false
		end
		self._currentRound = self._vRounds[ self._nRoundNumber ]
		self._currentRound:Begin()
		return
	end

	if not self._entPrepTimeQuest then
		self._entPrepTimeQuest = SpawnEntityFromTableSynchronous( "quest", { name = "PrepTime", title = "#DOTA_Quest_Wintermaul_PrepTime" } )
		self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber )

		self._vRounds[ self._nRoundNumber ]:Precache()
	end
	self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._flPrepTimeEnd - GameRules:GetGameTime() )
end


-- this is the thinker. it thinks
-- Evaluate the state of the game
function CWintermaulGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--self:_CheckForDefeat()
		--self:_ThinkLootExpiry()

		if self._flPrepTimeEnd ~= nil then
			self:_ThinkPrepTime()
		elseif self._currentRound ~= nil then
			self._currentRound:Think()
			if self._currentRound:IsFinished() then
				self._currentRound:End()
				self._currentRound = nil

				self._nRoundNumber = self._nRoundNumber + 1
				if self._nRoundNumber > #self._vRounds then
					self._nRoundNumber = 1
					GameRules:MakeTeamLose( DOTA_TEAM_BADGUYS )
				else
					self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
				end
			end
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end

	-- Call a function that uses the CanFindPath function for each spawner and check it below
	if self._currentRound then
		if self:CreepsCanReachEnd() then
			if self.CreepsAreAttacking then
				
				self:SwitchAttackMode( 0 )
				self.CreepsAreAttacking = false
			end
		elseif self.CreepsAreAttacking == false then
			-- Then for every enemy entity there is on the map AND all new creeps that are spawned
			-- Change their AttackCapability to melee/ranged - this should be in a seperate function
			self:SwitchAttackMode( 1 )
			self.CreepsAreAttacking = true
		end
	end
	
	return 1
end

function CWintermaulGameMode:OnEntityKilled( event )
	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	-- The Killing entity
	local killerEntity
	if event.entindex_attacker then
		killerEntity = EntIndexToHScript(event.entindex_attacker)
	end

	-- Player owner of the unit
	local player = killedUnit:GetPlayerOwner()
	
	if IsCustomBuilding(killedUnit) then
		 -- Building Helper grid cleanup
		BuildingHelper:RemoveBuilding(killedUnit, true)

		-- Check units for downgrades
		local building_name = killedUnit:GetUnitName()
		--[[
		-- Substract 1 to the player building tracking table for that name
		if player.buildings[building_name] then
			player.buildings[building_name] = player.buildings[building_name] - 1
		end

		-- possible unit downgrades
		for k,units in pairs(player.units) do
			CheckAbilityRequirements( units, player )
		end

		-- possible structure downgrades
		for k,structure in pairs(player.structures) do
			CheckAbilityRequirements( structure, player )
		end
		]]--
	end
end

function CWintermaulGameMode:CreepsCanReachEnd()
	local endPoint = Entities:FindByName( nil, "path_end" )
	for k, v in pairs(self._vSpawnsList) do
		local tempSpawner = Entities:FindByName( nil, v.szSpawnerName )
		if not GridNav:CanFindPath( tempSpawner:GetOrigin(), endPoint:GetOrigin() ) then
			return false
		end
	end

	return true
end

function CWintermaulGameMode:SwitchAttackMode( attackMode )

	-- Detect all creatures in this round:
	for _, v in pairs(self._currentRound._vSpawners) do

		local allUnits = Entities:FindAllByName( "npc_dota_creature" )
		
		for _, unit in pairs(allUnits) do

			if unit:GetUnitLabel() == "waveCreep" then
				unit:SetAttackCapability(attackMode)
			end
		end
		
	end
	print("The creeps have switched attack mode.")
end