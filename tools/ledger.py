#!/usr/bin/env python3
"""Summarize agent cost per run from assets/_runs/ledger.csv.

Usage:
  ledger.py                      Table per run and role.
  ledger.py add <run> <round> <role> <model> <tokens> <duration_ms>

Normalization: HET = Haiku-equivalent tokens = tokens x model weight.
Weights come from list prices. Every model here prices output at 5x input,
so the weight is exact for any input/output mix.
Dollar estimate: assumes 90% input / 10% output tokens and no cache discount.
Treat it as an upper estimate: cache reads make real input cheaper.
The token counts are the subagent totals that the harness reports.
"""
import csv
import sys
from collections import defaultdict
from pathlib import Path

LEDGER = Path(__file__).resolve().parent.parent / "assets" / "_runs" / "ledger.csv"
PRICE = {"haiku": (0.10, 0.50), "sonnet": (2.00, 10.00), "opus": (4.00, 20.00), "fable": (8.00, 40.00), "local": (0.0, 0.0)}  # $ per 1M in/out
WEIGHT = {m: p[0] / PRICE["haiku"][0] for m, p in PRICE.items()}
BLEND = {m: 0.9 * p[0] + 0.1 * p[1] for m, p in PRICE.items()}  # $ per 1M, assumed mix


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "add":
        with LEDGER.open("a", newline="") as f:
            csv.writer(f).writerow(sys.argv[2:8])
        return
    rows = list(csv.DictReader(LEDGER.open()))
    runs = defaultdict(lambda: defaultdict(lambda: [0, 0.0, 0, 0]))  # tokens, het, calls, ms
    for r in rows:
        kind = r["role"].split(":")[0]
        for key in (kind, "TOTAL"):
            a = runs[r["run"]][(key, r["model"]) if key != "TOTAL" else ("TOTAL", "")]
            t = int(r["tokens"])
            a[0] += t; a[1] += t * WEIGHT[r["model"]]; a[2] += 1; a[3] += int(r["duration_ms"])
    print(f"{'run':<14}{'part':<16}{'calls':>6}{'tokens':>10}{'HET':>12}{'est $':>9}")
    for run, parts in runs.items():
        for (kind, model), (t, het, n, ms) in sorted(parts.items(), key=lambda kv: kv[0][0] == "TOTAL"):
            usd = het * BLEND["haiku"] / 1e6
            label = f"{kind} ({model})" if model else kind
            print(f"{run:<14}{label:<16}{n:>6}{t:>10,}{het:>12,.0f}{usd:>9.2f}")
        print()


if __name__ == "__main__":
    main()
