-- Brief: cat
-- Canvas 20x20, 1 px margin. Orange tabby cat, sitting, side view facing RIGHT.
-- Tail curls around the front feet. Pointed ears, visible eye, white muzzle and chest,
-- 2-3 darker tabby stripes on the back. Game sprite (pet/NPC in a cozy RPG), reads at 1x.
-- Light from the top-left. Fixed 8-color palette. Color layers + final "outline" layer.
local s = px.sprite{ w = 20, h = 20, palette = {
  {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
  {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"} } }

local map = { d="dk", m="mid", l="lt", h="hl", w="white", e="eye", p="pink", o="outline" }

local body = s:layer("body")
body:grid(0, 0, {
  "....................",
  "....................",
  ".........l....m.....",
  "........lmm..lpm....",
  "........lldmdmmm....",
  ".......llmmmmmmmd...",
  ".......lmmmmmeomd...",
  ".......lmmmmmmwwp...",
  ".......mmmmmmwwww...",
  "........dmmmmwww....",
  ".......lmmmmwww.....",
  "......lddmmmwwwm....",
  ".....lmmmmmmwwwm....",
  "....lddmmmmmmwwd....",
  "....lmmmmmmmmwwd....",
  "...lmmmddddddwwdlh..",
  "...lmmdlllllllllmd..",
  "....ddddmmmmmmmmd...",
  "....................",
  "....................",
}, map)

local ol = s:layer("outline")
ol:outline("outline", {from = {body}})
return s
