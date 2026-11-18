-- chess_rook: castle tower rook, front view, white piece, 16x16.
-- Three merlons on top (gaps between them), straight sturdy tower body,
-- shared base at y 12..14. Light from the top-left.
local s = px.sprite{
  w = 16, h = 16,
  palette = {
    {"outline", "#1a1c2c"},
    {"dk",      "#8b9bb4"},
    {"mid",     "#c0cbdc"},
    {"lt",      "#e4ebf2"},
    {"hl",      "#ffffff"},
  },
}

local piece = s:layer("piece")

-- shared base (do not change)
piece:fill(3, 13, 10, 2, "mid")   -- y 13..14
piece:fill(4, 12, 8, 1, "mid")    -- y 12

-- left half (x 0..7): merlons y 4..6, ledge y 7, tower body y 8..11
piece:fill(3, 4, 2, 3, "mid")     -- left merlon x 3..4
piece:fill(7, 4, 1, 3, "mid")     -- centre merlon x 7 (mirrors to 8)
piece:fill(3, 7, 5, 1, "mid")     -- wall ledge x 3..7
piece:fill(4, 8, 4, 4, "mid")     -- tower body x 4..7

piece:mirror("x")

-- shading after the mirror: shadow on right and bottom, lit left edges
for y = 4, 7 do piece:px(12, y, "dk") end
for y = 7, 12 do piece:px(11, y, "dk") end
piece:px(12, 13, "dk"); piece:px(12, 14, "dk")
for x = 3, 11 do piece:px(x, 14, "dk") end

piece:px(3, 5, "lt"); piece:px(3, 6, "lt")
for y = 8, 11 do piece:px(4, y, "lt") end

piece:px(3, 4, "hl"); piece:px(4, 4, "hl")

local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})

return s
