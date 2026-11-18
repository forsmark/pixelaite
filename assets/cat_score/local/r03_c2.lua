local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse to create volume
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Shading test: if pixel is outside the ellipse shifted toward light, it's shadow
                local sdx = x - light_dx
                local sdy = y - light_dy
                local s_dx = sdx - cx
                local s_dy = sdy - cy
                local is_shadow = (s_dx*s_dx)/(rx*rx) + (s_dy*s_dy)/(ry*ry) > 1
                
                if is_shadow then
                    canvas:px(x, y, "dk")
                else
                    canvas:px(x, y, col)
                end
            end
        end
    end
end

-- 1. BODY (Sitting posture)
-- Main torso/rump
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)
-- Chest/Belly area (White)
c:ellipse(14, 14, 2.5, 3.5, "white", true)

-- 2. HEAD
-- Head shape
draw_shaded_ellipse(c, 15, 8, 3, 2.5, "mid", 1, 1)
-- Muzzle (White)
c:ellipse(16, 9, 1.5, 1.5, "white", true)
-- Ears (Pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")
-- Eye & Nose
c:px(16, 8, "eye")
c:px(17, 9, "pink")

-- 3. TAIL (Curling around feet)
-- Use a path to create a thick, curved tail shape
c:path({{10,15}, {8,16}, {6,15}, {6,13}, {8,12}, {10,12}}, "mid")

-- 4. DETAILS
-- Tabby Stripes on the back (darker orange)
c:rect(9, 11, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")

-- 5. LEGS (Simplified sitting legs)
c:rect(11, 16, 3, 2, "lt")

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
