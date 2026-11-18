local s = px.sprite{ w = 20, h = 20, palette = { {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"}, {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"} } }
local body = s:layer("body")
local outline_layer = s:layer("outline")

-- Helper function for ellipse shading (approximation for roundness)
-- cx, cy: center coordinates
-- rx, ry: radii
-- light_offset_x, light_offset_y: offset for shadow calculation
local function shade_ellipse(cx, cy, rx, ry, light_offset_x, light_offset_y, color)
    local pixels = {}
    -- Iterate over a bounding box slightly larger than the ellipse
    for x = cx - rx - 1, cx + rx + 1 do
        for y = cy - ry - 1, cy + ry + 1 do
            -- Test if point (x, y) is inside the ellipse
            local dx = x - cx
            local dy = y - cy
            local dist_sq = (dx * dx) / (rx * rx) + (dy * dy) / (ry * ry)

            if dist_sq <= 1.0 then
                -- Test the point shifted towards the light source (top-left: -1, -1)
                local sx = x - light_offset_x
                local sy = y - light_offset_y
                local sdx = sx - cx
                local sdy = sy - cy
                local s_dist_sq = (sdx * sdx) / (rx * rx) + (sdy * sdy) / (ry * ry)

                -- If the point shifted is outside the ellipse, it's in shadow
                if s_dist_sq > 1.0 then
                    pixels[x] = pixels[x] or {}
                    pixels[x][y] = color
                else
                    -- Otherwise, it's lit (or self-shadowed if we wanted more complexity, but for simplicity, lit)
                    pixels[x] = pixels[x] or {}
                    pixels[x][y] = color
                end
            end
        end
    end
    return pixels
end

-- --- Drawing the Cat Body (Orange Tabby) ---

-- Base body shape (approximated as a blob/sitting form)
-- We'll use a primary layer for the main color, and then use shading logic on top if needed, 
-- but given the complexity, we'll draw major shapes and use shading hints.

-- Body mass (approximated)
local function draw_body(c)
    -- Torso/Back (Mid tone)
    c:rect(4, 7, 12, 8, "mid")
    -- Hips/Base (Slightly darker/more grounded)
    c:rect(3, 14, 14, 3, "dk")
    -- Chest/Belly (Lighter)
    c:rect(5, 10, 6, 5, "lt")
end

draw_body(body)

-- Head shape (approximated circle/oval)
local function draw_head(c)
    -- Main head shape (using an ellipse approximation)
    local cx, cy = 7, 6
    local rx, ry = 3, 3.5
    local shadow_color = "dk"
    local light_color = "mid"

    -- Draw the base shape using the ellipse test, favoring the lighter tone for the main shape
    local ellipse_pixels = shade_ellipse(cx, cy, rx, ry, 1, 1, light_color) -- Light from top-left (1, 1) relative to the shape center
    
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
        c:poly({{x, y}, {x + size, y - size/2}, {x + size/2, y - size}}, "mid")
    end
    -- Left Ear
    ear_base(6, 4, 2)
    -- Right Ear
    ear_base(10, 4, 2)
end
draw_ears(body)

-- Muzzle/Snout (White)
local function draw_muzzle(c)
    c:rect(7, 8, 4, 2, "white")
end
draw_muzzle(body)

-- Tail (Curling around front feet area)
local function draw_tail(c)
    -- Tail starts near the back, curves down/forward
    c:line(15, 12, 13, 10, "mid")
    c:line(13, 10, 11, 11, "mid")
    c:line(11, 11, 9, 12, "mid")
end
draw_tail(body)

-- Front Feet/Paws (Small pads)
local function draw_feet(c)
    c:rect(6, 14, 1, 1, "dk")
    c:rect(8, 14, 1, 1, "dk")
end
draw_feet(body)


-- --- Details ---

-- Eye (Greenish/Yellowish, small)
local function draw_eye(c)
    -- Right eye (facing right, so it's on the right side of the head)
    c:circle(9.5, 5.5, 0.4, "eye", true)
end
draw_eye(body)

-- Pink inner ear detail (optional, small)
local function draw_inner_ear(c)
    c:rect(6.5, 3.5, 0.5, 0.5, "pink")
    c:rect(9.5, 3.5, 0.5, 0.5, "pink")
end
draw_inner_ear(body)

-- Tabby Stripes (Darker lines on the back)
local function draw_stripes(c)
    -- Stripe 1 (Back)
    c:line(14, 8, 11, 11, "dk")
    -- Stripe 2 (Lower back)
    c:line(12, 10, 9, 12, "dk")
end
draw_stripes(body)

-- --- Final Assembly ---
-- We draw all color shapes onto the 'body' layer.
-- The outline layer is drawn last using the outline function.

-- The outline layer needs to reference all color layers.
outline_layer:outline("outline", {from = {body}})

return s
