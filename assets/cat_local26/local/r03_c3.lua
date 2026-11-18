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
-- Large haunch/body mass
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", -1, -1)
-- Head
draw_shaded_ellipse(c, 15, 8, 2.5, 2.2, "lt", -1, -1)

-- 2. Ears (Pointed, on top of head)
-- Left ear (back)
c:poly({{14, 7}, {14, 5}, {15, 7}}, "dk")
-- Right ear (front)
c:poly({{15, 7}, {16, 5}, {17, 7}}, "dk")

-- 3. White Muzzle and Chest (Front of cat)
-- Muzzle/Chin
c:circle(16, 8.5, 1, "white", true)
-- Chest/Neck
c:rect(15, 10, 2, 4, "white")

-- 4. Eye and Nose
c:circle(16, 8, 0.5, "eye", true)
c:rect(16, 9, 0.5, 0.5, "pink")

-- 5. Tail (Curling around front feet)
-- Tail starts from back and curves to the bottom left
c:path({{7, 14}, {6, 15}, {7, 16}, {9, 17}, {11, 17}}, "mid")
-- Tail shading/detail
c:rect(7, 15, 1, 1, "dk")

-- 6. Tabby Stripes (On the back/haunches)
c:rect(9, 11, 1, 2, "dk")
c:rect(10, 13, 1, 2, "dk")

-- 7. Paws (White, tucked under)
c:ellipse(11, 17, 2, 0.8, "white", true)

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
