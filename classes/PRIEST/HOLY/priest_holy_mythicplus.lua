SpellCoreRotations["PRIEST_HOLY_MYTHICPLUS"] = function()
    print("✨ Holy Priest M+ rotation loaded.")

    -- ⚙️ Out of Combat
    SpellCore.OOC_Rotation = {

	---BUFF---
	---MOVEMENT---
	---PRE HOT/SHIELD---


        { "Prayer of Mending", "not hasBuff('player', 'Prayer of Mending')", "target.lowest" },
        { "Renew", "not hasBuff('target.lowest', 'Renew')", "target.lowest" },
    }

    -- ⚔️ In Combat
    SpellCore.CombatRotation = {




	---DEF---
	---MOVEMENT---
	---AGGRO---
	---CD---
	---EXTERNALS---
	---DISPELL---
	---TANK---
	---SEASON SPEC---
	---HEALING---



        -- Cooldowns
        { "Halo", "toggle.major", "hasNearbyEnemies(40, 3)" },
        { "Divine Hymn", "toggle.major", "alliesBelowHP(60, 4)" },
        { "Apotheosis", "toggle.major", "alliesBelowHP(70, 3)" },

        -- Healing Priority
        { "Prayer of Mending", "cooldown('Prayer of Mending') <= 0", "target.lowest" },
        { "Heal", "healthPercent('target.lowest') <= 80", "hasBuff('player', 'Resonant Words')", "hasBuff('player', 'Lightweaver')", "target.lowest" },
        { "Holy Word: Serenity", "healthPercent('target.lowest') <= 90", "buff.count('player', 'Resonant Words') == 0", "cooldown('Holy Word: Serenity') <= 0", "target.lowest" },
        { "Holy Word: Sanctify", "buff.count('player', 'Resonant Words') == 0", "enemyCount(8) >= 3", "target.cursor" },
        { "Flash Heal", "healthPercent('target.lowest') <= 70", "buff.count('player', 'Lightweaver') < 2", "target.lowest" },
        { "Holy Word: Serenity", "healthPercent('target.lowest') <= 50", "buff.count('player', 'Resonant Words') == 0", "target.lowest" },
        { "Holy Nova", "buff.count('player', 'Rhapsody') >= 15", "enemyCount(8) >= 3", "target.player" },
        { "Heal", "healthPercent('target.lowest') <= 75", "cooldown('Holy Word: Serenity') > 0", "target.lowest" },
        { "Renew", "toggle.mov", "not hasBuff('target.lowest', 'Renew')", "target.lowest" },

        -- Damage Priority
        { "Holy Fire", "cooldown('Holy Fire') <= 0", "isAttackable(target)", "target.target" },
        { "Holy Word: Chastise", "cooldown('Holy Word: Chastise') <= 0", "isAttackable(target)", "target.target" },
        { "Holy Nova", "buff.count('player', 'Rhapsody') >= 15", "enemyCount(8) >= 3", "target.player" },
        { "Holy Nova", "enemyCount(8) >= 5", "target.player" },
        { "Smite", "isAttackable(target)", "target.target" },
        { "Shadow Word: Pain", "toggle.mov", "not hasDebuff('target', 'Shadow Word: Pain')", "target.target" }

    }
end
