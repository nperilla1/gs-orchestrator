---
name: context-engineering
description: Anthropic's 4 pillars of context engineering for Claude Code and LLM-powered systems. Covers Write (craft prompts and system messages), Select (choose relevant context from available sources like RAG, knowledge files, and conversation history), Compress (reduce token usage without losing meaning through summarization and pruning), and Isolate (use subagents and tool boundaries to prevent context pollution). Includes context rot prevention, knowledge file management, CLAUDE.md optimization, memory architecture, and practical patterns for keeping context windows effective over long sessions.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Context Engineering

You are applying context engineering principles to optimize how context is managed in an LLM-powered system. Context engineering is the art of getting the right information to the model at the right time in the right format.

## Target
$ARGUMENTS
(The system, prompt, or architecture to optimize for context management)

## The 4 Pillars

### Pillar 1: WRITE -- Craft Prompts and System Messages

The foundation. What you put INTO the context window.

**Principles:**
- Front-load the most important information (models attend more to the beginning and end)
- Use structured formats (headers, lists, tables) over prose
- Be explicit about what matters most
- Remove filler words and redundant explanations

**Patterns:**
- CLAUDE.md for project-level context (loaded every session)
- SKILL.md for task-specific context (loaded on demand)
- System prompts for agent behavior (loaded per conversation)
- Few-shot examples for output format (most token-efficient teaching method)

**Example -- front-loading:**
```
## CRITICAL: This project uses SQLAlchemy 2.0 async (NOT sync). All database operations MUST use async/await.

## Project Overview
[less critical details here...]
```

### Pillar 2: SELECT -- Choose Relevant Context

Not everything is relevant. Select what matters for the current task.

**Sources to select from:**
- RAG results (semantic search over documents)
- Knowledge files (static reference docs)
- Conversation history (recent messages)
- Code context (current file, related files)
- Database state (current schema, recent queries)

**Selection strategies:**
- **Semantic search**: Embed the query, find similar content
- **Keyword match**: Fast, deterministic, no model needed
- **Recency bias**: Recent context is usually more relevant
- **Task-based filtering**: Only load context relevant to the current operation
- **User-directed**: Let the user specify what to include

**Anti-pattern: Loading everything.** If you dump the entire codebase into context, the model loses focus on what matters.

**Pattern -- progressive disclosure:**
```
Level 0: CLAUDE.md (always loaded, <500 lines)
Level 1: Relevant SKILL.md (loaded when task matches)
Level 2: Specific source files (loaded when editing)
Level 3: Full codebase search (only when needed)
```

### Pillar 3: COMPRESS -- Reduce Token Usage Without Losing Meaning

Context windows are finite. Every wasted token displaces useful information.

**Compression techniques:**

1. **Summarize conversation history**: Replace detailed back-and-forth with a summary
   ```
   ## Session Summary (compressed from 15 messages)
   - Built the writer agent with 3 phases (analyze, strategize, write)
   - Fixed the SQLAlchemy async session handling
   - Tests pass: 65/65
   - Current focus: adding the review phase
   ```

2. **Prune irrelevant context**: Remove completed tasks, resolved issues, old search results

3. **Use references instead of inline content**: "See writer/CLAUDE.md for architecture" instead of pasting the full file

4. **Structured over prose**: A table with 5 rows replaces 5 paragraphs

5. **Archive to knowledge files**: Move static reference info out of active context into files that can be loaded on demand

**Context rot detection:**
- Conversation exceeds 50K tokens -- time to summarize
- Repeated information appears in multiple places -- deduplicate
- Old search results still in context -- prune them
- Stale code snippets from files that have changed -- refresh

### Pillar 4: ISOLATE -- Prevent Context Pollution

Long contexts accumulate noise. Isolation prevents cross-contamination.

**Isolation strategies:**

1. **Subagents**: Spawn a subagent for a focused task. It gets clean context with only what it needs. Results come back as a summary.
   ```
   Main agent context: Project architecture + current task
   Subagent context: Specific file + specific test + grading criteria
   ```

2. **Tool boundaries**: Each tool call is a fresh context. Use tools to compartmentalize.

3. **Session boundaries**: Start new sessions for new tasks rather than continuing a sprawling conversation.

4. **Schema isolation**: Different database schemas for different concerns (writer schema, watcher schema, etc.)

5. **File isolation**: Put detailed reference docs in separate files, not inline in CLAUDE.md.

**Anti-pattern: The mega-session.** A single session that does research, architecture, implementation, testing, and deployment accumulates massive context. Break into focused sessions.

## Practical Patterns

### CLAUDE.md Optimization
Keep CLAUDE.md under 500 lines. It loads every session, so every line costs tokens.
- Put architecture decisions in CLAUDE.md
- Put detailed API docs in separate files linked from CLAUDE.md
- Update CLAUDE.md after major decisions
- Remove obsolete information regularly

### Memory Architecture
```
Always loaded:     CLAUDE.md (~500 lines)
Task-loaded:       SKILL.md files (on-demand via skill invocation)
Search-loaded:     RAG results (via semantic search)
Session-specific:  Conversation summary (compressed periodically)
Persistent:        Knowledge files (loaded by reference)
```

### When to Compress
- After completing a major milestone -- summarize and archive
- When context exceeds 50K tokens -- summarize conversation
- When switching between very different tasks -- start fresh
- When information is repeated in 3+ places -- deduplicate
