-- chess_knight: horse head in side view, facing left, 16x16, white piece.
-- Ears at y=3, muzzle to the left, mane on the right (back) edge, neck on the base.
-- Light from the top-left. Used as a chess piece in a board game.
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

-- shared base (must match every piece)
piece:fill(3, 13, 10, 2, "mid")   -- y 13..14
piece:fill(4, 12, 8, 1, "mid")    -- y 12

-- silhouette rows for the head and neck: y -> {left x, right x}
-- head: ear at top-right, forehead slopes down-left to a narrow nose at x=2,
-- chin notch, throat notch, mane bump on the right (back) edge.
-- each row is a list of solid spans {left, right}. Row 10 has a gap between
-- the chin and the neck: the jaw notch.
local rows = {
  [3]  = {{9, 10}},
  [4]  = {{8, 11}},
  [5]  = {{7, 12}},
  [6]  = {{5, 13}},
  [7]  = {{4, 12}},
  [8]  = {{3, 11}},
  [9]  = {{2, 12}},
  [10] = {{2, 4}, {7, 13}},
  [11] = {{7, 12}},
  [12] = {{4, 11}},
  [13] = {{3, 12}},
  [14] = {{3, 12}},
}

local function solid(x, y)
  for _, r in ipairs(rows[y] or {}) do
    if x >= r[1] and x <= r[2] then return true end
  end
  return false
end

for y = 3, 11 do
  for _, r in ipairs(rows[y]) do
    piece:fill(r[1], y, r[2] - r[1] + 1, 1, "mid")
  end
end

-- shading pass: decide every colour from the silhouette first, then paint
local paint = {}
for y = 3, 14 do
  for x = 1, 14 do
    if solid(x, y) then
      local right_out  = not solid(x + 1, y)
      local bottom_out = not solid(x, y + 1)
      local left_out   = not solid(x - 1, y)
      local top_out    = not solid(x, y - 1)
      local c = "mid"
      if right_out or bottom_out then
        c = "dk"
      elseif left_out or top_out then
        c = "lt"
      end
      paint[#paint + 1] = {x, y, c}
    end
  end
end
for _, p in ipairs(paint) do
  piece:px(p[1], p[2], p[3])
end

-- highlights, upper left
piece:px(7, 4, "hl")
piece:px(5, 6, "hl")

-- eye (outline pixel), set after shading
piece:px(7, 6, "outline")

-- outline layer is made last
local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})

return s
