ClassSphere = ClassSphere or {}
local CS = ClassSphere

CS.VERSION = "0.1.7"
CS.buttons = {}
CS.menus = {}
CS.classDefs = {}
CS.spellbook = {}
CS.pendingRefresh = false
CS.class = select(2, UnitClass("player"))
CS.playerKey = UnitName("player") .. " - " .. GetRealmName()

-- Réglages visuels principaux.
-- Ces valeurs permettent de modifier facilement l’UI sans chercher dans le code.
CS.Visual = {
    buttonSize = 30,          -- taille des boutons autour de la sphère
    menuButtonSize = 30,      -- taille des boutons du menu clic droit
    menuGap = 2,              -- espace horizontal entre les boutons du menu
    menuVerticalRange = 30,   -- décalage vertical du premier bouton du menu
    sphereSize = 64,          -- taille du bouton central
    classIconSize = 56,       -- taille de l’icône de classe au centre
}

-- Atlas des icônes de classe du client TBC 2.4.3.
CS.ClassIconCoords = {
    WARRIOR = {0, 0.25, 0, 0.25},
    MAGE    = {0.25, 0.49609375, 0, 0.25},
    ROGUE   = {0.49609375, 0.7421875, 0, 0.25},
    DRUID   = {0.7421875, 0.98828125, 0, 0.25},
    HUNTER  = {0, 0.25, 0.25, 0.5},
    SHAMAN  = {0.25, 0.49609375, 0.25, 0.5},
    PRIEST  = {0.49609375, 0.7421875, 0.25, 0.5},
    WARLOCK = {0.7421875, 0.98828125, 0.25, 0.5},
    PALADIN = {0, 0.25, 0.5, 0.75},
}


local defaults = {
    global = {
        scale = 1.0,
        buttonScale = 1.0,
        radius = 82,
        locked = false,
        visible = true,
        angle = 0,
        x = 0,
        y = 0,
        menuAutoCloseDelay = 6,
    },
    chars = {},
}

local function CopyDefaults(src, dst)
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

function CS:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffClassSphere:|r " .. tostring(msg))
end

function CS:RegisterClass(class, def)
    self.classDefs[class] = def
end

function CS:GetCharDB()
    local c = ClassSphereDB.chars[self.playerKey]
    if not c then
        c = { buttons = {}, selections = {}, order = {}, shaman = {}, warlock = {} }
        ClassSphereDB.chars[self.playerKey] = c
    end
    c.buttons = c.buttons or {}
    c.selections = c.selections or {}
    c.order = c.order or {}
    c.shaman = c.shaman or {}
    c.warlock = c.warlock or {}
    return c
end

function CS:InitDB()
    ClassSphereDB = CopyDefaults(defaults, ClassSphereDB or {})
    self.db = ClassSphereDB.global
    self.char = self:GetCharDB()
end

function CS:BuildSpellBook()
    self.spellbook = {}
    self.spellbookByRank = {}

    local numTabs = GetNumSpellTabs()
    local i

    for i = 1, numTabs do
        local _, _, offset, numSpells = GetSpellTabInfo(i)

        local slot
        for slot = offset + 1, offset + numSpells do
            local name, rank = GetSpellName(slot, BOOKTYPE_SPELL)

            if name then
                rank = rank or ""

                local spell = {
                    slot = slot,
                    name = name,
                    rank = rank,
                }

                -- Garde le rang le plus élevé comme avant
                self.spellbook[name] = spell

                -- Permet aussi de retrouver un rang précis
                self.spellbookByRank[name .. "|" .. rank] = spell
            end
        end
    end
end

function CS:GetLearnedSpellByID(id)
    if not id then return nil end

    local name, rank = GetSpellInfo(id)
    if not name then return nil end

    rank = rank or ""

    local s = self.spellbookByRank[name .. "|" .. rank]
    if not s then
        return nil
    end

    return {
        slot = s.slot,
        name = s.name,
        rank = s.rank,
        id = id,
    }
end

function CS:GetBestLearned(ids)
    if type(ids) == "number" then ids = { ids } end
    local best = nil
    if not ids then return nil end
    local i
    for i = 1, table.getn(ids) do
        local s = self:GetLearnedSpellByID(ids[i])
        if s then best = s end
    end
    return best
end

function CS:GetChoiceSpell(choice)
    if not choice then return nil end
    return self:GetBestLearned(choice.ids or choice.spells or choice.id)
end

