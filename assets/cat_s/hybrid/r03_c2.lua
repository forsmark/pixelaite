local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for shaded volume
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

-- 1. Tail (Drawn first so body overlaps it slightly)
-- A distinct curl starting from the back and wrapping to the front
c:path({{8,14}, {6,14}, {5,15}, {5,17}, {7,17}, {8,16}, {7,15}, {8,15}}, "mid")
c:px(5, 17, "lt") -- Tail tip highlight

-- 2. Body (Main sitting mass)
draw_shaded_ellipse(c, 11, 13, 4.5, 5, "mid", 1, 1)

-- 3. Head (Larger and rounder)
draw_shaded_ellipse(c, 14, 8, 3.5, 3, "mid", 1, 1)

-- 4. White patches (Chest and Muzzle)
-- Chest connects to front legs area
c:ellipse(13, 13, 2.5, 3.5, "white", true)
-- Muzzle
c:ellipse(16, 9, 1.8, 1.5, "white", true)

-- 5. Ears (Pointed and separated)
c:poly({{13,7}, {12,4}, {15,7}}, "mid")
c:poly({{15,7}, {16,4}, {17,7}}, "mid")
c:px(12, 5, "hl") -- Ear highlight
c:px(16, 5, "hl")

-- 6. Face details
c:px(15, 8, "eye")      -- Eye
c:px(17, 9, "pink")     -- Nose

-- 7. Tabby Stripes (Deliberate bands on back)
c:rect(8, 11, 1, 2, "dk")
c:rect(9, 13, 1, 2, "dk")
c:rect(7, 15, 1, 1, "dk")

-- 8. Paws/Front Legs (Defined sitting posture)
c:rect(13, 16, 2, 2, "white") -- Front paws/chest base
c:rect(11, 17, 3, 1, "lt")    -- Bottom contact

-- 9. Highlights (Top edges)
c:rect(12, 6, 3, 1, "hl") -- Forehead
c:rect(10, 9, 2, 1, "hl") -- Back/shoulder

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
