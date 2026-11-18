local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse (Light from top-left: light_dx/dy are negative shifts)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test if pixel is in shadow by shifting the shape toward the light
                -- If we shift the shape by (light_dx, light_dy), pixels outside the shifted shape are shadow
                local sdx = x - light_dx - cx
                local sdy = y - light_dy - cy
                local is_shadow = (sdx*sdx)/(rx*rx) + (sdy*sdy)/(ry*ry) > 1
                
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
-- Main torso/rump
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", -1, -1)

-- Head
draw_shaded_ellipse(c, 14, 8, 3, 3, "mid", -1, -1)

-- White Muzzle and Chest
c:ellipse(15, 9, 2, 2, "white", true)
c:rect(13, 11, 2, 3, "white")

-- Ears
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- Eye and Nose
c:px(15, 8, "eye")
c:px(16, 9, "pink")

-- Tail (curls around feet)
c:path({{10,15}, {8,16}, {7,14}, {8,12}, {10,12}}, "mid")

-- Stripes on back (Darker tabby markings)
c:rect(9, 11, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")

-- Feet area
c:rect(11, 16, 3, 2, "lt")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
