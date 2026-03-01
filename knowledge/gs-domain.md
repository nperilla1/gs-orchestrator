# GS Domain Knowledge -- Gotchas, Patterns, and Reference

Production-hardened knowledge about the GrantSmiths platform. Everything here has been learned from real bugs, real production incidents, and real debugging sessions.

## Database Gotchas

### pgvector Returns Strings

pgvector stores embeddings as `vector(1536)` but returns them as strings when queried via asyncpg:

```python
# WRONG: Pydantic receives a string, fails validation
row = await conn.fetchrow("SELECT embedding FROM rag.embeddings WHERE id = $1", id)
# row['embedding'] is a string like "[0.123, -0.456, ...]"

# RIGHT: Parse the string before constructing the model
import json
embedding = json.loads(row['embedding'])
model = EmbeddingRecord(embedding=embedding, **other_fields)
```

### asyncpg Dict-to-JSONB Serialization

asyncpg cannot serialize Python dicts to PostgreSQL JSONB columns:

```python
# WRONG: asyncpg raises "cannot serialize dict"
await conn.execute(
    "INSERT INTO writer.project_artifacts (metadata) VALUES ($1)",
    {"key": "value"}
)

# RIGHT: json.dumps() + CAST in SQL
import json
await conn.execute(
    "INSERT INTO writer.project_artifacts (metadata) VALUES (CAST($1 AS jsonb))",
    json.dumps({"key": "value"})
)
```

### asyncpg NULL Parameter Typing

asyncpg cannot infer the type of NULL parameters in conditional expressions:

```sql
-- WRONG: asyncpg raises "could not determine data type of parameter $1"
WHERE (:param IS NULL OR col = :param)

-- RIGHT: Explicit CAST tells asyncpg the type
WHERE (CAST(:param AS uuid) IS NULL OR col = :param)
```

### Silent Data Loss with get_connection()

Using `get_connection()` instead of `get_transaction()` for writes causes silent data loss because there is no implicit commit:

```python
# WRONG: Data is written to the connection but never committed
async with db.get_connection() as conn:
    await conn.execute("INSERT INTO ...")  # Silent data loss

# RIGHT: Auto-commits on success, rolls back on error
async with db.get_transaction() as conn:
    await conn.execute("INSERT INTO ...")  # Committed automatically
```

### Embedding Dimensions

| Model | Default Dimensions | Notes |
|-------|-------------------|-------|
| text-embedding-3-small | 1536 | Correct, no extra params needed |
| text-embedding-3-large | 3072 | Must pass `dimensions=1536` to match DB columns |

All `vector(1536)` columns in gs_unified expect 1536 dimensions. Using a 3072-dim embedding will cause a dimension mismatch error.

### Memory Retriever NULL Embeddings

Cosine similarity on NULL vectors throws a runtime error:

```sql
-- WRONG: Rows with NULL embedding cause "cannot compute similarity of NULL vectors"
SELECT *, 1 - (embedding <=> $1::vector) as similarity
FROM gsbot.memories
ORDER BY embedding <=> $1::vector

-- RIGHT: Filter out NULLs first
SELECT *, 1 - (embedding <=> $1::vector) as similarity
FROM gsbot.memories
WHERE embedding IS NOT NULL
ORDER BY embedding <=> $1::vector
```

## Pydantic V2 Gotchas

### Silent Field Dropping

Pydantic V2 drops unknown fields by default. If user identity or metadata is passed through an API chain, it can be silently lost:

```python
# WRONG: Extra fields are dropped
class WriterRequest(BaseModel):
    section_id: UUID
    content: str
# If the API sends {"section_id": ..., "content": ..., "user_id": ...}, user_id is lost

# RIGHT: Include all fields that flow through the chain
class WriterRequest(BaseModel):
    section_id: UUID
    content: str
    user_id: UUID | None = None
```

### Structured Output with Large Prompts

When system prompts exceed ~50K characters, Sonnet tends to return empty list fields in structured output. The model's attention is overwhelmed by the prompt volume.

**Solution**: Use the V1-to-V2 prompt migration that strips OUTPUT FORMAT sections from prompts and relies on `default_factory=list` with `ModelRetry` in Pydantic:

```python
class SectionAnalysis(BaseModel):
    requirements: list[Requirement] = Field(default_factory=list)
    evidence: list[Evidence] = Field(default_factory=list)
```

This reduced total prompt size from 489K to ~383K characters.

## The Grant/Project Hierarchy

This is the core data model. Understanding it prevents data modeling mistakes.

