# HTML authoring guide

How to author the HTML documents this skill produces: lessons, quizzes, reference sheets, and presentation decks. All documents are **self-contained**: one `.html` file, CSS and JS inline, no network access, system fonts, opens directly from `file://`.

## Universal build rules

- Semantic structure (`h1`–`h3`, `nav`, `main`, `figure`), meaningful labels, sufficient contrast, visible focus, keyboard-operable controls, `prefers-reduced-motion` respected.
- No accidental horizontal overflow; contain intentionally wide tables or diagrams in their own scroll region.
- Every visible control works. No placeholder buttons.
- Citations as real `<a href>` links next to the claim they support. Mark illustrative examples as such; never invent evidence.
- Reuse before authoring: read `./assets/` first and build from the components there. Anything a second document could reuse (stylesheet, slide-deck engine, quiz widget) is written once as a component in `./assets/`, never inlined.
- The shared stylesheet is the first asset of every workspace: every document links it so the whole course looks like one course.

## Document types — one per teaching purpose

| Type | Purpose | Form |
|---|---|---|
| **Lesson** (`lessons/`) | Teach one tightly-scoped thing, one sitting, one tangible win | Slide deck, linear, prev/next |
| **Quiz / drill** (`lessons/`) | Retrieval practice with immediate feedback | Interactive single page |
| **Reference sheet** (`reference/`) | Compressed essence of a lesson: syntax, algorithms, tables | Printable single page |
| **Deck summary** (`reference/`) | Review a group of lessons, presentation-style | Slide deck, same engine as lessons |

Pick the form from the purpose, not from habit. Don't turn a reference sheet into a deck — the user returns to references to *scan*, so they print well and show everything at once.

## Slide-deck engine (lessons and deck summaries)

The first deck earns a shared engine component in `./assets/`; later decks link it. Required behavior:

- Each `<section class="slide">` is one screen with **one job and one dominant idea**. Essential information visible without hover.
- Navigation three ways, all always functional: **Prev/Next buttons** (fixed, obvious, large hit areas), **arrow keys / space**, and **direct slide links** (numbered footer dots or a slide index).
- Progress indicator (e.g. "4 / 12") plus a numbered footer of clickable dots.
- Transitions (simple fade/slide) only to explain order; respect reduced motion.
- Keyboard focus moves sensibly; slides reachable out of order via links; all content still in the DOM (works without JS for reading, degrades gracefully).
- A useful scrolling fallback when a slide's content is taller than the viewport.
- Consistent rhythm across slides of the deck; break it only for emphasis.

## Quiz widget

- Immediate feedback on answer selection: correct/incorrect shown right away, with the reasoning.
- **Answer-position discipline**: options of equal length/word count, correct-answer position varied, no formatting clues. Ship a shuffle step at render time in the component so authoring order never leaks the answer.
- Score summary at the end, and a "what to review" pointer linking back to the lesson slides and reference docs.

## Lesson shape

A typical lesson deck: title slide (topic, lesson number, mission tie-in) → "try it first" prompt (a question they attempt before you reveal) → concept slides (claim + citation + example) → worked example → quiz slide(s) → one recommended primary source → next-lesson pointer + reminder to ask followup questions.

## Typography and register

Quiet, editorial treatment — readable measures, deliberate pacing, restrained color with one accent. Content is the decoration. Print styles for every `reference/` document (essential content visible without interaction).
