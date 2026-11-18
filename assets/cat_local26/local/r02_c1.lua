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
                elseif color == "hl" then ctx:px(x, y, "lt")
                end
            end
        end
    end
end

-- 1. Body (Sitting profile, facing right)
-- Main torso/haunches (centered around 10, 12)
draw_shaded_ellipse(c, 10, 12, 4, 5, "mid", -1, -1)
-- Head (placed above and to the right of torso)
draw_shaded_ellipse(c, 14, 7, 3, 2.5, "lt", -1, -1)

-- 2. Ears (Pointed, on top of head)
c:poly({{13, 5}, {14, 3}, {15, 5}}, "dk")
c:poly({{15, 5}, {16, 3}, {17, 5}}, "dk")

-- 3. White Muzzle and Chest
c:ellipse(15, 7.5, 2, 1.5, "white", true) -- Muzzle
c:rect(11, 10, 3, 4, "white")           -- Chest

-- 4. Eye (Green, visible)
c:circle(15, 7, 0.6, "eye", true)

-- 5. Nose (Pink)
c:circle(16, 8, 0.4, "pink", true)

-- 6. Tail (Curling around feet at bottom)
-- Using a path to define the tail shape
c:path({{8, 14}, {6, 15}, {5, 13}, {6, 11}, {8, 11}}, "mid")
-- Simple shading for tail
c:path({{8, 14}, {6, 15}, {5, 13}, {6, 11}, {8, 11}}, "dk")

-- 7. Tabby Stripes (On the back/haunches)
c:rect(8, 10, 1, 2, "dk")
c:rect(9, 11, 1, 2, "dk")

-- 8. Paws (White, at the base)
c:ellipse(10, 17, 2.5, 1, "white", true)

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
