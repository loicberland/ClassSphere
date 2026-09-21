local CS = ClassSphere
CS:RegisterClass("PRIEST", { buttons = {
    { id="priest_fortitude", label="Robustesse", type="spellGroup", choices={
        CS:Choice("SINGLE","Mot de pouvoir : Robustesse",{1243,1244,1245,2791,10937,10938,25389}),
        CS:Choice("GROUP","Prière de robustesse",{21562,21564,25392}),
    }},
    { id="priest_spirit", label="Esprit divin", type="spellGroup", choices={
        CS:Choice("SINGLE","Esprit divin",{14752,14818,14819,27841,25312}),
        CS:Choice("GROUP","Prière d'Esprit",{27681,32999}),
    }},
    { id="priest_shadow", label="Protection contre l'Ombre", type="spellGroup", choices={
        CS:Choice("SINGLE","Protection contre l'Ombre",{976,10957,10958,25433}),
        CS:Choice("GROUP","Prière de protection contre l'Ombre",{27683,39374}),
    }},
    { id="priest_innerfire", label="Feu intérieur", type="spell", spells={588,7128,602,1006,10951,10952,25431} },
    { id="priest_fearward", label="Gardien de peur", type="spell", spells={6346}, default=false },
}})
