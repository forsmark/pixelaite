-- chess_bishop: front view, white piece, 16x16. Tall pointed-oval mitre with a
-- small ball on top and a diagonal slit (upper right to lower left) cut into the
-- head. Thin neck, collar, wide base. Light from the top-left. Game use: chess board.
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

-- shared base (must be drawn first)
piece:fill(3, 13, 10, 2, "mid")   -- y 13..14
piece:fill(4, 12, 8, 1, "mid")    -- y 12

-- left half, x 0..7 (mirrored after)
piece:px(7, 3, "mid")             -- ball top
piece:fill(6, 4, 2, 1, "mid")     -- ball
piece:px(7, 5, "mid")             -- mitre tip
piece:fill(6, 6, 2, 1, "mid")     -- head
piece:fill(5, 7, 3, 1, "mid")     -- head
piece:fill(5, 8, 3, 1, "mid")     -- head
piece:fill(4, 9, 4, 1, "mid")     -- head widest
piece:fill(6, 10, 2, 1, "mid")    -- thin neck
piece:fill(4, 11, 4, 1, "mid")    -- collar

piece:mirror("x")

-- diagonal slit, drawn after the mirror (the only asymmetric detail)
piece:px(9, 6, "outline")
piece:px(8, 7, "outline")
piece:px(7, 8, "outline")
piece:px(6, 9, "outline")

-- one-directional shading: right edges and bottom edges dark, left edges light
local function at(x, y)
  if x < 0 or x > 15 or y < 0 or y > 15 then return nil end
  return piece:get(x, y)
end

local marks = {}
for y = 0, 15 do
  for x = 0, 15 do
    if at(x, y) == "mid" then
      if at(x + 1, y) == nil then
        marks[#marks + 1] = {x, y, "dk"}
      elseif at(x, y + 1) == nil then
        marks[#marks + 1] = {x, y, "dk"}
      elseif at(x - 1, y) == nil and at(x, y - 1) ~= nil then
        marks[#marks + 1] = {x, y, "lt"}
      end
    end
  end
end
for _, m in ipairs(marks) do
  piece:px(m[1], m[2], m[3])
end

-- highlights on the upper left
piece:px(6, 4, "hl")
piece:px(6, 6, "hl")

local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})

return s
