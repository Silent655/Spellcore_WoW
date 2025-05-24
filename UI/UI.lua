-- Create the main frame using Blizzard visual style
local SpellCoreUI = CreateFrame("Frame", "SpellCoreUI", UIParent, "ButtonFrameTemplate")
SpellCoreUI:SetSize(1000, 500) -- ⬅️ largeur augmentée ici
SetPortraitTexture(SpellCoreUIPortrait, "player")
SpellCoreUIPortrait:SetAlpha(1)
SpellCoreUIPortrait:SetTexCoord(0, 1, 0, 1)
C_Timer.After(0.1, function()
    SetPortraitTexture(SpellCoreUIPortrait, "player")
end)
SpellCoreUI:SetPoint("CENTER")
SpellCoreUI:EnableMouse(true)
SpellCoreUI:SetMovable(true)
SpellCoreUI:RegisterForDrag("LeftButton")
SpellCoreUI:SetScript("OnDragStart", SpellCoreUI.StartMoving)
SpellCoreUI:SetScript("OnDragStop", SpellCoreUI.StopMovingOrSizing)
SpellCoreUI:Hide()

-- Title (manually added)
local title = SpellCoreUI:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -6)
title:SetText("SpellCore Configuration")

-- Frame inset adjustment (marge intérieure)
SpellCoreUI.Inset:ClearAllPoints()
SpellCoreUI.Inset:SetPoint("TOPLEFT", 6, -60)
SpellCoreUI.Inset:SetPoint("BOTTOMRIGHT", -10, 26)

-- Tabs logic
local tabs, tabFrames, currentTab = {}, {}, nil

local function SwitchTab(index)
    for i, frame in pairs(tabFrames) do
        frame:Hide()
        PanelTemplates_DeselectTab(tabs[i])
    end
    PanelTemplates_SelectTab(tabs[index])
    tabFrames[index]:Show()
    currentTab = index
end

local function CreateTab(index, text)
    local tab = CreateFrame("Button", "SpellCoreTab"..index, SpellCoreUI, "PanelTabButtonTemplate")
    tab:SetID(index)
    tab:SetText(text)
    tab:SetScript("OnClick", function() SwitchTab(index) end)
    tabs[index] = tab
    return tab
end

local function CreateTabFrame(index)
    local frame = CreateFrame("Frame", nil, SpellCoreUI.Inset)
    frame:SetAllPoints()
    frame:Hide()
    tabFrames[index] = frame
    return frame
end

-- Create tabs
local generalTab = CreateTab(1, "General")
generalTab:SetPoint("TOPLEFT", SpellCoreUI, "BOTTOMLEFT", 15, 3)

local rotationsTab = CreateTab(2, "Rotations")
rotationsTab:SetPoint("LEFT", generalTab, "RIGHT", -15, 0)

local conditionsTab = CreateTab(3, "Conditions")
conditionsTab:SetPoint("LEFT", rotationsTab, "RIGHT", -15, 0)

local togglesTab = CreateTab(4, "Toggles")
togglesTab:SetPoint("LEFT", conditionsTab, "RIGHT", -15, 0)

PanelTemplates_SetNumTabs(SpellCoreUI, 4)
for i = 1, 4 do
    PanelTemplates_EnableTab(SpellCoreUI, i)
end

-- Create tab content frames
local generalFrame = CreateTabFrame(1)
local rotationsFrame = CreateTabFrame(2)
local conditionsFrame = CreateTabFrame(3)
local togglesFrame = CreateTabFrame(4)

-- Sample content
local function AddLabel(frame, text)
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 10, -10)
    label:SetText(text)
end

-- Label "License Key"
local keyLabel = generalFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
keyLabel:SetPoint("TOPLEFT", 20, -20)
keyLabel:SetText("License Key:")

