-- ✅ SpellCore Conditions System

-- 📦 Libraries
local RangeCheck = LibStub("LibRangeCheck-3.0")
local IsSpellInRange = C_Spell.IsSpellInRange
local GetSpellInfo = _G.GetSpellInfo or C_Spell.GetSpellInfo
local GetSpellCharges = _G.GetSpellCharges or C_ActionBar.GetSpellCharges or function() return nil end
SpellCore.SpellIDCache = SpellCore.SpellIDCache or {}

-- 🔧 Debug Toggle
SpellCore.Debug = true

-- 🧾 Utility Function
local function IsValidUnit(unit)
    return UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit)
end

-- 🎯 Condition Table Initialization
SpellCore.Conditions = {}

--------------------------------------------------
-- 🧪 Buffs & Debuffs
--------------------------------------------------
SpellCore.Conditions["buff.count"] = function(unit, buffName)
    if not UnitExists(unit) then return 0 end
    local aura = C_UnitAuras.GetAuraDataBySpellName(unit, buffName)
    return aura and (aura.applications or 0) or 0
end

SpellCore.Conditions["hasBuff"] = function(unit, buffName)
    local result = IsValidUnit(unit) and C_UnitAuras.GetAuraDataBySpellName(unit, buffName) ~= nil
    return result
end

SpellCore.Conditions["hasDebuff"] = function(unit, debuffName)
    return IsValidUnit(unit) and C_UnitAuras.GetAuraDataBySpellName(unit, debuffName, "HARMFUL") ~= nil
end

SpellCore.Conditions["buffDuration"] = function(unit, spell)
    if not UnitExists(unit) then return 0 end
    local name = (type(spell) == "number") and (C_Spell.GetSpellInfo(spell) or {}).name or spell
    local aura = C_UnitAuras.GetAuraDataBySpellName(unit, name)
    return aura and aura.expirationTime and math.max(0, aura.expirationTime - GetTime()) or 0
end

SpellCore.Conditions["debuffDuration"] = function(unit, spell)
    if not UnitExists(unit) then return 0 end
    local name = (type(spell) == "number") and (C_Spell.GetSpellInfo(spell) or {}).name or spell
    local aura = C_UnitAuras.GetAuraDataBySpellName(unit, name, "HARMFUL")
    return aura and aura.expirationTime and math.max(0, aura.expirationTime - GetTime()) or 0
end

SpellCore.Conditions["buffUpTime"] = function(unit, buffName, duration)
    local aura = C_UnitAuras.GetAuraDataBySpellName(unit, buffName)
    if aura and aura.applicationTime then
        return (GetTime() - aura.applicationTime) >= tonumber(duration)
    end
    return false
end

SpellCore.Conditions["canDispel"] = function(unit)
if not UnitExists(unit) or not UnitInRange(unit) then return false end   
	for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if aura and aura.isDispellable then
            return true
        end
    end
    return false
end

SpellCore.Conditions["canDispelMagic"] = function(unit)
if not UnitExists(unit) or not UnitInRange(unit) then return false end
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if aura and aura.dispelName == "Magic" then
            return true
        end
    end
    return false
end

SpellCore.Conditions["canDispelDisease"] = function(unit)
if not UnitExists(unit) or not UnitInRange(unit) then return false end
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if aura and aura.dispelName == "Disease" then
            return true
        end
    end
    return false
end

SpellCore.Conditions["canDispelPoison"] = function(unit)
if not UnitExists(unit) or not UnitInRange(unit) then return false end
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if aura and aura.dispelName == "Poison" then
            return true
        end
    end
    return false
end

SpellCore.Conditions["canDispelCurse"] = function(unit)
if not UnitExists(unit) or not UnitInRange(unit) then return false end
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if aura and aura.dispelName == "Curse" then
            return true
        end
    end
    return false
end

--------------------------------------------------
-- 🔍 Unit State
--------------------------------------------------
SpellCore.Conditions["isEnemy"] = function(unit)
    return UnitExists(unit) and UnitCanAttack("player", unit) and not UnitIsDeadOrGhost(unit)
end

SpellCore.Conditions["isFriend"] = function(unit)
    return UnitExists(unit) and UnitIsFriend("player", unit) and not UnitIsDeadOrGhost(unit)
end

SpellCore.Conditions["isAttackable"] = function(unit)
    return UnitExists(unit) and UnitCanAttack("player", unit) and not UnitIsDeadOrGhost(unit)
