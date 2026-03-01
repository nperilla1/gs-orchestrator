---
name: writing-skills
description: How to write effective SKILL.md files for Claude Code auto-discovery and invocation. Covers YAML frontmatter structure (name, description trigger text, allowed-tools), progressive disclosure pattern (overview then steps then details), imperative instruction style, concrete examples with code blocks, skill chaining, testing skills, and description optimization for auto-discovery matching. The description field is the most important part -- it determines when Claude auto-invokes the skill. Use when creating new skills or improving existing ones for the gs-orchestrator skill library.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Writing SKILL.md Files

You are creating or improving a SKILL.md file for Claude Code's skill system. Skills are auto-discovered based on their description field and invoked when matching tasks are detected.

## Target
$ARGUMENTS
(The skill to create or improve)

## SKILL.md Anatomy

### Frontmatter (YAML)

```yaml
---
name: skill-name
description: Comprehensive trigger description. This is the MOST IMPORTANT field -- it determines auto-discovery. Include all keywords, use cases, and contexts where this skill should activate. Be specific and exhaustive. Mention the tools, frameworks, patterns, and outcomes this skill handles.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---
```

**Fields:**
- `name` (required): Kebab-case identifier. Used for `/skill-name` invocation.
- `description` (required): The auto-discovery trigger. Claude matches user requests against this text. Make it comprehensive.
- `allowed-tools` (optional): Restrict which tools the skill can use. Omit for full access.
- `user-invocable` (optional): Set to `false` for reference-only skills that should not be directly invoked.

### Description Field -- The Critical Part

The description determines when Claude auto-invokes the skill. Write it like a search index entry:

**Bad description (too vague):**
```
description: Help with frontend work.
```

**Good description (comprehensive triggers):**
```
description: Apply distinctive, anti-AI-slop frontend aesthetics to any UI work. Injects typography, color, motion, and background design principles that prevent generic-looking UIs. Auto-invokes when building React/Next.js/frontend components to ensure every interface is bold and distinctive. Covers font pairing, OKLCH color systems, framer-motion patterns, atmospheric backgrounds, layout rules, and 10 named aesthetic directions.
```

**Rules for descriptions:**
- Include ALL keywords a user might use when asking for this skill
- Mention specific tools, libraries, and frameworks by name
- Describe the outcome, not just the process
- Include the trigger context ("Use when...", "Auto-invokes when...")
- Keep under 500 characters but be as comprehensive as possible

## Skill Body Structure

### Pattern: Progressive Disclosure

```markdown
# Skill Title

[1-2 sentence overview of what this skill does]

## Target
$ARGUMENTS
(What the user provides)

## Quick Start (the 80% case)
[3-5 steps for the most common use case]

## Full Process (detailed)
### Step 1: ...
### Step 2: ...

## Advanced (edge cases, customization)
[Less common patterns]

## Output
[What the skill produces]
```

### Imperative Instructions

Write in imperative mood. Tell Claude what to DO, not what it COULD do.

**Weak:**
```
You might want to check if the dev server is running before taking screenshots.
```

**Strong:**
```
Check if a dev server is running on localhost:3000 or localhost:5173. If not, start it before proceeding.
```

### Concrete Examples

Always include code blocks showing exact commands, file content, or output format:

```python
# Show the exact expected output format
def grade_output(output: str) -> dict:
    return {
        "score": 85,
        "verdict": "SHIP",
        "issues": ["Minor: missing docstring on line 42"]
    }
```

### $ARGUMENTS Placeholder

Use `$ARGUMENTS` where the user's input gets injected:

```markdown
## Target
$ARGUMENTS
(Expected: project name and optional framework choice)
```

## Skill Chaining

Skills can reference other skills:

```markdown
After building the component, verify it visually using the /ui-verify skill.
```

Or invoke them:

```markdown
## Step 5: Verify
Invoke the `/ui-verify` skill to screenshot and check the output.
```

## Testing Skills

After writing a skill:

1. **Trigger test**: Ask Claude something that should match the description. Does it auto-invoke?
2. **Execution test**: Run the skill manually with `/skill-name test-args`. Does it complete correctly?
3. **Edge case test**: Run with minimal arguments, no arguments, and unusual arguments.
4. **Chaining test**: If the skill references other skills, verify those invocations work.

## Common Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| Description too short | Add keywords, use cases, frameworks |
| No output format specified | Always show what the skill produces |
| Instructions in passive voice | Use imperative: "Run X", "Check Y" |
| No examples | Add code blocks with concrete examples |
| Monolithic wall of text | Use headers, lists, tables |
| Skill does too many things | Split into focused skills |
| Missing $ARGUMENTS | Always show where user input goes |
