-- chess_queen: white chess queen, front view, 16x16. Four-point coronet with a
-- small ball on top, slim waist flaring to a wide base. Light from top-left.
-- Used as a chess piece on a board tile in a 2D game.
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

-- left half, x 0..7, rows y 2..11
local left = {
  [2]  = ".......m",   -- ball top
  [3]  = "..m...mm",   -- outer point tip, ball
  [4]  = "..mm.mmm",   -- outer point, valley, center point into ball
  [5]  = "..mmmmmm",   -- coronet band
  [6]  = "..mmmmmm",
  [7]  = "...mmmmm",   -- band ends, shoulder
  [8]  = "....mmmm",   -- neck
  [9]  = ".....mmm",   -- slim waist
  [10] = "....mmmm",   -- flare
  [11] = "....mmmm",   -- skirt, matches base width so no notch
}
for y = 2, 11 do
  piece:grid(0, y, {left[y]}, {m = "mid"})
end

piece:mirror("x")

-- occupancy helper, mirrors the shape above so shading can test edges
local function solid(x, y)
  if x < 0 or x > 15 or y < 0 or y > 14 then return false end
  if y == 12 then return x >= 4 and x <= 11 end
  if y == 13 or y == 14 then return x >= 3 and x <= 12 end
  local row = left[y]
  if not row then return false end
  local i = (x < 8) and x or (15 - x)
  return row:sub(i + 1, i + 1) ~= "."
end

-- shading after mirror: light from top-left
for y = 2, 14 do
  for x = 0, 15 do
    if solid(x, y) then
      if (x < 8 and not solid(x, y - 1)) or (not solid(x - 1, y)) then
        piece:px(x, y, "lt")
      elseif (not solid(x + 1, y)) or (not solid(x, y + 1)) then
        piece:px(x, y, "dk")
      end
    end
  end
end

-- highlights on the upper left
piece:px(7, 2, "hl")
piece:px(6, 3, "hl")

local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})

return s
