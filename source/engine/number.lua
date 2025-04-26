--[[
    used to set circle style
]]
Direction = {
    VERTICAL = "V",
    HORIZONTAL = "H",
}
--make it constant
Direction = protect(Direction)

AMPLITUDE = 1

class('Number', {
    value=nil,
    x=nil,
    y=nil,
    direction=nil,
    curX=nil,
    curY=nil,
    dir=true,
    scary=false,
}).extends(Object)

function Number:init(value,x,y, direction, scary)
    self.value=value
    self.x=x
    self.y=y
    self.curX=x
    self.curY=y
    self.direction=direction
    self.scary=scary

    if(self.direction == Direction.HORIZONTAL) then
        self.curX = self.curX + math.random(-2,2)
    else
        self.curY = self.curY + math.random(-2,2)
    end
end

function Number:update()
    if(self.direction == Direction.HORIZONTAL) then
        if(self.dir) then
            if(self.curX < self.x + AMPLITUDE) then
                self.curX = self.curX + 1
            else
                self.dir = not self.dir
                self.curX = self.curX - 1
            end
        else
            if(self.curX > self.x - AMPLITUDE) then
                self.curX = self.curX - 1
            else
                self.dir = not self.dir
                self.curX = self.curX + 1
            end
        end
    elseif(self.direction == Direction.VERTICAL) then
        if(self.dir) then
            if(self.curY < self.y + AMPLITUDE) then
                self.curY = self.curY + 1
            else
                self.dir = not self.dir
                self.curY = self.curY - 1
            end
        else
            if(self.curY > self.y - AMPLITUDE) then
                self.curY = self.curY - 1
            else
                self.dir = not self.dir
                self.curY = self.curY + 1
            end
        end
    end
end