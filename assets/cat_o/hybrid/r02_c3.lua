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
-- Main torso
draw_shaded_ellipse(c, 11, 13, 4.5, 5, "mid", 1, 1)
-- Head
draw_shaded_ellipse(c, 15, 8, 3, 2.8, "mid", 1, 1)

-- 2. Details & Goal 2: Separate White Bib/Chest from Paws
-- White muzzle and chest area (running down from muzzle to chest)
c:ellipse(16, 9, 1.8, 1.5, "white", true) -- Muzzle
c:path({{15,10}, {16,13}, {17,14}, {18,13}, {17,10}}, "white") -- Chest bib

-- Ears (Pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- Eye & Nose
c:px(16, 8, "eye")
c:px(17, 9, "pink")

-- 3. Stripes (Goal 3: Deliberate, evenly spaced bands)
c:rect(8, 11, 1, 2, "dk")
c:rect(9, 13, 1, 2, "dk")
c:rect(10, 15, 1, 1, "dk")

-- 4. Tail (Goal 1: Clear dark-edged band sweeping from rear)
-- Tail base at rear, curling around to front feet
c:path({{8,14}, {6,15}, {5,15}, {5,13}, {6,12}, {8,12}}, "mid")
c:path({{7,14}, {6,14}, {5,13}, {6,13}}, "lt") -- Tail highlight

-- 5. Legs/Feet (Goal 2: Paws sit under the bib as separate shapes)
-- Front paws
c:ellipse(14, 16, 2, 1, "lt", true)
-- Back leg/rump area
c:ellipse(9, 15, 2, 1.5, "dk", true)

-- 6. Lighting highlights (Top-left)
c:px(14, 7, "hl") 
c:px(10, 10, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
