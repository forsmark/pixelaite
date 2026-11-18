#!/usr/bin/env python3
"""Hybrid loop: a local model draws, a Claude agent judges (the orchestrator runs the judge).

  draw <round> <target>... [--cands 3] [--model ID]
        For each target: draw candidates from assets/<target>/sprite.lua and the last goals,
        then build a blind sheet hybrid/rNN_sheet.png with the current best and the
        candidates shuffled under the labels A, B, C, ... The mapping is in hybrid/rNN_map.json.
  pick <target> <round> <label> <judge_answer_file> [--confidence low|medium|high]
        Promote the entry with that label, save the judge's answer as the next goals,
        and render a new iteration if the winner is a candidate. With low confidence,
        the current best stays.
"""
import argparse
import json
import random
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from PIL import Image, ImageDraw, ImageFont  # noqa: E402

import local_loop as L  # noqa: E402
from pixelaite import ASSETS, ROOT  # noqa: E402

DEFAULT_MODEL = "gemma-4-26B-A4B-it-GGUF-UD-IQ4_XS"


def checker(w, h, cell):
    img = Image.new("RGBA", (w, h), (200, 200, 200, 255))
    d = ImageDraw.Draw(img)
    for y in range(0, h, cell):
        for x in range(0, w, cell):
            if (x // cell + y // cell) % 2:
                d.rectangle([x, y, x + cell - 1, y + cell - 1], fill=(160, 160, 160, 255))
    return img


def sheet(entries, out):
    """entries: list of (label, frame). Each at 10x on checker, plus 1x and 3x on green."""
    w, h = entries[0][1].size
    s, pad = 10, 20
    f = ImageFont.load_default(size=22)
    col = w * s + pad
    img = Image.new("RGBA", (pad + col * len(entries), 50 + h * s + pad + h * 3 + 20), (48, 48, 56, 255))
    d = ImageDraw.Draw(img)
    for i, (label, fr) in enumerate(entries):
        x = pad + i * col
        d.text((x, 12), label, fill="white", font=f)
        b = checker(w * s, h * s, s)
        b.alpha_composite(fr.resize((w * s, h * s), Image.NEAREST))
        img.alpha_composite(b, (x, 50))
        g = Image.new("RGBA", (w * s, h * 3 + 10), (90, 110, 90, 255))
        g.alpha_composite(fr, (5, 5))
        g.alpha_composite(fr.resize((w * 3, h * 3), Image.NEAREST), (w + 15, 5))
        img.alpha_composite(g, (x, 50 + h * s + pad))
    img.save(out)


def cmd_draw(args):
    log = []
    m = L.Model(args.model, False, log.append)
    for target in args.targets:
        tdir = ASSETS / target
        hdir = tdir / "hybrid"
        hdir.mkdir(exist_ok=True)
        brief = (tdir / "brief.md").read_text()
        prev_goals = hdir / f"r{args.round - 1:02d}_judge.md"
        goals = prev_goals.read_text() if prev_goals.exists() else "(no notes yet: improve whatever looks weakest)"
        entries = []
        current = ""   # no sprite.lua yet: draw from scratch, the judge picks the start
        if (tdir / "sprite.lua").exists():
            current = (tdir / "sprite.lua").read_text()
            _, cur_frame, err = L.try_render(tdir / "sprite.lua")
            assert not err, err
            entries = [("current", cur_frame)]
        for k in range(args.cands):
            path = hdir / f"r{args.round:02d}_c{k + 1}.lua"
            _, frame = L.draw(m, brief, current, goals, L.STRATEGIES[k % len(L.STRATEGIES)], path)
            if frame is None:
                print(f"{target} c{k + 1}: failed to render", flush=True)
                continue
            frame.save(path.with_suffix(".png"))
            entries.append((f"c{k + 1}", frame))
        random.shuffle(entries)
        labels = "ABCDEFGH"
        mapping = {labels[i]: name for i, (name, _) in enumerate(entries)}
        (hdir / f"r{args.round:02d}_map.json").write_text(json.dumps(mapping, indent=1))
        out = hdir / f"r{args.round:02d}_sheet.png"
        sheet([(labels[i], fr) for i, (_, fr) in enumerate(entries)], out)
        print(f"{target}: {out}  entries {len(entries)}", flush=True)
    secs = sum(e["seconds"] for e in log)
    toks = sum(e["prompt_tokens"] + e["completion_tokens"] for e in log)
    print(f"local calls {len(log)}, tokens {toks:,}, model time {secs:.0f} s")


def cmd_pick(args):
    tdir = ASSETS / args.target
    hdir = tdir / "hybrid"
    mapping = json.loads((hdir / f"r{args.round:02d}_map.json").read_text())
    winner = mapping[args.label.upper()]
    shutil.copy(args.answer, hdir / f"r{args.round:02d}_judge.md")
    if winner != "current" and args.confidence == "low":
        print(f"{args.target} round {args.round}: judge picked {winner} with low confidence -> kept current")
        return
    if winner != "current":
        shutil.copy(hdir / f"r{args.round:02d}_{winner}.lua", tdir / "sprite.lua")
        subprocess.run([sys.executable, str(ROOT / "pixelaite.py"), "render", args.target, "--force"],
                       check=True, stdout=subprocess.DEVNULL)
    print(f"{args.target} round {args.round}: winner {args.label.upper()} = {winner}")


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("draw")
    a.add_argument("round", type=int)
    a.add_argument("targets", nargs="+")
    a.add_argument("--cands", type=int, default=3)
    a.add_argument("--model", default=DEFAULT_MODEL)
    a.set_defaults(fn=cmd_draw)
    a = sub.add_parser("pick")
    a.add_argument("target"); a.add_argument("round", type=int)
    a.add_argument("label"); a.add_argument("answer")
    a.add_argument("--confidence", choices=["low", "medium", "high"], default="medium",
                   help="a candidate replaces the current best only with medium or high confidence")
    a.set_defaults(fn=cmd_pick)
    args = ap.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
