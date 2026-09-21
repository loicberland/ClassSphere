local CS = ClassSphere

CS.ShamanTotems = {
    EARTH = {
        CS:Choice("EARTHBIND","Totem de lien terrestre",{2484}),
        CS:Choice("STONECLAW","Totem de griffes de pierre",{5730,6390,6391,6392,10427,10428,25525}),
        CS:Choice("STRENGTH","Totem de Force de la Terre",{8075,8160,8161,10442,25361,25528}),
        CS:Choice("STONESKIN","Totem de peau de pierre",{8071,8154,8155,10406,10407,10408,25509}),
        CS:Choice("TREMOR","Totem de séisme",{8143}),
        CS:Choice("EARTHELEM","Totem d'élémentaire de terre",{2062}),
    },
    FIRE = {
        CS:Choice("FIRENOVA","Totem Nova de feu",{1535,8498,8499,11314,11315,25546}),
        CS:Choice("SEARING","Totem incendiaire",{3599,6363,6364,6365,10437,10438,25533}),
        CS:Choice("FROSTRESIST","Totem de résistance au Givre",{8181,10478,10479,25560}),
        CS:Choice("MAGMA","Totem de magma",{8190,10585,10586,10587,25552}),
        CS:Choice("FLAMETONGUE","Totem Langue de feu",{8227,8249,10526,16387,25557}),
        CS:Choice("FIREELEM","Totem d'élémentaire de feu",{2894}),
        CS:Choice("WRATH","Totem de courroux",{30706,57720,57721}),
    },
    WATER = {
        CS:Choice("POISON","Totem de Purification du poison",{8166}),
        CS:Choice("MANA","Totem Fontaine de mana",{5675,10495,10496,10497,25570}),
        CS:Choice("FIRERESIST","Totem de résistance au Feu",{8184,10537,10538,25563}),
        CS:Choice("HEALING","Totem guérisseur",{5394,6375,6377,10462,10463,25567}),
        CS:Choice("DISEASE","Totem de Purification des maladies",{8170}),
        CS:Choice("MANATIDE","Totem de Vague de mana",{16190,17354,17359}),
    },
    AIR = {
        CS:Choice("GROUNDING","Totem de Glèbe",{8177}),
        CS:Choice("NATURERESIST","Totem de résistance à la Nature",{10595,10600,10601,25574}),
        CS:Choice("WINDFURY","Totem Furie-des-vents",{8512,10613,10614,25585}),
        CS:Choice("SENTRY","Totem Sentinelle",{6495}),
        CS:Choice("WINDWALL","Totem de Mur des vents",{15107,15111,15112}),
        CS:Choice("GRACE","Totem de Grâce aérienne",{8835,10627,25359}),
        CS:Choice("TRANQUIL","Totem de Tranquillité de l'air",{25908}),
        CS:Choice("WRATHAIR","Totem de courroux de l'air",{3738}),
    },
}

local function GetShamanDB()
    local s = CS.char.shaman
    s.setCount = tonumber(s.setCount) or 3
    s.activeSet = tonumber(s.activeSet) or 1
    s.sets = s.sets or {}
    local i
    for i=1,s.setCount do
        s.sets[i] = s.sets[i] or { name="Set "..i, EARTH="NONE", FIRE="NONE", WATER="NONE", AIR="NONE" }
    end
    return s
end

function CS:GetShamanChoice(element, key)
    if key == "NONE" then return self.EmptyChoice end
    local list = self.ShamanTotems[element] or {}
    local i
    for i=1,table.getn(list) do if list[i].key == key then return list[i] end end
    return nil
end

function CS:ApplyShamanTotemButton(b, cfg)
    local sdb = GetShamanDB(); local set = sdb.sets[sdb.activeSet]
    local choice = self:GetShamanChoice(cfg.element, set[cfg.element])
    if choice and choice.allowEmpty then
        b.icon:SetTexture(choice.icon); b.csLabel="Aucun"; b.csTooltip=cfg.label.." : Aucun"
        b.csRightHint="Clic droit : choisir pour le set actif"
        self:SetButtonAttributeSafe(b,"type1",nil); self:SetButtonAttributeSafe(b,"spell1",nil); self:SetButtonAttributeSafe(b,"type2",nil)
    else
        if not choice or not self:GetChoiceSpell(choice) then
            local list = self.ShamanTotems[cfg.element]
            local i; choice=nil
            for i=1,table.getn(list) do if self:GetChoiceSpell(list[i]) then choice=list[i]; break end end
        end
        if not choice then return false end
        local spell = self:GetChoiceSpell(choice)
        b.icon:SetTexture(self:GetChoiceTexture(choice)); b.csLabel=spell.name; b.csTooltip=cfg.label.." : "..spell.name
        b.csRightHint="Clic droit : choisir pour le set actif"
        self:SetButtonAttributeSafe(b,"type1","spell"); self:SetButtonAttributeSafe(b,"spell1",spell.name); self:SetButtonAttributeSafe(b,"type2",nil)
        b.csCooldownSpellSlot = spell.slot
    end
    b.csRightClick = function(owner)
        local choices={CS.EmptyChoice}; local list=CS.ShamanTotems[cfg.element]; local i
        for i=1,table.getn(list) do table.insert(choices,list[i]) end
        CS:ToggleChoiceMenu(owner, choices, function(c)
            if InCombatLockdown and InCombatLockdown() then CS:Print("Choix impossible en combat."); return end
            local db=GetShamanDB(); db.sets[db.activeSet][cfg.element]=c.key; CS:QueueRefresh(); if CS.RefreshConfig then CS:RefreshConfig() end
        end)
    end
    return true
end

