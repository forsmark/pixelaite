#!/usr/bin/env python3
"""pixelaite: render pixel art asset scripts and build critique sheets.

Commands:
  new <name> [--size 32x32]   Create assets/<name>/sprite.lua from a template.
  render <name>               Run the script, save a new iteration, print the paths.
  aseprite <name>             Build assets/<name>/<name>.aseprite with Aseprite.
"""
import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

from lupa import lua54
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets"
PX_LUA = ROOT / "px" / "px.lua"

TEMPLATE = """\
-- {name}: describe the asset here (subject, view angle, style, use in game).
local s = px.sprite{{
  w = {w}, h = {h},
  palette = {{
    {{"outline", "#1a1c2c"}},
    {{"dark",    "#333c57"}},
    {{"mid",     "#566c86"}},
    {{"light",   "#94b0c2"}},
    {{"white",   "#f4f4f4"}},
  }},
}}

local body = s:layer("body")
body:ellipse({cx}, {cy}, {r}, {r}, "mid", true)
body:outline("outline")

return s
"""


# ---------------------------------------------------------------------------
# Run the Lua script
# ---------------------------------------------------------------------------

def run_script(script: Path) -> dict:
    lua = lua54.LuaRuntime(unpack_returned_tuples=True)
    px = lua.execute(PX_LUA.read_text())
    lua.globals().px = px
    try:
        sprite = lua.execute(script.read_text())
    except lua54.LuaError as e:
        raise SystemExit(f"Lua error in {script}:\n{e}")
    if sprite is None:
        raise SystemExit(f"{script} must end with 'return s' (the px sprite).")
    data = sprite.export(sprite)
    return lua_to_py(data)


def lua_to_py(v):
    if lua54.lua_type(v) == "table":
        keys = list(v.keys())
        if keys and all(isinstance(k, int) for k in keys):
            return [lua_to_py(v[k]) for k in sorted(keys)]
        if not keys:
            return []
        return {k: lua_to_py(v[k]) for k in keys}
    return v


# ---------------------------------------------------------------------------
# Composite frames
# ---------------------------------------------------------------------------

def composite(data: dict) -> list[Image.Image]:
    w, h = data["w"], data["h"]
    pal = [(0, 0, 0, 0)] + [(p["r"], p["g"], p["b"], p["a"]) for p in data["palette"]]
    frames = []
    for f in data["frames"]:
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        cels = f["cels"] if isinstance(f["cels"], dict) else {}
        for layer in data["layers"]:  # bottom to top
            pixels = cels.get(layer)
            if not pixels:
                continue
            layer_img = Image.new("RGBA", (w, h))
            layer_img.putdata([pal[i] for i in pixels])
            img.alpha_composite(layer_img)
        frames.append(img)
    return frames


def index_frames(data: dict) -> list[list[int]]:
    """Top visible palette index per pixel, per frame. 0 is transparent."""
    w, h = data["w"], data["h"]
    out = []
    for f in data["frames"]:
        idx = [0] * (w * h)
        cels = f["cels"] if isinstance(f["cels"], dict) else {}
        for layer in data["layers"]:
            pixels = cels.get(layer)
            if not pixels:
                continue
            for i, v in enumerate(pixels):
                if v:
                    idx[i] = v
        out.append(idx)
    return out


# ---------------------------------------------------------------------------
# Lint: objective checks that help the critique
# ---------------------------------------------------------------------------

def lint(data: dict) -> list[str]:
    w, h = data["w"], data["h"]
    names = [p["name"] for p in data["palette"]]
    lines = []
    used = set()
    for n, idx in enumerate(index_frames(data), start=1):
        def at(x, y):
            return idx[y * w + x] if 0 <= x < w and 0 <= y < h else 0

        opaque = [(x, y) for y in range(h) for x in range(w) if at(x, y)]
        used.update(at(x, y) for x, y in opaque)
        prefix = f"frame {n}: " if len(data["frames"]) > 1 else ""
        if not opaque:
            lines.append(prefix + "EMPTY: no opaque pixels")
            continue
        xs = [p[0] for p in opaque]
        ys = [p[1] for p in opaque]
        bx0, bx1, by0, by1 = min(xs), max(xs), min(ys), max(ys)
        lines.append(
            f"{prefix}bbox x={bx0}..{bx1} y={by0}..{by1} "
            f"({bx1 - bx0 + 1}x{by1 - by0 + 1} of {w}x{h}), "
            f"coverage {100 * len(opaque) // (w * h)}%, "
            f"margins L{bx0} R{w - 1 - bx1} T{by0} B{h - 1 - by1}"
        )
        nb8 = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
        floating = [(x, y) for x, y in opaque if not any(at(x + dx, y + dy) for dx, dy in nb8)]
        if floating:
            lines.append(f"{prefix}floating pixels (no opaque neighbor): {len(floating)} at {floating[:10]}")
        orphans = [
            (x, y, names[at(x, y) - 1]) for x, y in opaque
            if all(at(x + dx, y + dy) != at(x, y) for dx, dy in nb8)
        ]
        if orphans:
            lines.append(
                f"{prefix}single-pixel color islands: {len(orphans)} "
                f"(can be noise, or intended highlights) e.g. {orphans[:8]}"
            )
    unused = [names[i - 1] for i in range(1, len(names) + 1) if i not in used]
    lines.insert(0, f"colors used {len(used)}/{len(names)}" + (f", unused: {unused}" if unused else ""))
    return lines


