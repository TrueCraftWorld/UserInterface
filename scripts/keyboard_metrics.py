#!/usr/bin/env python3
import argparse
import re
from collections import defaultdict


EVENT_RE = re.compile(r"\[KBD-KEY\]\s+(pressed|released|canceled)\b.*label=\s+(.+?)\s+btnKey=\s+(-?\d+)")


def normalize_label(raw: str) -> str:
    return raw.strip()


def parse_metrics(lines):
    totals = {"pressed": 0, "released": 0, "canceled": 0}
    per_label = defaultdict(lambda: {"pressed": 0, "released": 0, "canceled": 0})

    for line in lines:
        m = EVENT_RE.search(line)
        if not m:
            continue
        event, label, _ = m.groups()
        label = normalize_label(label)
        totals[event] += 1
        per_label[label][event] += 1

    return totals, per_label


def print_report(totals, per_label):
    pressed = totals["pressed"]
    released = totals["released"]
    canceled = totals["canceled"]
    lost_release = max(0, pressed - released)
    cancel_rate = (canceled / pressed * 100.0) if pressed else 0.0
    lost_rate = (lost_release / pressed * 100.0) if pressed else 0.0

    print("=== Keyboard Reliability Metrics ===")
    print(f"pressed: {pressed}")
    print(f"released: {released}")
    print(f"canceled: {canceled}")
    print(f"lost_release: {lost_release}")
    print(f"cancel_rate_percent: {cancel_rate:.2f}")
    print(f"lost_release_rate_percent: {lost_rate:.2f}")
    print("")
    print("Per-label (top by lost release):")

    rows = []
    for label, stats in per_label.items():
        p = stats["pressed"]
        r = stats["released"]
        c = stats["canceled"]
        lost = max(0, p - r)
        if p == 0:
            continue
        rows.append((lost, c, p, r, label))

    rows.sort(reverse=True)
    for lost, c, p, r, label in rows[:30]:
        print(f"{label:>10}  pressed={p:4d}  released={r:4d}  canceled={c:4d}  lost={lost:4d}")


def main():
    parser = argparse.ArgumentParser(description="Compute keyboard canceled/released metrics from app logs.")
    parser.add_argument("log_file", help="Path to log file containing [KBD-KEY] lines")
    args = parser.parse_args()

    with open(args.log_file, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    totals, per_label = parse_metrics(lines)
    print_report(totals, per_label)


if __name__ == "__main__":
    main()
