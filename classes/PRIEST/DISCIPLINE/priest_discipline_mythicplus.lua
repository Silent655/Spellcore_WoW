SpellCoreRotations["PRIEST_DISCIPLINE_MYTHICPLUS"] = function()
    print("🔥 PRIEST_DISCIPLINE_MYTHICPLUS rotation initialized.")

    -- Out of Combat
	
    SpellCore.OOC_Rotation = {

	--BUFFS---      
  

	{ "Power Word: Fortitude", "not hasBuff('player', 'Power Word: Fortitude')", "target.player" },
	{ "Power Word: Fortitude", "unitExists('party1')", "not hasBuff('party1', 'Power Word: Fortitude')", "target.player" },
	{ "Power Word: Fortitude", "unitExists('party2')", "not hasBuff('party2', 'Power Word: Fortitude')", "target.player" },
	{ "Power Word: Fortitude", "unitExists('party3')", "not hasBuff('party3', 'Power Word: Fortitude')", "target.player" },
	{ "Power Word: Fortitude", "unitExists('party4')", "not hasBuff('party4', 'Power Word: Fortitude')", "target.player" },

	--MOVEMENT---

	 { "Angelic Feather", "player.moving", "not hasBuff('player', 'Angelic Feather')", "target.feet" },

	---PREPULL---

	{ "Smite", "isAttackable(target)", "bigwigsTimerLE('Pull,2')", "target.target" },
	
	}

    -- Combat
	
    SpellCore.CombatRotation = {

	---DEF---
	
	{ "Desperate Prayer", "toggle.def", "healthPercent('player') <= 30", "target.player" },
	{ "item:Healthstone", "toggle.def","healthPercent('player') <= 25", "itemCooldownByName('Healthstone') <= 0", "target.player" },
	{ "item:Algari Healing Potion", "toggle.def", "healthPercent('player') <= 25", "itemCooldownByName('Algari Healing Potion') <= 0", "target.player" },
	
	---MOVEMENT---

	{ "Angelic Feather", "player.moving", "not hasBuff('player', 'Angelic Feather')", "target.feet" },
	{ "Power Word: Shield", "player.moving", "lowest.hp <= 90", "target.lowest" },
	{ "Renew", "player.moving", "cooldown('Power Word: Shield') > 0", "lowest.hp <= 90", "buffDuration('lowest', 'Atonement') <= 2", "target.lowest" },
	{ "Renew", "player.moving", "cooldown('Power Word: Shield') > 0", "secondLowest.hp <= 90", "buffDuration('lowest', 'Atonement') <= 2", "target.secondLowest" },

	---AGGRO---

	{ "Fade", "hasAggro(player)", "target.player" },

	---CD---
	
	{ "Evangelism", "toggle.major", "myAtonementCount() > 3", "target.player" },
	{ "Mindbender", "toggle.major", "isAttackable(target)", "myAtonementCount() > 3", "target.target" },

	---EXTERNALS---
	
	{ "Pain Suppression", "toggle.minor", "lowest.hp <= 25", "target.lowest" },

	---DISPELL---

	{ "Purify", "canDispelMagic('player')", "target.player" },
	{ "Purify", "unitExists('party1')", "canDispelMagic('party1')", "target.party1" },
	{ "Purify", "unitExists('party2')", "canDispelMagic('party2')", "target.party2" },
	{ "Purify", "unitExists('party3')", "canDispelMagic('party3')", "target.party3" },
	{ "Purify", "unitExists('party4')", "canDispelMagic('party4')", "target.party4" },
	
	---TANK PRIO---
	
	{ "Power Word: Shield", "buffDuration('tankmate', 'Atonement') <= 2", "target.tankmate" },
	{ "Renew", "cooldown('Power Word: Shield') > 0", "buffDuration('tankmate', 'Atonement') <= 2", "target.tankmate" },

	---MYTHIC+ SEASON 2 AOE DAMAGE---

	{ "Power Word: Radiance", "enemyCastingSpell(Trickshot)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Warp Blood)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Jettison Kelp)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Backwash)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Battery Discharge)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Localized Storm)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Attracting Shadows)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Feasting Void)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Unleash Darkness)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Reflective Shield)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Sacred Toll)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Fireball Volley)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Radiant Flame)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Explosive Flame)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Drain Light)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Volatile Keg)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Failed Batch)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Reckless Delivery)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Honey Volley)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Fan of Knives)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Charged Shield)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Rapid Extraction)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Furious Quake)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Charged Shot)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Detonate)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Mega Drill)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(High-Explosive Rockets)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Raging Tantrum)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Soulstorm)", "myAtonementCount() < 3", "target.player" },
	{ "Power Word: Radiance", "enemyCastingSpell(Withering Discharge)", "myAtonementCount() < 3", "target.player" },

	---HEAL---
	
	{ "Power Word: Radiance", "not player.moving", "alliesBelowHP(90, 3)", "myAtonementCount() < 3", "target.lowest" },
	{ "Power Word: Radiance", "not player.moving", "alliesBelowHP(70, 3)", "myAtonementCount() < 5", "target.lowest" },
	{ "Power Word: Shield", "lowest.hp <= 80", "target.lowest" },
	{ "Flash Heal", "lowest.hp <= 75", "not hasBuff('lowest', 'Atonement')", "target.lowest" },
	{ "Shadow Word: Pain", "isAttackable(target)", "debuffDuration('target', 'Shadow Word: Pain') <= 3", "target.target" },
	{ "Shadow Word: Death", "isAttackable(target)", "target.target" },
	{ "Mind Blast", "isAttackable(target)", "not player.moving", "target.target" },
	{ "Penance", "isAttackable(target)", "target.target" },
	{ "Smite", "isAttackable(target)", "not player.moving", "target.target" },

	
    }
end
