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
                -- Test shadow: if the pixel is outside the ellipse shifted towards light
                local sdx, sdy = x - light_dx - cx, y - light_dy - cy
                local is_shadow = (sdx*sdx)/(rx*rx) + (sdy*sdy)/(ry*ry) > 1
                canvas:px(x, y, is_shadow and "dk" or col)
            end
        end
    end
end

-- 1. Body (Main Sitting Mass)
-- Using a larger ellipse for a solid silhouette
draw_shaded_ellipse(c, 11, 13, 5, 5, "mid", -1, -1)

-- 2. Head
-- Head is a separate sphere
draw_shaded_ellipse(c, 15, 8, 3, 3, "mid", -1, -1)

-- 3. White Muzzle and Chest
-- Chest area
c:ellipse(13, 13, 2, 3, "white", true)
-- Muzzle
c:ellipse(16, 9, 2, 1.5, "white", true)
c:px(17, 9, "pink") -- Nose

-- 4. Ears (Pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 5. Eye
c:px(16, 8, "eye")

-- 6. Tail (Curled around feet)
-- Using a thick path for better readability
c:path({{10,15}, {8,16}, {6,15}, {6,13}, {8,12}, {10,12}}, "mid")
-- Shade tail slightly
c:path({{10,15}, {8,16}, {6,15}, {6,13}, {8,12}, {10,12}}, "dk", false)

-- 7. Tabby Stripes (on the back/side)
c:rect(9, 11, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")

-- 8. Highlights (Top-left light)
c:px(14, 7, "hl")
c:px(15, 6, "hl")
c:px(12, 11, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
