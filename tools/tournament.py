#!/usr/bin/env python3
"""Blind pairwise tournament: current best + candidates, judged LEFT vs RIGHT.

  setup   <target> <round> <cand>...   Shuffle the current best and the candidates into two
                                        semifinals. Write judge/rNN_semi1.png and _semi2.png.
  final   <target> <round> <s1> <s2>   s1, s2 are the judges' LEFT/RIGHT picks. Write rNN_final.png.
  resolve <target> <round> <f>         f is the final pick. Print the winner's asset name.

The mapping from LEFT/RIGHT to asset names is in judge/rNN.json. Never show it to a judge.
"""
import json
import random
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"
PY = ROOT / ".venv" / "bin" / "python"


def latest_frame(name):
    its = sorted(p for p in (ASSETS / name / "iterations").iterdir() if p.name.isdigit())
    return str(its[-1] / "frame1.png")


def make_pair(out, left, right):
    subprocess.run([str(PY), str(ROOT / "tools" / "candidates.py"), "pair", out,
                    latest_frame(left), latest_frame(right)], check=True, stdout=subprocess.DEVNULL)


def main():
    cmd, target, rnd = sys.argv[1], sys.argv[2], int(sys.argv[3])
    jdir = ASSETS / target / "judge"
    jdir.mkdir(exist_ok=True)
    mfile = jdir / f"r{rnd:02d}.json"
    if cmd == "setup":
        entries = [target] + sys.argv[4:]   # the target folder holds the current best
        random.shuffle(entries)
        m = {"semi1": entries[0:2], "semi2": entries[2:4]}
        for k in ("semi1", "semi2"):
            make_pair(str(jdir / f"r{rnd:02d}_{k}.png"), *m[k])
            print(jdir / f"r{rnd:02d}_{k}.png")
        mfile.write_text(json.dumps(m, indent=1))
    elif cmd == "final":
        m = json.loads(mfile.read_text())
        pick = lambda pair, side: pair[0] if side.upper() == "LEFT" else pair[1]
        finalists = [pick(m["semi1"], sys.argv[4]), pick(m["semi2"], sys.argv[5])]
        random.shuffle(finalists)
        m["final"] = finalists
        make_pair(str(jdir / f"r{rnd:02d}_final.png"), *finalists)
        mfile.write_text(json.dumps(m, indent=1))
        print(jdir / f"r{rnd:02d}_final.png")
    elif cmd == "resolve":
        m = json.loads(mfile.read_text())
        winner = m["final"][0] if sys.argv[4].upper() == "LEFT" else m["final"][1]
        m["winner"] = winner
        mfile.write_text(json.dumps(m, indent=1))
        print(winner)
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
