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

require('builder')

require('libraries/buildinghelper')
require('libraries/selection')
require('libraries/notifications')
require('libraries/timers')

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
	PrecacheUnitByNameSync("crystal_buster",context)
	PrecacheUnitByNameSync("crystal_slower",context)
	PrecacheUnitByNameSync("crystal_fury",context)
	PrecacheUnitByNameSync("crystal_blaster",context)
	PrecacheUnitByNameSync("crystal_shooter",context)

	PrecacheResource("particle","particles/units/heroes/hero_tinker/tinker_laser.vpcf",context)
	PrecacheResource("particle","particles/units/heroes/hero_oracle/oracle_base_attack.vpcf",context)
	PrecacheResource("particle","particles/econ/items/enigma/enigma_geodesic/enigma_base_attack_eidolon_geodesic.vpcf",context)
	PrecacheResource("particle","particles/base_attacks/fountain_attack.vpcf",context)

	--Earth towers
	PrecacheUnitByNameSync("nature_pool",context)
	PrecacheUnitByNameSync("terran_protector",context)
	PrecacheUnitByNameSync("gaias_box",context)
	PrecacheUnitByNameSync("earths_soul",context)
	PrecacheUnitByNameSync("ground_pounder",context)
	PrecacheUnitByNameSync("gaia",context)

	PrecacheResource("particle","particles/units/heroes/hero_morphling/morphling_base_attack.vpcf",context)
	PrecacheResource("particle","particles/base_attacks/ranged_hero.vpcf",context)
	PrecacheResource("particle","particles/units/heroes/hero_enchantress/enchantress_base_attack.vpcf",context)

	--Powerplant towers
	PrecacheUnitByNameSync("shock_tower",context)
	PrecacheUnitByNameSync("",context)
	PrecacheUnitByNameSync("",context)
	PrecacheUnitByNameSync("",context)
	PrecacheUnitByNameSync("",context)
	PrecacheUnitByNameSync("",context)

	print( "Precaching is complete, bitches." )
end

function Activate()
	--activates the mod.
	GameRules.CWintermaulGameMode = CWintermaulGameMode()
	--calls InitGameMode
	GameRules.CWintermaulGameMode:InitGameMode()
end