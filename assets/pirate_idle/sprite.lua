-- Brief: pirate, 30x20, 1 px margin. Full body, side view facing RIGHT, standing.
-- Tricorn hat, beard, long coat, belt with gold buckle. Right arm holds a cutlass
-- pointing forward (right). One wooden peg leg, one black boot.
-- Use: enemy/NPC sprite in a 2D platformer, must read as a pirate at 1x.
-- Idle loop, 4 frames: breathing bob down 1 px (top margin is full, so the bob goes down),
-- hat lags one frame, coat tail flares one frame later. Feet stay planted.
-- Light from the top-left. Fixed 13-color palette. Color layer + final "outline" layer.
local s = px.sprite{ w = 30, h = 20, palette = {
  {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
  {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
  {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
  {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} } }

local map = { K="black", s="skin", d="skin_dk", c="coat", C="coat_dk", w="wood", W="wood_dk",
  t="steel", T="steel_hl", g="gold", b="beard", h="shirt" }

s:layer("body"); s:layer("sword"); s:layer("outline")

-- d: body offset (head, torso, belt, sword), hd: hat offset, flare: coat tail swings out
local function draw(f, d, hd, flare)
  local c, sw, ol = s:cel("body", f), s:cel("sword", f), s:cel("outline", f)
  c:clear(); sw:clear(); ol:clear()
  local function row(y, x, str) c:grid(x, y, {str}, map) end
  -- head, beard (an extra forehead row fills the gap while the hat lags)
  if d > hd then row(5 + hd, 7, "bbssss") end
  row(5 + d, 7, "bbssss")
  row(6 + d, 7, "bbdsKss")
  row(7 + d, 8, "gbbbbb")
  -- tricorn hat
  row(2 + hd, 8, "KKKK")
  row(3 + hd, 6, "KKKKgKKK")
  row(4 + hd, 4, "KKKKKKKKKKKK")
  row(3 + hd, 4, "K")
  row(3 + hd, 15, "K")
  -- torso, arm, hand
  row(8 + d, 6, "cccbbbbb")
  row(9 + d, 6, "ccccbbbh")
  row(10 + d, 6, "cccccccccchs")
  row(11 + d, 6, "cccccCCCCChs")
  row(12 + d, 6, "KKKKKggK")
  -- coat skirt: the hem row stays at y=14, the skirt compresses when the body sinks
  if d == 0 then row(13, 6, "cccCCCCC") end
  row(14, 5, "ccccCCCCC")
  if flare then row(14, 4, "c") row(15, 4, "cc") else row(15, 5, "cc") end
  -- peg leg (planted)
  row(15, 8, "wW")
  row(16, 8, "wW")
  row(17, 8, "w")
  -- boot (planted)
  row(15, 11, "KK")
  row(16, 11, "KK")
  row(17, 11, "KKKK")
  -- cutlass, bobs with the hand
  local function srow(y, x, str) sw:grid(x, y + d, {str}, map) end
  srow(9, 18, "g")
  srow(10, 18, "g")
  srow(11, 18, "g")
  srow(7, 26, "TT")
  srow(8, 23, "TTTtt")
  srow(9, 19, "TTTTtttt")
  srow(10, 19, "ttttt")
  ol:outline("outline", { from = { c, sw } })
end

draw(1, 0, 0, false)
for _ = 2, 4 do s:dup_frame(1) end
draw(2, 1, 0, false)   -- body sinks, hat lags
draw(3, 1, 1, true)    -- hat settles, coat tail flares
draw(4, 0, 0, true)    -- body rises, tail still out
s:duration(1, 240); s:duration(2, 160); s:duration(3, 240); s:duration(4, 160)
s:tag("idle", 1, 4)
return s
