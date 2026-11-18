-- chess_king: white front-view king chess piece, 16x16. Tallest piece: a small cross
-- (2 px stem on the x=7/8 axis) on top of a crown band, a neck, and a body that widens
-- into the shared base. Light from the top-left. Game use: board piece sprite.
local s = px.sprite{
  w = 16, h = 16,
  palette = {
    {"outline", "#1a1c2c"},
    {"dk",      "#1b1f33"},
    {"mid",     "#3a4466"},
    {"lt",      "#5a6988"},
    {"hl",      "#8b9bb4"},
  },
}

local piece = s:layer("piece")

-- shared base (same for every piece)
piece:fill(3, 13, 10, 2, "mid")   -- y 13..14
piece:fill(4, 12, 8, 1, "mid")    -- y 12

-- left half, x 0..7
-- cross: top tip y1, bar y2 x5..7, stem x7..8 y3..4
piece:px(7, 1, "mid")
piece:fill(4, 2, 4, 1, "mid")
piece:fill(7, 3, 1, 2, "mid")
-- crown: notched points at x3 and x5 y4, band y5..6 x3..7, rim y7 x4..7
piece:px(3, 4, "mid")
piece:px(5, 4, "mid")
piece:fill(3, 5, 5, 2, "mid")
piece:fill(4, 7, 4, 1, "mid")
-- neck y8..9 x5..7
piece:fill(5, 8, 3, 2, "mid")
-- body: widens toward the base, y10..11 x4..7
piece:fill(4, 10, 4, 2, "mid")

piece:mirror("x")

-- shading after the mirror, light from top-left
local function solid(x, y)
  return x >= 0 and x < 16 and y >= 0 and y < 16 and piece:get(x, y) ~= nil
end

for y = 0, 15 do
  for x = 0, 15 do
    if solid(x, y) then
      if not solid(x - 1, y) then
        piece:px(x, y, "lt")
      elseif not solid(x + 1, y) or not solid(x, y + 1) then
        piece:px(x, y, "dk")
      end
    end
  end
end

-- highlight: two pixels on the upper left of the crown band
piece:px(4, 5, "hl")
piece:px(4, 6, "hl")

local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})

return s
