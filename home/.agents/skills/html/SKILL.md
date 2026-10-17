---
name: html
description: Create self-contained HTML reports, visual explainers, diagrams, charts, plans, and presentations. Use when a visual artifact will help someone understand information; do not use for product UI design, mockups, prototypes, or ordinary application work.
---

# Visual HTML artifacts

Create one self-contained HTML file that makes a system, process, dataset, plan, or idea easier to understand. Use real source material and a visual direction suited to the subject, not a reusable house style.

## Choose the form

Start with the question the reader needs answered. Choose the simplest useful form:

- **Visual explainer:** make a concept, system, or comparison easier to grasp. Read [`references/visual-explanations.md`](references/visual-explanations.md).
- **Diagram:** show relationships, sequence, topology, state, hierarchy, or process. Read [`references/diagrams.md`](references/diagrams.md).
- **Chart or data story:** explain quantitative comparisons. Read [`references/charts-and-data.md`](references/charts-and-data.md).
- **Plan:** present a roadmap or sequence while preserving source commitments. Read [`references/plans.md`](references/plans.md).
- **Report or presentation:** organize findings or ideas for a reader or audience. Read [`references/documents-and-presentations.md`](references/documents-and-presentations.md).

Combine forms when useful, and load only the references that apply. Don't turn a visual explanation into a product UI mockup or prototype.

## Set the direction

Inspect the brief and, when working in a repository, its instructions, design tokens, components, and nearby artifacts. Follow this authority order:

1. The user's explicit instructions and accepted decisions.
2. The project's existing design system and terminology.
3. The subject, audience, and purpose.
4. Your design judgment.

Settle the audience, the question to answer, the artifact form, and visual register before coding. Use [`references/creative-direction.md`](references/creative-direction.md) when visual direction is open. A quiet, workmanlike treatment is right for many internal artifacts; use editorial or expressive treatment only when the subject benefits from it.

## Build contract

- Deliver a single `.html` file with essential CSS and JavaScript inline. It should open directly, without a build step or network access unless the user asks for external resources.
- Prefer native HTML, CSS, and browser behavior. Add interaction only when it helps explain the material, such as revealing detail or stepping through a sequence.
- Use semantic structure, meaningful labels, responsive layout, sufficient contrast, visible focus, keyboard-operable controls, and reduced-motion support.
- Use real copy and data from the brief. Mark illustrative values or assumptions; never invent evidence, commitments, or functional outcomes.
- Make every visible control work. Remove controls that do not help explain the content.
- Keep the page free of accidental horizontal overflow. Contain intentionally wide tables, charts, or diagrams in their own scroll region.
- If a single file cannot reasonably contain the requested result, explain the constraint and ask before changing the deliverable shape.

## Verify and hand off

Write the artifact to the requested path or a clear filename. When browser tooling is available, inspect wide and narrow viewports, exercise controls and keyboard paths, and check the console, focus, readability, overflow, and state changes. Fix issues found. If browser inspection is unavailable, say what remains unchecked.

Return the absolute path and a concise description of what the artifact explains. For plans, diagrams, and data views, mention material assumptions or simplifications.

## Share through artefakt

When the user asks to publish or share an artifact on SumUp's internal artefakt host, follow [`../aftefakt/SKILL.md`](../aftefakt/SKILL.md) for upload and link verification. The HTML should already be self-contained. Do not upload merely because an artifact was created.
