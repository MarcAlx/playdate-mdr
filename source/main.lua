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

refreshTimer = nil

WIDTH = 250
HEIGHT = 100
PADDING = 4
HEADER_HEIGHT = 27
GRID_HEIGHT = 180
FOLDER_HEIGHT = 219
OFFSET_STEP = 2

GRID_AREA = playdate.geometry.rect.new(15, HEADER_HEIGHT+2, 372, 150)
PROGRESS_BAR = playdate.geometry.rect.new(10, 8, 300, 17)

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

-- create scary pattern in given number matrix
function createScaryNumbers(matrix, x1, y1, x2, y2, density)
    density = density or 0.7
    --identify scary
    for y = y1, y2 do
        for x = x1, x2 do
            if math.random() < density then
                matrix[x][y].scary = true
            end
        end
    end

    --prevent hole
    for y = y1, y2 do
        for x = x1, x2 do
            --number is not scary
            if matrix[x][y].scary == false then
                local finalScary = false
                local count = 0
                --look neighbor
                for a = x-1, x+1 do
                    for b = y-1, y+1 do
                        if(matrix[a][b].scary) then
                            count = count + 1
                        end
                    end
                end

                -- more than 4 scary neighbor -> should be scary
                if(count > 4) then 
                    matrix[x][y].scary = true
                end
            end
        end
    end
end

numbers= {}
--init number matrix
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

    --create scary pattern
    local scaryWidth = math.random(2, 4)
    local scaryHeight = math.random(2, 4)
    local lowerX = math.random(10, WIDTH - scaryWidth)
    local lowerY = math.random(10, HEIGHT - scaryHeight)
    createScaryNumbers(numbers, lowerX, lowerY, lowerX + scaryWidth, lowerY + scaryHeight, 0.7)
end

--draw number grid, considering input offset
function drawGrid(oX, oY)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(GRID_AREA)
    playdate.graphics.setDrawOffset(offsetX, offsetY)
    gfx.setScreenClipRect(GRID_AREA)
    for i = 1, WIDTH do
        for j = 1, HEIGHT do
            if(numbers[i][j].scary) then
                gfx.setFont(GameAssets.LARGE_FONT)
            else
                gfx.setFont(GameAssets.NORMAL_FONT)
            end
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText(numbers[i][j].value, numbers[i][j].curX + PADDING, numbers[i][j].curY + HEADER_HEIGHT)
        end
    end
    gfx.clearClipRect()
    playdate.graphics.setDrawOffset(0,0)
end

-- draw static ui shell
function drawShell() 
    --playdate.drawFPS(190,0)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(GRID_AREA)

    --progress
    gfx.setColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawRect(PROGRESS_BAR)

    gfx.setColor(gfx.kColorWhite)
    --header
    gfx.drawLine(PADDING,HEADER_HEIGHT,playdate.display.getWidth()-(2*PADDING)+2,HEADER_HEIGHT)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    GameAssets.LOGO_SMALL:draw(PROGRESS_BAR.width+PROGRESS_BAR.x+45, 6)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

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

    gfx.drawText("O1", FOLDER_1.x + FOLDER_1.width/2.5, FOLDER_1.y+2)
    gfx.drawText("O2", FOLDER_2.x + FOLDER_2.width/2.5, FOLDER_2.y+2)
    gfx.drawText("O3", FOLDER_3.x + FOLDER_3.width/2.5, FOLDER_3.y+2)
    gfx.drawText("O4", FOLDER_4.x + FOLDER_4.width/2.5, FOLDER_4.y+2)
    gfx.drawText("O5", FOLDER_5.x + FOLDER_5.width/2.5, FOLDER_5.y+2)

    --start coord
    --remove top round
    gfx.fillRect(PADDING,FOLDER_HEIGHT,playdate.display.getWidth()-8, playdate.display.getHeight()-FOLDER_HEIGHT-(3*PADDING))
    gfx.fillRoundRect(PADDING,FOLDER_HEIGHT,playdate.display.getWidth()-8, playdate.display.getHeight()-FOLDER_HEIGHT-PADDING, 5)
    
    --screen corner
    gfx.drawRoundRect(PADDING,PADDING,playdate.display.getWidth()-8,playdate.display.getHeight()-(2*PADDING),5)

end

-- render UI
function render()
    --update numbers
    for i = 1, WIDTH do
        for j = 1, HEIGHT do
            numbers[i][j]:update()
        end
    end   
    
    --progress
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(progress .. "% Complete", 30, 10)
    
    --grid
    drawGrid(offsetX, offsetY)
    
    --start folder
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(frolder1Progress .. "%", PROGRESS_1.x + PROGRESS_1.width/2.5, PROGRESS_1.y+2)
    gfx.drawText(frolder2Progress .. "%", PROGRESS_2.x + PROGRESS_2.width/2.5, PROGRESS_2.y+2)
    gfx.drawText(frolder3Progress .. "%", PROGRESS_3.x + PROGRESS_3.width/2.5, PROGRESS_3.y+2)
    gfx.drawText(frolder4Progress .. "%", PROGRESS_4.x + PROGRESS_4.width/2.5, PROGRESS_4.y+2)
    gfx.drawText(frolder5Progress .. "%", PROGRESS_5.x + PROGRESS_5.width/2.5, PROGRESS_5.y+2)

    --start coord
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(150, 222, 120, 10)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText("0x" .. string.format("%x", offsetX) .. " : " .. "0x" .. string.format("%x", offsetY), 150, 222)

end

--look for input in order to adjust offset
function handleInput()
    if playdate.buttonIsPressed( playdate.kButtonUp ) then
        offsetY+=OFFSET_STEP
    elseif playdate.buttonIsPressed( playdate.kButtonRight ) then
        offsetX-=OFFSET_STEP
    elseif playdate.buttonIsPressed( playdate.kButtonDown ) then
        offsetY-=OFFSET_STEP
    elseif playdate.buttonIsPressed( playdate.kButtonLeft ) then
        offsetX+=OFFSET_STEP
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
    
    gfx.setFont(GameAssets.NORMAL_FONT)

    GameAssets.LOGO:draw(0,0)

    --delay update to let startup logo display
    tmr.new(2000, function() 
        gfx.clear(gfx.kColorBlack)
        drawShell()
        tmr.keyRepeatTimerWithDelay(1000,500,render)
        tmr.keyRepeatTimerWithDelay(0,150,handleInput)
    end)
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