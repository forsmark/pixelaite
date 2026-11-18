local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse to create volume
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, color, light_dx, light_dy)
    for y = math.floor(cy - ry + 0.5), math.ceil(cy + ry - 0.5) do
        for x = math.floor(cx - rx + 0.5), math.ceil(cx + rx - 0.5) do
            local dx, dy = x - cx, y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Shadow test: shift ellipse toward light (top-left)
                local sdx, sdy = x - light_dx, y - light_dy
                local s_dx, s_dy = sdx - cx, sdy - cy
                local is_shadow = (s_dx*s_dx)/(rx*rx) + (s_dy*s_dy)/(ry*ry) > 1
                
                if is_shadow then
                    canvas:px(x, y, "dk")
                else
                    canvas:px(x, y, color)
                end
            end
        end
    end
end

-- 1. Body (Sitting mass)
draw_shaded_ellipse(c, 11, 13, 4.5, 5, "mid", 1, 1)

-- 2. Head (Larger and rounder)
draw_shaded_ellipse(c, 14, 8, 3.5, 3, "mid", 1, 1)

-- 3. Muzzle and Chest (White patches)
c:ellipse(15.5, 9, 1.8, 1.5, "white", true) -- Muzzle
c:ellipse(13, 13, 2.5, 3.5, "white", true) -- Chest/Front legs

-- 4. Ears (Separated and pointed)
c:poly({{12.5,7}, {12,4}, {14,7}}, "mid") -- Left ear
c:poly({{15,7}, {16.5,4}, {17,7}}, "mid") -- Right ear
c:px(12,5, "hl") -- Ear highlight
c:px(16,5, "hl")

-- 5. Face details
c:px(15, 8, "eye")      -- Eye
c:px(16.5, 9, "pink")   -- Nose

-- 6. Tail (Distinct curl wrapping around front)
-- Drawn as a path that curves from the back to the front feet
c:path({{8,13}, {6,13}, {5,15}, {6,17}, {8,17}}, "mid")
c:path({{8,13}, {6,13}, {5,15}, {6,17}, {8,17}}, "hl") -- Tail highlight

-- 7. Tabby Stripes (Deliberate bands on back)
c:rect(9, 10, 1, 2, "dk")
c:rect(8, 12, 1, 2, "dk")

-- 8. Paws/Feet (Defined bottom)
c:rect(11, 17, 3, 1, "lt") -- Back paw
c:rect(14, 17, 2, 1, "white") -- Front paw visible through white chest

-- 9. Highlights (Top edges)
c:rect(12, 6, 4, 1, "hl") -- Head highlight
c:rect(9, 10, 2, 1, "hl") -- Back highlight

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
