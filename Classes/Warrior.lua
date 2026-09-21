local CS = ClassSphere
CS:RegisterClass("WARRIOR", { buttons = {
    { id="warrior_shout", label="Cri", type="spellGroup", choices={
        CS:Choice("BATTLE","Cri de guerre",{6673,5242,6192,11549,11550,11551,25289,2048}),
        CS:Choice("COMMANDING","Cri de commandement",{469}),
    }},
    { id="warrior_stance", label="Posture", type="spellGroup", choices={
        CS:Choice("BATTLE","Posture de combat",{2457}),
        CS:Choice("DEF","Posture défensive",{71}),
        CS:Choice("BERSERKER","Posture berserker",{2458}),
    }},
    { id="warrior_berserker", label="Rage berserker", type="spell", spells={18499} },
}})
