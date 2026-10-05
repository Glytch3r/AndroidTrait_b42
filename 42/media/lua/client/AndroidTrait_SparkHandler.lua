AndroidTrait = AndroidTrait or {}
AndroidTrait.SparkHandler = AndroidTrait.SparkHandler or {}
AndroidTrait.SparkHandler.module = "AndroidTraitSparkHandler"
AndroidTrait.SparkHandler.command = "start"
AndroidTrait.SparkHandler.texturePath = "media/ui/sparkSpr/Sparks_"
AndroidTrait.SparkHandler.textureCount = 8
AndroidTrait.SparkHandler.imageSize = 128
AndroidTrait.SparkHandler.imageScale = 0.75
AndroidTrait.SparkHandler.bodyOffsetY = 80
AndroidTrait.SparkHandler.active = AndroidTrait.SparkHandler.active or {}
AndroidTrait.SparkHandler.textures = AndroidTrait.SparkHandler.textures or {}
AndroidTrait.SparkHandler.screenPos = AndroidTrait.SparkHandler.screenPos or Vector2.new()
AndroidTrait.SparkHandler.headOffset = 128 / (2 / Core.getTileScale())

function AndroidTrait.SparkHandler.getTargKey(targ)
    if not targ then return nil end
    local targID = targ.getOnlineID and targ:getOnlineID() or nil
    if targID and targID >= 0 then return tostring(targID) end
    local user = targ.getUsername and targ:getUsername() or nil
    return user and string.lower(tostring(user)) or tostring(targ)
end

function AndroidTrait.SparkHandler.getTexture(index)
    if not AndroidTrait.SparkHandler.textures[index] then
        AndroidTrait.SparkHandler.textures[index] = getTexture(AndroidTrait.SparkHandler.texturePath .. tostring(index - 1) .. ".png")
    end
    return AndroidTrait.SparkHandler.textures[index]
end

function AndroidTrait.SparkHandler.getFrameIndex(seed, frame)
    return ((seed + frame * 5 + frame * frame * 3) % AndroidTrait.SparkHandler.textureCount) + 1
end

function AndroidTrait.SparkHandler.isBlankFrame(seed, frame, blankFrequency)
    blankFrequency = math.floor(tonumber(blankFrequency) or 0)
    return blankFrequency > 0 and ((seed + frame * 7) % blankFrequency) == 0
end

function AndroidTrait.SparkHandler.removeTag(data)
    if not data then return end
    local sprites = data.targ and data.targ.getAttachedAnimSprite and data.targ:getAttachedAnimSprite() or nil
    if sprites and data.spr then
        sprites:remove(data.spr)
    end
    data.spr = nil
    data.tag = nil
    data.texture = nil
    data.tagIndex = nil
    data.tagZoomKey = nil
end

function AndroidTrait.SparkHandler.setTag(data, index)
    if not data then return end
    if not index then
        AndroidTrait.SparkHandler.removeTag(data)
        return
    end
    if data.tagIndex == index and data.texture then return end
    local texture = AndroidTrait.SparkHandler.getTexture(index)
    if not texture then
        AndroidTrait.SparkHandler.removeTag(data)
        return
    end
    AndroidTrait.SparkHandler.removeTag(data)
    data.texture = texture
    data.tagIndex = index
end

function AndroidTrait.SparkHandler.getScreenPos(targ, offsetY)
    local screenX, screenY = ISCoordConversion.ToScreen(targ:getX(), targ:getY(), targ:getZ())
    return screenX, screenY + (offsetY or 0)
end
function AndroidTrait.SparkHandler.playSound(targ)
    local sq = targ and targ:getSquare() or nil
    if not sq then return end
    getSoundManager():PlayWorldSound("Android_Spark" .. tostring(ZombRand(9)), sq, 0, 5, 5, false)
end

function AndroidTrait.SparkHandler.removeLight(data)
    if not data or not data.light or not getCell() then return end
    getCell():removeLamppost(data.light)
    data.light = nil
end

function AndroidTrait.SparkHandler.createLight(targ)
    local sq = targ and targ:getSquare() or nil
    if not sq or not getCell() then return nil end
    local light = IsoLightSource.new(sq:getX(), sq:getY(), sq:getZ(), 0, 0, 1, 5)
    getCell():addLamppost(light)
    return light
end

