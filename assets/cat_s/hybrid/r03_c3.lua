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

-- 1. Body (Sitting mass)
draw_shaded_ellipse(c, 11, 13, 4.5, 5.5, "mid", 1, 1)

-- 2. Head (Larger and rounder for readability)
draw_shaded_ellipse(c, 15, 8, 3.5, 3, "mid", 1, 1)

-- 3. Muzzle and Chest (White patches)
-- Muzzle (positioned more clearly on the face)
c:ellipse(16.5, 8.5, 1.8, 1.5, "white", true)
-- Chest (Connecting to the front/lower part of body)
c:ellipse(13, 13, 2.5, 3.5, "white", true)

-- 4. Ears (Pointed and distinct)
c:poly({{13.5,7}, {13,3}, {15.5,7}}, "mid") -- Left ear
c:poly({{15.5,7}, {17,3}, {18,7}}, "mid")  -- Right ear
c:px(13, 4, "hl") -- Ear tip highlight
c:px(17, 4, "hl")

-- 5. Face details (Enhanced for 1x readability)
c:px(16, 7.5, "eye")      -- Eye (placed high for expression)
c:px(17.5, 8.5, "pink")   -- Nose (small and distinct)

-- 6. Tail (Distinct curl wrapping around front feet)
-- Using a path to create a clear "C" shape
c:path({{8,14}, {6,14}, {5,16}, {7,17}, {9,17}, {10,16}}, "mid")
c:px(10, 16, "hl") -- Tail tip highlight

-- 7. Tabby Stripes (Deliberate bands on the back)
c:rect(8, 11, 1, 2, "dk")
c:rect(7, 13, 1, 2, "dk")

-- 8. Paws/Feet (Defining the seated position)
c:rect(10, 17.5, 4, 1, "lt") -- Front paws (part of white chest area)
c:rect(8, 17.5, 3, 1, "dk")  -- Back paw

-- 9. Highlights (Consistent top-left light)
c:rect(13, 6, 3, 1, "hl") -- Head top
c:rect(9, 10, 2, 1, "hl") -- Back curve

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
