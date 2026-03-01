---
name: deep-research-swarm
description: Deploy a swarm of 4-6 parallel research agents to exhaustively research any topic. Decomposes the subject into non-overlapping domains (tools, APIs, open source, frameworks, integration, best practices), deploys one researcher agent per domain each performing 15-20+ web searches, then synthesizes all findings into a comprehensive report with tool matrix, recommended stack, Claude Code integration plan, architecture decision, and gap analysis. Use for any topic where you need the absolute best tools, libraries, approaches, and current best practices.
allowed-tools: Task, Read, Write, Edit, WebSearch, WebFetch, Grep, Glob, Bash
---

# Deep Research Swarm

You are deploying a parallel research swarm to exhaustively research a topic and find the best tools, libraries, frameworks, approaches, best practices, and resources available.

## Topic
$ARGUMENTS

## Phase 1: Scope Decomposition (YOU do this -- do NOT delegate)

Break the topic into 4-6 non-overlapping research domains. Each domain should cover a distinct aspect of the topic. Think about:

- **Tools & Libraries**: What software exists for this?
- **APIs & Services**: What cloud/SaaS APIs are available?
- **Open Source**: What free/self-hosted alternatives exist?
- **Frameworks & Patterns**: What architectural approaches work best?
- **Integration**: How does this connect to Claude Code (MCP servers, skills, plugins, hooks)?
- **Best Practices**: What do experts recommend? What are the pitfalls?

For each domain, write a detailed research brief (the prompt for the agent). Each brief MUST include:
- 7+ specific sub-topics to search for
- "Search at least 15-20 queries" instruction
- "For each tool/approach found, provide: what it is, how to set up, pricing, open source alternatives, Claude Code integration, links/sources"
- The instruction to be EXHAUSTIVE

## Phase 2: Deploy Research Agents (ALL in parallel)

Launch 4-6 researcher agents simultaneously using the Task tool:
- `subagent_type: researcher`
- `run_in_background: true`
- Each agent gets one domain from Phase 1
- Each agent's prompt should be self-contained (include all context it needs)

Example deployment pattern:
```
Agent 1: "[Domain 1] tools, libraries, APIs"
Agent 2: "[Domain 2] frameworks, patterns, architecture"
Agent 3: "[Domain 3] integration, automation, workflows"
Agent 4: "[Domain 4] best practices, case studies, examples"
Agent 5: "[Domain 5] Claude Code specific (MCPs, skills, plugins, hooks)"
Agent 6: "[Domain 6] emerging trends, cutting edge, 2025-2026 innovations"
```

## Phase 3: Wait & Collect

After all agents are deployed:
1. Tell the user how many agents are deployed and what each is researching
2. Wait for all agents to complete (they'll send notifications)
3. As each completes, acknowledge it

## Phase 4: Synthesize (After ALL agents complete)

Once all research is back, produce a comprehensive synthesis:

### 4a. Executive Summary
- One paragraph overview of the landscape
- Top 5 most impactful findings

### 4b. Tool/Library Matrix
Create a table with ALL discovered tools organized by category:
| Tool | Category | Type (OSS/SaaS/API) | Pricing | Best For | Claude Code Integration |

### 4c. Recommended Stack
Based on all findings, recommend the optimal combination of tools for the user's use case. Explain trade-offs.

### 4d. Claude Code Integration Plan
What to deploy immediately:
- MCP servers to add
- Skills to create
- Hooks to configure
- Rules to add
- Agents to define
- CLAUDE.md patterns

### 4e. Architecture Decision
Determine whether the topic needs:
- **Skills only** (guidance for Claude, no runtime) -- for workflow/process topics
- **Skills + tool in ~/tools/** (needs database, API server, scheduled jobs) -- for operational topics
- **Skills + n8n workflows** (needs automation, scheduling, webhooks) -- for integration topics

### 4f. Gap Analysis
What's NOT available yet? What would need to be built custom?

## Phase 5: Write Output

Write the full synthesis report to `/tmp/research-swarm-output.md` and present the key findings to the user.

## Key Principles

- **Breadth over depth initially**: Cast a wide net first, then deep-dive on the best findings
- **Always check for Claude Code integration**: For every tool found, ask "does this have an MCP server? A plugin? Can it be called from a skill?"
- **Open source preference**: Always list open source alternatives alongside commercial tools
- **Recency matters**: Prioritize 2025-2026 information. Older tools may be outdated.
- **No hallucination**: Agents must cite sources. If a tool can't be verified, flag it as unconfirmed.
