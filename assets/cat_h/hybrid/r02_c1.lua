local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse (Volume technique)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test a light-shifted ellipse for shading
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
-- Main torso
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)

-- Head (Separated from body for neck break)
draw_shaded_ellipse(c, 15, 7, 3, 2.5, "mid", 1, 1)

-- Muzzle/White chest area
c:ellipse(16, 7.5, 1.5, 1, "white", true)

-- Ears (Pointed)
c:poly({{14,6}, {15,3}, {16,6}}, "mid")
c:poly({{16,6}, {17,3}, {18,6}}, "mid")

-- Eye
c:px(16, 6.5, "eye")

-- Nose
c:px(17, 7.5, "pink")

-- Tail (Curled around front feet - distinct shape)
c:path({{9,15}, {7,15}, {6,14}, {6,12}, {8,11}, {10,12}}, "mid")

-- Stripes on back (Distinct bands)
c:rect(8, 11, 1, 2, "dk")
c:rect(7, 13, 1, 2, "dk")

-- Legs/Feet area
c:rect(10, 16, 4, 2, "lt")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
