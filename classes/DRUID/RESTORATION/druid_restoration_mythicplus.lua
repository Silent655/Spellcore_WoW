SpellCoreRotations["DRUID_RESTORATION_MYTHICPLUS"] = function()
    print("🔥 DRUID_RESTORATION_MYTHICPLUS rotation initialized.")

    -- Out of Combat

    SpellCore.OOC_Rotation = {

	--BUFFS---  

	{ "Mark of the Wild", "not hasBuff('player', 'Mark of the Wild')", "target.player" },
	{ "Symbiotic Relationship", "isTank('tankmate')", "not hasBuff('tankmate', 'Symbiotic Relationship')", "target.tankmate" },
	{ "Mark of the Wild", "unitExists('party1')", "isFriend('party1')", "isFriendlyInRange('party1')", "not hasBuff('party1', 'Mark of the Wild')", "target.party1" },
	{ "Mark of the Wild", "unitExists('party2')", "isFriend('party2')", "isFriendlyInRange('party2')", "not hasBuff('party2', 'Mark of the Wild')", "target.party2" },
	{ "Mark of the Wild", "unitExists('party3')", "isFriend('party3')", "isFriendlyInRange('party3')","not hasBuff('party3', 'Mark of the Wild')", "target.party3" },
	{ "Mark of the Wild", "unitExists('party4')", "isFriend('party4')", "isFriendlyInRange('party4')","not hasBuff('party4', 'Mark of the Wild')", "target.party4" },

	--LIFEBLOOM PRECOMBAT---

	{ "Lifebloom", "not hasBuff('player', 'Food & Drink')", "buffDuration('tankmate', 'Lifebloom') <= 4", "target.tankmate" },
	{ "Lifebloom", "not hasBuff('player', 'Food & Drink')", "buffDuration('player', 'Lifebloom') <= 4", "target.player" },

	--PRE REJUV---

	{ "Rejuvenation", "not hasBuff('player', 'Food & Drink')", "unitExists('party1')", "isFriend('party1')", "isFriendlyInRange('party1')", "not hasBuff('party1', 'Rejuvenation')", "target.party1" },
	{ "Rejuvenation", "not hasBuff('player', 'Food & Drink')", "unitExists('party2')", "isFriend('party2')", "isFriendlyInRange('party2')", "not hasBuff('party2', 'Rejuvenation')", "target.party2" },
	{ "Rejuvenation", "not hasBuff('player', 'Food & Drink')", "unitExists('party3')", "isFriend('party3')", "isFriendlyInRange('party3')", "not hasBuff('party3', 'Rejuvenation')", "target.party3" },
	{ "Rejuvenation", "not hasBuff('player', 'Food & Drink')", "unitExists('party4')", "isFriend('party4')", "isFriendlyInRange('party4')", "not hasBuff('party4', 'Rejuvenation')", "target.party4" },

 }

    -- Combat.

    SpellCore.CombatRotation = {

	--DEF---

	{ "item:Algari Healing Potion", "healthPercent('player') <= 15", "itemCooldownByName('Algari Healing Potion') <= 0", "target.player" },
	{ "item:Healthstone", "healthPercent('player') <= 15", "itemCooldownByName('Healthstone') <= 0", "target.player" },
	{ "Renewal", "healthPercent('player') <= 25", "target.player" },
	{ "Barkskin", "healthPercent('player') <= 40", "target.player" },

	--BUFFS---  

	{ "Mark of the Wild", "not hasBuff('player', 'Mark of the Wild')", "target.player" },

	{ "Mark of the Wild", "unitExists('party1')", "isFriend('party1')", "isFriendlyInRange('party1')", "not hasBuff('party1', 'Mark of the Wild')", "target.party1" },
	{ "Mark of the Wild", "unitExists('party2')", "isFriend('party2')", "isFriendlyInRange('party2')", "not hasBuff('party2', 'Mark of the Wild')", "target.party2" },
	{ "Mark of the Wild", "unitExists('party3')", "isFriend('party3')", "isFriendlyInRange('party3')","not hasBuff('party3', 'Mark of the Wild')", "target.party3" },
	{ "Mark of the Wild", "unitExists('party4')", "isFriend('party4')", "isFriendlyInRange('party4')","not hasBuff('party4', 'Mark of the Wild')", "target.party4" },

	---DISPELL---

	{ "Nature's Cure", "canDispelMagic('player')", "target.player" },
	{ "Nature's Cure", "unitExists('party1')", "canDispelMagic('party1')", "target.party1" },
	{ "Nature's Cure", "unitExists('party2')", "canDispelMagic('party2')", "target.party2" },
	{ "Nature's Cure", "unitExists('party3')", "canDispelMagic('party3')", "target.party3" },
	{ "Nature's Cure", "unitExists('party4')", "canDispelMagic('party4')", "target.party4" },
	{ "Nature's Cure", "unitExists('party1')", "canDispelPoison('party1')", "target.party1" },
	{ "Nature's Cure", "unitExists('party2')", "canDispelPoison('party2')", "target.party2" },
	{ "Nature's Cure", "unitExists('party3')", "canDispelPoison('party3')", "target.party3" },
	{ "Nature's Cure", "unitExists('party4')", "canDispelPoison('party4')", "target.party4" },
	{ "Nature's Cure", "unitExists('party1')", "canDispelCurse('party1')", "target.party1" },
	{ "Nature's Cure", "unitExists('party2')", "canDispelCurse('party2')", "target.party2" },
	{ "Nature's Cure", "unitExists('party3')", "canDispelCurse('party3')", "target.party3" },
	{ "Nature's Cure", "unitExists('party4')", "canDispelCurse('party4')", "target.party4" },

	---INTERUPT---

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Surveying Beam')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Surveying Beam')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Cinderblast')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Cinderblast')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Fireball Volley')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Fireball Volley')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Mole Frenzy')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Mole Frenzy')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Explosive Flame')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Explosive Flame')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Flaming Tether')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Flaming Tether')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Drain Light')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Drain Light')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Free Samples?')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Free Samples?')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Bee-stial Wrath')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Bee-stial Wrath')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Honey Volley')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Honey Volley')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Toxic Blades')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Toxic Blades')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Rock Lance')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Rock Lance')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Furious Quake')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Furious Quake')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Detonate')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Detonate')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Giga-Wallop')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Giga-Wallop')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Bone Spear')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Bone Spear')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Necrotic Bolt Volley')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Necrotic Bolt Volley')", "target.mouseover" },

	{ "Skull Bash", "isEnemy('target')", "castInterruptible('target')", "castRemaining('target') <= 0.4", "targetCastingSpell('Withering Discharge')", "target.target" },
	{ "Skull Bash", "isEnemy('mouseover')", "castInterruptible('mouseover')", "castRemaining('mouseover') <= 0.4", "mouseoverCastingSpell('Withering Discharge')", "target.mouseover" },


	---EXTERNALS---

	{ "Ironbark", "bigwigsTimerLE('Rock Buster', 2)", "target.tankmate" },
	{ "Ironbark", "bigwigsTimerLE('Rock Buster', 2)", "target.tankmate" },
	{ "Ironbark", "healthPercent('tankmate') <= 55", "target.tankmate" },

	---COOLDOWNS---

	{ "Convoke the Spirits", "toggle.major", "isAttackable('target')", "target.target" },
	{ "Nature's Vigil", "toggle.major", "isAttackable('target')", "target.target" },
	{ "Heart of the Wild", "toggle.major", "isAttackable('target')", "target.target" },


	---HEAL---

	{ "Wild Growth", "not player.moving", "buffDuration('player', 'Soul of the Forest') >= 1", "target.lowest" },
	{ "Efflorescence", "modifier.shift", "buffDuration('player', 'Efflorescence') <= 2", "target.feet" },
	{ "Efflorescence", "toggle.ground", "buffDuration('player', 'Efflorescence') <= 2", "target.feet" },
	{ "Lifebloom", "buffDuration('tankmate', 'Lifebloom') <= 4", "target.tankmate" },
	{ "Lifebloom", "buffDuration('player', 'Lifebloom') <= 4", "target.player" },
	{ "Swiftmend", "not player.moving", "alliesBelowHP(90, 3)", "buffDuration('player', 'Soul of the Forest') <= 0", "buffDuration('lowest', 'Regrowth') >= 0", "target.lowest" },
	{ "Swiftmend", "not player.moving", "alliesBelowHP(90, 3)", "buffDuration('player', 'Soul of the Forest') <= 0", "buffDuration('lowest', 'Rejuvenation') >= 0", "target.lowest" },
	{ "Wild Growth", "not player.moving", "alliesBelowHP(90, 3)", "buffDuration('player', 'Soul of the Forest') >= 0", "buffDuration('player', 'Regrowth') >= 0", "target.lowest" },
	{ "Swiftmend", "lowest.hp <= 60", "buffDuration('lowest', 'Regrowth') >= 0", "target.lowest" },
	{ "Swiftmend", "lowest.hp <= 60", "buffDuration('lowest', 'Rejuvenation') >= 0", "target.lowest" },
	{ "Grove Guardians", "lowest.hp <= 70", "target.lowest" },
	{ "Regrowth", "lowest.hp <= 65", "target.lowest" },
	{ "Rejuvenation", "lowest.hp <= 80", "not hasBuff('lowest', 'Rejuvenation')", "target.lowest" },

	{ "Rejuvenation", "unitExists('party1')", "isFriend('party1')", "isFriendlyInRange('party1')", "not hasBuff('party1', 'Rejuvenation')", "target.party1" },
	{ "Rejuvenation", "unitExists('party2')", "isFriend('party2')", "isFriendlyInRange('party2')", "not hasBuff('party2', 'Rejuvenation')", "target.party2" },
	{ "Rejuvenation", "unitExists('party3')", "isFriend('party3')", "isFriendlyInRange('party3')", "not hasBuff('party3', 'Rejuvenation')", "target.party3" },
	{ "Rejuvenation", "unitExists('party4')", "isFriend('party4')", "isFriendlyInRange('party4')", "not hasBuff('party4', 'Rejuvenation')", "target.party4" },

	
	{ "Rip", "isAttackable('target')", "comboPoints('player') >= 5", "debuffDuration('target', 'Rip') <= 3", "hasBuff('player', 'Cat Form')", "target.target" },
	{ "Ferocious Bite", "isAttackable('target')", "comboPoints('player') >= 5", "debuffDuration('target', 'Rip') >= 3", "hasBuff('player', 'Cat Form')", "target.target" },
	{ "Thrashcat", "isAttackable('target')", "comboPoints('player') <= 5", "debuffDuration('target', 'Thrash') <= 3", "hasBuff('player', 'Cat Form')", "target.target" },

	{ "Rake", "isAttackable('target')", "comboPoints('player') <= 5", "debuffDuration('target', 'Rake') <= 3", "target.target" },
	{ "Moonfire", "isAttackable('target')", "comboPoints('player') <= 5", "debuffDuration('target', 'Moonfire') <= 3", "target.target" },
	{ "Shred", "isAttackable('target')", "comboPoints('player') <= 5", "power('player', 'ENERGY') > 50", "target.target" }


    }
end