function CS:GetChoiceName(choice)
    local s = self:GetChoiceSpell(choice)
    if s then return s.name end
    if choice and choice.label then return choice.label end
    if choice and choice.id then return GetSpellInfo(choice.id) or tostring(choice.id) end
    return "Inconnu"
end

function CS:GetChoiceTexture(choice)
    local s = self:GetChoiceSpell(choice)
    if s then return GetSpellTexture(s.slot, BOOKTYPE_SPELL) end
    if choice and choice.icon then return choice.icon end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

function CS:FindBestItem(itemIds)
    if type(itemIds) == "number" then itemIds = { itemIds } end
    if not itemIds then return nil end
    local i
    for i = table.getn(itemIds), 1, -1 do
        local id = itemIds[i]
        if GetItemCount(id) and GetItemCount(id) > 0 then
            local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(id)
            if name then return { id = id, name = name, texture = texture, count = GetItemCount(id), link = link } end
        end
    end
    return nil
end

function CS:FindBagItem(itemId)
    local bag
    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        local slot
        for slot = 1, slots do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local id = tonumber(string.match(link, "item:(%d+):"))
                if id == itemId then return bag, slot end
            end
        end
    end
    return nil
end

function CS:QueueRefresh()
    if InCombatLockdown and InCombatLockdown() then
        self.pendingRefresh = true
        return
    end
    self.pendingRefresh = false
    self:BuildSpellBook()
    self:BuildButtons()
end

function CS:SetButtonAttributeSafe(button, key, value)
    if InCombatLockdown and InCombatLockdown() then
        self.pendingRefresh = true
        return false
    end
    button:SetAttribute(key, value)
    return true
end

function CS:HideAllMenus(except)
    for k, frame in pairs(self.menus) do
        if frame ~= except then frame:Hide() end
    end
end

function CS:GetMenuPlacement(owner)
    -- Le menu part vers la gauche ou la droite selon la position du bouton
    -- autour du centre, avec un léger décalage vertical du premier bouton.
    local menuPos = owner and owner.csAngle or 0
    while menuPos < 0 do menuPos = menuPos + 360 end
    while menuPos >= 360 do menuPos = menuPos - 360 end

    local relDirection
    local ySign
    local distanceFromHorizontal

    if menuPos < 90 then
        relDirection = "RIGHT"
        ySign = 1
        distanceFromHorizontal = menuPos
    elseif menuPos < 180 then
        relDirection = "LEFT"
        ySign = 1
        distanceFromHorizontal = 180 - menuPos
    elseif menuPos < 270 then
        relDirection = "LEFT"
        ySign = -1
        distanceFromHorizontal = menuPos - 180
    else
        relDirection = "RIGHT"
        ySign = -1
        distanceFromHorizontal = 360 - menuPos
    end

    local range = (self.Visual and self.Visual.menuVerticalRange) or 16
    local relOffsetY = math.floor((distanceFromHorizontal / 90) * range + 0.5) * ySign
    return relDirection, relOffsetY
end

function CS:ApplySquareButtonSkin(b, dynamic)
    local size = dynamic
        and ((self.Visual and self.Visual.menuButtonSize) or 30)
        or ((self.Visual and self.Visual.buttonSize) or 30)

    b:SetWidth(size)
    b:SetHeight(size)
    b:SetHitRectInsets(0, 0, 0, 0)

    ------------------------------------------------
    -- ICONE
    ------------------------------------------------

    if not b.icon then
        b.icon = b:CreateTexture(nil, "BACKGROUND")

        b.icon:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
        b.icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)

        -- Léger recadrage des icônes Blizzard
        b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    ------------------------------------------------
    -- ETATS DU BOUTON
    ------------------------------------------------

    -- Aucun contour permanent
    b:SetNormalTexture(nil)

    -- Survol carré Blizzard
    b:SetHighlightTexture(
        "Interface\\Buttons\\ButtonHilight-Square"
    )

    -- Effet lorsque le bouton est enfoncé
    b:SetPushedTexture(
        "Interface\\Buttons\\UI-Quickslot-Depress"
    )
end

