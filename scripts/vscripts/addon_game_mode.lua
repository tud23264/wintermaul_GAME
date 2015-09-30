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
	

	--Fire towers
	PrecacheUnitByNameSync("flare_tower", context)
	PrecacheUnitByNameSync("flame_dancer", context)
	PrecacheUnitByNameSync("meteor_watcher", context)
	PrecacheUnitByNameSync("blast_furnace", context)
	PrecacheUnitByNameSync("incinerator", context)
	PrecacheUnitByNameSync("flame_staff", context)

	PrecacheResource("particle","particles/base_attacks/ranged_badguy.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_jakiro/jakiro_macropyre_projectile.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_luna/luna_eclipse_impact.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire_b.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_lina/lina_base_attack.vpcf", context)
	PrecacheResource("particle","particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf", context)
	
	--Crystal towers
	PrecacheUnitByNameSync("crystal_dissolver",context)
	PrecacheResource("particle","particles/units/heroes/hero_tinker/tinker_laser.vpcf",context)
	print( "Precaching is complete, bitches." )
end

function Activate()
	--activates the mod.
	GameRules.CWintermaulGameMode = CWintermaulGameMode()
	--calls InitGameMode
	GameRules.CWintermaulGameMode:InitGameMode()
	
end