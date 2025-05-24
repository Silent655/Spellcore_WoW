function SpellCore:RunRotation()
    local inCombat = InCombatLockdown()
    local rotation = inCombat and SpellCore.CombatRotation or SpellCore.OOC_Rotation
    if not rotation then
        print("❌ No rotation defined.")
        return
    end

    -- ⏸️ Ctrl held = pause
    if SpellCore.Conditions["modifier.ctrl"] and SpellCore.Conditions["modifier.ctrl"]() then
        return
    end

    -- ⏸️ Channeling? Don't interrupt
    if UnitChannelInfo("player") then
        return
    end

    local env = SpellCore.ConditionEnv:Init()
    SpellCore.CurrentEnv = env  -- Store current environment for condition evaluation

    for _, entry in ipairs(rotation) do
        local spell = entry[1]
        local isMacro = type(spell) == "string" and spell:sub(1, 2) == "!/"
        local target = nil
        local cast = true

        -- 🔁 First pass: Find targeting directive
        for i = 2, #entry do
            local cond = entry[i]
            if type(cond) == "string" and string.sub(cond, 1, 7) == "target." then
                local targetRef = string.sub(cond, 8)

                if targetRef == "cursor" then
                    target = "cursor"
                elseif targetRef == "feet" then
                    target = "feet"
                elseif env[targetRef] and env[targetRef].unit then
                    target = env[targetRef].unit
                    if SpellCore.Debug then
                        print("🎯 Targeting", targetRef, "unit:", target)
                    end
                else
                    if SpellCore.Debug then
                        print("⚠️ Target alias not found or invalid:", targetRef)
                    end
                    target = nil
                end
            end
        end

        -- 🧠 Second pass: Evaluate conditions (ignore conditions if macro)
        for i = 2, #entry do
            local cond = entry[i]
            if not (type(cond) == "string" and string.sub(cond, 1, 7) == "target.") and not isMacro then
                local result = SpellCore:Eval(cond)
                if not result then
                    cast = false
                    break
                end
            end
        end

        -- ✅ Portée de sort (si applicable, pas zone au sol, et pas une macro)
        if cast and target and target ~= "cursor" and target ~= "feet"
           and SpellCore.Conditions["canCastSpell"]
           and not isMacro then

            local ok, result = pcall(SpellCore.Conditions["canCastSpell"], spell, target)
            if not ok then
                print("❌ Error in canCastSpell with:", spell, target, "-", result)
                cast = false
            elseif not result then
                if SpellCore.Debug then
                    print("⛔ Out of range:", spell, "→", target)
                end
                cast = false
            end
        end

        -- ✅ Casting
        if cast then
            if SpellCore.Debug then
                print("✅ Casting", spell, "on target:", target or "default")
            end
            local didCast = self:Cast(spell, target)
            if didCast then
                return
            end
        end
    end
end
