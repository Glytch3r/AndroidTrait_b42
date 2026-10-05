
AndroidTrait = AndroidTrait or {}
AndroidTrait.Highlight = AndroidTrait.Highlight or {}
AndroidTrait.Highlight.objs = AndroidTrait.Highlight.objs or setmetatable({}, { __mode = "k" })

function AndroidTrait.Highlight.apply(obj)
    local pl = getPlayer()
    if not obj or not pl then return false end
    if not instanceof(obj, "IsoObject") then return false end

    local plNum = pl:getPlayerNum()

    obj:setHighlightColor(plNum, 0, 0.3, 1, 1)
    obj:setHighlighted(plNum, true, false)
    obj:setOutlineHighlightCol(plNum, 0, 0.3, 1, 1)
    obj:setOutlineHighlight(plNum, true)

    return true
end

function AndroidTrait.Highlight.set(obj)
    if not AndroidTrait.Highlight.apply(obj) then return false end
    AndroidTrait.Highlight.objs[obj] = true
    return true
end

function AndroidTrait.Highlight.clear(obj)
    local pl = getPlayer()
    if not obj or not pl then return false end
    if not instanceof(obj, "IsoObject") then return false end

    local plNum = pl:getPlayerNum()

    obj:setHighlighted(plNum, false, false)
    obj:setOutlineHighlight(plNum, false)
    AndroidTrait.Highlight.objs[obj] = nil

    return true
end


function AndroidTrait.Highlight.clearAll()
    for obj in pairs(AndroidTrait.Highlight.objs) do
        AndroidTrait.Highlight.clear(obj)
    end
end

function AndroidTrait.Highlight.update()
    for obj in pairs(AndroidTrait.Highlight.objs) do
        if obj:getSquare() then
            AndroidTrait.Highlight.apply(obj)
        else
            AndroidTrait.Highlight.objs[obj] = nil
        end
    end
end
--Events.OnTick.Remove(AndroidTrait.Highlight.update)
--Events.OnTick.Add(AndroidTrait.Highlight.update)
