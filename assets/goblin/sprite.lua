-- goblin: small goblin enemy, 32x32, front view, idle pose.
-- Big head, long pointed ears, green skin, yellow eyes, toothy grin, brown loincloth.
-- Light from top-left. Enemy sprite for a fantasy RPG.
local s = px.sprite{
  w = 32, h = 32,
  palette = {
    {"outline",  "#20152e"},
    {"skin_dk",  "#3a6b35"},
    {"skin",     "#6aa84f"},
    {"skin_lt",  "#a7d46f"},
    {"eye",      "#f4e04d"},
    {"teeth",    "#f4f4f4"},
    {"mouth",    "#7a2e3b"},
    {"cloth_dk", "#5b3a29"},
    {"cloth",    "#8b5a3c"},
  },
}

-- Shape helpers. The same test as px ellipse, so shading lines up with the shapes.
local function in_ell(x, y, cx, cy, rx, ry)
  local dx, dy = x - cx, y - cy
  return (dx * dx) / (rx * rx + 0.8 * rx) + (dy * dy) / (ry * ry + 0.8 * ry) <= 1
end
local HEAD = {15.5, 12, 7, 6}
local BODY = {15.5, 23, 4, 3.5}

-- Skin: draw the left half, then mirror. The center axis is x = 15.5.
local skin = s:layer("skin")
skin:poly({{9, 10}, {2, 7}, {9, 14}}, "skin")       -- left ear
skin:line(10, 19, 7, 25, "skin"); skin:line(11, 19, 8, 25, "skin") -- left arm, apart from the torso
skin:fill(12, 27, 3, 3, "skin")                     -- left leg
skin:fill(11, 29, 4, 1, "skin")                     -- left foot
skin:mirror("x")
skin:ellipse(HEAD[1], HEAD[2], HEAD[3], HEAD[4], "skin", true)
skin:ellipse(BODY[1], BODY[2], BODY[3], BODY[4], "skin", true)

-- Shading after the mirror, so the light comes from the top-left only.
-- Round parts: a crescent shadow where the shape is not covered by itself
-- moved toward the light, and a lit rim on the opposite side.
skin:map(function(x, y, c)
  if c ~= "skin" then return end
  for _, e in ipairs({HEAD, BODY}) do
    local cx, cy, rx, ry = e[1], e[2], e[3], e[4]
    if in_ell(x, y, cx, cy, rx, ry) then
      if not in_ell(x, y, cx - 1.5, cy - 1.5, rx, ry) then return "skin_dk" end
      if e == HEAD and not in_ell(x, y, cx + 1, cy + 1, rx, ry) and x < 16 then return "skin_lt" end
      return
    end
  end
  -- Arms and legs on the right side face away from the light: all shadow.
  if y >= 19 and x >= 16 then return "skin_dk" end
  -- Other thin parts (ears, left limbs): shadow on the bottom and right edges.
  if not skin:get(x + 1, y) or not skin:get(x, y + 1) then return "skin_dk" end
end)
-- Shadow under the chin.
skin:line(13, 19, 18, 19, "skin_dk")

-- Loincloth.
local cloth = s:layer("cloth")
cloth:fill(11, 24, 10, 2, "cloth")
cloth:poly({{12, 26}, {19, 26}, {15.5, 29}}, "cloth")
cloth:line(11, 25, 20, 25, "cloth_dk")

-- Face: draw the left half, then mirror.
local face = s:layer("face")
face:grid(10, 10, {
  "ooo",
  "eep",
}, { o = "outline", e = "eye", p = "outline" })    -- brow and left eye
face:fill(12, 15, 4, 1, "mouth")
face:px(13, 15, "teeth"); face:px(13, 16, "teeth")  -- fang
face:mirror("x")

local ol = s:layer("outline")
ol:outline("outline", { from = { skin, cloth } })

return s
