#!/usr/bin/env python3
"""Render-and-critique loop with a local model served by Lemonade (OpenAI-compatible API).

The same local model draws and judges:
  1. Each round, K drawers write a full sprite.lua. Lua errors go back to the drawer for a retry.
  2. Each candidate challenges the current best. Two judge modes:
     --judge score (default): the model turns the brief into yes/no checks once
       (saved to assets/<target>/checks.md, edit it if you like). Each sprite is shown
       alone and scored on the checks, twice. The candidate replaces the current best
       only if its mean score is strictly higher.
     --judge pair: a blind LEFT/RIGHT judgment, twice with the sides swapped. The
       candidate replaces the current best only if it wins both times.
  3. The judge writes goals (not pixel positions) for the next round.

Usage:
  tools/local_loop.py <target> [--rounds 3] [--cands 3] [--model ID] [--think] [--judge score|pair]
                      [--start path/to/sprite.lua]

<target> is an asset folder with brief.md. Output: assets/<target>/local/ (all candidates,
judge answers, log.jsonl) and the winner of each round rendered into assets/<target>/iterations/.
"""
import argparse
import base64
import io
import json
import re
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from PIL import Image, ImageDraw, ImageFont  # noqa: E402

from pixelaite import ASSETS, ROOT, composite, lint, run_script  # noqa: E402

URL = "http://localhost:13305/api/v1/chat/completions"
DEFAULT_MODEL = "gemma-4-E4B-it-GGUF-Q4_K_M"

API_REF = (ROOT / "CLAUDE.md").read_text().split("## Techniques that worked")[1]
API_REF = "## Techniques that worked" + API_REF

STRATEGIES = [
    "Fix the most important goal with the smallest change. Keep everything else.",
    "Fix the most important goal with a different approach than the current script uses.",
    "Work on the second goal in the list. Keep everything else.",
    "Fix the most important goal, and make the silhouette bolder and simpler.",
]


# ---------------------------------------------------------------------------
# Model calls
# ---------------------------------------------------------------------------

class Model:
    def __init__(self, model, think, log):
        self.model, self.think, self.log = model, think, log

    def chat(self, role, content, max_tokens=6000, temperature=0.7):
        body = {"model": self.model, "max_tokens": max_tokens, "temperature": temperature,
                "messages": [{"role": "user", "content": content}]}
        if not self.think:
            body["chat_template_kwargs"] = {"enable_thinking": False}
        t = time.time()
        req = urllib.request.Request(URL, json.dumps(body).encode(), {"Content-Type": "application/json"})
        r = json.load(urllib.request.urlopen(req, timeout=900))
        usage = r.get("usage", {})
        entry = {"role": role, "seconds": round(time.time() - t, 1),
                 "prompt_tokens": usage.get("prompt_tokens", 0),
                 "completion_tokens": usage.get("completion_tokens", 0)}
        self.log(entry)
        return r["choices"][0]["message"].get("content") or ""


