-- Generated from template
require('buildinghelper')
MAPSIZE = 16384
NUMBERTOSPAWN = 8 --How many to spawn
SPAWNLOCATION = {"red_spawn_1","red_spawn_2","blue_spawn_1","blue_spawn_2","teal_spawn_1","teal_spawn_2","orange_spawn_1","orange_spawn_2","yellow_spawn_1","yellow_spawn_2","purple_spawn_1","purple_spawn_2","green_spawn_1","green_spawn_2","grey_spawn_1","grey_spawn_2","pink_spawn_1","pink_spawn_2"}--table of spawn locations in order
WAYPOINTNAME = {"pc_red","pc_red","pc_blue_1","pc_blue_2","pc_teal","pc_teal","pc_orange","pc_orange","pc_yellow_1","pc_yellow_2","pc_purple","pc_purple","pc_green_top","pc_green_top","pc_grey","pc_grey","pc_pink_top","pc_pink_top",}--table to waypoints after spawn location(after this units will know where to go)
CREATURETOSPAWN = {"npc_dota_wintermaul_scouts","npc_dota_wintermaul_engineers","npc_dota_wintermaul_night_ranger","npc_dota_wintermaul_barbarians","npc_dota_wintermaul_drake","npc_dota_wintermaul_stalker","npc_dota_wintermaul_water_runner","npc_dota_wintermaul_ice_troll","npc_dota_wintermaul_wolf_rider","npc_dota_wintermaul_hovercraft","npc_dota_wintermaul_goblin_machine","npc_dota_wintermaul_frosty_reptile","npc_dota_wintermaul_demonic_pets","npc_dota_wintermaul_matured_dragon","npc_dota_wintermaul_ice_shard_golem","npc_dota_wintermaul_eternal_spirit","npc_dota_wintermaul_supply_tank","npc_dota_wintermaul_walking_corpse","npc_dota_wintermaul_totem_carriers","npc_dota_wintermaul_unholy_knight","npc_dota_wintermaul_crystal_mage","npc_dota_wintermaul_frozen_infernal","npc_dota_wintermaul_dragon","npc_dota_wintermaul_polar_bear","npc_dota_wintermaul_posessed_hunter","npc_dota_wintermaul_corrupt_chieftain","npc_dota_wintermaul_ancient_dragon","npc_dota_wintermaul_spider_fiend","npc_dota_wintermaul_armored wisp","npc_dota_wintermaul_duke_wintermaul"}--eventually will be the table of all unit names we need to spawn. For now is just a dumb zombie stolen from reddit

if CMyMod == nil then
	CMyMod = class({})
end

--essential. loads the unit and model needed into memory
function Precache( context )
		PrecacheUnitByNameAsync( "npc_dota_wintermaul_scouts", context )
        PrecacheModel( "npc_dota_wintermaul_scouts", context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
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
					local creature = CreateUnitByName( CREATURETOSPAWN , spawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
					--print ("create unit has run")
					creature:SetInitialGoalEntity( waypointlocation )
					j = j + 1
			end
			print ("nextspawn")
			i=i+1
			j=1
		end
		
end    
function Activate()
	--activates the mod. 
	GameRules.CMyMod = CMyMod()
	--calls InitGameMode
	GameRules.CMyMod:InitGameMode()
end

function CMyMod:InitGameMode()
	print( "Template addon is loaded." )
	print(SPAWNLOCATION[1])
	BuildingHelper:BlockGridNavSquares(MAPSIZE)
	
	--sets the first think
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 15 )
	
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
	return 30
end