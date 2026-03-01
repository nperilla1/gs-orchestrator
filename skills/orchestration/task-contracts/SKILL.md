---
name: task-contracts
description: "Define provides/consumes contracts between tasks to prevent hidden dependencies and enable parallel execution. Triggers when decomposing work into subtasks, coordinating multi-agent work, managing task dependencies, or when tasks fail due to missing prerequisites."
version: "1.0"
---

# Task Contracts Skill

Every task must declare what it produces and what it consumes. No hidden dependencies. No implicit state. If a task needs something, it says so upfront. If it produces something, it declares the shape.

## When to Use

- When breaking a large feature into subtasks
- When multiple agents or sessions will work on related code
- When a task fails because a prerequisite wasn't met
- When you need to identify which tasks can run in parallel
- During the **planning** skill when sequencing steps

## Contract Structure

Every task gets a contract block:

```yaml
task: "create-organization-api"
consumes:
  - name: "Organization SQLAlchemy model"
    source: "src/writer/models/organization.py"
    type: file
    required: true
    shape: "class Organization(Base) with id, name, ein, state fields"
  - name: "Database session factory"
    source: "src/writer/core/database.py"
    type: function
    required: true
    shape: "async def get_session() -> AsyncSession"
provides:
  - name: "Organization CRUD endpoints"
    target: "src/writer/api/routes/organizations.py"
    type: file
    shape: "FastAPI router with GET/POST/PUT/DELETE /organizations"
  - name: "Organization repository"
    target: "src/writer/repositories/organization.py"
    type: file
    shape: "class OrganizationRepository with create/read/update/delete/list methods"
```

## Contract Types

### File Contract
The task needs or produces a file at a specific path.

```yaml
- name: "User model"
  source: "src/auth/models/user.py"  # or target for provides
  type: file
  required: true
  shape: "SQLAlchemy model with id, email, hashed_password, role"
```

### Function Contract
The task needs or produces a specific function/class.

```yaml
- name: "JWT token generator"
  source: "src/auth/services/tokens.py::create_access_token"
  type: function
  required: true
  shape: "(user_id: UUID, role: str) -> str"
```

### Data Contract
The task needs or produces data in a specific shape (DB rows, API responses).

```yaml
- name: "System prompts in DB"
  source: "writer.system_prompts table"
  type: data
  required: true
  shape: "Rows with prompt_name, system_message, is_active columns"
```

### State Contract
The task needs the system to be in a certain state.

```yaml
- name: "Database migrations applied"
  source: "alembic"
  type: state
  required: true
  shape: "All migrations up to head applied to writer schema"
```

## Using Contracts

### Before Starting a Task

1. Read the task's `consumes` list
2. Verify each consumed item exists and matches the expected shape
3. If anything is missing, STOP — do not proceed with partial dependencies
4. Report: "Task X is blocked — missing: [list of unsatisfied consumes]"

### After Completing a Task

1. Verify each item in `provides` was actually created
2. Check that the shape matches what was declared
3. Run tests that exercise the provided interfaces
4. Mark the task as completed only if ALL provides are satisfied

### Identifying Parallelism

Tasks can run in parallel if and only if:
- They do NOT consume each other's provides
- They do NOT modify the same files
- They do NOT have ordering constraints

Build a dependency graph:

```
Task A provides X
Task B provides Y
Task C consumes X and Y

A ──┐
    ├──> C
B ──┘

A and B can run in parallel. C must wait for both.
```

### Resolving Conflicts

If two tasks provide the same file:
- They CANNOT run in parallel
- Sequence them: the second task consumes the first task's output
- Consider merging them into one task

If a circular dependency exists (A consumes B's output, B consumes A's output):
- Break the cycle by extracting shared interfaces
- Create a "contract interface" task that both consume

## Contract Validation Checklist

Before executing any task, verify:

- [ ] All `consumes` items exist at the declared paths
- [ ] All `consumes` items match the expected `shape`
- [ ] No two active tasks provide the same file
- [ ] The dependency graph has no cycles
- [ ] Parallel tasks have been identified and marked

## Example: Multi-Task Feature

```yaml
# Task 1
task: "add-organization-model"
consumes:
  - name: "Base model class"
    source: "src/writer/models/base.py"
    type: file
    required: true
provides:
  - name: "Organization model"
    target: "src/writer/models/organization.py"
    type: file
    shape: "class Organization(Base) with UUID pk, name, ein, state, created_at"

# Task 2 (PARALLEL with Task 1)
task: "add-organization-schemas"
consumes: []
provides:
  - name: "Organization Pydantic schemas"
    target: "src/writer/schemas/organization.py"
    type: file
    shape: "OrganizationCreate, OrganizationUpdate, OrganizationResponse"

# Task 3 (DEPENDS on Task 1)
task: "add-organization-repository"
consumes:
  - name: "Organization model"
    source: "src/writer/models/organization.py"
    type: file
    required: true
provides:
  - name: "Organization repository"
    target: "src/writer/repositories/organization.py"
    type: file

# Task 4 (DEPENDS on Task 2 and Task 3)
task: "add-organization-routes"
consumes:
  - name: "Organization schemas"
    source: "src/writer/schemas/organization.py"
    type: file
    required: true
  - name: "Organization repository"
    source: "src/writer/repositories/organization.py"
    type: file
    required: true
provides:
  - name: "Organization API routes"
    target: "src/writer/api/routes/organizations.py"
    type: file
```

Execution order: Tasks 1 and 2 in parallel, then Task 3, then Task 4.
