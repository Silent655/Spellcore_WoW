function SpellCore:Cast(spell, target)

-- 📜 Macro support
if type(spell) == "string" and spell:sub(1, 6) == "!/cast" then
    RunMacroText(spell:sub(2)) -- Strip leading !
    print("📜 Trying to run macro:", spell:sub(2)) -- ← AJOUT ICI
    if SpellCore.Debug then print("📜 Running macro:", spell) end
    return true
end

    -- 🐾 Alias spécial pour Thrash (Cat)
    if spell == "Thrashcat" then
        spell = "Thrash"
    end

-- 🔹 Use item directly by name (format: item:Algari Healing Potion)
if type(spell) == "string" and string.sub(spell, 1, 5) == "item:" then
    local expectedName = string.sub(spell, 6)

    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local name = GetItemInfo(itemLink)
                if name == expectedName then
                    local start, duration, enable = C_Container.GetContainerItemCooldown(bag, slot)
                    local cd = start + duration - GetTime()
                    if enable == 1 and cd <= 0 then
                        print("🧪 Using", name, "from bag", bag, "slot", slot)
                        C_Container.UseContainerItem(bag, slot)
                        return true
                    else
                        print("⏳", name, "on cooldown.")
                    end
                end
            end
        end
    end

    print("❌", expectedName, "not found or not usable.")
    return false
end

    -- 🔢 Attempt to use an item by itemID (numeric only, used for trinkets/weapons)
    local itemID = tonumber(spell)
    if itemID then
        local slots = {
            INVSLOT_TRINKET1, INVSLOT_TRINKET2,
            INVSLOT_FINGER1, INVSLOT_FINGER2,
            INVSLOT_MAINHAND, INVSLOT_OFFHAND,
            INVSLOT_NECK
        }

        for _, slotID in ipairs(slots) do
            if GetInventoryItemID("player", slotID) == itemID then
                UseInventoryItem(slotID)
                return true
            end
        end

        return false -- Item not found
    end

    -- 🎯 Cast regular spell
    local spellID = C_Spell.GetSpellIDForSpellIdentifier(spell)
    if not spellID then return false end

    local info = C_Spell.GetSpellCooldown(spellID)
    if info and info.isEnabled and info.duration > 0 then
        local expires = info.startTime + info.duration - GetTime()
        if expires > 0 then return false end
    end

    if not C_Spell.IsSpellUsable(spellID) then return false end

    -- ✅ Handle targeting
    if target == "cursor" then
        CastSpellByName(spell, "cursor")
    elseif target == "feet" then
        CastSpellByName(spell, "player")
    elseif target and UnitExists(target) then
        CastSpellByName(spell, target)
    else
        CastSpellByName(spell)
    end

    return true
end
