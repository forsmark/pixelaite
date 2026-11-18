local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse (volume-based shading)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test if the pixel is in the shadow of the light source
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

-- 1. Body (Sitting posture, facing right)
-- Main torso (Large ellipse)
draw_shaded_ellipse(c, 11, 13, 4.5, 5, "mid", 1, 1)
-- Head
draw_shaded_ellipse(c, 15, 8, 3, 2.8, "mid", 1, 1)

-- 2. Details
-- White muzzle and chest area (Connected shape)
c:path({{14,7}, {17,7}, {18,9}, {17,11}, {15,14}, {13,14}, {13,9}}, "white")
-- Ears (Pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")
-- Eye
c:px(16, 8, "eye")
-- Nose
c:px(17, 9, "pink")

-- 3. Stripes (Darker tabby markings on the back/torso)
-- Making them more distinct as requested
c:rect(9, 10, 1, 1, "dk")
c:rect(8, 12, 1, 1, "dk")
c:rect(9, 14, 1, 1, "dk")

-- 4. Tail (Curled around feet)
-- Distinct tail shape wrapping around the front
c:path({{9,15}, {7,15}, {6,14}, {6,12}, {7,11}, {9,11}, {10,12}, {9,14}}, "mid")
-- Add a highlight to tail
c:path({{8,15}, {7,15}, {6,14}, {7,13}}, "lt")

-- 5. Legs/Feet (Defining the front paws/chest boundary)
-- Front paws area (Separated from main body to show depth)
c:ellipse(13, 16, 2, 1, "lt", true)

-- 6. Lighting highlights (Top-left)
c:px(14, 7, "hl") -- Head highlight
c:px(10, 10, "hl") -- Back highlight

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
