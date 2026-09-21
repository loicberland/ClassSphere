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
    }
})
