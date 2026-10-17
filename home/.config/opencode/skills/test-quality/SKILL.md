---
name: test-quality
description: Describes which tests are worth writing and how to write them. Use this whenever you are about to add, review, or delete automated tests in any application.
---

# Test Quality: Invariants and Critical Behavior

Testing effort is finite, and every test is a maintenance cost. A test earns its place by catching a bug that matters while staying quiet through refactors. Tests that do the opposite — break on every restructuring, catch nothing — are worse than no test: they train people to update assertions blindly.

These are principles to judge tests by, not a procedure. Apply them with judgment to the codebase in front of you, and follow its established conventions where they don't conflict with the intent here. For Python mechanics (pytest, fixtures, faking HTTP and the clock, async, framework seams) read `references/python.md`.

## Behavior vs implementation

**Behavior** is what the code's users — a caller, an end user, another service — can observe through the interface they use: return values, errors, state they can read back, and effects on systems outside the code (a request sent, a row written, a message emitted). **Implementation** is everything they can't see: private helpers, internal call order, intermediate data, which collaborator did the work.

Tests should pin behavior. A test pinned to implementation fails on refactors that change nothing a user can see, and usually misses real bugs.

## The two-edit litmus test

Imagine two edits against any test, existing or proposed:

1. **Break the behavior** the test claims to protect: wrong value, skipped effect, effect done twice. If the test still passes, it isn't protecting it. Common causes: an assertion looser than the contract, an expected value derived from the code under test, a restated constant or prompt string that never runs the code that reads it, an assertion on data the test built itself.
2. **Change the internals** while keeping every observable result. If the test now fails, it's pinned to implementation.

A good test catches the first and survives the second. An empty list is the exact answer when no record matches, and a hollow check when the test only needs "some result" — assert what the contract promises, no less and no more.

A test may also pin an **invariant** rather than an action — a key that must exist in two tables, two registries that must stay in sync. The invariant is the behavior.

## What's worth testing

Where a wrong answer costs money, data, security, or trust:

- business logic and invariants: calculations, eligibility, state transitions, validation and authorization rules
- contracts at public boundaries: what a route, CLI, or consumer returns or sends, including failure shapes
- failure handling: typed errors, retries, idempotency, partial-failure recovery
- non-trivial logic likely to break: parsers, complex queries, security guards (path traversal, allowlists), concurrency, performance contracts (query counts)
- consequences of critical wiring: "unauthenticated request is rejected", "webhook with a bad signature is refused" — not that the middleware is registered
- regressions: one test per real bug, red first when feasible

The default for anything else is no test. If a candidate test doesn't guard something on this list, say so in one line instead of writing it — unless the user explicitly asked for it; then write it and note the concern.

## Recognizing low-value tests

These patterns are signals, not automatic verdicts — check them with the two-edit test before deciding.

- **Implementation-coupled**: mocks internal collaborators, calls private methods, asserts call counts or order, or verifies through a side channel when an interface exists. Read back the way users do; query the store directly only when the stored record *is* the contract (outbox, audit log, a table another service reads) and has no read interface.

  ```
  BAD:  create_user("Alice"); expect db.query("SELECT ... WHERE name='Alice'") exists
  GOOD: user = create_user("Alice"); expect get_user(user.id).name is "Alice"
  ```
- **Tautological**: the expected value is produced the same way the code produces it, so the test passes by construction (see "Expected values" below).
- **Bypassing invariants**: building domain objects around their parsers, validators, or constructors to reach states production can't produce.
- **Coverage filler**: "get name returns name", a dataclass stores its fields, anything a type checker already guarantees. The most common model-generated slop.
- **Wiring restatement**: mirrors the application flow hop by hop — "service calls repository, repository calls mapper" — each hop mocked and asserted. It tests the diagram, not the system.

## Expected values

