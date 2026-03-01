---
name: eval-harness
description: Eval-Driven Development framework. Define success criteria BEFORE writing code using two metrics -- pass@k (at least 1 of k attempts succeeds for capability testing) and pass^k (all k attempts succeed for regression testing). Three grader types -- code-based (deterministic assertions), model-based (Haiku scoring on rubric), and human (flagged for manual review). Structure is define eval cases first, write code, run evals, iterate until passing. Use when building LLM-powered features, prompt engineering, or any component where correctness needs to be measured empirically rather than through traditional unit tests.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Eval-Driven Development

You are implementing Eval-Driven Development (EDD). The core principle: define what success looks like BEFORE writing code, then measure empirically.

## Target
$ARGUMENTS
(The feature, prompt, or LLM-powered component to build with evals)

## Core Concepts

### Two Metrics

**pass@k** -- Capability testing
- Run k attempts, succeed if AT LEAST 1 passes
- Used for: exploring if the system CAN do something
- Example: "Can the model extract budget figures from a NOFO?" -- run 5 attempts, pass if 1+ extracts correctly
- Good for early development and capability discovery

**pass^k** -- Regression testing
- Run k attempts, succeed if ALL k pass
- Used for: verifying reliability and consistency
- Example: "Does the writer always include the required section headers?" -- run 5 attempts, all must include them
- Good for CI/CD and production readiness

### Three Grader Types

**1. Code-Based Graders (Deterministic)**
- Assert on structure, format, presence of required elements
- Fastest, cheapest, most reliable
- Use when: correctness can be checked programmatically

```python
def grade_section_structure(output: str) -> bool:
    """Check that output has required section headers."""
    required = ["Executive Summary", "Statement of Need", "Project Narrative"]
    return all(header in output for header in required)
```

**2. Model-Based Graders (LLM Scoring)**
- Use a fast model (Haiku) to score on a rubric
- More flexible, can assess quality/style/tone
- Use when: correctness requires judgment

```python
GRADER_PROMPT = """
Score the following grant narrative on a rubric of 1-5:
- Evidence usage: Does it cite specific data points? (1=none, 5=all claims supported)
- Relevance: Does it address the NOFO requirements? (1=off-topic, 5=perfectly aligned)
- Tone: Is it professional and compelling? (1=poor, 5=excellent)

Narrative: {output}
NOFO Requirements: {requirements}

Return JSON: {"evidence": N, "relevance": N, "tone": N}
"""
```

**3. Human Graders (Manual Review)**
- Flag outputs for human review
- Use when: subjective quality matters or stakes are high
- Log the output + context to a review queue

```python
def flag_for_review(output: str, context: dict) -> None:
    """Write to review queue for human assessment."""
    review_item = {
        "output": output,
        "context": context,
        "timestamp": datetime.now().isoformat(),
        "status": "pending"
    }
    append_jsonl("eval_review_queue.jsonl", review_item)
```

## EDD Workflow

### Step 1: Define Eval Cases FIRST

Before writing any implementation code:

```python
# eval_cases.py
EVAL_CASES = [
    {
        "name": "basic_extraction",
        "input": {"nofo_text": "...", "section": "budget"},
        "expected": {"has_budget_table": True, "total_matches": True},
        "grader": "code",  # or "model" or "human"
        "tags": ["smoke", "budget"]
    },
    {
        "name": "edge_case_empty_section",
        "input": {"nofo_text": "", "section": "budget"},
        "expected": {"graceful_error": True},
        "grader": "code",
        "tags": ["edge_case"]
    },
    {
        "name": "quality_narrative",
        "input": {"nofo_text": "...", "section": "narrative"},
        "expected": {"min_evidence_score": 3, "min_relevance_score": 4},
        "grader": "model",
        "tags": ["quality"]
    }
]
```

### Step 2: Write the Implementation

Now write the code to pass the eval cases.

### Step 3: Run Evals

```python
# run_evals.py
async def run_eval_suite(
    cases: list[dict],
    k: int = 3,
    mode: str = "pass_at_k"  # or "pass_all_k"
) -> dict:
    results = []
    for case in cases:
        attempts = []
        for _ in range(k):
            output = await run_implementation(case["input"])
            grade = await grade_output(output, case)
            attempts.append(grade)

        if mode == "pass_at_k":
            passed = any(a["passed"] for a in attempts)
        else:  # pass_all_k
            passed = all(a["passed"] for a in attempts)

        results.append({
            "case": case["name"],
            "passed": passed,
            "attempts": attempts,
            "mode": mode
        })

    return {
        "total": len(results),
        "passed": sum(1 for r in results if r["passed"]),
        "failed": [r for r in results if not r["passed"]],
        "pass_rate": sum(1 for r in results if r["passed"]) / len(results)
    }
```

### Step 4: Iterate

- If pass@k fails: the system cannot do the task -- redesign approach
- If pass@k passes but pass^k fails: the system is flaky -- improve reliability
- If pass^k passes: ship it

## Eval File Structure

```
evals/
├── cases/
│   ├── budget_extraction.py     # eval case definitions
│   ├── narrative_quality.py
│   └── section_structure.py
├── graders/
│   ├── code_graders.py          # deterministic graders
│   ├── model_graders.py         # LLM-based graders
│   └── prompts/                 # grader prompt templates
├── fixtures/
│   ├── sample_nofo.txt          # test inputs
│   └── sample_narrative.txt
├── run.py                       # eval runner
└── results/                     # eval output logs
    └── 2026-03-01_budget.jsonl
```

## When to Use Each Metric

| Scenario | Metric | k value | Why |
|---|---|---|---|
| New feature exploration | pass@k | 5 | "Can it do this at all?" |
| Prompt iteration | pass@k | 3 | "Is this prompt direction viable?" |
| Pre-merge CI check | pass^k | 3 | "Is this reliable enough to ship?" |
| Production monitoring | pass^k | 5 | "Is this consistently working?" |
| Model migration | pass^k | 5 | "Does the new model match the old one?" |

## Key Principles

- **Evals before code**: Always define what "done" looks like first
- **Start with code graders**: They are fast, cheap, deterministic. Only use model graders when you need judgment.
- **Log everything**: Every eval run should be logged with inputs, outputs, grades, and timestamps
- **Evals are living documents**: Update them as requirements change
- **Separate capability from reliability**: pass@k tells you what's possible; pass^k tells you what's dependable
