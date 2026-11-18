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

-- 1. Body (Large sitting mass)
draw_shaded_ellipse(c, 11, 13, 4.5, 5, "mid", 1, 1)

-- 2. Head (Improved: Larger, clearer face turned right)
-- Head base
draw_shaded_ellipse(c, 15, 8, 3.2, 2.8, "mid", 1, 1)
-- Muzzle (Extending further right to define the snout)
c:ellipse(17, 9, 1.8, 1.5, "white", true)
-- Chin/Neck area
c:ellipse(16, 10, 1.5, 1, "white", true)

-- 3. Ears (Improved: Larger, distinct pointed ears)
c:poly({{14,7}, {13,3}, {16,7}}, "mid") -- Left ear (back)
c:poly({{16,7}, {18,3}, {19,7}}, "mid") -- Right ear (front)

-- 4. Face details (Improved: Clearer eye and nose position)
c:px(17, 8, "eye")      -- Eye placed on the snout area
c:px(18, 9, "pink")     -- Nose at the tip of the muzzle

-- 5. Chest (White patch)
c:ellipse(13, 13, 2.2, 3, "white", true)

-- 6. Tail (Improved: Curled around front feet, distinct from body)
-- Using a thick path to represent the tail curling from the back around the bottom
c:path({{8,13}, {6,14}, {5,16}, {7,17}, {9,17}, {10,16}}, "mid")

-- 7. Tabby Stripes (Improved: 3 clean bands on the back)
c:rect(8, 11, 1, 2, "dk")
c:rect(9, 12, 1, 2, "dk")
c:rect(10, 13, 1, 2, "dk")

-- 8. Paws/Feet (Visible under the white chest)
c:rect(12, 17, 2, 1, "lt")
c:rect(14, 17, 2, 1, "lt")

-- 9. Highlights (Top-left edge shading)
c:rect(13, 6, 3, 1, "hl") -- Top of head
c:rect(10, 10, 2, 1, "hl") -- Top of back

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
