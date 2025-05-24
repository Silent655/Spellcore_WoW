SpellCoreRotations["MAGE_FIRE_MYTHICPLUS"] = function()
    print("🔥 MAGE_FIRE_MYTHICPLUS rotation initialized.")

    SpellCore.OOC_Rotation = {
        { "Arcane Intellect", "not hasBuff('player', 'Arcane Intellect')" },
    }

    SpellCore.CombatRotation = {

		-- 🔥 DEF
		
		{ "item:Algari Healing Potion", "healthPercent('player') <= 25", "itemCooldownByName('Algari Healing Potion') <= 0", "target.player" },







		-- 🔥 CD
		{ "Combustion", "isAttackable(target)", "toggle.major", "target.target" },
		{ "168973", "itemCooldown(168973) <= 0", "hasBuff('player', 'Combustion')", "isAttackable(target)", "target.target" },

	

        -- 🔥 COMBUSTION Phase
        { "Pyroblast", "not toggle.aoe", "hasBuffFixed('player', 'Hot Streak')", "hasBuff('player', 'Combustion')", "isAttackable(target)", "target.target" },
		{ "Flamestrike", "toggle.aoe", "hasBuffFixed('player', 'Hot Streak')", "hasBuff('player', 'Combustion')", "isAttackable(target)", "target.cursor" },
        { "Fire Blast", "hasBuff('player', 'Heating Up')", "hasBuff('player', 'Combustion')", "isAttackable(target)", "target.target" },
        { "Phoenix Flames", "hasBuff('player', 'Heating Up')", "hasBuff('player', 'Combustion')", "isAttackable(target)", "target.target" },
        { "Phoenix Flames", "hasBuff('player', 'Combustion')", "isAttackable(target)", "target.target" },
        { "Scorch", "hasBuff('player', 'Combustion')", "isAttackable(target)", "target.target" },

        -- 🔥 OUTSIDE Combustion Phase
        { "Shifting Power", "not player.moving", "not hasBuff('player', 'Combustion')", "hasBuff('player', 'Hyperthermia')", "isAttackable(target)", "target.player" },
        { "Pyroblast", "not toggle.aoe", "hasBuffFixed('player', 'Hot Streak')", "not hasBuff('player', 'Combustion')", "isAttackable(target)", "target.target" },
	    { "Flamestrike", "toggle.aoe", "hasBuffFixed('player', 'Hot Streak')", "not hasBuff('player', 'Combustion')", "isAttackable(target)", "target.cursor" },
        { "Fire Blast", "toggle.major", "hasBuff('player', 'Heating Up')", "not hasBuff('player', 'Combustion')", "cooldown(Combustion) > 10", "isAttackable(target)", "target.target" },
		{ "Fire Blast", "not toggle.major", "hasBuff('player', 'Heating Up')", "not hasBuff('player', 'Combustion')", "isAttackable(target)", "target.target" },
        { "Phoenix Flames", "not hasBuff('player', 'Combustion')", "isAttackable(target)", "target.target" },
        { "Scorch", "healthPercent('target') <= 30", "isAttackable(target)", "target.target" },
		{ "Scorch", "player.moving", "isAttackable(target)", "target.target" },
        { "Fireball", "not player.moving", "isAttackable(target)", "target.target" },
    }
end