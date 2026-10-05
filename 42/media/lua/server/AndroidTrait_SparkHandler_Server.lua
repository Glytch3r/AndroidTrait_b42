if isClient() then return end

AndroidTrait = AndroidTrait or {}
AndroidTrait.SparkHandler = AndroidTrait.SparkHandler or {}
AndroidTrait.SparkHandler.module = "AndroidTraitSparkHandler"
AndroidTrait.SparkHandler.command = "start"

function AndroidTrait.SparkHandler.clamp(num, min, max, default)
    num = tonumber(num)
    if not num then return default end
    return math.max(min, math.min(max, num))
end

function AndroidTrait.SparkHandler.onClientCommand(module, command, sender, args)
    if module ~= AndroidTrait.SparkHandler.module or command ~= AndroidTrait.SparkHandler.command or not sender then return end
    args = args or {}
    sendServerCommand(AndroidTrait.SparkHandler.module, AndroidTrait.SparkHandler.command, {
        targID = sender:getOnlineID(),
        duration = AndroidTrait.SparkHandler.clamp(args.duration, 0.05, 60, 1),
        frameSpeed = AndroidTrait.SparkHandler.clamp(args.frameSpeed, 0.016, 5, 0.1),
        offsetX = AndroidTrait.SparkHandler.clamp(args.offsetX, -512, 512, 0),
        offsetY = AndroidTrait.SparkHandler.clamp(args.offsetY, -512, 512, 0),
        rotation = AndroidTrait.SparkHandler.clamp(args.rotation, -3600, 3600, 0),
        randomRotation = args.randomRotation == true,
        blankFrequency = math.floor(AndroidTrait.SparkHandler.clamp(args.blankFrequency, 0, 20, 0)),
        seed = ZombRand(0, 2147483647)
    })
end
Events.OnClientCommand.Remove(AndroidTrait.SparkHandler.onClientCommand)
Events.OnClientCommand.Add(AndroidTrait.SparkHandler.onClientCommand)
