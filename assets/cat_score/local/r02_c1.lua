local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse to provide volume
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

-- Body (Sitting posture, facing RIGHT)
-- Main torso (centered roughly at 11, 13)
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)

-- Head (positioned at the top right of the body)
draw_shaded_ellipse(c, 14, 8, 3, 3, "mid", 1, 1)

-- Ears (Pointed)
c:poly({{12,7}, {13,4}, {14,7}}, "mid") -- Left ear (back)
c:poly({{14,7}, {15,4}, {16,7}}, "mid") -- Right ear (front)

-- Face details
c:px(15, 8, "eye")      -- Green eye
c:px(16, 9, "pink")     -- Nose
c:ellipse(16, 10, 2, 1.5, "white", true) -- White muzzle

-- White chest area
c:ellipse(13, 13, 2, 3, "white", true)

-- Stripes on back (darker tabby stripes)
c:rect(8, 11, 1, 2, "dk")
c:rect(7, 13, 1, 2, "dk")

-- Tail (curls around the front feet)
-- A path that starts from the back, curves down and around
c:path({{7,14}, {6,16}, {8,17}, {10,17}, {11,16}}, "mid")

-- Feet/Legs (simplified sitting base)
c:rect(11, 16, 3, 2, "lt")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
