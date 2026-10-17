---
name: module-design
description: Principles for shaping application code into cohesive, loosely coupled modules that are cheap to change. Use whenever you design a feature, add or restructure modules or packages, decide where code belongs, or review code structure in a backend application, consumer, worker, or scheduled job.
---

# Module Design: Deep Building Blocks, Thin Arrangement

Most of an application's cost is change. A good design turns a new requirement into a re-arrangement of existing building blocks plus maybe one new block. A bad design makes every requirement touch everything, so people bolt on special cases until nobody can change it safely.

These are principles to judge designs by, not a procedure. Apply them with judgment to the codebase in front of you. Follow its established conventions where they don't conflict with the intent here; where an old pattern does conflict, contain it at the nearest boundary instead of copying it into new code or rewriting unrelated code. Scale the design to the problem: a twenty-line cron job needs none of the machinery below. For Python mechanics read `references/python.md`. For tests, see the `test-quality` skill. For naming domain concepts, see the `domain-modeling` skill.

## Vocabulary

**Module**: anything with an interface and an implementation: a function, class, file, or package. The principles here apply at every scale.

**Interface**: everything a caller must know to use the module correctly. That's the signature, plus invariants, ordering constraints, error modes, required configuration, and performance characteristics. A short signature followed by a long list of "but first you must..." is a large interface.

**Depth**: how much behavior a caller gets per unit of interface it has to learn. A deep module hides a lot behind a small interface. A shallow one makes the caller learn almost as much as the implementation.

**Seam**: the place where a module's interface meets its callers. An implementation can be swapped at a seam without editing the callers.

**Roles**: code changes for one of a few reasons, and naming the reason tells you where the code belongs.

- **Domain logic** changes when business meaning changes: which values are valid, calculations, legal state transitions. It is pure: no I/O, no clock, no framework.
- **Application operation** changes when a use case's policy or sequence of effects changes: authorization, which effects happen, in what order, under which transaction.
- **Adapter** changes when a technology changes. Inbound adapters (HTTP route, message consumer, cron entrypoint, CLI) turn external input into a call and the result into an external outcome. Outbound adapters (database, HTTP client, message producer, SDK wrapper) implement what the application needs with a concrete technology.
- **Wiring**, the composition root, changes when construction or configuration changes. It reads config, builds adapters, and hands them to the code that needs them.

The roles are responsibilities, not layers, folders, or class suffixes. A pure calculation can be called straight from a handler with no "service" in between, so don't create three layers where one function is enough. Split a module when it owns more than one reason to change, not to satisfy the taxonomy.

## Deep building blocks, thin arrangement

Build features from blocks that each hide a real decision: a domain type that owns its transitions, a store that returns domain values, a client that hides the vendor protocol. The code that arranges them for a use case should read like the use case itself, a few calls with no knowledge of how each block works.

```
BAD — the caller arranges shallow steps, and every entrypoint repeats the policy:
  row = db.fetch("invoices", id)
  if row.status != "sent": raise ...
  row.status = "paid"; row.paid_at = now()
  db.update("invoices", row)
  producer.send("invoice-events", {"type": "paid", "id": row.id})

GOOD — deep blocks, one thin arrangement reused by the route, the consumer and the cron job:
  pay_invoice(invoice_id, invoices, events, clock):
    invoice = invoices.get(invoice_id)        # a domain type, never a row
    paid = invoice.pay(at=clock.now())        # the legal transition lives in the domain
    invoices.save(paid)
    events.publish(InvoicePaid(paid.id))
```

When the requirement changes ("also pay from the bank-statement importer", "notify accounting"), the blocks stay as they are and only an arrangement changes. If a change forces you to open every block, the boundaries are in the wrong place.

Blocks should be fine-grained enough to recombine, but not so fine that callers end up carrying the complexity. **Primitives are deep, arrangements are thin, and each policy lives in exactly one arrangement.** If two entrypoints arrange the same steps the same way, that arrangement is a block of its own.

Judging a block:

- **Deletion test.** Imagine deleting it. If the complexity reappears across its callers, the block earns its place. If the complexity just disappears, it was a pass-through, so inline it.
- **One implementation is a hypothetical seam; two make it real.** Introduce an abstraction (port, protocol, base class) when something actually varies across it, typically a production adapter and a test fake for an external system. "In case we switch databases" doesn't count.
- **The interface is the test surface.** If testing a module requires reaching past its interface, the module is the wrong shape.
- **Write the caller first.** Before shaping a new block, write the two or three lines that use it and derive the signature from them. If the call site is awkward, so is the block.
- **Data shape first.** Get the core types right before writing logic; with the right structure the logic is usually obvious. When the shape isn't obvious, sketch more than one structurally different option before committing to one.

