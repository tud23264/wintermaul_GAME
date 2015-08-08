--[[
Wintermaul

	Underscore prefix such as "_function()" denotes a local function and is used to improve readability

	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
]]
require( "wintermaul_game_round" )
require( "wintermaul_game_spawner" )
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

if CWintermaulGameMode == nil then
	CWintermaulGameMode = class({})
end

--essential. loads the unit and model needed into memory
function Precache( context )

	print( "Precaching is complete." )
end

function Activate()
	--activates the mod.
	GameRules.CWintermaulGameMode = CWintermaulGameMode()
	--calls InitGameMode
	GameRules.CWintermaulGameMode:InitGameMode()
end


function CWintermaulGameMode:InitGameMode()
	self._nRoundNumber = 1
	self._currentRound = nil
	self._flLastThinkGameTime = nil
	self._nCurrentSpawnerID = 1
	print("id: %d", self._nCurrentSpawnerID)
	self:_ReadGameConfiguration()
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetPreGameTime( 10.0 )
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
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CWintermaulGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( CWintermaulGameMode, "OnPlayerPicked" ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CWintermaulGameMode, "OnGameRulesStateChange" ), self )

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 0.25 )
	print( "Wintermaul is loaded." )
end

-- Read and assign configurable keyvalues if applicable
function CWintermaulGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues( "scripts/maps/wintermaul_map_config.txt" )
	kv = kv or {} -- Handle the case where there is not keyvalues file

	self._flPrepTimeBetweenRounds = tonumber( kv.PrepTimeBetweenRounds or 0 )

	self:_ReadSpawnsConfiguration( kv["Spawns"] )
	self:_ReadRoundConfigurations( kv["Waves"])
end


-- Verify spawners if random is set
function CWintermaulGameMode:ChooseSpawnInfo()
	if #self._vSpawnsList == 0 then
		error( "Attempt to choose a random spawn, but no random spawns are specified in the data." )
		return nil
	end
	return self._vSpawnsList[ self:_NextSpawnerID() ]  --#RandomInt( 1, #self._vpawnsList )
end

function CWintermaulGameMode:_NextSpawnerID()
	print("id: %d", self._nCurrentSpawnerID)
	if self._nCurrentSpawnerID == nil then
		self._nCurrentSpawnerID = 0
	end
	print("id: %d", self._nCurrentSpawnerID)
	--calculate the next ID
	--increment the spawn ID
	local nNextSpawnerID = (self._nCurrentSpawnerID + 1)
	-- wrap the value
	nNextSpawnerID = (nNextSpawnerID % #self._vSpawnsList) + 1

	--store the current ID
	local nSpawnerID = self._nCurrentSpawnerID

	--set the current ID to be the next one
	self._nCurrentSpawnerID = nNextSpawnerID

	--return the current ID
	return nSpawnerID
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
function CWintermaulGameMode:OnPlayerPicked()

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
	return 1
end
