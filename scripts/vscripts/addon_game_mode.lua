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
	_G.CWintermaulGameMode = class({})		-- I believe the _G prefix specifies a global class
end

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
require('gamemode')

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
	--activates the mod.
	GameRules.CWintermaulGameMode = CWintermaulGameMode()
	--calls InitGameMode
	GameRules.CWintermaulGameMode:InitGameMode()
	
end