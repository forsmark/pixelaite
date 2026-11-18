local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse to create round volume
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
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
                    if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) < 0.3 then
                        canvas:px(x, y, "hl")
                    else
                        canvas:px(x, y, col)
                    end
                end
            end
        end
    end
end

-- Body (Sitting posture) - Shifted slightly left/up to respect 1px margin
-- Main torso
draw_shaded_ellipse(c, 10, 12, 4, 5, "mid", 1, 1)

-- Head (Moved slightly left to ensure nose doesn't hit edge)
draw_shaded_ellipse(c, 13, 7, 3, 2.5, "mid", 1, 1)

-- White Muzzle and Chest
c:ellipse(14, 8, 2, 1.5, "white", true) -- Muzzle
c:ellipse(11, 12, 2, 3, "white", true) -- Chest

-- Ears (Pointed)
c:poly({{12,6}, {13,3}, {14,6}}, "mid")
c:poly({{14,6}, {15,3}, {16,6}}, "mid")

-- Eye
c:px(14, 7, "eye")

-- Nose
c:px(15, 8, "pink")

-- Tail (Curled around feet) - Adjusted to be orange/mid tone
c:path({{9,15}, {7,16}, {5,15}, {5,13}, {7,12}, {9,12}}, "mid")

-- Stripes on back (Darker tabby stripes)
c:rect(8, 10, 1, 2, "dk")
c:rect(7, 12, 1, 2, "dk")

-- Legs/Feet area
c:ellipse(10, 16, 3, 1.5, "lt", 1, 1)

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
