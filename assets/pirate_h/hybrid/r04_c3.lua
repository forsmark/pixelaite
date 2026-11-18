local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs
-- Back leg: Black boot
c:rect(10, 17, 3, 2, "black")
c:rect(10, 18, 4, 1, "black")

-- Front leg: Wooden peg
c:rect(15, 15, 2, 4, "wood")
c:rect(14, 18, 3, 1, "wood_dk")

-- 2. Coat
c:rect(10, 9, 7, 7, "coat")
c:path({{10,14}, {13,14}, {13,17}, {10,17}}, "coat")
-- Shading coat (light top-left)
for y = 9, 15 do
    for x = 10, 16 do
        if x > 14 or y > 13 then c:px(x, y, "coat_dk") end
    end
end

-- 3. Shirt/Chest
c:rect(12, 10, 3, 2, "shirt")

-- 4. Arm and Cutlass
c:rect(16, 11, 2, 3, "coat") -- Arm
c:rect(18, 12, 2, 2, "black") -- Hand
c:rect(19, 12, 1, 2, "gold") -- Hilt
c:path({{20,13}, {23,12}, {25,13}, {25,14}, {22,14}, {20,14}}, "steel")
c:px(25, 13, "steel_hl")

-- 5. Head and Beard (IMPROVED GOAL 2)
-- Face profile (Skin)
c:rect(12, 5, 5, 5, "skin")
-- Shading skin (bottom/right side)
for y = 5, 9 do
    for x = 12, 16 do
        if x > 14 or y > 7 then c:px(x, y, "skin_dk") end
    end
end
-- Eye (Black pixel)
c:px(15, 6, "black")
-- Nose/Muzzle protrusion
c:px(16, 7, "skin")
c:px(16, 8, "skin")
-- Beard (Mass below face/jaw)
c:path({{13,8}, {16,8}, {16,10}, {14,10}, {13,9}}, "beard")
-- Beard shading
c:px(14, 9, "beard")

-- 6. Tricorn Hat
c:path({{9,6}, {18,6}, {17,7}, {10,7}}, "black") -- Brim
c:path({{11,5}, {16,5}, {15,3}, {13,3}}, "black") -- Crown

-- 7. Belt and Buckle
c:rect(10, 14, 7, 2, "black")
c:rect(13, 14, 2, 2, "gold")

-- 8. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
