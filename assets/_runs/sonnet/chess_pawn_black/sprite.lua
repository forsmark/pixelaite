-- chess_pawn: white pawn, 16x16 front view, light top-left, chess set piece.
local s = px.sprite{
  w = 16, h = 16,
  palette = {
    {"outline","#1a1c2c"}, {"dk","#1b1f33"}, {"mid","#3a4466"}, {"lt","#5a6988"}, {"hl","#8b9bb4"},
  },
}
local piece = s:layer("piece")
piece:fill(3, 13, 10, 2, "mid")
piece:fill(4, 12, 8, 1, "mid")
-- head (left half)
piece:fill(6, 6, 2, 1, "mid")
piece:fill(5, 7, 3, 3, "mid")
-- neck, collar, body
piece:fill(6, 10, 2, 1, "mid")
piece:fill(4, 11, 4, 1, "mid")
piece:mirror("x")
-- shading
local function dk(...) for _, v in ipairs({...}) do piece:px(v[1], v[2], "dk") end end
dk({10,7},{10,8},{10,9},{9,9},{8,9},{9,6},{9,10},{8,10})
dk({9,11},{10,11},{11,11},{10,12},{11,12},{12,13},{12,13})
for x = 3, 12 do piece:px(x, 14, "dk") end
piece:px(5, 7, "lt"); piece:px(5, 8, "lt"); piece:px(4, 11, "lt"); piece:px(4, 12, "lt")
piece:px(6, 7, "hl"); piece:px(6, 8, "hl")
local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})
return s
