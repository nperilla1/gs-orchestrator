# Prompt Patterns -- Token-Efficient Templates

Reference guide for writing effective prompts for Claude and other LLMs. Focuses on token efficiency, clarity, and reliability.

## The 4-Block Pattern

Every system prompt should follow this structure:

```
[ROLE]        -- Who are you? (1-2 sentences)
[INSTRUCTIONS] -- What should you do? (numbered steps)
[CONSTRAINTS]  -- What should you NOT do? (explicit boundaries)
[OUTPUT]       -- What should the response look like? (format spec)
```

### Example

```
You are a PostgreSQL query optimizer for the GrantSmiths platform.

## Instructions
1. Analyze the provided SQL query for performance issues
2. Check for missing indexes on JOIN and WHERE columns
3. Suggest query rewrites that reduce execution time
4. Estimate the performance improvement for each suggestion

## Constraints
- Do not suggest schema changes (table restructuring)
- Do not use database-specific features beyond PostgreSQL 16
- Do not recommend changes that alter query semantics (result set must be identical)

## Output Format
For each suggestion:
- **Issue**: What is slow and why
- **Fix**: The rewritten query or index creation
- **Impact**: Estimated improvement (High/Medium/Low)
```

## Positive Phrasing

Always state what the model SHOULD do, not what it should NOT do. Negative instructions are harder to follow.

| Bad (Negative) | Good (Positive) |
|-----------------|-----------------|
| Don't make up information | Use only information from the provided context |
| Don't be verbose | Keep responses under 200 words |
| Don't use technical jargon | Use language accessible to non-technical readers |
| Don't forget to cite sources | Include a source citation for every factual claim |

## Structured Output Patterns

### JSON Output

```
Respond with a JSON object matching this schema:

{
  "analysis": "string -- one paragraph summary",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "location": "string -- file:line",
      "description": "string",
      "suggestion": "string"
    }
  ],
  "score": "number 0-100"
}
```

### Markdown Table Output

```
Present your findings as a markdown table with these columns:
| Finding | Severity | File | Line | Suggestion |
```

### Enumerated List Output

```
List exactly 5 suggestions, numbered 1-5. Each suggestion must be:
- One sentence (max 20 words)
- Actionable (starts with a verb)
- Specific (names a file, function, or concept)
```

## Few-Shot Patterns

Provide 2-3 examples to anchor the model's behavior. Structure as input/output pairs.

```
## Examples

Input: "The organization serves 500 families annually in rural Appalachia"
Output: {"claim": "serves 500 families annually", "evidence_type": "quantitative", "verifiable": true, "source_needed": "annual report or program data"}

Input: "Our innovative approach leverages cutting-edge technology"
Output: {"claim": "innovative approach", "evidence_type": "qualitative", "verifiable": false, "source_needed": "specific technology description and outcomes data"}
```

Few-shot rules:
- Include at least one "tricky" example that demonstrates edge case handling
- Keep examples concise but representative
- The output format in examples MUST match the format spec exactly

## Chain-of-Thought Triggers

Use these phrases to activate reasoning before answering:

| Trigger | Effect |
|---------|--------|
| "Think step by step" | General reasoning chain |
| "Before answering, consider..." | Directed reasoning |
| "First, analyze X. Then, based on that analysis..." | Sequential reasoning |
| "What are the tradeoffs between..." | Comparative reasoning |
| "Let's work through this systematically" | Structured reasoning |

For complex tasks, explicitly structure the thinking:

```
## Process
1. First, read the entire document and identify all sections
2. Then, for each section, extract the key requirements
3. Next, cross-reference requirements against the evidence provided
4. Finally, produce the gap analysis
```

## XML Tag Usage for Claude

Claude responds well to XML tags for structured sections:

```
<context>
Background information the model needs to know.
</context>

<task>
The specific thing you want the model to do.
</task>

<format>
How the output should be structured.
</format>

<examples>
Input/output pairs demonstrating expected behavior.
</examples>

<constraints>
Boundaries and restrictions on the response.
</constraints>
```

XML tags are especially useful when:
- Separating user-provided data from instructions
- Creating clear boundaries between multiple input documents
- Preventing prompt injection (wrap untrusted input in `<user_input>` tags)

## Token Efficiency Techniques

### Use Tables Instead of Prose

Bad (43 tokens):
```
The severity levels are as follows: critical means the issue must be fixed immediately, high means it should be fixed before the next release, medium means it should be fixed eventually, and low means it is optional.
```

Good (25 tokens):
```
Severity levels: critical=fix now, high=fix before release, medium=fix eventually, low=optional
```

### Use Abbreviations in Internal Instructions

```
Resp in JSON. Fields: analysis (str, 1 para), findings (arr of {sev, loc, desc, fix}), score (int 0-100).
```

### Compress with Bullet Points

Instead of paragraphs, use terse bullet points for instructions the model will internalize:

```
- Evidence: cite source for every claim
- Length: 500-800 words per section
- Tone: professional, not academic
- Format: markdown with ## headers
```

## Anti-Patterns

- **Wall of text instructions**: Break into numbered steps or bullets
- **Contradictory constraints**: "Be concise but thorough" -- pick one and quantify
- **Vague output format**: "Respond appropriately" -- specify exact format
- **Overloaded prompts**: >50K chars of instructions overwhelm attention -- use ADAPT-style compression
- **Repeating the same instruction**: Saying "remember to X" three times wastes tokens and does not improve compliance
- **No examples**: Complex output formats need at least one example
