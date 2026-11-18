local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs (Goal 3: Distinct peg leg and black boot, no muddy coat hem)
-- Back leg: Black boot
c:rect(11, 17, 4, 2, "black")
c:rect(10, 18, 5, 1, "black")

-- Front leg: Tapered wooden peg
c:path({{16,15}, {17,15}, {17,18}, {16,18}}, "wood")
c:px(15, 17, "wood")
c:px(15, 18, "wood")
c:px(18, 18, "wood_dk") -- Peg foot base

-- 2. Coat (Goal 2: Long coat with light top-left, shade bottom-right)
c:rect(10, 9, 7, 7, "coat")
-- Shading the coat using a simple diagonal split
for y = 9, 15 do
    for x = 10, 16 do
        if x + y > 24 then
            c:px(x, y, "coat_dk")
        end
    end
end

-- 3. Shirt/Chest
c:rect(12, 10, 3, 2, "shirt")

-- 4. Arm and Cutlass (Goal 1: Curved blade, hilt, and grip)
c:rect(16, 11, 2, 3, "coat") -- Arm
c:rect(18, 12, 1, 1, "skin") -- Hand/Grip
c:rect(19, 11, 1, 3, "gold") -- Guard
-- Curved blade: tapering to a point
c:path({{20,12}, {22,12}, {25,13}, {25,14}, {22,14}, {20,14}}, "steel")
c:px(25, 13, "steel_hl") -- Tip highlight

-- 5. Head and Beard
c:rect(12, 5, 5, 5, "skin") 
c:path({{13,8}, {16,8}, {17,10}, {13,10}}, "beard") 
c:px(13, 6, "black") -- Eye

-- 6. Tricorn Hat
c:path({{9,6}, {18,6}, {17,7}, {10,7}}, "black") -- Wide Brim
c:path({{11,5}, {16,5}, {15,3}, {13,3}}, "black") -- Crown

-- 7. Belt and Buckle (Goal 2: Belt across coat)
c:rect(10, 14, 7, 2, "black")
c:rect(13, 14, 2, 2, "gold")

-- 8. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
