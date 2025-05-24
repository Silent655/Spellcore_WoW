function SpellCore:Eval(expression)
    if type(expression) == "function" then
        return expression()
    end

    local env = SpellCore.CurrentEnv or SpellCore.ConditionEnv:Init()

    -- 🔐 Pattern escape pour noms complexes
    local function escapePattern(text)
        return text:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    end

    -- 🔁 Unit alias resolution
    local function resolveUnitAlias(unit)
        unit = unit:gsub("^['\"](.-)['\"]$", "%1")

        local dynamicUnits = {
            lowest = "lowest.unit", secondLowest = "secondLowest.unit",
            thirdLowest = "thirdLowest.unit", fourthLowest = "fourthLowest.unit",
            fifthLowest = "fifthLowest.unit", tank = "tank.unit",
            healer = "healer.unit", tankmate = "tankmate.unit",
            tankmateTwo = "tankmateTwo.unit", self = "player",
            pet = "pet", focusTarget = "focusTarget.unit",
            dispelTarget = "dispelTarget.unit",
        }

        local aliasPath = dynamicUnits[unit]
        if aliasPath then
            local parts = { strsplit(".", aliasPath) }
            local current = env
            for _, key in ipairs(parts) do
                current = current and current[key]
            end
            if current then return current end
        end

        return unit
    end

    local function evaluateSide(side)
        if string.sub(side, 1, 4) == "not " then
            local result = evaluateSide(string.sub(side, 5))
            return not result
        end

        if side:match("^alliesBelowHP%(") then
            local a, b = side:match("^alliesBelowHP%(([^,]+),%s*([^%)]+)%)")
            return SpellCore.Conditions["alliesBelowHP"](tonumber(a), tonumber(b))
        end

        local itemName = side:match("^useItemInBags%(['\"](.+)['\"]%)")
        if itemName then return SpellCore.Conditions["useItemInBags"](itemName) end

        itemName = side:match("^itemCooldownByName%(['\"](.+)['\"]%)")
        if itemName then return SpellCore.Conditions["itemCooldownByName"](itemName) end

        local funcName, arg1, arg2 = side:match("([%w_]+)%(['\"]?(.-)['\"]?%s*,%s*['\"]?(.-)['\"]?%)")
        if funcName and arg1 and arg2 then
            arg1 = resolveUnitAlias(arg1:gsub("^['\"](.-)['\"]$", "%1"))
            arg2 = arg2:gsub("^['\"](.-)['\"]$", "%1")
            return SpellCore.Conditions[funcName] and SpellCore.Conditions[funcName](arg1, tonumber(arg2) or arg2)
        end

        local funcSingle, arg = side:match("([%w_]+)%(['\"]?(.-)['\"]?%)")
        if funcSingle and arg then
            arg = resolveUnitAlias(arg:gsub("^['\"](.-)['\"]$", "%1"))
            return (env[funcSingle] and env[funcSingle](arg)) or (SpellCore.Conditions[funcSingle] and SpellCore.Conditions[funcSingle](arg))
        end

        local funcOp, baseName, arg1, arg2 = side:match("([%w_]+)%.?([%w_]+)%(['\"]?(.-)['\"]?%s*,%s*['\"]?(.-)['\"]?%)")
        if funcOp and baseName and arg1 and arg2 then
            arg1 = resolveUnitAlias(arg1)
            arg2 = tonumber(arg2) or arg2
            local conditionFunc = SpellCore.Conditions[funcOp]
            if conditionFunc then return conditionFunc(baseName, arg1, arg2) end
        end

        if SpellCore.Conditions[side] and type(SpellCore.Conditions[side]) == "function" then
            return SpellCore.Conditions[side]()
        end

        if side == "player.moving" then return GetUnitSpeed("player") > 0 end

        if side:match("buff.count") then
            local unit, buffName = side:match("buff.count%(['\"]?(.-)['\"]?%s*,%s*['\"]?(.-)['\"]?%)")
            return SpellCore.Conditions["buff.count"](resolveUnitAlias(unit), buffName)
        end

        if side:match("^range%(") then
            return SpellCore.Conditions["range"](resolveUnitAlias(side:match("^range%((.+)%)")))
        end

        local unit, attr = side:match("([%w_]+)%.(%w+)")
        if unit and attr and env[unit] and env[unit][attr] ~= nil then return env[unit][attr] end

        return tonumber(side)
    end

    local lhs, op, rhs = expression:match("^%s*(.-)%s*([<>=!]=?)%s*(.-)%s*$")
    if lhs and op and rhs then
        local left, right = evaluateSide(lhs), evaluateSide(rhs)
        if left == nil or right == nil then return false end
        if op == "<" then return left < right
        elseif op == "<=" then return left <= right
        elseif op == ">" then return left > right
        elseif op == ">=" then return left >= right
        elseif op == "==" then return left == right
        elseif op == "~=" then return left ~= right
        else return false end
    else
        return evaluateSide(expression) == true
    end
end
