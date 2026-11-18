local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse to create round volume
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
                    -- Use hl for highlight if it's very close to light, else col
                    if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) < 0.3 then
                        canvas:px(x, y, "hl")
                    else
                        canvas:px(x, y, col)
                    end
                end
            end
        end
    end
end

-- 1. Body (Sitting posture)
-- Main torso (Sitting upright)
draw_shaded_ellipse(c, 11, 12, 4, 5, "mid", 1, 1)

-- 2. Head
-- Smoother head shape
draw_shaded_ellipse(c, 14, 7, 3, 2.5, "mid", 1, 1)

-- Ears (Pointed)
c:poly({{13,6}, {14,3}, {15,6}}, "mid")
c:poly({{15,6}, {16,3}, {17,6}}, "mid")

-- Eye and Nose
c:px(15, 7, "eye")
c:px(16, 8, "pink")

-- 3. White Muzzle and Chest (Clean bib/chest area)
-- Muzzle (Front of face)
c:ellipse(15.5, 8, 1.5, 1.2, "white", true)
-- Chest/Bib (Clean white area on front of body)
c:ellipse(13, 12, 1.5, 3, "white", true)

-- 4. Tabby Stripes (Deliberate bands on back)
c:rect(9, 10, 1, 2, "dk")
c:rect(8, 12, 1, 2, "dk")
c:rect(14, 5, 1, 1, "dk") -- stripe on head

-- 5. Tail (Curled around front feet)
-- A single clean path for the tail
c:path({{10,15}, {8,16}, {6,15}, {6,13}, {8,12}, {10,12}}, "mid")

-- 6. Legs/Feet area (Paws)
c:ellipse(11, 16, 3, 1.5, "lt", 1, 1)

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
