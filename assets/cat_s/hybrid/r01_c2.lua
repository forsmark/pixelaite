local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse to create volume
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, color, light_dx, light_dy)
    for y = math.floor(cy - ry + 0.5), math.ceil(cy + ry - 0.5) do
        for x = math.floor(cx - rx + 0.5), math.ceil(cx + rx - 0.5) do
            local dx, dy = x - cx, y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Shadow test: shift ellipse toward light (top-left)
                local sdx, sdy = x - light_dx, y - light_dy
                local s_dx, s_dy = sdx - cx, sdy - cy
                local is_shadow = (s_dx*s_dx)/(rx*rx) + (s_dy*s_dy)/(ry*ry) > 1
                
                if is_shadow then
                    canvas:px(x, y, "dk")
                else
                    canvas:px(x, y, color)
                end
            end
        end
    end
end

-- 1. Body (Large sitting mass)
draw_shaded_ellipse(c, 11, 13, 4.5, 5, "mid", 1, 1)

-- 2. Head (Connected to upper body)
draw_shaded_ellipse(c, 14, 8, 3, 2.8, "mid", 1, 1)

-- 3. Muzzle and Chest (White patches)
-- Muzzle
c:ellipse(15, 9, 1.5, 1.5, "white", true)
-- Chest
c:ellipse(13, 13, 2, 3, "white", true)

-- 4. Ears (Pointed)
c:poly({{13,7}, {12,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- 5. Face details
c:px(15, 8, "eye")      -- Eye
c:px(16, 9, "pink")     -- Nose

-- 6. Tail (Curled around feet)
-- We draw the tail as a thick path/line to ensure it looks like a limb
c:path({{9,14}, {7,15}, {6,14}, {6,12}, {8,11}, {10,11}}, "mid")

-- 7. Tabby Stripes (Dark accents on back/side)
c:rect(9, 11, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")

-- 8. Paws/Feet (Bottom of the sitting mass)
c:rect(10, 17, 4, 1, "lt")

-- 9. Highlights (Top edges for extra pop)
c:rect(12, 6, 3, 1, "hl") -- Forehead highlight
c:rect(10, 10, 2, 1, "hl") -- Back highlight

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
