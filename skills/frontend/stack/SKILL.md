---
name: frontend-stack
description: Reference guide for the recommended 2026 frontend stack. Consult when starting a new frontend project, choosing libraries, or making technology decisions. Covers frameworks (Next.js 15, Vite, React 19), styling (Tailwind CSS v4), components (shadcn/ui, Aceternity, Magic UI), animation (Motion v12, GSAP), state management (Zustand, TanStack Query), testing (Playwright, axe-core), icons, fonts, data visualization, rich text editors, drag-and-drop, and real-time tools.
allowed-tools: Read, WebSearch, WebFetch
---

# Frontend Stack Reference (2026)

Consult this guide when making frontend technology decisions. $ARGUMENTS

## Recommended Default Stack

```
Framework:      Next.js 15 (App Router) or Vite + React 19
Language:       TypeScript (strict mode)
Styling:        Tailwind CSS v4 (CSS-first config via @theme)
Components:     shadcn/ui (Radix or Base UI foundation)
State:          Zustand (client) + TanStack Query v5 (server)
Animation:      Motion v12 (framer-motion) + AutoAnimate (lists)
Icons:          Lucide (default) or Phosphor (more variety)
Linting:        Biome v2 (replaces ESLint + Prettier, 15-20x faster)
Testing:        Playwright (visual) + axe-core (accessibility)
Build:          Vite 6 or Turbopack (Next.js)
Fonts:          next/font/google (self-hosted, zero CLS)
```

## Component Libraries (by use case)

| Use Case | Library | Why |
|---|---|---|
| General app UI | **shadcn/ui** | Own every file, Radix/Base UI foundation |
| Animated components | **React Bits** | 110+ animated components, #1 Rising Stars 2025 |
| Landing pages | **MagicUI** + **AceternityUI** | High-impact hero sections, SaaS-ready |
| Motion primitives | **Motion Primitives** | Text reveals, magnetic effects, stagger |
| Smooth animations | **SmoothUI** | Drop-in animated shadcn replacements |
| Batteries-included | **Mantine** | 100+ components + 50 hooks, date pickers, rich text |
| Tailwind-only | **daisyUI v5** | 34kB CSS, zero JS, Tailwind v4 native |
| Dashboards | **Tremor** | Charts + data viz on shadcn + Recharts |

## Animation Decision Tree

```
Need list/table animations?     -> AutoAnimate (zero config, one ref)
Need page transitions?          -> CSS View Transitions API (native)
Need scroll-triggered reveals?  -> CSS scroll-driven animations (no JS)
Need complex orchestration?     -> Motion v12 (framer-motion)
Need timeline/scroll effects?   -> GSAP + ScrollTrigger
Need simple hover/entrance?     -> Tailwind v4 transition utilities
```

## Font Recommendations

**Display/Headings:** Playfair Display, Fraunces, Clash Display, Satoshi, Cabinet Grotesk, Syne
**Body:** Space Grotesk, IBM Plex Sans, General Sans, DM Sans, Source Sans 3
**Monospace:** JetBrains Mono, Fira Code, IBM Plex Mono
**Sources:** Google Fonts (free), Fontshare (free), fonts.bunny.net (privacy-focused)

## State Management Decision Tree

```
Simple global state?            -> Zustand
Atomic/granular state?          -> Jotai
Server/API data?                -> TanStack Query v5
Form state?                     -> React Hook Form + Zod
URL state?                      -> TanStack Router (searchParams)
Real-time collaboration?        -> Liveblocks or PartyKit
```

## Data Visualization

| Library | Best For |
|---|---|
| **Tremor** | Dashboard charts, quick setup, shadcn-compatible |
| **Recharts** | Custom charts, full control, React-native API |
| **Nivo** | Complex/custom viz, D3-powered |
| **Observable Plot** | Exploratory data viz, concise API |

## Rich Text Editors

| Editor | Best For |
|---|---|
| **Tiptap** | Production apps, extensible, collaborative |
| **Plate** | shadcn-styled editor components |
| **Lexical** | Meta-backed, lightweight, custom editors |

## Drag & Drop

**dnd-kit** -- the standard. Accessible, performant, React 19 compatible.

## Real-Time

| Tool | Best For |
|---|---|
| **Liveblocks** | Multiplayer UI (cursors, presence, comments) |
| **PartyKit** | Edge-deployed Yjs sync (now Cloudflare) |
| **Socket.IO** | Traditional WebSocket (simpler needs) |

## Icons

| Library | Count | Style |
|---|---|---|
| **Lucide** | 1700+ | Clean strokes (shadcn default) |
| **Phosphor** | 1000+ x 6 weights | Versatile, weight variations |
| **Heroicons** | 292 | Tailwind-native |
| **React Icons** | 50,000+ | Maximum variety |

## CSS Patterns (Tailwind v4)

**Setup (Vite):**
```bash
npm install tailwindcss @tailwindcss/vite
```

**Config in CSS (no tailwind.config.js needed):**
```css
@import "tailwindcss";
@theme {
  --color-brand: oklch(0.6 0.2 250);
  --font-display: "Playfair Display", serif;
}
```

## Performance Checklist

- [ ] React Compiler enabled (auto-memoization)
- [ ] Images optimized (next/image or sharp)
- [ ] Fonts self-hosted (next/font/google)
- [ ] Bundle analyzed (vite-bundle-analyzer)
- [ ] Lighthouse CI > 90 performance score
- [ ] Core Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1

## Accessibility Checklist

- [ ] axe-core in dev mode (zero false positives)
- [ ] eslint-plugin-jsx-a11y configured
- [ ] Keyboard navigation tested
- [ ] Focus rings visible
- [ ] Color contrast WCAG AA (4.5:1 text, 3:1 UI)
- [ ] Screen reader tested (VoiceOver / NVDA)
- [ ] prefers-reduced-motion respected
