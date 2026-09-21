local CS = ClassSphere

CS.EmptyChoice = { key = "NONE", label = "Aucun", allowEmpty = true, icon = "Interface\\Buttons\\UI-GroupLoot-Pass-Up" }

function CS:Choice(key, label, ids, reagents, icon)
    return {
        key = key,
        label = label,
        ids = ids,
        reagents = reagents,
        icon = icon,
    }
end

CS.Poisons = {
    { key="INSTANT", label="Poison instantané", items={6947,6949,6950,8926,8927,8928,21927}, icon="Interface\\Icons\\Ability_Poisons" },
    { key="DEADLY", label="Poison mortel", items={2892,2893,8984,8985,20844,22053,22054}, icon="Interface\\Icons\\Ability_Rogue_DualWeild" },
    { key="CRIPPLING", label="Poison affaiblissant", items={3775}, icon="Interface\\Icons\\Ability_PoisonSting" },
    { key="MIND", label="Poison de distraction mentale", items={5237}, icon="Interface\\Icons\\Spell_Nature_NullifyDisease" },
    { key="WOUND", label="Poison douloureux", items={10918,10920,10921,10922,22055}, icon="Interface\\Icons\\INV_Misc_Herb_16" },
    { key="ANESTHETIC", label="Poison anesthésiant", items={21835}, icon="Interface\\Icons\\Spell_Nature_SlowPoison", minLevel=68 },
}
