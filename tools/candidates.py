#!/usr/bin/env python3
"""Helpers for the best-of-N loop: one critic picks the best of several candidates.

  compare <target> <cand>...    Build assets/<target>/rounds/round_NN.png: the latest
                                render of each candidate, side by side.
  pair <out.png> <left_frame.png> <right_frame.png>
                                Build an anonymous LEFT/RIGHT image for blind judging.
  promote <target> <winner> <cand>...
                                Copy the winner's sprite.lua into <target>, render it,
                                and copy it into every candidate as the next start point.
"""
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"
PY = ROOT / ".venv" / "bin" / "python"


def latest_iteration(name):
    its = sorted(p for p in (ASSETS / name / "iterations").iterdir() if p.name.isdigit())
    return its[-1]


def checker(w, h, cell):
    img = Image.new("RGBA", (w, h), (200, 200, 200, 255))
    d = ImageDraw.Draw(img)
    for y in range(0, h, cell):
        for x in range(0, w, cell):
            if (x // cell + y // cell) % 2:
                d.rectangle([x, y, x + cell - 1, y + cell - 1], fill=(160, 160, 160, 255))
    return img


def compare(target, cands):
    rounds = ASSETS / target / "rounds"
    rounds.mkdir(exist_ok=True)
    n = len(list(rounds.glob("round_*.png"))) + 1
    frames = [(c, Image.open(latest_iteration(c) / "frame1.png").convert("RGBA")) for c in cands]
    w, h = frames[0][1].size
    scale, pad = 12, 24
    f = ImageFont.load_default(size=22)
    small_f = ImageFont.load_default(size=14)
    col_w = w * scale + pad
    sheet = Image.new("RGBA", (pad + col_w * len(frames), 50 + h * scale + pad + h * 3 + 50),
                      (48, 48, 56, 255))
    d = ImageDraw.Draw(sheet)
    for i, (name, img) in enumerate(frames):
        x = pad + i * col_w
        label = name.split("_")[-1].upper()
        d.text((x, 12), f"{label}   ({latest_iteration(name).name})", fill="white", font=f)
        big = checker(w * scale, h * scale, scale)
        big.alpha_composite(img.resize((w * scale, h * scale), Image.NEAREST))
        sheet.alpha_composite(big, (x, 50))
        y = 50 + h * scale + pad
        game = Image.new("RGBA", (w * 6 + 20, h * 3 + 10), (90, 110, 90, 255))
        game.alpha_composite(img, (5, 5))
        game.alpha_composite(img.resize((w * 3, h * 3), Image.NEAREST), (w + 15, 5))
        sheet.alpha_composite(game, (x, y))
        d.text((x, y + game.height + 4), "1x and 3x", fill=(200, 200, 200), font=small_f)
    out = rounds / f"round_{n:02d}.png"
    sheet.save(out)
    print(out)
    for c in cands:
        print(f"{c}: {latest_iteration(c) / 'preview.png'}")


def pair(out, left, right):
    imgs = [Image.open(left).convert("RGBA"), Image.open(right).convert("RGBA")]
    w, h = imgs[0].size
    scale, pad = 12, 24
    f = ImageFont.load_default(size=22)
    col_w = w * scale + pad
    sheet = Image.new("RGBA", (pad + col_w * 2, 50 + h * scale + pad + h * 3 + 30), (48, 48, 56, 255))
    d = ImageDraw.Draw(sheet)
    for i, (label, img) in enumerate(zip(["LEFT", "RIGHT"], imgs)):
        x = pad + i * col_w
        d.text((x, 12), label, fill="white", font=f)
        big = checker(w * scale, h * scale, scale)
        big.alpha_composite(img.resize((w * scale, h * scale), Image.NEAREST))
        sheet.alpha_composite(big, (x, 50))
        game = Image.new("RGBA", (w * 4 + 20, h * 3 + 10), (90, 110, 90, 255))
        game.alpha_composite(img, (5, 5))
        game.alpha_composite(img.resize((w * 3, h * 3), Image.NEAREST), (w + 15, 5))
        sheet.alpha_composite(game, (x, 50 + h * scale + pad))
    sheet.save(out)
    print(out)


def promote(target, winner, cands):
    src = (ASSETS / winner / "sprite.lua").read_text()
    (ASSETS / target / "sprite.lua").write_text(src)
    subprocess.run([str(PY), str(ROOT / "pixelaite.py"), "render", target, "--force"], check=True)
    for c in cands:
        (ASSETS / c / "sprite.lua").write_text(src)


def main():
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd == "compare":
        compare(args[0], args[1:])
    elif cmd == "pair":
        pair(args[0], args[1], args[2])
    elif cmd == "promote":
        promote(args[0], args[1], args[2:])
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
