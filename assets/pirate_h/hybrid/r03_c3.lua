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

-- Front leg: Thin tapered wooden peg
c:rect(15, 15, 2, 4, "wood")
c:rect(15, 16, 1, 3, "wood_dk") -- Shading on right side of peg
c:rect(14, 18, 3, 1, "wood_dk") -- Peg foot base

-- 2. Coat & Torso (Goal 2: Long coat, light top-left, shade bottom-right)
-- Main coat mass
c:rect(10, 9, 7, 8, "coat")
-- Shading: Apply coat_dk to the bottom and right edges
for y = 12, 17 do
    for x = 10, 16 do
        -- Light from top-left (x < 13 and y < 12)
        if x >= 13 or y >= 12 then
            c:px(x, y, "coat_dk")
        end
    end
end

-- 3. Shirt/Chest (Visible at the neck/front)
c:rect(12, 10, 3, 2, "shirt")

-- 4. Arm and Cutlass
c:rect(16, 11, 2, 3, "coat") -- Arm
c:rect(18, 12, 2, 2, "black") -- Hand
-- Hilt/Guard
c:rect(19, 12, 1, 2, "gold")
-- Curved Cutlass blade (Goal 1: Sharp and curved)
c:path({{20,13}, {23,12}, {25,13}, {25,14}, {22,14}, {20,14}}, "steel")
c:px(25, 13, "steel_hl") -- Bright tip

-- 5. Head and Beard
c:rect(12, 5, 5, 5, "skin") 
c:path({{12,8}, {16,8}, {16,10}, {13,10}}, "beard") 
c:px(13, 6, "black") -- Eye

-- 6. Tricorn Hat
c:path({{9,6}, {18,6}, {17,7}, {10,7}}, "black") -- Wide Brim
c:path({{11,5}, {16,5}, {15,3}, {13,3}}, "black") -- Crown

-- 7. Belt and Buckle (Goal 2: Clearly across the coat)
c:rect(10, 14, 7, 2, "black")
c:rect(13, 14, 2, 2, "gold")

-- 8. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
