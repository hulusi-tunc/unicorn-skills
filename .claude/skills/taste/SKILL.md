---
name: taste
description: The team's taste memory. Use whenever choosing or proposing a visual direction, hunting for inspiration or references, building a moodboard, or answering "what do we like" / "what's our style". Reads the synthesized profile in taste/TASTE.md and retrieves relevant saved inspiration from taste/library/ by tag. Pairs with no-slop — no-slop removes the generic, taste pulls toward what this team actually responds to.
---

# Taste

The team saves inspiration (via `/taste-add` locally, or the design Slack channel once the bot is live). Each save becomes an entry in `taste/library/` with the saver's own words, an attribute analysis, and a "steal this" line. `/taste-sync` distills the library into `taste/TASTE.md` — the profile this skill reads.

## Before proposing any visual direction

1. Read `taste/TASTE.md`. If it has real content, the direction you propose must either fit a strong preference or explicitly say why this project departs from it. Never contradict an anti-taste item without flagging it.
2. If TASTE.md is empty or missing, say so and proceed with the `no-slop` direction list — then suggest the team start saving inspiration.

## When asked for inspiration or references on a topic

1. Grep `taste/library/*.md` frontmatter for matching `tags`, `type`, and body text (e.g. `grep -l "dashboard" taste/library/`).
2. Surface the 3–5 highest-`score`, `status: active` matches. For each: the image path, the saver's own words, and the "Steal this" line — verbatim, not paraphrased.
3. If nothing matches, say so; do not invent library entries. Offer adjacent tags that do exist.

## Precedence rules

- **Client brand wins.** Taste never overrides a client's brand guidelines or an existing design system. Taste breaks ties when the brief leaves a choice open.
- **Anti-taste is a warning, not a law.** If the best design answer conflicts with an anti-taste item, present it with the conflict named.
- Entries with `status: anti` are examples of what the team dislikes — cite them only as counter-references.

## What this skill never does

- Never edits `taste/TASTE.md` (only `/taste-sync` regenerates it) and never edits library entries except through `/taste-add`.
- Never treats one entry as a trend — the profile (TASTE.md) carries the weight, single entries carry the specifics.
