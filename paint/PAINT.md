# Watercolor paintings as code

A painting is an ES module, `assets/<name>/paint.js`. p5.brush 3.0.0 (standalone build) renders it
in headless Chrome with software WebGL. The same script and seed give the same pixels.

## Commands

Use the project venv: `.venv/bin/python paint/render.py ...`

- `new <name> --size 512x512` creates `assets/<name>/paint.js` from a template.
- `render <name>` writes `assets/<name>/iterations/NNN/` with `paint.js`, `image.png`, `preview.png`
  (the image, a grid with pixel coordinates every 50 px, 1/2 and 1/4 size views, and a grayscale value view)
  and `info.txt` (size, hash, the brush and field names).
- `check <name>` renders twice and reports whether the output is identical.

## Script shape

```js
// Brief: subject, size, view, palette mood, use
export const meta = { w: 512, h: 512, seed: 1, paper: "#f4efe2" }

export default function draw(brush, W, H) {
  // top-left coordinates, angles in degrees, brushes already scaled to the canvas
}
```

The runner calls `createCanvas`, `scaleBrushes(W / 200)`, `angleMode(DEGREES)`, `seed`, `clear(paper)`,
`translate` and `render()`. Do not call them in the script. `meta.scale` overrides the brush scale.

### Per-element seeds

The fills share one random sequence, so adding or changing one fill changes the texture of every fill
after it. Start every element with `ctx.part("name")`: it reseeds from the element name, so the element
keeps its exact look when other elements change. Use a unique name per element.

```js
export default function draw(brush, W, H, ctx) {
  ctx.part("sky");  /* sky washes */
  ctx.part("coat"); /* coat washes */
}
```

### Animation

Set `meta.frames` (for example 8) and `meta.duration` (ms per frame, or an array). The runner calls
`draw` once per frame on a cleared canvas. `ctx.frame` is the frame index, `ctx.frames` the count, and
`ctx.t` runs from 0 to 1 over the loop. Drive motion with `Math.sin(2 * Math.PI * ctx.t)` so the loop is seamless.

- With `ctx.part("coat")` the coat's texture stays the same in every frame. Only its geometry moves.
- `ctx.part("sea", ctx.frame)` gives a new texture every frame: a deliberate hand-painted "boil".
  Use it sparingly, for example on water, not on the face.

- Move a watercolor fill by translating it as a whole (`brush.push()`, `brush.translate(dx, dy)`, draw, `brush.pop()`).
  Changing the outline points of a fill re-rolls its texture and makes it flicker, even with `ctx.part`.
  To make something bend, such as a coat tail, build it from separate overlapping pieces that each translate.

Animated renders also write `frame*.png`, `anim.gif` and `frames.png` (every frame, plus a view of what
changed from frame 1, to check that only the intended parts move).

## API

The full reference is `paint/p5brush-llms.txt`. Read the "Shared API" section and the standalone notes.
Main calls:

- Watercolor fill: `brush.fill(color, opacity 0-255)`, `brush.fillBleed(0-1, "out"|"in")`,
  `brush.fillTexture(texture 0-1, border 0-1, scatter?, split?)`, then a shape: `rect`, `circle(x, y, r, irregularity)`,
  `polygon([[x,y],...])`, `beginShape(curv)/vertex/endShape(true)`. `brush.noFill()` ends it.
  Fills drawn in the same pass bleed into each other where they touch (wet-in-wet).
- Flat fill without watercolor: `brush.wash(color, opacity)`, `brush.noWash()`.
- Lines: `brush.set(name, color, weight)`, then `line`, `spline([[x,y,pressure],...], curvature)`, `arc`,
  or `beginStroke/move/endStroke`. `brush.noStroke()` for fill-only shapes.
  Brushes: pen, rotring, 2B, HB, 2H, cpencil, pastel, crayon, charcoal, spray, marker.
- Hatching: `brush.hatch(dist, angle, {rand, continuous, gradient})`, `brush.hatchStyle(name, color, weight)`.
- Dry media fill: `brush.mass(brushName, color, {precision, strength, gradient, outline})`.
- Vector fields bend strokes: `brush.field("hand"|"curved"|"waves"|...)`, `brush.wiggle(n)`, `brush.noField()`.
- State: `brush.push()/pop()` keeps stroke, fill and hatch settings local.

## Watercolor practice

- Work light to dark. Large pale washes first, then mid values, then the darks, then line and detail last.
- Save the paper: the lightest lights are unpainted paper. Do not paint white.
- Few pigments. Pick 4 to 7 colors and mix by layering transparent washes, not by adding many hues.
- Vary edges: soft or bled edges for form turning away and for the background, hard edges at the focal point.
- Shadows are transparent glazes over the local color, often cool (blue or violet), on the side away from the light.
- Keep the value structure simple: check the grayscale view. The subject must read in values alone.

## Critique checklist

- Read: the subject is clear at 1/4 size.
- Values: 3 to 5 value groups, the darkest dark and lightest light at the focal point.
- Light: one light direction. Shadows and highlights agree with it.
- Edges: a mix of hard and soft edges, with hard ones at the focal point.
- Color: a limited palette with temperature shifts (warm light, cool shadow).
- Paper: white paper is kept where the lightest lights are.
- Mud: no grey, overworked areas from too many layers of complementary colors.
- Line: ink or pencil lines support the forms and do not outline everything evenly.
