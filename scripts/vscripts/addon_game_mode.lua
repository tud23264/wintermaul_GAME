-- Generated from template

MAPSIZE = 16384
NUMBERTOSPAWN = 8 --How many to spawn
SPAWNLOCATION = {"red_spawn_1","red_spawn_2","blue_spawn_1","blue_spawn_2","teal_spawn_1","teal_spawn_2","orange_spawn_1","orange_spawn_2","yellow_spawn_1","yellow_spawn_2","purple_spawn_1","purple_spawn_2","green_spawn_1","green_spawn_2","grey_spawn_1","grey_spawn_2","pink_spawn_1","pink_spawn_2"}--table of spawn locations in order
WAYPOINTNAME = {"pc_red","pc_red","pc_blue_1","pc_blue_2","pc_teal","pc_teal","pc_orange","pc_orange","pc_yellow_1","pc_yellow_2","pc_purple","pc_purple","pc_green_top","pc_green_top","pc_grey","pc_grey","pc_pink_top","pc_pink_top",}--table to waypoints after spawn location(after this units will know where to go)
CREATURETOSPAWN = {"npc_dota_wintermaul_scouts","npc_dota_wintermaul_engineers","npc_dota_wintermaul_night_ranger","npc_dota_wintermaul_barbarians","npc_dota_wintermaul_drake","npc_dota_wintermaul_stalker","npc_dota_wintermaul_water_runner","npc_dota_wintermaul_ice_troll","npc_dota_wintermaul_wolf_rider","npc_dota_wintermaul_hovercraft","npc_dota_wintermaul_goblin_machine","npc_dota_wintermaul_frosty_reptile","npc_dota_wintermaul_demonic_pets","npc_dota_wintermaul_matured_dragon","npc_dota_wintermaul_ice_shard_golem","npc_dota_wintermaul_eternal_spirit","npc_dota_wintermaul_supply_tank","npc_dota_wintermaul_walking_corpse","npc_dota_wintermaul_totem_carriers","npc_dota_wintermaul_unholy_knight","npc_dota_wintermaul_crystal_mage","npc_dota_wintermaul_frozen_infernal","npc_dota_wintermaul_dragon","npc_dota_wintermaul_polar_bear","npc_dota_wintermaul_posessed_hunter","npc_dota_wintermaul_corrupt_chieftain","npc_dota_wintermaul_ancient_dragon","npc_dota_wintermaul_spider_fiend","npc_dota_wintermaul_armored wisp","npc_dota_wintermaul_duke_wintermaul"}--eventually will be the table of all unit names we need to spawn.

GAIAPRECACHE = {"build_nature_pool","terran_protector","gaias_box","earths_soul","ground_pounder","gaia"}
CRYSTALPRECACHE = {"crystal_shooter","crystal_blaster","crystal_fury","crystal_slower","crystal_buster","crystal_dissolver"}
POWERPRECACHE = {"shock_tower","storm_caller","chain_lightning_caster","thunder_rod","sparkler","battery"}
FORGEPRECACHE = {"flare_tower","flame_dancer","meteor_watcher","blast_furnace","incinerator","flame_staff"}

WAVE = 1
ENEMIESLEFT = 144

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
		
        
		PrecacheModel( "npc_dota_wintermaul_scouts", context )
		for i =1,30 do
			PrecacheUnitByNameAsync( CREATURETOSPAWN[i], context )
			PrecacheModel( CREATURETOSPAWN[i], context )
		end
		PrecacheModel( "nature_pool", context )
		for i =1,6 do
			PrecacheUnitByNameAsync( GAIAPRECACHE[i], context)
			PrecacheModel( GAIAPRECACHE[i], context )
		end
		PrecacheModel( "shock_tower", context )
		for i =1,6 do
			PrecacheUnitByNameAsync( POWERPRECACHE[i], context)
			PrecacheModel( POWERPRECACHE[i], context )
		end
		PrecacheModel( "flare_tower", context )
		for i =1,6 do
			PrecacheUnitByNameAsync( FORGEPRECACHE[i], context)
			PrecacheModel( FORGEPRECACHE[i], context )
		end
		PrecacheModel( "crystal_shooter", context )
		for i =1,6 do
			PrecacheUnitByNameAsync( CRYSTALPRECACHE[i], context)
			PrecacheModel( CRYSTALPRECACHE[i], context )
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
	
	
	--sets the first think
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 71 )
	print( "Wintermaul is loaded." )
	print( "First spawning location loaded: " )
	print(SPAWNLOCATION[1] )
end

-- sets abilitypoints to 0 and sets skills to lvl1 at start.
function CMyMod:OnPlayerPicked( event )
	local spawnedUnit = event.hero
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if (PlayerResource:IsValidPlayer( nPlayerID ) ) then
			for e=0,5 do -- "0" is Ability 1 and "5" is ability 6. so it checks abilities 1 through 6 (if a builder has less than 6 abilitis this breaks)
				PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():GetAbilityByIndex(e):SetLevel(1)
				PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():SetAbilityPoints(0)
			end
		end
	end
end



-- spawns units
function CMyMod:spawnunits()
		print("trying to spawn.")
		local waypointlocation
		local spawnlocation
		local i = 1
		local j = 1
		while 18>=i do
			print(SPAWNLOCATION[i])
			--finds one of the twelve places to spawn
			spawnLocation = Entities:FindByName( nil, SPAWNLOCATION[i] )
			--finds where the unit should go after spawn
			waypointlocation = Entities:FindByName ( nil, WAYPOINTNAME[i])
			while NUMBERTOSPAWN>=j do
					--hscript CreateUnitByName( string name, vector origin, bool findOpenSpot, hscript, hscript, int team)
					--spawns the creature in an area around the spawner 
					local creature = CreateUnitByName( CREATURETOSPAWN[WAVE] , spawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
					--print ("create unit has run")
					creature:SetInitialGoalEntity( waypointlocation )
					j = j + 1
			end
			print ("nextspawn")
			i=i+1
			j=1
		end
		
end 

function CMyMod:OnEntityKilled( event )
	ENEMIESLEFT = ENEMIESLEFT - 1
	print( string.format( "Enemies remaining: %d", ENEMIESLEFT ) )
	if ENEMIESLEFT == 0 then
		WAVE = WAVE + 1
		print( string.format( "wave: %d", WAVE ) )
		GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 35 )
		if WAVE == 5 or WAVE == 14 or WAVE == 23 or WAVE == 27 then
			print("FLYINGWAVE")
			ENEMIESLEFT = 144 --ammount for air waves
		elseif WAVE == 30 then
			print("BOSSWAVE")
			ENEMIESLEFT = 12 --ammount for boss waves
		else
			print("GROUNDWAVE")
			ENEMIESLEFT = 144 --amount for ground waves
		end
		--self.spawnunits()
		
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
		print( "Wintermaul spawningscript is running." )
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