-- Input box
local keyInput = CreateFrame("EditBox", "SpellCoreUIKeyInput", generalFrame, "InputBoxTemplate")
keyInput:SetSize(250, 20)
keyInput:SetPoint("TOPLEFT", keyLabel, "TOPLEFT", 100, 0)
keyInput:SetAutoFocus(false)
keyInput:SetScript("OnEnterPressed", function(self)
    SpellCoreProductKey = self:GetText()
    if SpellCore:IsKeyValid() then
        print("|cff00ff00[SpellCore] Key saved successfully.|r")
    else
        print("|cffff0000[SpellCore] Invalid key.|r")
    end
    self:ClearFocus()
end)
keyInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
keyInput:SetScript("OnShow", function(self)
    self:SetText(SpellCoreProductKey or "")
end)

-- Button "Validate"
local keyButton = CreateFrame("Button", nil, generalFrame, "UIPanelButtonTemplate")
keyButton:SetSize(100, 22)
keyButton:SetPoint("LEFT", keyInput, "RIGHT", 10, 0)
keyButton:SetText("Validate")
keyButton:SetScript("OnClick", function()
    SpellCoreProductKey = keyInput:GetText()
    if SpellCore:IsKeyValid() then
        print("|cff00ff00[SpellCore] Key saved successfully.|r")
    else
        print("|cffff0000[SpellCore] Invalid key.|r")
    end
end)

-- Status label
local statusLabel = generalFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statusLabel:SetPoint("TOPLEFT", keyLabel, "BOTTOMLEFT", 0, -20)
statusLabel:SetText("Status:")

local statusText = generalFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
statusText:SetPoint("TOPLEFT", statusLabel, "TOPLEFT", 100, 0)
statusText:SetText("Inactive")

-- Update status on show
generalFrame:SetScript("OnShow", function()
    keyInput:SetText(SpellCoreProductKey or "")
    if SpellCore._validated then
        statusText:SetText("|cff00ff00Active (" .. (SpellCore.KeyType or "unknown") .. ")|r")
    else
        statusText:SetText("|cffff0000Inactive|r")
    end
end)

-- Auto-Cast option
local autoCastLabel = generalFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
autoCastLabel:SetPoint("TOPLEFT", statusLabel, "BOTTOMLEFT", 0, -20)
autoCastLabel:SetText("Auto-Cast:")

local autoCastCheckbox = CreateFrame("CheckButton", nil, generalFrame, "UICheckButtonTemplate")
autoCastCheckbox:SetSize(24, 24)
autoCastCheckbox:SetPoint("TOPLEFT", autoCastLabel, "TOPLEFT", 100, 0)
autoCastCheckbox:SetScript("OnClick", function(self)
    if SpellCore.KeyType ~= "pro" and self:GetChecked() then
        print("|cffff0000[SpellCore] Auto-cast is only available with a Pro key.|r")
        self:SetChecked(false)
        return
    end
    SpellCore:ToggleAutoCast()
    self:SetChecked(autoCastingSpellCore)
end)
autoCastCheckbox:SetScript("OnShow", function(self)
    self:SetChecked(autoCastingSpellCore or false)
end)
-- Context dropdown
local contextLabel = rotationsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
contextLabel:SetPoint("TOPLEFT", 20, -20)
contextLabel:SetText("Context:")

local dropDown = CreateFrame("Frame", "SpellCoreUIContextDropDown", rotationsFrame, "UIDropDownMenuTemplate")
dropDown:SetPoint("TOPLEFT", contextLabel, "TOPLEFT", 100, 5)
UIDropDownMenu_SetWidth(dropDown, 200)
UIDropDownMenu_JustifyText(dropDown, "LEFT")

local contexts = {"MYTHICPLUS", "RAID", "PVP", "OPENWORLD"}

