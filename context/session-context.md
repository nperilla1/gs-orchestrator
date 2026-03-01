# Session Context

<!-- This file is populated dynamically by the bootstrap hook at session start. -->
<!-- It provides Claude with situational awareness about the current environment. -->

## Infrastructure Status

<!-- Filled by bootstrap.sh / check-connectivity.sh -->

| Component | Status | Details |
|-----------|--------|---------|
| SSH | <!-- STATUS --> | gs-production-v2 (52.72.246.186) |
| DB Tunnel | <!-- STATUS --> | localhost:5434 -> 172.18.0.12:5432 |
| Database | <!-- STATUS --> | gs_unified (18 schemas) |

## Current Project

<!-- Detected from cwd or state.json -->

- **Name**: <!-- PROJECT_NAME -->
- **Path**: <!-- PROJECT_PATH -->
- **Schema**: <!-- DB_SCHEMA -->
- **Branch**: <!-- GIT_BRANCH -->
- **Modified Files**: <!-- MODIFIED_COUNT -->

## Recent Instincts

<!-- Last 5 instincts from ~/.gs-orchestrator/instincts.jsonl -->

1. <!-- INSTINCT_1 -->
2. <!-- INSTINCT_2 -->
3. <!-- INSTINCT_3 -->
4. <!-- INSTINCT_4 -->
5. <!-- INSTINCT_5 -->

## Active Tasks

<!-- From TodoWrite or state file -->

- <!-- TASK_1 -->
- <!-- TASK_2 -->

## Session Notes

<!-- Any notes from pre-compact state recovery or previous session handoff -->

<!-- NOTES -->
