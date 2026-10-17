# Python module mechanics

How to express the principles in SKILL.md in Python. In an existing project, its conventions win: consistency inside a codebase beats these defaults.

## Adopting a convention

Some of what follows changes how a codebase is laid out or wired: re-exporting a public surface from `__init__.py`, underscore-private submodules, import-linter contracts, moving client construction into a composition root. Before introducing one, look at how the codebase already does it.

- **It fits naturally** when the codebase already uses it, or when the change creates a new self-contained package whose neighbours wouldn't look odd next to it. Apply it.
- **It would be a first** when no other package does it, or when it would make one package unlike the rest. Ask the user before introducing it. If you can't ask, follow the existing style and mention the option in your summary.

A consistent, imperfect convention beats a mix of two. The parts of this file that don't change layout (types, parsing, error translation) apply to new code regardless.

## Ports

By default, depend on the concrete class. Duck typing already lets a test fake implement only the methods the code calls. Outbound HTTP and databases are usually faked at the transport or run for real (see the `test-quality` skill), so most adapters never get a second implementation.

```python
class ReminderJob:
    def __init__(self, users: PostgresUsers, mailer: Mailer) -> None: ...
```

Introduce an explicit interface when something really varies behind it: two or more real implementations (model providers, storage backends), or a fake that is much simpler than faking the transport (a Kafka producer, a boto client). Declare one interface per external capability, not one per caller.

```python
class ChatModel(Protocol):
    async def complete(self, messages: list[Message]) -> Completion: ...
```

- Choose between `ABC` and `Protocol` the way the codebase already does. An ABC with only abstract methods is easy to discover ("find implementations" works). A `Protocol` fits when the implementation can't or shouldn't inherit, such as a third-party class. Neither carries implementation, so neither creates inheritance coupling. Shared implementation in a base class is what does.
- An interface only checks anything when pyright or mypy runs in CI. Without a type checker, it's documentation.
- Match the interface's sync or async style to how it's used. Don't wrap an async adapter behind a sync interface, or the reverse.

## Domain types

- Value objects (money amounts, date ranges, parsed identifiers, settings) are `@dataclass(frozen=True)`, so callers can trust a value they were handed.
- Entities follow the codebase: Pydantic models, ORM models, and plain dataclasses are all normal. What matters is that the rules for changing them live in one place, not that they are immutable.
- Use `enum.StrEnum` for closed sets of strings that cross a boundary.
- Money is `Decimal` or integer minor units, never `float`.
- `NewType("InvoiceId", UUID)` costs nothing at runtime and catches mix-ups in the type checker. Use it where IDs of different kinds appear in the same signatures. Elsewhere it only adds wrapping. It validates nothing, so create values only through the parser at the boundary.
- The default state machine is a status enum plus transition methods that own the rules. It maps directly onto a database column:

```python
class InvoiceStatus(StrEnum):
    DRAFT = "draft"
    SENT = "sent"
    PAID = "paid"


class Invoice:
    def pay(self, at: datetime) -> None:
        if self.status is not InvoiceStatus.SENT:
            raise InvoiceNotPayable(self.id, self.status)
        self.status, self.paid_at = InvoiceStatus.PAID, at
```

- Callers never assign `status` directly. They call the transition.
- When states carry different data and live in memory (parsed events, agent run outcomes), use a union of dataclasses instead. Branch on it with `match`, ending in `case _: assert_never(x)`, so the type checker flags every `match` a new variant hasn't handled.
- Datetimes are timezone-aware. Pure functions take `now` as an argument.

## Parsing at boundaries

- Inbound adapters parse with whatever the project already uses (Pydantic, attrs, marshmallow): request bodies, message payloads, settings. Convert to domain types in the adapter, not in the operation.
- A request schema can double as a domain type only when its shape and meaning really are the same. Once they diverge (extra transport fields, different optionality, a version envelope), split them.
- Using ORM models (SQLAlchemy, SQLModel, Django) as domain objects is normal, and you don't need to map them to separate types by default. Two hazards matter regardless:
  - **Hidden database access.** Sessions, unloaded lazy relationships, and querysets must not leave the module that owns the query; they carry database access wherever they travel. Load what callers need up front, and pass objects or IDs.
  - **Wire contracts.** An ORM model must not double as an API response or a message payload; a column rename would then break consumers.
- Map to separate domain types only when the shapes really differ. For example, an aggregate assembled from several tables, or rules that would otherwise end up split between the model and its callers.
- Business rules live in model methods or domain functions, not in views, serializers, routes, or tasks.
- Settings are a typed object built once at startup (`pydantic-settings` or a frozen dataclass). Modules don't read `os.environ`.

## Errors