# ---------------------------------------------------------------------------
# Critique sheet
# ---------------------------------------------------------------------------

def font(size):
    try:
        return ImageFont.load_default(size=size)
    except TypeError:
        return ImageFont.load_default()


def checker(w, h, cell, a=(200, 200, 200), b=(160, 160, 160)):
    img = Image.new("RGB", (w, h), a)
    d = ImageDraw.Draw(img)
    for y in range(0, h, cell):
        for x in range(0, w, cell):
            if (x // cell + y // cell) % 2:
                d.rectangle([x, y, x + cell - 1, y + cell - 1], fill=b)
    return img


def on_bg(frame, scale, bg, grid=False):
    w, h = frame.size
    big = frame.resize((w * scale, h * scale), Image.NEAREST)
    if bg == "checker":
        base = checker(w * scale, h * scale, scale).convert("RGBA")
    else:
        base = Image.new("RGBA", big.size, bg)
    base.alpha_composite(big)
    if grid and scale >= 6:
        d = ImageDraw.Draw(base)
        for i in range(1, w):
            d.line([(i * scale, 0), (i * scale, h * scale)], fill=(0, 0, 0, 60))
        for j in range(1, h):
            d.line([(0, j * scale), (w * scale, j * scale)], fill=(0, 0, 0, 60))
        # Coordinate ticks every 4 px, to help the critique point at pixels.
        f = font(10)
        for i in range(0, w, 4):
            d.text((i * scale + 2, 1), str(i), fill=(255, 0, 255, 255), font=f)
        for j in range(4, h, 4):
            d.text((1, j * scale + 1), str(j), fill=(255, 0, 255, 255), font=f)
    return base


def build_sheet(name, data, frames, lint_lines, iteration):
    w, h = data["w"], data["h"]
    scale = max(4, min(16, 320 // max(w, h)))
    pad = 16
    title_f, text_f = font(18), font(13)
    tiles = []  # (label, image)
    for n, fr in enumerate(frames, start=1):
        sfx = f" f{n}" if len(frames) > 1 else ""
        tiles.append([
            (f"checker x{scale}{sfx}", on_bg(fr, scale, "checker")),
            (f"dark x{scale}{sfx}", on_bg(fr, scale, (24, 24, 32, 255))),
            (f"grid x{scale}{sfx}", on_bg(fr, scale, (232, 232, 232, 255), grid=True)),
        ])
    # Actual size and 2x / 3x, as players see it.
    small = Image.new("RGBA", (w * 6 + pad * 3 + 4, h * 3 + 4), (90, 110, 90, 255))
    x = 2
    for s in (1, 2, 3):
        for fr in frames[:1]:
            small.alpha_composite(fr.resize((w * s, h * s), Image.NEAREST), (x, 2))
        x += w * s + pad
    tile_w = w * scale
    cols = 3
    sheet_w = pad + cols * (tile_w + pad)
    rows_h = sum(h * scale + pad + 18 for _ in tiles)
    pal_h = 22 * ((len(data["palette"]) + 3) // 4) + 30
    lint_h = 18 * len(lint_lines) + 30
    sheet_h = 40 + rows_h + small.height + 40 + pal_h + lint_h
    sheet_w = max(sheet_w, 720)
    sheet = Image.new("RGBA", (sheet_w, sheet_h), (48, 48, 56, 255))
    d = ImageDraw.Draw(sheet)
    d.text((pad, 10), f"{name}  iteration {iteration:03d}  {w}x{h}  frames {len(frames)}",
           fill="white", font=title_f)
    y = 40
    for row in tiles:
        x = pad
        for label, img in row:
            d.text((x, y), label, fill=(200, 200, 200), font=text_f)
            sheet.alpha_composite(img, (x, y + 18))
            x += tile_w + pad
        y += h * scale + pad + 18
    d.text((pad, y), "actual size 1x / 2x / 3x on a game-like background", fill=(200, 200, 200), font=text_f)
    sheet.alpha_composite(small, (pad, y + 18))
    y += small.height + 40
    d.text((pad, y), "palette", fill=(200, 200, 200), font=text_f)
    y += 20
    for i, p in enumerate(data["palette"]):
        cx = pad + (i % 4) * 170
        cy = y + (i // 4) * 22
        d.rectangle([cx, cy, cx + 16, cy + 16], fill=(p["r"], p["g"], p["b"], 255), outline="black")
        d.text((cx + 22, cy + 1), p["name"], fill="white", font=text_f)
    y += 22 * ((len(data["palette"]) + 3) // 4) + 10
    d.text((pad, y), "lint", fill=(200, 200, 200), font=text_f)
    for i, line in enumerate(lint_lines):
        d.text((pad, y + 20 + i * 18), line, fill=(255, 220, 140), font=text_f)
    return sheet


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

def cmd_new(args):
    w, h = (int(v) for v in (args.size_pos or args.size).lower().split("x"))
    d = ASSETS / args.name
    if (d / "sprite.lua").exists():
        raise SystemExit(f"{d / 'sprite.lua'} exists")
    d.mkdir(parents=True, exist_ok=True)
    r = min(w, h) // 3
    (d / "sprite.lua").write_text(TEMPLATE.format(
        name=args.name, w=w, h=h, cx=(w - 1) / 2, cy=(h - 1) / 2, r=r))
    print(d / "sprite.lua")


def cmd_render(args):
    d = ASSETS / args.name
    script = d / "sprite.lua"
    data = run_script(script)
    frames = composite(data)
    it_root = d / "iterations"
    it_root.mkdir(exist_ok=True)
    existing = sorted(int(p.name) for p in it_root.iterdir() if p.name.isdigit())
    if existing and not args.force:
        last = it_root / f"{existing[-1]:03d}"
        if (last / "sprite.lua").read_text() == script.read_text():
            print(f"sprite.lua is unchanged since iteration {existing[-1]:03d}. Nothing to render.")
            print(f"preview: {last / 'preview.png'}")
            print("Use --force to render a new iteration anyway.")
            return
    n =(existing[-1] + 1) if existing else 1
    out = it_root / f"{n:03d}"
    out.mkdir()
    shutil.copy(script, out / "sprite.lua")
    lint_lines = lint(data)
    # Change count against the previous iteration.
    if existing:
        prev_png = it_root / f"{existing[-1]:03d}" / "frame1.png"
        if prev_png.exists():
            prev = Image.open(prev_png).convert("RGBA")
            if prev.size == frames[0].size:
                pa, pb = prev.tobytes(), frames[0].tobytes()
                changed = sum(pa[i:i + 4] != pb[i:i + 4] for i in range(0, len(pa), 4))
                lint_lines.append(f"pixels changed vs iteration {existing[-1]:03d} (frame 1): {changed}")
    for i, fr in enumerate(frames, start=1):
        fr.save(out / f"frame{i}.png")
    if len(frames) > 1:
        durations = [f.get("duration", 100) for f in data["frames"]]
        big = [fr.resize((fr.width * 8, fr.height * 8), Image.NEAREST) for fr in frames]
        big[0].save(out / "anim.gif", save_all=True, append_images=big[1:],
                    duration=durations, loop=0, disposal=2)
    sheet = build_sheet(args.name, data, frames, lint_lines, n)
    sheet.save(out / "preview.png")
    (out / "lint.txt").write_text("\n".join(lint_lines) + "\n")
    shutil.copy(out / "frame1.png", d / f"{args.name}.png")
    print(f"iteration {n:03d}")
    print(f"preview: {out / 'preview.png'}")
    print("lint:")
    for line in lint_lines:
        print("  " + line)


def cmd_aseprite(args):
    exe = os.environ.get("ASEPRITE") or shutil.which("aseprite")
    if not exe:
        raise SystemExit("Aseprite not found. Put it on PATH or set ASEPRITE=/path/to/aseprite.")
    d = ASSETS / args.name
    out = d / f"{args.name}.aseprite"
    subprocess.run([exe, "-b",
                    "--script-param", f"asset={d / 'sprite.lua'}",
                    "--script-param", f"out={out}",
                    "--script", str(ROOT / "aseprite" / "build.lua")], check=True)
    print(out)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("new"); a.add_argument("name")
    a.add_argument("size_pos", nargs="?", metavar="size", help="WxH, for example 32x32")
    a.add_argument("--size", default="32x32")
    a.set_defaults(fn=cmd_new)
    a = sub.add_parser("render"); a.add_argument("name")
    a.add_argument("--force", action="store_true", help="render even if sprite.lua is unchanged")
    a.set_defaults(fn=cmd_render)
    a = sub.add_parser("aseprite"); a.add_argument("name"); a.set_defaults(fn=cmd_aseprite)
    args = p.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
