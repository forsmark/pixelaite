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

-- 1. Tail (Distinct curl wrapping around front feet)
-- Using a path to create a clear "C" shape that is not a blob
c:path({{7,16}, {5,16}, {4,17}, {4,18}, {6,18}, {7,17}}, "mid")
c:px(4, 18, "hl") -- Highlight on tail tip

-- 2. Body (A single cohesive seated volume)
-- Main body mass (haunch and torso)
draw_shaded_ellipse(c, 10, 13, 5, 5, "mid", -1, -1)
-- Connect head to body more smoothly by filling the neck area
c:rect(13, 10, 3, 4, "mid")

-- 3. Head (Integrated with the neck)
draw_shaded_ellipse(c, 15, 8, 3, 2.8, "mid", -1, -1)

-- 4. White Muzzle and Chest (A clean, solid bib)
-- Chest bib: a solid shape from chin down to belly
c:path({{13,10}, {14,12}, {15,15}, {17,15}, {18,12}, {18,10}}, "white")
-- Muzzle patch
c:ellipse(16, 9, 2, 1.2, "white", true)
c:px(17, 9, "pink") -- Nose

-- 5. Ears (Pointed and clear)
c:poly({{14,7}, {15,3}, {16,7}}, "mid")
c:poly({{16,7}, {17,3}, {18,7}}, "mid")

-- 6. Eye
c:px(16, 8, "eye")

-- 7. Tabby Stripes (On the back/haunch)
c:rect(7, 11, 1, 2, "dk")
c:rect(8, 12, 1, 2, "dk")

-- 8. Highlights (Top-left light direction)
c:px(14, 6, "hl")
c:px(15, 5, "hl")
c:px(12, 11, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
