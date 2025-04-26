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

WIDTH = 250
HEIGHT = 100
PADDING = 4
HEADER_HEIGHT = 27
GRID_HEIGHT = 180
FOLDER_HEIGHT = 219

GRID_AREA = playdate.geometry.rect.new(15, HEADER_HEIGHT+2, 372, 150)
PROGRESS_BAR = playdate.geometry.rect.new(12, 9, 300, 14)

FOLDER_OFFSET = 30
FOLDER_SPACING = 15
FOLDER_PROGRESS_WIDTH  = 50
FOLDER_PROGRESS_HEIGHT = 14
FOLDER_1   = playdate.geometry.rect.new(FOLDER_OFFSET + (1 * FOLDER_SPACING) + (0*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_1 = playdate.geometry.rect.new(FOLDER_OFFSET + (1 * FOLDER_SPACING) + (0*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
FOLDER_2   = playdate.geometry.rect.new(FOLDER_OFFSET + (2 * FOLDER_SPACING) + (1*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_2 = playdate.geometry.rect.new(FOLDER_OFFSET + (2 * FOLDER_SPACING) + (1*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
FOLDER_3   = playdate.geometry.rect.new(FOLDER_OFFSET + (3 * FOLDER_SPACING) + (2*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_3 = playdate.geometry.rect.new(FOLDER_OFFSET + (3 * FOLDER_SPACING) + (2*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
FOLDER_4   = playdate.geometry.rect.new(FOLDER_OFFSET + (4 * FOLDER_SPACING) + (3*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_4 = playdate.geometry.rect.new(FOLDER_OFFSET + (4 * FOLDER_SPACING) + (3*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
FOLDER_5   = playdate.geometry.rect.new(FOLDER_OFFSET + (5 * FOLDER_SPACING) + (4*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_5 = playdate.geometry.rect.new(FOLDER_OFFSET + (5 * FOLDER_SPACING) + (4*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)

offsetX = -200
offsetY = -200
progress = 0
frolder1Progress = 0
frolder2Progress = 0
frolder3Progress = 0
frolder4Progress = 0
frolder5Progress = 0

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

function drawGrid(oX, oY)
    playdate.graphics.setDrawOffset(offsetX, offsetY)
    gfx.setScreenClipRect(GRID_AREA)
    for i = 1, WIDTH do
        for j = 1, HEIGHT do
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText(numbers[i][j].value, numbers[i][j].curX + PADDING, numbers[i][j].curY + HEADER_HEIGHT)
        end
    end
    gfx.clearClipRect()
    playdate.graphics.setDrawOffset(0,0)
end

function render()
    --update numbers
    for i = 1, WIDTH do
        for j = 1, HEIGHT do
            numbers[i][j]:update()
        end
    end   
    
    gfx.clear(gfx.kColorBlack)

    --progress
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(progress .. "% Complete", 30, 11)
    gfx.drawRect(PROGRESS_BAR)

    gfx.setColor(gfx.kColorWhite)
    --header
    gfx.drawLine(PADDING,HEADER_HEIGHT,playdate.display.getWidth()-(2*PADDING)+2,HEADER_HEIGHT)
    
    --grid
    drawGrid(offsetX, offsetY)
    
    --start folder
    gfx.drawLine(PADDING,GRID_HEIGHT,playdate.display.getWidth()-(2*PADDING)+2,GRID_HEIGHT)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawRect(FOLDER_1)
    gfx.drawRect(PROGRESS_1)
    gfx.drawRect(FOLDER_2)
    gfx.drawRect(PROGRESS_2)
    gfx.drawRect(FOLDER_3)
    gfx.drawRect(PROGRESS_3)
    gfx.drawRect(FOLDER_4)
    gfx.drawRect(PROGRESS_4)
    gfx.drawRect(FOLDER_5)
    gfx.drawRect(PROGRESS_5)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(GameAssets.NORMAL_FONT)
    gfx.drawText("O1", FOLDER_1.x + FOLDER_1.width/2.5, FOLDER_1.y+2)
    gfx.drawText("O2", FOLDER_2.x + FOLDER_2.width/2.5, FOLDER_2.y+2)
    gfx.drawText("O3", FOLDER_3.x + FOLDER_3.width/2.5, FOLDER_3.y+2)
    gfx.drawText("O4", FOLDER_4.x + FOLDER_4.width/2.5, FOLDER_4.y+2)
    gfx.drawText("O5", FOLDER_5.x + FOLDER_5.width/2.5, FOLDER_5.y+2)
    gfx.drawText(frolder1Progress .. "%", PROGRESS_1.x + PROGRESS_1.width/2.5, PROGRESS_1.y+2)
    gfx.drawText(frolder2Progress .. "%", PROGRESS_2.x + PROGRESS_2.width/2.5, PROGRESS_2.y+2)
    gfx.drawText(frolder3Progress .. "%", PROGRESS_3.x + PROGRESS_3.width/2.5, PROGRESS_3.y+2)
    gfx.drawText(frolder4Progress .. "%", PROGRESS_4.x + PROGRESS_4.width/2.5, PROGRESS_4.y+2)
    gfx.drawText(frolder5Progress .. "%", PROGRESS_5.x + PROGRESS_5.width/2.5, PROGRESS_5.y+2)

    --start coord
    --remove top round
    gfx.fillRect(PADDING,FOLDER_HEIGHT,playdate.display.getWidth()-8, playdate.display.getHeight()-FOLDER_HEIGHT-(3*PADDING))
    gfx.fillRoundRect(PADDING,FOLDER_HEIGHT,playdate.display.getWidth()-8, playdate.display.getHeight()-FOLDER_HEIGHT-PADDING, 5)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText("0x" .. string.format("%x", offsetX) .. " : " .. "0x" .. string.format("%x", offsetY), 150, 222)

    --screen corner
    gfx.drawRoundRect(PADDING,PADDING,playdate.display.getWidth()-8,playdate.display.getHeight()-(2*PADDING),5)
    
end

function handleInput()
    if playdate.buttonIsPressed( playdate.kButtonUp ) then
        offsetY-=1
    elseif playdate.buttonIsPressed( playdate.kButtonRight ) then
        offsetX+=1
    elseif playdate.buttonIsPressed( playdate.kButtonDown ) then
        offsetY+=1
    elseif playdate.buttonIsPressed( playdate.kButtonLeft ) then
        offsetX-=1
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

    timer = tmr.keyRepeatTimerWithDelay(0,600,render)
    timer = tmr.keyRepeatTimerWithDelay(0,200,handleInput)
end

--startup call
startup();
--[[
    Called every frame, add here your game logic
]]--
function playdate.update()
    --update all sprites
    gfx.sprite.update()
    --update all timers
    tmr.updateTimers()
end