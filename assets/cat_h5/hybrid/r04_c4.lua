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

-- 1. Tail (Curled around the front, distinct shape)
-- A large "C" shape at the bottom left
c:path({{11,16}, {8,16}, {5,15}, {4,13}, {5,11}, {7,10}, {9,11}, {8,13}, {10,14}, {11,15}}, "mid")
-- Add some shading/detail to tail
c:px(5, 12, "dk")
c:px(6, 11, "dk")
c:px(7, 10, "hl") -- highlight on the outer curve

-- 2. Body (Sitting posture: Haunch at back, legs at front)
-- Back haunch (large ellipse)
draw_shaded_ellipse(c, 10, 13, 4, 4.5, "mid", -1, -1)
-- Front legs area (lower part of body)
c:rect(12, 15, 2, 2, "mid") 
c:rect(13, 16, 2, 1, "mid")

-- 3. Head (Separate round shape)
draw_shaded_ellipse(c, 15, 8, 2.5, 2.5, "mid", -1, -1)

-- 4. White Muzzle and Chest (Clean bib/patch)
-- Chest bib (under chin/neck)
c:path({{13,11}, {14,10}, {15,10}, {16,11}, {15,14}, {13,14}}, "white")
-- Muzzle
c:ellipse(16, 9, 1.5, 1, "white", true)
c:px(17, 9, "pink") -- Nose

-- 5. Ears (Pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 6. Eye
c:px(16, 8, "eye")

-- 7. Tabby Stripes (On the back haunch)
c:rect(7, 12, 1, 2, "dk")
c:rect(8, 13, 1, 1, "dk")

-- 8. Highlights (Top-left light)
c:px(14, 6, "hl")
c:px(15, 5, "hl")
c:px(9, 11, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
