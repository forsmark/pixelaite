-- chess_queen: white queen chess piece, 16x16 front view, light top-left, coronet with ball. Set piece for a chess game.
local s = px.sprite{
  w = 16, h = 16,
  palette = {
    {"outline","#1a1c2c"}, {"dk","#1b1f33"}, {"mid","#3a4466"}, {"lt","#5a6988"}, {"hl","#8b9bb4"},
  },
}
local piece = s:layer("piece")
piece:fill(3, 13, 10, 2, "mid")
piece:fill(4, 12, 8, 1, "mid")
piece:grid(0, 3, {
  ".......#",
  ".......#",
  "....#..#",
  ".#.#.#.#",
  ".#######",
  "..######",
  ".....###",
  ".....###",
  "....####",
}, {["#"]="mid"})
piece:mirror("x")
local snap = {}
for y = 0, 15 do for x = 0, 15 do snap[y*16+x] = piece:get(x, y) end end
local function at(x, y) return snap[y*16+x] end
piece:map(function(x, y, c)
  if not c then return nil end
  if y == 14 or (y >= 12 and x >= 12) then return "dk" end
  if y >= 12 then return c end
  if x >= 10 then return "dk" end
  if x >= 8 and at(x+1, y) == nil then return "dk" end
  if y == 8 and x >= 8 then return "dk" end
  if x < 8 and at(x-1, y) == nil then return "lt" end
  return c
end)
piece:px(7, 3, "hl")
piece:px(1, 6, "hl")
piece:px(2, 7, "hl")
local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})
return s
