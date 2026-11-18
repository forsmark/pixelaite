-- potion: red health potion, 32x32, front view, round glass flask with cork.
-- Light from top-left. Inventory icon for a fantasy RPG.
local s = px.sprite{
  w = 32, h = 32,
  palette = {
    {"outline",  "#1a1c2c"},
    {"red_dk",   "#5d275d"},
    {"red",      "#b13e53"},
    {"red_lt",   "#ef7d57"},
    {"glass",    "#566c86"},
    {"glass_lt", "#94b0c2"},
    {"white",    "#f4f4f4"},
    {"cork_dk",  "#73464c"},
    {"cork",     "#c28569"},
  },
}

local cx, cy, r = 15.5, 20, 9

-- Glass body and neck.
local glass = s:layer("glass")
glass:circle(cx, cy, r, "glass_lt", true)
glass:fill(13, 8, 6, 4, "glass_lt")
glass:fill(12, 7, 8, 1, "glass")             -- lip
-- Shadow side of the glass: right part of the body and the neck.
glass:map(function(x, y, c)
  if c == "glass_lt" and ((x - cx) + 0.6 * (y - cy) > 5 or x >= 17) then return "glass" end
end)

-- Liquid in the lower part of the body.
local liquid = s:layer("liquid")
liquid:circle(cx, cy, r - 1, "red", true)
liquid:map(function(x, y, c) if c and y < 16 then return false end end)
-- Shadow on the right and bottom, light on the left.
liquid:map(function(x, y, c)
  if not c then return end
  -- Round shading: distance from a light point up-left of the center.
  local d = math.sqrt((x - (cx - 3.5)) ^ 2 + (y - (cy - 3)) ^ 2)
  if d < 3.6 then return "red_lt" end
  if d > 9.2 then return "red_dk" end
end)
liquid:line(8, 16, 23, 16, "red_lt") -- surface
liquid:map(function(x, y, c) if y == 16 and x >= 19 and c then return "red" end end)

-- Cork.
local cork = s:layer("cork")
cork:fill(12, 3, 8, 4, "cork")
cork:fill(17, 3, 3, 4, "cork_dk")

-- Highlights on the glass.
local hl = s:layer("highlight")
hl:line(10, 17, 10, 21, "white")
hl:px(11, 15, "white")
hl:px(14, 9, "white")
hl:px(14, 10, "white")

-- Outline around everything.
local ol = s:layer("outline")
ol:outline("outline", { from = { glass, cork } })

return s