end

SpellCore.Conditions["hasTarget"] = function(unit)
    return UnitExists(unit) and UnitExists(unit .. "target")
end

SpellCore.Conditions["unitInCombat"] = function(unit)
    return UnitAffectingCombat(unit)
end

SpellCore.Conditions["isCasting"] = function(unit)
    return UnitCastingInfo(unit) ~= nil
end

--------------------------------------------------
-- ⏱️ Cooldowns & Items
--------------------------------------------------
SpellCore.Conditions["cooldown"] = function(spell)
    local info = C_Spell.GetSpellCooldown(spell)
    if not info or not info.isEnabled or info.duration == 0 then return 0 end
    local expires = info.startTime + info.duration - GetTime()
    return (expires > 0) and expires or 0
end

SpellCore.Conditions["useItem"] = function(itemID)
    local usable, noMana = IsUsableItem(itemID)
    local start, duration, enabled = GetItemCooldown(itemID)
    return usable and enabled == 1 and (start + duration - GetTime()) <= 0
end

SpellCore.Conditions["useEquippedItem"] = function(itemID)
    local slots = {
        INVSLOT_TRINKET1, INVSLOT_TRINKET2,
        INVSLOT_FINGER1, INVSLOT_FINGER2,
        INVSLOT_MAINHAND, INVSLOT_OFFHAND,
        INVSLOT_NECK
    }
    for _, slotID in ipairs(slots) do
        local equippedItemID = GetInventoryItemID("player", slotID)
        if equippedItemID == itemID then
            local start, duration, enabled = GetItemCooldown(itemID)
            local usable = IsUsableItem(itemID)
            if usable and enabled == 1 and (start + duration - GetTime()) <= 0 then
                UseInventoryItem(slotID)
                return true
            end
        end
    end
    return false
end

SpellCore.Conditions["itemCooldown"] = function(itemID)
    local start, duration = GetItemCooldown(tonumber(itemID))
    return math.max(0, start + duration - GetTime())
end

--------------------------------------------------
-- 📏 Range & Enemy Count
--------------------------------------------------
SpellCore.Conditions["range"] = function(unit)
    if not IsValidUnit(unit) then return 0 end

    local min, max = RangeCheck:GetRange(unit)

    if not max or max >= 46 then
        local spell = getHealingRangeSpell()
        if IsSpellInRange(spell, unit) == 1 then
            if SpellCore.Debug then
                
            end
            return 40
        else
            return 99
        end
    end

    return max
end

SpellCore.Conditions["isInRange"] = function(unit, maxYards)
    if not UnitExists(unit) then return false end

    local _, range = LibStub("LibRangeCheck-3.0"):GetRange(unit)
    if not range then return false end

    return range <= tonumber(maxYards)
end


SpellCore.Conditions["isFriendlyInRange"] = function(unit)
    return UnitInRange(unit) == true
end

SpellCore.Conditions["canCastSpell"] = function(spell, unit)
    if not UnitExists(unit) then return false end
    local ok, result = pcall(C_Spell.IsSpellInRange, spell, unit)
    if not ok or result == nil then
        if SpellCore.Debug then
            print("⚠️ [SpellCore] Skipping range check (invalid):", spell, unit)
        end
        return true -- 🔁 Laisse passer si check invalide
    end
    return result == true
end

SpellCore.Conditions["enemyCount"] = function(maxRange)
    local count = 0
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) and UnitCanAttack("player", unit) then
            local _, range = RangeCheck:GetRange(unit)
            if range and range <= tonumber(maxRange or 8) then
                count = count + 1
            end
        end
    end
    return count
end

SpellCore.Conditions["hasNearbyEnemies"] = function(range, minCount)
    local found = 0
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) and UnitCanAttack("player", unit) then
            local _, r = RangeCheck:GetRange(unit)
            if r and r <= tonumber(range or 8) then
                found = found + 1
                if found >= tonumber(minCount) then
                    return true
                end
            end
        end
    end
    return false
end

--------------------------------------------------
-- 🧠 Role & Health
--------------------------------------------------
SpellCore.Conditions["isTank"] = function(unit)
    return UnitGroupRolesAssigned(unit) == "TANK"
end

SpellCore.Conditions["isHealer"] = function(unit)
    return UnitGroupRolesAssigned(unit) == "HEALER"
end

SpellCore.Conditions["isDPS"] = function(unit)
    return UnitGroupRolesAssigned(unit) == "DAMAGER"
