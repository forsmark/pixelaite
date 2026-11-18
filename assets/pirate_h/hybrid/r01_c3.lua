local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs (Back leg: boot, Front leg: peg)
-- Black boot (left side)
c:rect(11, 15, 3, 3, "black")
-- Peg leg (right side, tapered)
c:rect(15, 16, 2, 3, "wood")
c:rect(14, 18, 3, 1, "wood_dk") -- Base of peg

-- 2. Coat (Torso)
c:rect(10, 9, 7, 6, "coat")
-- Shading coat (light top-left)
for y = 9, 14 do
    for x = 10, 16 do
        if x > 14 or y > 12 then c:px(x, y, "coat_dk") end
    end
end

-- 3. Shirt / Chest area
c:rect(12, 10, 3, 2, "shirt")

-- 4. Arms and Cutlass (Goal 2: Curved blade, hilt, and hand)
c:rect(16, 11, 2, 2, "coat") -- Arm
c:rect(17, 12, 2, 2, "black") -- Hand/Grip
c:rect(17, 13, 1, 1, "gold")  -- Hilt pommel
-- Curved blade using a path
c:path({{19,12}, {21,11}, {24,11}, {25,12}, {24,13}, {21,13}, {19,13}}, "steel")
-- Blade highlight
c:path({{21,11}, {23,11}, {23,12}}, "steel_hl")

-- 5. Head and Beard
c:rect(12, 6, 4, 4, "skin")      -- Face
c:rect(12, 9, 4, 3, "beard")     -- Beard
c:px(13, 7, "skin_dk")           -- Eye/Shadow detail
c:rect(14, 7, 1, 1, "black")     -- Eye

-- 6. Tricorn Hat (Goal 1: Wide brim, angled sides)
c:path({{9,7}, {17,7}, {16,5}, {14,4}, {12,5}, {11,5}}, "black")
c:rect(10, 6, 7, 1, "black")     -- Brim

-- 7. Belt and Buckle
c:rect(10, 14, 7, 1, "black")
c:rect(13, 14, 1, 1, "gold")

-- 8. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
