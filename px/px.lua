-- px.lua: a small pixel art drawing library.
--
-- An asset script uses this library to describe a sprite as code.
-- The library is pure Lua and has no dependency on Aseprite.
-- Two backends read the result of sprite:export():
--   * pixelaite.py runs the script with an embedded Lua and renders PNG previews.
--   * aseprite/build.lua runs the script inside Aseprite and writes a .aseprite file.
--
-- Coordinates are integers. (0, 0) is the top-left pixel.
-- Colors are palette names (strings). nil means "transparent".

local px = {}

local function hex_to_rgba(hex)
  hex = hex:gsub("#", "")
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  local a = 255
  if #hex == 8 then a = tonumber(hex:sub(7, 8), 16) end
  return r, g, b, a
end

local function round(v) return math.floor(v + 0.5) end

---------------------------------------------------------------------------
-- Canvas: the pixels of one layer in one frame (an Aseprite "cel").
---------------------------------------------------------------------------

local Canvas = {}
Canvas.__index = Canvas

local function new_canvas(sprite, layer, frame)
  local c = setmetatable({ sprite = sprite, layer = layer, frame = frame,
    w = sprite.w, h = sprite.h, data = {} }, Canvas)
  for i = 1, c.w * c.h do c.data[i] = 0 end
  return c
end

function Canvas:_idx(color)
  if color == nil or color == false then return 0 end
  local i = self.sprite.palette_index[color]
  if not i then error("unknown palette color '" .. tostring(color) .. "'", 3) end
  return i
end

function Canvas:inside(x, y) return x >= 0 and y >= 0 and x < self.w and y < self.h end

-- Set one pixel. Pixels outside the canvas are ignored.
function Canvas:px(x, y, color)
  x, y = round(x), round(y)
  if self:inside(x, y) then self.data[y * self.w + x + 1] = self:_idx(color) end
  return self
end

-- Return the palette name at (x, y), or nil when transparent.
function Canvas:get(x, y)
  if not self:inside(x, y) then return nil end
  local i = self.data[y * self.w + x + 1]
  if i == 0 then return nil end
  return self.sprite.palette[i].name
end

function Canvas:clear() for i = 1, self.w * self.h do self.data[i] = 0 end return self end

-- Filled rectangle.
function Canvas:fill(x, y, w, h, color)
  for yy = y, y + h - 1 do for xx = x, x + w - 1 do self:px(xx, yy, color) end end
  return self
end

-- Rectangle border, 1 pixel wide.
function Canvas:rect(x, y, w, h, color)
  for xx = x, x + w - 1 do self:px(xx, y, color); self:px(xx, y + h - 1, color) end
  for yy = y, y + h - 1 do self:px(x, yy, color); self:px(x + w - 1, yy, color) end
  return self
end

-- Bresenham line, 1 pixel wide, no double pixels at corners.
function Canvas:line(x0, y0, x1, y1, color)
  x0, y0, x1, y1 = round(x0), round(y0), round(x1), round(y1)
  local dx, dy = math.abs(x1 - x0), -math.abs(y1 - y0)
  local sx = x0 < x1 and 1 or -1
  local sy = y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    self:px(x0, y0, color)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy; x0 = x0 + sx end
    if e2 <= dx then err = err + dx; y0 = y0 + sy end
  end
  return self
end

