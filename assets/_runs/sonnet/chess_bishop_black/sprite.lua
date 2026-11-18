-- chess_bishop: white bishop, 16x16, front view, light top-left, chess set piece.
local s = px.sprite{
  w = 16, h = 16,
  palette = {
    {"outline","#1a1c2c"}, {"dk","#1b1f33"}, {"mid","#3a4466"}, {"lt","#5a6988"}, {"hl","#8b9bb4"},
  },
}
local piece = s:layer("piece")
piece:fill(3, 13, 10, 2, "mid")
piece:fill(4, 12, 8, 1, "mid")
piece:fill(7, 3, 1, 2, "mid")      -- ball
piece:fill(6, 5, 2, 1, "mid")      -- mitre
piece:fill(5, 6, 3, 4, "mid")
piece:fill(6, 10, 2, 1, "mid")     -- neck
piece:fill(4, 11, 4, 1, "mid")     -- collar
piece:mirror("x")
-- shading
piece:px(7,3,"hl"); piece:px(6,5,"lt"); piece:px(5,6,"lt"); piece:px(5,7,"hl"); piece:px(5,8,"lt")
piece:px(6,9,"lt"); piece:px(4,11,"lt"); piece:px(3,13,"lt"); piece:px(3,14,"lt")
piece:px(8,4,"dk"); piece:px(9,5,"dk"); piece:px(10,6,"dk"); piece:px(10,7,"dk"); piece:px(10,8,"dk")
piece:px(9,9,"dk"); piece:px(8,10,"dk"); piece:px(11,11,"dk"); piece:px(8,11,"dk"); piece:px(9,11,"dk")
piece:px(11,12,"dk"); piece:fill(12,13,1,2,"dk"); piece:fill(4,14,8,1,"dk")
-- slit (after mirror)
piece:px(9,6,"outline"); piece:px(8,7,"outline"); piece:px(7,8,"outline")
local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})
return s
