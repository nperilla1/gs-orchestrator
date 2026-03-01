---
name: brand-voice
description: Brand voice and tone enforcement system. Two modes -- (1) create a comprehensive brand voice guide for new clients with personality, tone spectrum, vocabulary, sentence structure, CTA style, approved examples, and anti-persona, or (2) check existing content against a brand voice guide and score compliance 0-100 across tone match, vocabulary, structure adherence, and overall feel. Flags violations and suggests specific rewrites. Use before publishing any marketing content or when onboarding new clients.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Brand Voice System

## Mode 1: Create Brand Voice Guide

If the user asks to create/define a brand voice, produce this template:

```markdown
# Brand Voice Guide: [CLIENT NAME]

## Personality (5 adjectives)
1. [e.g., Bold]
2. [e.g., Knowledgeable]
3. [e.g., Approachable]
4. [e.g., Witty]
5. [e.g., Direct]

## Tone Spectrum
- Formal <----[X]----> Casual
- Serious <----[X]----> Playful
- Technical <----[X]----> Simple
- Reserved <----[X]----> Enthusiastic

## Vocabulary
**Preferred terms:** [list 10-20 on-brand words]
**Prohibited terms:** [list 10-20 off-brand words]
**Industry jargon:** [include / define-before-use / avoid]

## Sentence Structure
- Average length: [short <15 / medium / long]
- Contractions: [yes/no]
- Voice: [active preferred / passive acceptable for X]
- Person: [first person "we" / second person "you" / third person]

## CTA Style
[imperative "Get started" / benefit-led "See your results" / question "Ready to grow?"]

## Approved Examples (Few-Shot Training)
### Example 1 -- [format]: [paste approved copy]
### Example 2 -- [format]: [paste approved copy]
### Example 3 -- [format]: [paste approved copy]

## Anti-Examples (DO NOT write like this)
### Bad 1: [paste rejected copy + note what's wrong]

## Anti-Persona
Never sound like: [competitor or archetype to avoid]
```

## Mode 2: Check Content Against Brand Voice

If the user asks to check/review content:

1. Find the brand voice guide (search for `brand-guide.md`, `voice.md`, or ask the user)
2. Score the content 0-100 across these dimensions:
   - **Tone match** (0-25): Does it sound like the brand?
   - **Vocabulary compliance** (0-25): Any prohibited words? Missing preferred terms?
   - **Structure adherence** (0-25): Sentence length, voice, person correct?
   - **Overall feel** (0-25): Would a brand expert approve this?
3. Output:
   - **Score**: X/100
   - **Verdict**: PASS (80+), NEEDS_REVISION (50-79), BLOCK (<50)
   - **Violations**: Specific issues with exact quotes
   - **Fixes**: Suggested rewrites for each violation

$ARGUMENTS
