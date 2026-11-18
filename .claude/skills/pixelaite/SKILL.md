---
name: pixelaite
description: Make game art as code with a render and critique loop. Pixel art sprites (Lua, exported to Aseprite) and watercolor illustrations (p5.brush), stills or looping animations. Use when the user asks for a sprite, an icon, card art, an illustration or an animation in this repository.
---

# Game art as code

Every asset is a script. A renderer turns it into pixels the same way every time.
An agent writes the script, renders it, looks at the preview, critiques it, and edits the script.

There are two media. Pick one from the request:

| Medium | Script | Render | Rules |
|---|---|---|---|
| Pixel art | `assets/<name>/sprite.lua` | `.venv/bin/python pixelaite.py render <name>` | `CLAUDE.md` |
| Watercolor | `assets/<name>/paint.js` | `.venv/bin/python paint/render.py render <name>` | `paint/PAINT.md` |

Each render writes `assets/<name>/iterations/NNN/` with a `preview.png` that holds the image, a coordinate grid,
small views and a value view. Read `preview.png` with the Read tool after every render.

## Workflow

1. Write `assets/<name>/brief.md`: subject, size, view, light direction, palette, game use,
   and the size at which it must read (for example "1x on a green background" or "1/4 size").
2. Give the whole job to ONE subagent on the strongest model available, with a render cap.
   One strong model that draws and critiques its own work beat every split setup we tried
   (see "What we learned" below). Brief the subagent with:
   - the rules file for the medium (`CLAUDE.md` or `paint/PAINT.md`) and, for watercolor, `paint/p5brush-llms.txt`,
   - the brief path and the script path,
   - the render cap: 3 renders for a pixel sprite, 4 for a watercolor still, 3 more for an animation,
   - "look at preview.png after each render and fix the worst 1 to 3 problems",
   - "do not look at other folders in assets/" (old attempts anchor the result),
   - a short reply: the final iteration, what works, what is still weak.
3. When it returns, look at the final `image.png` or `frames.png` yourself before you report.
4. For a second pass, send a numbered list of concrete fixes, most important first.
   Name parts and positions. "Make the far arm cooler and darker, partly behind the body" works.
   "Make it better" does not.

## Animation

- Pixel art: `s:dup_frame`, `s:duration`, `s:tag`. Keep the volume constant between frames.
  A 1 px bob with a part that lags one frame (hat, hair, coat) reads well as an idle.
- Watercolor: `meta.frames`, `meta.duration`, `ctx.t` from 0 to 1. Drive motion with `Math.sin(2 * Math.PI * ctx.t)`.
- Watercolor fills must move as a whole: `brush.push()`, `translate`/`rotate`, draw, `brush.pop()`.
  Changing a fill's outline points re-rolls its texture and the part flickers.
  To bend something, build it from overlapping pieces that each move.
- Start every watercolor element with `ctx.part("name")` so it keeps its texture in every frame.
  `ctx.part("steam", ctx.frame)` gives a deliberate per-frame "boil" for steam or water.
- Plan the moving parts in the still already: each one drawn around its own pivot.
- Check `frames.png`: its lower row shows what changed from frame 1. Only the parts that should move may light up.
- For loops of rotating parts, turn by a whole number of teeth or spokes per loop, so the last frame flows into the first.

## What we learned

- A local 26B model (Gemma) could not judge quality, neither pairwise nor with a yes/no checklist.
- Local model draws + Claude judges: quality was capped by the drawer. A better judge helped only a little.
  A "keep the current one when confidence is low" rule stopped the drift.
- One strong model alone with 3 renders ranked first in blind rankings (pirate: first for all three judges,
  cat: mean rank 1.3), at about the cost of the best hybrid run (about $0.55 per sprite).
- Small watercolor fills dry too pale. Use them for areas larger than about 15 px, and paint tiny dark
  details (pupils, rivets, holes) with a pen or marker stroke instead.
