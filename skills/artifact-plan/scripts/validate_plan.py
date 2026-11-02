#!/usr/bin/env python3
"""Check a plan's task graph before it reaches the board.

Usage: python3 validate_plan.py tasks.json   (or pipe JSON on stdin)
Input: a JSON list of tasks, each {"id", "title", "doneWhen", "blockedBy", "status"?}.
Exit 0 and print "ok", or exit 1 and print one problem per line.
Run with --selftest to check the checker.
"""
import json
import sys

STATUSES = {"todo", "in_progress", "review", "done", "failed"}


def problems(tasks):
    out, ids = [], [t.get("id") for t in tasks]
    seen = set()
    for i in ids:
        if not i:
            out.append("a task has no id")
        elif i in seen:
            out.append(f"duplicate id {i}")
        seen.add(i)
    for t in tasks:
        tid = t.get("id", "?")
        for f in ("title", "doneWhen"):
            if not str(t.get(f, "")).strip():
                out.append(f"{tid}: missing {f}")
        if t.get("status", "todo") not in STATUSES:
            out.append(f"{tid}: unknown status {t.get('status')!r}")
        for b in t.get("blockedBy", []):
            if b == tid:
                out.append(f"{tid}: blocked by itself")
            elif b not in seen:
                out.append(f"{tid}: blocked by unknown id {b}")
    # Cycle check: depth-first search, colour 1 = on the stack.
    graph = {}
    for t in tasks:
        graph.setdefault(t.get("id"), []).extend(b for b in t.get("blockedBy", []) if b in seen and b != t.get("id"))
    colour = {}

    def visit(n, path):
        colour[n] = 1
        for b in graph.get(n, []):
            if colour.get(b) == 1:
                out.append("cycle: " + " -> ".join(path[path.index(b):] + [b]))
            elif b not in colour:
                visit(b, path + [b])
        colour[n] = 2

    for n in graph:
        if n not in colour:
            visit(n, [n])
    return out


def selftest():
    good = [{"id": "T1", "title": "a", "doneWhen": "x", "blockedBy": []},
            {"id": "T2", "title": "b", "doneWhen": "y", "blockedBy": ["T1"]}]
    assert problems(good) == []
    bad = [{"id": "T1", "title": "a", "doneWhen": "x", "blockedBy": ["T2"]},
           {"id": "T2", "title": "b", "doneWhen": "", "blockedBy": ["T1", "T9"]},
           {"id": "T2", "title": "c", "doneWhen": "z", "status": "ready"}]
    p = problems(bad)
    assert "duplicate id T2" in p
    assert "T2: missing doneWhen" in p
    assert "T2: blocked by unknown id T9" in p
    assert "T2: unknown status 'ready'" in p
    assert any(x.startswith("cycle:") for x in p)
    print("selftest ok")


if __name__ == "__main__":
    if sys.argv[1:] == ["--selftest"]:
        selftest()
        sys.exit(0)
    src = open(sys.argv[1]) if sys.argv[1:] else sys.stdin
    found = problems(json.load(src))
    print("\n".join(found) if found else "ok")
    sys.exit(1 if found else 0)
