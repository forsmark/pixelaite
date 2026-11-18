local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for volume-based shading
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx, dy = x - cx, y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                local sdx, sdy = x - light_dx - cx, y - light_dy - cy
                local is_shadow = (sdx*sdx)/(rx*rx) + (sdy*sdy)/(ry*ry) > 1
                canvas:px(x, y, is_shadow and "dk" or col)
            end
        end
    end
end

-- 1. Tail (Curled around front feet)
c:path({{8,15}, {6,15}, {5,16}, {5,18}, {7,18}, {8,17}}, "mid")
c:px(5, 17, "hl")

-- 2. Body (Sitting structure: Haunch + Legs)
-- We use a larger ellipse to create a smoother, unified seated volume
draw_shaded_ellipse(c, 10, 13, 5, 5, "mid", -1, -1)
-- Front legs/chest area
c:rect(13, 14, 2, 4, "mid") 
c:rect(14, 14, 1, 4, "dk")

-- 3. Head (Integrated with body flow)
draw_shaded_ellipse(c, 15, 8, 2.8, 2.8, "mid", -1, -1)

-- 4. White Muzzle and Chest (Clean, connected bib)
-- Expanded bib to ensure it reads as a solid shape from chin to belly
c:path({{13,10}, {14,12}, {15,15}, {17,16}, {18,14}, {18,11}, {17,9}}, "white")
c:ellipse(16, 9, 1.8, 1.2, "white", true)
c:px(17, 9, "pink")

-- 5. Ears
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 6. Eye
c:px(16, 8, "eye")

-- 7. Tabby Stripes (On the back/haunch)
c:rect(8, 11, 1, 2, "dk")
c:rect(9, 12, 1, 2, "dk")

-- 8. Highlights
c:px(14, 7, "hl")
c:px(15, 6, "hl")
c:px(12, 11, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
