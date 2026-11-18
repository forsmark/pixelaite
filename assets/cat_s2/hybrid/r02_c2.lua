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

-- 1. BODY & HAUNCHES
-- Main sitting mass
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)
-- Tail base connection
c:rect(7, 14, 3, 2, "mid")

-- 2. WHITE CHEST & MUZZLE (Clean bib)
-- Chest bib
c:ellipse(13, 13, 2.5, 3.5, "white", true)
-- Muzzle area
c:ellipse(15, 8, 2, 1.5, "white", true)

-- 3. HEAD
-- Head shape
draw_shaded_ellipse(c, 15, 7, 3, 2.5, "mid", 1, 1)
-- Ears
c:poly({{13,6}, {14,3}, {15,6}}, "mid")
c:poly({{15,6}, {16,3}, {17,6}}, "mid")
-- Face details
c:px(16, 7, "eye")
c:px(17, 8, "pink")

-- 4. TABBY STRIPES (Deliberate bands)
c:rect(8, 11, 1, 2, "dk")  -- Back stripe 1
c:rect(9, 13, 1, 2, "dk")  -- Back stripe 2
c:rect(14, 5, 1, 1, "dk")  -- Forehead stripe

-- 5. TAIL (Clean curl around feet)
-- Drawing the tail as a distinct path to ensure it wraps the bottom
-- Tail starts from back, curves down and around the front paws
c:path({{7,14}, {5,15}, {5,17}, {7,18}, {9,17}, {9,16}, {7,16}, {6,16}, {6,15}, {8,14}}, "lt")
-- Add a bit of shading to the tail to separate it
c:path({{5,15}, {5,17}, {6,17}, {6,15}}, "dk")

-- 6. PAWS (Visible at the bottom of the white chest)
c:ellipse(13, 17, 2, 1, "white", true)
c:ellipse(15, 17, 2, 1, "white", true)

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
