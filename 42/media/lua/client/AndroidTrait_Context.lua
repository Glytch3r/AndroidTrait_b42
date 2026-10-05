----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

AndroidTrait = AndroidTrait or {}
AndroidTrait.batteryTypes = {
	"Base.Battery",
	"Base.CarBattery1",
	"Base.CarBattery2",
	"Base.CarBattery3"
}
function AndroidTrait.isBattery(fullType)
	for i = 1, #AndroidTrait.batteryTypes do
		if fullType == AndroidTrait.batteryTypes[i] then
			return true
		end
	end
	return false
end
function AndroidTrait.addBatteryType(newType)
    if not AndroidTrait.batteryTypes then
        AndroidTrait.batteryTypes = {}
    end
    for _, batteryType in ipairs(AndroidTrait.batteryTypes) do
        if batteryType == newType then
            return false
        end
    end
    table.insert(AndroidTrait.batteryTypes, newType)
    return true
end
-----------------------            ---------------------------
function AndroidTrait.applyEnergy(pl, amount)
    --print(amount)
	local md = pl:getModData()
	if not md['AndroidTraitData'] then md['AndroidTraitData'] = {} end
	md['AndroidTraitData']["NewEnergy"] = (md['AndroidTraitData']["NewEnergy"] or 0) + amount
end
-----------------------            ---------------------------
function AndroidTrait.repairWithItem(pl, item)
	local container = item:getContainer()
	if container then container:Remove(item) end
	local bd = pl:getBodyDamage()
	local wt = math.floor(item:getWeight() * 100)
	local minHeal = math.max(1, math.floor(wt * 0.5))
	local maxHeal = math.max(2, math.floor(wt * 1.5))
	local heal = ZombRand(minHeal, maxHeal + 1)
	bd:AddGeneralHealth(heal)
	AndroidTrait.doAnim(ZombRand(1, 10))
end
-----------------------            ---------------------------
function AndroidTrait.getBattery(inv)
	local battery
	for _, batteryType in ipairs(AndroidTrait.batteryTypes) do
		battery = inv:FindAndReturn(batteryType)
		if battery then break end
	end
	return battery or nil
end
function AndroidTrait.getEarmuffEnergyCostPercent()
    local cost = SandboxVars.AndroidTrait.EarmuffEnergyCost or 15
    return math.max(0, math.min(100, tonumber(cost) or 15))
end
function AndroidTrait.getEnergy(pl)
    pl = pl or getPlayer()
    if not pl then return 0 end
    local data = pl:getModData().AndroidTraitData
    if type(data) ~= "table" then return 0 end
    return tonumber(data.Energy) or 0
end
function AndroidTrait.canWearEarmuff(pl)
    return AndroidTrait.getEnergy(pl) >= AndroidTrait.getEarmuffEnergyCostPercent() * 0.01
end
function AndroidTrait.wearEarmuff(pl, textureChoice)
    if not pl or not AndroidTrait.canWearEarmuff(pl) then return false end
    local data = pl:getModData().AndroidTraitData
    local item = pl:getInventory():AddItem("AndroidTrait.AndroidEars")
    if not item then return false end
    local vis = item:getVisual()
    if not vis then
        pl:getInventory():Remove(item)
        return false
    end
    vis:setTextureChoice(textureChoice)
    pl:setWornItem(item:getBodyLocation(), item)
    data.Energy = math.max(0, AndroidTrait.getEnergy(pl) - AndroidTrait.getEarmuffEnergyCostPercent() * 0.01)
    return true
