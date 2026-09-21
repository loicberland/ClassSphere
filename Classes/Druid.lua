local CS = ClassSphere
CS:RegisterClass("DRUID", { buttons = {
    { id="druid_mark", label="Marque du fauve", type="spellGroup", choices={
        CS:Choice("SINGLE","Marque du fauve",{1126,5232,6756,5234,8907,9884,9885,26990}),
        CS:Choice("GROUP","Don du fauve",{21849,21850,26991},{17021, 17026, 22148}),
    }},
    { id="druid_thorns", label="Épines", type="spell", spells={467,782,1075,8914,9756,9910,26992} },
    { id="druid_form", label="Forme", type="spellGroup", choices={
        CS:Choice("CAT","Forme de félin",{768}),
        CS:Choice("BEAR","Forme d'ours",{5487}),
        CS:Choice("DIREBEAR","Forme d'ours redoutable",{9634}),
        CS:Choice("TRAVEL","Forme de voyage",{783}),
        CS:Choice("AQUATIC","Forme aquatique",{1066}),
        CS:Choice("MOONKIN","Forme de sélénien",{24858}),
        CS:Choice("TREE","Arbre de vie",{33891}),
        CS:Choice("FLIGHT","Forme de vol",{33943}),
        CS:Choice("SWIFTFLIGHT","Forme de vol rapide",{40120}),
    }},
    { id="druid_omen", label="Augure de clarté", type="spell", spells={16864}, default=false },
    { id = "druid_rebirth", label = "Renaissance", type = "reagentSpell", ranks = {
        { spell = 20484, reagent = 17034 },
        { spell = 20739, reagent = 17035 },
        { spell = 20742, reagent = 17036 },
        { spell = 20747, reagent = 17037 },
        { spell = 20748, reagent = 17038 },
        { spell = 26994, reagent = 22147 },
    }},
}})
