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
--   ▫ Discord  ꞉   glytch3r                                  --
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


function AndroidTrait.init()
	local pl = getPlayer()
    if not pl or not AndroidTrait.hasTrait(pl) then return end
	local md = pl:getModData()
	if md['AndroidTraitData'] == nil then
		AndroidTrait.initTrait()
	end
	
	if md['AndroidTraitData']["CD"] > 0 then
		local cd = md['AndroidTraitData']["CD"]
		md['AndroidTraitData']["CD"] = math.max(0, cd - 1)
	end
end


Events.EveryHours.Remove(AndroidTrait.init)
Events.EveryHours.Add(AndroidTrait.init)

function AndroidTrait.initTrait()
    local RecalCD = SandboxVars.AndroidTrait.RecalCD
    local pl = getPlayer()
    if not pl or not AndroidTrait.hasTrait(pl) then return end

    local data = pl:getModData()['AndroidTraitData'] or {}
	
    if not data.Energy then
        data.Energy = 1
    end
    if not data.CD then
        data.CD = RecalCD
    end
    
    pl:getModData()['AndroidTraitData'] = data
    AndroidTrait.doAutoOff(pl)
end

Events.OnCreatePlayer.Remove(AndroidTrait.initTrait)
Events.OnCreatePlayer.Add(AndroidTrait.initTrait)
