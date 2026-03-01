---
name: greenfield-pipeline
description: "Full pipeline for building new projects from zero to deployed, covering requirements through deployment. Triggers when starting a brand new project, creating a new service from scratch, scaffolding a new codebase, or when the user says 'new project', 'start from scratch', or 'bootstrap'."
version: "1.0"
---

# Greenfield Pipeline Skill

You are building a new project from zero. Follow these phases in order. Each phase has entry criteria (what must exist before starting) and exit criteria (what must be true before moving on). Do NOT skip phases.

## When to Use

- Starting a completely new project or service
- Building a new microservice or package from scratch
- The user says "new project", "start fresh", "bootstrap", "scaffold"
- When there's no existing code to build on

## The 10 Phases

### Phase 1: Requirements Gathering

**Entry**: User has described what they want to build.
**Process**:
1. Invoke the **brainstorming** skill to fully explore the problem
2. Define functional requirements (what it MUST do)
3. Define non-functional requirements (performance, scale, security)
4. Define out-of-scope items explicitly
5. Identify integration points (databases, APIs, other services)

**Exit**: A requirements document with acceptance criteria for every requirement. User has confirmed the requirements.

### Phase 2: Technology Selection

**Entry**: Confirmed requirements.
**Process**:
1. For each major component, evaluate technology options
2. Check compatibility with existing GS stack (Python 3.12, SQLAlchemy 2.0, FastAPI, Pydantic V2)
3. Use Context7 MCP to verify library APIs if using anything unfamiliar
4. Document choices and rationale

**Exit**: Technology decisions documented. No "we'll decide later" items.

**GS Standard Stack** (prefer these unless there's a specific reason not to):
- Python 3.12, hatchling build
- FastAPI + uvicorn
- SQLAlchemy 2.0 async ORM
- Pydantic V2 for schemas/settings
- Alembic for migrations
- pytest + pytest-asyncio for testing
- ruff for linting
- structlog for logging

### Phase 3: Architecture Design

**Entry**: Technology choices made.
**Process**:
1. Define the module structure (which packages, what goes where)
2. Define the data flow (request -> route -> service -> repo -> DB)
3. Define external interfaces (API contracts, event schemas)
4. Identify shared code vs. project-specific code
5. Draw the dependency graph between modules

**Exit**: Module structure defined. No circular dependencies. Clear separation of concerns.

### Phase 4: Project Scaffolding

**Entry**: Architecture design.
**Process**:
1. Create the directory structure:
   ```
   project-name/
   ├── src/project_name/
   │   ├── __init__.py
   │   ├── api/
   │   │   ├── __init__.py
   │   │   ├── app.py
   │   │   └── routes/
   │   ├── models/
   │   ├── schemas/
   │   ├── services/
   │   ├── repositories/
   │   └── core/
   │       ├── config.py
   │       └── database.py
   ├── tests/
   ├── alembic/
   ├── pyproject.toml
   ├── alembic.ini
   └── .env.example
   ```
2. Create `pyproject.toml` with dependencies
3. Create config with Pydantic Settings (`env_file=("../.env.shared", ".env")`)
4. Create database module with async session factory
5. Set up Alembic with schema-scoped migrations
6. Create virtual environment and install dependencies

**Exit**: `python -c "import project_name"` works. Virtual environment created. Alembic initialized.

### Phase 5: Core Data Model

**Entry**: Working project scaffold.
**Process**:
1. Define SQLAlchemy models for all entities
2. Set `schema="project_name"` in `Base.__table_args__`
3. Add cross-schema FKs with `use_alter=True` where needed
4. Create initial Alembic migration
5. Run migration against database (or test DB)
6. Write model tests

**Exit**: All tables created. Migration applies cleanly. Model tests pass.

### Phase 6: API Layer

**Entry**: Data model in place.
**Process**:
1. Define Pydantic request/response schemas
2. Create repository classes (data access layer)
3. Create FastAPI route files
4. Wire up the app with routers
5. Add authentication middleware (gs-auth shared library)
6. Write API tests

**Exit**: All CRUD endpoints work. Tests pass. Auth is enforced.

### Phase 7: Business Logic

**Entry**: API layer working.
**Process**:
1. Implement service classes with domain logic
2. Add validation beyond basic Pydantic (business rules)
3. Implement any background tasks or workflows
4. Add error handling with proper HTTP status codes
5. Write unit tests for all business logic

**Exit**: All business logic implemented and tested. Edge cases covered.

### Phase 8: Testing

**Entry**: Business logic implemented.
**Process**:
1. Review test coverage — aim for 80%+ on business logic
2. Add integration tests (API -> DB roundtrips)
3. Add edge case tests (empty data, max limits, concurrent access)
4. Run full test suite: `pytest --tb=short -q`
5. Run linter: `ruff check src/ tests/`
6. Fix all failures and lint issues

**Exit**: All tests pass. Lint is clean. Coverage meets target.

### Phase 9: Frontend (if applicable)

**Entry**: API is stable and tested.
**Process**:
1. Scaffold frontend (React 18 + TypeScript + Vite)
2. Create API client layer
3. Build components for each feature
4. Add loading states, error handling, empty states
5. Consult **frontend-aesthetics** agent for styling review
6. Write component tests

**Exit**: Frontend connects to API. All features accessible. No console errors.

### Phase 10: Deployment Config

**Entry**: All code working and tested.
**Process**:
1. Create Dockerfile
2. Create docker-compose.yml (or add to existing)
3. Document environment variables
4. Add health check endpoint (`GET /health`)
5. Configure logging for production
6. Test docker build and run

**Exit**: `docker compose up` starts the service. Health check returns 200. Logs are structured.

## Phase Transition Protocol

At the end of each phase:
1. Verify all exit criteria are met
2. Report to user: "Phase N complete. [summary]. Ready for Phase N+1?"
3. Wait for user confirmation
4. If exit criteria not met, list what's missing and fix before moving on

## Shortcuts

For small projects, phases can be compressed:
- Phases 1-3 can be combined if the project is simple and well-understood
- Phase 9 can be skipped if the project is backend-only
- Phase 10 can be deferred if deploying to an existing infrastructure

State which phases you're combining and why.
