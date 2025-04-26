--imports
import "CoreLibs/animation"
import "CoreLibs/graphics"
import "CoreLibs/object"
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

import "engine/utils/debug"
import "engine/utils/luaUtils"
import "engine/utils/extensions"

import "engine/number"

import "gameAssets"
import "gameConfig"
import "l10n"

--shorthands
local gfx  <const> = playdate.graphics
local disp  <const> = playdate.display
local tmr  <const> = playdate.timer

--to handle game state
local stateManager = nil

--settings manager for general access
settingsManager = nil

refreshTimer = nil

WIDTH = 25
HEIGHT = 14

numbers= {}
function initNumbers()
    for i = 1, WIDTH do
        numbers[i] = {}
        for j = 1, HEIGHT do
            local dir = math.random(0, 1)
            if(dir == 0) then 
                numbers[i][j] = Number(math.random(0, 9), i*15, j*15, Direction.HORIZONTAL)
            elseif(dir == 1) then 
                numbers[i][j] = Number(math.random(0, 9), i*15, j*15, Direction.VERTICAL)
            end
        end
    end
end

function drawGrid()
    for i = 1, WIDTH do
        for j = 1, HEIGHT do
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText(numbers[i][j].value, numbers[i][j].curX, numbers[i][j].curY)
        end
    end
end

--[[
    startup function called once at the begining
]]--
function startup()
    print("startup")

    --init random seed
    math.randomseed(playdate.getSecondsSinceEpoch())

    initNumbers()

    --init stateManager
    --stateManager = StateManager()
    
    
    gfx.setFont(GameAssets.NORMAL_FONT)
    --gfx.drawText("hello", 0, 0)

    timer = tmr.keyRepeatTimerWithDelay(0,300,function ()
        gfx.clear(gfx.kColorBlack)
        for i = 1, WIDTH do
            for j = 1, HEIGHT do
                numbers[i][j]:update()
            end
        end      
        drawGrid()
    end)
end

--startup call
startup();
--[[
    Called every frame, add here your game logic
]]--
function playdate.update()
    --update according to game state
    --stateManager:update()
    --update all sprites
    gfx.sprite.update()
    --update all timers
    tmr.updateTimers()
end