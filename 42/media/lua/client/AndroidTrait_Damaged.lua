AndroidTrait = AndroidTrait or {}
AndroidTrait.Damaged = AndroidTrait.Damaged or {}
AndroidTrait.Damaged.shockFrameSpeed = 0.05
AndroidTrait.Damaged.shockBlankFrequency = 4

function AndroidTrait.Damaged.getShockDuration(dmg)
    dmg = tonumber(dmg) or 0
    if dmg <= 0.5 then return 0.5 end
    if dmg <= 1 then return 1 end
    if dmg <= 2 then return 1.5 end
    return 3
end

function AndroidTrait.Damaged.triggerShock(pl, dmg)
    local duration = AndroidTrait.Damaged.getShockDuration(dmg)
    AndroidTrait.SparkHandler.request(pl, duration, AndroidTrait.Damaged.shockFrameSpeed, 0, 0, 0, true, AndroidTrait.Damaged.shockBlankFrequency)
end

function AndroidTrait.Damaged.dbgSpark(dmg)
    local pl = getPlayer()
    if not pl then return false end
    AndroidTrait.Damaged.triggerShock(pl, tonumber(dmg) or 1)
    return true
end

function AndroidTrait.Damaged.onPlayerGetDamage(pl, dmgType, dmg)
    if not pl or pl ~= getPlayer() or not AndroidTrait.hasTrait(pl) then return end
    if dmgType ~= "WEAPONHIT" or not dmg or dmg <= 0 then return end
    AndroidTrait.Damaged.triggerShock(pl, dmg)
end
Events.OnPlayerGetDamage.Remove(AndroidTrait.Damaged.onPlayerGetDamage)
Events.OnPlayerGetDamage.Add(AndroidTrait.Damaged.onPlayerGetDamage)
