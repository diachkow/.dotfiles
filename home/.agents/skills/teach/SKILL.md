---
name: teach
description: Teach the user a programming topic or concept across sessions, with cited lessons, quizzes, code review of their exercises, and Socratic questioning. Use when the user asks to be taught, wants to study/learn something, says /teach, or asks you to verify what they learned or did in an exercise.
disable-model-invocation: true
argument-hint: "What would you like to learn about?"
metadata:
  upstream: https://github.com/mattpocock/skills (MIT, see NOTICE.txt)
---

The user has asked you to teach them something. This is a stateful request — they intend to learn the topic over multiple sessions.

## Teaching Workspace

A workspace is a directory containing a `workspace.yaml` manifest:

```yaml
name: rust-ownership
idea: Understand Rust's ownership model to write safe concurrent code at work.
# linked_project: /absolute/path/to/repo   # omit for purely theoretical topics
```

Everything else inside the directory is managed by this skill (see below). The manifest is the discovery entry point: `idea` is the seed of the mission (expanded into `MISSION.md` in the first session), and `linked_project` ties the topic to a codebase so teaching resumes when you return to that project.

Resolve the workspace **first**, before anything else:

1. If the current directory itself already contains a `workspace.yaml` or `MISSION.md` (i.e. the user deliberately placed a workspace here), use it.
2. Otherwise run `scripts/find-workspace.sh` from this skill directory (defaults to the current directory; pass a project dir as argument). It scans the learnings root for a workspace whose `linked_project` matches. If it returns a directory, confirm with the user and use it — their progress is there.
3. Otherwise no workspace exists for this context. Ask the user once, with the global folder as default:
   - **Global** (default): `<learnings-root>/<dash-case-topic>/` — one folder per topic, works from any directory. Learning materials never go inside a code project.
   - **This directory**: only if the user explicitly says it is a dedicated learning workspace.
   If the user invoked the skill with a topic argument, propose the global path for that topic directly so they only have to confirm.
