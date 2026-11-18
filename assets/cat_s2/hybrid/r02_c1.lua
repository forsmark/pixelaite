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
                    if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) < 0.4 then
                        canvas:px(x, y, "hl")
                    else
                        canvas:px(x, y, col)
                    end
                end
            end
        end
    end
end

-- Body (Sitting posture)
-- Main torso
draw_shaded_ellipse(c, 11, 12, 4, 5, "mid", 1, 1)

-- Head (Refined shape)
draw_shaded_ellipse(c, 14, 7, 3, 2.5, "mid", 1, 1)

-- White Muzzle and Chest (Cleaned up to be a solid bib)
c:ellipse(15, 8, 2, 1.5, "white", true) -- Muzzle
c:ellipse(13, 12, 2.5, 3.5, "white", true) -- Large clean chest bib

-- Ears (Pointed)
c:poly({{13,6}, {14,3}, {15,6}}, "mid")
c:poly({{15,6}, {16,3}, {17,6}}, "mid")

-- Eye and Nose
c:px(15, 7, "eye")
c:px(16, 8, "pink")

-- Tail (Refined: clean curl with clear tip and separation)
c:path({{9,15}, {7,15}, {6,14}, {6,12}, {7,11}, {9,11}, {10,12}}, "mid")
-- Tail tip highlight
c:px(6, 13, "hl")

-- Tabby stripes (Deliberate bands on back)
c:rect(9, 10, 1, 2, "dk")
c:rect(8, 12, 1, 2, "dk")
c:rect(13, 5, 1, 1, "dk") -- forehead stripe

-- Legs/Feet area (Integrated with white chest)
c:ellipse(11, 16, 3, 1.5, "lt", 1, 1)

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
