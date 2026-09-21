local CS = ClassSphere
CS:RegisterClass("ROGUE", {
    buttons = {
        { id="rogue_poison_mh", label="Poison main droite", type="poison", slot=16, choices=CS.Poisons },
        { id="rogue_poison_oh", label="Poison main gauche", type="poison", slot=17, choices=CS.Poisons },
        { id="rogue_stealth", label="Camouflage", type="spell", spells={1784,1785,1786,1787,26889} },
        { id="rogue_pick", label="Crochetage", type="spell", spells={1804} },
        { id="rogue_disarm_trap", label="Désarmement de piège", type="spell", spells={1842} },
        { id="rogue_poisons", label="Poisons", type="spell", spells={2842} },
    }
})