def image_part(img):
    buf = io.BytesIO()
    img.convert("RGB").save(buf, "PNG")
    return {"type": "image_url", "image_url": {"url": "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode()}}


def big(frame, size=320, bg=(90, 110, 90, 255)):
    out = Image.new("RGBA", (size, size), bg)
    out.alpha_composite(frame.resize((size, size), Image.NEAREST))
    return out


def pair_image(a, b):
    """LEFT/RIGHT sheet: each sprite large, plus 1x and 3x."""
    f = ImageFont.load_default(size=22)
    w = 320
    sheet = Image.new("RGBA", (w * 2 + 60, w + 130), (48, 48, 56, 255))
    d = ImageDraw.Draw(sheet)
    for i, (label, fr) in enumerate([("LEFT", a), ("RIGHT", b)]):
        x = 20 + i * (w + 20)
        d.text((x, 8), label, fill="white", font=f)
        sheet.alpha_composite(big(fr, w), (x, 40))
        strip = Image.new("RGBA", (w, 70), (90, 110, 90, 255))
        strip.alpha_composite(fr, (10, 25))
        strip.alpha_composite(fr.resize((fr.width * 3, fr.height * 3), Image.NEAREST), (50, 5))
        sheet.alpha_composite(strip, (x, w + 50))
    return sheet


# ---------------------------------------------------------------------------
# Steps
# ---------------------------------------------------------------------------

def extract_lua(text):
    blocks = re.findall(r"```(?:lua)?\s*\n(.*?)```", text, re.S)
    code = max(blocks, key=len) if blocks else text
    return code.strip() + "\n"


def try_render(path):
    try:
        data = run_script(path)
        return data, composite(data)[0], None
    except SystemExit as e:
        return None, None, str(e)[-1500:]
    except Exception as e:  # noqa: BLE001
        return None, None, f"{type(e).__name__}: {e}"[-1500:]


def draw(m, brief, current, goals, strategy, path, retries=2):
    if current:
        task = (f"Here is the current best script:\n```lua\n{current}```\n\n"
                f"The judge's notes on the current best:\n{goals}\n\n"
                f"Your strategy: {strategy}\nWrite the complete improved script.")
    else:
        task = "Write the complete script from scratch."
    prompt = (f"You write pixel art sprites as Lua scripts with the px library.\n\n{API_REF}\n\n"
              f"# Brief\n{brief}\n\n# Task\n{task}\n\n"
              "Rules: use only the palette names from the brief. The script must end with `return s`. "
              "Answer with one ```lua code block and nothing else.")
    msg = prompt
    for attempt in range(retries + 1):
        out = m.chat("draw", msg)
        code = extract_lua(out)
        path.write_text(code)
        data, frame, err = try_render(path)
        if not err:
            return data, frame
        msg = (prompt + f"\n\n# Your previous attempt failed\n```lua\n{code}```\nError:\n{err}\n"
               "Fix the error and answer with the complete corrected script.")
    return None, None


def judge_once(m, brief, a, b):
    prompt = ("You judge two pixel art game sprites. The brief:\n" + brief +
              "\n\nWhich sprite better fits the brief, as a player sees it at 1x and 3x? "
              "Weigh: (1) the silhouette reads instantly as the subject, (2) the brief's features "
              "are present, (3) clean shapes, no mud or stray pixels.\n"
              "End your answer with exactly one line: WINNER: LEFT or WINNER: RIGHT")
    out = m.chat("judge", [{"type": "text", "text": prompt}, image_part(pair_image(a, b))], temperature=0.2)
    hit = re.findall(r"WINNER:\s*\**\s*(LEFT|RIGHT)", out.upper())
    return (hit[-1] if hit else None), out


def challenge(m, brief, champ, cand):
    """True if the candidate beats the champion with the sides in both orders."""
    first, t1 = judge_once(m, brief, champ, cand)    # candidate is RIGHT
    second, t2 = judge_once(m, brief, cand, champ)   # candidate is LEFT
    return (first == "RIGHT" and second == "LEFT"), [first, second], [t1, t2]


def make_checks(m, brief, path):
    if path.exists():
        return [l.split(".", 1)[1].strip() for l in path.read_text().splitlines() if re.match(r"\s*\d+\.", l)]
    prompt = ("Turn this pixel art brief into 6 to 8 yes/no checks that a reviewer can answer by looking at "
              "the finished sprite. Each check is one short question. A good sprite gets YES on every check. "
              "Put the most important checks first: does the silhouette read as the subject, the pose, "
              "the view direction. Do not ask about the palette hex values or the margin.\n\nBrief:\n" + brief +
              "\n\nAnswer with a numbered list only.")
    out = m.chat("checks", prompt, temperature=0.2)
    checks = [l.split(".", 1)[1].strip() for l in out.splitlines() if re.match(r"\s*\d+\.", l)]
    path.write_text("\n".join(f"{i + 1}. {c}" for i, c in enumerate(checks)) + "\n")
    return checks


def score_once(m, checks, frame):
    """One call per check, sprite alone, look first and then answer (more reliable than one batch)."""
    img = image_part(big(frame))
    yes, texts = 0, []
    for i, c in enumerate(checks):
        prompt = ("This image shows a pixel art game sprite, scaled up on a green background. "
                  "First describe in one or two sentences what you see that is relevant to the question. "
                  f"Then answer the question.\n\nQuestion: {c}\n\nEnd with one line: ANSWER: YES or ANSWER: NO")
        out = m.chat("score", [{"type": "text", "text": prompt}, img], max_tokens=1500, temperature=0.2)
        hit = re.findall(r"ANSWER:\s*\**\s*(YES|NO)", out.upper())
        ok = bool(hit) and hit[-1] == "YES"
        yes += ok
        texts.append(f"{i + 1}. {c} -> {'YES' if ok else 'NO'}\n{out.strip()}")
    return yes, "\n\n".join(texts)


def score(m, checks, frame, n=1):
    results = [score_once(m, checks, frame) for _ in range(n)]
    return sum(r[0] for r in results) / n, [r[1] for r in results]


def goals_for(m, brief, frame, lint_lines):
    prompt = ("You review one pixel art game sprite (shown large, on a green background). The brief:\n"
              + brief + "\n\nAutomatic checks:\n" + "\n".join(lint_lines) +
              "\n\nDescribe what a player sees. Then list what works and must be kept, and the 3 most "
              "important problems as goals: the result a player should see, not pixel positions.\n"
              "Format:\nSEES: <one sentence>\nKEEP: <...>\nGOALS:\n1. ...\n2. ...\n3. ...")
    return m.chat("goals", [{"type": "text", "text": prompt}, image_part(big(frame))], temperature=0.3)


# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("target")
    ap.add_argument("--rounds", type=int, default=3)
    ap.add_argument("--cands", type=int, default=3)
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--think", action="store_true", help="let the model reason before it answers")
    ap.add_argument("--start", help="start from this sprite.lua instead of from scratch")
    ap.add_argument("--judge", choices=["score", "pair"], default="score")
    args = ap.parse_args()

    tdir = ASSETS / args.target
    brief = (tdir / "brief.md").read_text()
    out = tdir / "local"
    out.mkdir(parents=True, exist_ok=True)
    logf = (out / "log.jsonl").open("a")
    totals = {"calls": 0, "prompt_tokens": 0, "completion_tokens": 0, "seconds": 0.0}

    def log(entry):
        entry["model"] = args.model
        logf.write(json.dumps(entry) + "\n"); logf.flush()
        totals["calls"] += 1
        for k in ("prompt_tokens", "completion_tokens", "seconds"):
            totals[k] += entry[k]

    m = Model(args.model, args.think, log)
    champ_code = Path(args.start).read_text() if args.start else None
    champ_frame = champ_data = None
    if champ_code:
        p = out / "start.lua"; p.write_text(champ_code)
        champ_data, champ_frame, err = try_render(p)
        assert not err, err
    checks = make_checks(m, brief, tdir / "checks.md") if args.judge == "score" else None
    if checks:
        print("checks:\n  " + "\n  ".join(checks), flush=True)
    champ_score = None
    goals = goals_for(m, brief, champ_frame, lint(champ_data)) if champ_frame else ""

    for rnd in range(1, args.rounds + 1):
        print(f"\n=== round {rnd} ===", flush=True)
        changed = False
        for k in range(args.cands):
            strat = STRATEGIES[k % len(STRATEGIES)]
            path = out / f"r{rnd:02d}_c{k + 1}.lua"
            data, frame = draw(m, brief, champ_code, goals, strat, path)
            if frame is None:
                print(f"  c{k + 1}: failed to render after retries", flush=True)
                continue
            frame.save(path.with_suffix(".png"))
            if args.judge == "score":
                if champ_frame is not None and champ_score is None:
                    champ_score, _ = score(m, checks, champ_frame)
                s, texts = score(m, checks, frame)
                (out / f"r{rnd:02d}_c{k + 1}_judge.txt").write_text("\n\n---\n\n".join(texts))
                won = champ_frame is None or s > champ_score
                print(f"  c{k + 1}: score {s:.1f}/{len(checks)} vs best "
                      f"{'-' if champ_score is None else f'{champ_score:.1f}'} -> "
                      f"{'NEW BEST' if won else 'kept current'}", flush=True)
                if won:
                    champ_score = s
            else:
                if champ_frame is None:
                    champ_code, champ_frame, champ_data = path.read_text(), frame, data
                    print(f"  c{k + 1}: first valid sprite, becomes current best", flush=True)
                    changed = True
                    continue
                won, votes, texts = challenge(m, brief, champ_frame, frame)
                (out / f"r{rnd:02d}_c{k + 1}_judge.txt").write_text("\n\n---\n\n".join(texts))
                print(f"  c{k + 1}: votes {votes} -> {'NEW BEST' if won else 'kept current'}", flush=True)
            if won:
                champ_code, champ_frame, champ_data = path.read_text(), frame, data
                changed = True
        if champ_frame is None:
            print("no valid sprite yet", flush=True)
            continue
        (tdir / "sprite.lua").write_text(champ_code)
        if changed:
            subprocess.run([sys.executable, str(ROOT / "pixelaite.py"), "render", args.target, "--force"],
                           check=True, stdout=subprocess.DEVNULL)
        goals = goals_for(m, brief, champ_frame, lint(champ_data))
        (out / f"r{rnd:02d}_goals.txt").write_text(goals)
        print("  goals:", goals.replace("\n", " | ")[:400], flush=True)

    print(f"\ncalls {totals['calls']}, prompt tokens {totals['prompt_tokens']:,}, "
          f"completion tokens {totals['completion_tokens']:,}, model time {totals['seconds']:.0f} s")


if __name__ == "__main__":
    main()
