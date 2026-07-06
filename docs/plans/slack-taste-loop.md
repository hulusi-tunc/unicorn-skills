# Plan: Slack taste loop

**Status:** ready to build · **Builder:** Claude Code (Opus session), working through the tasks below in order · **Owner:** Hulusi

## What this is

A taste-capture system for the design team. When anyone posts an image (with a comment) to the `#design-inspiration` Slack channel, the system saves it, analyzes *why* it was saved, and files it into a versioned taste library in this repo. A weekly synthesis distills the library into `taste/TASTE.md` — a living profile of what the team likes and dislikes. Claude Code reads that profile when designing: the `no-slop` skill already points to `taste/TASTE.md` when choosing a project's visual direction.

The loop: **save in Slack → analyzed + filed → synthesized into a profile → shapes the next design → react in Slack → profile sharpens.** That is "taste that always improves": every save and every emoji reaction is training signal.

## Architecture

```
Slack #design-inspiration
  │  message + image (+ 👍/👎 reactions later)
  ▼
Vercel function  /api/slack/events        (Slack Events API, signature-verified)
  │  downloads image, calls Claude (vision) for a structured taste entry
  ▼
GitHub Contents API → this repo
  taste/library/<id>.md   +   taste/images/<id>.png     (one commit per save)
  │
  ▼  weekly (Vercel cron  /api/cron/synthesize)
Claude synthesis → taste/TASTE.md regenerated → summary posted back to Slack
  │
  ▼
Claude Code (this repo): `taste` skill reads TASTE.md + greps library when designing
```

Why this shape: no database (git is the database — versioned, reviewable, and readable by Claude Code in every session), no server to babysit (two Vercel functions), and the team's existing tools (Slack, GitHub, Vercel) with one new Slack app.

## Data model

```
taste/
  TASTE.md              # synthesized profile — the only file Claude Code reads by default
  library/              # one entry per saved item
    2026-07-06-a1b2c3.md
  images/
    2026-07-06-a1b2c3.png
  inbox/                # manual drop folder for /taste-add (v0, no Slack needed)
```

**Entry format** (`taste/library/<date>-<slack-ts-hash>.md`):

```markdown
---
id: 2026-07-06-a1b2c3
date: 2026-07-06
source: slack            # slack | manual
author: hulusi
type: screen             # screen | component | typography | palette | motion | illustration | layout
tags: [dashboard, dark, data-dense, mono]
score: 1                 # 1 + (👍 count) − (👎 count), updated by reaction events
status: active           # active | anti | archived   (anti = "we dislike this")
image: ../images/2026-07-06-a1b2c3.png
---

## Their words
"love how calm this table is, no borders at all"   ← the Slack message, verbatim

## Analysis
- Layout: single-column data table, no vertical rules, 48px row height
- Type: mono numerals, 13px labels in caps with tracking
- Color: near-black surface, one desaturated accent, no gradients
- Mood: calm, technical, confident
## Steal this
Alignment and whitespace doing the separation work borders usually do.
```

**TASTE.md format** — regenerated weekly, never hand-edited:

```markdown
# Team taste profile
Updated: <date> · <n> entries · <n> anti-patterns

## Strong preferences (seen 5+ times, recent)
- Data-dense, calm tables — separation by whitespace, not borders [12 entries]
- Mono or grotesque numerals in data UI [9]
## Emerging (2–4 signals — watch)
...
## Anti-taste (from 👎 and #anti saves)
- Glassmorphism panels [4]
## Directions this maps to
Industrial technical > brutalist utilitarian (per no-slop direction list)
## Aging out (no reinforcement in 90 days — confirm or drop)
...
```

## Build tasks (in order — each is one commit/PR)

### Task 1 — v0: taste library + Claude Code integration (no Slack, works today)
1. Create `taste/` scaffold: `TASTE.md` seeded with the headers above and zero entries, empty `library/`, `images/`, `inbox/` (with a one-line README each).
2. New skill `.claude/skills/taste/SKILL.md` — description triggers on: inspiration, moodboard, reference, "what do we like", visual direction, taste. Behavior: (a) read `taste/TASTE.md` before proposing any visual direction; (b) when asked for inspiration on X, grep `taste/library/` frontmatter tags and surface the 3–5 most relevant entries with their "Steal this" lines; (c) never treat taste as override of client brand — client wins, taste breaks ties.
3. New command `.claude/commands/taste-add.md` (same format as the other 5 commands): for each image in `taste/inbox/` (or a pasted image), Read it, ask the user one question — "what made you save this?" — then write the entry per the data model above, move the image to `images/`, delete from inbox, and append nothing to TASTE.md (synthesis owns that).
4. New command `.claude/commands/taste-sync.md`: regenerate `TASTE.md` from all `library/` entries using the synthesis rules in Task 4 (same logic, run locally). This is the manual fallback for the weekly cron.
5. Wire-up: add the `taste` skill to `unicorn`, `ui-designer`, and `designer-copilot` agents' `skills:` lists; add one routing line to CLAUDE.md ("Choosing a visual direction → `taste` + `no-slop`"); update the skill/command counts in CLAUDE.md and README (27→28 skills, 5→7 commands).

