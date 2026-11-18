local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded volume
-- Instead of just swapping colors, we use the ellipse test to determine if a pixel
-- is in the 'lit' part or 'shadow' part of the shape.
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col_lit, col_shd)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx, dy = x - cx, y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Light from top-left (dx-1, dy-1)
                -- Test if the pixel is outside the ellipse shifted toward the light
                local sdx, sdy = x - 1.5, y - 1.5
                local s_dx, s_dy = sdx - cx, sdy - cy
                local is_shadow = (s_dx*s_dx)/(rx*rx) + (s_dy*s_dy)/(ry*ry) > 1
                canvas:px(x, y, is_shadow and col_shd or col_lit)
            end
        end
    end
end

-- 1. Tail (behind body, so drawn first)
-- A thick curved tail curling around the bottom
c:path({{11,15}, {8,16}, {6,15}, {5,13}, {6,12}, {8,12}}, "mid")

-- 2. Body (Sitting)
-- Large oval for the torso
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", "dk")

-- 3. Head
-- Head oval
draw_shaded_ellipse(c, 15, 8, 3, 2.5, "mid", "dk")
-- Ears (Triangles)
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- 4. Face details
c:px(16, 8, "eye")        -- Eye
c:px(17, 9, "pink")       -- Nose
-- White muzzle/chest (drawn on top of body)
c:ellipse(16, 10, 2, 1.5, "white", true)
c:ellipse(14, 13, 1.5, 3, "white", true)

-- 5. Markings (Stripes and highlights)
-- Dark stripes on back
c:rect(10, 11, 1, 2, "dk")
c:rect(9, 13, 1, 1, "dk")
-- Light highlights on top of head/back
c:px(15, 6, "hl")
c:px(14, 10, "hl")

-- 6. Paws (Front legs visible)
c:rect(13, 16, 3, 1, "lt")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
