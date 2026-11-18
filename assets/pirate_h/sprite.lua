local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs (Goal 3: Clear distinction between peg leg and boot)
-- Back leg: Black boot
c:rect(10, 17, 4, 2, "black")
c:rect(9, 18, 5, 1, "black")
-- Front leg: Wooden peg (narrower, lighter)
c:rect(15, 15, 2, 4, "wood")
c:rect(14, 18, 3, 1, "wood_dk")

-- 2. Torso & Coat (Goal 4: Separate coat, shirt, and belt)
-- Long Coat
c:rect(10, 9, 7, 8, "coat")
-- Shading coat (bottom and right side)
for y = 9, 16 do
    for x = 10, 16 do
        if x > 13 or y > 14 then
            c:px(x, y, "coat_dk")
        end
    end
end
-- Shirt (visible at chest/neck)
c:rect(13, 9, 3, 2, "shirt")
-- Belt & Buckle
c:rect(10, 14, 7, 2, "black")
c:rect(13, 14, 2, 2, "gold")

-- 3. Head & Face (Goal 1: Clear skin, beard, and hat)
-- Skin/Face
c:rect(12, 6, 5, 4, "skin")
-- Shading skin (bottom right)
c:px(16, 9, "skin_dk")
c:px(15, 9, "skin_dk")
-- Beard (distinct dark mass below face)
c:path({{12,9}, {17,9}, {17,11}, {14,11}, {12,10}}, "beard")
-- Eye
c:px(15, 7, "black")
-- Tricorn Hat
c:path({{8,7}, {18,7}, {17,6}, {9,6}}, "black") -- Brim
c:path({{10,6}, {16,6}, {15,3}, {11,3}}, "black") -- Crown

-- 4. Arm & Cutlass (Goal 2: Curved blade with hilt and light edge)
-- Arm
c:rect(16, 11, 2, 3, "coat")
c:rect(18, 12, 1, 1, "skin") -- Hand
-- Hilt
c:rect(19, 11, 1, 3, "gold")
-- Cutlass Blade (Curved shape)
c:path({{20,12}, {24,11}, {26,13}, {26,14}, {20,14}}, "steel")
-- Lit edge (top/left of blade)
c:px(21, 12, "steel_hl")
c:px(22, 12, "steel_hl")
c:px(23, 11, "steel_hl")
c:px(25, 13, "steel_hl")

-- 5. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
