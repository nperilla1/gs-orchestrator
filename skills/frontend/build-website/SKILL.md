---
name: build-website
description: Build a complete, beautiful, deployed website from scratch using a structured 6-phase pipeline. Asks 3-5 guiding questions, proposes 3 distinct style options with OKLCH palettes and font pairings, generates a design brief, then uses parallel agents to build foundation, hero, content sections, and footer simultaneously. Handles deployment to Vercel or Cloudflare Pages. For company sites, product pages, blogs, marketing pages, and campaigns. Use /frontend for web apps and dashboards instead. Integrates with the Website Manager API for build tracking.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, WebSearch, WebFetch, Skill
---

# Build Website

You are building a complete, beautiful, production-ready website from scratch. This skill handles company sites, product pages, blogs, marketing pages, and campaigns -- NOT web apps or dashboards (use `/frontend` for those).

**Arguments:** $ARGUMENTS

## Reference Knowledge

Before starting, read the embedded trend knowledge:
```
Read file: skills/frontend/build-website/website-trends.md
```
This contains current best practices for typography, color, animation, components, and layout. Use it to inform all design decisions.

If `--research` flag is present in arguments, ALSO run 3-5 web searches for current design trends in the user's specific industry before proceeding to Phase 2. Focus on: Awwwards sites in their space, competitor design quality, trending aesthetics for their audience.

---

## API Integration

This skill integrates with the Website Manager API to track builds and register sites.

**API Base URL:** `https://sites.grantsmiths.com` (or `http://localhost:8100` for local dev)

### At the start of each build (after Phase 1 DISCOVER):

Create the build job via the API so the dashboard can track progress:

```bash
API_URL="https://sites.grantsmiths.com"

# Get auth token
TOKEN=$(curl -s -X POST "$API_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@grantsmiths.com","password":"SitesAdmin2026"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# Create build job (auto_build=false -- skill controls the process)
JOB=$(curl -s -X POST "$API_URL/api/build" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"SITE_NAME","display_name":"DISPLAY_NAME","purpose":"PURPOSE","audience":"AUDIENCE","vibe":"VIBE","pages":["PAGES"],"auto_build":false}')

JOB_ID=$(echo "$JOB" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
SITE_ID=$(echo "$JOB" | python3 -c "import sys,json; print(json.load(sys.stdin)['site_id'])")
```

### During each phase, report progress:

```bash
curl -s -X PATCH "$API_URL/api/build/$JOB_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"status":"building","progress_message":"Generating hero section..."}'
```

### After deployment, register with the site manager:

```bash
# Run health checks on the new site
curl -s -X POST "$API_URL/api/sites/$SITE_ID/health/run" \
  -H "Authorization: Bearer $TOKEN"

# Run security scan
curl -s -X POST "$API_URL/api/sites/$SITE_ID/security/run" \
  -H "Authorization: Bearer $TOKEN"

# Mark build complete
curl -s -X PATCH "$API_URL/api/build/$JOB_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"status":"complete","result":{"deploy_url":"DEPLOYED_URL","pages_created":N}}'
```

**Note:** Replace SITE_NAME, DISPLAY_NAME, PURPOSE, AUDIENCE, VIBE, PAGES, DEPLOYED_URL, N with actual values from the build session.

---

## Phase 1: DISCOVER

Ask these questions. Use multiple choice where possible. Ask ALL questions in a single call (up to 4 questions per call, so split into 2 calls if needed).

**Call 1:**
1. **What is this site for?** (free text -- company name, product, campaign, purpose)
2. **Who's the audience?** (Developers & technical / Business executives / Consumers & general public / Creative professionals / Other)
3. **What's the vibe?** (Bold & energetic / Clean & professional / Warm & approachable / Dark & premium / Playful & creative / Other)

**Call 2:**
4. **How many pages?** (Single landing page / 3-5 pages (Home, About, Features, Pricing, Contact) / Full site with blog / Other)

Also ask if they have any reference sites they love, or specific requirements.

---

## Phase 2: PROPOSE

Using the answers from Phase 1 + the trend knowledge from website-trends.md, generate **3 distinct style proposals**.

Each proposal should include:

### Proposal Format
```
# [Creative Name] -- e.g., "Midnight Editorial"

## Aesthetic
[One of: Brutally minimal / Editorial / Retro-futuristic / Organic / Luxury / Glassmorphism / Cyberpunk / Art deco / Solarpunk / Neobrutalist -- or a custom blend]

## Colors (OKLCH)
bg:      oklch(...)
surface: oklch(...)
text:    oklch(...)
accent:  oklch(...)
muted:   oklch(...)

## Typography
Display: [Font Name] -- "[Sample headline text]"
Body:    [Font Name] -- "[Sample body text]"
Mono:    [Font Name] (for code/accents)

## Layout Concept
[ASCII mockup of homepage -- header, hero, sections, footer]

## Animation Approach
- [e.g., "SplitText headline reveals on scroll"]
- [e.g., "Lenis smooth scroll + parallax depth layers"]
- [e.g., "Staggered card entrance with 0.1s delays"]

## Key Components
- Hero: [Aceternity Aurora Background + large serif headline]
- Social proof: [Magic UI Marquee for logos]
- Features: [Bento grid with scroll-triggered reveals]
- CTA: [Dark section + Motion animated button]
```

