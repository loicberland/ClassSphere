local CS = ClassSphere
CS:RegisterClass("WARLOCK", {
    buttons = {
        { id="warlock_armor", label="Armure", type="spellGroup", choices={
            CS:Choice("DEMON","Armure démoniaque",{706,1086,11733,11734,11735,27260}),
            CS:Choice("FEL","Gangrarmure",{28176,28189}),
        }},
        { id="warlock_demon", label="Démon", type="spellGroup", choices={
            CS:Choice("IMP","Diablotin",{688}),
            CS:Choice("VOID","Marcheur du Vide",{697}),
            CS:Choice("SUCC","Succube",{712}),
            CS:Choice("FELH","Chasseur corrompu",{691}),
            CS:Choice("FELG","Gangregarde",{30146}),
        }},
        { id="warlock_healthstone", label="Pierre de soins", type="createUse", items={5512,5511,5509,5510,9421,22103,22104,22105}, createSpells={6201,6202,5699,11729,11730,27230} },
        { id="warlock_soulstone", label="Pierre d'âme", type="createUse", items={5232,16892,16893,16895,16896,22116}, createSpells={693,20752,20755,20756,20757,27238} },
        { id="warlock_firestone", label="Pierre de feu", type="createUse", items={1254,13699,13700,13701,22128}, createSpells={6366,17951,17952,17953,27250} },
        { id="warlock_spellstone", label="Pierre de sort", type="createUse", items={5522,13602,13603,22646}, createSpells={2362,17727,17728,28172} },
        { id="warlock_curse", label="Malédictions", type="spellGroup", choices={
            CS:Choice("AGONY", "Malédiction d'agonie",{980,1014,6217,11711,11712,11713,27218}),
            CS:Choice("WEAKNESS", "Malédiction de faiblesse",{702,1108,6205,7646,11707,11708,27224,30909}),
            CS:Choice("RECKLESSNESS", "Malédiction de témérité",{704,7658,7659,11717,27226}),
            CS:Choice("TONGUES", "Malédiction des langages",{1714,11719}),
            CS:Choice("ELEMENTS", "Malédiction des éléments",{1490,11721,11722,27228}),
            CS:Choice("SHADOW", "Malédiction de l'ombre",{17862,17937,27229}),
            CS:Choice("DOOM", "Malédiction funeste",{603,30910}),
            CS:Choice("EXHAUSTION", "Malédiction de fatigue",{18223}),} },
        { id = "warlock_hadow_metamorphosis",label = "Détection des démons",type = "spell",spells = {47524}, },
        { id = "warlock_breath_invisibility",label = "Respiration interminable / Détection de l'invisibilité",type = "dualSpell",leftSpells = {5697},rightSpells = {132, 2970, 11743}, },
    }
})
