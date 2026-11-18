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
-- Main haunch/body mass
draw_shaded_ellipse(c, 11, 13, 4.5, 5, "mid", 1, 1)

-- 2. Head (Distinct shape facing right)
-- Head shape
draw_shaded_ellipse(c, 15, 8, 2.5, 2.5, "mid", 1, 1)
-- Muzzle (White protrusion)
c:ellipse(16.5, 9, 1.2, 1.2, "white", true)

-- 3. Ears (Pointed and clear)
c:poly({{14,7}, {14,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 4. Face Details
c:px(16, 8, "eye")      -- Eye
c:px(17, 9, "pink")     -- Nose

-- 5. Tail (Clear curl wrapping around feet)
-- We use a path with a consistent width to ensure it doesn't merge into the body
-- Tail starts from back (left), curls down and around to the front (right)
c:path({{8,13}, {7,14}, {7,16}, {9,17}, {11,17}, {12,16}, {11,15}, {9,15}, {8,15}}, "mid")

-- 6. Tabby Stripes (Clean, deliberate bands on the back)
c:rect(9, 10, 1, 2, "dk")
c:rect(10, 10, 1, 2, "dk")

-- 7. Chest and Paws (White patches and visible legs)
-- Chest
c:ellipse(13, 13, 2, 3, "white", true)
-- Paws/Legs visible under white chest
c:rect(12, 17, 1, 1, "lt")
c:rect(14, 17, 1, 1, "lt")

-- 8. Highlights (Top-left edges only)
c:rect(10, 10, 2, 1, "hl") -- Back highlight
c:rect(14, 6, 2, 1, "hl") -- Top of head highlight

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
