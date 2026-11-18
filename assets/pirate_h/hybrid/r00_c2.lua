local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs (Back leg: boot, Front leg: peg)
c:rect(11, 15, 3, 3, "black")    -- Boot
c:rect(15, 15, 2, 4, "wood")     -- Peg leg
c:rect(15, 18, 2, 1, "wood_dk")  -- Peg foot shadow

-- 2. Coat (Torso)
c:rect(10, 9, 7, 6, "coat")
-- Shading coat (light top-left)
for y = 9, 14 do
    for x = 10, 16 do
        if x > 14 then c:px(x, y, "coat_dk") end
    end
end

-- 3. Shirt / Chest area
c:rect(12, 10, 3, 2, "shirt")

-- 4. Arms and Cutlass
c:rect(16, 11, 2, 2, "coat")     -- Arm
c:path({{18,11}, {22,10}, {24,12}, {23,13}, {19,13}}, "steel") -- Blade
c:rect(18, 12, 2, 1, "black")    -- Hand

-- 5. Head and Beard
c:rect(12, 6, 4, 4, "skin")      -- Face
c:rect(12, 9, 4, 2, "beard")     -- Beard
c:rect(14, 7, 1, 1, "skin_dk")   -- Shadow on face

-- 6. Tricorn Hat
c:path({{10,6}, {17,6}, {15,3}, {12,3}}, "black")

-- 7. Belt and Buckle
c:rect(10, 14, 7, 1, "black")
c:rect(13, 14, 1, 1, "gold")

-- 8. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
