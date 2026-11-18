local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse (Volume technique)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test a light-shifted ellipse for shading
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

-- 1. Body (Torso) - Separated from head
-- Main sitting mass
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)

-- 2. Head - Distinct from body
-- Head base
draw_shaded_ellipse(c, 14, 8, 2.5, 2.5, "mid", 1, 1)

-- Ears (Pointed, sitting on top of head)
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- Facial features
c:px(15, 8, "eye")
c:px(16, 9, "pink")
-- White muzzle/chest area
c:ellipse(15, 9.5, 1.5, 1.5, "white", true)

-- 3. Stripes (Distinct bands on back)
c:rect(8, 11, 1, 1, "dk")
c:rect(8, 13, 1, 1, "dk")
c:rect(8, 15, 1, 1, "dk")

-- 4. Tail (Separate curl wrapped around feet)
-- Drawn with a distinct color/path to avoid merging with body mass
c:path({{9,15}, {7,15}, {6,14}, {6,12}, {7,11}, {9,11}, {10,12}}, "lt")

-- 5. Feet/Base
c:rect(10, 17, 3, 1, "lt")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
