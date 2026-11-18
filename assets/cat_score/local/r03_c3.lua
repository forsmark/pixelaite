local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse to give round volume
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test light-shifted ellipse for shading
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

-- 1. Body (Sitting posture)
-- Main torso/rump
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)
-- Head
draw_shaded_ellipse(c, 15, 8, 3, 2.5, "mid", 1, 1)

-- 2. Details
-- Ears (pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- Eye & Nose
c:px(16, 8, "eye")
c:px(17, 9, "pink")

-- White muzzle and chest
c:ellipse(16, 9.5, 2, 1.5, "white", true)
c:rect(13, 11, 2, 3, "white")

-- Tabby Stripes (on the back/side)
c:rect(9, 11, 1, 2, "dk")
c:rect(10, 13, 1, 2, "dk")

-- 3. Tail (Curling around the front feet)
-- Using a path to create a thick, curved tail
c:path({{8,14}, {7,15}, {7,17}, {9,17}, {10,16}, {9,15}, {8,15}}, "mid")

-- 4. Paws (Bottom of the sitting shape)
c:rect(11, 17, 4, 1, "lt")

-- Final Outline layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
