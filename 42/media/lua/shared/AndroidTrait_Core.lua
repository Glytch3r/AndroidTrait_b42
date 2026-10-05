AndroidTrait = AndroidTrait or {}
AndroidTrait.traitID = "AndroidTrait:Android"

function AndroidTrait.getTrait()
    if not CharacterTrait or not CharacterTrait.get or not ResourceLocation or not ResourceLocation.of then return nil end
    return CharacterTrait.get(ResourceLocation.of(AndroidTrait.traitID))
end

function AndroidTrait.hasTrait(pl)
    if not pl or not pl.hasTrait then return false end
    local trait = AndroidTrait.getTrait()
    return trait and pl:hasTrait(trait) or false
end

function AndroidTrait.getBatteryCharge(item)
    if not item or not item.getCurrentUsesFloat then return 0 end
    return item:getCurrentUsesFloat() or 0
end

function AndroidTrait.setTrait(pl, isAdd)
    if not pl then return end
    local trait = AndroidTrait.getTrait()
    if not trait then return end
    if isAdd then
        if not pl:hasTrait(trait) then
            pl:getCharacterTraits():add(trait)
            pl:modifyTraitXPBoost(trait, false)
        end
    elseif pl:hasTrait(trait) then
        pl:getCharacterTraits():remove(trait)
        pl:modifyTraitXPBoost(trait, true)
    end
    SyncXp(pl)
end
