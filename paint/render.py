#!/usr/bin/env python3
"""Render a watercolor paint script with p5.brush in headless Chrome.

  new <name> [--size 512x512]   create assets/<name>/paint.js from a template
  render <name> [--force]       render to assets/<name>/iterations/NNN/
                                (paint.js, image.png, preview.png, info.txt)
  check <name>                  render the current script twice and report if the PNGs match

The script is an ES module: `export const meta = {w, h, seed, paper}` and
`export default function draw(brush, W, H) { ... }` with top-left coordinates.
"""
import argparse
import base64
import functools
import hashlib
import http.server
import io
import shutil
import sys
import threading
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"

TEMPLATE = """// Brief: <subject, size, view, palette mood, use>
export const meta = { w: %d, h: %d, seed: 1, paper: "#f4efe2" }

export default function draw(brush, W, H) {
  // 1. Light washes first, large shapes.
  brush.noStroke()
  brush.fill("#7fa7c9", 90)
  brush.fillBleed(0.2)
  brush.fillTexture(0.4, 0.5)
  brush.rect(0, 0, W, H * 0.6)
  brush.noFill()

  // 2. Darker shapes, then 3. line work and details on top.
  brush.set("HB", "#2b2233", 1)
  brush.spline([[W * 0.2, H * 0.7], [W * 0.5, H * 0.62], [W * 0.8, H * 0.72]], 0.5)
}
"""


