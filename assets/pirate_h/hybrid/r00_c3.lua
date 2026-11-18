local s = px.sprite{ w = 30, h = 20, palette = {
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"}
} }

local c = s:layer("body")

-- Helper for elliptical shading (light from top-left)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, color, shadow_color)
    for y = cy - ry + 0.5, cy + ry - 0.5 do
        for x = cx - rx + 0.5, cx + rx - 0.5 do
            local dx, dy = x - cx, y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test shadow: ellipse moved 2px right, 1px down (away from top-left light)
                local sx, sy = x - 2, y - 1
                local sdx, sdy = sx - cx, sy - cy
                local is_shadow = (sdx*sdx)/(rx*rx) + (sdy*sdy)/(ry*ry) <= 1
                canvas:px(math.floor(x), math.floor(y), is_shadow and shadow_color or color)
            end
        end
    end
end

-- 1. Legs/Bottom
-- Peg leg (Left leg, back)
c:rect(10, 16, 3, 2, "wood_dk")
c:rect(11, 14, 1, 2, "wood")
-- Boot leg (Right leg, front)
c:rect(16, 16, 3, 2, "black")
c:rect(16, 14, 3, 2, "black")

-- 2. Coat / Body
c:rect(10, 8, 7, 7, "coat_dk") -- base coat
c:rect(11, 8, 5, 7, "coat")    -- light side
-- Belt
c:rect(10, 12, 7, 1, "black")
c:rect(13, 12, 1, 1, "gold")

-- 3. Shirt/Chest
c:rect(13, 8, 3, 3, "shirt")

-- 4. Head & Beard
-- Neck
c:rect(13, 7, 2, 1, "skin_dk")
-- Face
c:rect(13, 5, 3, 3, "skin")
-- Beard
c:rect(13, 6, 3, 2, "beard")
-- Tricorn Hat
c:poly({{11,5}, {16,5}, {15,3}, {12,3}}, "black")
c:rect(12, 4, 4, 1, "black")

-- 5. Arms & Cutlass
-- Arm holding sword (Right arm)
c:rect(16, 9, 2, 3, "coat")
-- Cutlass (curved)
c:path({{18,10}, {21,9}, {23,11}, {22,12}, {19,11}}, "steel")
c:path({{18,10}, {21,9}, {23,11}, {22,12}, {19,11}}, "steel_hl") -- highlight
c:rect(17, 9, 1, 1, "skin") -- hand

-- 6. Details
-- Eye (tiny dot)
c:px(15, 6, "outline")

-- Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
