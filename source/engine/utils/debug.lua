local gfx  <const> = playdate.graphics

-- draw fps along metdata info
function drawDebugInfo()
	--gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    playdate.drawFPS(190,0)
    --gfx.setFont(GameAssets.SMALL_BOLD_FONT)
    gfx.drawLocalizedText(l10nKeys.creator, 40, 0)--use l10n to avoid having a wrong creator name due to _ char
    --gfx.drawText(playdate.metadata.name, 120, 0)
    --gfx.drawText(playdate.metadata.version, 300, 0)
end

local memoryInit = collectgarbage("count")*1024
local memoryUsed = memoryInit

--print memory info console, from : https://devforum.play.date/t/tracking-memory-usage-throughout-your-game/1132
function memoryCheck()
	local new <const> = collectgarbage("count")*1024
	local diff <const> = new - memoryUsed
	
	-- still making large numbers of allocations
	if diff > memoryInit then
		memoryUsed = new
		return
	end
	
	-- fine grained memory changes
	if diff > 0 then
		print(string.format("memory use\t+%dKB (%d bytes)", diff//1024, new - memoryInit))
	elseif diff < 0 then
		print(string.format("memory free\t%dKB (%d bytes)", diff//1024, new - memoryInit))
	end

	memoryUsed = new
end