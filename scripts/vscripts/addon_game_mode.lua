--[[
Wintermaul

	Underscore prefix such as "_function()" denotes a local function and is used to improve readability

	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
]]

if CWintermaulGameMode == nil then
	CWintermaulGameMode = class({})
end

if CustomGameMode == nil then
	_G.CustomGameMode = class({})
end

require('gamemode')
require('utilities')
require('upgrades')
require('mechanics')
require('orders')
require('builder')
require('buildinghelper')

require('libraries/timers')
require('libraries/popups')
require('libraries/notifications')


require("wintermaul_game_round")
require("wintermaul_game_spawner")

--essential. loads the unit and model needed into memory
function Precache( context )
	-- Model ghost and grid particles
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheUnitByNameSync("nature_pool", context)
	PrecacheUnitByNameSync("terran_protector", context)
	PrecacheItemByNameSync("item_apply_modifiers", context)
	print( "Precaching is complete." )
end

function Activate()
	CustomGameMode:InitGameMode()
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
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,10)
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
	
	-- Initialize Variables for Tracking
	player.units = {} -- This keeps the handle of all the units of the player, to iterate for unlocking upgrades
	player.structures = {} -- This keeps the handle of the constructed units, to iterate for unlocking upgrades
	player.buildings = {} -- This keeps the name and quantity of each building
	player.upgrades = {} -- This kees the name of all the upgrades researched
	player.lumber = 0 -- Secondary resource of the player


	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if (PlayerResource:IsValidPlayer( nPlayerID ) ) then
			for e=0,15 do
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

function CWintermaulGameMode:OnEntityKilled()
	--@todo do something when an entity dies
end

--[[
-- Called whenever a player changes its current selection, it keeps a list of entity indexes
function CWintermaulGameMode:OnPlayerSelectedEntities( event )
	local pID = event.pID

	GameRules.SELECTED_UNITS[pID] = event.selected_entities

	-- This is for Building Helper to know which is the currently active builder
	local mainSelected = GetMainSelectedEntity(pID)
	if IsValidEntity(mainSelected) and IsBuilder(mainSelected) then
		local player = PlayerResource:GetPlayer(pID)
		player.activeBuilder = mainSelected
	end
end
]]--