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

-- 1. Body (Sitting posture) - Centered to respect 1px margin
-- Main torso
draw_shaded_ellipse(c, 11, 12, 4, 5, "mid", 1, 1)

-- 2. Head
draw_shaded_ellipse(c, 14, 7, 2.5, 2, "mid", 1, 1)

-- 3. Ears (Pointed) - Ensuring they stay within x < 19
c:poly({{13,6}, {14,3}, {15,6}}, "mid")
c:poly({{15,6}, {16,4}, {17,6}}, "mid")

-- 4. Face Details
c:px(15, 7, "eye")
c:px(16, 8, "pink")
c:ellipse(15, 8.5, 1.5, 1, "white", true) -- White muzzle

-- 5. White Chest
c:ellipse(11, 13, 2, 3, "white", true)

-- 6. Tail (Curled around front feet)
-- A distinct orange curve wrapping from the back (left) towards the front (right)
-- Using a thin path to ensure it doesn't look like a dark block
c:path({{8,14}, {7,15}, {7,16}, {8,17}, {10,17}, {12,16}, {13,15}, {13,14}}, "mid")
-- Add some light to the tail to make it readable
c:path({{8,14}, {7,15}, {7,16}, {8,17}, {10,17}, {12,16}, {13,15}, {13,14}}, "lt")

-- 7. Stripes on back (Darker tabby stripes)
c:rect(9, 10, 1, 1, "dk")
c:rect(8, 12, 1, 1, "dk")

-- 8. Feet area
c:ellipse(11, 17, 3, 1.5, "lt", 1, 1)

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