UIDropDownMenu_Initialize(dropDown, function(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for _, context in ipairs(contexts) do
        info.text = context
        info.func = function(self)
            UIDropDownMenu_SetSelectedValue(dropDown, self.value)
            SpellCore:LoadRotationContext(self.value)
        end
        info.value = context
        info.checked = (SpellCore.currentContext == context)
        UIDropDownMenu_AddButton(info, level)
    end
end)

rotationsFrame:SetScript("OnShow", function()
    UIDropDownMenu_SetSelectedValue(dropDown, SpellCore.currentContext or "OPENWORLD")
    UIDropDownMenu_SetText(dropDown, SpellCore.currentContext or "OPENWORLD")
end)

-- Scrollable list for spells (with BackdropTemplate fix)
local spellListFrame = CreateFrame("Frame", nil, rotationsFrame, "BackdropTemplate")
spellListFrame:SetPoint("TOPLEFT", contextLabel, "BOTTOMLEFT", 0, -20)
spellListFrame:SetPoint("BOTTOMRIGHT", -20, 40)
spellListFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local scrollFrame = CreateFrame("ScrollFrame", "SpellCoreUIRotationScrollFrame", spellListFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 8, -8)
scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

local scrollChild = CreateFrame("Frame", "SpellCoreUIRotationScrollChild", scrollFrame)
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetSize(scrollFrame:GetWidth(), 500)

-- Function to update the spell list
local function UpdateRotationList()
    for _, child in pairs({scrollChild:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local rotation = (UnitAffectingCombat("player") and SpellCore.CombatRotation) or SpellCore.OOC_Rotation
    if not rotation then return end

    local prev
    for i, entry in ipairs(rotation) do
        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetSize(scrollChild:GetWidth() - 20, 24)

        if i == 1 then
            row:SetPoint("TOPLEFT", 10, -10)
        else
            row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -5)
        end

        local spellText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        spellText:SetPoint("LEFT", 5, 0)

        local spellName = entry[1]
        if tonumber(spellName) then
            local name = GetSpellInfo(tonumber(spellName))
            spellText:SetText(i .. ". " .. (name or spellName) .. " [ID: " .. spellName .. "]")
        else
            spellText:SetText(i .. ". " .. spellName)
        end

        prev = row
    end

    if prev then
        scrollChild:SetHeight(prev:GetBottom() * -1 + 20)
    end
end

-- Refresh list on show
rotationsFrame:SetScript("OnShow", function()
    UIDropDownMenu_SetSelectedValue(dropDown, SpellCore.currentContext or "OPENWORLD")
    UIDropDownMenu_SetText(dropDown, SpellCore.currentContext or "OPENWORLD")
    UpdateRotationList()
end)

-- Scrollable frame for conditions (with backdrop)
local conditionsListFrame = CreateFrame("Frame", nil, conditionsFrame, "BackdropTemplate")
conditionsListFrame:SetPoint("TOPLEFT", 20, -20)
conditionsListFrame:SetPoint("BOTTOMRIGHT", -20, 40)
conditionsListFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local conditionsScrollFrame = CreateFrame("ScrollFrame", "SpellCoreUIConditionsScrollFrame", conditionsListFrame, "UIPanelScrollFrameTemplate")
conditionsScrollFrame:SetPoint("TOPLEFT", 8, -8)
conditionsScrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

local conditionsScrollChild = CreateFrame("Frame", "SpellCoreUIConditionsScrollChild", conditionsScrollFrame)
conditionsScrollFrame:SetScrollChild(conditionsScrollChild)
conditionsScrollChild:SetSize(conditionsScrollFrame:GetWidth(), 1000)

-- Function to update condition list
local function UpdateConditionsList()
    for _, child in pairs({conditionsScrollChild:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    if not SpellCore or not SpellCore.Conditions then return end

    local sortedKeys = {}
    for key in pairs(SpellCore.Conditions) do
        table.insert(sortedKeys, key)
    end
    table.sort(sortedKeys)

    local prev
    for i, key in ipairs(sortedKeys) do
        local row = CreateFrame("Frame", nil, conditionsScrollChild)
        row:SetSize(conditionsScrollChild:GetWidth() - 20, 20)

        if i == 1 then
            row:SetPoint("TOPLEFT", 10, -10)
        else
            row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -5)
        end

        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", 5, 0)
        text:SetText(key)

        prev = row
    end

    if prev then
        conditionsScrollChild:SetHeight(prev:GetBottom() * -1 + 20)
    end
end

-- Refresh list on show
conditionsFrame:SetScript("OnShow", function()
    UpdateConditionsList()
end)

AddLabel(togglesFrame, "Contenu Toggles")

-- Onglet Rotation Builder (UI 2.0)
local builderTab = CreateTab(5, "Rotation Builder")
builderTab:SetPoint("LEFT", togglesTab, "RIGHT", -15, 0)
PanelTemplates_SetNumTabs(SpellCoreUI, 5)
PanelTemplates_EnableTab(SpellCoreUI, 5)
local builderFrame = CreateTabFrame(5)

-- Données des spells (prêtre uniquement ici)
local priestSpells = {
    [17] = "Power Word: Shield", [33076] = "Prayer of Mending", [194509] = "Power Word: Radiance",
    [47540] = "Penance", [2061] = "Flash Heal", [585] = "Smite",
    [34433] = "Shadowfiend", [246287] = "Evangelism", [10060] = "Power Infusion",
    [62618] = "Power Word: Barrier", [33206] = "Pain Suppression",
}

-- Cibles standards
local availableTargets = { "target", "focus", "lowest", "tank", "mouseover", "player", "party1", "party2" }

-- Conditions avec paramètres
local conditionArguments = {
    hasBuff = {"unit", "buff"}, buffDuration = {"unit", "buff"}, cooldown = {"spell"},
    healthPercent = {"unit"}, hasAggro = {"unit"}, unitExists = {"unit"},
    isAttackable = {"unit"}, itemCooldownByName = {"item"}, canDispelMagic = {"unit"},
    hasDebuff = {"unit", "debuff"}, enemiesAround = {"radius"}, alliesBelowHP = {"threshold"},
    myAtonementCount = {}, modifier = {"key"}, isInterruptible = {"unit"},
    unitInRange = {"unit"}, enemyCastingSpell = {"spell"},
}

-- Spell Dropdown
local selectedSpellID
local spellDropdown = CreateFrame("Frame", "SpellCoreSpellDropdown", builderFrame, "UIDropDownMenuTemplate")
spellDropdown:SetPoint("TOPLEFT", 10, -40)
UIDropDownMenu_SetWidth(spellDropdown, 200)
UIDropDownMenu_Initialize(spellDropdown, function(self, level)
    for id, name in pairs(priestSpells) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = name
        info.value = id
        info.func = function()
            selectedSpellID = id
            UIDropDownMenu_SetSelectedValue(spellDropdown, id)
            UIDropDownMenu_SetText(spellDropdown, name)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

-- Target Dropdown
local selectedTarget
local targetDropdown = CreateFrame("Frame", "SpellCoreTargetDropdown", builderFrame, "UIDropDownMenuTemplate")
targetDropdown:SetPoint("TOPLEFT", spellDropdown, "BOTTOMLEFT", 0, -20)
UIDropDownMenu_SetWidth(targetDropdown, 200)
UIDropDownMenu_Initialize(targetDropdown, function(self, level)
    for _, target in ipairs(availableTargets) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = target
        info.value = target
        info.func = function()
            selectedTarget = target
            UIDropDownMenu_SetSelectedValue(targetDropdown, target)
            UIDropDownMenu_SetText(targetDropdown, target)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

-- Conditions dynamiques
local conditionBlocks = {}
local function CreateConditionBlock(index)
    local block = {}
    block.dropdown = CreateFrame("Frame", nil, builderFrame, "UIDropDownMenuTemplate")
    block.dropdown:SetPoint("TOPLEFT", 220, -40 - ((index - 1) * 70))
    UIDropDownMenu_SetWidth(block.dropdown, 200)
    UIDropDownMenu_Initialize(block.dropdown, function(self, level)
        for cond, _ in pairs(conditionArguments) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = cond
            info.value = cond
            info.func = function()
                block.name = cond
                UIDropDownMenu_SetText(block.dropdown, cond)

                -- Crée les champs de texte pour les arguments
                if block.args then
                    for _, f in ipairs(block.args) do f:Hide() end
                end
                block.args = {}
                local args = conditionArguments[cond]
                for i, label in ipairs(args) do
                    local input = CreateFrame("EditBox", nil, builderFrame, "InputBoxTemplate")
                    input:SetSize(120, 20)
                    input:SetAutoFocus(false)
                    input:SetPoint("TOPLEFT", block.dropdown, "TOPRIGHT", 10, -((i - 1) * 22))
                    input:SetText(label)
                    table.insert(block.args, input)
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    table.insert(conditionBlocks, block)
end

-- Ajouter un bloc condition
local addCondButton = CreateFrame("Button", nil, builderFrame, "UIPanelButtonTemplate")
addCondButton:SetText("➕ Ajouter une condition")
addCondButton:SetSize(200, 25)
addCondButton:SetPoint("TOPLEFT", targetDropdown, "BOTTOMLEFT", 0, -10)
addCondButton:SetScript("OnClick", function()
    CreateConditionBlock(#conditionBlocks + 1)
end)
CreateConditionBlock(1)

-- Bouton d'ajout à la rotation
local addRotationButton = CreateFrame("Button", nil, builderFrame, "UIPanelButtonTemplate")
addRotationButton:SetText("Ajouter à la rotation")
addRotationButton:SetSize(200, 25)
addRotationButton:SetPoint("TOPLEFT", addCondButton, "BOTTOMLEFT", 0, -10)

local visualList = {}
local function RefreshRotationDisplay()
    for _, row in ipairs(visualList) do row:Hide() end
    wipe(visualList)
    if not SpellCore.CustomRotation then return end
    local prev
    for i, entry in ipairs(SpellCore.CustomRotation) do
        local row = CreateFrame("Frame", nil, builderFrame)
        row:SetSize(600, 20)
        row:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
        if prev then row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -4)
        else row:SetPoint("TOPLEFT", addRotationButton, "BOTTOMLEFT", 0, -20) end
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", 5, 0)
        text:SetText(i .. ". " .. table.concat(entry, " | "))
        table.insert(visualList, row)
        prev = row
    end
end

addRotationButton:SetScript("OnClick", function()
    if not selectedSpellID or not selectedTarget then
        print("|cffff0000[SpellCore] Choisissez un sort et une cible.|r")
        return
    end

    local conditionStrings = {}
    for _, block in ipairs(conditionBlocks) do
        if block.name then
            local args = {}
            for _, f in ipairs(block.args or {}) do table.insert(args, f:GetText()) end
            local condition = block.name .. "(" .. table.concat(args, ", ") .. ")"
            table.insert(conditionStrings, condition)
        end
    end

    SpellCore.CustomRotation = SpellCore.CustomRotation or {}
    table.insert(SpellCore.CustomRotation, {
        tostring(selectedSpellID),
        #conditionStrings > 0 and table.concat(conditionStrings, " and ") or nil,
        "target." .. selectedTarget
    })

    RefreshRotationDisplay()
end)

-- Sauvegarde
local saveButton = CreateFrame("Button", nil, builderFrame, "UIPanelButtonTemplate")
saveButton:SetText("💾 Sauvegarder")
saveButton:SetSize(200, 25)
saveButton:SetPoint("TOPLEFT", addRotationButton, "TOPRIGHT", 10, 0)
saveButton:SetScript("OnClick", function()
    if SpellCore.CustomRotation and #SpellCore.CustomRotation > 0 then
        SpellCore.CombatRotation = CopyTable(SpellCore.CustomRotation)
        print("|cff00ff00[SpellCore] Rotation personnalisée sauvegardée.|r")
    else
        print("|cffff0000[SpellCore] Aucune rotation définie.|r")
    end
end)

builderFrame:SetScript("OnShow", RefreshRotationDisplay)



-- Default tab
SwitchTab(1)

-- Slash command
SLASH_SPELLCOREUI1 = "/spellcoreui"
SlashCmdList["SPELLCOREUI"] = function()
    if SpellCoreUI:IsShown() then
        SpellCoreUI:Hide()
    else
        SpellCoreUI:Show()
    end
end
