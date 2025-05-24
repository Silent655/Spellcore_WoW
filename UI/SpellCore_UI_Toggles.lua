local function LoadToggleUI()
    if not SpellCore or not SpellCore.IsKeyValid or not SpellCore:IsKeyValid() then
        print("|cffff0000[SpellCore] Access to toggles denied. Valid key (lite or pro) required.|r")
        return
    end

    local Masque = LibStub("Masque", true)
    local MasqueGroup = Masque and Masque:Group("SpellCore", "Toggles")

    SpellCore.Toggle = SpellCore.Toggle or {
        auto = false, aoe = false, major = false, minor = false,
        def = false, kick = false, ground = false, mov = false,
    }

    SpellCoreDB = SpellCoreDB or {}
    SpellCoreDB.BarPosition = SpellCoreDB.BarPosition or { x = 0, y = -200 }

    SpellCoreSaved = SpellCoreSaved or {}
    SpellCoreSaved.ToggleStates = SpellCoreSaved.ToggleStates or {}

    local toggleBar = CreateFrame("Frame", "SpellCoreToggleBar", UIParent, "BackdropTemplate")
    toggleBar:SetSize(320, 45)
    toggleBar:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8x8",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
    })
    toggleBar:SetBackdropColor(0, 0, 0, 0.4)
    toggleBar:SetBackdropBorderColor(0, 0, 0, 0.8)
    toggleBar:SetPoint("CENTER", UIParent, "CENTER", SpellCoreDB.BarPosition.x, SpellCoreDB.BarPosition.y)

    local dragBg = CreateFrame("Frame", nil, toggleBar, "BackdropTemplate")
    dragBg:SetAllPoints()
    dragBg:SetFrameStrata("BACKGROUND")
    dragBg:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })
    dragBg:SetBackdropColor(0, 0, 0, 0)
    dragBg:EnableMouse(true)
    dragBg:SetMovable(true)
    dragBg:RegisterForDrag("LeftButton")

    dragBg:SetScript("OnDragStart", function()
        toggleBar:StartMoving()
    end)

    dragBg:SetScript("OnDragStop", function()
        toggleBar:StopMovingOrSizing()
        local barX, barY = toggleBar:GetCenter()
        local parentX, parentY = UIParent:GetCenter()
        if barX and barY and parentX and parentY then
            SpellCoreDB.BarPosition.x = math.floor(barX - parentX)
            SpellCoreDB.BarPosition.y = math.floor(barY - parentY)
        end
        toggleBar:ClearAllPoints()
        toggleBar:SetPoint("CENTER", UIParent, "CENTER", SpellCoreDB.BarPosition.x, SpellCoreDB.BarPosition.y)
    end)

    toggleBar:SetMovable(true)
    toggleBar:EnableMouse(false)
    toggleBar:Show()

    local rotationMenu = CreateFrame("Frame", "SpellCoreRotationMenu", UIParent, "UIDropDownMenuTemplate")
    local function InitializeRotationMenu(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(self, arg1)
            SpellCore:LoadRotationContext(arg1)
            SpellCoreSaved.RotationContext = arg1
        end
        local contexts = { "OPENWORLD", "MYTHICPLUS", "RAID", "PVP", "CUSTOM" }
        for _, context in ipairs(contexts) do
            info.text = context
            info.arg1 = context
            info.checked = (SpellCore.currentContext == context)
            UIDropDownMenu_AddButton(info, level)
        end
    end

    local function CreateToggleButton(name, iconTexture, key, labelText, onClick)
        local btn = CreateFrame("Button", name, toggleBar, "SecureActionButtonTemplate")
        btn:SetSize(40, 40)

        btn.icon = btn:CreateTexture(nil, "BACKGROUND")
        btn.icon:SetAllPoints()
        btn.icon:SetTexture(iconTexture)

        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.text:SetText(labelText)
        btn.text:SetTextColor(1, 1, 1, 1)

        if key ~= "auto" and SpellCoreSaved.ToggleStates[key] ~= nil then
            SpellCore.Toggle[key] = SpellCoreSaved.ToggleStates[key]
        end

        btn.icon:SetDesaturated(not SpellCore.Toggle[key])

        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetScript("OnClick", function(_, button)
            if button == "RightButton" and key == "auto" then
                UIDropDownMenu_Initialize(rotationMenu, InitializeRotationMenu, "MENU")
                ToggleDropDownMenu(1, nil, rotationMenu, btn, 0, 0)
            else
                SpellCore.Toggle[key] = not SpellCore.Toggle[key]
                btn.icon:SetDesaturated(not SpellCore.Toggle[key])

                if key ~= "auto" then
                    SpellCoreSaved.ToggleStates[key] = SpellCore.Toggle[key]
                end

                if onClick then onClick(SpellCore.Toggle[key]) end
            end
        end)

        if MasqueGroup then
            MasqueGroup:AddButton(btn)
        end

        return btn
    end

    local btns = {
        { "ROT", "Interface\\Icons\\inv_misc_punchcards_red", "auto", "ROTATION", function() SpellCore:ToggleAutoCast() end },
        { "AOE", "Interface\\Icons\\Spell_Fire_SelfDestruct", "aoe", "AOE" },
        { "MAJ", "Interface\\Icons\\spell_holy_borrowedtime", "major", "MAJOR" },
        { "MIN", "Interface\\Icons\\inv_misc_covenant_renown", "minor", "MINOR" },
        { "DEF", "Interface\\Icons\\inv_shield_32", "def", "DEF" },
        { "KIK", "Interface\\Icons\\ability_kick", "kick", "KICK" },
        { "GRD", "Interface\\Icons\\inv_misc_volatileearth", "ground", "GROUND" },
        { "MOV", "Interface\\Icons\\ability_rogue_sprint", "mov", "MOV" },
    }

    local last = nil
    for i, data in ipairs(btns) do
        local name = "SpellCoreBtn_" .. data[1]
        local btn = CreateToggleButton(name, data[2], data[3], data[4], data[5])
        if i == 1 then
            btn:SetPoint("LEFT", toggleBar, "LEFT", 0, 0)
        else
            btn:SetPoint("LEFT", last, "RIGHT", 0, 0)
        end
        last = btn
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    LoadToggleUI()
end)
