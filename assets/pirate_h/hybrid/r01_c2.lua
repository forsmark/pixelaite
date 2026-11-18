local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs (Separated by coat hem)
-- Back leg: Black boot
c:rect(10, 16, 3, 3, "black")
c:rect(10, 18, 4, 1, "black") -- Sole

-- Front leg: Tapered wooden peg
c:path({{15,16}, {16,16}, {17,18}, {15,18}}, "wood")
c:rect(15, 18, 3, 1, "wood_dk") -- Peg foot shadow

-- 2. Coat (Torso)
c:rect(10, 9, 7, 7, "coat")
-- Shading coat (light top-left)
for y = 9, 15 do
    for x = 10, 16 do
        if x > 14 or y > 13 then c:px(x, y, "coat_dk") end
    end
end

-- 3. Shirt/Chest
c:rect(12, 10, 3, 2, "shirt")

-- 4. Arm and Cutlass (Right side)
c:rect(16, 11, 2, 3, "coat") -- Arm
c:rect(18, 12, 2, 2, "black") -- Hand/Grip
-- Curved Cutlass blade
c:path({{20,13}, {24,11}, {25,12}, {21,14}}, "steel")
c:px(24, 11, "steel_hl") -- Highlight

-- 5. Head and Beard
c:rect(12, 5, 5, 5, "skin") -- Face
c:path({{12,8}, {16,8}, {16,10}, {13,10}}, "beard") -- Beard shape
c:px(13, 6, "black") -- Eye

-- 6. Tricorn Hat (Wide brim, angled sides)
c:path({{9,6}, {18,6}, {16,4}, {12,4}}, "black") -- Brim
c:path({{11,5}, {16,5}, {15,3}, {13,3}}, "black") -- Crown

-- 7. Belt and Buckle
c:rect(10, 14, 7, 2, "black")
c:rect(13, 14, 2, 2, "gold")

-- 8. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