end
function AndroidTrait.context(plNum, context, worldobjects, test)
    local pl = getSpecificPlayer(plNum)
    if not pl or not AndroidTrait.hasTrait(pl) then return end
    local inv = pl:getInventory()
    local stats = pl:getStats()
    local sq = ISWorldObjectContextMenu.fetchVars.clickedSquare
    if not sq then return end
    local Main = context:addOptionOnTop("Android: ")
    Main.iconTexture = getTexture("media/ui/Android_Context.png")
    local opt = ISContextMenu:getNew(context)
    context:addSubMenu(Main, opt)
	-----------------------            ---------------------------
    local wearMenu = opt:addOption("Wear Earmuff")
    local wearSub = ISContextMenu:getNew(opt)
    opt:addSubMenu(wearMenu, wearSub)
    local costPercent = AndroidTrait.getEarmuffEnergyCostPercent()
    local canWear = AndroidTrait.canWearEarmuff(pl)
    local pinkOpt = wearSub:addOption("Pink", pl, AndroidTrait.wearEarmuff, 0)
    local blueOpt = wearSub:addOption("Blue", pl, AndroidTrait.wearEarmuff, 1)
    local pinkTip = ISWorldObjectContextMenu.addToolTip()
    pinkTip.description = "Consumes "..tostring(costPercent).."% battery."
    pinkOpt.toolTip = pinkTip
    local blueTip = ISWorldObjectContextMenu.addToolTip()
    blueTip.description = "Consumes "..tostring(costPercent).."% battery."
    blueOpt.toolTip = blueTip
    pinkOpt.notAvailable = not canWear
    blueOpt.notAvailable = not canWear
	-----------------------            ---------------------------
    local batteries = {}
    for i = 0, inv:getItems():size()-1 do
        local item = inv:getItems():get(i)
        if item and AndroidTrait.isBattery(item:getFullType()) then
            table.insert(batteries, item)
        end
    end
    if #batteries > 0 then
        local rechargeMenu = opt:addOption("Recharge")
        rechargeMenu.iconTexture = getTexture("media/ui/LootableMaps/map_lightning.png")
        local chargeSub = ISContextMenu:getNew(opt)
        opt:addSubMenu(rechargeMenu, chargeSub)
        for _, battery in ipairs(batteries) do
            local usedDelta = AndroidTrait.getBatteryCharge(battery)
            local entry = chargeSub:addOption(battery:getDisplayName(), worldobjects, function()
				local chargeGained = AndroidTrait.getBatteryCharge(battery)
				AndroidTrait.applyEnergy(pl, chargeGained)
				local container = battery:getContainer()
				if container then container:Remove(battery) end
				HaloTextHelper.addTextWithArrow(pl, "Energy: " .. tostring(AndroidTrait.getEnergyPercent()), true, 0, 0, 255)
				local sq2 = pl:getSquare()
				if isClient() and sq2 then
					getSoundManager():PlayWorldSound('Android_Charge', sq2, 0, 5, 5, false)
				else
					getSoundManager():playUISound("Android_Charge")
				end
				AndroidTrait.doAnim(ZombRand(1, 10))
				context:hideAndChildren()
			end)
            local tex = battery:getTexture()
            if tex then entry.iconTexture = tex end
            local tip = ISWorldObjectContextMenu.addToolTip()
            tip.description = "Restore Energy: " .. math.floor(usedDelta * 100) .. "%"
            entry.toolTip = tip
        end
    end
	-----------------------            ---------------------------
	local minWt = SandboxVars.AndroidTrait.minWt
	local maxWt = SandboxVars.AndroidTrait.maxWt
	local minCal = SandboxVars.AndroidTrait.minCal
    local maxCal = SandboxVars.AndroidTrait.maxCal
    local md = pl:getModData()
    if type(md.AndroidTraitData) ~= "table" then md.AndroidTraitData = {} end
    local curCd = md.AndroidTraitData and md.AndroidTraitData.CD or 0
    local RecalCD = SandboxVars.AndroidTrait.RecalCD
    local rOpt = opt:addOption("Recalibrate Body", worldobjects, function()
        md.AndroidTraitData.CD = RecalCD
        local nut = pl:getNutrition()
        local oldWt = nut:getWeight()
        local randWt = ZombRand(minWt, maxWt + 1)
        local randCal = ZombRand(minCal, maxCal + 1)
        local col = HaloTextHelper.getColorWhite()
        HaloTextHelper.addTextWithArrow(pl, tostring(randWt), randWt > oldWt, col)
        pl:playSoundLocal("TrapTimerExpired")
        addSound(pl, pl:getX(), pl:getY(), pl:getZ(), 10, 1)
        nut:setWeight(randWt)
        nut:setCalories(randCal)
        AndroidTrait.doAnim(ZombRand(1, 10))
        if isClient() then
            sendClientCommand(pl, 'player', 'setWeight', { weight = randWt, id = pl:getOnlineID() })
            sendClientCommand(pl, 'player', 'syncWeight', { id = pl:getOnlineID() })
        end
        context:hideAndChildren()
    end)
    rOpt.iconTexture = getTexture("media/ui/LootableMaps/map_gears.png")
    local rTip = ISWorldObjectContextMenu.addToolTip()
    if curCd > 0 then
        rOpt.notAvailable = true
        if curCd == 1 then
            rTip.description = "Cooldown: 1 Hour Remaining"
        else
            rTip.description = "Cooldown: "..curCd.." Hours Remaining"
        end
    else
        rTip.description = "Randomizes character weight and calories\n" .. "Weight avg: "..math.floor((minWt + maxWt) * 0.5).."\n" .. "Calories avg: "..math.floor((minCal + maxCal) * 0.5).."\n" .. "Cooldown after use: "..RecalCD.." Hours"
    end
    rOpt.toolTip = rTip
	-----------------------            ---------------------------
	local repairItems = {}
    for i = 0, inv:getItems():size()-1 do
        local item = inv:getItems():get(i)
        if item then
            local categ = item:getDisplayCategory()
            if categ == "Electronics" or categ == "Communications" then
                table.insert(repairItems, item)
            end
        end
    end
    if #repairItems > 0 then
        local repairMenu = opt:addOption("Repair")
        repairMenu.iconTexture = getTexture("media/ui/LootableMaps/map_wrench.png")
        local repSub = ISContextMenu:getNew(opt)
        opt:addSubMenu(repairMenu, repSub)
        for _, item in ipairs(repairItems) do
            local entry = repSub:addOption("Consume " .. item:getDisplayName(), worldobjects, function()
				AndroidTrait.repairWithItem(pl, item)
				context:hideAndChildren()
			end)
            local tex = item:getTexture()
            if tex then entry.iconTexture = tex end
            local tip = ISWorldObjectContextMenu.addToolTip()
            tip.description = "Repair using electronic parts\n" .. "Health Restore: ~" .. math.floor(item:getWeight()*100)
            entry.toolTip = tip
        end
    end
	-----------------------            ---------------------------
    local isLowbatt = stats:get(CharacterStat.ENDURANCE) <= 0.2
    local nvgOpt = opt:addOption("Toggle NVG", worldobjects, function()
        AndroidTrait.toggleNVG()
        context:hideAndChildren()
    end)
	nvgOpt.iconTexture = getTexture("media/ui/LootableMaps/map_sun.png")
    if isLowbatt then nvgOpt.notAvailable = true end
