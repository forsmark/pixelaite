local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for volumetric shading: tests if pixel is outside an ellipse shifted towards light
local function draw_volumetric_ellipse(canvas, cx, cy, rx, ry, col_light, col_shadow)
    for y = math.floor(cy - ry), math.ceil(cy + ry) do
        for x = math.floor(cx - rx), math.ceil(cx + rx) do
            local dx, dy = x - cx, y - cy
            if (dx*dx)/(rx*rx) + (dy*dy)/(ry*ry) <= 1 then
                -- Light is top-left, so we shift the "test" ellipse +1, +1 to find shadow
                local sx, sy = x - 1 - cx, y - 1 - cy
                local is_shadow = (sx*sx)/(rx*rx) + (sy*sy)/(ry*ry) > 1
                canvas:px(x, y, is_shadow and col_shadow or col_light)
            end
        end
    end
end

-- 1. Body: Sitting posture (large oval)
draw_volumetric_ellipse(c, 12, 13, 4.5, 5, "mid", "dk")

-- 2. Head: Slightly smaller oval on top
draw_volumetric_ellipse(c, 15, 8, 3, 2.5, "lt", "mid")

-- 3. White areas (Muzzle and Chest)
c:ellipse(16, 9, 1.5, 1.5, "white", true) -- Muzzle
c:ellipse(13, 13, 2, 3, "white", true)   -- Chest/Belly

-- 4. Ears (Pointed)
c:poly({{14,7}, {15,4}, {16,7}}, "mid")
c:poly({{16,7}, {17,4}, {18,7}}, "mid")

-- 5. Face details
c:px(16, 8, "eye")
c:px(17, 9, "pink")

-- 6. Stripes (Darker tabby markings on the back/head)
c:rect(11, 11, 1, 2, "dk")
c:rect(10, 13, 1, 2, "dk")
c:rect(15, 6, 1, 1, "dk")

-- 7. Tail (Curled around feet)
-- Using a path for a thicker, more organic feel
c:path({{11,15}, {9,16}, {7,15}, {7,13}, {8,12}, {10,12}}, "mid")

-- 8. Paws (Simplified sitting feet)
c:ellipse(11, 17, 2, 1, "lt", true)
c:ellipse(14, 17, 2, 1, "lt", true)

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
