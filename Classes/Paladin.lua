local CS = ClassSphere

CS:RegisterClass("PALADIN", {
    buttons = {

        -- AURAS
        {
            id = "pal_aura",
            label = "Auras",
            type = "spellGroup",
            choices = {
                CS:Choice("DEVOTION", "Aura de dévotion",
                    {465,10290,643,10291,1032,10292,10293,27149}),

                CS:Choice("RETRI", "Aura de vindicte",
                    {7294,10298,10299,10300,10301,27150}),

                CS:Choice("CONC", "Aura de concentration",
                    {19746}),

                CS:Choice("SHADOW", "Aura de résistance à l'Ombre",
                    {19876,19895,19896,27151}),

                CS:Choice("FROST", "Aura de résistance au Givre",
                    {19888,19897,19898,27152}),

                CS:Choice("FIRE", "Aura de résistance au Feu",
                    {19891,19899,19900,27153}),

                CS:Choice("SANCTITY", "Aura de sainteté",
                    {20218}),

                CS:Choice("CRUSADER", "Aura de croisé",
                    {32223}),
            },
        },

        -- BENEDICTIONS
        -- Chaque bénédiction supérieure utilise un Symbole des rois :
        -- objet 21177, indiqué pour chacun de ses rangs.
        {
            id = "pal_blessings",
            label = "Bénédictions",
            type = "spellGroup",
            choices = {
                CS:Choice("MIGHT", "Bénédiction de puissance",
                    {19740,19834,19835,19836,19837,19838,25291,27140}),

                CS:Choice("GREATER_MIGHT",
                    "Bénédiction de puissance supérieure",
                    {25782,25916,27141},
                    {21177,21177,21177}),

                CS:Choice("WISDOM", "Bénédiction de sagesse",
                    {19742,19850,19852,19853,19854,25290,27142}),

                CS:Choice("GREATER_WISDOM",
                    "Bénédiction de sagesse supérieure",
                    {25894,25918,27143},
                    {21177,21177,21177}),

                CS:Choice("KINGS", "Bénédiction des rois",
                    {20217}),

                CS:Choice("GREATER_KINGS",
                    "Bénédiction des rois supérieure",
                    {25898},
                    {21177}),

                CS:Choice("SALVATION", "Bénédiction de salut",
                    {1038}),

                CS:Choice("GREATER_SALVATION",
                    "Bénédiction de salut supérieure",
                    {25895},
                    {21177}),

                CS:Choice("LIGHT", "Bénédiction de lumière",
                    {19977,19978,19979,27144}),

                CS:Choice("GREATER_LIGHT",
                    "Bénédiction de lumière supérieure",
                    {25890,27145},
                    {21177,21177}),

                CS:Choice("SANCTUARY", "Bénédiction du sanctuaire",
                    {20911,20912,20913,20914,27168}),

                CS:Choice("GREATER_SANCTUARY",
                    "Bénédiction du sanctuaire supérieure",
                    {25899,27169},
                    {21177,21177}),

                CS:Choice("FREEDOM", "Bénédiction de liberté",
                    {1044}),

                CS:Choice("PROTECTION", "Bénédiction de protection",
                    {1022,5599,10278}),

                CS:Choice("SACRIFICE", "Bénédiction de sacrifice",
                    {6940,20729,27147,27148}),
            },
        },

        -- SCEAUX
        {
            id = "pal_seals",
            label = "Sceaux",
            type = "spellGroup",
            choices = {
                CS:Choice("RIGHTEOUSNESS", "Sceau de piété",
                    {21084,20287,20288,20289,20290,20291,20292,20293,27155}),

                CS:Choice("CRUSADER", "Sceau du Croisé",
                    {21082,20162,20305,20306,20307,20308,27158}),

                CS:Choice("COMMAND", "Sceau d'autorité",
                    {20375,20915,20918,20919,20920,27170}),

                CS:Choice("JUSTICE", "Sceau de justice",
                    {20164}),

                CS:Choice("LIGHT", "Sceau de lumière",
                    {20165,20347,20348,20349,27160}),

                CS:Choice("WISDOM", "Sceau de sagesse",
                    {20166,20356,20357,27166}),

                CS:Choice("BLOOD", "Sceau de sang",
                    {31892}),

                CS:Choice("VENGEANCE", "Sceau de vengeance",
                    {31801}),
            },
        },

        -- REDEMPTION : meilleur rang appris, sans composant
        {
            id = "pal_redemption",
            label = "Rédemption",
            type = "spell",
            spells = {7328,10322,10324,20772,20773},
        },

        -- FUREUR VERTUEUSE
        {
            id = "pal_righteous_fury",
            label = "Fureur vertueuse",
            type = "spell",
            spells = {25780},
        },

    },
})