Make the 3 proposals genuinely DIFFERENT -- vary the aesthetic direction, color temperature, typography style, and layout approach. Do not make 3 minor variations of the same idea.

**IMPORTANT:** After the user picks a direction, ask ONE follow-up question:
> "Any adjustments to this direction? (e.g., 'warmer accent color', 'more whitespace', 'add a blog section')"

Incorporate their feedback before proceeding.

---

## Phase 3: DESIGN BRIEF

Auto-generate a `design_brief.md` in the project directory with ALL locked-in decisions:

```markdown
# Design Brief -- [Project Name]

## Aesthetic Direction
[chosen direction name and description]

## Colors
[all oklch values as CSS custom properties]

## Typography
[font names, weights, sizes, line-heights]
[Google Fonts / Fontshare URLs]

## Pages & Sections
[page-by-page breakdown with section types]
[which Aceternity/Magic UI/shadcn components per section]

## Animation Spec
[entrance animations, scroll behaviors, hover states]
[which libraries handle what]

## Responsive Strategy
[mobile-first, breakpoints, what changes at each]

## Technical Stack
[framework, hosting, CMS if needed]
```

Show the design brief to the user and ask for approval:
> "Here's the complete design brief. Ready to build, or any changes?"

Do NOT proceed to Phase 4 until the user approves.

---

## Phase 4: BUILD (Parallel Agents)

Once the design brief is approved, spawn parallel build agents using the Task tool.

### Agent 1: Foundation
```
Set up project scaffold, install deps, configure Tailwind v4 @theme with exact
colors from design brief, set up fonts, create base layout, verify with npm run dev.
```

### Agent 2: Hero + Navigation (runs AFTER Agent 1 completes)
```
Build hero section and navigation. Follow /frontend-aesthetics principles.
Use specified Aceternity/Magic UI components. Implement animations.
```

### Agent 3: Content Sections (runs AFTER Agent 1 completes)
```
Build all middle sections: features, social proof, how-it-works, pricing, CTA.
Each section gets scroll-triggered entrance animations.
```

### Agent 4: Footer + Secondary Pages (runs AFTER Agent 1 completes)
```
Build footer, secondary pages (About, Contact, Blog), 404 page.
Keep secondary pages simpler but visually consistent.
```

### Agent Orchestration
1. Launch Agent 1 (Foundation) and WAIT for it to complete
2. Launch Agents 2, 3, 4 in PARALLEL (all depend on Agent 1's scaffold)
3. **MID-BUILD CHECKPOINT:** When Agent 2 (Hero + Nav) completes, take a screenshot. Show to user:
   > "Here's the hero section. Does this match your vision? Any adjustments before I finish the rest?"
4. If user wants changes, send feedback to a follow-up agent to fix
5. Wait for Agents 3 and 4 to complete
6. Assemble: ensure all pages are properly linked, navigation works, all imports resolve

---

## Phase 5: VERIFY

1. **Start dev server** if not running
2. **Screenshot at 3 viewports** (375px mobile, 768px tablet, 1440px desktop)
3. **Check for issues:** layout breaks, font loading, color consistency, animation, responsive, missing states
4. **Accessibility audit:** `npx @axe-core/cli http://localhost:3000`
5. **Lint:** Run Biome check
6. **Fix all issues found**
7. **Re-screenshot and show user**

Iterate until the user approves.

---

## Phase 6: DEPLOY

1. **Initialize git** (if not already):
   ```bash
   git init && git add -A && git commit -m "Initial website build"
   ```
2. **Ask the user for confirmation before deploying:**
   > "Site is ready. Deploy to Vercel or Cloudflare Pages?"
3. **Deploy:**
   - **Vercel:** `npx vercel --prod`
   - **Cloudflare Pages:** `npx wrangler pages deploy`
4. **Report the live URL** to the user.
5. **If custom domain needed**, provide Cloudflare DNS instructions.

---

## Key Principles Throughout

- **Read website-trends.md** before every design decision -- it contains current best practices
- **Never use generic defaults** -- no Inter, no purple gradients, no cookie-cutter layouts
- **Every section needs animation** -- at minimum, scroll-triggered entrance reveals
- **Atmospheric backgrounds** -- layered gradients, noise, or patterns. Never solid colors.
- **The hero section is 80% of the first impression** -- spend the most effort here
- **Use Context7 MCP** before using any library API to get latest docs
- **Mobile-first** -- design for 375px, then expand. Not the other way around.
