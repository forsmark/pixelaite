local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs (Goal 1: Distinct peg leg and black boot)
-- Back leg: Black boot (Left side of pirate)
c:rect(11, 16, 3, 3, "black")
c:rect(10, 18, 4, 1, "black")

-- Front leg: Wooden peg (Right side of pirate)
c:rect(15, 15, 2, 4, "wood")
c:rect(15, 18, 3, 1, "wood_dk") -- Peg base

-- 2. Coat (Goal 3: Long coat, lit top-left)
-- Main coat mass
c:rect(10, 9, 7, 7, "coat")
-- Shading using volume technique: test pixels against a shifted ellipse/rect
for y = 9, 15 do
    for x = 10, 16 do
        -- Light from top-left (x+1, y+1)
        if x > 13 or y > 12 then
            c:px(x, y, "coat_dk")
        end
    end
end

-- 3. Shirt (Small patch in coat)
c:rect(13, 10, 2, 2, "shirt")

-- 4. Arm and Cutlass (Goal 1: Curved sword)
c:rect(16, 11, 2, 3, "coat") -- Arm connecting to coat
c:rect(18, 12, 1, 1, "skin") -- Hand
-- Hilt
c:rect(18, 11, 1, 2, "gold")
-- Curved Cutlass blade
c:path({{19,12}, {23,11}, {25,12}, {25,13}, {22,14}, {19,13}}, "steel")
c:px(25, 12, "steel_hl") -- Bright tip

-- 5. Head and Beard (Goal 2: Profile)
c:rect(12, 5, 4, 4, "skin") -- Face
c:path({{15,7}, {16,7}, {16,10}, {13,10}, {12,9}}, "beard") -- Beard mass
c:px(13, 6, "black") -- Eye

-- 6. Tricorn Hat
c:path({{9,6}, {17,6}, {16,7}, {10,7}}, "black") -- Brim
c:path({{11,5}, {15,5}, {14,3}, {12,3}}, "black") -- Crown

-- 7. Belt and Buckle
c:rect(10, 14, 7, 2, "black")
c:rect(13, 14, 2, 2, "gold")

-- 8. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
