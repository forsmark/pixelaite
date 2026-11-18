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

-- 1. Body (Seated Mass)
-- Main torso
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", -1, -1)

-- 2. Head & Ears
-- Head
draw_shaded_ellipse(c, 15, 8, 2.5, 2.5, "mid", -1, -1)
-- Ears (Pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")
-- Eye & Nose
c:px(16, 8, "eye")
c:px(17, 9, "pink")

-- 3. White Chest/Muzzle (Clearer separation)
-- Chest bib (lower part of face/neck)
c:ellipse(14, 12, 2, 3, "white", true)
-- Muzzle (front of face)
c:ellipse(16, 9, 1.5, 1, "white", true)

-- 4. Tail (Clearly curling from back, around feet)
-- Tail starts at the back (left side of body) and curves down and around
-- We use a path to define the center line of the tail for a distinct shape
c:path({{8,13}, {6,14}, {5,16}, {7,17}, {9,16}}, "mid")
-- Add some shading to the tail to give it volume
c:path({{8,13}, {6,14}, {5,16}, {7,17}, {9,16}}, "dk")

-- 5. Tabby Stripes (Distinct bands on the back)
-- Three distinct dark bands on the upper back/side
c:rect(9, 11, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")
c:rect(10, 10, 1, 1, "dk")

-- 6. Highlights (Top-left light)
c:px(14, 7, "hl")
c:px(13, 11, "hl")
c:px(15, 6, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
