local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for round volume shading
local function draw_shaded_ellipse(ctx, cx, cy, rx, ry, color, light_dx, light_dy)
    -- Draw base shape
    ctx:ellipse(cx, cy, rx, ry, color, true)
    -- Shading: pixels outside a slightly shifted ellipse are darker
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            local dist_sq = (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry)
            
            local sdx = x - (cx + light_dx)
            local sdy = y - (cy + light_dy)
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

-- 1. Body (sitting profile)
-- Main torso/haunches
draw_shaded_ellipse(c, 12, 13, 4, 5, "mid", -1, -1)
-- Head
draw_shaded_ellipse(c, 15, 8, 3, 3, "lt", -1, -1)
-- Ears
c:poly({{14, 6}, {15, 4}, {16, 6}}, "dk")
c:poly({{16, 6}, {17, 4}, {18, 6}}, "dk")

-- 2. White Muzzle and Chest
c:ellipse(16, 9, 1.5, 1.5, "white", true)
c:rect(14, 10, 2, 5, "white")

-- 3. Eye
c:circle(16, 8, 0.7, "eye", true)

-- 4. Tail (curls around feet)
-- A curved path for the tail
c:path({{10, 15}, {8, 16}, {7, 14}, {8, 12}, {10, 12}}, "mid")
-- Tail shading (simplified)
c:path({{10, 15}, {8, 16}, {7, 14}, {8, 12}, {10, 12}}, "dk")

-- 5. Tabby Stripes (on the back)
c:rect(10, 11, 1, 2, "dk")
c:rect(11, 12, 1, 2, "dk")

-- 6. Nose/Mouth
c:circle(17, 9.5, 0.5, "pink", true)

-- 7. Paws (White)
c:ellipse(12, 17, 2, 1, "white", true)

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
