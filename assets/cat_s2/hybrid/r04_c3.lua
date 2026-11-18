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

-- Body (Sitting posture)
-- Main torso
draw_shaded_ellipse(c, 11, 12, 4, 5, "mid", 1, 1)

-- Head
draw_shaded_ellipse(c, 14, 7, 3, 2.5, "mid", 1, 1)

-- White Muzzle and Chest
c:ellipse(15, 8, 2, 1.5, "white", true)
c:ellipse(12, 12, 2, 3, "white", true)

-- Ears
c:poly({{13,6}, {14,3}, {15,6}}, "mid")
c:poly({{15,6}, {16,3}, {17,6}}, "mid")

-- Eye & Nose
c:px(15, 7, "eye")
c:px(16, 8, "pink")

-- Tail (Curled around front feet)
-- A distinct path that wraps from the rear toward the bottom-left
c:path({{9,14}, {7,15}, {6,16}, {7,17}, {9,17}, {10,16}, {9,15}}, "mid")

-- Stripes on back (Distinct small stripes)
c:rect(9, 10, 1, 1, "dk")
c:rect(8, 12, 1, 1, "dk")
c:rect(9, 14, 1, 1, "dk")

-- Front Paws/Feet (Visible at bottom to avoid flat-bottom look)
-- Small rounded shapes at the base of the chest/belly
draw_shaded_ellipse(c, 12, 16, 2, 1, "lt", 1, 1)
draw_shaded_ellipse(c, 14, 17, 2, 1, "lt", 1, 1)

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
