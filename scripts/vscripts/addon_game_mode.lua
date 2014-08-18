-- Generated from template
require('buildinghelper')
MAPSIZE = 16384
NUMBERTOSPAWN = 8 --How many to spawn
SPAWNLOCATION = {"red_spawn_1","red_spawn_2","blue_spawn_1","blue_spawn_2","teal_spawn_1","teal_spawn_2","orange_spawn_1","orange_spawn_2","yellow_spawn_1","yellow_spawn_2","purple_spawn_1","purple_spawn_2","green_spawn_1","green_spawn_2","grey_spawn_1","grey_spawn_2","pink_spawn_1","pink_spawn_2"}--table of spawn locations in order
WAYPOINTNAME = {"pc_red","pc_red","pc_blue_1","pc_blue_2","pc_teal","pc_teal","pc_orange","pc_orange","pc_yellow_1","pc_yellow_2","pc_purple","pc_purple","pc_green_top","pc_green_top","pc_grey","pc_grey","pc_pink_top","pc_pink_top",}--table to waypoints after spawn location(after this units will know where to go)
CREATURETOSPAWN = {"npc_dota_wintermaul_scouts","npc_dota_wintermaul_engineers","npc_dota_wintermaul_night_ranger","npc_dota_wintermaul_barbarians","npc_dota_wintermaul_drake","npc_dota_wintermaul_stalker","npc_dota_wintermaul_water_runner","npc_dota_wintermaul_ice_troll","npc_dota_wintermaul_wolf_rider","npc_dota_wintermaul_hovercraft","npc_dota_wintermaul_goblin_machine","npc_dota_wintermaul_frosty_reptile","npc_dota_wintermaul_demonic_pets","npc_dota_wintermaul_matured_dragon","npc_dota_wintermaul_ice_shard_golem","npc_dota_wintermaul_eternal_spirit","npc_dota_wintermaul_supply_tank","npc_dota_wintermaul_walking_corpse","npc_dota_wintermaul_totem_carriers","npc_dota_wintermaul_unholy_knight","npc_dota_wintermaul_crystal_mage","npc_dota_wintermaul_frozen_infernal","npc_dota_wintermaul_dragon","npc_dota_wintermaul_polar_bear","npc_dota_wintermaul_posessed_hunter","npc_dota_wintermaul_corrupt_chieftain","npc_dota_wintermaul_ancient_dragon","npc_dota_wintermaul_spider_fiend","npc_dota_wintermaul_armored wisp","npc_dota_wintermaul_duke_wintermaul"}--eventually will be the table of all unit names we need to spawn. For now is just a dumb zombie stolen from reddit
WAVE = 1
ENEMIESLEFT = 144

if CMyMod == nil then
	CMyMod = class({})
end

--essential. loads the unit and model needed into memory
function Precache( context )
		PrecacheUnitByNameAsync( "npc_dota_wintermaul_scouts", context )
        PrecacheModel( "npc_dota_wintermaul_scouts", context )
		for i =1,30 do
			PrecacheUnitByNameAsync( CREATURETOSPAWN[i], context )
			PrecacheModel( CREATURETOSPAWN[i], context )
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
	
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetPreGameTime( 60.0 )
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 60.0 )
	GameRules:SetHeroMinimapIconSize( 600 )
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
	BuildingHelper:BlockGridNavSquares(MAPSIZE)
	
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CMyMod, 'OnEntityKilled' ), self )
	
	--sets the first think
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 15 )
	print( "Template addon is loaded." )
	print(SPAWNLOCATION[1])
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
	print(ENEMIESLEFT)
	if ENEMIESLEFT == 0 then
		WAVE = WAVE + 1
		--print("Next wave: " + WAVE)
		GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 35 )
		if WAVE == 5 or WAVE == 14 or WAVE == 23 or WAVE == 27 then
			print("FLYINGWAVE")
			ENEMIESLEFT = 144 --change this later
		else
			ENEMIESLEFT = 144 --amount for ground waves
		end
		
	end
end

-- this is the thinker. it thinks
function CMyMod:OnThink()
	--idk what this stuff does was in the template
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
		self.spawnunits()
	--every 30 seconds call this function again	
	--return 30000
end