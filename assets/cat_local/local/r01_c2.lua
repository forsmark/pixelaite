local s = px.sprite{ w = 20, h = 20, palette = { {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"}, {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"} } }
local body = s:layer("body")
local outline_layer = s:layer("outline")

-- Light source is top-left (dx=-1, dy=-1 relative to object space)
local LIGHT_OFFSET_X = -1
local LIGHT_OFFSET_Y = -1

-- Helper function for ellipse shading (approximating 3D form)
-- cx, cy: center coordinates
-- rx, ry: radii
-- color: the base color to shade
local function shade_ellipse(cx, cy, rx, ry, color)
    local pixels = {}
    for x = cx - rx - 1, cx + rx + 1 do
        for y = cy - ry - 1, cy + ry + 1 do
            local dx = x - cx
            local dy = y - cy
            local dist_sq = (dx * dx) / (rx * rx) + (dy * dy) / (ry * ry)

            if dist_sq <= 1.0 then
                -- Test point shifted towards light source
                local sx = x + LIGHT_OFFSET_X
                local sy = y + LIGHT_OFFSET_Y
                local sdx = sx - cx
                local sdy = sy - cy
                local s_dist_sq = (sdx * sdx) / (rx * rx) + (sdy * sdy) / (ry * ry)

                -- If the shifted point is outside the ellipse, it's in shadow
                if s_dist_sq > 1.0 then
                    pixels[x] = pixels[x] or {}
                    pixels[x][y] = "dk" -- Use darker shade for shadow
                else
                    -- Otherwise, it's lit
                    pixels[x] = pixels[x] or {}
                    pixels[x][y] = color
                end
            end
        end
    end
    return pixels
end

-- --- Drawing the Cat Body (Orange Tabby) ---

-- Body mass (Torso, hips, chest) - Use 'mid' as primary tone
local function draw_body(c)
    -- Torso/Back (Mid tone) - Adjusted for side view sitting posture
    c:rect(4, 8, 12, 7, "mid")
    -- Hips/Base (Slightly darker/more grounded)
    c:rect(3, 15, 14, 3, "dk")
    -- Chest/Belly (Lighter)
    c:rect(5, 11, 6, 4, "lt")
end
draw_body(body)

-- Head shape (Approximated oval/circle)
local function draw_head(c)
    local cx, cy = 7, 6
    local rx, ry = 3, 3.5
    
    -- Draw the main shape using ellipse shading for volume
    local ellipse_pixels = shade_ellipse(cx, cy, rx, ry, "mid")
    
    for x, y_map in pairs(ellipse_pixels) do
        for y, color in pairs(y_map) do
            c:px(x, y, color)
        end
    end
end
draw_head(body)

-- Ears (Triangular, pointing up)
local function draw_ears(c)
    local ear_base = function(x, y, size)
        -- Use mid tone, apply some slight shading to the edges if needed, but keep it simple
        c:poly({{x, y}, {x + size, y - size/2}, {x + size/2, y - size}}, "mid")
    end
    -- Left Ear (Viewer's Left)
    ear_base(6, 4, 2)
    -- Right Ear (Viewer's Right, higher up)
    ear_base(10, 3, 2)
end
draw_ears(body)

-- Muzzle/Snout (White) - Front facing part
local function draw_muzzle(c)
    -- White area for snout/chin
    c:rect(7, 9, 4, 2, "white")
    -- Small white patch under chin
    c:rect(7, 12, 3, 1, "white")
end
draw_muzzle(body)

-- Tail (Curling around front feet area)
local function draw_tail(c)
    -- Tail starts near the back (around x=15, y=10) and curls forward
    c:line(15, 10, 13, 11, "mid")
    c:line(13, 11, 11, 12, "mid")
    c:line(11, 12, 9, 13, "mid")
    -- A bit thicker/rounder tail end approximation
    c:rect(8, 13, 2, 2, "mid")
end
draw_tail(body)

-- Front Feet/Paws (Small pads) - Where the tail wraps
local function draw_feet(c)
    -- Left foot (closer to viewer)
    c:rect(6, 14, 1, 1, "dk")
    -- Right foot
    c:rect(8, 14, 1, 1, "dk")
end
draw_feet(body)

-- Eyes (Small, positioned on the side facing right)
local function draw_eye(c)
    -- Right eye (on the side facing right)
    c:circle(9.5, 5.5, 0.4, "eye", true)
    -- Pupil/Iris detail (optional, use darker tone if needed, but stick to brief colors)
    -- We will rely on the base 'eye' color for simplicity.
end
draw_eye(body)

-- Pink inner ear detail
local function draw_inner_ear(c)
    c:rect(6.5, 3.5, 0.5, 0.5, "pink") -- Left
    c:rect(9.5, 3.5, 0.5, 0.5, "pink") -- Right
end
draw_inner_ear(body)

-- Tabby Stripes (Darker lines on the back/torso)
local function draw_stripes(c)
    -- Stripe 1 (Upper back)
    c:line(14, 8, 11, 10, "dk")
    -- Stripe 2 (Mid back)
    c:line(13, 10, 10, 12, "dk")
    -- Stripe 3 (Lower back, curving)
    c:line(12, 12, 10, 13, "dk")
end
draw_stripes(body)

-- --- Final Assembly ---
outline_layer:outline("outline", {from = {body}})

return s
