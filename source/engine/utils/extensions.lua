--Add here any extension to existing classes/modules...

--[[
    Add a forefround drawing callback
    /!\ must be called only once, multiple call results in multiple fg sprite added
    inspired from : https://sdk.play.date/1.9.3/#f-graphics.sprite.setBackgroundDrawingCallback
]]
function playdate.graphics.sprite.setForegroundDrawingCallback(drawCallback)
    local fgsprite = playdate.graphics.sprite.new()
    fgsprite:setSize(playdate.display.getSize())
    fgsprite:setCenter(0, 0)
    fgsprite:moveTo(0, 0)
    fgsprite:setZIndex(32767)
    fgsprite:setIgnoresDrawOffset(true)
    fgsprite:setUpdatesEnabled(false)
    fgsprite.draw = drawCallback
    fgsprite:add()
    return fgsprite
end

--merge table t1 with t2
function table.merge(t1, t2)
    for _,v in ipairs(t2) do
       table.insert(t1, v)
    end 
    return t1
 end