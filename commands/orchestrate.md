---
name: gs:orchestrate
description: "Run a sequential agent chain with structured handoff documents. Each agent completes its work and passes a handoff to the next agent in the chain."
arguments:
  - name: agents
    description: "Comma-separated list of agent names to chain (e.g., 'researcher,code-reviewer,devils-advocate')"
    required: true
  - name: task
    description: "The task description for the chain to work on"
    required: true
---

# /gs:orchestrate -- Sequential Agent Chain

You are orchestrating a sequential chain of specialized agents. Each agent receives the task plus all prior handoff documents, completes its work, and produces a structured handoff for the next agent.

## How It Works

```
TASK + Context
    |
    v
Agent 1 (e.g., db-analyst)
    |  produces Handoff Document #1
    v
Agent 2 (e.g., researcher)
    |  receives Task + Handoff #1
    |  produces Handoff Document #2
    v
Agent 3 (e.g., code-reviewer)
    |  receives Task + Handoff #1 + #2
    |  produces Handoff Document #3
    v
Agent N (e.g., devils-advocate)
    |  receives Task + all prior Handoffs
    |  produces Final Verdict
    v
ORCHESTRATION COMPLETE
```

## Handoff Document Format

Every agent MUST produce a handoff document in this exact structure:

```markdown
# Handoff: [Agent Name] -> [Next Agent Name]

## Task
[Original task description]

## Completed Work
- [Specific action taken]
- [Specific action taken]
- [Files read/analyzed/modified]

## Key Findings
1. [Finding with evidence/citation]
2. [Finding with evidence/citation]
3. [Finding with evidence/citation]

## Modified Files
- `path/to/file.py` -- [what was changed and why]
- (or "No files modified" if read-only analysis)

## Unresolved Questions
- [Question that needs investigation]
- [Ambiguity that the next agent should clarify]

## Recommendations for Next Agent
- [Specific thing to investigate]
- [Area of concern to validate]
- [Suggestion for the next phase]

## Confidence: [High / Medium / Low]
[One sentence explaining confidence level]
```

## Final Verdict (Last Agent Only)

The final agent in the chain produces the handoff document AND a verdict:

```markdown
## Final Verdict: [SHIP / NEEDS WORK / BLOCKED]

### SHIP
All agents agree the work is complete and meets quality standards.
No critical issues found. Minor suggestions are optional.

### NEEDS WORK
One or more agents found issues that must be addressed.
List the specific items that need fixing before shipping.

### BLOCKED
A blocking issue was found that requires user decision or external input.
Describe the blocker and what information is needed to proceed.
```

## Execution Protocol

### Phase 1: Parse the Chain

1. Parse the comma-separated agent list
2. Verify each agent name is valid (exists in the agents/ directory)
3. Report the chain: "Orchestrating: agent1 -> agent2 -> agent3 (N agents)"

### Phase 2: Execute Each Agent

For each agent in the chain:

1. **Announce**: "Running [agent name] (agent N of M)..."
2. **Provide context**: Pass the original task AND all prior handoff documents
3. **Execute**: Let the agent do its work according to its own instructions
4. **Collect handoff**: Ensure the agent produces the structured handoff document
5. **Report**: Summarize what the agent found in 2-3 sentences

### Phase 3: Compile Final Report

After all agents have run:

```
ORCHESTRATION COMPLETE
======================

Chain: agent1 -> agent2 -> agent3
Task:  [task description]

Agent Summaries:
  1. [agent1]: [2-sentence summary]
  2. [agent2]: [2-sentence summary]
  3. [agent3]: [2-sentence summary]

Final Verdict: [SHIP / NEEDS WORK / BLOCKED]

[Details from final agent's verdict]
```

## Common Chains

### Grant Writing Pipeline
```
db-analyst -> researcher -> code-reviewer -> devils-advocate
```
- db-analyst: Check schema, data integrity, existing records
- researcher: Investigate production code, prompts, patterns
- code-reviewer: Review implementation quality
- devils-advocate: Stress test and find weaknesses

### Code Quality Pipeline
```
test-runner -> code-reviewer -> security-sentinel -> db-reviewer
```
- test-runner: Verify tests pass, check coverage
- code-reviewer: Code quality, patterns, maintainability
- security-sentinel: OWASP checks, credential handling
- db-reviewer: Query performance, PostgreSQL anti-patterns

### Architecture Review Pipeline
```
researcher -> code-reviewer -> devils-advocate
```
- researcher: Gather context on existing system
- code-reviewer: Evaluate design decisions and patterns
- devils-advocate: Challenge assumptions and find failure modes

### Quick Review Pipeline
```
code-reviewer -> test-runner
```
- code-reviewer: Review changes
- test-runner: Verify nothing is broken

## Rules

- Agents execute sequentially -- never in parallel (each needs the prior handoff)
- Every agent MUST produce a handoff document, no exceptions
- If an agent produces a BLOCKED verdict mid-chain, stop the chain and report
- The final agent always produces the verdict
- Do not modify the agent list mid-chain without user permission
- Maximum chain length: 6 agents (longer chains lose coherence)
