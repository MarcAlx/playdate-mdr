--imports
import "CoreLibs/animation"
import "CoreLibs/graphics"
import "CoreLibs/object"
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'CoreLibs/ui'
import 'CoreLibs/math'

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

--game state
GameState = {
    SPLASHSCREEN = 0,
    SEARCH = 1,
    CATCH = 2,
    CATCHED = 3,
}
--make it constant
GameState = protect(GameState)

--grid related
WIDTH = 250
HEIGHT = 250
NB_ON_SCREEN_WIDTH = 25
NB_ON_SCREEN_HEIGHT= 9

SCREEN_CENTER = playdate.geometry.point.new(playdate.display.getWidth()/2,playdate.display.getHeight()/2)

--design
PADDING = 4
HEADER_HEIGHT = 27
GRID_HEIGHT = 180
FOLDER_HEIGHT = 219
OFFSET_STEP = 2
NUMBER_SPACING = 15
FOLDER_OPEN_AMPLITUDE = 20
RENDER_DELTA_IN_SECOND = 0.45
SCARY_RADIUS = 30

GRID_AREA = playdate.geometry.rect.new(15, HEADER_HEIGHT+2, 372, 150)
PROGRESS_BAR = playdate.geometry.rect.new(10, 8, 300, 17)

--folder
FOLDER_OFFSET = 30
FOLDER_SPACING = 15
FOLDER_PROGRESS_WIDTH  = 50
FOLDER_PROGRESS_HEIGHT = 14
FOLDER_1   = playdate.geometry.rect.new(FOLDER_OFFSET + (1 * FOLDER_SPACING) + (0*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_1 = playdate.geometry.rect.new(FOLDER_OFFSET + (1 * FOLDER_SPACING) + (0*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_1_TEXT = playdate.geometry.point.new(PROGRESS_1.x + PROGRESS_1.width/2.5, PROGRESS_1.y+2)
FOLDER_2   = playdate.geometry.rect.new(FOLDER_OFFSET + (2 * FOLDER_SPACING) + (1*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_2 = playdate.geometry.rect.new(FOLDER_OFFSET + (2 * FOLDER_SPACING) + (1*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_2_TEXT = playdate.geometry.point.new(PROGRESS_2.x + PROGRESS_2.width/2.5, PROGRESS_2.y+2)
FOLDER_3   = playdate.geometry.rect.new(FOLDER_OFFSET + (3 * FOLDER_SPACING) + (2*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_3 = playdate.geometry.rect.new(FOLDER_OFFSET + (3 * FOLDER_SPACING) + (2*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_3_TEXT = playdate.geometry.point.new(PROGRESS_3.x + PROGRESS_3.width/2.5, PROGRESS_3.y+2)
FOLDER_4   = playdate.geometry.rect.new(FOLDER_OFFSET + (4 * FOLDER_SPACING) + (3*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_4 = playdate.geometry.rect.new(FOLDER_OFFSET + (4 * FOLDER_SPACING) + (3*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_4_TEXT = playdate.geometry.point.new(PROGRESS_4.x + PROGRESS_4.width/2.5, PROGRESS_4.y+2)
FOLDER_5   = playdate.geometry.rect.new(FOLDER_OFFSET + (5 * FOLDER_SPACING) + (4*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + 4                              , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_5 = playdate.geometry.rect.new(FOLDER_OFFSET + (5 * FOLDER_SPACING) + (4*FOLDER_PROGRESS_WIDTH) , GRID_HEIGHT + (1*FOLDER_PROGRESS_HEIGHT) + 8 , FOLDER_PROGRESS_WIDTH , FOLDER_PROGRESS_HEIGHT)
PROGRESS_5_TEXT = playdate.geometry.point.new(PROGRESS_5.x + PROGRESS_5.width/2.5, PROGRESS_5.y+2)

refreshTimer = nil
offsetX = -200
offsetY = -200
folder1Progress = 0
folder2Progress = 0
folder3Progress = 0
folder4Progress = 0
folder5Progress = 0
scaryArea = nil
displayedArea = nil
displayedCenter = nil
state = GameState.SPLASHSCREEN
wasCrankdisplayed = false
scaryNumbers = {}
scaryLocation = nil
crankStart = 0
crankScary = 0
pickedFolder = 1
movePercentage = 0.0
bagPosition = nil
bagDestination = nil
possibleScore=0
scaryCenter= nil

--update progresss by applying possible score
function updateProgress()
    if(pickedFolder==1) then 
        folder1Progress += possibleScore
        folder1Progress = math.min(100, folder1Progress)
    elseif(pickedFolder==2) then 
        folder2Progress += possibleScore
        folder2Progress = math.min(100, folder2Progress)
    elseif(pickedFolder==3) then 
        folder3Progress += possibleScore
        folder3Progress = math.min(100, folder3Progress)
    elseif(pickedFolder==4) then 
        folder4Progress += possibleScore
        folder4Progress = math.min(100, folder4Progress)
    elseif(pickedFolder==5) then 
        folder5Progress += possibleScore
        folder5Progress = math.min(100, folder5Progress)
    end
end

--start new pick
function start()
    wasCrankdisplayed = false
    scaryNumbers = {}
    crankStart = 0
    crankScary = 0
    pickedFolder = 1
    movePercentage = 0.0
    bagPosition = nil
    bagDestination = nil
    possibleScore = 0
    
    if(scaryArea ~= nil) then
        for x = scaryArea.x, scaryArea.x+scaryArea.width do 
            for y = scaryArea.y, scaryArea.y+scaryArea.height do 
                numbers[x][y].scary = false
            end
        end
    end

    addScaryNumbers()
end

--reset game
function reset()
    folder1Progress = 0
    folder2Progress = 0
    folder3Progress = 0
    folder4Progress = 0
    folder5Progress = 0
    start()
end

--pick folder to fill
function pickFolder()
    pickedFolder = 1
    bagDestination = PROGRESS_1_TEXT
    if(folder1Progress==100) then 
        pickedFolder=2
        bagDestination = PROGRESS_2_TEXT
    end
    if(folder2Progress==100) then 
        pickedFolder=3
        bagDestination = PROGRESS_3_TEXT
    end
    if(folder3Progress==100) then 
        pickedFolder=4
        bagDestination = PROGRESS_4_TEXT
    end
    if(folder4Progress==100) then 
        pickedFolder=5
        bagDestination = PROGRESS_5_TEXT
    end
end

--true if scary numbers are on screen
function areScaryNumbersOnScreen()
    return scaryArea~=il 
       and displayedArea~=nil
       and scaryArea:containsPoint(displayedCenter)
end

--add scary numbers
function addScaryNumbers()
    --create scary pattern
    local scaryWidth = math.random(2, 4)
    local scaryHeight = math.random(2, 4)
    local lowerX = math.random(10, WIDTH - scaryWidth)
    local lowerY = math.random(10, HEIGHT - scaryHeight)
    --print(lowerX.." "..lowerY)
    scaryArea = playdate.geometry.rect.new(lowerX, lowerY, scaryWidth, scaryHeight) 
    generateScaryPattern(numbers, lowerX, lowerY, lowerX + scaryWidth, lowerY + scaryHeight, 0.7)
    scaryLocation = playdate.geometry.point.new((lowerX+(scaryWidth/1.5)) * NUMBER_SPACING, (lowerY ) * NUMBER_SPACING)
    prepareScaryNumbers()
    pickFolder()

    possibleScore = 0
    for i = 1, #scaryNumbers do
        possibleScore+=scaryNumbers[i].value
    end
end

function prepareScaryNumbers()
    local lastx = scaryArea.width+scaryArea.x
    local lasty = scaryArea.height+scaryArea.y

    --first line
    for x = scaryArea.x, lastx do 
        for y = scaryArea.y, lasty do 
            if(numbers[x][y].scary) then 
                table.insert(scaryNumbers, 
                             Number(numbers[x][y].value, 
                             scaryLocation.x-15+math.random(-15,15),
                             scaryLocation.y-90+math.random(-15,15),
                                    Direction.HORIZONTAL))
            end
        end
    end
end

-- unused
function identifyScaryBorder() 
    local lastx = scaryArea.width+scaryArea.x
    local lasty = scaryArea.height+scaryArea.y

    --first line
    for i = scaryArea.x, lastx do 
        print(numbers[i][scaryArea.y].value)
    end

    --right most col (exept first line)
    for j = scaryArea.y+1, lasty do 
        print(numbers[lastx][j].value)
    end

    --bottom row (exept last col)
    for i = lastx-1, scaryArea.x, -1 do 
        print(numbers[i][lasty].value)
    end

    --first col (exept first and last row)
    for j = lasty-1, scaryArea.y+1, -1 do 
        print(numbers[scaryArea.x][j].value)
    end
end

-- create scary pattern in given number matrix
function generateScaryPattern(matrix, x1, y1, x2, y2, density)
    density = density or 0.7
    scaryNumbers = {}
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
                numbers[i][j] = Number(math.random(0, 9), i*NUMBER_SPACING, j*NUMBER_SPACING, Direction.HORIZONTAL)
            else
                numbers[i][j] = Number(math.random(0, 9), i*NUMBER_SPACING, j*NUMBER_SPACING, Direction.VERTICAL)
            end
        end
    end
    addScaryNumbers()
end

--update display area
function updateDisplayedArea()
    displayedArea = playdate.geometry.rect.new(math.floor(((-offsetX)/(NUMBER_SPACING))),
                                               math.floor(((-offsetY)/(NUMBER_SPACING))),
                                               NB_ON_SCREEN_WIDTH,
                                               NB_ON_SCREEN_HEIGHT)
    displayedCenter =  playdate.geometry.point.new(displayedArea.x+displayedArea.width/2, displayedArea.y+displayedArea.height/2)
   -- print(displayedArea.x .. " " .. displayedArea.y)
end

--draw number grid, considering input offset
function drawGrid(oX, oY)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(GRID_AREA)
    playdate.graphics.setDrawOffset(oX, oY)
    gfx.setScreenClipRect(GRID_AREA)
    for i = displayedArea.x+1, displayedArea.x+1+displayedArea.width do
        for j = displayedArea.y+1, displayedArea.y+1+displayedArea.height do
            if(numbers[i][j].scary and (state == GameState.CATCH or state == GameState.CATCHED) and crankScary > 1) then
                --do nothing
            elseif(numbers[i][j].scary and (state == GameState.SEARCH or state == GameState.CATCH)) then
                gfx.setFont(GameAssets.LARGE_FONT)
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                gfx.drawText(numbers[i][j].value, numbers[i][j].curX + PADDING*2, numbers[i][j].curY + HEADER_HEIGHT)
            else
                gfx.setFont(GameAssets.NORMAL_FONT)
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                gfx.drawText(numbers[i][j].value, numbers[i][j].curX + PADDING*2, numbers[i][j].curY + HEADER_HEIGHT)
            end
        end
    end
    gfx.clearClipRect()
    playdate.graphics.setDrawOffset(0,0)
end

--draw folders
function drawFolders()
    gfx.setFont(GameAssets.NORMAL_FONT)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0,GRID_HEIGHT,playdate.display.getWidth(),GRID_HEIGHT)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText("O1", FOLDER_1.x + FOLDER_1.width/2.5, FOLDER_1.y+2)
    gfx.drawText("O2", FOLDER_2.x + FOLDER_2.width/2.5, FOLDER_2.y+2)
    gfx.drawText("O3", FOLDER_3.x + FOLDER_3.width/2.5, FOLDER_3.y+2)
    gfx.drawText("O4", FOLDER_4.x + FOLDER_4.width/2.5, FOLDER_4.y+2)
    gfx.drawText("O5", FOLDER_5.x + FOLDER_5.width/2.5, FOLDER_5.y+2)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawLine(PADDING,GRID_HEIGHT,playdate.display.getWidth()-(2*PADDING)+2,GRID_HEIGHT)
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
end

--draw folder open according to picked one
function drawOpenFolder()
    if(state == GameState.CATCHED) then 
        gfx.setLineWidth(3)
        gfx.setColor(gfx.kColorWhite)
        if(pickedFolder==1) then 
            gfx.drawLine(FOLDER_1.x                      , FOLDER_1.y, FOLDER_1.x-FOLDER_OPEN_AMPLITUDE                      , FOLDER_1.y-FOLDER_OPEN_AMPLITUDE)
            gfx.drawLine(FOLDER_1.x+FOLDER_PROGRESS_WIDTH, FOLDER_1.y, FOLDER_1.x+FOLDER_PROGRESS_WIDTH+FOLDER_OPEN_AMPLITUDE, FOLDER_1.y-FOLDER_OPEN_AMPLITUDE)
        elseif(pickedFolder==2) then 
            gfx.drawLine(FOLDER_2.x                      , FOLDER_2.y, FOLDER_2.x-FOLDER_OPEN_AMPLITUDE                      , FOLDER_2.y-FOLDER_OPEN_AMPLITUDE)
            gfx.drawLine(FOLDER_2.x+FOLDER_PROGRESS_WIDTH, FOLDER_2.y, FOLDER_2.x+FOLDER_PROGRESS_WIDTH+FOLDER_OPEN_AMPLITUDE, FOLDER_2.y-FOLDER_OPEN_AMPLITUDE)
        elseif(pickedFolder==3) then 
            gfx.drawLine(FOLDER_3.x                      , FOLDER_3.y, FOLDER_3.x-FOLDER_OPEN_AMPLITUDE                      , FOLDER_3.y-FOLDER_OPEN_AMPLITUDE)
            gfx.drawLine(FOLDER_3.x+FOLDER_PROGRESS_WIDTH, FOLDER_3.y, FOLDER_3.x+FOLDER_PROGRESS_WIDTH+FOLDER_OPEN_AMPLITUDE, FOLDER_3.y-FOLDER_OPEN_AMPLITUDE)
        elseif(pickedFolder==4) then 
            gfx.drawLine(FOLDER_4.x                      , FOLDER_3.y, FOLDER_4.x-FOLDER_OPEN_AMPLITUDE                      , FOLDER_4.y-FOLDER_OPEN_AMPLITUDE)
            gfx.drawLine(FOLDER_4.x+FOLDER_PROGRESS_WIDTH, FOLDER_3.y, FOLDER_4.x+FOLDER_PROGRESS_WIDTH+FOLDER_OPEN_AMPLITUDE, FOLDER_4.y-FOLDER_OPEN_AMPLITUDE)
        elseif(pickedFolder==5) then 
            gfx.drawLine(FOLDER_5.x                      , FOLDER_5.y, FOLDER_5.x-FOLDER_OPEN_AMPLITUDE                      , FOLDER_5.y-FOLDER_OPEN_AMPLITUDE)
            gfx.drawLine(FOLDER_5.x+FOLDER_PROGRESS_WIDTH, FOLDER_5.y, FOLDER_5.x+FOLDER_PROGRESS_WIDTH+FOLDER_OPEN_AMPLITUDE, FOLDER_5.y-FOLDER_OPEN_AMPLITUDE)
        end
        gfx.setLineWidth(1)
    end
end

--draw screen borders
function drawScreenCorner()
    gfx.drawRoundRect(PADDING,PADDING,playdate.display.getWidth()-8,playdate.display.getHeight()-(2*PADDING),5)
end

--draw coordinates
function drawCoord()
    --bg
    gfx.fillRect(PADDING,FOLDER_HEIGHT,playdate.display.getWidth()-8, playdate.display.getHeight()-FOLDER_HEIGHT-(3*PADDING))
    gfx.fillRoundRect(PADDING,FOLDER_HEIGHT,playdate.display.getWidth()-8, playdate.display.getHeight()-FOLDER_HEIGHT-PADDING, 5)
    --text
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(150, 222, 120, 10)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText("0x" .. string.format("%x", offsetX) .. " : " .. "0x" .. string.format("%x", offsetY), 150, 222)
end

-- draw static ui shell
function drawShell() 
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

    --start folder
    drawFolders()

    --start coord
    --remove top round
    drawCoord()

    --screen corner
    drawScreenCorner()
end

-- render all numbers
function updateAllNumbers()
    --update visible numbers
    for i = displayedArea.x+1, displayedArea.x+1+displayedArea.width do
        for j = displayedArea.y+1, displayedArea.y+1+displayedArea.height do
            numbers[i][j]:update()
        end
    end
end

-- render all numbers
function updateNumbersInBag()
    --update visible numbers
    for i = 1, #scaryNumbers do
        scaryNumbers[i]:update()
    end
end

-- all progress bars
function drawProgress()
    gfx.setFont(GameAssets.NORMAL_FONT)
    local p = (folder1Progress+folder2Progress+folder3Progress+folder4Progress+folder5Progress)/5/100
    --progress
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(PROGRESS_BAR.x+1, PROGRESS_BAR.y+1, PROGRESS_BAR.width-2, PROGRESS_BAR.height-2)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(PROGRESS_BAR.x+1, PROGRESS_BAR.y+1, (p*PROGRESS_BAR.width)-2, PROGRESS_BAR.height-2)
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    gfx.drawText(p*100 .. "% Complete", 30, 10)
    
    --start folder
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(PROGRESS_1.x+1, PROGRESS_1.y+1, PROGRESS_1.width-2, PROGRESS_1.height-2)
    gfx.fillRect(PROGRESS_2.x+1, PROGRESS_2.y+1, PROGRESS_2.width-2, PROGRESS_2.height-2)
    gfx.fillRect(PROGRESS_3.x+1, PROGRESS_3.y+1, PROGRESS_3.width-2, PROGRESS_3.height-2)
    gfx.fillRect(PROGRESS_4.x+1, PROGRESS_4.y+1, PROGRESS_4.width-2, PROGRESS_4.height-2)
    gfx.fillRect(PROGRESS_5.x+1, PROGRESS_5.y+1, PROGRESS_5.width-2, PROGRESS_5.height-2)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(PROGRESS_1.x+1, PROGRESS_1.y+1, ((folder1Progress/100)*PROGRESS_1.width)-2, PROGRESS_1.height-2)
    gfx.fillRect(PROGRESS_2.x+1, PROGRESS_2.y+1, ((folder2Progress/100)*PROGRESS_2.width)-2, PROGRESS_2.height-2)
    gfx.fillRect(PROGRESS_3.x+1, PROGRESS_3.y+1, ((folder3Progress/100)*PROGRESS_3.width)-2, PROGRESS_3.height-2)
    gfx.fillRect(PROGRESS_4.x+1, PROGRESS_4.y+1, ((folder4Progress/100)*PROGRESS_4.width)-2, PROGRESS_4.height-2)
    gfx.fillRect(PROGRESS_5.x+1, PROGRESS_5.y+1, ((folder5Progress/100)*PROGRESS_5.width)-2, PROGRESS_5.height-2)
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    gfx.drawText(folder1Progress .. "%", PROGRESS_1_TEXT.x, PROGRESS_1_TEXT.y)
    gfx.drawText(folder2Progress .. "%", PROGRESS_2_TEXT.x, PROGRESS_2_TEXT.y)
    gfx.drawText(folder3Progress .. "%", PROGRESS_3_TEXT.x, PROGRESS_3_TEXT.y)
    gfx.drawText(folder4Progress .. "%", PROGRESS_4_TEXT.x, PROGRESS_4_TEXT.y)
    gfx.drawText(folder5Progress .. "%", PROGRESS_5_TEXT.x, PROGRESS_5_TEXT.y)
end

--look for input in order to adjust offset
function handleInput()

    if(state == GameState.SEARCH) then
        local newOx = offsetX
        local newOy = offsetY
        if playdate.buttonIsPressed(playdate.kButtonUp) then
            newOy = offsetY + OFFSET_STEP
        elseif playdate.buttonIsPressed(playdate.kButtonRight) then
            newOx = offsetX - OFFSET_STEP
        elseif playdate.buttonIsPressed(playdate.kButtonDown) then
            newOy = offsetY - OFFSET_STEP
        elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
            newOx = offsetX + OFFSET_STEP
        end

        -- prevent offscreen display

        if(((HEIGHT - NB_ON_SCREEN_HEIGHT) * NUMBER_SPACING * -1)+1 <= newOy and newOy <= 0) then 
            offsetY = newOy
        end
        if(((WIDTH  - NB_ON_SCREEN_WIDTH)  * NUMBER_SPACING * -1)+1 <= newOx and newOx <= 0) then 
            offsetX = newOx
        end
        
        updateDisplayedArea()
    elseif(state == GameState.CATCH) then
        crankScary = crankScary + math.abs(playdate.getCrankChange())
    elseif(state == GameState.CATCHED) then
        local change = playdate.getCrankChange()
        if(change > 0) then
            movePercentage += math.abs(change/4)/100
            movePercentage = math.min(1.0, movePercentage)
            moveBag(movePercentage)
        end 
    end
end

--draw bag number at position
function drawBagNumber(at)
    --border
    gfx.setColor(gfx.kColorWhite)
    gfx.drawArc(at.x,at.y, SCARY_RADIUS+1, 0, crankScary)
    --background
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(at, SCARY_RADIUS)
    --numbers
    for i = 1, #scaryNumbers do
        gfx.setFont(GameAssets.LARGE_FONT)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText(scaryNumbers[i].value, scaryNumbers[i].curX + PADDING*2, scaryNumbers[i].curY + HEADER_HEIGHT)
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

    GameAssets.LOGO:draw(0,0)

    state = GameState.SPLASHSCREEN

    gfx.setFont(GameAssets.NORMAL_FONT)

    updateDisplayedArea()

    --delay update to let startup logo display
    tmr.new(2000, function() 
        state = GameState.SEARCH

        start()
        
        --clear screen
        gfx.clear(gfx.kColorBlack)
        --start timers
        tmr.keyRepeatTimerWithDelay(0,300,updateAllNumbers)
        tmr.keyRepeatTimerWithDelay(0,300,updateNumbersInBag)
    end)
end

--return linear interpolation between two points
function lerp(p1, p2, t)
    return playdate.geometry.point.new(playdate.math.lerp(p1.x,p2.x, t),playdate.math.lerp(p1.y, p2.y, t))
end

--move bag
function moveBag(t) 
    local oldPos = bagPosition
    bagPosition = lerp(bagPosition, bagDestination, movePercentage)
    local deltaX = bagPosition.x - oldPos.x
    local deltaY = bagPosition.y - oldPos.y
    for i = 1, #scaryNumbers do
        scaryNumbers[i].curX += deltaX
        scaryNumbers[i].curY += deltaY
    end
end

--startup call
startup();

--[[
    Called every frame, add here your game logic
]]--
function playdate.update()
    --not splashscreen draw game UI
    if(state ~= GameState.SPLASHSCREEN) then
        --clear screen
        gfx.clear(gfx.kColorBlack) 
        drawShell()
        drawFolders()
        drawCoord()
        drawScreenCorner()
        drawProgress()
        drawGrid(offsetX, offsetY)
    
        if(movePercentage == 1.0) then
            updateProgress()
            state = GameState.SEARCH
            if((folder1Progress+folder2Progress+folder3Progress+folder4Progress+folder5Progress) >= 500) then
                reset()
            else
                start()
            end
        elseif(crankScary >= 360) then
            crankScary = 360
            state = GameState.CATCHED
        --check scary numbers
        elseif(areScaryNumbersOnScreen()) then  
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            playdate.ui.crankIndicator:draw()
            wasCrankdisplayed = true
            oldState = state
            state = GameState.CATCH
            if(state ~= oldState) then
                crankStart = playdate.getCrankPosition()
                crankScary = 1
                movePercentage = 0.0
                bagPosition = SCREEN_CENTER
            end
        else
            --prevent move when scary are on screen
            state = GameState.SEARCH
        end

        if(state == GameState.CATCH and crankScary > 1) then 
            drawBagNumber(bagPosition)
        elseif(state == GameState.CATCHED) then
            drawBagNumber(bagPosition)
        end

        drawOpenFolder()

        handleInput()
    end

    --playdate.drawFPS(0,0)
         
    --update all sprites
    gfx.sprite.update()
    --update all timers
    tmr.updateTimers()
end