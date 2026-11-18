local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse (using the technique requested)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx, dy = x - cx, y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test the same ellipse moved toward light for shadow
                local sdx, sdy = x - light_dx, y - light_dy
                local s_dx, s_dy = sdx - cx, sdy - cy
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

-- Composition: Subject centered, respecting 1px margin (y=1 to y=18)
-- Body (Sitting posture)
-- Main torso/rump
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)
-- Head
draw_shaded_ellipse(c, 15, 8, 3, 3, "mid", 1, 1)

-- Ears (Pointed)
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- Details
c:px(16, 8, "eye")    -- Eye
c:px(17, 9, "pink")   -- Nose
c:ellipse(17, 10, 2, 1.5, "white", true) -- White muzzle/chest area

-- Tail (curls around front feet)
-- Using a path to define the curve of the tail
c:path({{9,15}, {7,15}, {6,14}, {6,12}, {8,11}, {10,11}}, "mid")

-- Tabby Stripes on back
c:rect(9, 11, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")

-- Legs/Feet (Visible under belly)
c:rect(11, 17, 3, 1, "lt")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