## Cohesion and coupling

- **What changes together lives together.** If one requirement forces edits across many modules (shotgun surgery), gather that code. If one module gets edited for unrelated reasons (divergent change), split it.
- **Group by knowledge, not by execution order.** Modules named after steps (`loaders`, `validators`, `transformers`, `savers`) repeat the same representation and rules in every step. A module owns a body of knowledge, even when its functions run at different times.
- **Callers shouldn't depend on what they don't use.** A job that needs one lookup shouldn't take a twenty-method repository that mixes unrelated capabilities. Split adapters by cohesive capability, so each caller depends on a small, coherent surface. Where the language makes it cheap (structural typing), a caller can also declare just the narrow slice it uses.

  ```
  BAD:  ReminderJob(users: UserRepository)          # 20 methods for profiles, billing, auth, reminders
  GOOD: ReminderJob(users: ReminderRecipients)      # find_due(before), mark_reminded(user_id)
  ```
- **Dependencies point toward stable, pure code.** Domain logic imports nothing from application code or adapters. Application code knows what adapters do in domain terms, not the technology behind them. Adapters depend on both and translate between them. Volatile, technology-specific code depends on stable code, never the reverse.
- **No dependency cycles** between modules. A cycle means the two modules are really one, or a third concept is missing.
- **Accept dependencies, don't construct them.** A module that builds its own clients or reads environment variables hides its requirements and can't be rearranged. Wiring constructs; everything else receives.
- **Prefer composition over inheritance** for sharing behavior. An inheritance tree couples every subclass to the base class's internals.
- **Avoid grab-bag modules** (`utils`, `helpers`, `common`, `misc`). They have no single reason to change, so they attract everything. Put a helper next to the concept it serves, and name a genuinely generic one after what it does.

## Boundaries

Data entering the system is untrusted and loosely shaped. Data inside should be neither.

- **Parse at the edge, trust inside.** Turn raw input (request bodies, messages, rows, environment variables, third-party responses) into domain types at the adapter, once. Inner code takes those types and doesn't re-validate them. Checks scattered deep in call chains are noise and give false safety.
- **Representations stay where they belong.** Wire schemas, vendor SDK objects and framework request types stay inside the adapter that handles them, and a module doesn't re-export them from its public surface. Once they leak, a field rename or a vendor upgrade becomes a change everywhere. Persistence models may double as domain objects where that is the codebase's idiom. But database access (open sessions, lazy loading) doesn't travel with them, and they don't double as wire contracts.

  ```
  BAD:  charge(payload: dict, customer: stripe.Customer)
  GOOD: charge(order: Order, customer: CustomerId) -> Charge     # the adapter maps to and from Stripe
  ```

  The exception is a framework that *is* a module's runtime, such as an agent framework inside the agent package or a web framework inside its routes. Its types are fine inside that module. Keep them out of domain types, persisted state, and the module's public surface.
- **Expected failures are part of the interface.** Callers branch on "not found", "already paid" and "provider unavailable", so give such failures stable, precise types owned by the module that reports them. Vendor and driver errors stay inside the adapter that met them. Inbound adapters translate failures into whatever their protocol needs: a status code, a retry, a dead letter, an exit code. Defects such as violated invariants or impossible branches may fail loudly.

  If every caller has to handle an outcome as a normal branch ("needs approval", "needs step-up auth"), it isn't a failure. Return it as one variant of a result type. Signal a failure out of band (an exception, in most languages) when most callers just pass it upward.
- **Parse configuration once, at startup,** into a typed object, and pass it down. Missing config is a startup failure, not a surprise three calls deep at runtime.
- **No side effects at import time**: no connections, no scattered environment reads, no registration. Keep ambient state (clock, randomness, ID generation) out of pure logic by passing it in as arguments, so the same block runs in production, in tests, and in a backfill script.

## Model the domain in data

Encode rules in data structures instead of scattering them across conditionals. The right structure deletes branches and makes invalid states unrepresentable.

- **State machine over flags.** Two booleans that must stay in sync, or a nullable timestamp that's "always set when status is X", are invariants waiting to break. Model the states and the allowed transitions explicitly. The state changes only through transitions that own the rules.

  ```
  BAD:  Invoice(is_sent: bool, is_paid: bool, sent_at: datetime?, paid_at: datetime?)
  GOOD: Invoice(status: Draft | Sent | Paid); invoice.pay(at) refuses unless status is Sent
  ALSO: Invoice = Draft(lines) | Sent(sent_at) | Paid(paid_at)    # when states carry different data
  ```
