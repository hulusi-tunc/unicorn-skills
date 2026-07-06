---
description: Design one screen end to end — layout, type, color, responsive, dark mode, interaction states, inclusive pass, no-slop gate.
argument-hint: "[screen description, e.g., 'user profile settings page']"
---
# /design-screen
Design a complete screen end to end.
## Steps
1. **Grid** — Define the layout grid using `ui-design` skill.
2. **Hierarchy** — Establish visual priority using `ui-design` skill.
3. **Type, color, spacing** — Apply type scale, color system, and spacing scale using `ui-design` skill.
4. **Responsive + dark mode** — Define breakpoint behavior and dark mode adaptation using `ui-design` skill.
5. **Interaction states** — Spec hover/focus/active/loading/error/empty states using `interaction-design` skill.
6. **Inclusive pass** — Check keyboard, touch targets, contrast, motion, and content using `inclusive-design` skill.
7. **Slop gate** — Run `no-slop` skill over the spec; fix anything generic before shipping.
## Output
Write to `project/screens/<screen-name>.md` (or a folder if it includes code): grid, hierarchy, typography, color, spacing, responsive, dark mode, interaction states, inclusive notes, and no-slop result. Use `project/design-system/` tokens only. Update `project/STATE.md`.
