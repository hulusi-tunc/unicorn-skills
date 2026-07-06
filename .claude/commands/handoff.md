---
description: Prepare a developer handoff — spec, accessibility handoff, QA checklist, and Figma Code Connect pointers.
argument-hint: [feature, screen, or component to hand off]
---
# /handoff
Prepare a developer handoff package.
## Steps
1. **Spec** — Write the handoff spec (measurements, tokens, states, assets) using `design-ops` skill.
2. **Accessibility handoff** — Document ARIA, keyboard behavior, and compliance decisions using `accessibility-process` skill.
3. **QA checklist** — Build the design QA checklist for implementation review using `design-ops` skill.
4. **Figma** — If Figma is in play, map components to code using `figma-code-connect` skill (load `figma-use` first before any `use_figma` call).
## Output
Write to `project/handoff/<feature-name>/`: spec doc, accessibility requirements, QA checklist, and Code Connect mappings (if applicable). Blocked if the latest `/slop-check` in `project/reviews/` failed. Update `project/STATE.md`.