end

SpellCore.Conditions["hasAggro"] = function(unit)
    local threat = UnitThreatSituation(unit)
    return (threat or 0) >= 2
end

SpellCore.Conditions["healthPercent"] = function(unit)
    if not UnitExists(unit) then return 0 end
    return (UnitHealth(unit) / UnitHealthMax(unit)) * 100
end

SpellCore.Conditions["alliesBelowHP"] = function(threshold, count)
    local found = 0
    local groupType = IsInRaid() and "raid" or "party"
    local max = IsInRaid() and 40 or 4

    for i = 1, max do
        local unit = groupType .. i
        if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
            local hp = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
            if hp <= threshold then
                found = found + 1
                if found >= count then return true end
            end
        end
    end

    return false
end

--------------------------------------------------
-- 👀 Enemy Casting Checks
--------------------------------------------------

SpellCore.Conditions["castInterruptible"] = function(unit)
    local name, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
    if not name then return false end
    return not notInterruptible
end



SpellCore.Conditions["enemyCasting"] = function(spellName)
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitCastingInfo(unit) == spellName then
            return true
        end
    end
    return false
end

--------------------------------------------------
-- 🧼 Group Debuffs
--------------------------------------------------
SpellCore.Conditions["groupHasDebuff"] = function(debuffName, count)
    local groupType = IsInRaid() and "raid" or "party"
    local max = IsInRaid() and 40 or 4
    local hits = 0
    for i = 1, max do
        local unit = groupType .. i
        if UnitExists(unit) and C_UnitAuras.GetAuraDataBySpellName(unit, debuffName, "HARMFUL") then
            hits = hits + 1
            if hits >= tonumber(count) then
                return true
            end
        end
    end
    return false
end

--------------------------------------------------
-- 🧠 CC Conditions
--------------------------------------------------
local ccTypes = {
    STUN = true, FEAR = true, SILENCE = true, CHARM = true,
    CONFUSE = true, PACIFY = true, PACIFYSILENCE = true,
    POLYMORPH = true, HORROR = true, SLEEP = true, ROOT = true,
    INCAPACITATE = true, DISORIENTED = true, BIND = true,
    BANISH = true, CYCLONE = true
}

SpellCore.Conditions["isUnderCC"] = function(unit)
    local i = 1
    while true do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if not aura then break end
        if aura.dispelName and ccTypes[aura.dispelName] then
            return true
        end
        i = i + 1
    end
    return false
end

local knownCCs = {
    ["Polymorph"] = true, ["Fear"] = true, ["Psychic Scream"] = true,
    ["Hex"] = true, ["Cyclone"] = true, ["Freezing Trap"] = true,
    ["Repentance"] = true, ["Hammer of Justice"] = true, ["Blind"] = true, ["Sap"] = true
}

SpellCore.Conditions["hasControlDebuff"] = function(unit)
    local i = 1
    while true do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if not aura then break end
        if aura.name and knownCCs[aura.name] then
            return true
        end
        i = i + 1
    end
    return false
end

--------------------------------------------------
-- ⏳ Time to Die / Damage History
--------------------------------------------------
local lastDamageTime = 0

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function()
    local _, event, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if (event == "SWING_DAMAGE" or event == "SPELL_DAMAGE" or event == "RANGE_DAMAGE") and destGUID == UnitGUID("player") then
        lastDamageTime = GetTime()
    end
end)

SpellCore.Conditions["timeSinceLastDamage"] = function()
    return GetTime() - lastDamageTime
end

local ttdBuffer = {}