- **Table over branching.** When each new variant adds an `elif` in several places, replace the branches with one lookup table, registry, or polymorphic type, so there's a single place to add a variant.
- **Types for meaning.** Give IDs, money, units, and validated strings their own types when mixing them up is a realistic bug. Construct them through one parser, then trust them.
- **Named options, not flags.** `send(msg, True)` hides its meaning; `send(msg, delivery="best_effort")` doesn't. A boolean parameter that switches behavior often means there should be two functions.
- **One source of truth.** Derive data instead of keeping copies in sync. If two lists must be edited together, generate one from the other, or add a check that fails when they diverge.

Don't force structure where it buys nothing. Code that is already clear, local, and unlikely to grow stays plain. An abstraction earns its keep by deleting branches, duplicated rules, invalid states, or lifecycle risk.

## Red flags

These are signals, not verdicts. Check each one against the deletion test and the reason-to-change question.

- **Shallow module or pass-through**: it forwards the same arguments to something of the same shape. Collapse it unless it adds policy, translation, or a distinct abstraction.
- **Callers coordinate internals**: completing one operation means calling several methods in the right order, or knowing the module's internal rules. The module should do that coordination.
- **Information leakage**: the same decision (a format, a status string, a key layout, a retry policy) appears in several modules, so changing it takes a coordinated edit.
- **Split ownership**: more than one module writes the same state or keeps its own copy of it. Give each piece of state one owner; other modules read it or ask the owner to change it.
- **Two ways to do one task**: old and new APIs coexist. Each copy-paste picks one at random, so both keep gaining callers.
- **Importable internals**: callers reach past the public surface because nothing stops them, and the internals become the interface.
- **Feature envy**: a function mostly works on another module's data, so it belongs in that module.
- **Data clumps or primitive obsession**: the same few values travel together everywhere, or a raw string stands in for a domain concept. A type wants to exist.
- **Speculative generality**: hooks, parameters, plugin points, or base classes for needs nobody has. Delete them until a real need shows up.
- **Ad-hoc branches in shared paths**: `if tenant == "acme":` inside a general flow, or the same rollout `if is_enabled(FLAG):` repeated across modules. Resolve the decision once at the entry and pass down the chosen value or strategy, or move the variation into the one module that owns it.
- **Stringly-typed contracts**: a writer and its readers agree on dict keys, payload shapes, or template variables by hand. Give the contract one type that all of them use, parsed once.

## Backend runtime concerns

Consumers, workers and scheduled jobs run amid crashes, redeliveries and overlapping runs. These concerns shape module boundaries, not just implementations.

- **Make state-changing operations idempotent.** Ask "what if this runs twice?" and "what if the last run died halfway?". Derive each step from the current state, not from what a previous run meant to do. Natural keys, unique constraints, dedup records, and state-transition guards all help. Assume at-least-once delivery.
- **One writer per piece of state.** Before reaching for a lock, ask whether the actors need to share the mutable thing at all. Often each can get its own key, row, or partition, with the results merged on read. Serialize structurally (a transaction, a single consumer per partition, compare-and-swap) only when a single writer is a real invariant.
- **Don't hold a transaction open across a network call.** Commit and then call out, or record the intent atomically (an outbox) and publish it separately.
- **Retries have one owner.** Adapters may retry short-lived technical failures when the call is safe to repeat. Whether to attempt an operation again is application policy. Retries that must survive restarts or delays belong to the queue or a durable workflow, not an in-process loop. Retry layers multiply: an app loop around an SDK client that already retries, behind a model fallback chain, makes many attempts per call. Know every layer and give each one a deliberate budget.
- **Entrypoints stay thin.** A consumer handler, cron job, or route parses its input, calls an operation, and translates the outcome. Any entrypoint should be able to call the same operation, and so should a one-off backfill script.

## Evolving a design

- **Integrate a requirement as if it had been there from day one.** Ask what you'd build from scratch knowing it, then move toward that. A bolted-on flag and branch is how good designs rot.
- **Subtract before you add.** Remove dead code, one-caller wrappers, and obsolete paths first, then build on the smaller base. Leave the design simpler, or more capable behind the same surface, than you found it.
- **Migrate callers and delete the old way in the same change** when there are no external consumers. Compatibility shims inside one application tend to become permanent.
- **Scrap the shape when it fights you.** The tells:
  - the same workaround keeps appearing in unrelated places
  - unrelated edge cases each need a special-case branch
  - types only fit with casts or "optional" fields that are always set
  - callers need to know the abstraction's internal rules
  - "we need a lock" when the design said nothing was shared

  One awkward case is complexity in the data. A pattern of them is complexity in the design.
- **Prefer structure over instructions.** If a rule keeps having to be restated ("don't import X from Y"), make the wrong thing fail with a type, an import rule, or a check.

Stay within scope. Restructure what the task touches and the modules it has to change. Report other design problems instead of refactoring them uninvited.
