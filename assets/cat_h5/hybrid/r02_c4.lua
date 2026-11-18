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

-- 1. Body (Sitting silhouette)
-- Main mass
draw_shaded_ellipse(c, 11, 13, 5, 5, "mid", -1, -1)
-- Head
draw_shaded_ellipse(c, 15, 8, 3, 3, "mid", -1, -1)

-- 2. White Bib and Muzzle (Distinct areas)
-- Chest bib
c:ellipse(12, 14, 2, 3, "white", true)
-- Muzzle
c:ellipse(16, 9, 2, 1, "white", true)
c:px(17, 9, "pink") -- Nose

-- 3. Ears (Pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 4. Eye
c:px(16, 8, "eye")

-- 5. Tail (Curled around front feet)
-- A distinct S-curve tail that wraps from the back to the front
c:path({{8,14}, {6,14}, {5,15}, {5,17}, {7,17}, {8,16}, {8,15}}, "mid")
-- Tail shading
c:path({{8,14}, {6,14}, {5,15}, {5,17}, {7,17}, {8,16}, {8,15}}, "dk", false)

-- 6. Tabby Stripes (Distinct bands on the back)
c:rect(8, 11, 1, 2, "dk")
c:rect(9, 12, 1, 2, "dk")

-- 7. Highlights (Top-left light)
c:px(14, 7, "hl")
c:px(15, 6, "hl")
c:px(11, 11, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
