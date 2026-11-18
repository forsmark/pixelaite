-- chess_knight: white knight chess piece, horse head side view facing left, 16x16, top-left light.
local s = px.sprite{
  w = 16, h = 16,
  palette = {
    {"outline","#1a1c2c"}, {"dk","#1b1f33"}, {"mid","#3a4466"}, {"lt","#5a6988"}, {"hl","#8b9bb4"},
  },
}
local piece = s:layer("piece")
piece:fill(3, 13, 10, 2, "mid")
piece:fill(4, 12, 8, 1, "mid")
piece:fill(3, 14, 10, 1, "dk")
piece:grid(2, 3, {
  "...llm......",
  "...lmmmd....",
  "...lmmmmdd..",
  "..lhmmmmmdd.",
  ".llmommmmmmd",
  ".lmmmmmmmmdd",
  "lmmmmmmmmmdd",
  "lddmmmmmmmdd",
  ".dddmmmmmmdd",
  "....mmmmmmdd",
}, {l="lt", m="mid", d="dk", h="hl", o="outline"})
piece:fill(4, 12, 8, 1, "mid")
piece:px(11, 12, "dk")
local ol = s:layer("outline")
ol:outline("outline", {from = {piece}})
return s
