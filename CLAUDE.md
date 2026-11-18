# pixelaite

Pixel art game assets described as Lua code, improved in a render and critique loop.
An agent writes `assets/<name>/sprite.lua`, renders it, looks at the preview image, critiques it, and edits the script.
Aseprite is the export target: `aseprite/build.lua` turns the same script into a layered `.aseprite` file.

## Commands

Use the project venv: `.venv/bin/python pixelaite.py ...`

- `new <name> --size 32x32` creates `assets/<name>/sprite.lua` from a template.
- `render <name>` runs the script and saves `assets/<name>/iterations/NNN/` with `sprite.lua`, `preview.png`, `frame*.png`, `lint.txt`, and `anim.gif` for animations.
- `aseprite <name>` writes `assets/<name>/<name>.aseprite`. It needs Aseprite on PATH or `ASEPRITE=/path`.

## The loop

1. Write a short brief at the top of `sprite.lua` as a comment: subject, size, view, palette mood, game use.
2. Write or edit the script. Build the shape first: silhouette, then large color areas, then shading, then details.
3. Run `render <name>`.
4. Read `iterations/NNN/preview.png` with the Read tool. Also read the lint lines.
5. Critique against the checklist below. Write the critique in `iterations/NNN/notes.md`. Name pixel coordinates from the grid tile.
6. Change the script to fix the top 1 to 3 problems. Do not rewrite everything when a local fix is enough.
7. Repeat from step 3. Stop when the checklist passes, or after about 8 iterations. Report what is still weak.

## Critique checklist

- Silhouette: the subject is readable at 1x on the game-like background.
- Light: one light direction, usually top-left. Highlights and shadows agree with it.
- Palette: few colors, each with a purpose. Shading ramps change hue as well as value.
- Outline: no gaps. Consider a darker colored outline instead of pure black ("selective outline").
- Lines: no jaggies. Line steps follow a regular pattern, for example 1-1-1 or 2-2-2, not 2-1-3.
- Noise: no stray pixels. Single-pixel color islands in the lint are intended highlights or defects.
- No pillow shading: shading follows the light direction, not the outline of the shape.
- Animation: frames keep the volume, and the motion reads in `anim.gif`.

## Techniques that worked

- Symmetric subjects: draw the left half, call `mirror("x")`, then shade. Shading before the mirror gives light from both sides.
- Round volume: for each pixel of an ellipse, test the same ellipse moved 1 to 2 px toward the light. Pixels outside it are shadow. Copy the px ellipse test into the script so the shading lines up with the shape.
- Thin diagonal limbs (2 px): edge-based shading makes a checker of two colors. Give the whole limb one tone. Use shadow for the limb on the side away from the light.
- Keep a 1 px margin. The outline needs room, or the canvas cuts it off.

## px.lua API (Lua 5.4, the full language is available)

```lua
local s = px.sprite{ w = 32, h = 32, palette = { {"outline", "#1a1c2c"}, {"red", "#b13e53"} } }
local c = s:layer("body")          -- canvas for layer "body", frame 1. Layers stack in creation order.
local c2 = s:cel("body", 2)        -- canvas for layer "body", frame 2
local f = s:dup_frame(1)           -- copy all cels of frame 1 into a new frame, returns its number
s:duration(f, 120)                 -- frame time in ms for frame f. s:duration(120) sets all frames
s:tag("idle", 1, 4)

c:px(x, y, color)                  -- color is a palette name, nil is transparent
c:fill(x, y, w, h, color)          c:rect(x, y, w, h, color)
c:line(x0, y0, x1, y1, color)      c:path({{x,y},...}, color, closed)
c:ellipse(cx, cy, rx, ry, color, filled)   c:circle(cx, cy, r, color, filled)  -- .5 centers for even sizes
c:poly({{x,y},...}, color)         -- filled polygon
c:grid(x, y, {".##.", "#oo#"}, {["#"]="outline", o="red"})   -- "." skips, map a char to "_" to erase
c:flood(x, y, color)               c:replace(from, to)
c:dither(x, y, w, h, c1, c2, only_opaque)
c:outline(color, {diagonal=false, from={other_canvas}})
c:mirror("x")                      -- copy left half onto right half. mirror("x", true) copies right to left
c:shift(dx, dy)                    c:copy_from(other)   c:get(x, y)   c:clear()
c:map(function(x, y, color) return new_color_or_nil end)   -- return false to erase
return s                           -- the script must return the sprite
```