function CS:CreateMenu(owner, choices, onSelect)
    local key = owner:GetName() .. "Menu"
    local menu = self.menus[key]
    if not menu then
        menu = CreateFrame("Frame", key, UIParent)
        menu:SetFrameStrata("DIALOG")
        menu.buttons = {}

        ------------------------------------------------
        -- FERMETURE AUTOMATIQUE
        ------------------------------------------------

        menu.csIdleTime = 0
        menu.csMouseOver = false

        menu:SetScript("OnShow", function()
            this.csIdleTime = 0
            this.csMouseOver = false
        end)

        menu:SetScript("OnHide", function()
            this.csIdleTime = 0
            this.csMouseOver = false
        end)

        menu:SetScript("OnUpdate", function()
            if not CS.db then
                return
            end

            local delay = tonumber(CS.db.menuAutoCloseDelay) or 6

            -- 0 = fermeture automatique désactivée
            if delay <= 0 then
                this.csIdleTime = 0
                return
            end

            -- Le délai est en pause lorsque la souris est sur le menu.
            if this.csMouseOver then
                return
            end

            this.csIdleTime = (this.csIdleTime or 0) + arg1

            if this.csIdleTime >= delay then
                this.csIdleTime = 0
                this:Hide()
            end
        end)

        self.menus[key] = menu
    end

    for _, b in pairs(menu.buttons) do b:Hide() end

    local count = 0
    local i
    for i = 1, table.getn(choices) do
        local choice = choices[i]
        if choice.allowEmpty or choice.forceVisible or self:GetChoiceSpell(choice) then
            count = count + 1
            local b = menu.buttons[count]
            if not b then
                b = CreateFrame("Button", key .. "B" .. count, menu)
                self:ApplySquareButtonSkin(b, true)
                b:SetScript("OnEnter", function()
                    local menu = this:GetParent()

                    if menu then
                        menu.csMouseOver = true
                        menu.csIdleTime = 0
                    end

                    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")

                    if this.csSpellSlot then
                        GameTooltip:SetSpell(this.csSpellSlot, BOOKTYPE_SPELL)
                    else
                        GameTooltip:SetText(this.csLabel or "")
                    end

                    GameTooltip:Show()
                end)

                b:SetScript("OnLeave", function()
                    local menu = this:GetParent()

                    if menu then
                        menu.csMouseOver = false

                        -- En quittant le menu, le délai repart entièrement de zéro.
                        menu.csIdleTime = 0
                    end

                    GameTooltip:Hide()
                end)
                menu.buttons[count] = b
            end

            b.csChoice = choice
            b.csLabel = choice.allowEmpty and "Aucun" or (choice.label or self:GetChoiceName(choice))

            local spell = self:GetChoiceSpell(choice)
            b.csSpellSlot = spell and spell.slot or nil

            b.icon:SetTexture(choice.allowEmpty and "Interface\\Buttons\\UI-GroupLoot-Pass-Up" or (choice.icon or self:GetChoiceTexture(choice)))
            b.icon:SetVertexColor(1, 1, 1)
            b:ClearAllPoints()
            b:SetScript("OnClick", function()
                onSelect(this.csChoice)
                menu:Hide()
            end)
            b:Show()
        end
    end

    -- Les boutons du menu sont chaînés horizontalement vers l'extérieur.
    local relDirection, relOffsetY = self:GetMenuPlacement(owner)
    local relPoint = owner
    local menuGap = (self.Visual and self.Visual.menuGap) or -5

    menu:ClearAllPoints()
    menu:SetPoint("CENTER", owner, "CENTER", 0, 0)
    menu:SetWidth(1); menu:SetHeight(1)

    for i = 1, count do
        local b = menu.buttons[i]
        b:ClearAllPoints()
        if relDirection == "LEFT" then
            b:SetPoint("LEFT", relPoint, "LEFT", -(b:GetWidth() + menuGap), relOffsetY)
        else
            b:SetPoint("LEFT", relPoint, "RIGHT", menuGap, relOffsetY)
        end
        relOffsetY = 0
        relPoint = b
    end

    return menu
end

function CS:ToggleChoiceMenu(owner, choices, onSelect)
    local menu = self:CreateMenu(owner, choices, onSelect)

    if menu:IsVisible() then
        menu:Hide()
    else
        self:HideAllMenus(menu)

        menu.csIdleTime = 0
        menu.csMouseOver = false

        menu:Show()
    end
end

function CS:SaveSpherePosition()
    if not self.sphere or not self.db then return end
    local point, relativeTo, relativePoint, x, y = self.sphere:GetPoint(1)
    if not point then return end
    self.db.spherePoint = point
    self.db.sphereRelativePoint = relativePoint or point
    self.db.sphereX = x or 0
    self.db.sphereY = y or 0
end

