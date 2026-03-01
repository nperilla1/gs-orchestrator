---
name: ui-verify
description: Visual UI verification loop using browser automation. Takes screenshots of the running frontend at multiple viewports, compares against design intent, identifies layout breaks and visual issues, and auto-fixes them. Use after building or modifying UI components to verify they render correctly. Requires a dev server running on localhost. Covers layout, typography, color, spacing, responsive, missing states, animation, and accessibility checks.
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

# UI Visual Verification Loop

You are performing visual verification of a frontend implementation. This creates a closed feedback loop where you can SEE your work and fix issues.

## Target
$ARGUMENTS
(If no target specified, verify the main page of the running dev server)

## Step 1: Ensure Dev Server is Running

Check if a dev server is running:
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || \
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 2>/dev/null || \
curl -s -o /dev/null -w "%{http_code}" http://localhost:4321 2>/dev/null
```

If not running, start it in the background:
```bash
npm run dev &
# Wait for server to be ready
sleep 3
```

## Step 2: Take Screenshot via Agent Browser

Use agent-browser (token-efficient) for structural verification:
```bash
agent-browser navigate http://localhost:3000
agent-browser snapshot
```

Or use Playwright MCP for pixel-accurate screenshots (if available).

## Step 3: Analyze What You See

Check for these common issues:
1. **Layout breaks** -- overflow, collapsed elements, wrong grid alignment
2. **Typography** -- wrong font loading, size hierarchy issues, line-height problems
3. **Color** -- contrast issues, wrong theme application, inconsistent palette
4. **Spacing** -- cramped elements, inconsistent padding/margins
5. **Responsive** -- elements that break at different widths
6. **Missing states** -- hover, focus, active, disabled, loading, empty, error
7. **Animation** -- janky transitions, missing entrance animations
8. **Accessibility** -- missing focus rings, insufficient contrast, no alt text

## Step 4: Fix Issues

For each issue found:
1. Identify the exact file and component
2. Make the fix
3. Wait for HMR to update
4. Re-screenshot to verify the fix

## Step 5: Multi-Viewport Check

Test at key breakpoints:
```bash
# Mobile
agent-browser navigate http://localhost:3000 --viewport 375x812

# Tablet
agent-browser navigate http://localhost:3000 --viewport 768x1024

# Desktop
agent-browser navigate http://localhost:3000 --viewport 1440x900
```

## Step 6: Accessibility Audit

If axe-core is installed:
```bash
npx @axe-core/cli http://localhost:3000
```

## Iteration

Repeat Steps 2-4 until the UI matches design intent. Typically takes 2-3 iterations to reach excellent quality.

## Output

Report:
- Screenshots taken and viewport sizes checked
- Issues found and fixed (with file:line references)
- Remaining known issues (if any)
- Accessibility audit results
