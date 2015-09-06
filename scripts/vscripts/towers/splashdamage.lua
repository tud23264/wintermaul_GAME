function SplashDamage(keys)
	local caster = keys.caster
	local keydamage = caster:GetAverageTrueAttackDamage() --/2
	local radius = keys.radius
	local target = keys.target

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)

	for i = 1, #targets do
		if targets[i] ~= target then --avoid dealing twice the damage
			local damageTable = {
				victim = targets[i],
				attacker = caster,
				damage = keydamage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)
		end
	end
end