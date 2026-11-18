local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse to create volume
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, color, light_dx, light_dy)
    for y = math.floor(cy - ry + 0.5), math.ceil(cy + ry - 0.5) do
        for x = math.floor(cx - rx + 0.5), math.ceil(cx + rx + 0.5) do
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

-- 2. Head (Distinctly shaped for a cat facing right)
draw_shaded_ellipse(c, 15, 8, 3, 2.5, "mid", 1, 1)

-- 3. Muzzle and Chest (White patches)
-- Muzzle sticks out slightly to the right
c:ellipse(17, 9, 1.5, 1.5, "white", true)
-- Chest
c:ellipse(14, 13, 2, 3, "white", true)

-- 4. Ears (Large and pointed)
c:poly({{14,7}, {13,3}, {16,7}}, "mid")
c:poly({{16,7}, {17,3}, {19,7}}, "mid")

-- 5. Face details
c:px(17, 8, "eye")      -- Eye
c:px(18, 9, "pink")     -- Nose

-- 6. Tail (Clear separate curl wrapping around feet)
-- Using a path for a distinct "C" shape
c:path({{8,14}, {6,14}, {5,15}, {5,17}, {7,17}, {8,16}}, "mid")

-- 7. Tabby Stripes (Clean bands on the back)
c:rect(9, 10, 1, 2, "dk")
c:rect(8, 12, 1, 2, "dk")

-- 8. Paws/Feet (Visible under white chest)
c:rect(13, 17, 2, 1, "lt")
c:rect(15, 17, 2, 1, "lt")

-- 9. Highlights (Top-left edges only)
c:rect(12, 6, 3, 1, "hl") -- Top of head
c:rect(9, 10, 2, 1, "hl") -- Top of back

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
