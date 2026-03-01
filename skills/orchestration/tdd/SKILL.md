---
name: tdd
description: "Strict RED-GREEN-REFACTOR test-driven development enforcement. Triggers when writing new features with tests, implementing from a spec, when the user says 'TDD', 'test first', 'write tests before code', or when building any code that needs high reliability."
version: "1.0"
---

# TDD Skill

You are in strict Test-Driven Development mode. The test comes FIRST. Always. No exceptions.

## When to Use

- When implementing any new feature or function
- When the user says "TDD", "test first", "test-driven"
- When building code that needs high reliability (data access, business logic, security)
- During the GREEN phase of **executing-plans** when steps specify test-first approach

## The Cycle

### RED: Write a Failing Test

1. **Create the test file** (or add to existing test file)
2. **Write a test that describes the desired behavior** — not the implementation
3. **Run the test** — it MUST fail
4. **Verify it fails for the RIGHT reason** — `ImportError` or `NameError` means the implementation doesn't exist yet (good). A test that passes immediately is not a RED test.

```python
# tests/test_organization_repo.py
import pytest
from writer.repositories.organization import OrganizationRepository

@pytest.mark.asyncio
async def test_create_organization_returns_id(db_session):
    repo = OrganizationRepository(db_session)
    org = await repo.create(name="Test Org", ein="12-3456789", state="NY")
    assert org.id is not None
    assert org.name == "Test Org"
```

Run: `pytest tests/test_organization_repo.py::test_create_organization_returns_id -v`
Expected: FAIL (module doesn't exist yet)

Rules for RED phase:
- Write ONE test at a time — not the entire test suite
- The test must be specific — test one behavior, not "test everything"
- Test names describe behavior: `test_create_organization_returns_id`, NOT `test_create`
- Do NOT write implementation code during RED phase

### GREEN: Write Minimum Code to Pass

1. **Write the minimum implementation** that makes the test pass
2. **Do NOT write more than needed** — resist the urge to add features the test doesn't require
3. **Run the test** — it MUST pass
4. **Run the full test suite** — no regressions

```python
# src/writer/repositories/organization.py
class OrganizationRepository:
    def __init__(self, session):
        self.session = session

    async def create(self, name: str, ein: str, state: str):
        # Minimum implementation to pass the test
        query = text("""
            INSERT INTO writer.organizations (name, ein, state)
            VALUES (:name, :ein, :state)
            RETURNING id, name, ein, state
        """)
        result = await self.session.execute(query, {"name": name, "ein": ein, "state": state})
        return result.fetchone()
```

Run: `pytest tests/test_organization_repo.py::test_create_organization_returns_id -v`
Expected: PASS

Rules for GREEN phase:
- Test files are READ-ONLY during GREEN phase — do not modify tests to make them pass
- Write the simplest code that passes — hardcoded values are acceptable if the test only checks one case
- If you need to modify the test, go back to RED phase
- Do NOT add error handling, validation, or optimization — those come from future RED tests

### REFACTOR: Clean Up

1. **Review the code** you just wrote in GREEN phase
2. **Improve structure** without changing behavior:
   - Extract common patterns
   - Improve naming
   - Remove duplication
   - Add type annotations
3. **Run all tests** — they must still pass after refactoring
4. **Run linter** — clean up any issues

Rules for REFACTOR phase:
- Tests must pass before AND after refactoring
- Do NOT add new functionality during refactoring
- If refactoring breaks a test, you've changed behavior — revert and try again
- This is the ONLY phase where you can modify both test and implementation (for cleanup only)

## Cycle Cadence

```
RED   → Write test_create_organization_returns_id    → FAIL
GREEN → Implement create() method                     → PASS
REFACTOR → Clean up, add type hints                   → PASS

RED   → Write test_create_organization_validates_ein  → FAIL
GREEN → Add EIN validation                            → PASS
REFACTOR → Extract validation to helper               → PASS

RED   → Write test_create_organization_duplicate_name → FAIL
GREEN → Add unique constraint handling                → PASS
REFACTOR → Consolidate error handling                  → PASS
```

Each cycle adds ONE behavior. The implementation grows incrementally.

## Testing Tools

**Python**: pytest + pytest-asyncio
```bash
# Run single test
pytest tests/test_file.py::test_name -v

# Run test file
pytest tests/test_file.py -v

# Run all tests
pytest --tb=short -q

# Run with coverage
pytest --cov=src/writer --cov-report=term-missing
```

**TypeScript**: vitest
```bash
# Run single test
npx vitest run tests/file.test.ts -t "test name"

# Run test file
npx vitest run tests/file.test.ts

# Run all tests
npx vitest run
```

## Test Quality Checklist

Before moving from RED to GREEN, verify the test:

- [ ] Tests ONE specific behavior (not multiple behaviors in one test)
- [ ] Has a descriptive name that explains the expected behavior
- [ ] Uses descriptive assertion messages where helpful
- [ ] Does not depend on other tests (can run in isolation)
- [ ] Cleans up after itself (no leftover DB state, files, etc.)
- [ ] Fails for the RIGHT reason (not an import error from a typo)

## Anti-Patterns

- **Writing implementation first** — "I'll add tests later" means tests never get written, or they're written to match the implementation rather than the spec
- **Testing implementation details** — Test WHAT it does, not HOW it does it. Don't assert on internal method calls.
- **Test suite runs slow** — Each test should run in <1 second. Mock external calls.
- **Skipping REFACTOR** — The code will accumulate mess. Refactor every cycle.
- **Giant RED phase** — Writing 20 tests before any GREEN. Write ONE test, make it pass, repeat.
- **Modifying tests in GREEN** — If the test is wrong, go back to RED. Do not adjust tests to match your implementation.