class Quiet(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


def serve():
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", 0), functools.partial(Quiet, directory=str(ROOT)))
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    return srv


def render_png(script_rel, timeout=120):
    """Return (frames, durations, brushes, fields) or raise RuntimeError with the JS error."""
    from playwright.sync_api import sync_playwright
    srv = serve()
    port = srv.server_address[1]
    try:
        with sync_playwright() as p:
            args = ["--use-angle=swiftshader", "--enable-unsafe-swiftshader",
                    "--use-gl=angle", "--disable-gpu-rasterization"]
            try:  # Google Chrome if installed, else Playwright's own Chromium
                b = p.chromium.launch(channel="chrome", headless=True, args=args)
            except Exception:
                b = p.chromium.launch(headless=True, args=args)
            page = b.new_page()
            errors = []
            page.on("pageerror", lambda e: errors.append(str(e)))
            page.goto(f"http://127.0.0.1:{port}/paint/runner.html?script=/{script_rel}")
            page.wait_for_function("window.__done === true", timeout=timeout * 1000)
            err = page.evaluate("window.__error || null")
            if err or errors:
                raise RuntimeError(err or "\n".join(errors))
            data = page.evaluate("window.__frames")
            durations = page.evaluate("window.__durations")
            brushes = page.evaluate("window.__brushes")
            fields = page.evaluate("window.__fields")
            b.close()
    finally:
        srv.shutdown()
    frames = [Image.open(io.BytesIO(base64.b64decode(d.split(",", 1)[1]))).convert("RGB") for d in data]
    return frames, durations, brushes, fields


def preview(img, out):
    """Full image, a grid view with coordinates every 50 px, and small views as a player/viewer sees them."""
    w, h = img.size
    f = ImageFont.load_default(size=12)
    grid = img.copy()
    d = ImageDraw.Draw(grid)
    for x in range(0, w, 50):
        d.line([(x, 0), (x, h)], fill=(255, 0, 140), width=1)
        d.text((x + 2, 2), str(x), fill=(255, 0, 140), font=f)
    for y in range(0, h, 50):
        d.line([(0, y), (w, y)], fill=(255, 0, 140), width=1)
        d.text((2, y + 2), str(y), fill=(255, 0, 140), font=f)
    small = img.resize((w // 4, h // 4), Image.LANCZOS)
    half = img.resize((w // 2, h // 2), Image.LANCZOS)
    gray = img.convert("L").convert("RGB")
    pad = 16
    sheet = Image.new("RGB", (w * 2 + pad * 3, h + h // 2 + pad * 4 + 20), (40, 40, 46))
    sd = ImageDraw.Draw(sheet)
    sheet.paste(img, (pad, pad + 16)); sd.text((pad, 2), "image", fill="white", font=f)
    sheet.paste(grid, (w + pad * 2, pad + 16)); sd.text((w + pad * 2, 2), "grid (px)", fill="white", font=f)
    y2 = h + pad * 2 + 32
    sheet.paste(half, (pad, y2)); sd.text((pad, y2 - 16), "1/2", fill="white", font=f)
    sheet.paste(small, (w // 2 + pad * 2, y2)); sd.text((w // 2 + pad * 2, y2 - 16), "1/4", fill="white", font=f)
    sheet.paste(gray.resize((w // 2, h // 2)), (w + pad * 2, y2)); sd.text((w + pad * 2, y2 - 16), "values (grayscale)", fill="white", font=f)
    sheet.save(out)


def strip(frames, out, scale=0.5):
    """All frames side by side, plus a difference view per frame (what changed from frame 1)."""
    w, h = frames[0].size
    tw, th = int(w * scale), int(h * scale)
    f = ImageFont.load_default(size=12)
    pad = 8
    sheet = Image.new("RGB", (pad + len(frames) * (tw + pad), 2 * (th + pad + 16) + pad), (40, 40, 46))
    d = ImageDraw.Draw(sheet)
    base = frames[0].convert("L")
    from PIL import ImageChops
    for i, fr in enumerate(frames):
        x = pad + i * (tw + pad)
        d.text((x, 2), f"frame {i + 1}", fill="white", font=f)
        sheet.paste(fr.resize((tw, th), Image.LANCZOS), (x, 16))
        diff = ImageChops.difference(fr.convert("L"), base).point(lambda v: min(255, v * 4))
        d.text((x, th + pad + 18), "changed vs 1", fill="white", font=f)
        sheet.paste(diff.resize((tw, th)).convert("RGB"), (x, th + pad + 32))
    sheet.save(out)


def cmd_new(a):
    d = ASSETS / a.name
    d.mkdir(parents=True, exist_ok=True)
    p = d / "paint.js"
    if p.exists():
        sys.exit(f"{p} exists")
    w, h = map(int, a.size.lower().split("x"))
    p.write_text(TEMPLATE % (w, h))
    print(p)


def cmd_render(a):
    d = ASSETS / a.name
    src = d / "paint.js"
    its = d / "iterations"
    its.mkdir(exist_ok=True)
    prev = sorted(p for p in its.iterdir() if p.name.isdigit())
    if prev and not a.force and (prev[-1] / "paint.js").read_text() == src.read_text():
        print(f"unchanged since {prev[-1].name}, use --force"); return
    try:
        frames, durations, brushes, fields = render_png(f"assets/{a.name}/paint.js")
    except RuntimeError as e:
        sys.exit("render failed:\n" + str(e))
    out = its / f"{len(prev) + 1:03d}"
    out.mkdir()
    shutil.copy(src, out / "paint.js")
    img = frames[0]
    img.save(out / "image.png")
    preview(img, out / "preview.png")
    if len(frames) > 1:
        for i, fr in enumerate(frames):
            fr.save(out / f"frame{i + 1}.png")
        frames[0].save(out / "anim.gif", save_all=True, append_images=frames[1:], duration=durations, loop=0)
        strip(frames, out / "frames.png")
    info = [f"size {img.size[0]}x{img.size[1]}, frames {len(frames)}, durations {durations}",
            f"sha256 {hashlib.sha256(b''.join(f.tobytes() for f in frames)).hexdigest()[:16]}",
            "brushes: " + ", ".join(brushes), "fields: " + ", ".join(fields)]
    (out / "info.txt").write_text("\n".join(info) + "\n")
    print(out)
    print("\n".join(info[:2]))


def cmd_check(a):
    r = [hashlib.sha256(b"".join(f.tobytes() for f in render_png(f"assets/{a.name}/paint.js")[0])).hexdigest()[:16]
         for _ in range(2)]
    print(f"run 1 {r[0]}\nrun 2 {r[1]}\n{'deterministic' if r[0] == r[1] else 'NOT deterministic'}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("new"); s.add_argument("name"); s.add_argument("--size", default="512x512"); s.set_defaults(fn=cmd_new)
    s = sub.add_parser("render"); s.add_argument("name"); s.add_argument("--force", action="store_true"); s.set_defaults(fn=cmd_render)
    s = sub.add_parser("check"); s.add_argument("name"); s.set_defaults(fn=cmd_check)
    a = ap.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
