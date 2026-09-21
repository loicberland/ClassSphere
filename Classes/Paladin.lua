local CS = ClassSphere
CS:RegisterClass("PALADIN", { buttons = {
    { id="pal_might", label="Bénédiction de puissance", type="spellGroup", choices={
        CS:Choice("NORMAL","Bénédiction de puissance",{19740,19834,19835,19836,19837,19838,25291,27140}),
        CS:Choice("GREATER","Bénédiction de puissance supérieure",{25782,25916,27141}),
    }},
    { id="pal_wisdom", label="Bénédiction de sagesse", type="spellGroup", choices={
        CS:Choice("NORMAL","Bénédiction de sagesse",{19742,19850,19852,19853,19854,25290,27142}),
        CS:Choice("GREATER","Bénédiction de sagesse supérieure",{25894,25918,27143}),
    }},
    { id="pal_kings", label="Bénédiction des rois", type="spellGroup", choices={
        CS:Choice("NORMAL","Bénédiction des rois",{20217}),
        CS:Choice("GREATER","Bénédiction des rois supérieure",{25898}),
    }},
    { id="pal_salvation", label="Bénédiction de salut", type="spellGroup", choices={
        CS:Choice("NORMAL","Bénédiction de salut",{1038}),
        CS:Choice("GREATER","Bénédiction de salut supérieure",{25895}),
    }},
    { id="pal_light", label="Bénédiction de lumière", type="spellGroup", choices={
        CS:Choice("NORMAL","Bénédiction de lumière",{19977,19978,19979,27144}),
        CS:Choice("GREATER","Bénédiction de lumière supérieure",{25890,27145}),
    }},
    { id="pal_aura", label="Aura", type="spellGroup", choices={
        CS:Choice("DEVOTION","Aura de dévotion",{465,10290,643,10291,1032,10292,10293,27149}),
        CS:Choice("RETRI","Aura de vindicte",{7294,10298,10299,10300,10301,27150}),
        CS:Choice("CONC","Aura de concentration",{19746}),
        CS:Choice("SHADOW","Aura de résistance à l'Ombre",{19876,19895,19896,27151}),
        CS:Choice("FROST","Aura de résistance au Givre",{19888,19897,19898,27152}),
        CS:Choice("FIRE","Aura de résistance au Feu",{19891,19899,19900,27153}),
        CS:Choice("CRUSADER","Aura de croisé",{32223}),
    }},
}})
