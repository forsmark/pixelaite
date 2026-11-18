-- chess_pawn: 16x16 front view, white pawn, light from top-left.
-- Subject: pawn. Round ball head (rows 6-11), collar (row 12), short widening base (rows 13-14).
-- Palette mood: cool white/steel. Game use: chess board sprite, one piece of a set.
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

-- Ellipse test in index coordinates (pixel x,y counts as its own center).
local function inE(x, y, cx, cy, rx, ry)
  local dx = (x - cx) / rx
  local dy = (y - cy) / ry
  return dx * dx + dy * dy <= 1
end

local piece = s:layer("piece")

-- Shared base, drawn first for every piece.
piece:fill(3, 13, 10, 2, "mid")   -- y 13..14
piece:fill(4, 12, 8, 1, "mid")    -- y 12

-- Head: left half only (x 0..7), then mirror.
for y = 6, 11 do
  for x = 0, 7 do
    if inE(x, y, 7.5, 8.5, 4, 3.2) then
      piece:px(x, y, "mid")
    end
  end
end
piece:mirror("x")

-- Shading after the mirror. Light from top-left.
-- Head: shifted-ellipse test. Pixels in the head but outside the ellipse moved toward the light are shadow.
for y = 6, 11 do
  for x = 0, 15 do
    if inE(x, y, 7.5, 8.5, 4, 3.2) then
      if not inE(x, y, 6.5, 7.5, 4.2, 3.4) then
        piece:px(x, y, "dk")
      elseif inE(x, y, 6.5, 7.5, 2.8, 2.2) then
        piece:px(x, y, "lt")
      end
    end
  end
end
piece:px(5, 7, "hl")
piece:px(4, 8, "hl")

-- Collar and base edges: left lit, right and bottom shadowed.
piece:px(4, 12, "lt")
piece:px(11, 12, "dk")
piece:px(3, 13, "lt")
piece:px(3, 14, "lt")
piece:px(12, 13, "dk")
piece:px(12, 14, "dk")
piece:fill(4, 14, 8, 1, "dk")

local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})

return s
