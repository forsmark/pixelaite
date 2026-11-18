local s = px.sprite{ w = 20, h = 20, palette = {
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
} }

local c = s:layer("body")

-- Helper for round volume shading
local function draw_shaded_circle(ctx, cx, cy, r, color, light_dx, light_dy)
    -- Draw base shape
    ctx:circle(cx, cy, r, color, true)
    -- Shading: pixels outside a slightly shifted circle are darker
    for y = math.floor(cy - r), math.ceil(cy + r) do
        for x = math.floor(cx - r), math.ceil(cx + r) do
            local dx, dy = x - cx, y - cy
            local dist_sq = dx*dx + dy*dy
            if dist_sq <= r*r then
                -- Check shadow: pixel is in shadow if it's NOT in the light-shifted circle
                local sdx, sdy = x - (cx + light_dx), y - (cy + light_dy)
                if sdx*sdx + sdy*sdy > r*r then
                    if color == "lt" then ctx:px(x, y, "mid")
                    elseif color == "mid" then ctx:px(x, y, "dk")
                    elseif color == "white" then ctx:px(x, y, "lt") end
                end
            end
        end
    end
end

-- 1. Body (Sitting Profile, facing right)
-- Main torso (sitting haunch)
draw_shaded_circle(c, 12, 13, 4, "mid", -1, -1)
-- Head
draw_shaded_circle(c, 15, 8, 2.5, "lt", -1, -1)

-- 2. Ears (Pointed)
c:poly({{14, 7}, {15, 4}, {16, 7}}, "dk")
c:poly({{16, 7}, {17, 4}, {18, 7}}, "dk")

-- 3. White Muzzle and Chest
c:rect(15, 8, 3, 3, "white") -- Muzzle area
c:rect(13, 11, 3, 5, "white") -- Chest area

-- 4. Eye (Small and bright)
c:circle(16, 8, 0.6, "eye", true)

-- 5. Nose
c:circle(17, 9, 0.5, "pink", true)

-- 6. Tail (Curled around feet)
-- Using a thick path to represent the tail volume
c:path({{10, 15}, {8, 16}, {6, 15}, {5, 13}, {6, 11}, {8, 11}, {10, 12}}, "mid")
-- Add some shading to tail
c:path({{10, 15}, {8, 16}, {6, 15}, {5, 13}, {6, 11}, {8, 11}, {10, 12}}, "dk")

-- 7. Tabby Stripes (Back)
c:rect(9, 11, 1, 2, "dk")
c:rect(10, 13, 1, 2, "dk")

-- 8. Paws (White)
c:circle(11, 17, 2, "white", true)

-- Final Outline Layer
local ol = s:layer("outline")
ol:outline("outline", {from = {c}})

return s
