---
name: test-quality
description: Describes which tests are worth writing and how to write them. Use this skill each time you will add, review, or delete automated tests in any application.
---

# Test Quality

You have a limited budget of effort for tests. Each test is also a maintenance cost. A good test catches a bug that matters, and stays green when a person refactors the code. A bad test fails after each internal change and catches no bug. A bad test is worse than no test. It teaches persons to update assertions without thought.

These principles are mandatory rules, not a procedure. You shall apply each rule to the codebase in front of you. If you do not apply a rule, this is a critical mistake. Obey the conventions of that codebase when they do not conflict with this text. For Python tests, you shall **always** obey `references/python.md`.

## Behavior versus implementation

**Behavior** is what the users of the code can observe through their interface. Users are callers, end users, and other services. Behavior includes return values, errors, state that they can read, and effects on external systems. Examples: a request that the code sends, a row that the code writes, a message that the code emits.

**Implementation** is everything that users cannot see. Examples: private helpers, internal call order, intermediate data, and which collaborator does the work.

Tests must pin behavior. A test that pins implementation fails when a person refactors internals and no user sees a change. Such a test usually misses real bugs.

## The two-edit litmus test

Do this check for each test, existing or proposed:

1. **Break the behavior** that the test says it protects. Use a wrong value, skip an effect, or do an effect twice. If the test still passes, the test does not protect that behavior. Common causes:
   - an assertion looser than the contract
   - an expected value from the code under test
   - a constant or prompt string that the test restates, but the code never reads during the test
   - an assertion on data that the test itself builds
2. **Change the internals** and keep each observable result. If the test now fails, the test pins implementation.

A good test catches the first edit and stays green after the second edit. An empty list is the exact answer when no record matches. It is a hollow check when the test only needs "some result". Assert what the contract promises. Do not assert less. Do not assert more.

A test can also pin an **invariant** instead of an action. Examples: a key that must exist in two tables, or two registries that must stay equal. The invariant is the behavior.

## What is worth a test

Write a test where a wrong answer costs money, data, security, or trust:

- business logic and invariants: calculations, eligibility, state transitions, validation and authorization rules
- contracts at public boundaries: what a route, CLI, or consumer returns or sends, including failure shapes
- failure handling: typed errors, retries, idempotency, partial-failure recovery
- complex logic with a high risk of defects: parsers, complex queries, security guards (path traversal, allowlists), concurrency, performance contracts (query counts)
- consequences of critical wiring. Example: "the system rejects a request without authentication", "the system refuses a webhook with a bad signature". Do not test that the system registers the middleware.
- regressions: write one test per real bug. Make the test red first when possible.

The default for all other code is: no test. If a candidate test does not protect an item on this list, say this in one line. Do not write the test. Exception: the user asked for it explicitly. Then write the test and record the concern.

## How to recognize tests of low value

These patterns are signals, not automatic verdicts. Do the two-edit check before you decide.

- **Implementation-coupled**: the test mocks internal collaborators, calls private methods, asserts call counts or order, or verifies through a side channel when an interface exists. Read the data through the interface that users use. Query the store directly only when the stored record *is* the contract. Examples: an outbox, an audit log, or a table that another service reads. The record must have no read interface.

  ```
  BAD:  create_user("Alice"); expect db.query("SELECT ... WHERE name='Alice'") exists
  GOOD: user = create_user("Alice"); expect get_user(user.id).name is "Alice"
  ```
- **Tautological**: the test produces the expected value in the same way as the code. The test therefore passes by construction. See "Expected values" below.
- **Bypassing invariants**: the test builds domain objects around their parsers, validators, or constructors. The test then reaches states that production code cannot produce.
- **Coverage filler**: examples are "get name returns name", "a dataclass stores its fields", or anything that a type checker already guarantees. This is the most common low-value output that a model generates.
- **Wiring restatement**: the test mirrors the application flow step by step. Example: "service calls repository, repository calls mapper". The test mocks and asserts each step. It tests the diagram, not the system.

## Expected values

The expected value needs a source that is independent of the code under test. Approved sources are a literal from the specification, a manually calculated example, or a property that must hold (round-trip, idempotence). Approve a snapshot only after a human reviews it. Never use a value that comes from a run of the implementation, or from a new derivation of it.

