local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse (volume based)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry + 0.5), math.ceil(cy + ry - 0.5) do
        for x = math.floor(cx - rx + 0.5), math.ceil(cx + rx - 0.5) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test light-shifted ellipse for shading
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

-- Body (Sitting posture)
-- Main torso (using light from top-left: light_dx=-1, light_dy=-1)
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", -1, -1)

-- Head
draw_shaded_ellipse(c, 14, 8, 3, 3, "mid", -1, -1)

-- Ears (Pointed)
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- Muzzle/White chest area
c:ellipse(15, 9, 2, 1.5, "white", true)

-- Eye
c:px(15, 8, "eye")

-- Nose
c:px(16, 9, "pink")

-- Tail (curls around feet)
-- Drawing tail as a thick path/series of circles for better volume
c:ellipse(8, 15, 2, 1, "mid", -1, -1)
c:ellipse(7, 14, 2, 1, "mid", -1, -1)
c:ellipse(7, 12, 1.5, 1, "mid", -1, -1)

-- Stripes on back (Dark tabby stripes)
c:rect(9, 11, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")

-- Legs/Feet area (simplified)
c:rect(11, 16, 3, 1, "lt")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
