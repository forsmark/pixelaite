-- Brief: cat (candidate C)
-- Canvas 20x20, 1 px margin. Orange tabby cat, sitting, side view facing RIGHT.
-- Tail curls along the ground in front of the feet. Pointed ears, visible eye,
-- white muzzle and chest, dark tabby stripes on the back. Light from top-left.
-- Method: one character grid for the silhouette and shading, then a generated outline.
local s = px.sprite{
  w = 20, h = 20,
  palette = {
    {"outline", "#2b1b18"},
    {"dk",      "#a14f2b"},
    {"mid",     "#e0812f"},
    {"lt",      "#f4b45e"},
    {"hl",      "#fce3a8"},
    {"white",   "#f4f4f4"},
    {"eye",     "#7ec850"},
    {"pink",    "#e88a9a"},
  },
}

local body = s:layer("body")
body:grid(0, 0, {
  "....................",
  "....................",
  "..........m....m....",
  "..........mpmmpm....",
  ".........hlmmmmmm...",
  "........llmmmemmm...",
  "........lmmmmwwwwp..",
  ".........mmwwwwww...",
  "........lmmwwwwd....",
  ".......ldmmdwwwwd...",
  ".....lldmmdmmwwwd...",
  "....lldmmdmmmwwwd...",
  "...lmdmmdmmdmwwd....",
  "..mldmmdmmdmmmw.....",
  "..mlmmdmmdmmmww.....",
  "..mmmmmmdmmmwww.....",
  "..mmmmmdmmwww.......",
  "..mmmmmmmmmww.......",
}, {
  ["m"] = "mid",
  ["l"] = "lt",
  ["h"] = "hl",
  ["d"] = "dk",
  ["w"] = "white",
  ["e"] = "eye",
  ["p"] = "pink",
})

-- Tail by contrast: a light tail (hl tip edge, lt body) along the back-left and
-- under the haunch, separated from the mid/dk haunch by one outline column, with a
-- white tip in front of the feet.
body:px(2, 13, "hl")
for y = 14, 17 do body:px(2, y, "lt") end
for x = 3, 6 do body:px(x, 17, "lt") end
body:px(7, 17, "white")
body:px(8, 17, "white")
for y = 13, 16 do body:px(3, y, "outline") end

local ol = s:layer("outline")
ol:outline("outline", {from = {body}})

return s