function CS:ChangeShamanSet(delta)
    if InCombatLockdown and InCombatLockdown() then
        self:Print("Changement de set de totems impossible en combat.")
        return
    end
    local sdb = GetShamanDB()
    sdb.activeSet = (tonumber(sdb.activeSet) or 1) + delta
    if sdb.activeSet > sdb.setCount then sdb.activeSet = 1 end
    if sdb.activeSet < 1 then sdb.activeSet = sdb.setCount end
    self:QueueRefresh()
    if self.RefreshConfig then self:RefreshConfig() end
end

function CS:ApplyTotemSetCycleButton(b, cfg)
    local sdb = GetShamanDB()
    b.icon:SetTexture("Interface\\Icons\\Spell_Nature_NullWard")
    b.count:SetText(tostring(sdb.activeSet))
    b.csLabel = "Changer de set de totems"
    b.csTooltip = "Set actif : " .. tostring(sdb.activeSet) .. " / " .. tostring(sdb.setCount)
    b.csRightHint = "Clic gauche : set précédent (-1) | Clic droit : set suivant (+1)"
    self:SetButtonAttributeSafe(b, "type1", nil)
    self:SetButtonAttributeSafe(b, "spell1", nil)
    self:SetButtonAttributeSafe(b, "macrotext1", nil)
    self:SetButtonAttributeSafe(b, "type2", nil)
    b.csLeftClick = function() CS:ChangeShamanSet(-1) end
    b.csRightClick = function() CS:ChangeShamanSet(1) end
    return true
end

function CS:ApplyTotemRecallButton(b, cfg)
    local sdb = GetShamanDB()
    local set = sdb.sets[sdb.activeSet]
    local names = {}
    local order = {"EARTH", "FIRE", "WATER", "AIR"}
    local firstSpell = nil
    local recall = self:GetLearnedSpellByID(36936)
    local i

    for i = 1, 4 do
        local c = self:GetShamanChoice(order[i], set[order[i]])
        if c and not c.allowEmpty then
            local sp = self:GetChoiceSpell(c)
            if sp then
                table.insert(names, sp.name)
                if not firstSpell then firstSpell = sp end
            end
        end
    end

    -- Le bouton affiche l'icône native de Rappel totémique.
    if recall then
        b.icon:SetTexture(GetSpellTexture(recall.slot, BOOKTYPE_SPELL))
    elseif firstSpell then
        b.icon:SetTexture(GetSpellTexture(firstSpell.slot, BOOKTYPE_SPELL))
    end

    b.count:SetText(tostring(sdb.activeSet))
    b.csLabel = "Totems"
    b.csTooltip = "Set " .. sdb.activeSet .. " : Terre > Feu > Eau > Air"
    b.csRightHint = "Clic gauche : poser les totems | Clic droit : Rappel totémique"

    -- Clic gauche : castsequence du set actif.
    if table.getn(names) > 0 then
        local macro = "/castsequence reset=combat " .. table.concat(names, ", ")
        self:SetButtonAttributeSafe(b, "type1", "macro")
        self:SetButtonAttributeSafe(b, "macrotext1", macro)

        local gcdProbe = self:GetBestLearned({
            403,529,548,915,943,6041,
            10391,10392,15207,15208,25448
        })
        if gcdProbe then
            b.csCooldownSpellSlot = gcdProbe.slot
        elseif firstSpell then
            b.csCooldownSpellSlot = firstSpell.slot
        end
    else
        self:SetButtonAttributeSafe(b, "type1", nil)
        self:SetButtonAttributeSafe(b, "macrotext1", nil)
    end

    -- Clic droit : Rappel totémique.
    if recall then
        self:SetButtonAttributeSafe(b, "type2", "spell")
        self:SetButtonAttributeSafe(b, "spell2", recall.name)
    else
        self:SetButtonAttributeSafe(b, "type2", nil)
        self:SetButtonAttributeSafe(b, "spell2", nil)
    end

    return true
end

CS:RegisterClass("SHAMAN", {
    buttons = {
        { id="shaman_earth", label="Totem de terre", type="shamanTotem", element="EARTH" },
        { id="shaman_fire", label="Totem de feu", type="shamanTotem", element="FIRE" },
        { id="shaman_water", label="Totem d'eau", type="shamanTotem", element="WATER" },
        { id="shaman_air", label="Totem d'air", type="shamanTotem", element="AIR" },
        { id="shaman_setcycle", label="Changer de set", type="totemSetCycle" },
        { id="shaman_recall", label="Totems", type="totemRecall" },
        { id="shaman_shield", label="Bouclier", type="spellGroup", choices={
            CS:Choice("LIGHTNING","Bouclier de foudre",{324,325,905,945,8134,10431,10432,25469}),
            CS:Choice("WATER","Bouclier d'eau",{24398,33736}),
            CS:Choice("EARTH","Bouclier de terre",{974,32593,32594}),
        }},
        { id="shaman_weapon", label="Enchantement d'arme", type="spellGroup", choices={
            CS:Choice("ROCK","Arme Croque-roc",{8017,8018,8019,10399,16314,16315,16316,25479}),
            CS:Choice("FLAME","Arme Langue de feu",{8024,8027,8030,16339,16341,16342,25489}),
            CS:Choice("FROST","Arme de givre",{8033,8038,10456,16355,16356,25500}),
            CS:Choice("WIND","Arme Furie-des-vents",{8232,8235,10486,16362,25505}),
        }},
        { id="shamam_frost_windwalkon", label="Marche sur l'eau", type="reagentSpell", reagent=17058, spells={546} },
        { id="shaman_shadow_demonbreath", label="Respiration aquatique", type="reagentSpell", reagent=17057, spells={131} },
        { id="shaman_spiritwolf_nature_farsight", label="Loup fantôme / Double vue", type="dualSpell", leftSpells={2645}, rightSpells={6196} },
    }
})
