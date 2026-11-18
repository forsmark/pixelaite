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

-- 1. Body (Sitting posture, facing right)
-- Main haunches/body sitting on the ground
draw_shaded_ellipse(c, 11, 13, 4, 4, "mid", -1, -1)
-- Upper torso
draw_shaded_ellipse(c, 13, 10, 3, 4, "lt", -1, -1)

-- 2. Head
-- Head shape
draw_shaded_ellipse(c, 15, 7, 3, 2.5, "lt", -1, -1)
-- Ears (pointed)
c:poly({{14, 6}, {15, 3}, {16, 5}}, "dk")
c:poly({{16, 5}, {17, 3}, {18, 6}}, "dk")

-- 3. Facial Features
-- White muzzle area
c:ellipse(16, 8, 2, 1.5, "white", true)
-- Eye (facing right)
c:circle(16, 7, 0.6, "eye", true)
-- Nose
c:circle(17, 7.5, 0.4, "pink", true)

-- 4. Chest and Belly (White)
c:rect(13, 11, 2, 4, "white")
c:ellipse(13, 15, 3, 1.5, "white", true)

-- 5. Tail (Curling around the front feet)
-- Using a thick path for a 2px wide feel
c:path({{9, 14}, {8, 15}, {8, 17}, {10, 17}, {12, 16}}, "mid")
-- Shading the tail
c:path({{9, 14}, {8, 15}, {8, 17}, {10, 17}, {12, 16}}, "dk")

-- 6. Tabby Stripes (Darker stripes on the back/torso)
c:rect(11, 9, 1, 2, "dk")
c:rect(12, 10, 1, 2, "dk")

-- 7. Paws (White)
c:circle(11, 17, 1.5, "white", true)

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
