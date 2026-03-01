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
