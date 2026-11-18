-- Build a .aseprite file from an asset script.
--
-- Usage:
--   aseprite -b --script-param asset=assets/potion/sprite.lua \
--               --script-param out=assets/potion/potion.aseprite \
--               --script aseprite/build.lua
--
-- The asset script must return a px sprite (the value of px.sprite{...}).

local here = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
package.path = here .. "../px/?.lua;" .. package.path
_G.px = require("px")

local asset = app.params["asset"]
local out = app.params["out"]
assert(asset and out, "pass --script-param asset=... and --script-param out=...")

local sprite = dofile(asset)
assert(sprite and sprite.export, "the asset script must return a px sprite")
local data = sprite:export()

local spr = Sprite(data.w, data.h, ColorMode.INDEXED)
spr.transparentColor = 0

local pal = Palette(#data.palette + 1)
pal:setColor(0, Color { r = 0, g = 0, b = 0, a = 0 })
for i, p in ipairs(data.palette) do
  pal:setColor(i, Color { r = p.r, g = p.g, b = p.b, a = p.a })
end
spr:setPalette(pal)

-- Layers. A new sprite has one layer. Rename it and add the rest above it.
local layers = {}
for i, name in ipairs(data.layers) do
  local layer = (i == 1) and spr.layers[1] or spr:newLayer()
  layer.name = name
  layers[name] = layer
end

-- Frames.
for i = 2, #data.frames do spr:newEmptyFrame() end
for i, f in ipairs(data.frames) do
  spr.frames[i].duration = f.duration / 1000
  for name, pixels in pairs(f.cels) do
    local img = Image(data.w, data.h, ColorMode.INDEXED)
    for y = 0, data.h - 1 do
      for x = 0, data.w - 1 do
        local v = pixels[y * data.w + x + 1]
        if v ~= 0 then img:drawPixel(x, y, v) end
      end
    end
    -- A new sprite already has an empty cel in frame 1 of the first layer.
    spr:newCel(layers[name], i, img, Point(0, 0))
  end
end

for _, t in ipairs(data.tags) do
  local tag = spr:newTag(t.from, t.to)
  tag.name = t.name
end

spr:saveAs(out)
