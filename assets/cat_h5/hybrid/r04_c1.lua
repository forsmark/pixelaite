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

-- 1. Tail (Improved: Larger, clear curl coming from back towards front paws)
c:path({{10,14}, {8,14}, {6,15}, {5,17}, {6,18}, {8,18}, {10,16}}, "mid")
c:path({{10,14}, {8,14}, {6,15}, {5,17}, {6,18}, {8,18}, {10,16}}, "dk") 
c:px(5, 17, "hl")
c:px(6, 18, "hl")

-- 2. Body (Split into haunch/back and front legs for better silhouette)
-- Back/Haunch
draw_shaded_ellipse(c, 11, 13, 4, 4, "mid", -1, -1)
-- Front legs/chest area
c:rect(14, 14, 2, 3, "mid") 
c:rect(14, 16, 2, 1, "dk") -- Shadow under legs

-- 3. Head (Clearly separated from body)
draw_shaded_ellipse(c, 15, 8, 2.8, 2.8, "mid", -1, -1)

-- 4. White Muzzle and Chest (Clean separation)
-- Chest bib (tucked under chin)
c:rect(13, 11, 3, 4, "white")
-- Muzzle patch
c:ellipse(16, 9, 1.8, 1.2, "white", true)
c:px(17, 9, "pink") -- Nose

-- 5. Ears
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 6. Eye
c:px(16, 8, "eye")

-- 7. Tabby Stripes
c:rect(9, 11, 1, 2, "dk")
c:rect(10, 12, 1, 2, "dk")

-- 8. Highlights
c:px(14, 7, "hl")
c:px(15, 6, "hl")
c:px(12, 11, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
