local gfx  <const> = playdate.graphics

GameAssets = {
    SMALL_FONT  = gfx.font.new("assets/game/fonts/Nontendo/Nontendo-Light"),
    NORMAL_FONT = gfx.font.new("assets/game/fonts/Nontendo/Nontendo-Bold"),
    LARGE_FONT  = gfx.font.new("assets/game/fonts/Nontendo/Nontendo-Bold-2x"),
    LOGO        = gfx.image.new("assets/game/images/logo.png"),
    LOGO_SMALL  = gfx.image.new("assets/game/images/logo-small.png")
}

--make it constant
GameAssets = protect(GameAssets)