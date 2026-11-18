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

-- 2. Coat & Shirt
-- Main coat body
c:rect(10, 9, 7, 7, "coat")
-- Shading coat (light top-left)
for y = 9, 15 do
    for x = 10, 16 do
        if x > 14 or y > 13 then c:px(x, y, "coat_dk") end
    end
end
-- Coat tail/hem separation
c:path({{10,14}, {13,14}, {13,17}, {10,17}}, "coat")
-- Shirt area
c:rect(12, 10, 3, 2, "shirt")

-- 3. Belt and Buckle
c:rect(10, 14, 7, 2, "black")
c:rect(13, 14, 2, 2, "gold")

-- 4. Arm and Cutlass (Focus: Goal 2 - Improved curved blade and hilt)
c:rect(16, 11, 2, 3, "coat") -- Arm
c:rect(18, 12, 2, 2, "black") -- Hand/Grip

-- Hilt/Guard (Gold)
c:rect(19, 11, 1, 3, "gold") 

-- Curved Cutlass blade
-- We use a path to create a distinct curve and add a highlight on the top edge
c:path({{20,12}, {23,11}, {25,12}, {25,13}, {22,14}, {20,14}}, "steel")
-- Highlight on the top edge for "lit edge" effect
c:path({{20,12}, {23,11}, {24,11}, {21,13}, {20,13}}, "steel_hl")

-- 5. Head and Beard (Goal 1: Clear skin and beard)
c:rect(12, 5, 5, 5, "skin") 
-- Eye
c:px(13, 6, "black")
-- Beard mass below chin
c:path({{12,8}, {17,8}, {17,10}, {15,11}, {13,10}}, "beard")

-- 6. Tricorn Hat
c:path({{9,6}, {18,6}, {17,7}, {10,7}}, "black") -- Wide Brim
c:path({{11,5}, {16,5}, {15,3}, {13,3}}, "black") -- Crown

-- 7. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
