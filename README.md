# gs-orchestrator

Unified Claude Code plugin for the GrantSmiths platform. Bundles all custom agents, skills, hooks, MCP configs, and autonomous workflows into a single self-deploying package.

## What's Included

| Component | Count | Purpose |
|-----------|-------|---------|
| **Agents** | 13 | Specialized subagents (review, security, debug, research, DB, etc.) |
| **Skills** | 38 | Orchestration, frontend, marketing, research, quality, prompt-eng, git, learning, sites |
| **Hooks** | 7 | Skill router, file protection, auto-format, validation, completion gate |
| **Commands** | 7 | `/gs:setup`, `/gs:start`, `/gs:status`, `/gs:orchestrate`, `/gs:eval`, `/gs:learn`, `/gs:evolve` |
| **MCP Servers** | 5 | Context7, Playwright, Supabase, Airtable, gs-unified PostgreSQL |
| **Knowledge** | 5 | Prompt patterns, context engineering, hooks, model selection, GS domain |
| **Rubrics** | 3 | Code review, security audit, prompt quality |
| **Templates** | 6 | CLAUDE.md, agent, skill, steering docs, handoff document |

## Installation

```bash
claude plugin add ./gs-orchestrator
```

Or from GitHub:
```bash
claude plugin add https://github.com/nperilla1/gs-orchestrator
```

## First-Time Setup

After installation, start a new Claude Code session. The bootstrap hook will detect first-run and prompt you to run:

```
/gs:setup
```

This walks through:
1. SSH connectivity to Lightsail (52.72.246.186)
2. Database password configuration
3. SSH tunnel setup for local development
4. Environment variable configuration
5. Companion plugin check (superpowers, coderabbit)

## Companion Plugins

These should be installed alongside gs-orchestrator:

- **superpowers** — worktree management, upstream updates
- **coderabbit** — external 40+ analyzer code review service

Optional:
- **plugin-dev** — only if building plugins
- **skill-creator** — only if creating skills

## Key Innovations

### Skill Router (Autonomy Engine)
The `skill-router.sh` UserPromptSubmit hook auto-detects what you're working on and injects relevant skills into context. No manual `/skill-name` invocation needed.

### Completion Gate (Opt-In)
Drop a `.gs-completion-gate` file in your project root. Claude won't stop until tests pass.

### Sequential Agent Orchestration
`/gs:orchestrate` chains agents with structured handoff documents. Maps to the grant writing pipeline: analysis -> strategy -> writing -> review.

### Continuous Learning
Observations crystallize into instincts over time. `/gs:learn` extracts patterns, `/gs:evolve` promotes them to skills.

## Environment Variables

Set these in your shell profile or `.env`:

| Variable | Required | Purpose |
|----------|----------|---------|
| `GS_DB_URL` | Yes | PostgreSQL connection string for gs_unified |
| `GS_DB_PASSWORD` | Yes | Database password (used to construct GS_DB_URL) |
| `SUPABASE_ACCESS_TOKEN` | Optional | Supabase MCP access |
| `AIRTABLE_API_KEY` | Optional | Airtable MCP access |

## Project Structure

```
gs-orchestrator/
├── .claude-plugin/plugin.json    # Plugin manifest
├── .mcp.json                     # MCP server configurations
├── hooks/                        # Event handlers
├── agents/                       # 13 specialized subagents
├── skills/                       # 36 skills across 9 categories
├── commands/                     # 7 slash commands
├── knowledge/                    # Reference documentation
├── rubrics/                      # Quality scoring criteria
├── templates/                    # Templates for new projects
├── context/                      # Dynamic context injection
└── scripts/                      # Helper scripts
```
