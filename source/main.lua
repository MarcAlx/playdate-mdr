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
HEIGHT = 10
PADDING = 4
HEADER_HEIGHT = 20
GRID_HEIGHT = 190
FOLDER_HEIGHT = 215

numbers= {}
function initNumbers()
    for i = 1, WIDTH do
        numbers[i] = {}
        for j = 1, HEIGHT do
            if(math.fmod(i,2) == 0) then 
                numbers[i][j] = Number(math.random(0, 9), i*15, j*15, Direction.HORIZONTAL)
            else
                numbers[i][j] = Number(math.random(0, 9), i*15, j*15, Direction.VERTICAL)
            end
        end
    end
end

function drawGrid()
    for i = 1, WIDTH do
        for j = 1, HEIGHT do
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText(numbers[i][j].value, numbers[i][j].curX + PADDING, numbers[i][j].curY + HEADER_HEIGHT)
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

    timer = tmr.keyRepeatTimerWithDelay(0,600,function ()
        for i = 1, WIDTH do
            for j = 1, HEIGHT do
                numbers[i][j]:update()
            end
        end   
        
        gfx.clear(gfx.kColorBlack)
        gfx.setColor(gfx.kColorWhite)
        --header
        gfx.drawLine(PADDING,HEADER_HEIGHT,playdate.display.getWidth()-(2*PADDING)+2,HEADER_HEIGHT)
        
        --grid
        drawGrid()
        
        --start folder
        gfx.drawLine(PADDING,GRID_HEIGHT,playdate.display.getWidth()-(2*PADDING)+2,GRID_HEIGHT)
        gfx.setColor(gfx.kColorWhite)

        --start coord
        --remove top round
        gfx.fillRect(PADDING,FOLDER_HEIGHT,playdate.display.getWidth()-8, playdate.display.getHeight()-FOLDER_HEIGHT-(3*PADDING))
        gfx.fillRoundRect(PADDING,FOLDER_HEIGHT,playdate.display.getWidth()-8, playdate.display.getHeight()-FOLDER_HEIGHT-PADDING, 5)
        
        --scrren corner
        gfx.drawRoundRect(PADDING,PADDING,playdate.display.getWidth()-8,playdate.display.getHeight()-(2*PADDING),5)
        
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