```
BAD:  expect price_with_vat(100) == 100 * (1 + pricing.VAT_RATE)   # same constant, same formula
GOOD: expect price_with_vat(100) == 119                            # from the tax spec
```

Exception: **characterization tests**. Before a person refactors legacy code with no specification, such a test can capture the current output. Label these tests as characterization tests. Review each captured value, because they pin bugs as easily as features.

Thresholds need a test case on each side of the boundary. Inputs that all stay on one side cannot catch an off-by-one error.

## Test doubles

Rule of thumb: **fake system boundaries, not your own code.** Boundaries are external services, SDKs, the clock, and randomness. If you replace your own domain collaborators to check the orchestration, you get wiring-restatement tests.

The real distinction is domain logic versus ports to the outside world. Code ownership does not matter. Your own adapter to a payment provider is a boundary. An injected fake or in-memory implementation of it is acceptable. Your own pricing service is not a boundary.

- **Database**: if the project can already run tests against the real engine, use that engine. SQL semantics (constraints, locking, JSON types) differ between engines. A different engine gives false confidence. If the real engine is not available, use an in-memory or stub implementation of the repository port.
- **Filesystem**: a real temporary directory is better than a mock of file operations.
- **Designing a boundary**: pass the boundary in as a parameter. Do not construct it inside. Prefer one method per external operation over a generic `request(endpoint, ...)`. Then a fake returns one shape per method, without routing logic.

Prefer assertions on observable outcomes over spies:

```
BAD - fakes the own code, replays the application path, asserts the wiring:
  test "order service processes order":
    replace repo.save with a mock
    replace notifier.notify with a mock
    order_service.process(order)
    expect repo.save called once
    expect notifier.notify called once

GOOD - real domain code, fake only at the external boundary, observable outcome:
  test "placing a paid order confirms it to the buyer":
    mailbox = in-memory fake of the external mail service
    service = OrderService(orders, mailbox)

    confirmation = service.place(paid_order)

    expect confirmation.status is "confirmed"
    expect mailbox has a message for buyer's email
```

The contract decides whether an interaction is behavior. The payload that an external service receives is behavior, because that service observes it. "An empty cart never charges" makes the absence of a call on the payment client part of the behavior. Pair it with a case where the charge happens. Then the test proves that it can see a charge. A call to an internal helper is implementation.

Errors obey the same logic. The error type, status, or stable code that callers branch on is the contract. Exact message text is contract only when a person or system relies on it. Examples: a documented API error, CLI output. Otherwise the text is incidental.

## How to select the seam

A **seam** is a public boundary where you can observe behavior without access to the internals. Select the smallest stable public boundary that exposes the risk. Use focused domain tests for calculation rules. Use integration tests for the composition of pieces. Use end-to-end tests through the real entrypoint for contracts that users depend on. Broader is not automatically better. An endpoint test is a poor way to pin rounding rules.

Before you write a test, state the seams that you test at. State what each seam catches and what it misses. If the session is interactive and the scope is large or not clear, ask the user first. Otherwise state it and continue.

When you build new behavior, work in vertical slices. Write one test, then write just enough code to pass it. Do not write a batch of tests against imagined behavior. Such a batch tends to pin shape instead of what users see.

## Naming and shape

- Test names state capabilities. Example: "expired token is rejected", not "handle request calls validator". Use the domain vocabulary of the project when one exists.
- Write one coherent scenario per test. Several actions are acceptable when the behavior is sequential by nature. Examples: idempotency, retries, state transitions.

## When a test fails after your change

First decide if you intended the behavior change. If yes, update the expected value. You must be able to say which requirement the new value comes from. If no, the test caught a bug. Do not loosen an assertion, skip a test, or mark a test as expected-to-fail only to get a green run. That defeats the purpose of the test.

## How to delete tests

To delete low-value tests is part of the job. But stay within the scope of the task. Delete or rewrite the tests that your change breaks or forces you to touch. Replace each real invariant that such a test protects with a behavior test at a correct seam. Report the other offenders. Do not delete them. Review-only tasks propose. They do not delete.
