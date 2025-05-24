SpellCoreRotations["EVOKER_PRESERVATION_MYTHICPLUS"] = function()
    print("🔥 EVOKER_PRESERVATION_MYTHICPLUS rotation initialized.")

    -- Out of Combat
    SpellCore.OOC_Rotation = {

	{ "Dream Breath", "target.target" },
    }

    -- Combat
    SpellCore.CombatRotation = {
        -- Example: { "SpellName", "Condition" }
    }
end
