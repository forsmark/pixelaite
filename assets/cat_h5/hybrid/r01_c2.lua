local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse using the "test shifted ellipse" technique
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col_main, col_shadow, light_dx, light_dy)
    for y = math.floor(cy - ry + 0.5), math.ceil(cy + ry + 0.5) do
        for x = math.floor(cx - rx + 0.5), math.ceil(cx + rx + 0.5) do
            local dx, dy = x - cx, y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Check if pixel is in shadow by testing ellipse shifted towards light
                local sdx, sdy = x - light_dx, y - light_dy
                local s_dx, s_dy = sdx - cx, sdy - cy
                local is_shadow = (s_dx*s_dx)/(rx*rx) + (s_dy*s_dy)/(ry*ry) > 1
                canvas:px(x, y, is_shadow and col_shadow or col_main)
            end
        end
    end
end

-- 1. Body (Sitting posture)
-- Main torso: Large ellipse
draw_shaded_ellipse(c, 11, 12, 4.5, 5, "mid", "dk", 1, 1)

-- 2. Head
-- Head base
draw_shaded_ellipse(c, 14, 7, 3, 2.5, "mid", "dk", 1, 1)
-- Muzzle/White area (front of face)
c:ellipse(15.5, 8, 1.5, 1.5, "white", true)
-- Ears (pointed)
c:poly({{13,6}, {12,3}, {14,5}}, "mid")
c:poly({{15,6}, {16,3}, {17,5}}, "mid")
-- Eye (facing right)
c:px(15, 7, "eye")
-- Nose
c:px(16, 8, "pink")

-- 3. Tail (Curled around feet)
-- Using a thick path for the tail
c:path({{8,15}, {7,16}, {6,15}, {6,13}, {7,12}, {9,12}}, "mid")
-- Tail shading (light from top-left)
c:path({{8,15}, {7,16}, {6,15}, {6,13}, {7,12}, {9,12}}, "dk", true)

-- 4. Stripes (on the back/top of body)
c:rect(9, 10, 1, 2, "dk")
c:rect(10, 9, 1, 2, "dk")

-- 5. Chest/Belly (White)
c:rect(13, 11, 2, 4, "white")

-- 6. Feet (Front paws visible)
c:ellipse(13, 16, 2, 1, "lt", true)

-- 7. Accents (High-light on top edges)
c:rect(11, 9, 3, 1, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
