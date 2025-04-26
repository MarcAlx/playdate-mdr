local gfx  <const> = playdate.graphics

GameAssets = {
    NORMAL_FONT            = gfx.font.new("assets/game/fonts/Nontendo/Nontendo-Bold"),
    LARGE_FONT             = gfx.font.new("assets/game/fonts/Nontendo/Nontendo-Bold-2x")
}

--make it constant
GameAssets = protect(GameAssets)