-- Connect a list of points {{x,y},{x,y},...} with lines.
function Canvas:path(points, color, closed)
  for i = 1, #points - 1 do
    self:line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2], color)
  end
  if closed and #points > 2 then
    self:line(points[#points][1], points[#points][2], points[1][1], points[1][2], color)
  end
  return self
end

-- Ellipse centered at (cx, cy). Use .5 centers for even sizes,
-- for example cx = 7.5 gives a shape that is symmetric around x = 7.5.
-- filled = true fills the shape. Otherwise only the 1 pixel border is drawn.
function Canvas:ellipse(cx, cy, rx, ry, color, filled)
  local function inside(x, y)
    local dx, dy = x - cx, y - cy
    return (dx * dx) / (rx * rx + 0.8 * rx) + (dy * dy) / (ry * ry + 0.8 * ry) <= 1
  end
  local x0, x1 = math.floor(cx - rx - 1), math.ceil(cx + rx + 1)
  local y0, y1 = math.floor(cy - ry - 1), math.ceil(cy + ry + 1)
  for y = y0, y1 do
    for x = x0, x1 do
      if inside(x, y) then
        if filled or not (inside(x - 1, y) and inside(x + 1, y) and inside(x, y - 1) and inside(x, y + 1)) then
          self:px(x, y, color)
        end
      end
    end
  end
  return self
end

function Canvas:circle(cx, cy, r, color, filled) return self:ellipse(cx, cy, r, r, color, filled) end

-- Filled polygon. points = {{x,y},...}. Pixel centers inside the polygon are set.
function Canvas:poly(points, color)
  local miny, maxy = math.huge, -math.huge
  for _, p in ipairs(points) do miny = math.min(miny, p[2]); maxy = math.max(maxy, p[2]) end
  for y = math.floor(miny), math.ceil(maxy) do
    local xs = {}
    for i = 1, #points do
      local a, b = points[i], points[i % #points + 1]
      if (a[2] <= y and b[2] > y) or (b[2] <= y and a[2] > y) then
        xs[#xs + 1] = a[1] + (y - a[2]) / (b[2] - a[2]) * (b[1] - a[1])
      end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do
      for x = math.ceil(xs[i] - 0.5), math.floor(xs[i + 1] - 0.5) do self:px(x, y, color) end
    end
  end
  -- Also draw the edges, so thin polygons do not lose pixels.
  return self:path(points, color, true)
end

-- Draw rows of characters. map links a character to a palette name.
-- "." and " " are skipped and keep the existing pixel.
-- Example: c:grid(4, 2, {".##.", "#oo#"}, {["#"]="outline", o="red"})
function Canvas:grid(x, y, rows, map)
  for j, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      if ch ~= "." and ch ~= " " then
        local color = map[ch]
        if color == nil then error("grid: no palette entry for character '" .. ch .. "'", 2) end
        if color == "_" then color = nil end -- "_" in the map erases
        self:px(x + i - 1, y + j - 1, color)
      end
    end
  end
  return self
end

-- Flood fill the 4-connected area that has the same color as (x, y).
function Canvas:flood(x, y, color)
  if not self:inside(x, y) then return self end
  local target = self.data[y * self.w + x + 1]
  local new = self:_idx(color)
  if target == new then return self end
  local stack = { { x, y } }
  while #stack > 0 do
    local p = table.remove(stack)
    local px_, py_ = p[1], p[2]
    if self:inside(px_, py_) and self.data[py_ * self.w + px_ + 1] == target then
      self.data[py_ * self.w + px_ + 1] = new
      stack[#stack + 1] = { px_ + 1, py_ }; stack[#stack + 1] = { px_ - 1, py_ }
      stack[#stack + 1] = { px_, py_ + 1 }; stack[#stack + 1] = { px_, py_ - 1 }
    end
  end
  return self
end

-- Checker dither in a rectangle. c1 on even (x + y), c2 on odd. nil skips.
function Canvas:dither(x, y, w, h, c1, c2, only_opaque)
  for yy = y, y + h - 1 do
    for xx = x, x + w - 1 do
      if not only_opaque or self:get(xx, yy) then
        local c = ((xx + yy) % 2 == 0) and c1 or c2
        if c then self:px(xx, yy, c) end
      end
    end
  end
  return self
end

-- Replace every pixel of one color with another color.
function Canvas:replace(from, to)
  local a, b = self:_idx(from), self:_idx(to)
  for i = 1, #self.data do if self.data[i] == a then self.data[i] = b end end
  return self
end

-- Call fn(x, y, color) for each pixel. If fn returns a value other than nil,
-- that value is the new color. Return false to make the pixel transparent.
function Canvas:map(fn)
  local out = {}
  for y = 0, self.h - 1 do
    for x = 0, self.w - 1 do
      local r = fn(x, y, self:get(x, y))
      if r ~= nil then out[#out + 1] = { x, y, r } end
    end
  end
  for _, o in ipairs(out) do self:px(o[1], o[2], o[3] or nil) end
  return self
end

-- Add a 1 pixel outline around the opaque pixels.
-- opts.diagonal = true also uses diagonal neighbors (thicker corners).
-- opts.from = {canvas, ...} also treats pixels of those canvases as the shape.
function Canvas:outline(color, opts)
  opts = opts or {}
  local sources = { self }
  for _, c in ipairs(opts.from or {}) do sources[#sources + 1] = c end
  local function solid(x, y)
    if x < 0 or y < 0 or x >= self.w or y >= self.h then return false end
    for _, c in ipairs(sources) do if c.data[y * self.w + x + 1] ~= 0 then return true end end
    return false
  end
  local add = {}
  for y = 0, self.h - 1 do
    for x = 0, self.w - 1 do
      if not solid(x, y) then
        local n = solid(x - 1, y) or solid(x + 1, y) or solid(x, y - 1) or solid(x, y + 1)
        if not n and opts.diagonal then
          n = solid(x - 1, y - 1) or solid(x + 1, y - 1) or solid(x - 1, y + 1) or solid(x + 1, y + 1)
        end
        if n then add[#add + 1] = { x, y } end
      end
    end
  end
  for _, p in ipairs(add) do self:px(p[1], p[2], color) end
  return self
end

-- Mirror one half onto the other. axis "x": left half to right half.
-- axis "y": top half to bottom half. Use flip = true to copy the other way.
function Canvas:mirror(axis, flip)
  local w, h = self.w, self.h
  local d = self.data
  if axis == "x" then
    for y = 0, h - 1 do
      for x = 0, math.floor(w / 2) - 1 do
        local a, b = y * w + x + 1, y * w + (w - 1 - x) + 1
        if flip then d[a] = d[b] else d[b] = d[a] end
      end
    end
  else
    for y = 0, math.floor(h / 2) - 1 do
      for x = 0, w - 1 do
        local a, b = y * w + x + 1, (h - 1 - y) * w + x + 1
        if flip then d[a] = d[b] else d[b] = d[a] end
      end
    end
  end
  return self
end

-- Move all pixels by (dx, dy). Pixels that leave the canvas are lost.
function Canvas:shift(dx, dy)
  local old = {}
  for i = 1, #self.data do old[i] = self.data[i]; self.data[i] = 0 end
  for y = 0, self.h - 1 do
    for x = 0, self.w - 1 do
      local nx, ny = x + dx, y + dy
      if self:inside(nx, ny) then self.data[ny * self.w + nx + 1] = old[y * self.w + x + 1] end
    end
  end
  return self
end

-- Copy all pixels from another canvas.
function Canvas:copy_from(other)
  for i = 1, #self.data do self.data[i] = other.data[i] end
  return self
end

---------------------------------------------------------------------------
-- Sprite: size, palette, layers, frames, tags.
---------------------------------------------------------------------------

local Sprite = {}
Sprite.__index = Sprite

-- px.sprite{ w = 32, h = 32, palette = { {"outline", "#1a1c2c"}, {"red", "#b13e53"} } }
-- The palette is an ordered list. Index 0 is always transparent.
function px.sprite(opts)
  assert(opts.w and opts.h, "px.sprite needs w and h")
  local s = setmetatable({ w = opts.w, h = opts.h, palette = {}, palette_index = {},
    layers = {}, layer_index = {}, frames = {}, tags = {} }, Sprite)
  for i, entry in ipairs(opts.palette or {}) do
    local name, hex = entry[1], entry[2]
    local r, g, b, a = hex_to_rgba(hex)
    s.palette[i] = { name = name, hex = hex, r = r, g = g, b = b, a = a }
    s.palette_index[name] = i
  end
  s.frames[1] = { duration = opts.duration or 100, cels = {} }
  return s
end

-- Return the layer list index, and create the layer if it is new.
-- Layers are stacked in creation order: the first layer is at the bottom.
function Sprite:_layer(name)
  if not self.layer_index[name] then
    self.layers[#self.layers + 1] = name
    self.layer_index[name] = #self.layers
  end
  return self.layer_index[name]
end

-- Return the canvas for a layer in a frame. Default frame is 1.
function Sprite:cel(layer, frame)
  frame = frame or 1
  self:_layer(layer)
  while #self.frames < frame do
    self.frames[#self.frames + 1] = { duration = self.frames[#self.frames].duration, cels = {} }
  end
  local f = self.frames[frame]
  if not f.cels[layer] then f.cels[layer] = new_canvas(self, layer, frame) end
  return f.cels[layer]
end

-- Shortcut: s:layer("body") is s:cel("body", 1).
function Sprite:layer(name) return self:cel(name, 1) end

-- Copy every cel of frame src into a new frame at the end. Return the new frame number.
function Sprite:dup_frame(src)
  local n = #self.frames + 1
  self.frames[n] = { duration = self.frames[src].duration, cels = {} }
  for name, c in pairs(self.frames[src].cels) do
    self:cel(name, n):copy_from(c)
  end
  return n
end

-- Frame duration in milliseconds.
-- s:duration(ms) sets every frame. s:duration(frame, ms) sets one existing frame.
function Sprite:duration(frame, ms)
  if ms == nil then
    for _, f in ipairs(self.frames) do f.duration = frame end
    return
  end
  if not self.frames[frame] then
    error("duration: frame " .. tostring(frame) .. " does not exist (sprite has " .. #self.frames .. " frames)", 2)
  end
  self.frames[frame].duration = ms
end

-- Animation tag over frames from..to (inclusive).
function Sprite:tag(name, from, to) self.tags[#self.tags + 1] = { name = name, from = from, to = to } end

-- Plain tables for the backends.
function Sprite:export()
  local out = { w = self.w, h = self.h, palette = {}, layers = {}, frames = {}, tags = self.tags }
  for i, p in ipairs(self.palette) do out.palette[i] = { name = p.name, r = p.r, g = p.g, b = p.b, a = p.a } end
  for i, l in ipairs(self.layers) do out.layers[i] = l end
  for i, f in ipairs(self.frames) do
    local cels = {}
    for name, c in pairs(f.cels) do cels[name] = c.data end
    out.frames[i] = { duration = f.duration, cels = cels }
  end
  return out
end

return px