function CS:RestoreSpherePosition()
    if not self.sphere or not self.db then return end
    self.sphere:ClearAllPoints()
    if self.db.spherePoint then
        self.sphere:SetPoint(
            self.db.spherePoint,
            UIParent,
            self.db.sphereRelativePoint or self.db.spherePoint,
            self.db.sphereX or 0,
            self.db.sphereY or 0
        )
    else
        self.sphere:SetPoint("CENTER", UIParent, "CENTER", self.db.x or 0, self.db.y or 0)
    end
end

function CS:EnsureSphere()
    if self.sphere then return end

    local f = CreateFrame("Button", "ClassSphereMain", UIParent)
    local sphereSize = (self.Visual and self.Visual.sphereSize) or 64
    f:SetWidth(sphereSize); f:SetHeight(sphereSize)
    f:SetHitRectInsets(10, 10, 10, 10)
    f:SetMovable(true); f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")

    -- Bouton central carré utilisant uniquement les textures du client.
    f.icon = f:CreateTexture(nil, "BACKGROUND")
    local classIconSize = (self.Visual and self.Visual.classIconSize) or 56
    f.icon:SetWidth(classIconSize); f.icon:SetHeight(classIconSize)
    f.icon:SetPoint("CENTER", f, "CENTER", 0, 0)
    f.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
    local coords = self.ClassIconCoords[self.class]
    if coords then
        f.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    else
        f.icon:SetTexCoord(0, 1, 0, 1)
    end

    f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

    f.label = f:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    f.label:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)
    f.label:SetText("")

    self.sphere = f
    self:RestoreSpherePosition()

    f:SetScript("OnDragStart", function()
        if not CS.db.locked and (not InCombatLockdown or not InCombatLockdown()) then
            this:StartMoving()
        end
    end)
    f:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        CS:SaveSpherePosition()
    end)
    f:SetScript("OnClick", function()
        CS:HideAllMenus()

        if arg1 == "RightButton" and CS.ToggleConfig then
            CS:ToggleConfig()
        end
    end)
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText("ClassSphere " .. CS.VERSION)
        GameTooltip:AddLine("Glisser : déplacer", 1,1,1)
        GameTooltip:AddLine("Clic droit : configuration", 1,1,1)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function CS:UpdateSphereStatus()
    if not self.sphere or not self.sphere.label then return end
    if self.class == "WARLOCK" then
        self.sphere.label:SetText(tostring(GetItemCount(6265) or 0))
    else
        self.sphere.label:SetText("")
    end
end

function CS:GetOrderedDefs(def)
    local out, seen = {}, {}
    local byId = {}
    local i
    for i = 1, table.getn(def.buttons or {}) do byId[def.buttons[i].id] = def.buttons[i] end
    for i = 1, table.getn(self.char.order) do
        local id = self.char.order[i]
        if byId[id] then table.insert(out, byId[id]); seen[id] = true end
    end
    for i = 1, table.getn(def.buttons or {}) do
        local b = def.buttons[i]
        if not seen[b.id] then table.insert(out, b); table.insert(self.char.order, b.id) end
    end
    return out
end

function CS:IsButtonEnabled(id, default)
    if self.char.buttons[id] == nil then return default ~= false end
    return self.char.buttons[id]
end

function CS:AcquireButton(id)
    local b = self.buttons[id]
    if b then return b end

    b = CreateFrame("Button", "ClassSphereButton_" .. id, UIParent, "SecureActionButtonTemplate")
    self:ApplySquareButtonSkin(b, false)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    b.cooldown = CreateFrame("Cooldown", "ClassSphereCooldown_" .. id, b, "CooldownFrameTemplate")
    b.cooldown:SetWidth(26); b.cooldown:SetHeight(26)
    b.cooldown:SetPoint("CENTER", b, "CENTER", 0, 0)
    b.cooldown:SetFrameLevel(b:GetFrameLevel() + 2); b.cooldown:Hide()

    b.overlayFrame = CreateFrame("Frame", nil, b)
    b.overlayFrame:SetAllPoints(b)
    b.overlayFrame:SetFrameLevel(b:GetFrameLevel() + 3)

    b.count = b.overlayFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    b.count:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 1, -1)

    b.cooldownText = b.overlayFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    b.cooldownText:SetPoint("CENTER", b, "CENTER", 0, 0); b.cooldownText:SetText("")

    b:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText(this.csTooltip or this.csLabel or "ClassSphere")
        if this.csRightHint then GameTooltip:AddLine(this.csRightHint, .8,.8,.8) end
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)

    b:SetScript("OnMouseUp", function()
        if arg1 == "RightButton" and this.csRightClick then

            -- Le bouton possède lui-même un menu.
            -- ToggleChoiceMenu gérera la fermeture de l'ancien menu.
            this.csRightClick(this)

        else

            -- Tout autre clic sur un bouton ClassSphere
            -- ferme les menus actuellement ouverts.
            CS:HideAllMenus()

            if arg1 == "LeftButton" and this.csLeftClick then
                this.csLeftClick(this)
            end
        end
    end)

    self.buttons[id] = b
    return b
