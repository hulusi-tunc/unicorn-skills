---
description: Run the no-slop review gate over the current design, code, or copy — with WIG and Emil passes where relevant.
argument-hint: "[target: files, screen, or copy to check — defaults to current working set]"
---
# /slop-check
Review the target (default: the design/code/copy currently in play) for AI slop.
## Steps
1. **Slop gate** — Run `no-slop` skill over the target: generic layouts, filler copy, default-y styling, hedge words.
2. **Code pass** — If code (TSX/JSX/HTML/CSS) is in scope, audit it using `vercel-web-design-guidelines` skill.
3. **Motion pass** — If animation or motion is in scope, review it using `emil-design-eng` skill (Before | After | Why table).
4. **Verdict** — Consolidate all findings into a single pass/fail table.
## Output
Pass/fail table: one row per finding — check, verdict, `file:line` or screen reference, fix. End with overall PASS or FAIL.
