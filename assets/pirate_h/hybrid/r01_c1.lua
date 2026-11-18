local s = px.sprite{ w = 30, h = 20, palette = { 
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"} 
} }

local c = s:layer("body")

-- 1. Legs (Back leg: boot, Front leg: peg)
c:rect(10, 15, 3, 4, "black")    -- Boot (Back)
c:rect(15, 15, 2, 4, "wood")     -- Peg leg (Front)
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
-- Improved Cutlass: Hilt, Hand, and Curved Blade
c:rect(18, 11, 1, 2, "black")    -- Hilt/Hand
c:path({{19,11}, {23,10}, {25,12}, {24,13}, {20,12}}, "steel") -- Curved Blade
c:px(23, 11, "steel_hl")         -- Blade highlight

-- 5. Head and Beard
c:rect(12, 6, 4, 4, "skin")      -- Face
c:rect(12, 9, 4, 2, "beard")     -- Beard
c:px(13, 7, "black")             -- Eye
c:rect(14, 7, 1, 1, "skin_dk")   -- Shadow on face

-- 6. Tricorn Hat (Improved shape: wide brim, angled sides)
c:path({{9,6}, {18,6}, {16,4}, {14,3}, {11,4}}, "black")

-- 7. Belt and Buckle
c:rect(10, 14, 7, 1, "black")
c:rect(13, 14, 1, 1, "gold")

-- 8. Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
