
CREATURETOSPAWN = "npc_dota_creature_basic_zombie"--eventually will be the table of all unit names we need to spawn. For now is just a dumb zombie stolen from reddit

--essential. loads the unit and model needed into memory
function Precache( context )
		PrecacheUnitByNameAsync( "npc_dota_creature_basic_zombie", context )
        PrecacheModel( "npc_dota_creature_basic_zombie", context )
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
	print( "Addon is loaded." )
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