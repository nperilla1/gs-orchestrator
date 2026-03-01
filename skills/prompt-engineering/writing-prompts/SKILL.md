---
name: writing-prompts
description: System prompt best practices and engineering patterns. Covers the 4-block prompt pattern (Role + Context, Instructions, Constraints, Output Format), token-efficient techniques, positive vs negative instructions, structured output with examples, Anthropic prompt engineering guide patterns, few-shot learning, chain-of-thought reasoning, and common anti-patterns. Use when writing or refining system prompts for LLM-powered features, agents, or any component that talks to a language model. Includes concrete before/after examples.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Writing System Prompts

You are crafting or improving a system prompt. Follow these patterns to produce clear, effective, token-efficient prompts.

## Target
$ARGUMENTS
(The prompt to write or improve, the use case, or the LLM-powered feature it will serve)

## The 4-Block Pattern

Every system prompt should have these 4 sections, in this order:

### Block 1: Role + Context
Tell the model WHO it is and WHAT it knows.

```
You are a senior grant writer specializing in federal NOFO applications.
You have 15 years of experience writing successful proposals for nonprofit organizations.
You are working on a proposal for [organization] applying to [grant].
```

**Rules:**
- Be specific about domain expertise
- Include relevant context the model needs
- Establish the working relationship (advisor, executor, reviewer)

### Block 2: Instructions
Tell the model WHAT to do, step by step.

```
Analyze the following NOFO section and:
1. Extract all stated requirements (mandatory and optional)
2. Identify the scoring criteria and point allocations
3. List evidence types that would satisfy each requirement
4. Flag any ambiguous requirements that need clarification
```

**Rules:**
- Use numbered steps for sequential tasks
- Use bullet points for parallel/unordered items
- One instruction per line
- Start each instruction with a verb (analyze, extract, identify, list, flag)

### Block 3: Constraints
Tell the model what NOT to do and the boundaries.

```
When writing the narrative:
- Use ONLY evidence provided in the context. Never fabricate statistics or claims.
- Stay within the word count specified for this section.
- Match the tone of the approved examples.
- If evidence is insufficient, state what is missing rather than inventing data.
```

**Rules:**
- Prefer positive instructions ("Use only provided evidence") over negative ("Don't hallucinate")
- Be explicit about boundaries
- Include the most critical constraint first

### Block 4: Output Format
Tell the model exactly what the response should look like.

```
Respond with a JSON object:
{
  "requirements": [
    {
      "id": "R1",
      "text": "requirement text from NOFO",
      "type": "mandatory | optional",
      "scoring_points": number,
      "evidence_needed": ["type1", "type2"]
    }
  ],
  "ambiguous": ["list of unclear requirements"],
  "total_points": number
}
```

**Rules:**
- Show the exact structure with example values
- Specify types (string, number, array)
- Include an example of a filled-in response if the format is complex

## Token-Efficient Techniques

### Use Lists, Not Paragraphs

**Wasteful (67 tokens):**
```
When analyzing the document, you should pay attention to the requirements section where the funder describes what they want to see. You should also look at the scoring criteria because these tell you how points will be awarded. Additionally, check for any special formatting requirements that applicants must follow.
```

**Efficient (31 tokens):**
```
Analyze these sections:
- Requirements: what the funder wants
- Scoring criteria: how points are awarded
- Formatting rules: required structure
```

### Positive Over Negative Instructions

**Negative (asks model to NOT do things -- model still processes the concept):**
```
Don't use technical jargon. Don't write long paragraphs. Don't include unverified claims.
```

**Positive (tells model what TO do):**
```
Use plain language. Keep paragraphs under 4 sentences. Cite sources for all claims.
```

### Few-Shot Over Long Descriptions

Instead of describing what you want in prose, show 1-2 examples:

```
Format each finding as:

Example:
Input: "The program shall serve at least 500 youth annually"
Output: {"requirement": "Serve 500+ youth/year", "type": "mandatory", "metric": "annual_youth_served", "threshold": 500}

Now process the following inputs:
```

## Chain-of-Thought Prompting

For complex reasoning, ask the model to think step by step:

```
Before writing the narrative:
1. First, list the 3 strongest evidence points from the provided materials
2. Then, map each evidence point to the NOFO requirement it satisfies
3. Identify any gaps where evidence is missing
4. Draft an outline based on the evidence-to-requirement mapping
5. Write the narrative following the outline
```

## Common Anti-Patterns

| Anti-Pattern | Why It Fails | Fix |
|---|---|---|
| "Be creative and thorough" | Vague, no actionable guidance | Specify exactly what to produce |
| 10+ constraints in a row | Model loses track of later ones | Prioritize top 3-5, move rest to examples |
| "Don't hallucinate" | Negative instruction, model processes concept | "Use ONLY provided sources. If unsure, say 'insufficient data'" |
| Repeating instructions 3 ways | Wastes tokens, confuses priority | State once clearly |
| No output format | Model guesses structure | Always specify format with example |
| Role = "You are a helpful assistant" | Generic, no domain grounding | Be specific: "You are a federal grants compliance reviewer" |

## Prompt Size Guidelines

| Prompt Type | Target Size | Why |
|---|---|---|
| Chat/interactive | 500-2000 tokens | Fast, leaves room for conversation |
| Single-task agent | 2000-5000 tokens | Detailed enough for complex tasks |
| System prompt (ADAPT) | 5000-50000 tokens | Domain expertise encoding |
| Maximum effective | ~100K tokens | Beyond this, attention degrades |

## Testing Your Prompt

After writing a prompt:
1. Run it 3 times with the same input -- are outputs consistent? (pass^3)
2. Run it with an edge case input -- does it handle gracefully?
3. Run it with adversarial input -- does it stay within constraints?
4. Check token count -- can you say the same thing with fewer tokens?
