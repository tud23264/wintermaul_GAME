-- Generated from template

MAPSIZE = 16384
NUMBERTOSPAWN = 8 --How many to spawn

GAIAPRECACHE = {"nature_pool","terran_protector","gaias_box","earths_soul","ground_pounder","gaia"}
CRYSTALPRECACHE = {"crystal_shooter","crystal_blaster","crystal_fury","crystal_slower","crystal_buster","crystal_dissolver"}
POWERPRECACHE = {"shock_tower","storm_caller","chain_lightning_caster","thunder_rod","sparkler","battery"}
FORGEPRECACHE = {"flare_tower","flame_dancer","meteor_watcher","blast_furnace","incinerator","flame_staff"}

MAX_NUMBER_OF_TEAMS = 9                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = true          -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = true          -- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }  --    Teal
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }   --    Yellow
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }  --    Pink
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }   --    Orange
TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }   --    Blue
TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }  --    Green
TEAM_COLORS[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }   --    Brown
TEAM_COLORS[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }  --    Cyan
TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }  --    Olive
--TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }  --    Purple

USE_AUTOMATIC_PLAYERS_PER_TEAM = false   -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 1
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 1
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_1] = 1
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_2] = 1
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_3] = 1
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_4] = 1
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_5] = 1
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_6] = 1
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_7] = 1
--CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_8] = 1

if CMyMod == nil then
	CMyMod = class({})
end

--essential. loads the unit and model needed into memory
function Precache( context )
		for i =1,#dota_wintermaul.Wave do -- load in wave unit models
			PrecacheUnitByNameSync( dota_wintermaul.Wave[i].NPCName, context )
		end
		
		-- Perhaps we should prechache the towers from the heroes which are only picked by the players, not all of them? Check Green TD code
		
		--PrecacheModel( "nature_pool", context )
		for i =1,6 do
			PrecacheUnitByNameSync( GAIAPRECACHE[i], context)
		end
		--PrecacheModel( "shock_tower", context )
		for i =1,6 do
			PrecacheUnitByNameSync( POWERPRECACHE[i], context)
		end
		--PrecacheModel( "flare_tower", context )
		for i =1,6 do
			PrecacheUnitByNameSync( FORGEPRECACHE[i], context)
		end
		--PrecacheModel( "crystal_shooter", context )
		for i =1,6 do
			PrecacheUnitByNameSync( CRYSTALPRECACHE[i], context)
		end
		
		--PrecacheUnitByNameAsync( CREATURETOSPAWN[WAVE], context )
        --PrecacheModel( CREATURETOSPAWN[WAVE], context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

function Activate()
	--activates the mod. 
	GameRules.CMyMod = CMyMod()
	--calls InitGameMode
	GameRules.CMyMod:InitGameMode()
end


function CMyMod:InitGameMode()
	self._WaveNumber = 1
	
	kv = LoadKeyValues( "scripts/maps/wintermaul_map_config.txt" )
	kv = kv or {} -- Handle the case where there is not key values file

	self._SpawnData = kv["Spawns"]
	self._WaveData = kv["Waves"]
	self._ItemData = kv["ItemDrops"]
	
	--[[self._entAncient = Entities:FindByName( nil, "dota_goodguys_fort" )
	if not self._entAncient then
		print( "Ancient entity not found!" )
	else 
		print( "Antient entity found!" )
	
	end]]
	
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetPreGameTime( 60.0 )
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 60.0 )
	--GameRules:SetHeroMinimapIconSize( 600 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:SetGoldTickTime( 60.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:GetGameModeEntity():SetFogOfWarDisabled ( true )
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 1 )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels ( true )
	--BuildingHelper:BlockGridNavSquares(MAPSIZE)
	--BuildingHelper:BlockBadSquares(MAPSIZE)
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CMyMod, 'OnEntityKilled' ), self )
	ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( CMyMod, "OnPlayerPicked" ), self )
	
	
	
	--sets the first think...Does it do this every 71 seconds??? Eks
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 71 )
	print( "Wintermaul is loaded." )
end

-- sets ability points to 0 and sets skills to lvl1 at start.
function CMyMod:OnPlayerPicked()
	
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if (PlayerResource:IsValidPlayer( nPlayerID ) ) then
			for e=0,15 do -- 
				if (PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(e) ==nil) then
					break
				else
					PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(e):SetLevel(1)
					PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():SetAbilityPoints(0)
				end
			end
		end
	end
end



-- spawns units
function CMyMod:spawnunits()
	print("trying to spawn.")
	
	for i=1,#self._SpawnData do -- For each spawn location
	
		-- What does the first argument do on FindByName? Remember to check... Eks.
		local spawnLocation = Entities:FindByName( nil, self._SpawnData[i].SpawnerName )
		local waypointLocation = Entities:FindByName( nil, self._SpawnData[i].Waypoint )
		
		local currentWaveData = self.WaveData[self._WaveNumber]
		
		-- Room to program the SpawnInterval here (future work)
		for j=1,currentWaveData.UnitsPerSpawn do
			--hscript CreateUnitByName( string name, vector origin, bool findOpenSpot, hscript, hscript, int team)
			--spawns the creature in an area around the spawner 
			local creature = CreateUnitByName( currentWaveData.NPCName , spawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
			--print ("create unit has run")
			creature:SetInitialGoalEntity( waypointlocation )
		end
		print ("nextspawn")
	end
	self._EnemiesRemaining = currentWaveData.TotalUnitstoSpawn
end 

function CMyMod:OnEntityKilled()
	local mobsLeft = self._EnemiesRemaining - 1
	self._EnemiesRemaining = mobsLeft
	print( string.format( "Enemies remaining: %d", mobsLeft ) )
	if mobsLeft == 0 then
		self._Wave = self._Wave + 1
		print( string.format( "wave: %d", self._Wave ) )
		
		-- This function should spawn the next wave in...Global 
		GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 35 )

	end
end


-- Checks for defeat for ancient death because we dont have a life system yet.
--[[function CMyMod:_CheckForDefeat()
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return
	end
	
	if self._entAncient:GetHealth() <= 0 then
		GameRules:MakeTeamLose( DOTA_TEAM_GOODGUYS )
		return
	end
end]]


-- this is the thinker. it thinks
function CMyMod:OnThink()
	--idk what this stuff does was in the template
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "Wintermaul spawning script is running." )
		--if WAVE == 0 then
		--	WAVE = WAVE+1
		--
		--end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	
	self.spawnunits()
	return nil
	--every 30 seconds call this function again	
	--return 30000
end