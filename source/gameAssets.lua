local gfx  <const> = playdate.graphics

GameAssets = {
    SMALL_FONT            = gfx.font.new("assets/game/fonts/Nontendo/Nontendo-Light"),
    NORMAL_FONT            = gfx.font.new("assets/game/fonts/Nontendo/Nontendo-Bold"),
    LARGE_FONT             = gfx.font.new("assets/game/fonts/Nontendo/Nontendo-Bold-2x")
}

--make it constant
GameAssets = protect(GameAssets)