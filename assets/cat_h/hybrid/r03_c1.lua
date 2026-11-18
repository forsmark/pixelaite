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

-- Head (Separated slightly to prevent merging)
draw_shaded_ellipse(c, 14, 8, 3, 3, "mid", 1, 1)

-- Muzzle/White chest area
c:ellipse(15, 9, 2, 1.5, "white", true)

-- Ears
c:poly({{12,7}, {13,4}, {14,7}}, "mid")
c:poly({{14,7}, {15,4}, {16,7}}, "mid")

-- Eye
c:px(15, 8, "eye")

-- Nose
c:px(16, 9, "pink")

-- Tail (Curled around front feet - distinct shape)
c:path({{10,15}, {8,16}, {6,15}, {6,13}, {8,12}, {10,13}}, "mid")

-- Stripes on back (Clearly readable tabby marks)
c:rect(9, 11, 1, 1, "dk")
c:rect(8, 13, 1, 1, "dk")
c:rect(8, 15, 1, 1, "dk")

-- Legs/Feet (Distinct paws)
c:rect(10, 16, 2, 1, "lt")
c:rect(13, 16, 2, 1, "lt")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