- Each module defines its expected failures as a small exception hierarchy. Add structured fields (IDs, retry-after) when a caller reads them, not by default:

  ```python
  class InvoiceError(Exception): ...

  class InvoiceAlreadyPaid(InvoiceError):
      def __init__(self, invoice_id: InvoiceId) -> None:
          super().__init__(f"invoice {invoice_id} is already paid")
          self.invoice_id = invoice_id
  ```
- Adapters catch vendor and driver exceptions (`httpx.HTTPError`, `sqlalchemy.exc.IntegrityError`, botocore's `ClientError`) and re-raise the module's own types with `raise ... from exc`.
- Inbound adapters map exceptions to outcomes: an exception handler maps them to HTTP statuses, a consumer to retry, dead-letter, or skip, and a cron job to an exit code or alert.
- Broad `except Exception` belongs only at the outermost entrypoint, where it logs and translates, or around a fail-open side channel (telemetry, metrics, tracing) that must never break the request, where it logs and moves on. Never swallow an exception silently.
- For "needs approval" or "needs step-up" outcomes (see SKILL.md), return a union of dataclasses rather than raising. If the framework already returns such outcomes as data, don't convert them into exceptions.
- Returning `X | None` for "not found" is fine when absence is ordinary for the caller. Raise when the caller can't reasonably continue. Pick one per operation and keep to it.

## Public surface

Python doesn't enforce privacy, so the public surface is a convention. Options, from lightest to strictest:

1. **Leading-underscore names** for internals (`_build_payload`). This is universal and always fine.
2. **Underscore submodules** (`billing/_stripe_mapping.py`), signalling "don't import from outside the package".
3. **Re-exports in `__init__.py`** with `__all__`, so callers import from the package rather than its submodules. Keep `__init__.py` to imports only, with no logic. Heavy package imports slow startup and cause import cycles.
4. **import-linter contracts** in CI (`layers`, `forbidden`, `independence`), so a boundary violation fails the build.

Options 2–4 change layout, so follow "Adopting a convention" first. Whatever the level, never import another package's underscore names, and never export internals just for tests.

## Wiring

- Each process type (API, consumer, each scheduled job) has one composition root. It parses settings, opens pools and clients, constructs adapters and operations, and starts the loop. Elsewhere, construction happens through plain constructor arguments.
- Don't add a DI container the project doesn't already use. FastAPI's `Depends` is fine as the inbound adapter's wiring, but operations and domain code must not import FastAPI.
- Make resource lifetimes explicit in the root: use `async with`, `contextlib.AsyncExitStack`, or the framework's lifespan hook.
- A module-level `settings = Settings()` is idiomatic and fine, as long as it's built once from the environment and nothing else reads `os.environ`.
- Clients that hold connections (`httpx.AsyncClient`, database pools, Kafka producers) are not built at import time. They bind to whatever event loop is current, hide a dependency, and leak state across tests. Build them in the root, or in a factory the root calls.
- Pure functions take `now` as an argument. Injecting a clock into operations is optional. `time-machine` or `freezegun` in tests is idiomatic Python.
- Request-scoped context in a `contextvar` (request ID, tenant, locale) is acceptable ambient state for telemetry and logging. Business logic should take such values as explicit arguments or deps, so it behaves the same in a backfill script. And never read one value from two sources (the contextvar in one place, the deps object in another).

## Async

- Don't block the event loop. Sync SDK, file, or network calls inside `async def` go through an async client or `asyncio.to_thread`.
- Use `asyncio.Lock` in async code, not `threading.Lock`. Before adding any lock, check that the state really is shared (see SKILL.md "One writer per piece of state").
- Clients that hold connection pools are built once in the composition root and closed on shutdown, not created per call or per property access.

## Entrypoints

Message consumers, Celery tasks, cron scripts and routes all have the same shape: parse, call, translate.

```python
async def handle(message: Message, pay_invoice: PayInvoice) -> None:
    command = PayInvoiceCommand.model_validate_json(message.value)
    try:
        await pay_invoice(InvoiceId(command.invoice_id))
    except InvoiceAlreadyPaid:
        return
    except PaymentProviderUnavailable as exc:
        raise RetryLater(delay=timedelta(seconds=30)) from exc
```

The redelivered message is a no-op because `InvoiceAlreadyPaid` is an expected outcome, not an error. Task and message payloads carry IDs and parsed values, not serialized ORM objects, which go stale between enqueue and execution.

## Package layout

- Organizing packages by domain capability (`billing/`, `reminders/`) usually keeps what changes together in one place better than packages per technical layer (`models/`, `services/`, `repositories/`). If the project is already layered, follow the layering and keep each feature cohesive within it. Converting a codebase is a decision for the user, not a side effect of a task.
- Don't create `utils.py` or `helpers.py`. Name the module after the concept it serves.
- A circular import is a design signal (see "No dependency cycles" in SKILL.md), not something to patch with function-local imports. `if TYPE_CHECKING:` imports for type-only references are fine.
