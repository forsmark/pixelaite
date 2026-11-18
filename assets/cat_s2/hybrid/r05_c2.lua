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

-- 1. Body & Torso
draw_shaded_ellipse(c, 11, 12, 4, 5, "mid", 1, 1)

-- 2. Head & Face
draw_shaded_ellipse(c, 14, 7, 3, 2.5, "mid", 1, 1)
c:px(15, 7, "eye")
c:px(16, 8, "pink")
c:ellipse(15, 8.5, 1.5, 1, "white", true) -- Muzzle

-- 3. White Chest
c:ellipse(11, 13, 2, 3, "white", true)

-- 4. Ears
c:poly({{13,6}, {14,3}, {15,6}}, "mid")
c:poly({{15,6}, {16,3}, {17,6}}, "mid")

-- 5. Tabby Stripes (Distinct dark lines on back)
c:rect(9, 10, 1, 1, "dk")
c:rect(8, 12, 1, 1, "dk")
c:rect(9, 14, 1, 1, "dk")

-- 6. Tail (A clear curl wrapping around the feet)
-- We draw the tail as a separate curved path to ensure it doesn't merge into a blob
c:path({{9,15}, {7,15}, {6,14}, {6,12}, {7,11}, {9,11}}, "mid")
-- Add some shading to the tail to make it look round
c:path({{9,15}, {7,15}, {6,14}, {6,12}, {7,11}, {9,11}}, "dk", false) 
-- Wait, the path tool doesn't support easy shading. Let's use pixels for a cleaner tail.
c:px(8, 15, "mid"); c:px(7, 15, "mid"); c:px(6, 14, "mid"); c:px(6, 13, "mid"); c:px(6, 12, "mid"); c:px(7, 11, "mid"); c:px(8, 11, "mid"); c:px(9, 11, "mid")
c:px(7, 15, "dk"); c:px(6, 14, "dk"); c:px(6, 13, "dk"); c:px(6, 12, "dk"); c:px(7, 11, "dk") -- Shadow side of tail

-- 7. Feet (Bottom of the silhouette)
c:ellipse(12, 16, 3, 1.5, "lt", 1, 1)
c:px(13, 17, "dk") -- Shadow on the bottom right foot area

-- Final Outline
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
