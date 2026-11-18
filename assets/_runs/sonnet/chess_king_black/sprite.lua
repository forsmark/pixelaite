-- chess_king: white king, front view, 16x16, light from top-left, set piece for a chess game.
local s = px.sprite{
  w = 16, h = 16,
  palette = {
    {"outline","#1a1c2c"}, {"dk","#1b1f33"}, {"mid","#3a4466"}, {"lt","#5a6988"}, {"hl","#8b9bb4"},
  },
}
local piece = s:layer("piece")
piece:fill(3, 13, 10, 2, "mid")
piece:fill(4, 12, 8, 1, "mid")
-- cross
piece:fill(7, 2, 1, 3, "mid")
piece:fill(5, 3, 3, 1, "mid")
-- crown
piece:px(3, 5, "mid"); piece:fill(5, 5, 3, 1, "mid")
piece:fill(3, 6, 5, 2, "mid")
piece:fill(4, 8, 4, 1, "mid")
-- body
piece:fill(5, 9, 3, 2, "mid")
piece:fill(4, 11, 4, 1, "mid")
piece:mirror("x")
-- shading (light top-left)
piece:fill(4, 14, 8, 1, "dk")
piece:px(11, 13, "dk")
piece:fill(10, 12, 2, 1, "dk")
piece:fill(10, 9, 1, 3, "dk")
piece:fill(6, 8, 4, 1, "dk")
piece:fill(11, 6, 1, 2, "dk")
piece:px(10, 7, "dk")
piece:px(12, 6, "dk")
piece:fill(8, 3, 1, 2, "dk")
piece:px(9, 3, "dk")
-- lit left edges
piece:px(3, 13, "lt"); piece:px(4, 12, "lt")
piece:fill(5, 9, 1, 3, "lt")
piece:fill(3, 6, 1, 2, "lt")
piece:px(3, 5, "lt")
piece:px(4, 8, "lt")
piece:px(5, 3, "lt"); piece:px(7, 2, "lt")
piece:px(3, 6, "hl"); piece:px(7, 2, "hl"); piece:px(5, 9, "hl")
local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})
return s
