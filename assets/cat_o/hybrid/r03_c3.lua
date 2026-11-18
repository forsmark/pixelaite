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
c:path({{14,8}, {17,7}, {18,9}, {18,12}, {15,15}, {14,12}, {14,9}}, "white")
-- Ears (Pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")
-- Eye
c:px(16, 8, "eye")
-- Nose
c:px(17, 9, "pink")

-- 3. Tabby Stripes (Goal 2: 2-3 distinct darker stripes on the back)
c:rect(9, 10, 1, 2, "dk")
c:rect(8, 13, 1, 2, "dk")
c:rect(10, 16, 1, 1, "dk")

-- 4. Tail (Goal 1: Unmistakable curled tail)
-- Tail starts from back and curls around feet
c:path({{8,13}, {6,13}, {5,14}, {5,16}, {6,17}, {8,17}, {10,17}, {11,16}, {10,15}}, "mid")
-- Tail shading/highlight
c:path({{7,13}, {6,14}, {6,15}, {7,16}, {8,16}, {9,16}, {9,15}, {8,14}}, "lt")

-- 5. Legs/Feet (Goal 3: Definition of front legs/paws)
-- Paws at the front of the white chest
c:ellipse(15, 16, 2, 1, "lt", true)

-- 6. Lighting highlights (Top-left)
c:px(14, 7, "hl") -- Head highlight
c:px(10, 10, "hl") -- Back highlight

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
