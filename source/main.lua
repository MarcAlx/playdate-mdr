--imports
import "CoreLibs/animation"
import "CoreLibs/graphics"
import "CoreLibs/object"
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

import "engine/utils/debug"
import "engine/utils/luaUtils"
import "engine/utils/extensions"

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

function drawGrid()
    for i = 1, 15 do
        for j = 1, 15 do
            gfx.drawText(math.random(0, 9), i*15, j*15)
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

    --init stateManager
    --stateManager = StateManager()

    gfx.setFont(GameAssets.NORMAL_FONT)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText("hello", 0, 0)

    timer = tmr.keyRepeatTimerWithDelay(0,300,function ()
        print("ok")
        gfx.clear(gfx.kColorWhite)
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