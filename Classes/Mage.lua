local CS = ClassSphere
CS:RegisterClass("MAGE", {
    buttons = {
        { id="mage_armor", label="Armure", type="spellGroup", choices={
            CS:Choice("FROST","Armure de givre",{168,7300,7301,10219,10220}),
            CS:Choice("ICE","Armure de glace",{7302,7320,10219,10220,27124}),
            CS:Choice("MAGE","Armure du mage",{6117,22782,22783,27125}),
            CS:Choice("MOLTEN","Armure de la fournaise",{30482}),
        }},
        { id="mage_intellect", label="Intelligence", type="spellGroup", choices={
            CS:Choice("AI","Intelligence des Arcanes",{1459,1460,1461,10156,10157,27126}),
            CS:Choice("AB","Illumination des Arcanes",{23028,27127}),
        }},
        { id="mage_magic", label="Magie", type="spellGroup", choices={
            CS:Choice("AMPLIFY","Amplification de la magie",{1008,8455,10169,10170,27130}),
            CS:Choice("DAMPEN","Atténuation de la magie",{604,8450,8451,10173,10174,33944}),
        }},
        { id="mage_water", label="Eau", type="createUse", items={5350,2288,2136,3772,8077,8078,8079,22018,43523}, createSpells={5504,5505,5506,6127,10138,10139,10140,37420,27090} },
        { id="mage_food", label="Nourriture", type="createUse", items={5349,1113,1114,1487,8075,8076,22895,34062,43518}, createSpells={587,597,990,6129,10144,10145,28612,33717} },
        { id="mage_gem", label="Gemme de mana", type="createUse", items={5514,5513,8007,8008,22044}, createSpells={759,3552,10053,10054,27101} },
        { id="mage_ward", label="Gardien", type="spellGroup", choices={
            CS:Choice("FIRE","Gardien de feu",{543,8457,8458,10223,10225,27128}),
            CS:Choice("FROST","Gardien de givre",{6143,8461,8462,10177,28609,32796}),
        }},
    }
})