end

function CS:ResetButtonRuntime(b)
    b.csLeftClick = nil
    if b.icon then b.icon:SetVertexColor(1, 1, 1) end
    b.csRightClick = nil
    b.csCooldownSpellSlot = nil
    b.csCooldownItemId = nil
    if b.cooldown then b.cooldown:Hide() end
    if b.cooldownText then b.cooldownText:SetText("") end
end

function CS:UpdateButtonCooldown(b)
    if not b or not b.cooldown then return end
    local start, duration, enable = 0, 0, 0
    if b.csCooldownSpellSlot then
        start, duration, enable = GetSpellCooldown(b.csCooldownSpellSlot, BOOKTYPE_SPELL)
    elseif b.csCooldownItemId then
        local bag, slot = self:FindBagItem(b.csCooldownItemId)
        if bag then start, duration, enable = GetContainerItemCooldown(bag, slot) end
    end
    if start and duration and start > 0 and duration > 0 then
        CooldownFrame_SetTimer(b.cooldown, start, duration, enable or 1)
        b.cooldown:Show()
        local remain = duration - (GetTime() - start)
        if remain > 0 and b.cooldownText then
            if remain >= 60 then
                b.cooldownText:SetText(tostring(math.ceil(remain / 60)) .. "m")
            elseif remain >= 3 then
                b.cooldownText:SetText(tostring(math.ceil(remain)))
            else
                b.cooldownText:SetText(string.format("%.1f", remain))
            end
        end
    else
        b.cooldown:Hide()
        if b.cooldownText then b.cooldownText:SetText("") end
    end
end

function CS:UpdateCooldowns()
    for _, b in pairs(self.buttons) do
        if b:IsVisible() then self:UpdateButtonCooldown(b) end
    end
end

function CS:ApplySpellButton(b, cfg)
    local s = self:GetBestLearned(cfg.spells)
    if not s then return false end
    b.icon:SetTexture(GetSpellTexture(s.slot, BOOKTYPE_SPELL))
    b.csLabel = s.name
    b.csTooltip = cfg.label or s.name
    b.csRightHint = nil
    self:SetButtonAttributeSafe(b, "type1", "spell")
    self:SetButtonAttributeSafe(b, "spell1", s.name)
    self:SetButtonAttributeSafe(b, "type2", nil)
    b.csCooldownSpellSlot = s.slot
    b.csRightClick = nil
    return true
end

function CS:ApplySpellGroupButton(b, cfg)
    local selected = self.char.selections[cfg.id]
    local choice = nil
    local i

    ------------------------------------------------
    -- CHOIX DU SORT
    ------------------------------------------------

    for i = 1, table.getn(cfg.choices) do
        local c = cfg.choices[i]

        if c.key == selected and self:GetChoiceSpell(c) then
            choice = c
            break
        end
    end

    if not choice then
        for i = 1, table.getn(cfg.choices) do
            if self:GetChoiceSpell(cfg.choices[i]) then
                choice = cfg.choices[i]
                break
            end
        end
    end

    if not choice then
        return false
    end

    self.char.selections[cfg.id] = choice.key

    local s = self:GetChoiceSpell(choice)

    ------------------------------------------------
    -- ICONE / LABEL
    ------------------------------------------------

    b.icon:SetTexture(self:GetChoiceTexture(choice))
    b.csLabel = s.name
    b.csTooltip = cfg.label or s.name
    b.csRightHint = "Clic droit : choisir"

    ------------------------------------------------
    -- COMPOSANT EVENTUEL
    ------------------------------------------------

    local reagentId = nil

    if choice.reagents and s.id then
        for i = 1, table.getn(choice.ids) do
            if choice.ids[i] == s.id then
                reagentId = choice.reagents[i]
                break
            end
        end
    end

    if reagentId then
        local count = GetItemCount(reagentId) or 0

        b.count:SetText(tostring(count))

        if count > 0 then
            b.icon:SetVertexColor(1, 1, 1)
        else
            b.icon:SetVertexColor(0.35, 0.35, 0.35)
        end
    else
        -- Sort sans composant
        b.count:SetText("")
        b.icon:SetVertexColor(1, 1, 1)
    end

    ------------------------------------------------
    -- CLIC GAUCHE : LANCER LE SORT
    ------------------------------------------------

    self:SetButtonAttributeSafe(b, "type1", "spell")
    self:SetButtonAttributeSafe(b, "spell1", s.name)

    ------------------------------------------------
    -- CLIC DROIT : MENU DE SELECTION
    ------------------------------------------------

    self:SetButtonAttributeSafe(b, "type2", nil)
    self:SetButtonAttributeSafe(b, "spell2", nil)

    b.csCooldownSpellSlot = s.slot

    b.csRightClick = function(owner)
        CS:ToggleChoiceMenu(owner, cfg.choices, function(c)
            if InCombatLockdown and InCombatLockdown() then
                CS:Print("Choix impossible en combat.")
                return
            end

            CS.char.selections[cfg.id] = c.key
            CS:QueueRefresh()
        end)
    end

    return true
