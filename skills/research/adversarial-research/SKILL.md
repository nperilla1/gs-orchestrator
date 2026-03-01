---
name: adversarial-research
description: Launch an adversarial research workflow where one agent researches a topic thoroughly and a second agent independently fact-checks all findings. The researcher gathers information from multiple sources and produces a draft, then the fact-checker verifies every claim using independent searches, flags unsupported assertions, checks for outdated information, identifies logical inconsistencies, and rates confidence (HIGH/MEDIUM/LOW) per finding. If corrections are needed, a third pass produces a verified final draft. Use for any research task where accuracy is critical and hallucinations must be caught.
allowed-tools: Task, Read, Write, WebSearch, WebFetch, Grep, Glob
---

# Adversarial Research Workflow

You are coordinating an adversarial research process. This uses two agents working in tension to produce verified, accurate research.

## Process

1. **Parse the research topic** from: $ARGUMENTS

2. **Create two tasks**:
   - Task A: "Research: [topic]" - Assigned to a researcher agent
   - Task B: "Fact-check: [topic]" - Assigned to a fact-checker agent, BLOCKED BY Task A

3. **Spawn the Research Agent** (via Task tool, subagent_type: researcher):
   Prompt: "Research the following topic thoroughly. Use WebSearch and WebFetch to gather information from multiple sources. Cite all sources. Produce a comprehensive draft with findings. Topic: [topic]. Write your findings to /tmp/research-draft.md"

4. **After researcher completes, spawn the Fact-Checker Agent** (via Task tool, subagent_type: researcher):
   Prompt: "You are a critical fact-checker. Read /tmp/research-draft.md. Your job is to:
   - Verify every claim using independent WebSearch queries
   - Flag any unsupported assertions
   - Check for outdated information
   - Identify logical inconsistencies
   - Rate confidence (HIGH/MEDIUM/LOW) for each finding
   Write your fact-check report to /tmp/fact-check-report.md with corrections needed."

5. **If corrections needed**, send the fact-check report back to a new researcher agent to produce a corrected final draft at /tmp/research-final.md

6. **Synthesize** the final verified research and present it to the user with confidence ratings and sources.

## Key Principles
- The fact-checker must use INDEPENDENT searches, not just validate the researcher's sources
- Every claim needs at least one corroborating source
- Flag any claim that cannot be independently verified
- The adversarial tension is the point -- it catches what single-agent research misses
