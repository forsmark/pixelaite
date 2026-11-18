local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse (volume-based shading)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx, dy = x - cx, y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test shadow: pixel is shadow if it's outside the ellipse when shifted toward light
                local sdx, sdy = x - light_dx - cx, y - light_dy - cy
                local is_shadow = (sdx*sdx)/(rx*rx) + (sdy*sdy)/(ry*ry) > 1
                canvas:px(x, y, is_shadow and "dk" or col)
            end
        end
    end
end

-- 1. Body & Neck (Separated silhouette)
-- Main torso
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)
-- Head (positioned higher to create neck dip)
draw_shaded_ellipse(c, 15, 7, 2.5, 2.5, "mid", 1, 1)

-- 2. White Bib & Muzzle (Distinct shapes)
-- Muzzle
c:ellipse(16, 7, 1.5, 1.2, "white", true)
-- Chest/Bib (Running down from muzzle)
c:path({{15,8}, {14,10}, {14,14}, {15,15}, {16,15}, {17,14}, {17,10}}, "white", true)

-- 3. Tail (Clear dark-edged band sweeping from rear to front feet)
-- The tail wraps from the back (left) around the bottom/front
c:path({{8,14}, {7,14}, {6,15}, {6,17}, {8,18}, {10,18}, {12,17}, {12,16}, {10,16}, {9,16}, {9,15}, {8,15}}, "mid")
-- Tail shading/detail
c:path({{7,14}, {6,15}, {6,16}, {7,16}, {8,15}}, "dk")

-- 4. Feet (Separate from white chest)
c:ellipse(13, 17, 2, 1, "lt", true)
c:ellipse(15, 17, 2, 1, "lt", true)

-- 5. Head Details
-- Ears
c:poly({{14,6}, {15,3}, {16,6}}, "mid")
c:poly({{16,6}, {17,4}, {17,6}}, "mid")
-- Eye
c:px(16, 7, "eye")
-- Nose
c:px(17, 8, "pink")

-- 6. Tabby Stripes (3 deliberate bands on the back)
c:rect(8, 11, 1, 2, "dk")
c:rect(9, 13, 1, 2, "dk")
c:rect(10, 15, 1, 1, "dk")

-- 7. Lighting Highlights (Top-left)
c:px(14, 5, "hl") -- Head
c:px(10, 10, "hl") -- Back
c:px(13, 13, "hl") -- Shoulder/Chest edge

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
