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

-- 1. Body (Sitting mass)
-- Positioned slightly left-center to allow tail room on the left
draw_shaded_ellipse(c, 11, 13, 5, 5, "mid", -1, -1)

-- 2. Head (High and to the right)
draw_shaded_ellipse(c, 15, 8, 3, 3, "mid", -1, -1)

-- 3. Ears (Pointed and distinct)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 4. Face Details
c:px(16, 8, "eye")      -- Eye
c:px(17, 9, "pink")     -- Nose
c:ellipse(17, 9.5, 1.5, 1, "white", true) -- Muzzle patch

-- 5. White Chest (Separated from muzzle)
c:ellipse(13, 14, 2, 3, "white", true)

-- 6. Tail (Separate curled shape at bottom left)
-- Using a clear path to ensure it doesn't smudge into the body
c:path({{8,14}, {6,14}, {5,15}, {5,17}, {7,18}, {9,17}, {10,16}}, "mid")
-- Shade the tail side away from light to make it read as a volume
c:path({{8,14}, {6,14}, {5,15}, {5,17}, {7,18}, {9,17}, {10,16}}, "dk")

-- 7. Tabby Stripes (Clear dark vertical bands on the back)
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
