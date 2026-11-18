local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded ellipse (Volume technique)
local function draw_shaded_ellipse(canvas, cx, cy, rx, ry, col, light_dx, light_dy)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx = x - cx
            local dy = y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Test a light-shifted ellipse for shading
                local sdx = x - light_dx
                local sdy = y - light_dy
                local s_dx = sdx - cx
                local s_dy = sdy - cy
                local is_shadow = (s_dx*s_dx)/(rx*rx) + (s_dy*s_dy)/(ry*ry) > 1
                
                if is_shadow then
                    -- Use dark for shadow, but don't overwrite if it's a white area
                    if canvas:get(x,y) ~= "white" then
                        canvas:px(x, y, "dk")
                    end
                else
                    canvas:px(x, y, col)
                end
            end
        end
    end
end

-- 1. Body (Main sitting mass)
-- We use a slightly larger ellipse for the body to ensure a clear silhouette
draw_shaded_ellipse(c, 11, 13, 4, 5, "mid", 1, 1)

-- 2. Head (Separated from body)
-- We draw the head slightly offset to prevent merging with the back
draw_shaded_ellipse(c, 14, 8, 2.5, 2.5, "mid", 1, 1)

-- 3. Ears (Pointed)
c:poly({{13,7}, {14,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")

-- 4. Face Details
c:px(15, 8, "eye")     -- Green eye
c:px(16, 9, "pink")    -- Tiny nose
c:ellipse(16, 10, 1.5, 1, "white", true) -- White muzzle

-- 5. Tabby Stripes (Clearly on the back/left side)
c:rect(8, 11, 1, 2, "dk")
c:rect(9, 13, 1, 2, "dk")

-- 6. Tail (Curled around the front/bottom)
-- Using a path to make it look like a distinct limb curling forward
c:path({{9,14}, {7,15}, {6,16}, {7,17}, {9,16}, {10,15}}, "mid")

-- 7. Paws (Distinct from the body mass)
-- Drawing small rectangles at the base to define the front feet
c:rect(13, 16, 3, 1, "lt")
c:rect(12, 17, 2, 1, "lt")

-- 8. Lighting highlights
-- Adding small 'hl' pixels to the top-left edges for pop
c:px(12, 7, "hl")
c:px(13, 6, "hl")
c:px(10, 10, "hl")

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