end

function CS:ApplyCreateUseButton(b, cfg)
    local item = self:FindBestItem(cfg.items)
    local spell = self:GetBestLearned(cfg.createSpells)
    if not item and not spell then return false end
    b.icon:SetTexture(item and item.texture or (spell and GetSpellTexture(spell.slot, BOOKTYPE_SPELL)) or cfg.icon)
    b.csLabel = cfg.label; b.csTooltip = cfg.label
    if item then
        b.csRightHint = "Gauche : utiliser | Droite : créer"
        b.icon:SetVertexColor(1, 1, 1)
        self:SetButtonAttributeSafe(b, "type1", "item"); self:SetButtonAttributeSafe(b, "item1", item.name)
        b.count:SetText(item.count or "")
    else
        -- L'objet n'existe pas dans les sacs : impossible de l'utiliser en clic gauche.
        -- Le clic droit reste disponible pour le créer si le sort est appris.
        self:SetButtonAttributeSafe(b, "type1", nil); self:SetButtonAttributeSafe(b, "item1", nil)
        b.count:SetText("0")
        b.icon:SetVertexColor(0.35, 0.35, 0.35)
        b.csRightHint = spell and "Aucun objet | Droite : créer" or "Aucun objet disponible"
    end
    if spell then
        self:SetButtonAttributeSafe(b, "type2", "spell"); self:SetButtonAttributeSafe(b, "spell2", spell.name)
    else
        self:SetButtonAttributeSafe(b, "type2", nil); self:SetButtonAttributeSafe(b, "spell2", nil)
    end
    if item then b.csCooldownItemId = item.id elseif spell then b.csCooldownSpellSlot = spell.slot end
    b.csRightClick = nil
    return true
end

function CS:ApplyReagentSpellButton(b, cfg)
    local spell = nil
    local reagentId = nil

    ------------------------------------------------
    -- SORT AVEC COMPOSANT DIFFÉRENT SELON LE RANG
    ------------------------------------------------

    if cfg.ranks then
        local i

        for i = 1, table.getn(cfg.ranks) do
            local rank = cfg.ranks[i]
            local learned = self:GetLearnedSpellByID(rank.spell)

            if learned then
                spell = learned
                reagentId = rank.reagent
            end
        end

    ------------------------------------------------
    -- ANCIEN FORMAT :
    -- spells={...}, reagent=12345
    ------------------------------------------------

    else
        spell = self:GetBestLearned(cfg.spells)
        reagentId = cfg.reagent
    end

    if not spell then
        return false
    end

    local count = reagentId and (GetItemCount(reagentId) or 0) or 0

    ------------------------------------------------
    -- ICONE
    ------------------------------------------------

    b.icon:SetTexture(
        GetSpellTexture(spell.slot, BOOKTYPE_SPELL)
    )

    if count > 0 then
        b.icon:SetVertexColor(1, 1, 1)
    else
        b.icon:SetVertexColor(0.35, 0.35, 0.35)
    end

    ------------------------------------------------
    -- COMPTEUR DE COMPOSANTS
    ------------------------------------------------

    b.count:SetText(tostring(count))

    ------------------------------------------------
    -- CLIC GAUCHE : SORT
    ------------------------------------------------

    self:SetButtonAttributeSafe(b, "type1", "spell")
    self:SetButtonAttributeSafe(b, "spell1", spell.name)

    ------------------------------------------------
    -- PAS DE CLIC DROIT
    ------------------------------------------------

    self:SetButtonAttributeSafe(b, "type2", nil)
    self:SetButtonAttributeSafe(b, "spell2", nil)

    ------------------------------------------------
    -- TOOLTIP
    ------------------------------------------------

    b.csLabel = spell.name
    b.csTooltip = cfg.label or spell.name
    b.csRightHint = nil
    b.csRightClick = nil

    ------------------------------------------------
    -- COOLDOWN
    ------------------------------------------------

    b.csCooldownSpellSlot = spell.slot

    return true