function AndroidTrait.SparkHandler.start(targ, duration, frameSpeed, offsetX, offsetY, rotation, randomRotation, seed, blankFrequency)
    local key = AndroidTrait.SparkHandler.getTargKey(targ)
    if not key then return false end
    AndroidTrait.SparkHandler.removeTag(AndroidTrait.SparkHandler.active[key])
    AndroidTrait.SparkHandler.removeLight(AndroidTrait.SparkHandler.active[key])
    local now = getTimestampMs()
    AndroidTrait.SparkHandler.active[key] = {
        targ = targ,
        startTime = now,
        endTime = now + math.max(0.05, tonumber(duration) or 1) * 1000,
        frameSpeed = math.max(0.016, tonumber(frameSpeed) or 0.1) * 1000,
        offsetX = tonumber(offsetX) or 0,
        offsetY = tonumber(offsetY) or 0,
        rotation = tonumber(rotation) or 0,
        randomRotation = randomRotation == true,
        seed = math.floor(tonumber(seed) or ZombRand(0, 2147483647)),
        blankFrequency = math.max(0, math.floor(tonumber(blankFrequency) or 0)),
        light = AndroidTrait.SparkHandler.createLight(targ)
    }
    AndroidTrait.SparkHandler.playSound(targ)
    return true
end

function AndroidTrait.SparkHandler.stop(targ)
    local key = AndroidTrait.SparkHandler.getTargKey(targ)
    if not key then return false end
    AndroidTrait.SparkHandler.removeTag(AndroidTrait.SparkHandler.active[key])
    AndroidTrait.SparkHandler.removeLight(AndroidTrait.SparkHandler.active[key])
    AndroidTrait.SparkHandler.active[key] = nil
    return true
end

function AndroidTrait.SparkHandler.toggle(targ, isOn, duration, frameSpeed, offsetX, offsetY, rotation, randomRotation, seed, blankFrequency)
    if isOn == false then return AndroidTrait.SparkHandler.stop(targ) end
    return AndroidTrait.SparkHandler.start(targ, duration, frameSpeed, offsetX, offsetY, rotation, randomRotation, seed, blankFrequency)
end

function AndroidTrait.SparkHandler.render()
    if not isIngameState() then return end
    local now = getTimestampMs()
    for key, data in pairs(AndroidTrait.SparkHandler.active) do
        local pl = getPlayer()
        local canSee = data.targ and pl and (data.targ == pl or (pl.CanSee and pl:CanSee(data.targ)))
        if not data.targ or not data.targ:getSquare() or now >= data.endTime then
            AndroidTrait.SparkHandler.removeTag(data)
            AndroidTrait.SparkHandler.removeLight(data)
            AndroidTrait.SparkHandler.active[key] = nil
        elseif canSee then
            local frame = math.floor((now - data.startTime) / data.frameSpeed)
            if AndroidTrait.SparkHandler.isBlankFrame(data.seed, frame, data.blankFrequency) then
                AndroidTrait.SparkHandler.setTag(data, nil)
            else
                local index = AndroidTrait.SparkHandler.getFrameIndex(data.seed, frame)
                AndroidTrait.SparkHandler.setTag(data, index)
                if data.texture then
                    local imageSize = AndroidTrait.SparkHandler.imageSize
                    local screenX, screenY = AndroidTrait.SparkHandler.getScreenPos(data.targ, data.offsetY)
                    getRenderer():render(data.texture, screenX + data.offsetX - (imageSize / 2), screenY - imageSize, imageSize, imageSize, 1, 1, 1, 1, nil)
                end
            end
        end
    end
end

Events.OnPostRender.Remove(AndroidTrait.SparkHandler.render)
Events.OnPostRender.Add(AndroidTrait.SparkHandler.render)

function AndroidTrait.SparkHandler.onServerCommand(module, command, args)
    if module ~= AndroidTrait.SparkHandler.module or command ~= AndroidTrait.SparkHandler.command or not args then return end
    local targ = args.targID and getPlayerByOnlineID(tonumber(args.targID)) or nil
    if not targ then return end
    AndroidTrait.SparkHandler.start(targ, args.duration, args.frameSpeed, args.offsetX, args.offsetY, args.rotation, args.randomRotation, args.seed, args.blankFrequency)
end
Events.OnServerCommand.Remove(AndroidTrait.SparkHandler.onServerCommand)
Events.OnServerCommand.Add(AndroidTrait.SparkHandler.onServerCommand)

function AndroidTrait.SparkHandler.request(targ, duration, frameSpeed, offsetX, offsetY, rotation, randomRotation, blankFrequency)
    targ = targ or getPlayer()
    if not targ then return end
    local args = {
        duration = duration,
        frameSpeed = frameSpeed,
        offsetX = offsetX,
        offsetY = offsetY,
        rotation = rotation,
        randomRotation = randomRotation == true,
        blankFrequency = blankFrequency
    }
    if isClient() then
        sendClientCommand(AndroidTrait.SparkHandler.module, AndroidTrait.SparkHandler.command, args)
        return
    end
    AndroidTrait.SparkHandler.start(targ, duration, frameSpeed, offsetX, offsetY, rotation, randomRotation, nil, blankFrequency)
end