**Acceptance:** drop 2 screenshots in `taste/inbox/`, run `/taste-add`, get 2 valid entries; run `/taste-sync`, `TASTE.md` reflects them; ask Claude "design a settings screen" and it cites the profile.

### Task 2 — Slack app + events endpoint
1. New top-level `taste-bot/` directory: a minimal Vercel project (TypeScript, no framework — plain `api/` functions). Keep it deployable separately from the template (own `package.json`; add `taste-bot` to the template's `.gitignore`d build outputs only, never the source).
2. Slack app (manifest checked in as `taste-bot/slack-manifest.json`): bot scopes `channels:history`, `files:read`, `reactions:read`, `chat:write`; event subscriptions `message.channels`, `reaction_added`; request URL `https://<deploy>/api/slack/events`.
3. `api/slack/events.ts`:
   - Verify `X-Slack-Signature` (HMAC-SHA256 with `SLACK_SIGNING_SECRET`, reject >5 min old timestamps). Answer `url_verification` challenge.
   - Ignore: bot messages, messages outside `TASTE_CHANNEL_ID`, messages without image files (jpg/png/webp/gif, ≤10 MB).
   - ACK Slack within 3s (respond 200 immediately, then continue processing — use `waitUntil` on Vercel).
   - Download the file from `url_private_download` with `Authorization: Bearer <SLACK_BOT_TOKEN>` (Slack file URLs are private; this header is required).
4. Env vars (Vercel): `SLACK_BOT_TOKEN`, `SLACK_SIGNING_SECRET`, `TASTE_CHANNEL_ID`, `ANTHROPIC_API_KEY`, `GITHUB_TOKEN` (fine-grained PAT, contents read/write on this repo only), `GITHUB_REPO=hulusi-tunc/unicorn-skills`.

**Acceptance:** posting an image in the channel logs a verified, parsed event with the image bytes in hand; posting in any other channel is ignored.

### Task 3 — analyze + commit
1. `lib/analyze.ts`: call the Claude API, model `claude-haiku-4-5-20251001` (vision-capable, cheap — this runs per image), with the image + the user's message text. Tool-forced JSON output matching the entry frontmatter + body sections (type, tags 3–6, analysis bullets ≤5, steal-this ≤1 sentence). The user's message goes in verbatim as "Their words" — never paraphrased; it is the highest-value signal.
2. `lib/github.ts`: two Contents-API PUTs (image as base64, entry as markdown) in one push to `main` — commit message `taste: add <id> (via slack)`. Handle 409 retry-once on SHA conflict.
3. React ✅ on the Slack message on success, ❌ + a threaded one-line error on failure.
4. `reaction_added` handler: 👍/➕ increments `score` in the entry frontmatter; 👎 decrements; score ≤ −1 flips `status: anti`. Commit `taste: score <id> <±n>`.

**Acceptance:** post an image with a comment → within ~30s a commit appears with a valid entry + image, and the message gets ✅; a 👎 flips the entry to anti.

### Task 4 — weekly synthesis (the "improves always" part)
1. `api/cron/synthesize.ts` on a Vercel cron (`0 9 * * 1`, Monday morning): pull all `taste/library/*.md`, run the synthesis prompt on `claude-fable-5` (this is judgment work — use the strongest model; fall back to `claude-opus-4-8` if unavailable).
2. Synthesis rules (encode in the prompt): weight = score × recency (half-life 90 days); a preference needs ≥2 independent entries to appear at all, ≥5 to be "strong"; anti-taste from `status: anti` entries; map the profile onto the `no-slop` direction vocabulary; list preferences with no reinforcement in 90 days under "Aging out". Regenerate `TASTE.md` in full — never append.
3. Commit `taste: weekly synthesis`, then `chat.postMessage` a 5-line digest to the channel: new entries this week, what strengthened, what's aging out — with a prompt: "React 👍 to keep, 👎 to drop the aging items."
4. Reactions to the digest thread feed back via the Task-3 handler → next week's synthesis. This closes the loop.

**Acceptance:** cron run produces a coherent TASTE.md from ≥10 entries and posts the digest; an aging item that gets 👎 disappears from the next synthesis.

### Task 5 — polish (only after 1–4 work)
- Multi-image messages → one entry per image sharing "Their words".
- URL-only messages (Dribbble/site links): screenshot via the existing chrome-devtools MCP path or skip with a 🤷 reaction — decide then, don't build speculatively.
- Monthly "taste review" thread: synthesizer posts 3 borderline calls and asks the team to vote.

## Constraints for the builder

- Follow this repo's `no-slop` code rules (no utils dumping grounds, no dead abstractions, no bare TODOs) — the bot is ~5 small files, keep it that way.
- Secrets only in Vercel env; nothing in the repo. The Slack manifest ships without tokens.
- Every write to the repo goes through named commits (`taste: ...`) so the library's history is auditable.
- Don't touch `taste/TASTE.md` by hand anywhere in the code except the synthesizer.

## Kickoff for the Opus build session

```
Read docs/plans/slack-taste-loop.md and build Task 1 on a branch
feat/taste-loop. Stop after Task 1 acceptance passes and show me the
diff before continuing to Task 2.
```
