local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for round volume shading
local function draw_shaded_ellipse(ctx, cx, cy, rx, ry, color, light_dx, light_dy)
    ctx:ellipse(cx, cy, rx, ry, color, true)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx, dy = x - cx, y - cy
            local dist_sq = (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry)
            local sdx, sdy = x - (cx + light_dx), y - (cy + light_dy)
            local sdist_sq = (sdx*sdx)/(rx*rx) + (sdy*sdy)/(ry*ry)
            
            if dist_sq <= 1 and sdist_sq > 1 then
                if color == "lt" then ctx:px(x, y, "mid")
                elseif color == "mid" then ctx:px(x, y, "dk")
                elseif color == "hl" then ctx:px(x, y, "lt") end
            end
        end
    end
end

-- 1. Body (Sitting profile, facing RIGHT)
-- Main torso/haunches (Vertical sitting posture)
draw_shaded_ellipse(c, 10, 12, 4, 5, "mid", -1, -1)

-- 2. Head (Positioned above/front of body)
draw_shaded_ellipse(c, 14, 7, 3, 2.5, "lt", -1, -1)

-- 3. Ears (Pointed, on top of head)
-- Left ear (back)
c:poly({{13, 5}, {14, 3}, {15, 5}}, "dk")
-- Right ear (front)
c:poly({{15, 5}, {16, 3}, {17, 5}}, "dk")

-- 4. White Muzzle and Chest (Front of cat)
-- Chest area
c:rect(14, 10, 2, 5, "white") 
-- Muzzle/Chin
c:ellipse(15, 8, 2, 1.5, "white", true)

-- 5. Eye and Nose
c:circle(16, 7, 0.6, "eye", true)
c:circle(17, 8, 0.4, "pink", true)

-- 6. Tail (Curling around feet at bottom left)
-- A curved path for the tail
c:path({{7, 15}, {6, 16}, {7, 17}, {9, 17}, {10, 16}}, "mid")
-- Tail stripe
c:rect(7, 16, 1, 1, "dk")

-- 7. Tabby Stripes (On the back)
c:rect(8, 10, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")

-- 8. Paws (White, tucked in front/bottom)
c:ellipse(13, 16, 2, 1, "white", true)

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
