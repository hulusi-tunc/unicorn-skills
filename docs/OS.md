# Studio OS — how we work with Claude Code

The operating manual for the team. One page; if a routine isn't here, it isn't a routine.

## The folder structure

```
.claude/            The studio brain — agents, skills, commands. Edit via PR to the template.
CLAUDE.md           System config Claude loads every session. Keep it lean.
docs/
  OS.md             This manual.
  plans/            Build plans for the system itself.
project/            THE WORKSPACE — everything about the current client project.
  STATE.md          Shared memory between sessions and teammates. Unicorn owns it.
  brief/            PRD, WBS, references. You put things here; everything else is output.
  research/         /discover outputs — findings, personas, journey maps.
  design-system/    /tokenize outputs — tokens + docs. Source of truth for every screen.
  screens/          /design-screen outputs — one spec or code folder per screen.
  reviews/          /slop-check and critique reports, dated.
  handoff/          /handoff packages — what developers receive.
taste/              Shared taste memory. Fed from Slack #design-inspiration. Never hand-edit TASTE.md.
```

Two kinds of repo:
- **The template** (`unicorn-skills`) — the OS itself. Improvements to skills/agents/commands happen here, on a branch, via PR.
- **A project clone** — `git clone` the template per client project. Work on `main`; the `project/` folder is yours. Pull template updates with `git fetch template && git merge template/main`.

## Session routine (every designer, every session)

1. **Open Claude Code and say hi to Unicorn** (or just state your task). Unicorn reads `project/STATE.md` and tells you where the project stands and what's next.
2. Pick **instructor** (explains everything) or **operator** (just runs) when asked. Newcomers: instructor.
3. Work. Artifacts land in the `project/` folders automatically — commands know their output paths.
4. **Before you stop:** tell Claude "update STATE.md" if it hasn't already, and commit: `git add -A && git commit -m "what changed"`. STATE.md + git is how the next person (or tomorrow's you) resumes without re-explaining anything.

## Daily

- **First person in runs `/taste-pull`** — files whatever the team posted to `#design-inspiration` since the last pull.
- See something good anywhere? **Post it to `#design-inspiration` with one line on WHY you like it.** Your words are the signal; "nice" teaches nothing. React 👍/👎 on others' posts — reactions re-weight the taste profile.

## Weekly

- **Monday: `/taste-sync`** — regenerates the team taste profile and posts the digest to the channel. React on "aging out" items to keep or kill them.
- **Critique:** run `/slop-check` on the week's screens before showing the lead. The report lands in `project/reviews/`.

## Per stage (Unicorn drives this — you don't memorize it)

| Stage | You say | What runs | Lands in |
|---|---|---|---|
| Intake | "here's the PRD" | ux-strategy + `/discover` if research needed | `brief/`, `research/` |
| Design system | "let's build the system" | `/tokenize` (checks taste profile first) | `design-system/` |
| UI v1 | "design the dashboard screen" | `/design-screen` | `screens/` |
| Refine | "review this" | `/slop-check` + heuristics + a11y | `reviews/` |
| Ship | "prepare handoff" | `/handoff` | `handoff/` |

## Hard rules

- **No slop ships.** `/slop-check` failing blocks handoff, same as a broken state. Generic AI-default output is a defect.
- **Client brand beats taste; taste beats defaults.** The taste profile breaks ties — it never overrides a client's brand.
- **Tokens over raw values**, WCAG AA minimum, keyboard + reduced-motion from the start. Non-negotiable.
- **STATE.md is append-only for decisions.** Never rewrite history; the next designer needs it.

## Working with models and limits

- Day-to-day design work: the default model is fine. Save Opus/Fable for hard thinking — direction calls, complex reviews, system design.
- If you hit a session limit mid-task, don't panic: work is committed as you go, STATE.md holds the thread. Start a fresh session, say hi to Unicorn, continue.

## Improving the OS itself

Found a routine that works? A skill that's missing or slop that got through? That's a template change: branch in `unicorn-skills`, make it, PR it. The system is supposed to get better every project — same loop as taste, applied to the OS.