```
crm.organizations (22,348 rows)
    |
    +-- crm.contacts (63,664)
    |
    +-- crm.projects (98)
         | organization_id + grant_id
         |
         +-- crm.grants (79)
         |
         +-- writer.grant_instances (11) -- analyzed ONCE per NOFO
         |    +-- writer.grant_sections
         |    +-- writer.grant_requirements
         |    +-- writer.grant_prompts
         |
         +-- writer.project_instances (15) -- per org applying to a grant
              +-- writer.project_sections (133)
              +-- writer.project_requirements
              +-- writer.project_artifacts
              +-- writer.project_documents
              +-- writer.project_prompts
```

**Key distinction:**
- **Grant instance** = analyzed ONCE per NOFO, reused by all projects applying to it
- **Project instance** = per organization applying to a grant, with their specific evidence/strategy/drafts

Do NOT conflate these. A requirement from `grant_requirements` is the funder's ask. A requirement from `project_requirements` is how the applicant addresses it.

## The Evidence Chain of Custody

This is the integrity model for grant writing. Every claim in a grant narrative must trace back to real evidence.

```
requirement_fulfiller (GATHER)
  "Find evidence, don't invent it"
  Sources: RAG, organization documents, CRM data
      |
      v
section_strategist (ASSESS)
  "Map evidence to requirements, tier it by strength"
  Tiers: Strong (quantitative), Moderate (qualitative), Weak (anecdotal)
      |
      v
section_writer (DEPLOY)
  "Use ONLY provided evidence. Never fabricate."
  Every claim must cite a source from the ASSESS phase
      |
      v
section_reviewer (VERIFY)
  "Check every claim against the evidence inventory"
  Flag any claim without a traceable source
```

Breaking this chain (e.g., the writer inventing statistics) is the #1 risk in AI-assisted grant writing.

## The ADAPT System

Templates are 103K chars of generic grant-writing guidance. ADAPT transforms them into section-specific, NOFO-specific prompts:

```
TEMPLATE (generic, ~103K chars)
    + section_analysis (JSON from NOFO analysis)
    + grant_argument (JSON from strategy)
    + nofo_overview
    + project_description
    + user_note (HIGHEST PRIORITY)
    |
    v  ADAPT PROCESS
    1. MAP placeholders to section data
    2. FILTER irrelevant guidance
    3. COMPRESS (40-90% based on emphasis level)
    4. COORDINATE terminology
    5. EMBED requirements/evidence
    6. VALIDATE completeness
    |
    v
INSTANCE PROMPT (section-specific, 40-60K chars)
```

Emphasis levels control compression aggressiveness:
- **high**: Keep ~60% of template content
- **medium**: Keep ~40%
- **low**: Keep ~20%

## The Dependency Chain (Workflows)

```
2.x (NOFO Analysis) -- THE FOUNDATION
 |  Extracts what the funder wants
 |  Runs ONCE per grant
 |  If wrong, everything downstream fails
 v
4.x (Project Strategy) -- THE BRAIN
 |  Plans how to win within 2.x constraints
 |  Per organization applying
 v
5.x (Writing) -- THE HANDS
    Executes the plan
    Straightforward if 2.x and 4.x are right
```

Do NOT optimize writing (5.x) if analysis (2.x) is wrong. Fix upstream first.

## Database Connection Details

- **Host**: 172.18.0.12 (Docker internal IP of gs-backend)
- **Port**: 5432
- **Database**: gs_unified
- **User**: n8n
- **Password**: In `/home/ubuntu/n8n/.env` as `DB_POSTGRESDB_PASSWORD`
- **SSH Tunnel**: `ssh -L 5434:172.18.0.12:5432 gs-production-v2`
- **Local port**: 5434 (when tunneled)

Note: Port 5432 on the Lightsail host is used by Firecrawl's postgres, NOT gs-backend. Always tunnel to the Docker internal IP.

## Common DB Column Name Mismatches

Production schemas sometimes have column names that differ from what you would expect:

- Always verify column names with `\d schema.table` before writing queries
- The `writer.system_prompts` table uses `system_message` not `content` or `prompt_text`
- The `crm.organizations` table uses `organization_name` not just `name`
- Check for `snake_case` vs `camelCase` inconsistencies in older tables

## SSH Command Patterns

```bash
# Read production code
ssh gs-production-v2 "cat /home/ubuntu/gsbot-platform/src/<path>"

# Query production DB
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c '<SQL>'"

# Read system prompts
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -t -c \"SELECT system_message FROM writer.system_prompts WHERE prompt_name = '<name>' AND is_active = true;\""

# Check container status
ssh gs-production-v2 "docker ps --format 'table {{.Names}}\t{{.Status}}'"

# View service logs
ssh gs-production-v2 "docker logs --tail 50 <container>"
```
