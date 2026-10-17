# Python test mechanics

How to write the tests SKILL.md says are worth having. In an existing project, its conventions win — consistency inside a suite beats these defaults.

## Shape of a test

Arrange–Act–Assert, separated by single blank lines, so the call under test is visible at a glance. Type-annotate tests and fixtures; stale fixtures then surface when signatures change.

```python
def test_express_domestic_shipping_triples_base_rate() -> None:
    calculator = ShippingCalculator(base_rate=5)
    package = Package(weight_kg=2, destination="domestic", is_express=True)

    price = calculator.calculate(package)

    assert price == 15
```

Money is `Decimal`, compared exactly. Genuine floats use `pytest.approx`; raw `==` breaks on harmless changes to operation order.

## Tables of cases

One behavior with several inputs — especially a threshold — is one `parametrize`d test, with each case a `pytest.param(..., id=...)` so the id sits next to its values and failures read as facts. Properties (idempotence, round-trips) are plain asserts over such a table.

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

Fixtures are for setup that's reused or noisy; one-off values read better inline next to the assertion. Put shared fixtures in the nearest `conftest.py` covering all their users. Build test data through real constructors and validators — `model_construct()` or editing `__dict__` creates states production can't reach.

Default to function scope. Wider scopes suit expensive, read-only resources (a DB engine, a loaded model); a wider-scoped mutable object leaks state between tests and makes failures order-dependent.

Each test should start from a known DB state: a transaction rolled back on teardown, or whatever cleanup the project already uses. Code under test that commits on its own or opens its own connection escapes a simple rollback.

Async resources are bound to an event loop. A session-scoped async engine needs a session-scoped loop, and tests using it must run on that same loop:

```python
@pytest_asyncio.fixture(scope="session", loop_scope="session")
async def engine() -> AsyncIterator[AsyncEngine]: ...


@pytest.mark.asyncio(loop_scope="session")
async def test_inactive_users_are_excluded_from_count(db: AsyncSession) -> None: ...
```

Filesystem: use `tmp_path` rather than mocking file calls.

## Errors

Assert what callers branch on: `pytest.raises(SpecificError)`, or the status / error code of a response. Use `match=` or full-text comparison only when the message is part of a public contract.

```python
with pytest.raises(InsufficientFundsError):
    account.withdraw(Decimal("500.00"))
```

## Faking boundaries

In order of preference:

1. **Inject it.** A parameter for the clock, client, or RNG needs no patching, and the test reads as plain arguments:

   ```python
   def test_token_is_rejected_after_expiry() -> None:
       token = Token(expires_at=datetime(2026, 1, 1, tzinfo=UTC))

       valid = is_token_valid(token, now=lambda: datetime(2026, 1, 2, tzinfo=UTC))

       assert valid is False
   ```

   If injection isn't possible, use the time freezer the project already has (`time-machine`, `freezegun`) rather than a hand-rolled `datetime` subclass.

2. **Fake the transport, not your wrapper.** With `httpx`, an `httpx.MockTransport` lets your own request code (auth headers, retries, error mapping) run for real, and assertions land on what the external service receives. If the app builds its client in a factory (base URL, auth), pass the transport into that factory so its setup runs too. Use `respx` instead if the project already has it.

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

3. **Patch, as a last resort**, with `mocker` — for third-party code you can't inject. Patch where the name is looked up, not where it's defined, and pass `autospec=True` so a changed signature fails loudly:

   ```python
   mocker.patch.object(my_module.sdk, "send", autospec=True, return_value=receipt)
   ```

## Framework seams

- **FastAPI**: drive the app through `httpx.AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test")` and swap boundary dependencies with `app.dependency_overrides`. `ASGITransport` doesn't run lifespan events; start them explicitly if the app relies on them.
- **PydanticAI**: set `models.ALLOW_MODEL_REQUESTS = False` in `conftest.py` so no test reaches a real LLM; use `agent.override(model=TestModel())`, or `FunctionModel` to script specific tool calls. Assert on tool effects and validated output, not prompt text.
- **Django**: `pytest-django` with the `django_db` mark and the test client as the end-to-end seam; `django_assert_num_queries` pins N+1 query contracts.

## Async

Mark async tests with `@pytest.mark.asyncio` unless the project sets `asyncio_mode = "auto"` — in the default strict mode an unmarked async test doesn't run as intended. Async fixtures use `@pytest_asyncio.fixture`.

## Setting up pytest in a new project

Only when the project has no test setup yet; otherwise follow what exists.

- `pytest`, plus `pytest-mock` and `pytest-asyncio` if needed. Run with `uv run pytest`.
- Config in `pyproject.toml`, setting only what differs from pytest defaults and only keys for plugins actually installed — an unknown key is an error or warning, not a reason to add the plugin:

  ```toml
  [tool.pytest.ini_options]
  testpaths = ["tests"]
  addopts = ["-ra", "--strict-markers", "--import-mode=importlib"]
  asyncio_default_fixture_loop_scope = "function"
  ```

  `--strict-markers` turns a typo'd marker into an error instead of a silently ignored filter. `--import-mode=importlib` lets test files share a basename across directories without `__init__.py` files; the trade-off is that test modules can't import each other, so shared helpers live in `conftest.py`. With `uv` the project is installed, so `pythonpath` is unnecessary.
- `tests/` mirrors the package so a module's tests are findable without searching:

  ```
  my_project/nested/module.py   ->  tests/nested/test_module.py
  my_project/main.py            ->  tests/test_main.py
  ```
- Test settings: env-loading plugins (`pytest-env`, `pytest-dotenv`) set only the variables they list — anything else inherited from the shell, including real credentials, still leaks in. Make settings that point at external systems fail closed in tests.
