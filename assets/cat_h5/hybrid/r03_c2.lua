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
                -- Test shadow: if pixel is outside ellipse shifted towards light
                local sdx, sdy = x - light_dx - cx, y - light_dy - cy
                local is_shadow = (sdx*sdx)/(rx*rx) + (sdy*sdy)/(ry*ry) > 1
                canvas:px(x, y, is_shadow and "dk" or col)
            end
        end
    end
end

-- 1. Tail (Drawn first so it's behind the body if needed, but we want it to curl in front)
-- We'll draw it as a distinct shape at the bottom left to avoid smudging.
-- Using a path for a clear "C" shape curl.
c:path({{9,15}, {7,15}, {5,16}, {5,18}, {7,18}, {9,17}, {10,16}}, "mid")
-- Darker edge for the tail to give it volume and separation
c:path({{9,15}, {7,15}, {5,16}, {5,18}, {7,18}, {9,17}, {10,16}}, "dk") 
-- Add a highlight to the top of the tail curl
c:px(6, 16, "lt")
c:px(5, 17, "lt")

-- 2. Body (Main Sitting Mass)
-- Sitting upright silhouette
draw_shaded_ellipse(c, 11, 13, 4.5, 5, "mid", -1, -1)

-- 3. Head
draw_shaded_ellipse(c, 15, 8, 2.8, 2.8, "mid", -1, -1)

-- 4. White Muzzle and Chest (Ensuring clear separation)
-- Chest bib
c:ellipse(13, 14, 1.8, 2.5, "white", true)
-- Muzzle patch (more defined)
c:ellipse(16, 9, 1.8, 1.2, "white", true)
c:px(17, 9, "pink") -- Nose

-- 5. Ears (Pointed and distinct)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 6. Eye
c:px(16, 8, "eye")

-- 7. Tabby Stripes (2-3 clear, thin vertical-ish bands)
-- Positioned on the back (left side of body)
c:rect(8, 11, 1, 2, "dk")
c:rect(9, 12, 1, 2, "dk")
c:rect(10, 13, 1, 1, "dk")

-- 8. Highlights (Top-left light)
c:px(14, 7, "hl")
c:px(15, 6, "hl")
c:px(12, 11, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
