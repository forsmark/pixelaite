-- chess_rook: white rook, 16x16 front view, light top-left, chess set piece.
local s = px.sprite{
  w = 16, h = 16,
  palette = {
    {"outline","#1a1c2c"}, {"dk","#8b9bb4"}, {"mid","#c0cbdc"}, {"lt","#e4ebf2"}, {"hl","#ffffff"},
  },
}
local piece = s:layer("piece")
piece:fill(3, 13, 10, 2, "mid")
piece:fill(4, 12, 8, 1, "mid")
-- left half
piece:fill(3, 4, 2, 2, "mid")    -- merlon left
piece:fill(7, 4, 1, 2, "mid")    -- merlon center (mirrors to 7..8)
piece:fill(3, 6, 5, 2, "mid")    -- rim
piece:fill(5, 8, 3, 4, "mid")    -- body (waist)
piece:mirror("x")
-- shading
piece:fill(3, 4, 1, 4, "lt")     -- lit left edge of merlon/rim
piece:fill(5, 8, 1, 4, "lt")
piece:fill(3, 13, 1, 2, "lt")
piece:fill(12, 6, 1, 2, "dk")    -- shadow right
piece:fill(11, 4, 2, 2, "dk")
piece:fill(10, 8, 1, 4, "dk")
piece:fill(12, 13, 1, 2, "dk")
piece:fill(4, 14, 8, 1, "dk")
piece:fill(5, 6, 6, 1, "dk")     -- gap floor shade under battlements
piece:fill(4, 7, 8, 1, "mid")
piece:px(3, 7, "lt")
piece:fill(5, 11, 6, 1, "dk")
piece:px(3, 4, "hl") piece:px(3, 5, "hl")
piece:px(5, 8, "hl") piece:px(5, 9, "hl")
local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})
return s
