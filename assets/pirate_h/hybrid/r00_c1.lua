local s = px.sprite{ w = 30, h = 20, palette = {
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"}
} }

local c = s:layer("base")

-- Helper for shaded ellipse (volume)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, col_dk, light_x, light_y)
    for y = cy - ry + 0.5, cy + ry - 0.5 do
        for x = cx - rx + 0.5, cx + rx - 0.5 do
            local dx, dy = x - cx, y - cy
            if dx*dx/(rx*rx) + dy*dy/(ry*ry) <= 1 then
                -- Simple lighting check: distance to light source
                local lx, ly = x - light_x, y - light_y
                local dist = math.sqrt(lx*lx + ly*ly)
                if dist < 3 then canvas:px(x, y, col) else canvas:px(x, y, col_dk) end
            end
        end
    end
end

-- 1. Legs & Peg Leg (Bottom)
-- Boot leg (Left)
c:rect(11, 15, 3, 3, "black")
-- Peg leg (Right)
c:rect(15, 15, 2, 4, "wood")
c:rect(14, 18, 4, 1, "wood_dk") -- foot base

-- 2. Coat & Torso
c:rect(10, 9, 7, 7, "coat")
-- Shading the coat (side away from top-left)
c:rect(15, 9, 2, 7, "coat_dk")
-- Belt
c:rect(10, 13, 7, 1, "black")
c:rect(13, 13, 1, 1, "gold")

-- 3. Shirt (visible at neck/chest)
c:rect(11, 8, 3, 2, "shirt")

-- 4. Head & Beard
-- Head
draw_shaded_ellipse(c, 12, 7, 3, 3, "skin", "skin_dk", 8, 4)
-- Beard
c:rect(10, 7, 3, 3, "beard")
-- Eye (tiny dot)
c:px(13, 6, "outline")

-- 5. Tricorn Hat
c:poly({{8, 5}, {12, 3}, {16, 5}, {14, 6}, {10, 6}}, "black")
c:rect(10, 4, 4, 2, "black")

-- 6. Arm & Cutlass
-- Arm
c:rect(16, 10, 2, 3, "coat")
-- Cutlass (curved blade)
c:path({{18, 11}, {22, 10}, {24, 12}, {22, 13}, {18, 12}}, "steel")
-- Hilt
c:rect(17, 10, 1, 3, "wood")
-- Blade highlight
c:px(22, 11, "steel_hl")

-- 7. Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
