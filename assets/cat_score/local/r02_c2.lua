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
                -- Check shadow by testing if pixel is outside an ellipse shifted toward light
                local sx = x - light_dx
                local sy = y - light_dy
                local sdx = sx - cx
                local sdy = sy - cy
                local is_shadow = (sdx*sdx)/(rx*rx) + (sdy*sdy)/(ry*ry) > 1
                canvas:px(x, y, is_shadow and "dk" or col)
            end
        end
    end
end

-- 1. Body (Sitting posture, facing RIGHT)
-- Torso
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 0)
-- Head
draw_shaded_ellipse(c, 15, 8, 3, 3, "mid", 1, 0)

-- 2. Details
-- White muzzle and chest
c:path({{15,9}, {17,9}, {17,12}, {15,13}, {14,11}}, "white")
-- Eye (placed on the right side of the head)
c:px(16, 7, "eye")
-- Nose
c:px(17, 8, "pink")
-- Ears (Pointed, facing right)
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- 3. Tabby Stripes (on the back/left side)
c:rect(8, 11, 1, 2, "dk")
c:rect(8, 14, 1, 1, "dk")

-- 4. Tail (Curling around the front/bottom)
-- Using a path to create a curved tail shape that wraps
c:path({{9,14}, {7,15}, {6,16}, {7,17}, {9,17}, {10,16}, {9,15}}, "mid")

-- 5. Paws/Base
c:rect(12, 17, 4, 1, "lt")

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
