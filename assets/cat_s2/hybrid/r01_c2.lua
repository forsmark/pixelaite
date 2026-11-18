local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse to create volume
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test if pixel is in shadow by checking a shifted ellipse (light from top-left)
                local sdx = x - light_dx
                local sdy = y - light_dy
                local s_dx = sdx - cx
                local s_dy = sdy - cy
                local is_shadow = (s_dx*s_dx)/(rx*rx) + (s_dy*s_dy)/(ry*ry) > 1
                
                if is_shadow then
                    canvas:px(x, y, "dk")
                else
                    canvas:px(x, y, col)
                end
            end
        end
    end
end

-- 1. Body: Large sitting mass
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)

-- 2. Head: Smaller ellipse on top-right of body
draw_shaded_ellipse(c, 14, 8, 3, 2.5, "mid", 1, 1)

-- 3. White features: Muzzle and Chest
-- Muzzle (front of face)
c:ellipse(15.5, 9, 1.5, 1.5, "white", true)
-- Chest (bottom front of body)
c:ellipse(13, 14, 2, 3, "white", true)

-- 4. Ears: Pointed triangles
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- 5. Eye & Nose: Detail
c:px(15, 8, "eye")
c:px(16, 9, "pink")

-- 6. Tail: Curled around feet (using path for a smooth shape)
-- We use 'lt' for the tail to make it pop, with 'dk' for the shadow side
c:path({{10,15}, {8,16}, {6,15}, {6,13}, {8,12}, {10,12}}, "lt")
-- Shadow side of tail (right side of the thin tail)
c:path({{10,15}, {8,16}, {7,15}, {7,14}, {8,13}, {10,13}}, "dk")

-- 7. Tabby Stripes: Darker marks on the back
c:rect(9, 11, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")

-- 8. Highlights: Add a few 'hl' pixels for fur sheen
c:px(13, 7, "hl")
c:px(12, 11, "hl")
c:px(14, 13, "hl")

-- Final Outline: Creates the silhouette
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