The expected value needs a source independent of the code under test: a literal from the spec, a hand-worked example, a property that must hold (round-trip, idempotence), or a snapshot a human actually reviewed. Never one obtained by running or re-deriving the implementation.

```
BAD:  expect price_with_vat(100) == 100 * (1 + pricing.VAT_RATE)   # same constant, same formula
GOOD: expect price_with_vat(100) == 119                            # from the tax spec
```

Exception: **characterization tests** before refactoring legacy code with no spec may capture current output — label them as such and review each captured value, because they pin bugs as readily as features.

Thresholds need a case on each side; inputs that all sit on one side of a boundary can't catch an off-by-one.

## Test doubles

Rule of thumb: **fake system boundaries, not your own code.** Boundaries are external services and SDKs, the clock, randomness. Replacing your own domain collaborators to verify orchestration produces wiring-restatement tests.

The real distinction is domain logic vs ports to the outside world, not who owns the code. Your own adapter to a payment provider is a boundary: an injected fake or in-memory implementation of it is fine. Your own pricing service is not.

- **Database**: if the project can already run tests against the real engine, use it — SQL semantics (constraints, locking, JSON types) differ between engines, so a different engine gives false confidence. Otherwise use an in-memory or stub implementation of the repository port.
- **Filesystem**: a real temporary directory beats mocking file calls.
- **Designing a boundary**: pass it in rather than constructing it inside; prefer one method per external operation over a generic `request(endpoint, ...)`, so a fake returns one shape per method without routing logic.

Prefer asserting observable outcomes over spies:

```
BAD — fakes own code, replays the application path, asserts the wiring:
  test "order service processes order":
    replace repo.save with a mock
    replace notifier.notify with a mock
    order_service.process(order)
    expect repo.save called once
    expect notifier.notify called once

GOOD — real domain code, fake only at the external boundary, observable outcome:
  test "placing a paid order confirms it to the buyer":
    mailbox = in-memory fake of the external mail service
    service = OrderService(orders, mailbox)

    confirmation = service.place(paid_order)

    expect confirmation.status is "confirmed"
    expect mailbox has a message for buyer's email
```

The contract decides whether an interaction is behavior. The payload an external service receives is behavior, because that service observes it. "Empty cart never charges" makes a no-call on the payment client behavior — pair it with a case where the charge happens, so the test proves it can see one. A call to an internal helper is implementation.

Errors follow the same logic: the type, status, or stable code callers branch on is the contract. Exact message text is contract only when someone relies on it (a documented API error, CLI output); otherwise it's incidental.

## Choosing the seam

A **seam** is the public boundary where behavior is observed without reaching inside. Pick the smallest stable public boundary that exposes the risk: focused domain tests for calculation rules, integration tests for how pieces compose, end-to-end through the real entrypoint for contracts users depend on. Broader isn't automatically better — an endpoint test is a poor way to pin rounding rules.

Before writing, state the seams you're testing at and what each catches and misses. If the session is interactive and the scope is large or ambiguous, check with the user first; otherwise state it and proceed.

When building new behavior, work in vertical slices — one test, then just enough code to pass it — rather than a batch of tests against imagined behavior, which tends to pin shape instead of what users see.

## Naming and shape

- Names read as capabilities: "expired token is rejected", not "handle request calls validator". Use the project's domain vocabulary if it has one.
- One coherent scenario per test. Several actions are fine when the behavior is inherently sequential — idempotency, retries, state transitions.

## When a test fails after your change

Decide first whether the behavior change was intended. If it was, update the expected value and be able to say which requirement the new value comes from. If not, the test just caught a bug. Loosening an assertion, skipping, or marking it expected-to-fail to get green defeats its purpose.

## Deleting tests

Deleting low-value tests is part of the job, but stay within the task's scope: remove or rewrite the ones your change breaks or forces you to touch, and replace any real invariant they guarded with a behavior test at a proper seam. Report other offenders rather than deleting them. Review-only tasks propose, they don't delete.
