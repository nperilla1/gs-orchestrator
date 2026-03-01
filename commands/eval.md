---
name: gs:eval
description: "Run evaluation suites against the current project. Discovers eval definition files, executes them, and reports pass@k and pass^k metrics."
---

# /gs:eval -- Evaluation Suite Runner

You are running the evaluation suite for the current project. This discovers eval definitions, executes them, and reports metrics.

## Eval Discovery

Search the current project for eval definition files:

```bash
find . -name "*.eval.json" -o -name "*.eval.yaml" -o -name "*.eval.yml" 2>/dev/null
```

Also check for a top-level `evals/` directory:
```bash
ls -la evals/ 2>/dev/null
```

If no eval files are found, report that and suggest creating one using the eval definition format below.

## Eval Definition Format

### JSON Format (*.eval.json)

```json
{
  "name": "section-writer-quality",
  "description": "Evaluates grant narrative section quality",
  "model": "claude-sonnet-4-20250514",
  "runs": 5,
  "cases": [
    {
      "id": "case-1",
      "input": "Write a project narrative for a rural health clinic applying to HRSA",
      "expected": {
        "contains": ["evidence-based", "health outcomes", "underserved"],
        "min_length": 500,
        "max_length": 3000,
        "rubric": "prompt-quality"
      }
    }
  ]
}
```

### YAML Format (*.eval.yaml)

```yaml
name: section-writer-quality
description: Evaluates grant narrative section quality
model: claude-sonnet-4-20250514
runs: 5
cases:
  - id: case-1
    input: Write a project narrative for a rural health clinic applying to HRSA
    expected:
      contains:
        - evidence-based
        - health outcomes
        - underserved
      min_length: 500
      max_length: 3000
      rubric: prompt-quality
```

## Execution Protocol

### Step 1: Load Eval Definitions

Parse all discovered eval files. For each eval:
1. Validate the schema (name, cases, expected results)
2. Report: "Found N eval suites with M total cases"

### Step 2: Execute Cases

For each eval suite:
1. Announce: "Running eval: [name] (N cases, K runs each)"
2. For each case, run K times (for pass@k measurement)
3. For each run, check against expected criteria:
   - **contains**: Check if output includes required strings
   - **not_contains**: Check output does not include forbidden strings
   - **min_length** / **max_length**: Character count bounds
   - **rubric**: Apply the named rubric from the rubrics/ directory
   - **regex**: Match against a regex pattern
   - **json_schema**: Validate output against a JSON schema

### Step 3: Calculate Metrics

**pass@k** -- probability that at least one of k samples passes:
```
pass@k = 1 - C(n-c, k) / C(n, k)
where n = total runs, c = correct runs, k = samples
```

**pass^k** -- probability that all k samples pass:
```
pass^k = (c/n)^k
```

Report both metrics for k=1, k=3, k=5.

### Step 4: Report Results

```
EVAL RESULTS
============

Suite: [name]
  Cases: N
  Runs per case: K
  Total executions: N*K

  Case Results:
    case-1: 4/5 passed
      - pass@1: 0.80
      - pass@3: 0.99
      - pass@5: 1.00
      - Failures: [brief description of what failed]

    case-2: 5/5 passed
      - pass@1: 1.00

  Suite Summary:
    Overall pass@1: 0.90
    Overall pass@3: 0.99
    Mean score (rubric): 7.8/10

---

AGGREGATE
  Total suites: N
  Total cases: M
  Overall pass@1: X.XX
  Weakest case: [case-id] (pass@1: X.XX)
```

## Rubric Integration

When a case specifies a `rubric`, load the corresponding rubric from the `rubrics/` directory and use it to score the output. The rubric score should be reported alongside pass/fail.

- `prompt-quality` -> rubrics/prompt-quality-rubric.md
- `code-review` -> rubrics/code-review-rubric.md
- `security` -> rubrics/security-audit-rubric.md

## Rules

- Never modify eval definition files
- If a case requires API calls (LLM invocations), respect rate limits
- Report failures with enough detail to diagnose (show expected vs actual)
- If an eval suite takes longer than 5 minutes, report progress every 30 seconds
- Save results to `~/.gs-orchestrator/eval-results/[suite-name]-[timestamp].json`
