local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse (Light from top-left: dx=-1, dy=-1)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test light-shifted ellipse for shading
                -- To simulate light from top-left, we check if pixel is inside 
                -- an ellipse shifted towards the light (top-left)
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

-- 1. Body (Sitting posture)
-- Main torso: Large ellipse
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", -1, -1)

-- 2. Head
-- Head base
draw_shaded_ellipse(c, 15, 8, 3, 2.5, "mid", -1, -1)
-- Ears (Pointed)
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- 3. Details
-- White muzzle and chest
c:ellipse(16, 9, 2, 1.5, "white", true)
-- Eye (Green)
c:px(16, 8, "eye")
-- Nose (Pink)
c:px(17, 9, "pink")

-- Tabby stripes on back (Dark)
c:rect(9, 11, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")

-- 4. Tail (Curling around front feet)
-- We use a path to create a curved shape for the tail
c:path({{8,15}, {7,16}, {6,15}, {6,13}, {7,12}, {9,12}}, "mid")

-- 5. Feet/Legs (Front paws area)
-- Simplified sitting legs
c:rect(13, 16, 2, 1, "lt")

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