end

function CS:ApplyDualSpellButton(b, cfg)
    local leftSpell = self:GetBestLearned(cfg.leftSpells or {})
    local rightSpell = self:GetBestLearned(cfg.rightSpells or {})

    if not leftSpell and not rightSpell then return false end

    -- L'icône du clic gauche est prioritaire, sinon celle du clic droit.
    local iconSpell = leftSpell or rightSpell
    if iconSpell then
        b.icon:SetTexture(GetSpellTexture(iconSpell.slot, BOOKTYPE_SPELL))
    end

    if leftSpell then
        self:SetButtonAttributeSafe(b, "type1", "spell")
        self:SetButtonAttributeSafe(b, "spell1", leftSpell.name)
    else
        self:SetButtonAttributeSafe(b, "type1", nil)
        self:SetButtonAttributeSafe(b, "spell1", nil)
    end

    if rightSpell then
        self:SetButtonAttributeSafe(b, "type2", "spell")
        self:SetButtonAttributeSafe(b, "spell2", rightSpell.name)
    else
        self:SetButtonAttributeSafe(b, "type2", nil)
        self:SetButtonAttributeSafe(b, "spell2", nil)
    end

    b.csLabel = cfg.label or "Deux sorts"
    local leftName = leftSpell and leftSpell.name or "Non appris"
    local rightName = rightSpell and rightSpell.name or "Non appris"
    b.csTooltip = "Gauche : " .. leftName .. "\nDroite : " .. rightName
    b.csRightHint = nil

    if leftSpell then
        b.csCooldownSpellSlot = leftSpell.slot
    elseif rightSpell then
        b.csCooldownSpellSlot = rightSpell.slot
    end

    return true
end

function CS:IsPoisonChoiceAvailable(choice)
    if not choice then return false end
    if choice.minLevel and UnitLevel("player") < choice.minLevel then return false end
    return true
end

function CS:ApplyPoisonButton(b, cfg)
    -- Les boutons poison n'apparaissent qu'une fois la compétence Poisons apprise.
    if not self:GetLearnedSpellByID(2842) then return false end
    local selected = self.char.selections[cfg.id]
    local choice = nil
    local i
    for i=1, table.getn(cfg.choices) do
        if cfg.choices[i].key == selected and self:IsPoisonChoiceAvailable(cfg.choices[i]) then
            choice = cfg.choices[i]
            break
        end
    end
    if not choice then
        for i=1, table.getn(cfg.choices) do
            if self:IsPoisonChoiceAvailable(cfg.choices[i]) then
                choice = cfg.choices[i]
                break
            end
        end
    end
    if not choice then return false end
    self.char.selections[cfg.id] = choice.key
    local item = self:FindBestItem(choice.items)
    b.icon:SetTexture(item and item.texture or choice.icon or "Interface\\Icons\\INV_Potion_19")
    b.csLabel = cfg.label; b.csTooltip = cfg.label .. " : " .. choice.label
    b.csRightHint = "Clic droit : choisir le poison"
    b.count:SetText(item and item.count or "0")
    if item then
        local macro = "/use " .. item.name .. "\n/use " .. tostring(cfg.slot)
        self:SetButtonAttributeSafe(b, "type1", "macro"); self:SetButtonAttributeSafe(b, "macrotext1", macro)
    else
        self:SetButtonAttributeSafe(b, "type1", nil); self:SetButtonAttributeSafe(b, "macrotext1", nil)
    end
    self:SetButtonAttributeSafe(b, "type2", nil)
    if item then b.csCooldownItemId = item.id end
    b.csRightClick = function(owner)
        local pseudo = {}
        local n
        for n=1, table.getn(cfg.choices) do
            local c = cfg.choices[n]
            if CS:IsPoisonChoiceAvailable(c) then
                table.insert(pseudo, { key=c.key, label=c.label, icon=c.icon, forceVisible=true, _poison=c })
            end
        end
        CS:ToggleChoiceMenu(owner, pseudo, function(pc)
            CS.char.selections[cfg.id] = pc.key; CS:QueueRefresh()
        end)
    end
    return true
