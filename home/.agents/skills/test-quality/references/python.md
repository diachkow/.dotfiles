# Python test mechanics

This document shows how to write the tests that SKILL.md approves. In an existing project, the project conventions take precedence. Consistency inside a suite is more important than these defaults.

## Shape of a test

Use the Arrange–Act–Assert pattern. Separate the parts with one blank line each. Then a reader sees the call under test immediately. Add type annotations to tests and fixtures. When a signature changes, the type checker then reports each stale fixture.

```python
def test_express_domestic_shipping_triples_base_rate() -> None:
    calculator = ShippingCalculator(base_rate=5)
    package = Package(weight_kg=2, destination="domestic", is_express=True)

    price = calculator.calculate(package)

    assert price == 15
```

Money is `Decimal`. Compare it exactly. For genuine floats, use `pytest.approx`. A raw `==` breaks after a harmless change to the operation order.

## Tables of cases

One behavior with several inputs is one `parametrize`d test. This applies especially to a threshold. Give each case a `pytest.param(..., id=...)`. Then the id sits next to its values, and a failure reports the case by its id. Properties (idempotence, round-trips) are plain asserts over such a table.

```python
@pytest.mark.parametrize(
    ("reference", "accepted"),
    [
        pytest.param("A" * 26, True, id="at-limit"),
        pytest.param("A" * 27, False, id="over-limit"),
    ],
)
def test_card_reference_longer_than_26_chars_is_rejected(reference: str, accepted: bool) -> None:
    assert is_valid_reference(reference) is accepted
```

## Fixtures and isolation

Use fixtures for setup that several tests reuse, or that is noisy. Put one-off values inline, near the assertion. Put shared fixtures in the nearest `conftest.py` that covers all their users. Build test data through real constructors and validators. `model_construct()` or an edit of `__dict__` creates states that production code cannot reach.

Use function scope by default. Use a wider scope only for expensive, read-only resources. Examples: a DB engine, a loaded model. A mutable object with a wider scope lets state leak between tests. The failures then depend on the test order.

Each test must start from a known DB state. Use a transaction that rolls back on teardown, or the cleanup method that the project already uses. Code under test that commits by itself, or opens its own connection, is not covered by a simple rollback.

Async resources are bound to an event loop. A session-scoped async engine needs a session-scoped loop. Tests that use that engine must run on that same loop:

```python
@pytest_asyncio.fixture(scope="session", loop_scope="session")
async def engine() -> AsyncIterator[AsyncEngine]: ...


@pytest.mark.asyncio(loop_scope="session")
async def test_inactive_users_are_excluded_from_count(db: AsyncSession) -> None: ...
```

Filesystem: use `tmp_path`. Do not mock file operations.

## Errors

Assert what callers branch on. Use `pytest.raises(SpecificError)`, or the status or error code of a response. Use `match=` or a full-text comparison only when the message is part of a public contract.

```python
with pytest.raises(InsufficientFundsError):
    account.withdraw(Decimal("500.00"))
```

## Faking boundaries

In order of preference:

1. **Inject it.** A parameter for the clock, a client, or an RNG needs no patching. The test then reads as plain arguments:

   ```python
   def test_token_is_rejected_after_expiry() -> None:
       token = Token(expires_at=datetime(2026, 1, 1, tzinfo=UTC))

       valid = is_token_valid(token, now=lambda: datetime(2026, 1, 2, tzinfo=UTC))

       assert valid is False
   ```

   If injection is not possible, use the time freezer that the project already has (`time-machine`, `freezegun`). Do not write a custom `datetime` subclass.

2. **Fake the transport, not your wrapper.** With `httpx`, an `httpx.MockTransport` lets your own request code (auth headers, retries, error mapping) run for real. The assertions then land on what the external service receives. If the app builds its client in a factory (base URL, auth), pass the transport into that factory. Then the factory setup runs too. Use `respx` instead if the project already has it.

   ```python
   @pytest.mark.asyncio
   async def test_blocking_a_card_notifies_the_card_service() -> None:
       sent: list[httpx.Request] = []

       def card_service(request: httpx.Request) -> httpx.Response:
           sent.append(request)
           return httpx.Response(204)

       transport = httpx.MockTransport(card_service)
       async with httpx.AsyncClient(transport=transport, base_url="https://cards.test") as client:
           await block_card(client, card_id="c-1")

       assert [(r.method, r.url.path) for r in sent] == [("PUT", "/v1/cards/c-1/block")]
   ```

3. **Patch as a last resort**, with `mocker`. Use it for third-party code that you cannot inject. Patch the name at the place where the code under test looks it up. Do not patch the place where the code defines it. Pass `autospec=True`. Then a changed signature produces a clear error:

   ```python
   mocker.patch.object(my_module.sdk, "send", autospec=True, return_value=receipt)
   ```

## Framework seams

- **FastAPI**: drive the app through `httpx.AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test")`. Replace boundary dependencies with `app.dependency_overrides`. `ASGITransport` does not run lifespan events. Start them explicitly if the app relies on them.
- **PydanticAI**: set `models.ALLOW_MODEL_REQUESTS = False` in `conftest.py`. Then no test reaches a real LLM. Use `agent.override(model=TestModel())`, or `FunctionModel` to script specific tool calls. Assert on tool effects and validated output. Do not assert on prompt text.
- **Django**: use `pytest-django` with the `django_db` mark, and the test client as the end-to-end seam. `django_assert_num_queries` pins N+1 query contracts.

## Async

Mark async tests with `@pytest.mark.asyncio`. Exception: the project sets `asyncio_mode = "auto"`. In the default strict mode, an unmarked async test does not run as intended. Async fixtures use `@pytest_asyncio.fixture`.

## How to set up pytest in a new project

Do this only when the project has no test setup yet. Otherwise obey what exists.

- Use `pytest`, plus `pytest-mock` and `pytest-asyncio` if needed. Run the tests with `uv run pytest`.
- Put the config in `pyproject.toml`. Set only what differs from the pytest defaults. Set only keys for installed plugins. An unknown key is an error or a warning. It is not a reason to add the plugin:

  ```toml
  [tool.pytest.ini_options]
  testpaths = ["tests"]
  addopts = ["-ra", "--strict-markers", "--import-mode=importlib"]
  asyncio_default_fixture_loop_scope = "function"
  ```

  `--strict-markers` turns a marker with a typo into an error. Without it, pytest silently ignores that filter. `--import-mode=importlib` lets test files share a basename across directories, without `__init__.py` files. The trade-off: test modules cannot import each other. Put shared helpers in `conftest.py`. With `uv`, the project is already importable, so `pythonpath` is unnecessary.
- Let `tests/` mirror the package. Then a person can find the tests for a module without a search:

  ```
  my_project/nested/module.py   ->  tests/nested/test_module.py
  my_project/main.py            ->  tests/test_main.py
  ```
- Test settings: env-loading plugins (`pytest-env`, `pytest-dotenv`) set only the variables that they list. Any other variable that the shell defines leaks into the test run. Real credentials are one example. Make settings that point at external systems fail closed in tests. Fail closed means: reject the operation when the external system is not available.
