local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs (Goal 2: Distinct peg leg and black boot)
-- Back leg: Black boot
c:rect(10, 17, 3, 2, "black")
c:rect(10, 18, 4, 1, "black")

-- Front leg: Straight wooden peg
c:rect(15, 15, 2, 4, "wood")
c:rect(14, 18, 3, 1, "wood_dk") -- Peg foot base

-- 2. Coat (Goal 3: Long coat with tail/hem)
c:rect(10, 9, 7, 7, "coat")
-- Coat tail (separates legs)
c:path({{10,14}, {13,14}, {13,17}, {10,17}}, "coat")
-- Shading coat (light top-left)
for y = 9, 15 do
    for x = 10, 16 do
        if x > 14 or y > 13 then c:px(x, y, "coat_dk") end
    end
end

-- 3. Shirt/Chest (Goal 4: Separation)
c:rect(12, 10, 3, 2, "shirt")

-- 4. Arm and Cutlass (Goal 1: Curved sword with hilt)
c:rect(16, 11, 2, 3, "coat") -- Arm
c:rect(18, 12, 2, 2, "black") -- Hand
-- Hilt/Guard
c:rect(19, 12, 1, 2, "gold")
-- Curved Cutlass blade
c:path({{20,13}, {23,12}, {25,13}, {25,14}, {22,14}, {20,14}}, "steel")
c:px(25, 13, "steel_hl") -- Bright tip

-- 5. Head and Beard (Goal 1: Clear skin and beard)
c:rect(12, 5, 5, 5, "skin") 
c:path({{12,8}, {16,8}, {16,10}, {13,10}}, "beard") 
c:px(13, 6, "black") -- Eye

-- 6. Tricorn Hat (Goal 4: Angled brim)
c:path({{9,6}, {18,6}, {17,7}, {10,7}}, "black") -- Wide Brim
c:path({{11,5}, {16,5}, {15,3}, {13,3}}, "black") -- Crown

-- 7. Belt and Buckle (Goal 4: Dark belt)
c:rect(10, 14, 7, 2, "black")
c:rect(13, 14, 2, 2, "gold")

-- 8. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
