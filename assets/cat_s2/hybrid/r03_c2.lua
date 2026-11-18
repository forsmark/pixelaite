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
                local sdx = x - light_dx
                local sdy = y - light_dy
                local s_dx = sdx - cx
                local s_dy = sdy - cy
                local is_shadow = (s_dx*s_dx)/(rx*rx) + (s_dy*s_dy)/(ry*ry) > 1
                
                if is_shadow then
                    canvas:px(x, y, "dk")
                else
                    -- Use hl for highlight if it's very close to light, else col
                    if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) < 0.4 then
                        canvas:px(x, y, "hl")
                    else
                        canvas:px(x, y, col)
                    end
                end
            end
        end
    end
end

-- 1. Body (Sitting posture) - Centered to avoid edges
-- Main torso
draw_shaded_ellipse(c, 11, 12, 4, 5, "mid", 1, 1)

-- 2. Head
draw_shaded_ellipse(c, 14, 7, 3, 2.5, "mid", 1, 1)

-- 3. Ears (Pointed) - Adjusted to stay within 1px margin
c:poly({{13,6}, {14,3}, {15,6}}, "mid")
c:poly({{15,6}, {16,3}, {17,6}}, "mid")

-- 4. Face Details
c:px(15, 7, "eye")    -- Eye
c:px(16, 8, "pink")   -- Nose
-- White muzzle (small area to stay within head shape)
c:ellipse(15.5, 8.5, 1.5, 1, "white", true) 

-- 5. Chest/Belly (White)
c:ellipse(11, 13, 2, 3, "white", true)

-- 6. Tail (Curled orange shape)
-- A clear orange path that wraps from the back towards the front
c:path({{8,13}, {6,13}, {5,15}, {6,17}, {8,17}, {9,16}, {7,16}, {6,15}, {7,14}}, "mid")

-- 7. Tabby Stripes (on the back/haunch)
c:rect(9, 10, 1, 1, "dk")
c:rect(9, 12, 1, 1, "dk")

-- 8. Feet area (Base of the sitting cat)
draw_shaded_ellipse(c, 11, 16.5, 3, 1.5, "lt", 1, 1)

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
