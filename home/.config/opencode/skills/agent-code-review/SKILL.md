---
name: agent-code-review
description: Never run it autonomously, only when explicitly prompted by the user.
---

Start two `/agent-subtasks` for focused code review sessions of the current changes made by an agent.

## Subtask 1 -- Verify Correctness & Regression Risk

Does the change do its job without breaking anything?

Scope:
- correctness, edge cases, regressions
- security risks and trust boundaries (input validation, auth, permissions, data-loss error handling)
- performance concerns and complexity hotspots (concurrency, I/O, DB writes, N+1 queries)
- root cause vs. symptom: does the fix address the shared origin or only one caller path?

Rules:
- prioritize actionable findings over style commentary
- deep-dive risky paths: auth, permissions, I/O, concurrency, DB writes
- use local repository evidence first; use webfetch only when needed to confirm uncertain behavior
- if uncertainty remains, state assumption and reduce confidence accordingly

## Subtask 2 -- Verify Code Minimalism & Style

Is the change minimal, platform-native, and free of over-engineering?

Core principles:
- **YAGNI.** No abstractions that weren't explicitly requested: no one-implementation interfaces, no factories for one product, no config for values that never change, no scaffolding "for later." If the thing doesn't need to exist now, skip it.
- **Platform-first.** Use stdlib, native APIs, and already-installed dependencies before writing custom code. The platform ships for free, doesn't break on updates, and was written by domain experts. Never add a new dependency for what a few lines of stdlib can do.
- **Deletion over addition.** Removing code is always preferable to adding it. Every line never written has zero bugs and zero maintenance burden. Question whether the change needs to exist at all.
- **Fewest files possible.** Every new file is a navigation cost. Consolidate into existing modules unless a clear separation boundary is crossed.
- **Boring over clever.** Clever code is what someone has to decode at 3am. Choose the simplest, most obvious approach. Two stdlib options of equal size? Take the one that's correct on edge cases — minimalism is about volume, not algorithmic fragility.
- **Shortest working diff** — but only after full understanding. A tiny change in the wrong place is a second bug, not efficiency.
- **Root cause fix.** Trace every caller of the function you touch and fix the shared origin once — one guard there is a smaller diff than one per caller, and patching only the reported path leaves sibling callers broken.

Decision ladder (stop at the first rung that holds):
1. Does this need to exist at all? (speculative need → skip it)
2. Already in this codebase? (reuse the existing helper/util/pattern)
3. Stdlib does it? (standard library ships for free)
4. Native platform feature? (OS, browser API, DB constraint over app code)
5. Already-installed dependency? (use it, never add a new dep for triviality)
6. Can it be one line? (compress)
7. Only then write the minimum code that works.

What is never on the chopping block:
- Input validation at trust boundaries
- Error handling that prevents data loss
- Security measures (auth, encryption, path-traversal guards)
- Accessibility basics
- Anything explicitly requested by the user

Finding tags for this dimension:
- `delete:` — dead code, unused flexibility, speculative feature, scaffolding. Fix: remove it.
- `stdlib:` — hand-rolled code where stdlib already ships the function. Name the stdlib alternative.
- `native:` — dependency or custom code where the platform already provides the feature. Name the native API.
- `yagni:` — abstraction with one implementation, config nobody sets, layer with one caller, scaffolding for an unknown future.
- `shrink:` — same logic, fewer lines. Show the shorter form.

## Subtasks output format

1) **Overall merge confidence:** <1-10>
2) **Findings** sorted by impact (largest drop first). For each finding include:
   - **Dimension:** Correctness | Code-Style
   - **Confidence impact:** -1 to -4
   - **Why it matters**
   - **Evidence** (file:line)
   - **Suggested fix**
3) **Immediate actions (before merge):** concise checklist of must-fix items
4) **Nice-to-have backlog (after merge):** concise list of non-blocking improvements
5) **Merge recommendation:**
   - 9-10: Safe to merge
   - 7-8: Merge with follow-up fixes
   - 4-6: Fix before merge
   - 1-3: Do not merge
6) If no blockers, state: No blocking issues. Merge confidence: <score>/10.

## Confidence Scoring

Start at 10 and subtract per finding, then clamp to [1,10]:
- -4: exploitable security issue, data loss risk, or harmful system behavior
- -3: likely correctness regression, crash path, or trust-boundary break
- -2: significant performance/reliability risk under expected load
- -1: maintainability/readability risk with low near-term impact (includes YAGNI, stdlib, native, delete, shrink violations)

## Processing the subtasks output

Wait for both subtasks to execute and look up their feedback afterwards to load it into parent (current) session context.
