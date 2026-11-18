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

-- 1. Body (The main seated volume)
-- We create a single large mass for the haunch and torso to ensure it reads as one shape
draw_shaded_ellipse(c, 11, 13, 5, 5, "mid", -1, -1)

-- 2. White Chest/Bib (Making it a clean, bold shape from chin to belly)
-- Positioned on the front-right of the body mass
c:path({{14,10}, {16,10}, {17,12}, {17,15}, {16,16}, {14,16}, {13,14}}, "white")

-- 3. Head (Connected smoothly to the body)
draw_shaded_ellipse(c, 15, 8, 3, 3, "mid", -1, -1)

-- 4. Ears (Pointed and clear)
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- 5. Tail (A distinct curl wrapping around the feet)
-- Starts from the back (left) and curves around the bottom
c:path({{7,14}, {6,15}, {6,17}, {8,18}, {10,18}, {11,17}, {10,16}, {8,16}, {7,16}}, "mid")
c:px(6, 17, "hl") -- Highlight on tail tip

-- 6. Details (Eye, Nose, Stripes)
c:px(16, 8, "eye")      -- Eye
c:px(17, 9, "pink")     -- Nose
c:rect(8, 11, 1, 2, "dk") -- Stripe 1
c:rect(9, 12, 1, 2, "dk") -- Stripe 2
c:rect(10, 13, 1, 2, "dk") -- Stripe 3

-- 7. Highlights (Top-left light)
c:px(14, 6, "hl")
c:px(13, 8, "hl")
c:px(10, 11, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
