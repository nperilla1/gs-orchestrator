---
name: brainstorming
description: "Enhanced brainstorming and design thinking before any creative, architectural, or implementation work. Triggers when starting a new feature, designing a system, exploring approaches, evaluating tradeoffs, or when the user asks to think through a problem before coding."
version: "1.0"
---

# Brainstorming Skill

You are entering structured brainstorming mode. Do NOT write code yet. Your job is to fully explore the problem space before any implementation begins.

## When to Use

- Before starting any new feature, module, or system
- When the user says "let's think about", "how should we", "what's the best approach"
- Before any work that touches architecture, data models, or API design
- When there are multiple valid approaches and tradeoffs matter

## Process

### Step 1: Clarify the Goal

Ask yourself (and the user if needed):

- What is the user actually trying to accomplish? (not what they asked for — what they NEED)
- What does "done" look like? Define 2-3 concrete acceptance criteria.
- What are the constraints? (time, existing code, compatibility, performance)
- Who are the consumers of this work? (other developers, end users, other systems)

Do NOT proceed until the goal is unambiguous.

### Step 1.5: Database & Architecture Discovery

**If this work touches the database, APIs, or crosses service boundaries — this step is MANDATORY. Do not skip it.**

Before designing anything, understand what already exists:

**A. Read the Technology Constitution:**
Read `${CLAUDE_PLUGIN_ROOT}/knowledge/technology-constitution.md` to understand the architectural rules. Key questions it answers:
- Which schema should this data live in? (Article II.2)
- Is this raw data or analyzed data? (Article II.4)
- Is this global reference or client work product? (Article II.5)
- Does this need a new service or can it extend an existing one? (Article III.1, III.5)

**B. Discover existing database structure:**
```bash
# What schemas exist?
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c '\dn'"

# What tables exist in the relevant schema(s)?
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c '\dt <schema>.*'"

# What does the table structure look like?
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c '\d <schema>.<table>'"

# What foreign keys connect to other schemas?
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c \"SELECT tc.table_schema, tc.table_name, kcu.column_name, ccu.table_schema AS ref_schema, ccu.table_name AS ref_table FROM information_schema.table_constraints tc JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name WHERE tc.constraint_type = 'FOREIGN KEY' AND (tc.table_schema = '<schema>' OR ccu.table_schema = '<schema>');\""

# What data already exists that relates to this work?
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c 'SELECT count(*) FROM <schema>.<table>'"
```

**C. Map the data neighborhood:**
- What schemas will this feature READ from? List them.
- What schema will this feature WRITE to? (Must be exactly one — Article II.2)
- What existing data will this feature connect to? How?
- Are there views published for consumers? (`v_` prefix)
- Would this change affect other services that read from this schema?

**D. Document your findings:**
Write a brief "Data Context" section:
```
## Data Context
- **Write schema**: <schema_name> (existing / new)
- **Read schemas**: <list>
- **Key tables**: <table1>, <table2>
- **Row counts**: <table1>=N, <table2>=N
- **Cross-domain connections**: <description>
- **Constitution compliance**: [which articles apply and how this design follows them]
```

If you discover that the proposed design would violate the constitution (e.g., writing to another domain's schema, creating circular service dependencies, skipping raw/analyzed separation), flag it to the user and propose a compliant alternative.

### Step 2: Explore Approaches

Generate at least 3 distinct approaches. For each one:

- **Name it** — give it a short label (e.g., "Event-driven", "Polling-based", "Hybrid")
- **Sketch it** — describe the high-level structure in 3-5 sentences
- **Identify the key bet** — what assumption must be true for this approach to work?

Force yourself to include at least one unconventional approach. The obvious answer is not always the best one.

### Step 3: Evaluate Tradeoffs

For each approach, score on these dimensions (High/Medium/Low):

| Dimension | Approach A | Approach B | Approach C |
|-----------|-----------|-----------|-----------|
| Implementation speed | | | |
| Long-term maintainability | | | |
| Testability | | | |
| Fits existing patterns | | | |
| Performance at scale | | | |
| Failure mode severity | | | |

State which approach you recommend and WHY. Be explicit about what you're trading away.

### Step 4: Completeness Audit

Before finalizing, run through ALL 12 categories. For each, write one sentence about what this approach requires:

1. **Core Requirements** — What are the must-have behaviors?
2. **Edge Cases** — What inputs/states could break this? Empty data? Concurrent access? Partial failures?
3. **Error Handling** — How do errors propagate? What does the user see when something fails?
4. **Security** — Authentication? Authorization? Input validation? Data exposure risks?
5. **Performance** — Expected load? Bottlenecks? Caching needs? Query complexity?
6. **Testing Strategy** — Unit tests? Integration tests? What mocks are needed? What's hard to test?
7. **Data Model** — New tables? Schema changes? Migrations? Relationship to existing models?
8. **API Design** — Endpoints? Request/response shapes? Versioning? Breaking changes?
9. **UI/UX** — User-facing changes? Loading states? Error states? Mobile considerations?
10. **Deployment** — Config changes? Environment variables? Feature flags? Rollback plan?
11. **Monitoring** — What metrics matter? Alerts? Logging? How do you know it's working?
12. **Documentation** — What needs documenting? API docs? Architecture decisions? Runbooks?

If a category is not applicable, say "N/A — [reason]". Do NOT skip categories silently.

### Step 4.5: Constitution Gate (MANDATORY for new services, schemas, or interfaces)

If this work involves creating a new service, schema, table, or interface, you MUST answer these questions from the Technology Constitution (Article VI) before proceeding. Present them to the user.

**For a new service:**
- [ ] What specific problem does this solve? (one sentence)
- [ ] What data does it contribute to the ecosystem?
- [ ] What schema will it own?
- [ ] What will other domains be able to read from it?
- [ ] What are its core vs optional dependencies?

**For a new schema or table:**
- [ ] Is this raw data or analyzed data?
- [ ] Is this global reference data or client work product?
- [ ] Does this belong in an existing schema or a new one?
- [ ] If new, which category: shared kernel, infrastructure, or domain?
- [ ] Who are the expected consumers?

**For a new interface:**
- [ ] What services does it need?
- [ ] Do those services exist and have stable APIs?
- [ ] What state does this interface need to persist?
- [ ] Could this capability be exposed through an existing interface?

**For cross-domain data access:**
- [ ] Am I reading or triggering an action?
- [ ] If reading: using published analysis tables or internal tables?
- [ ] If triggering: calling the service's API?
- [ ] What happens if that domain's data or service is unavailable?

If any answer is unclear, stop and discuss with the user before proceeding. Any answer that violates the constitution requires a documented decision record explaining why.

### Step 5: Confirm Plan

Present the recommended approach with:

- A one-paragraph summary
- The 3 most important implementation decisions
- Any open questions that need user input
- Suggested next step (usually: invoke the **planning** skill to create an execution plan)

Wait for user confirmation before proceeding to implementation.

## Output Format

Structure your brainstorming output with clear headers for each step. Use tables for comparisons. Keep each section concise — the goal is clarity, not volume.

## Anti-Patterns to Avoid

- Do NOT start writing code "just to explore" — that is prototyping, not brainstorming
- Do NOT present only one approach — if you can only think of one, you haven't thought enough
- Do NOT skip the completeness audit — the categories you think are "obvious" are where bugs hide
- Do NOT let the user skip straight to coding — push back with "let me finish the audit first"
