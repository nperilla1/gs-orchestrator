---
name: writing-claude-md
description: How to structure and optimize CLAUDE.md files for Claude Code projects. Covers required sections (project overview, tech stack, key commands, architecture decisions, gotchas, testing conventions), line count targets (under 500 lines), progressive disclosure via linked files, when and what to update, common anti-patterns (too long, too detailed, stale information), and templates for different project types (Python backend, frontend app, monorepo, data pipeline). CLAUDE.md loads every session so every line costs tokens -- optimize ruthlessly. Use when creating CLAUDE.md for new projects or improving existing ones.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Writing CLAUDE.md Files

You are creating or improving a CLAUDE.md file for a project. CLAUDE.md is the primary context file that Claude Code loads every session, so every line matters.

## Target
$ARGUMENTS
(The project to create/improve CLAUDE.md for)

## Core Principle

**CLAUDE.md loads every session. Every unnecessary line wastes tokens across every conversation.** Optimize ruthlessly. Put details in separate files and link to them.

## Required Sections

### 1. Project Overview (5-10 lines)

What is this project? What does it do? What stage is it in?

```markdown
# Project Name

AI-powered grant writing platform. Analyzes NOFOs, builds strategy, writes narratives.
Currently rebuilding from n8n workflows to clean Python/Temporal architecture.

**Status:** Writer agent complete (65 tests), watcher in progress.
```

### 2. Tech Stack (table format)

```markdown
## Stack
| Layer | Technology |
|-------|-----------|
| Language | Python 3.12 |
| Framework | FastAPI + Pydantic 2 |
| Database | PostgreSQL 16 + pgvector (async SQLAlchemy 2.0) |
| Orchestration | Temporal |
| Testing | pytest-asyncio, hypothesis |
| Linting | ruff |
```

### 3. Key Commands (the ones you actually run)

```markdown
## Commands
```bash
pytest tests/ -x -q              # Run tests (stop on first failure)
ruff check src/ --fix             # Lint and auto-fix
ruff format src/                  # Format
alembic upgrade head              # Run migrations
uvicorn src.api.app:app --reload  # Start dev server
```
```

### 4. Architecture Decisions (ADR-lite)

Only the decisions that affect daily coding. Not a history book.

```markdown
## Architecture
- Repository pattern with raw SQL (not ORM) -- see `src/repositories/`
- Pydantic models for domain objects, SQLAlchemy for schema only
- Async everywhere -- never use sync database calls
- JSONB columns validated via Pydantic before writes
- Prompts loaded from DB with file fallback
```

### 5. Gotchas (things that waste time without warning)

```markdown
## Gotchas
- pgvector returns embeddings as strings -- must `json.loads()` before Pydantic
- asyncpg can't serialize dicts to jsonb -- use `json.dumps()` + `CAST`
- `get_connection()` without `conn.commit()` = silent data loss
- ruff TCH rules DISABLED -- fights with SQLAlchemy runtime imports
```

### 6. Testing Conventions

```markdown
## Testing
- All tests in `tests/` mirror `src/` structure
- Fixtures in `tests/conftest.py`
- Use `pytest.mark.asyncio` for async tests
- Mock external services, never call them in tests
- 65 tests currently, all passing
```

### 7. Links to Detailed Docs (progressive disclosure)

```markdown
## Detailed Docs
- [Database schema](docs/schema.md)
- [API endpoints](docs/api.md)
- [Prompt system](docs/prompts.md)
- [Deployment guide](docs/deploy.md)
```

## Size Targets

| Project Type | Target Lines | Why |
|---|---|---|
| Small library | 50-100 | Few decisions, simple stack |
| Backend service | 150-300 | More architecture, more gotchas |
| Full application | 300-500 | Multiple subsystems |
| Monorepo | 200-400 | Overview + links to per-package docs |

**Hard limit: 500 lines.** If you need more, split into linked files.

## Templates

### Python Backend Template

```markdown
# [Project Name]

[1-2 sentence description]

## Stack
| Layer | Technology |
|-------|-----------|
| ... | ... |

## Commands
[5-8 most used commands]

## Architecture
[5-10 bullet points of key decisions]

## Database
- Schema: `[schema_name]`
- Connection: [how to connect]
- Migrations: `alembic upgrade head`

## Gotchas
[3-7 things that trip people up]

## Testing
[conventions, how to run, current count]

## See Also
[links to detailed docs]
```

### Frontend App Template

```markdown
# [Project Name]

[1-2 sentence description]

## Stack
[framework, styling, components, state, animation]

## Commands
[dev, build, lint, test]

## Structure
[key directories and what they contain]

## Design System
[aesthetic direction, color tokens, fonts]
[link to design brief if it exists]

## Conventions
[component patterns, naming, state management approach]

## See Also
[links to design brief, component docs]
```

## When to Update CLAUDE.md

Update after:
- Major architecture decisions
- New gotchas discovered
- Test count changes significantly
- New commands become important
- Stack changes (new library, framework upgrade)

Do NOT update for:
- Individual bug fixes
- Minor refactors
- Each new file added
- Temporary state changes

## Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|---|---|---|
| Pasting full file contents | Wastes tokens every session | Link to the file instead |
| Changelog/history section | Stale quickly, use git | Remove, use git log |
| TODO lists | Stale quickly, use issues | Move to GitHub Issues |
| Detailed API docs | Too long for CLAUDE.md | Put in `docs/api.md` |
| Environment variable values | Security risk | Document names only, not values |
| Repeating info from README | Duplication | CLAUDE.md is for Claude, README is for humans |
| Over 500 lines | Token waste every session | Split into linked files |