end
Events.OnFillWorldObjectContextMenu.Remove(AndroidTrait.context)
Events.OnFillWorldObjectContextMenu.Add(AndroidTrait.context)
-----------------------            ---------------------------
-----------------------            ---------------------------
function AndroidTrait.invContext(player, context, items)
    local pl = getSpecificPlayer(player)
    if not pl or not AndroidTrait.hasTrait(pl) then return end
    local repairList = {}
    local repairGroups = {}
    for _, entry in ipairs(items) do
        local list = entry.items or { entry }
        for i = 1, #list do
            local item = list[i]
            if item then
                local categ = item:getDisplayCategory()
                if categ == "Electronics" or categ == "Communications" then
                    table.insert(repairList, item)
                    local name = item:getDisplayName()
                    if not repairGroups[name] then
                        repairGroups[name] = { items = {}, weight = item:getWeight(), tex = item:getTexture() }
                    end
                    table.insert(repairGroups[name].items, item)
                end
            end
        end
    end
    if #repairList > 0 then
        local repairOpt = context:addOption("Repair", nil, nil)
        local repSub = ISContextMenu:getNew(context)
        context:addSubMenu(repairOpt, repSub)
        for name, group in pairs(repairGroups) do
            local count = #group.items
            local label = count > 1 and ("Consume " .. name .. " x" .. count) or ("Consume " .. name)
            local entry = repSub:addOption(label, nil, function()
                for i = 1, #group.items do
                    local container = group.items[i]:getContainer()
                    if container then container:Remove(group.items[i]) end
                    local bd = pl:getBodyDamage()
                    local wt = math.floor(group.weight * 100)
                    local minHeal = math.max(1, math.floor(wt * 0.5))
                    local maxHeal = math.max(2, math.floor(wt * 1.5))
                    bd:AddGeneralHealth(ZombRand(minHeal, maxHeal + 1))
                end
                AndroidTrait.doAnim(ZombRand(1, 10))
            end)
            if group.tex then entry.iconTexture = group.tex end
            local tip = ISInventoryPaneContextMenu.addToolTip()
            local totalHeal = math.floor(group.weight * 100) * count
            tip.description = "Repair using electronic parts\n" .. "Health Restore: ~" .. totalHeal
            entry.toolTip = tip
        end
    end
    local batteryGroups = {}
    for _, entry in ipairs(items) do
        local list = entry.items or { entry }
        for i = 1, #list do
            local item = list[i]
            if item then
                local fType = item:getFullType()
                if fType and AndroidTrait.isBattery(fType) then
                    local name = item:getDisplayName()
                    if not batteryGroups[name] then
                        batteryGroups[name] = { items = {}, tex = item:getTexture() }
                    end
                    table.insert(batteryGroups[name].items, item)
                end
            end
        end
    end
    local hasBatteries = false
    for _ in pairs(batteryGroups) do hasBatteries = true break end
    if hasBatteries then
        local chargeOpt = context:addOption("Recharge", nil, nil)
        local chargeSub = ISContextMenu:getNew(context)
        context:addSubMenu(chargeOpt, chargeSub)
        for name, group in pairs(batteryGroups) do
            local count = #group.items
            local totalCharge = 0
            for i = 1, count do
                    totalCharge = totalCharge + AndroidTrait.getBatteryCharge(group.items[i])
            end
            local label = count > 1 and ("Consume " .. name .. " x" .. count) or ("Consume " .. name)
            local entry = chargeSub:addOption(label, nil, function()
                for i = 1, #group.items do
                    local battery = group.items[i]
                    local chargeGained = AndroidTrait.getBatteryCharge(battery)
                    AndroidTrait.applyEnergy(pl, chargeGained)
                    local container = battery:getContainer()
                    if container then container:Remove(battery) end
                end
                HaloTextHelper.addTextWithArrow(pl, "Energy: " .. tostring(AndroidTrait.getEnergyPercent()), true, 0, 0, 255)
                local sq = pl:getSquare()
                if isClient() and sq then
                    getSoundManager():PlayWorldSound('Android_Charge', sq, 0, 5, 5, false)
                else
                    getSoundManager():playUISound("Android_Charge")
                end
                AndroidTrait.doAnim(ZombRand(1, 10))
            end)
            if group.tex then entry.iconTexture = group.tex end
            local tip = ISInventoryPaneContextMenu.addToolTip()
            tip.description = "Restore Energy: " .. math.floor(totalCharge * 100) .. "%"
            entry.toolTip = tip
        end
    end
