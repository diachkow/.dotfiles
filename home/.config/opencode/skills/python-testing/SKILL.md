---
name: python-testing
description: This skill describes modern practices for writing automated tests in Python. Use this whenever you are about to add unit/automated/e2e test to any application.
---

# Testing in Python: Best Practices

- Always use `pytest` for writing automated tests in Python.
- Store the config for `pytest` in `pyproject.toml` file under `[tool.pytest.ini_options]` key. Sample config:
```toml
[tool.pytest.ini_options]
testpaths = "./tests"
addopts = "-v"
python_classes = "Test*"
python_files = "test_*.py"
python_functions = "test_*"
env_override_existing_values = 1
env_files = ".env.test"
asyncio_default_fixture_loop_scope = "function"
pythonpath = ["./src"]  # only if project is using src/ layout
```
- Tests shall live under `tests/` directory that is next to the project source. The structure of the tests shall mirror the original project structure. For example:
```
root/
|__ my_project/
|  |__ nested_package/
|  |  |__ __init__.py
|  |  |__ module.py
|  |  |__ another_module.py
|  |__ main.py
|__ tests/
|  |__ conftest.py
|  |__ nested_package/
|  |  |__ test_module.py
|  |  |__ test_another_module.py
|  |__ test_main.py
```
- Write tests following Arrange-Act-Assert pattern. Use empty lines to separate each block, e.g. one empty line between Arrange and Act blocks and one empty line between Act and Assert blocks:
```python
def test_shipping_calculator_returns_express_price() -> None:
    calculator = ShippingCalculator(base_rate=5)
    package = Package(weight_kg=2, destination="domestic", is_express=True)

    total_price = calculator.calculate(package)

    assert total_price == 15
```
- Always use `pytest` fixtures to create re-usable test values. When adding fixtures to test cases, always use type annotations:
```python
import pytest

@pytest.fixture(scope="session")
def tax_calculator() -> TaxCalculator:
    return TaxCalculator(standard_rate=0.2)

@pytest.fixture()
def order() -> Order:
    return Order(subtotal=100.0, customer_country="DE")


def test_calculate_total_with_tax(
    tax_calculator: TaxCalculator,
    order: Order,
) -> None:
    total = tax_calculator.total_with_tax(order.subtotal)

    assert total == 120.0
```
- Group related tests into test classes. Use class-scoped fixtures for re-usable test objects:
```python
class TestNotificationService:
    @pytest.fixture(scope="class")
    def service(self) -> NotificationService:
        return NotificationService()

    def test_send_welcome_email_marks_message_as_sent(self, service: NotificationService) -> None:
        recipient = User(email="alex@example.com", name="Alex")

        message = service.send_welcome_email(recipient)

        assert message.status == "sent"

    def test_queue_digest_creates_background_job(self, service: NotificationService) -> None:
        payload = {"user_id": "u-123", "frequency": "weekly"}

        job = service.queue_digest(payload)

        assert job.started()
```
- Use `pytest_mock` that provides `unittest.mock` functionality via `mocker` fixture to `pytest` test cases:
```python
# src/my_module.py
import random

def calculate_price(quantity: int) -> int:
    discount = random_discount_percent()
    return quantity * (100 - discount)

def random_discount_percent() -> int:
    return random.randint(1, 10)

# tests/test_my_module.py
import my_module
from pytest_mock import MockerFixture


def test_calculate_price(mocker: MockerFixture) -> None:
    mocker.patch.object(
        my_module,
        # RULE: always use `.__name__` attribute for mocking
        # functions/methods instead of literal strings, e.g.
        # `"random_discount_percent"` in this case.
        my_module.random_discount_percent.__name__,
        # Always prefer using `return_value=`, `side_effect=`
        # arguments in `mocker.patch()` and `mocker.patch.object()`
        # If necessary, create mock objects via `mocker.create_autospec()`
        return_value=5,
    )

    result = my_module.calculate_price(2)

    assert result == 190
```
- When testing asynchronous code, use `pytest-asyncio` library and `@pytest.mark.asyncio` mark:
```python
# src/my_module.py
async def fetch_active_user_count() -> int:
    return 42

# tests/test_my_module.py
import pytest

import my_module


@pytest.mark.asyncio
async def test_fetch_active_user_count() -> None:
    result = await my_module.fetch_active_user_count()

    assert result == 42
```
