-- ✅ SpellCore Environment System

-- 📦 Libraries
local RangeCheck = LibStub("LibRangeCheck-3.0")
local IsSpellInRange = C_Spell.IsSpellInRange
local GetSpellInfo = _G.GetSpellInfo or C_Spell.GetSpellInfo

-- 🌐 SpellCore Condition Environment (Refactored and Commented)
SpellCore.ConditionEnv = {}

-- 🎯 Healing spell used for range fallback
local function getHealingRangeSpell()
    local _, class = UnitClass("player")
    local spells = {
        PRIEST  = "Flash Heal",
        PALADIN = "Holy Light",
        DRUID   = "Rejuvenation",
        MONK    = "Vivify",
        SHAMAN  = "Healing Surge"
    }
    return spells[class] or "Flash Heal"
end

-- 🧠 Builds a simulated unit structure
local function makeUnit(unit)
    return {
        hp         = UnitHealth(unit) / UnitHealthMax(unit) * 100,
        attackable = UnitCanAttack("player", unit),
        friendly   = UnitIsFriend("player", unit),
        inrange    = true,
        buff = setmetatable({}, {
            __index = function(_, spellName)
                local aura = C_UnitAuras.GetAuraDataBySpellName(unit, spellName)
                if aura then
                    return {
                        active = true,
                        duration = aura.expirationTime and (aura.expirationTime - GetTime()) or 0,
                        applications = aura.applications or 1,
                        applicationTime = aura.applicationTime or 0
                    }
                end
                return { active = false, duration = 0, applications = 0 }
            end
        }),
        debuff = setmetatable({}, {
            __index = function(_, spellName)
                local aura = C_UnitAuras.GetAuraDataBySpellName(unit, spellName, "HARMFUL")
                if aura then
                    return {
                        active = true,
                        duration = aura.expirationTime and (aura.expirationTime - GetTime()) or 0
                    }
                end
                return { active = false, duration = 0 }
            end
        })
    }
end

-- 🧾 Utility Function
local function IsValidUnit(unit)
    return UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit)
end

-- 🔄 Environment initializer
function SpellCore.ConditionEnv:Init()
    local env = {}

    local function assignUnit(name)
        env[name] = makeUnit(name)
        env[name].unit = name
    end

    -- 🧍 Core units
    assignUnit("player")
    env["self"] = env["player"]

    for _, unit in ipairs({ "target", "focus", "mouseover", "targettarget", "focustarget" }) do
        if UnitExists(unit) then assignUnit(unit) end
    end

    -- 🐾 Pet unit
    if UnitExists("pet") and UnitIsConnected("pet") and not UnitIsDeadOrGhost("pet") then
        assignUnit("pet")
    end

    -- 🧍 Party / Raid units
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
            assignUnit(unit)
        end
    end

    if IsInRaid() then
        for i = 1, 40 do
            local unit = "raid" .. i
            if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
                assignUnit(unit)
            end
        end
    end

    -- 🧩 Arena / Boss units
    for i = 1, 5 do
        for _, group in ipairs({ "arena", "boss" }) do
            local unit = group .. i
            if UnitExists(unit) then assignUnit(unit) end
        end
    end

    -- 🦶 Cursor targeting helpers
    env["target.cursor"] = function() return "cursor" end
    env["target.feet"]   = function() return "feet" end

    -- 🏃 Movement status
    env["player.moving"] = function()
        return GetUnitSpeed("player") > 0
    end

    -- ❤️ Lowest HP units
    local injuredUnits = {}
    local function checkUnit(unit)
        if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
            local hpMax = UnitHealthMax(unit)
            if hpMax > 0 then
                local hp = UnitHealth(unit) / hpMax * 100
                if unit == "player" or UnitInRange(unit) then
                    table.insert(injuredUnits, { unit = unit, hp = hp })
                end
            end
        end
    end

    checkUnit("player")
    if IsInRaid() then
        for i = 1, 40 do checkUnit("raid" .. i) end
    elseif IsInGroup() then
        for i = 1, 4 do checkUnit("party" .. i) end
    end

    table.sort(injuredUnits, function(a, b) return a.hp < b.hp end)

    env["lowest"]       = injuredUnits[1] and { hp = injuredUnits[1].hp, unit = injuredUnits[1].unit } or nil
    env["secondLowest"] = injuredUnits[2] and { hp = injuredUnits[2].hp, unit = injuredUnits[2].unit } or nil
    env["thirdLowest"]  = injuredUnits[3] and { hp = injuredUnits[3].hp, unit = injuredUnits[3].unit } or nil
    env["fourthLowest"] = injuredUnits[4] and { hp = injuredUnits[4].hp, unit = injuredUnits[4].unit } or nil
    env["fifthLowest"]  = injuredUnits[5] and { hp = injuredUnits[5].hp, unit = injuredUnits[5].unit } or nil

    -- 🛡️ Tankmate detection
    local tankCandidates = {}
    local function checkAsTankCandidate(unit)
        if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
            local hpMax = UnitHealthMax(unit)
            if hpMax > 0 and (unit == "player" or UnitInRange(unit)) then
                table.insert(tankCandidates, { unit = unit, hpMax = hpMax })
            end
        end
    end

    checkAsTankCandidate("player")
    if IsInRaid() then
        for i = 1, 40 do checkAsTankCandidate("raid" .. i) end
    elseif IsInGroup() then
        for i = 1, 4 do checkAsTankCandidate("party" .. i) end
    end

    table.sort(tankCandidates, function(a, b) return a.hpMax > b.hpMax end)
    env["tankmate"]     = tankCandidates[1] and { unit = tankCandidates[1].unit, hpMax = tankCandidates[1].hpMax } or nil
    env["tankmateTwo"]  = tankCandidates[2] and { unit = tankCandidates[2].unit, hpMax = tankCandidates[2].hpMax } or nil

    return env
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