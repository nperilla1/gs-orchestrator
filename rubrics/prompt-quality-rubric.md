# Prompt Quality Rubric -- Effectiveness Scoring

Structured rubric for evaluating the quality of system prompts and prompt templates. Score each dimension 0-10, total 0-50.

## Dimensions

### 1. Clarity (0-10)

Is the intent of the prompt unambiguous? Can the model understand exactly what is expected?

| Score | Criteria |
|-------|----------|
| 9-10 | Crystal clear. A human reader could execute this prompt manually without questions. |
| 7-8 | Mostly clear. 1-2 minor ambiguities that the model can reasonably infer. |
| 5-6 | Somewhat clear. Key instructions are present but some steps require interpretation. |
| 3-4 | Unclear. Multiple interpretations are plausible. Model may guess wrong. |
| 1-2 | Confusing. Instructions contradict each other or are missing critical context. |
| 0 | Unintelligible. Cannot determine what the prompt is trying to accomplish. |

**Check for:**
- Is the role defined? (who the model is)
- Is the task defined? (what the model should do)
- Is the output format defined? (what the response should look like)
- Are the constraints explicit? (what the model should NOT do)
- Are ambiguous terms defined? (jargon, abbreviations, domain terms)

### 2. Specificity (0-10)

Are the constraints and expectations explicit enough to produce consistent results?

| Score | Criteria |
|-------|----------|
| 9-10 | Highly specific. Output format, length, style, and content boundaries are all defined. |
| 7-8 | Mostly specific. Most parameters are quantified, minor areas left to model judgment. |
| 5-6 | Moderately specific. Some constraints are vague (e.g., "be concise" without word count). |
| 3-4 | Underspecified. Many important parameters are left undefined. |
| 1-2 | Very vague. "Write something good about X." |
| 0 | No specificity. Open-ended with no guidance. |

**Check for:**
- Are output lengths specified (word count, character count, number of items)?
- Are quality criteria quantified (not just "good" but "scoring 7+/10 on rubric")?
- Are edge cases addressed (empty input, null values, conflicting data)?
- Are examples provided for complex output formats?
- Are forbidden patterns explicitly listed?

### 3. Efficiency (0-10)

Does the prompt achieve maximum effect with minimum tokens? Are there redundancies or wasted instructions?

| Score | Criteria |
|-------|----------|
| 9-10 | Minimal. Every sentence earns its place. No redundancy. |
| 7-8 | Efficient. Minor redundancies that do not significantly impact token usage. |
| 5-6 | Average. Some repeated instructions or verbose explanations that could be compressed. |
| 3-4 | Wasteful. Significant portions could be removed or compressed without losing information. |
| 1-2 | Very bloated. Same instruction repeated 3+ times. Walls of text that could be tables. |
| 0 | Massively wasteful. Prompt is 10x longer than necessary. |

**Check for:**
- Is the same instruction repeated in different words?
- Could prose be replaced with bullet points or tables?
- Are there unnecessary qualifiers ("please", "I'd like you to", "it would be great if")?
- Could examples be shorter while remaining illustrative?
- Is context included that the model already knows?

### 4. Robustness (0-10)

Does the prompt handle edge cases and produce reliable results across varied inputs?

| Score | Criteria |
|-------|----------|
| 9-10 | Handles all common edge cases. Includes fallback instructions for unexpected input. |
| 7-8 | Handles most edge cases. Minor gaps for unusual inputs. |
| 5-6 | Handles the happy path well. Some edge cases cause unexpected behavior. |
| 3-4 | Fragile. Small changes in input lead to very different output quality. |
| 1-2 | Breaks easily. Common variations in input produce incorrect or empty output. |
| 0 | Unreliable. Cannot produce consistent results even on standard inputs. |

**Check for:**
- What happens with empty input?
- What happens with very long input (exceeding expected length)?
- What happens with malformed input (wrong format, missing fields)?
- What happens with adversarial input (prompt injection attempts)?
- Are there fallback instructions ("if X is not provided, default to Y")?
- Are there validation steps ("before responding, verify that...")?

### 5. Consistency (0-10)

Does the same input produce the same quality of output across multiple runs?

| Score | Criteria |
|-------|----------|
| 9-10 | Highly consistent. Output structure and quality are predictable. Temperature-independent. |
| 7-8 | Mostly consistent. Minor variations in wording but same structure and conclusions. |
| 5-6 | Moderately consistent. Structure is stable but content varies significantly. |
| 3-4 | Inconsistent. Some runs produce good output, others produce poor output. |
| 1-2 | Very inconsistent. Output quality is a coin flip. |
| 0 | Completely unpredictable. No run resembles another. |

**Check for:**
- Is the output format strictly defined (JSON schema, markdown template)?
- Are there anchoring examples that constrain the response space?
- Is temperature set appropriately (0.0-0.3 for structured tasks, 0.7-1.0 for creative)?
- Are there self-check instructions ("verify your output matches the format before responding")?
- Has the prompt been tested with 5+ different inputs to verify consistency?

## Scoring Summary

```
## Prompt Quality Assessment: [prompt name]

| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | /10 | |
| Specificity | /10 | |
| Efficiency | /10 | |
| Robustness | /10 | |
| Consistency | /10 | |
| **Total** | **/50** | |

### Rating
- 45-50: Production-ready
- 35-44: Good, minor improvements recommended
- 25-34: Needs revision before deployment
- 15-24: Significant rewrite needed
- 0-14: Start over

### Top Improvement Opportunities
1. [Most impactful improvement]
2. [Second most impactful]
3. [Third most impactful]

### Strengths
- [What the prompt does well]
```

## GS-Specific Prompt Evaluation

For GrantSmiths system prompts (the 21 active prompts), also evaluate:

- **Evidence fidelity**: Does the prompt enforce the evidence chain of custody?
- **ADAPT compatibility**: Can this prompt be compressed via the ADAPT system without losing critical instructions?
- **Model compatibility**: Does this prompt work well with the intended model (e.g., Sonnet for writing, Gemini for analysis)?
- **Section awareness**: Does the prompt adapt to different grant section types (narrative, budget, abstract)?
