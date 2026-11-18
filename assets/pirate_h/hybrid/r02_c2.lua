local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs & Lower Body
-- Back leg: Black boot with distinct foot
c:rect(10, 16, 3, 3, "black")
c:rect(9, 18, 4, 1, "black") -- Foot base

-- Front leg: Peg leg (straight wooden stump)
c:rect(15, 16, 2, 3, "wood")
c:rect(15, 18, 2, 1, "wood_dk") -- Shadow side

-- 2. Coat (Long coat with visible hem/tail)
-- Main torso
c:rect(10, 9, 6, 7, "coat")
-- Coat tail (hanging down)
c:rect(10, 14, 4, 4, "coat_dk") 
-- Shading coat (top-left light)
for y = 9, 15 do
    for x = 10, 15 do
        if x > 13 or y > 13 then c:px(x, y, "coat_dk") end
    end
end

-- 3. Shirt & Belt
c:rect(12, 10, 3, 3, "shirt")
c:rect(10, 14, 6, 2, "black") -- Belt
c:rect(13, 14, 2, 2, "gold")   -- Gold Buckle

-- 4. Arm and Cutlass (Improved curved blade and hilt)
c:rect(15, 11, 2, 3, "coat") -- Arm
c:rect(17, 11, 2, 2, "black") -- Hand/Grip
-- Hilt/Guard
c:rect(17, 12, 1, 2, "gold")
-- Curved Cutlass Blade
c:path({{19,13}, {22,11}, {24,11}, {25,12}, {23,13}, {20,14}}, "steel")
c:px(24, 11, "steel_hl") -- Tip highlight

-- 5. Head and Beard
c:rect(12, 5, 5, 4, "skin") -- Face
c:path({{12,7}, {17,7}, {17,10}, {13,10}}, "beard") -- Beard block
c:px(13, 6, "black") -- Eye

-- 6. Tricorn Hat (Clearer silhouette)
c:path({{9,6}, {18,6}, {17,7}, {10,7}}, "black") -- Wide brim
c:path({{11,4}, {16,4}, {16,6}, {11,6}}, "black") -- Crown

-- 7. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
