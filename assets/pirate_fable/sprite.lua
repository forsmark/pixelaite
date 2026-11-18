-- Brief: pirate, 30x20, 1 px margin. Full body, side view facing RIGHT, standing.
-- Tricorn hat, beard, long coat, belt with gold buckle. Right arm holds a cutlass
-- pointing forward (right). One wooden peg leg, one black boot.
-- Use: enemy/NPC sprite in a 2D platformer, must read as a pirate at 1x.
-- Light from the top-left. Fixed 13-color palette. Color layer + final "outline" layer.
local s = px.sprite{ w = 30, h = 20, palette = {
  {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
  {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
  {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
  {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} } }

local map = { K="black", s="skin", d="skin_dk", c="coat", C="coat_dk", w="wood", W="wood_dk",
  t="steel", T="steel_hl", g="gold", b="beard", h="shirt" }

local c = s:layer("body")
local function row(y, x, str) c:grid(x, y, {str}, map) end

-- tricorn hat
row(2, 8, "KKKK")
row(3, 6, "KKKKgKKK")
row(4, 4, "KKKKKKKKKKKK")
row(3, 4, "K")
row(3, 15, "K")
-- head, beard
row(5, 7, "bbssss")
row(6, 7, "bbdsKss")
row(7, 8, "gbbbbb")
-- torso, arm, hand
row(8, 6, "cccbbbbb")
row(9, 6, "ccccbbbh")
row(10, 6, "cccccccccchs")
row(11, 6, "cccccCCCCChs")
row(12, 6, "KKKKKggK")
-- coat skirt
row(13, 6, "cccCCCCC")
row(14, 5, "ccccCCCCC")
row(15, 5, "cc")
-- peg leg
row(15, 8, "wW")
row(16, 8, "wW")
row(17, 8, "w")
-- boot
row(15, 11, "KK")
row(16, 11, "KK")
row(17, 11, "KKKK")

-- cutlass
local sw = s:layer("sword")
local function srow(y, x, str) sw:grid(x, y, {str}, map) end
srow(9, 18, "g")
srow(10, 18, "g")
srow(11, 18, "g")
srow(7, 26, "TT")
srow(8, 23, "TTTtt")
srow(9, 19, "TTTTtttt")
srow(10, 19, "ttttt")

local ol = s:layer("outline")
ol:outline("outline", { from = { c, sw } })
return s
