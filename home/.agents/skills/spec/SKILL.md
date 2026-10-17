---
name: spec
description: Write an implementation plan (spec) to a file before touching code, covering why and what changes, the design as types, signatures and call stacks, and ordered steps. Use when the user asks to prepare or revise a plan or spec, or to turn an earlier discussion into a reviewable document before coding.
---

# Spec: Plan Before Code

A spec turns a discussion into an agreed change before any code moves. Its value is catching misunderstandings while they cost a paragraph instead of a diff. Specs are throwaway: they live in the worktree until the change ships, then get deleted.

These are the user's preferences, not a procedure or a template. Shape each spec to the change in front of you: a one-file fix and a cross-service migration deserve very different documents. For shaping the design itself see the `module-design` skill, for what's worth testing see `test-quality`, and use the project's domain vocabulary (`domain-modeling`).

## What the user values

**Your understanding, not a paraphrase.** The user usually asks for a spec after an initial discussion. The most useful part is a short restatement of why we're changing this and what changes, in your own words: the motivation, the scope including what deliberately stays untouched, and the constraints and inferences nobody spelled out. That's where a misread gets caught. Echoing the prompt back catches nothing.

```
BAD:  We need to add invoice voiding.
GOOD: Finance can't reverse a sent invoice without deleting it, which breaks the audit trail.
      We add a Sent → Voided transition; voided invoices stay readable and emit InvoiceVoided.
      Refunds for paid invoices stay out of scope (separate flow, per discussion).
```

**Code-shaped design, prose for the why.** Types, function and method signatures, protocols, and schema changes say what changes more precisely than paragraphs do. Prose explains why a decision went this way. Use the project's language, real symbol names, and real file paths: the spec is short-lived, so precision beats staleness. For a new API or module, a few lines of calling code often say more than the signatures, so show how it's used before showing what it is.

```python
# Types carry the change; the signature shows how they're consumed
class Cadence(StrEnum):
    DAILY = "daily"
    WEEKLY = "weekly"

@dataclass(frozen=True)
class PayoutSchedule:
    merchant_id: MerchantId
    cadence: Cadence
    next_run: date

def schedule_payouts(merchant_id: MerchantId, cadence: Cadence, today: date) -> PayoutSchedule: ...
# raises MerchantNotFound, PayoutsSuspended
```

**Signatures, not implementations.** Snippets are contracts with `...` bodies. A finished function body turns review into line edits and hides the design. Pseudocode is welcome where the logic's shape is itself the decision: a state transition, a tricky query, a retry policy.

```python
# BAD: an implementation; the decision hides in the body
def void_invoice(invoice_id: InvoiceId, reason: VoidReason) -> Invoice:
    invoice = invoices.get(invoice_id)
    if invoice.status is not Status.SENT:
        raise InvoiceNotVoidable(invoice_id)
    ...  # 30 more lines

# GOOD: the contract; the decision sits in the types and failures
def void_invoice(invoice_id: InvoiceId, reason: VoidReason) -> Invoice: ...
# raises InvoiceNotFound; InvoiceNotVoidable unless the invoice is Sent
```

**Call stacks where the flow matters.** When a change threads through several modules, an indented tree from entrypoint to side effects, with a file per frame and new or changed frames marked, is the fastest way to review it. Showing current against proposed helps when existing behavior changes. Skip it when the flow is obvious.

```
POST /invoices/{id}/void            api/invoices.py
  void_invoice()                    billing/operations.py   ← new
    Invoice.void(at, reason)        billing/domain.py       ← new transition, refuses unless Sent
    invoices.save()
    events.publish(InvoiceVoided)                           ← new event
  InvoiceNotVoidable → 409
```

**Steps someone can execute.** An ordered implementation plan where each step is concrete enough to start on: which symbol in which file, and roughly how you'd know it works. Steps that leave the code in a working state are easier to review and to resume. Making the change easy before making it, and slicing through layers instead of building one layer at a time, often orders steps well. When the change touches persisted data, public contracts, or deploy order, the steps say how those move: migration, backfill, compatibility window.

```
BAD:  3. Update the service and API to support voiding.
GOOD: 3. Add `Invoice.void(at, reason) -> Invoice` in billing/domain.py;
         a paid invoice is refused with InvoiceNotVoidable.
```

**Decisions over options.** Recommend a design. Mention alternatives only when there were real contenders, briefly, with why they lost. Name tradeoffs you're accepting so they don't read as oversights later.

## Level of detail

Include what a reviewer could disagree with and what an implementer (often you, next turn) needs at the point of change: paths, signatures, existing contracts the change has to respect. Everything else is noise. A small change can be a few paragraphs and a handful of steps.

## Questions and unknowns

Find facts yourself: how the code works, which callers exist, what a library does. Ask the user when missing intent would materially change the design: scope, user-visible behavior, priorities between competing goals. Technical choices are yours to recommend. Asking up front fits when the answer would reshape the whole spec; a provisional spec with explicit assumptions often helps the user decide faster. If there's too little to go on, say so and interview the user (see `grilling`) rather than inventing requirements.

Open questions left in the spec read best with a recommendation attached, so the user's reply settles them.

```
BAD:  - Not sure how to handle already-exported invoices.
GOOD: - Refuse voiding invoices already exported to the ledger?
        Recommended: yes; ledger corrections stay manual.
```

## Working with the file

- Write the spec to a file. Follow the repo's convention for plans if there is one; otherwise a `.md` file at the worktree root is fine. HTML (the `html` skill) is fine when it explains the design better, such as diagrams.
- Don't touch code until the user says go. The user reads the file, so the reply only needs the path and whatever needs their attention.
- Iterate on the same file; one current document is easier to review than appended revisions.
