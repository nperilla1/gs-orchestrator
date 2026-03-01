---
name: writing-agents
description: How to write effective agent definitions for Claude Code subagent orchestration. Covers frontmatter structure (name, description, tools list, model selection), system prompt design for agents, tool access patterns (read-only vs full write access), model selection guide (haiku for fast/cheap interactive tasks, sonnet for balanced reasoning, opus for complex multi-step reasoning), memory and persistence flags, GS-specific patterns for grant writing agents, and the relationship between agents, skills, and orchestrators. Use when defining new agents for the gs-orchestrator system or any multi-agent Claude Code setup.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Writing Agent Definitions

You are defining an agent for Claude Code's multi-agent system. Agents are autonomous units that can be spawned as subagents with specific capabilities, tools, and behavioral instructions.

## Target
$ARGUMENTS
(The agent to define or improve)

## Agent vs Skill

| | Skill | Agent |
|---|---|---|
| **Invocation** | User or auto-discovery | Spawned by orchestrator or other agents |
| **Context** | Inherits parent context | Gets clean, focused context |
| **Persistence** | Single execution | Can maintain state across steps |
| **Tools** | Restricted set | Configured per agent |
| **Model** | Same as parent | Can use different model |

## Agent Definition Structure

### Frontmatter

```yaml
---
name: agent-name
description: What this agent does and when to spawn it. Be specific about capabilities and domain expertise.
model: sonnet  # haiku | sonnet | opus
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - WebSearch
memory: false  # whether agent maintains cross-session memory
---
```

### Model Selection Guide

| Model | When to Use | Cost | Speed | Reasoning |
|---|---|---|---|---|
| **haiku** | Interactive chat, simple extraction, formatting, classification | Lowest | Fastest | Basic |
| **sonnet** | Code generation, analysis, moderate complexity, most tasks | Medium | Medium | Good |
| **opus** | Complex multi-step reasoning, architecture decisions, nuanced writing, adversarial review | Highest | Slowest | Best |

**Decision tree:**
```
Is it interactive/real-time?           -> haiku
Is it a standard coding/analysis task? -> sonnet
Does it require deep reasoning?        -> opus
Is accuracy critical (no retries)?     -> opus
Is it high-volume/batch?               -> haiku
```

### System Prompt Design for Agents

Agents need more focused system prompts than skills because they operate autonomously.

**Structure:**
```markdown
# [Agent Name]

## Identity
You are a [specific role] with expertise in [domain].
You are working on [current task context].

## Mission
[Single sentence describing the agent's goal]

## Instructions
1. [Step-by-step process]
2. [Each step is imperative]
3. [Include decision points]

## Constraints
- [What the agent must NOT do]
- [Quality thresholds]
- [Resource limits]

## Output
[Exact format of what the agent produces]

## Escalation
If you encounter [situation], stop and report to the orchestrator rather than guessing.
```

### Tool Access Patterns

**Read-Only Agent** (reviewer, analyzer):
```yaml
tools:
  - Read
  - Grep
  - Glob
```
Use when the agent should analyze but never modify. Prevents accidental changes.

**Full Write Agent** (builder, editor):
```yaml
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
```
Use when the agent needs to create or modify files.

**Research Agent** (fact-finder, explorer):
```yaml
tools:
  - Read
  - WebSearch
  - WebFetch
  - Grep
  - Glob
```
Use when the agent needs to search the web. No file modification.

**Orchestrator Agent** (coordinator):
```yaml
tools:
  - Read
  - Write
  - Task
  - Grep
  - Glob
```
Use when the agent spawns and coordinates other agents.

## GS-Specific Agent Patterns

### Grant Writing Agents

The GS platform uses a pipeline of specialized agents:

```
NofoAnalyzer (sonnet)       -- Extracts requirements from NOFOs
  -> ArgumentBuilder (opus) -- Builds strategic grant arguments
  -> EvidenceGatherer (sonnet) -- Finds evidence via RAG
  -> SectionStrategist (opus) -- Plans section-by-section approach
  -> SectionWriter (sonnet) -- Writes narrative sections
  -> DevilsAdvocate (opus) -- Adversarial review of drafts
```

**Key pattern: Evidence chain of custody.**
Each agent in the chain passes structured output to the next. No agent invents information -- they transform, assess, or deploy what was gathered earlier.

### Agent Communication

Agents communicate through:
1. **Structured output**: JSON or Pydantic models passed between agents
2. **File artifacts**: Written to disk at known paths
3. **Database state**: Read from and write to the shared database

### Memory Flag

```yaml
memory: true  # Agent remembers across invocations
```

When `memory: true`:
- Agent can reference previous conversations
- Useful for agents that build cumulative knowledge (e.g., learning user preferences)
- Expensive -- only enable when needed

When `memory: false` (default):
- Each invocation is stateless
- Cheaper, more predictable
- Preferred for most task-specific agents

## Testing Agents

1. **Spawn test**: Can the orchestrator spawn this agent successfully?
2. **Tool test**: Can the agent use all its configured tools?
3. **Boundary test**: Does the agent stay within its constraints?
4. **Output test**: Does the agent produce correctly formatted output?
5. **Escalation test**: Does the agent escalate when it should rather than guessing?