end
Events.OnFillInventoryObjectContextMenu.Remove(AndroidTrait.invContext)
Events.OnFillInventoryObjectContextMenu.Add(AndroidTrait.invContext)
-----------------------            ---------------------------
function AndroidTrait.disableEatDrink(player, context, items)
    local pl = getSpecificPlayer(player)
    if not pl or not AndroidTrait.hasTrait(pl) then
        return
    end
	if not SandboxVars.AndroidTrait.DisableEatDrink then
        return
    end
    local disableOptions = {
        getText("ContextMenu_Drink"),
        getText("ContextMenu_Eat"),
        getText("ContextMenu_Eat_All"),
        getText("ContextMenu_Eat_Quarter"),
        getText("ContextMenu_Eat_Half"),
        getText("ContextMenu_Take_pills")
    }
	
    for i = #context.options, 1, -1 do
        local option = context.options[i]
        for _, name in ipairs(disableOptions) do
            if option.name == name then
                option.notAvailable = true
				option.toolTip = ISInventoryPaneContextMenu.addToolTip()
				option.toolTip.description = "Disabled by Android Trait"
            end
        end
    end
end
Events.OnFillInventoryObjectContextMenu.Remove(AndroidTrait.disableEatDrink)
Events.OnFillInventoryObjectContextMenu.Add(AndroidTrait.disableEatDrink)
