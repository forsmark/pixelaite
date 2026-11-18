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
                    -- Use hl for highlight if it's very close to light, else col
                    if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) < 0.25 then
                        canvas:px(x, y, "hl")
                    else
                        canvas:px(x, y, col)
                    end
                end
            end
        end
    end
end

-- 1. Body (Sitting posture)
-- Main torso
draw_shaded_ellipse(c, 11, 12, 4, 5, "mid", 1, 1)

-- 2. Head
draw_shaded_ellipse(c, 14, 7, 2.5, 2.2, "mid", 1, 1)
-- Ears
c:poly({{13,6}, {14,3}, {15,6}}, "mid")
c:poly({{15,6}, {16,3}, {17,6}}, "mid")
-- Face details
c:px(15, 7, "eye")
c:px(16, 8, "pink")
c:ellipse(15, 8, 1.5, 1, "white", true) -- Muzzle

-- 3. White Chest & Belly
c:ellipse(12, 13, 2, 3, "white", true)

-- 4. Tail (Curled around front feet)
-- Drawn as a distinct curved shape that wraps from the back (left) to the front (right)
c:path({{8,14}, {6,15}, {5,17}, {7,18}, {9,17}, {10,15}, {9,14}}, "mid")
-- Tail shading (top-left light)
c:path({{8,14}, {6,15}, {5,17}, {7,18}, {9,17}, {10,15}, {9,14}}, "dk")
-- Note: Since path fills, we draw the main color then a slightly offset dark path for shadow
-- For simplicity in 20x20, we'll just use a thicker path or specific pixels
c:px(5, 17, "dk")
c:px(6, 17, "dk")
c:px(6, 16, "dk")

-- 5. Tabby Stripes (Distinct on the back/side)
c:rect(9, 10, 1, 1, "dk")
c:rect(9, 12, 1, 1, "dk")
c:rect(8, 14, 1, 1, "dk")

-- 6. Front Paws (Visible at the bottom)
-- These sit at the end of the white chest/belly area
c:ellipse(12, 17, 2, 1, "lt", 1, 1)
c:ellipse(14, 17, 2, 1, "lt", 1, 1)

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
