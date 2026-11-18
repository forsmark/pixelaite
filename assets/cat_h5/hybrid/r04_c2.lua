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

-- 1. Tail: A clear "S" curl that starts from the back and sweeps to the front
-- Drawing the tail shape first so it sits behind the body/legs
c:path({{8,14}, {6,14}, {5,15}, {5,17}, {7,17}, {8,16}}, "mid")
c:px(5, 16, "hl") -- Highlight on the curve

-- 2. Body: Separated into a haunch (back) and chest/legs (front)
-- Haunch (sitting mass)
draw_shaded_ellipse(c, 10, 13, 3.5, 4, "mid", -1, -1)
-- Front legs/chest area
c:rect(13, 14, 2, 3, "mid") 
c:px(13, 16, "dk") -- Shadow under belly

-- 3. Head: Distinct round shape
draw_shaded_ellipse(c, 15, 8, 2.5, 2.5, "mid", -1, -1)

-- 4. White Bib and Muzzle: Clean separation
-- Muzzle
c:ellipse(16, 9, 1.5, 1, "white", true)
c:px(17, 9, "pink") -- Nose
-- Chest Bib (under chin)
c:path({{13,10}, {14,13}, {15,14}, {16,13}, {17,10}}, "white")

-- 5. Ears: Pointed
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 6. Eye
c:px(16, 8, "eye")

-- 7. Tabby Stripes: On the back/haunch
c:rect(8, 11, 1, 2, "dk")
c:rect(9, 12, 1, 2, "dk")

-- 8. Highlights
c:px(14, 7, "hl")
c:px(15, 6, "hl")
c:px(11, 11, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