SpellCore.Conditions["timeToDie"] = function(unit)
    if not UnitExists(unit) or UnitIsDeadOrGhost(unit) then return 0 end
    local guid = UnitGUID(unit)
    local now = GetTime()
    local hp = UnitHealth(unit)
    ttdBuffer[guid] = ttdBuffer[guid] or {}
    table.insert(ttdBuffer[guid], { time = now, hp = hp })
    while #ttdBuffer[guid] > 0 and (now - ttdBuffer[guid][1].time > 3) do
        table.remove(ttdBuffer[guid], 1)
    end
    if #ttdBuffer[guid] < 2 then return 999 end
    local oldest = ttdBuffer[guid][1]
    local newest = ttdBuffer[guid][#ttdBuffer[guid]]
    local deltaHP = oldest.hp - newest.hp
    local deltaTime = newest.time - oldest.time
    if deltaHP <= 0 or deltaTime <= 0 then return 999 end
    return math.floor(newest.hp / (deltaHP / deltaTime))
end

--------------------------------------------------
-- 🧃 Power Resources
--------------------------------------------------
SpellCore.Conditions["power"] = function(unit, powerType)
    local powerMap = {
        MANA = Enum.PowerType.Mana, RAGE = Enum.PowerType.Rage,
        FOCUS = Enum.PowerType.Focus, ENERGY = Enum.PowerType.Energy,
        RUNIC_POWER = Enum.PowerType.RunicPower, MAELSTROM = Enum.PowerType.Maelstrom,
        INSANITY = Enum.PowerType.Insanity, LUNAR_POWER = Enum.PowerType.LunarPower,
        FURY = Enum.PowerType.Fury, PAIN = Enum.PowerType.Pain
    }
    local powerID = powerMap[string.upper(powerType or "")]
    if not powerID or not UnitExists(unit) then return 0 end
    return UnitPower(unit, powerID)
end

SpellCore.Conditions["comboPoints"] = function(unit) return UnitPower(unit, Enum.PowerType.ComboPoints) or 0 end
SpellCore.Conditions["holyPower"] = function(unit) return UnitPower(unit, Enum.PowerType.HolyPower) or 0 end
SpellCore.Conditions["chi"] = function(unit) return UnitPower(unit, Enum.PowerType.Chi) or 0 end
SpellCore.Conditions["arcaneCharges"] = function(unit) return UnitPower(unit, Enum.PowerType.ArcaneCharges) or 0 end
SpellCore.Conditions["soulShards"] = function(unit) return UnitPower(unit, Enum.PowerType.SoulShards) or 0 end
SpellCore.Conditions["essence"] = function(unit) return UnitPower(unit, Enum.PowerType.Essence) or 0 end
SpellCore.Conditions["runesAvailable"] = function()
    local count = 0
    for i = 1, 6 do
        local _, _, ready = GetRuneCooldown(i)
        if ready then count = count + 1 end
    end
    return count
end

--------------------------------------------------
-- 🧠 Toggles & Modifiers
--------------------------------------------------
SpellCore.Conditions["toggle.rotation"] = function() return autoCastingSpellCore == true end
SpellCore.Conditions["toggle.aoe"] = function() return SpellCore.Toggle.aoe == true end
SpellCore.Conditions["toggle.major"] = function() return SpellCore.Toggle.major == true end
SpellCore.Conditions["toggle.minor"] = function() return SpellCore.Toggle.minor == true end
SpellCore.Conditions["toggle.def"] = function() return SpellCore.Toggle.def == true end
SpellCore.Conditions["toggle.kick"] = function() return SpellCore.Toggle.kick == true end
SpellCore.Conditions["toggle.ground"] = function() return SpellCore.Toggle.ground == true end
SpellCore.Conditions["toggle.mov"] = function() return SpellCore.Toggle.mov == true end
SpellCore.Conditions["modifier.ctrl"] = function() return IsControlKeyDown() end

--------------------------------------------------
-- 🔁 Last Spell Cast
--------------------------------------------------
SpellCore.LastCast = { id = nil, name = nil }

local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:SetScript("OnEvent", function(_, event, unitTarget, castGUID, spellID)
    if unitTarget == "player" and spellID then
        SpellCore.LastCast.id = spellID
        SpellCore.LastCast.name = _G.GetSpellInfo and _G.GetSpellInfo(spellID) or "Unknown"
        if SpellCore.Debug then
            
        end
    end
end)

SpellCore.Conditions["lastSpellID"] = function(spellID)
    return SpellCore.LastCast.id == tonumber(spellID)
end

SpellCore.Conditions["lastSpell"] = function(spellName)
    return SpellCore.LastCast.name == spellName
end

SpellCore.Conditions["hasBuffFixed"] = function(unit, buffName)
    if buffName == "Hot Streak" then buffName = "Hot Streak!" end
    return C_UnitAuras.GetAuraDataBySpellName(unit, buffName) ~= nil
end

SpellCore.Conditions["myRenewCount"] = function()
    local total = 0

    local function check(unit)
        if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
            local aura = C_UnitAuras.GetAuraDataBySpellName(unit, "Renew")
            if aura and aura.sourceUnit == "player" then
                total = total + 1
            end
        end
    end

    check("player")  -- ✅ Inclure soi-même

    local groupType = IsInRaid() and "raid" or "party"
    local max = IsInRaid() and 40 or 4
    for i = 1, max do check(groupType .. i) end

    return total
end

SpellCore.Conditions["myAtonementCount"] = function()
    local total = 0

    local function check(unit)
        if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
            local aura = C_UnitAuras.GetAuraDataBySpellName(unit, "Atonement")
            if aura and aura.sourceUnit == "player" then
                total = total + 1
            end
        end
    end

    check("player")  -- ✅ Inclure soi-même

    local groupType = IsInRaid() and "raid" or "party"
    local max = IsInRaid() and 40 or 4
    for i = 1, max do check(groupType .. i) end

    return total
end

SpellCore.Conditions["lowestMissingBuff"] = function(buffName)
    local groupType = IsInRaid() and "raid" or "party"
    local max = IsInRaid() and 40 or 4
    local lowestHP = 100
    local lowestUnit = nil

    for i = 1, max do
        local unit = groupType .. i
        if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
            local hp = UnitHealth(unit) / UnitHealthMax(unit) * 100
            local range = SpellCore.Conditions["range"](unit)
            if hp < lowestHP and range and range <= 40 then
                lowestHP = hp
                lowestUnit = unit
            end
        end
    end

    if not lowestUnit then return false end

    local aura = C_UnitAuras.GetAuraDataBySpellName(lowestUnit, buffName)
    return not (aura and aura.sourceUnit == "player")
end

SpellCore.Conditions["itemCooldownByName"] = function(itemName)
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemID = tonumber(itemLink:match("item:(%d+)"))
                if itemID then
                    local name = GetItemInfo(itemID)
                    if name == itemName then
                        
                        local start, duration, enable = C_Container.GetContainerItemCooldown(bag, slot)
                        local cd = start + duration - GetTime()
                        
                        if enable == 1 then
                            return math.max(0, cd)
                        end
                    end
                end
            end
        end
    end
    
    return 999
end

SLASH_CHECKENV1 = "/checkenv"
SlashCmdList.CHECKENV = function()
    SpellCore.CurrentEnv = SpellCore.ConditionEnv:Init()
    local env = SpellCore.CurrentEnv
    if not env then
        print("❌ SpellCore environment not initialized.")
        return
    end

    print("📊 [SpellCore Environment Units]")

    local function printUnitStatus(name, data)
        local unitID = data.unit or name
        local displayName = UnitExists(unitID) and UnitName(unitID) or "Unknown"

        if data and data.hp then
            print(string.format("✅ %s: %s (HP: %d%%)", name, displayName, math.floor(data.hp)))
        elseif data and data.hpMax then
            print(string.format("✅ %s: %s (HP Max: %d)", name, displayName, data.hpMax))
        else
            print(string.format("❌ %s: Non défini", name))
        end
    end

    for key, value in pairs(env) do
        if type(value) == "table" and (value.hp or value.hpMax) then
            printUnitStatus(key, value)
        end
    end
end

SpellCore.Conditions["enemyCastingSpell"] = function(spellName)
    local units = {"boss1", "boss2", "boss3", "boss4", "boss5", "target", "focus"}

    -- Ajouter jusqu’à 40 nameplates
    for i = 1, 40 do
        table.insert(units, "nameplate" .. i)
    end

    for _, unit in ipairs(units) do
        if UnitExists(unit) then
            local name = UnitCastingInfo(unit)
            if name and name == spellName then
                return true
            end
        end
    end

    return false
end

SpellCore.Conditions["unitExists"] = function(unit)
    return UnitExists(unit)
end

SpellCore.Conditions["charges"] = function(spellID)
    if not spellID then return 0 end

    -- Conversion sécurisée si on reçoit un string numérique
    if type(spellID) == "string" then
        spellID = tonumber(spellID)
    end

    if type(spellID) ~= "number" then
        if SpellCore.Debug then
            print("❌ [SpellCore] charges(): expected spellID number, got:", tostring(spellID))
        end
        return 0
    end

    local charges = GetSpellCharges(spellID)
    return charges or 0
end

SpellCore.Conditions["isIndoor"] = function()
    return IsIndoors() == true
end

local BigWigsTimers = {}

local function AddBigWigsBar(event, addon, spellId, duration, _, text, count, icon, isCooldown, isBarEnabled)
    if type(duration) ~= "number" or not text then return end

    local now = GetTime()
    BigWigsTimers[text] = {
        expiration = now + duration,
        duration = duration,
        text = text,
        count = count or 0,
        icon = icon,
        isCooldown = isCooldown,
        isBarEnabled = isBarEnabled,
        addedAt = now,
    }

    if SpellCore.Debug then
        print(string.format("✅ Added bar: %s, expires in %.1f sec", text, duration))
    end
end

-- Register events
if BigWigsLoader and not BigWigsTimers._registered then
    BigWigsTimers._registered = true

    BigWigsLoader.RegisterMessage(SpellCore, "BigWigs_Timer", function(_, addon, spellId, duration, _, text, count, icon, isCooldown, isBarEnabled)
        AddBigWigsBar("BigWigs_Timer", addon, spellId, duration, nil, text, count, icon, isCooldown, isBarEnabled)
    end)

    BigWigsLoader.RegisterMessage(SpellCore, "BigWigs_CastTimer", function(_, addon, spellId, duration, _, text, count, icon, _, isBarEnabled)
        AddBigWigsBar("BigWigs_CastTimer", addon, spellId, duration, nil, text, count, icon, false, isBarEnabled)
    end)

    BigWigsLoader.RegisterMessage(SpellCore, "BigWigs_StartPull", function(_, module, duration)
        AddBigWigsBar("BigWigs_StartPull", "BigWigs", 0, duration, nil, "Pull", 0, 136116, false, true)
    end)
end

-- ✅ Condition with auto-expiry
SpellCore.Conditions["bigwigsTimerLE"] = function(label, seconds)
    local now = GetTime()

    -- Clean expired bars
    for key, bar in pairs(BigWigsTimers) do
        if type(bar) == "table" then -- ✅ Ne traiter que les vrais barres
            if bar.expiration and now > bar.expiration then
                BigWigsTimers[key] = nil
                if SpellCore.Debug then
                    print("🧹 Removed expired bar:", key)
                end
            end
        end
    end

    -- Check remaining time for the label
    local bar = BigWigsTimers[label]
    if type(bar) == "table" and bar.expiration then
        local remaining = bar.expiration - now
        if SpellCore.Debug then
            print(string.format("⏳ Found bar: %s - Remaining: %.2f seconds", label, remaining))
        end
        return remaining <= tonumber(seconds)
    end

    return false
end

SpellCore.Conditions["modifier.shift"] = function()
    return IsShiftKeyDown()
end

SpellCore.Conditions["modifier.alt"] = function()
    return IsAltKeyDown()
end

SpellCore.Conditions["modifier.ctrl"] = function()
    return IsControlKeyDown()
end

SpellCore.Conditions["castRemaining"] = function(unit)
    if not UnitExists(unit) then return 0 end

    local name, _, _, startTimeMS, endTimeMS = UnitCastingInfo(unit)
    if not name then return 0 end

    local now = GetTime() * 1000
    local remaining = endTimeMS - now
    return math.max(0, remaining / 1000) -- retourne en secondes
end

SpellCore.Conditions["targetCastingSpell"] = function(spellName)
    local name = UnitCastingInfo("target")
    return name and name == spellName
end

SpellCore.Conditions["focusCastingSpell"] = function(spellName)
    local name = UnitCastingInfo("focus")
    return name and name == spellName
end

SpellCore.Conditions["mouseoverCastingSpell"] = function(spellName)
    local name = UnitCastingInfo("mouseover")
    return name and name == spellName
end

SpellCore.Conditions["shouldInterrupt"] = function(unit, spellName, maxTime)
    if not UnitExists(unit) then return false end

    local name, _, _, startTime, endTime, _, _, _, notInterruptible = UnitCastingInfo(unit)
    if not name or name ~= spellName then return false end
    if notInterruptible then return false end

    if not startTime or not endTime then return false end

    local remaining = (endTime - GetTime() * 1000) / 1000
    return remaining <= (maxTime or 0.4)
end

function SpellCore:castEmpowered(spellName, delay)
    if not spellName or type(delay) ~= "number" then
        if SpellCore.Debug then
            print("⚠️ Invalid parameters to castEmpowered:", spellName, delay)
        end
        return
    end

    CastSpellByName(spellName)

    C_Timer.After(delay, function()
        if SpellCore.Debug then
            print(string.format("🛑 StopCasting() after %.2fs for spell: %s", delay, spellName))
        end
        StopCasting()
    end)
end



