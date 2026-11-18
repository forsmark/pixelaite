-- sword: steel short sword, 16x16 inventory icon, diagonal (tip top-right).
-- Light from top-left. Fantasy RPG.
local s = px.sprite{
  w = 16, h = 16,
  palette = {
    {"outline",  "#1a1c2c"},
    {"steel_dk", "#566c86"},
    {"steel",    "#94b0c2"},
    {"steel_lt", "#f4f4f4"},
    {"gold_dk",  "#b86f50"},
    {"gold",     "#ffcd75"},
    {"grip",     "#73464c"},
  },
}

local blade = s:layer("blade")
blade:line(5, 9, 11, 3, "steel_lt")   -- lit edge
blade:line(6, 9, 12, 3, "steel")      -- center
blade:line(6, 10, 12, 4, "steel_dk")  -- shadow edge
blade:px(13, 2, "steel_lt")           -- tip

local hilt = s:layer("hilt")
hilt:line(3, 8, 8, 13, "gold")        -- crossguard, lit side
hilt:line(3, 9, 7, 13, "gold_dk")     -- crossguard, shadow side
hilt:line(4, 11, 3, 12, "grip")       -- grip
hilt:px(2, 13, "gold")                -- pommel

local ol = s:layer("outline")
ol:outline("outline", { from = { blade, hilt } })

return s
