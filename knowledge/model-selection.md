# Model Selection Guide

Decision framework for choosing the right Claude model (or other provider) for each task. Optimizes for cost, latency, and output quality.

## Claude Model Tiers

### Haiku -- Fast and Cheap

**Use for:**
- Status checks and health monitoring
- Simple file reads and transforms
- Quick formatting and linting
- Test execution and result parsing
- Simple data extraction from structured sources
- Git operations (commit, status, diff parsing)

**Characteristics:**
- Fastest response time (~0.5-2s for short tasks)
- Lowest cost per token
- Good at following explicit instructions
- Weaker at nuanced reasoning, creative writing, or multi-step analysis

**Agent assignments:**
- test-runner: Runs tests, reports results
- devops: Infrastructure checks, deployment commands

### Sonnet -- The Workhorse

**Use for:**
- Code generation and modification
- Code review and analysis
- Bug investigation and debugging
- Research synthesis
- Database analysis and query optimization
- Prompt engineering
- Most day-to-day development work

**Characteristics:**
- Good balance of speed and quality (~2-8s)
- Strong code generation
- Solid reasoning for most tasks
- Cost-effective for high-volume work

**Agent assignments:**
- researcher: Deep exploration across sources
- debugger: Root cause analysis
- code-reviewer: Multi-pass review
- db-analyst: Schema and query analysis
- writer-agent: Grant narrative drafting
- prompt-engineer: System prompt design
- performance-analyst: Profiling and optimization
- ux-reviewer: UI/UX evaluation

### Opus -- The Expert

**Use for:**
- Architecture design and system-level decisions
- Adversarial review and stress testing
- Security audits
- Complex multi-step reasoning
- Tasks where getting it wrong has high cost
- Nuanced writing (grant narratives, executive summaries)
- Evaluating other models' outputs

**Characteristics:**
- Highest quality output
- Slowest response time (~5-30s)
- Most expensive per token
- Best at handling ambiguity and nuance
- Strongest reasoning chain

**Agent assignments:**
- security-auditor: OWASP-aligned analysis
- devils-advocate: Adversarial review
- architect: System design decisions

## Decision Matrix

| Factor | Use Haiku | Use Sonnet | Use Opus |
|--------|-----------|------------|----------|
| Task complexity | Simple, mechanical | Moderate, some judgment | Complex, nuanced |
| Error tolerance | Retries are cheap | Some tolerance | Must get it right |
| Latency requirement | Under 2 seconds | Under 10 seconds | Minutes acceptable |
| Output length | Short (<500 tokens) | Medium (500-4K tokens) | Long (4K+ tokens) |
| Reasoning depth | None/shallow | Moderate | Deep/multi-step |
| Creative quality | Not needed | Good enough | Must be excellent |

## Task-Specific Recommendations

### Grant Writing Pipeline

| Stage | Model | Why |
|-------|-------|-----|
| NOFO section extraction | Gemini 2.5 Pro | Large NOFO context (100K+ chars) |
| Requirement analysis | Sonnet | Structured extraction |
| Strategy creation | GPT-5 | Strong structured output |
| Evidence gathering (RAG) | Sonnet | Query formulation + synthesis |
| Section writing | Claude Sonnet 4.5 | Nuanced prose quality |
| Section review | Claude Sonnet 4.5 | Quality assessment |
| Adversarial review | Opus | Finds weaknesses others miss |
| Budget narrative | Claude Opus 4.1 | Complex document generation |
| Quick edits/chat | Haiku | Fast interactive response |

### Development Workflow

| Task | Model | Why |
|------|-------|-----|
| Generate boilerplate code | Haiku | Fast, formulaic |
| Implement a feature | Sonnet | Code generation sweet spot |
| Debug a complex issue | Sonnet (escalate to Opus) | Start fast, escalate if needed |
| Architectural review | Opus | High-stakes design decisions |
| Code review | Sonnet | Good enough for most reviews |
| Security audit | Opus | Cannot afford to miss vulnerabilities |
| Write tests | Sonnet | Needs to understand the code |
| Run tests | Haiku | Just execution, no reasoning |

## Cost Comparison (Approximate)

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Relative Cost |
|-------|----------------------|----------------------|--------------|
| Haiku | $0.25 | $1.25 | 1x |
| Sonnet | $3.00 | $15.00 | 12x |
| Opus | $15.00 | $75.00 | 60x |

Rule of thumb: If Haiku can do it, use Haiku. If not, use Sonnet. Only use Opus when quality justifies the 5x premium over Sonnet.

## Escalation Pattern

Start with the cheapest model that might work, escalate if output quality is insufficient:

```
1. Try Haiku
   - If output is correct and complete -> done
   - If output is wrong or incomplete -> escalate

2. Try Sonnet
   - If output is correct and complete -> done
   - If output is wrong or nuance is lost -> escalate

3. Use Opus
   - For the highest-stakes version of the task
```

This works well for:
- Code generation (Haiku for boilerplate, Sonnet for logic, Opus for architecture)
- Reviews (Haiku for lint-level, Sonnet for logic-level, Opus for design-level)
- Research (Haiku for data extraction, Sonnet for synthesis, Opus for insights)

## Multi-Model Patterns

### LLM Council

Run the same task with 3 models and compare outputs:
- Haiku: fast draft
- Sonnet: balanced analysis
- Opus: deep analysis

Then synthesize the best insights from all three. Use when the cost of being wrong is high but you want speed for the initial pass.

### Reviewer Chain

Have a cheaper model generate, then a more expensive model review:
- Sonnet generates code
- Opus reviews it for security/architecture

This is more cost-effective than having Opus generate from scratch.

## Anti-Patterns

- **Always using Opus**: Wastes money and time on simple tasks
- **Always using Haiku**: Produces low-quality results on complex tasks
- **Ignoring context limits**: Haiku has smaller effective context than Opus
- **Not considering latency**: Opus in a real-time chat loop feels sluggish
- **Mixing models mid-conversation**: Each model has different "memory" of the conversation; switching models mid-task can cause inconsistencies
