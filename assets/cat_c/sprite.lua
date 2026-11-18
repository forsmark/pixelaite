-- Brief: cat (candidate C)
-- Canvas 20x20, 1 px margin. Orange tabby cat, sitting, side view facing RIGHT.
-- Tail: a J lying on its side. Thick at the rump (lower left), sweeps forward
-- along the ground, tip curls UP in front of the front paws. Pointed ears,
-- visible eye, white muzzle and chest, dark tabby stripes on the back.
-- Light from top-left.
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
  "........lmmmmwwww...",
  ".........mdwwwwww...",
  "........lmdwwwwd....",
  ".......lmmmmwwwwd...",
  "......ldmdmmmwwwd...",
  "....llmdmdmmmwwwd...",
  "...llmmmommmwww.ll..",
  "..mlmmdmommmwww.lm..",
  "..mmmooooommmww.md..",
  "..llllllllllmmm.md..",
  "..mmmmmmmmmmmmmmmd..",
  "...mddddddddd.......",
}, {
  ["m"] = "mid",
  ["l"] = "lt",
  ["h"] = "hl",
  ["d"] = "dk",
  ["o"] = "outline",
  ["w"] = "white",
  ["e"] = "eye",
  ["p"] = "pink",
})

local ol = s:layer("outline")
ol:outline("outline", {from = {body}})

return s
