local CS = ClassSphere
CS:RegisterClass("HUNTER", { buttons = {
    { id="hunter_aspect", label="Aspect", type="spellGroup", choices={
        CS:Choice("HAWK","Aspect du faucon",{13165,14318,14319,14320,14321,14322,25296,27044}),
        CS:Choice("MONKEY","Aspect du singe",{13163}),
        CS:Choice("CHEETAH","Aspect du guépard",{5118}),
        CS:Choice("PACK","Aspect de la meute",{13159}),
        CS:Choice("WILD","Aspect de la nature",{20043,20190,27045}),
        CS:Choice("VIPER","Aspect de la vipère",{34074}),
        CS:Choice("BEAST","Aspect de la bête",{13161}),
    }},
    { id="hunter_track", label="Pistage", type="spellGroup", choices={
        CS:Choice("BEASTS","Pistage des bêtes",{1494}),
        CS:Choice("HUMANOIDS","Pistage des humanoïdes",{19883}),
        CS:Choice("UNDEAD","Pistage des morts-vivants",{19884}),
        CS:Choice("HIDDEN","Pistage des camouflés",{19885}),
        CS:Choice("ELEMENTALS","Pistage des élémentaires",{19880}),
        CS:Choice("DEMONS","Pistage des démons",{19878}),
        CS:Choice("GIANTS","Pistage des géants",{19882}),
        CS:Choice("DRAGONKIN","Pistage des draconiens",{19879}),
    }},
    { id="hunter_mend", label="Guérison du familier", type="spell", spells={136,3111,3661,3662,13542,13543,13544,27046} },
    { id="hunter_callpet", label="Appel du familier", type="spell", spells={883} },
    { id="hunter_revive", label="Ressusciter le familier", type="spell", spells={982} },
}})