end

function CS:ConfigureButton(b, cfg)
    b.count:SetText("")
    self:ResetButtonRuntime(b)
    if cfg.type == "spell" then return self:ApplySpellButton(b, cfg)
    elseif cfg.type == "spellGroup" then return self:ApplySpellGroupButton(b, cfg)
    elseif cfg.type == "createUse" then return self:ApplyCreateUseButton(b, cfg)
    elseif cfg.type == "reagentSpell" then return self:ApplyReagentSpellButton(b, cfg)
    elseif cfg.type == "poison" then return self:ApplyPoisonButton(b, cfg)
    elseif cfg.type == "shamanTotem" then return self:ApplyShamanTotemButton(b, cfg)
    elseif cfg.type == "totemSetCycle" then return self:ApplyTotemSetCycleButton(b, cfg)
    elseif cfg.type == "totemRecall" then return self:ApplyTotemRecallButton(b, cfg)
    elseif cfg.type == "dualSpell" then return self:ApplyDualSpellButton(b, cfg)
    end
    return false
end

function CS:BuildButtons()
    self:EnsureSphere()
    self:UpdateSphereStatus()
    for _, b in pairs(self.buttons) do b:Hide() end
    local def = self.classDefs[self.class]
    if not def then
        self.sphere:Show(); self.sphere.label:SetText("?"); return
    end
    self.sphere:SetScale(self.db.scale or 1)
    -- Un refresh ne doit jamais modifier la position de la sphère.
    if self.db.visible then self.sphere:Show() else self.sphere:Hide() end
    local defs = self:GetOrderedDefs(def)
    local active = {}
    local i
    for i=1, table.getn(defs) do
        local cfg = defs[i]
        if self:IsButtonEnabled(cfg.id, cfg.default) then
            local b = self:AcquireButton(cfg.id)
            if self:ConfigureButton(b, cfg) then table.insert(active, b) end
        end
    end
    local n = table.getn(active)
    for i=1, n do
        local b = active[i]
        local angleDeg = (self.db.angle or 0) + ((i - 1) * (360 / math.max(1,n)))
        while angleDeg < 0 do angleDeg = angleDeg + 360 end
        while angleDeg >= 360 do angleDeg = angleDeg - 360 end
        local angle = math.rad(angleDeg)
        b.csAngle = angleDeg
        b:ClearAllPoints(); b:SetPoint("CENTER", self.sphere, "CENTER", math.cos(angle) * (self.db.radius or 82), math.sin(angle) * (self.db.radius or 82))
        b:SetScale(self.db.buttonScale or 1); b:Show()
    end
    self:UpdateCooldowns()
end

function CS:HandleSoulShards()
    if self.class ~= "WARLOCK" then return end
    local w = self.char.warlock
    if not w.autoDelete then return end
    local max = tonumber(w.maxShards) or 12
    local count = GetItemCount(6265) or 0
    if count <= max then return end
    local excess = count - max
    while excess > 0 do
        local bag, slot = self:FindBagItem(6265)
        if not bag then break end
        PickupContainerItem(bag, slot)
        if CursorHasItem() then DeleteCursorItem() end
        excess = excess - 1
    end
end

function CS:OnEvent(event)
    if event == "ADDON_LOADED" and arg1 == "ClassSphere" then
        self:InitDB(); self:BuildSpellBook(); self:QueueRefresh()
        self:Print("v" .. self.VERSION .. " chargé. /cs pour configurer.")
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_LEVEL_UP" or event == "SPELLS_CHANGED" or event == "LEARNED_SPELL_IN_TAB" then
        if self.db then self:QueueRefresh() end
    elseif event == "BAG_UPDATE" then
        if self.db then self:HandleSoulShards(); self:QueueRefresh() end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if self.pendingRefresh then self:QueueRefresh() end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function() CS:OnEvent(event) end)
eventFrame.csCooldownElapsed = 0
eventFrame:SetScript("OnUpdate", function()
    this.csCooldownElapsed = (this.csCooldownElapsed or 0) + arg1
    if this.csCooldownElapsed >= 0.10 then
        this.csCooldownElapsed = 0
        if CS.db then CS:UpdateCooldowns() end
    end
end)

SLASH_CLASSSPHERE1 = "/classsphere"
SLASH_CLASSSPHERE2 = "/cs"
SlashCmdList["CLASSSPHERE"] = function(msg)
    if CS.ToggleConfig then CS:ToggleConfig() else CS:Print("Interface non disponible.") end
end