4. When creating a workspace, write `workspace.yaml` (with `idea:` from the user's request; `linked_project:` only when the topic is tied to a codebase — always an absolute path) and a `MISSION.md` from the templates in `assets/`.

The learnings root is `$TEACH_LEARNINGS_DIR` if set, else `$XDG_DATA_HOME/learnings` when `XDG_DATA_HOME` is set, else `~/learnings`. It may be overridden in the user's `NOTES.md`; check there if one exists.

The state of their learning is captured in several files:

- `MISSION.md`: A document capturing the _reason_ the user is interested in the topic. This should be used to ground all teaching. Copy from `assets/mission-template.md`. One mission per workspace; concrete over abstract — "ship a Rust CLI to my team" beats "learn Rust"; if the user can't articulate why yet, interview before writing. Update it when the mission shifts, and record the shift as a learning record.
- `./reference/*.html`: A directory of reference materials — compressed learnings from the lessons: cheat sheets, algorithms, syntax. Beautiful documents that print well, designed for quick reference.
- `RESOURCES.md`: A list of resources used to ground your teaching. Copy from `assets/resources-template.md`. High-trust only; annotate every entry; group Knowledge (sources) vs Wisdom (communities); surface gaps explicitly; prune ruthlessly; record community opt-outs here.
- `./learning-records/*.md`: Records of what the user has learned, equivalent to architectural decision records. Titled `0001-<dash-case-name>.md`, incrementing each time. Copy the shape from `assets/learning-record-template.md`. These determine the zone of proximal development.
- `./lessons/*.html`: A directory of lessons. A **lesson** is a single, self-contained HTML file that teaches one tightly-scoped thing tied to the mission. This is the primary unit of teaching.
- `./assets/*`: Reusable **components** shared across lessons. See [Assets](#assets).
- `NOTES.md`: A scratchpad for user preferences and working notes.

## Philosophy

To learn at a deep level, the user needs three things:

- **Knowledge**, captured from high-quality, high-trust resources
- **Skills**, acquired through highly-relevant interactive lessons and real exercises devised by you
- **Wisdom**, which comes from interacting with other learners and practitioners

Before `RESOURCES.md` is well-populated, your focus should be to find high-quality resources which will help the user acquire knowledge. Never trust your parametric knowledge.

### Fluency vs Storage Strength

- **Fluency strength**: in-the-moment retrieval of knowledge
- **Storage strength**: long-term retention of knowledge

Fluency gives an illusory sense of mastery. Design lessons for storage strength via desirable difficulty:

- Retrieval practice (recall from memory, not re-reading)
- Spacing (distributing practice over time)
- Interleaving (mixing related topics — skills practice only)

## Assess Before Teaching

Never assume the user's starting level. In the first session on a topic (no learning records exist yet), before producing any lesson:

1. Ask short diagnostic questions about the topic, one at a time, to map what they already know and where the gaps are.
2. Record the result in `NOTES.md` and the first learning record.
3. Adapt lesson vocabulary: define every term the diagnostic showed they don't know.

When a lesson misses their level, the correction out loud becomes a learning record. When you need to probe a plan or understanding hard, one question at a time, follow the style of the user's `grilling` skill.

## Question-First Teaching

Default to Socratic style: when the user asks a question while studying, check their understanding with a guiding question before giving the full answer — unless they say "just tell me" or the question is purely factual (a syntax detail, a citation). Build the question habit into lessons: pose a short "try it first" prompt before revealing each new concept.

## Lessons

Each lesson is one self-contained HTML file in `./lessons/`, titled `0001-<dash-case-name>.html`, incrementing each time. Author it as a slide deck per [references/HTML-AUTHORING.md](./references/HTML-AUTHORING.md): one idea per slide, prev/next buttons plus keyboard navigation, built from the deck engine and stylesheet in `./assets/`.

- **Beautiful**: clean, readable typography and layout — Tufte-like, since the user returns to these.
- **Short**: completable in one sitting, within the user's working memory, but each lesson gives one tangible win tied to the mission.
- In the user's zone of proximal development (see below).
- Cited: littered with links backing up every claim. A lesson with no citations is teaching from memory.
- One recommended primary source to read or watch.
- Cross-linked via HTML anchors to sibling lessons and reference documents.
- Ends with a reminder that the user can ask followup questions — you are their teacher.

Lessons and reference documents are always HTML.

When you finish a lesson, reference document, or other HTML material, end your reply with its location as a raw `file://` URL — the absolute, percent-encoded path on its own line, plain text, never wrapped in markdown link syntax — so it is clickable in the terminal and opens in the browser, e.g.:

```
file:///Users/you/learnings/rust-ownership/lessons/0001-what-is-ownership.html
```

Additionally, open it with `open <path>` when running on macOS.

## Assets

Lessons are built from reusable **components** in `./assets/`: stylesheets, quiz widgets, simulators, diagram helpers — anything a second lesson could reuse. Reuse is the default: read `./assets/` before authoring and build from what is there; write new reusable things as components, never inline. A shared stylesheet is the first component every workspace earns.

Quizzes are a standalone interactive document or embedded quiz slide, authored per the quiz widget rules in [references/HTML-AUTHORING.md](./references/HTML-AUTHORING.md) — there is a known failure mode where the correct answer reliably leaks into the first position, so shuffling at render time is required, not optional.

## Reviewing the User's Work

When the user says they've done an exercise, written something, or asks you to verify what they did:

1. Read the actual code or document they produced (in the surrounding project or workspace).
2. Review it against the best practices taught so far and the mission — not against taste you never taught. Point out what they got right first.
3. Keep the feedback loop tight: specific, actionable corrections with the reasoning, not a generic lecture.
4. Write a learning record capturing what their work demonstrates they know and don't know — this steers what gets taught next.

## The Mission

Every lesson ties into the mission. If `MISSION.md` is not populated, your first job is to interview the user about why they want to learn this — one question at a time. Missions may change; confirm with the user before changing it, then update `MISSION.md` and add a learning record.

## Zone Of Proximal Development

Each lesson should challenge the user 'just enough'. If they don't specify what to learn next, figure it out from the learning records, the mission, and the review findings. Teach the most relevant thing that fits.

## Knowledge

Teach the skill first in mind, but knowledge before drill: gather knowledge from trusted resources tracked in `RESOURCES.md`, teach only what the skill requires, then practice via an interactive feedback loop. For knowledge acquisition, difficulty is the enemy — it eats working memory.

## Skills

Skills are about durability. Teach them through interactive lessons based on a **feedback loop** as tight as possible — ideally automatic:

- Quizzes and light in-browser tasks
- Exercises done in the user's own code, which you then review (see [Reviewing the User's Work](#reviewing-the-users-work))

## Acquiring Wisdom

When a question requires real-world judgement, attempt an answer, then delegate to a **community**: a forum, subreddit, Discord, or class. Find high-reputation communities. If the user prefers not to join communities, respect it.

## Reference Documents

While creating lessons, also create reference documents: the compressed essence of the lesson, designed for quick reference and printing (form per [references/HTML-AUTHORING.md](./references/HTML-AUTHORING.md)). Lessons are rarely revisited; references are. Programming topics especially: syntax, code snippets, algorithms.

Terminology lives in `NOTES.md`: when a lesson introduces a term the user must retain, add it with a one-line definition to a Terminology section there, and use it consistently in every later lesson and review. No separate glossary file.

## `NOTES.md`

Record the user's teaching preferences here — level, style, what worked — so lessons and reviews can refer back to them.
