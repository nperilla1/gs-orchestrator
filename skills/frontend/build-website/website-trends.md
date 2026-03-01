# Website Design Trends & Best Practices (2025-2026)

> Last updated: 2026-02-24 via /deep-research-swarm
> Refresh by running: /deep-research-swarm <website design trends 2026>

---

## Stack Recommendations

### For Marketing/Landing Pages (default)
```
Framework:    Astro 5 (zero JS default, View Transitions, fastest CWV)
Styling:      Tailwind CSS v4 (CSS-first @theme config, OKLCH colors)
Components:   shadcn/ui (base) + Aceternity UI (hero wow-factor) + Magic UI (marketing sections)
Animation:    GSAP + ScrollTrigger + Lenis (smooth scroll) + SplitText (text reveals)
Icons:        Lucide React
CMS:          Keystatic (Git-based, if blog needed)
Hosting:      Cloudflare Pages (free unlimited bandwidth)
```

### For Product Sites / Multi-Page (when SSR/dynamic needed)
```
Framework:    Next.js 15 (App Router, RSC, ISR)
Styling:      Tailwind CSS v4
Components:   shadcn/ui + Aceternity UI + Magic UI + Motion Primitives
Animation:    Motion (Framer Motion) + GSAP ScrollTrigger + Lenis
Icons:        Lucide React
CMS:          Payload CMS (self-hosted, free) or Sanity
Hosting:      Vercel
```

---

## Typography -- What's Trending

### Display/Headline Fonts (pick ONE per project)
| Font | Vibe | Source |
|------|------|--------|
| Satoshi | Modern startup, geometric, clean | Fontshare (free) |
| Clash Display | Bold, confident, attention-grabbing | Fontshare (free) |
| Cabinet Grotesk | Characterful, editorial weight | Fontshare (free) |
| Bricolage Grotesque | Playful, optical sizing, expressive | Google Fonts |
| Playfair Display | Elegant serif, editorial luxury | Google Fonts |
| Fraunces | Soft serif, warm, approachable | Google Fonts |
| Syne | Futuristic, geometric, distinctive | Google Fonts |
| DM Serif Display | Classic serif, high contrast | Google Fonts |
| Geist | Technical, Vercel-made, precise | Vercel (free) |

### Body Fonts (pair with display)
General Sans, Switzer, Space Grotesk, DM Sans, IBM Plex Sans, Source Sans 3

### Monospace (for code/technical accents)
JetBrains Mono, Fira Code, IBM Plex Mono, Geist Mono

### Pairing Rules
- Serif display + sans body (classic contrast)
- Geometric display + humanist body (modern warmth)
- 3x+ size jumps between heading levels (48px+ h1, 14-16px body)
- Use variable fonts for performance (one file, all weights)

### Font Sources
- **Fontshare** (fontshare.com) -- free for commercial use, privacy-friendly CDN
- **Google Fonts** -- largest collection, use via next/font for self-hosting
- **fonts.bunny.net** -- GDPR-compliant Google Fonts proxy

---

## Color -- Current Best Practices

### OKLCH Color Space (the new standard)
Tailwind v4 uses OKLCH natively. Perceptually uniform -- colors at the same lightness LOOK equally bright.

```css
@theme {
  /* Example: Dark premium palette */
  --color-bg: oklch(0.13 0.02 260);
  --color-surface: oklch(0.18 0.02 260);
  --color-text: oklch(0.93 0.01 260);
  --color-accent: oklch(0.75 0.18 160);
  --color-accent-muted: oklch(0.45 0.10 160);
}
```

### Color Strategy
- **80/20 rule**: One dominant color + one sharp accent
- **Draw from**: IDE themes (Dracula, Nord, Monokai), nature, architecture
- **Avoid**: Purple-on-white gradients, blue-to-purple, generic teal/coral
- Use `color-mix(in oklch, ...)` for dynamic variations in CSS
- Use relative color syntax for palette generation from one brand color

### Tools
- oklch.com -- interactive picker
- atmos.style -- UI palette builder in OKLCH

---

## Animation Techniques -- What Award-Winning Sites Use

### The Big 5 Techniques (Awwwards/FWA standard)
1. **SplitText + ScrollTrigger text reveals** -- THE most common award-winning technique. Split headlines into chars/words, stagger reveal on scroll.
2. **Pinned horizontal scroll sections** -- Pin a section, tween X while vertical scrolling. Portfolio showcases, feature tours.
3. **Smooth scroll + parallax** -- Lenis for butter-smooth scrolling, elements at different scroll speeds.
4. **Video scrubbing on scroll** -- Control video playback via scroll position (Apple-style).
5. **Staggered entrance animations** -- Elements cascade in with 0.08-0.12s delays on page load.

### Animation Stack
```
Smooth scrolling:     Lenis (3.5KB) -- the standard
Scroll-linked:        GSAP ScrollTrigger -- pin, scrub, batch
Text animation:       GSAP SplitText (now free) -- chars/words/lines
Timeline sequences:   GSAP -- complex choreography
React UI transitions: Motion (framer-motion) -- layout, gestures, exit
Page transitions:     View Transitions API (CSS native, baseline 2025)
List animations:      AutoAnimate (1.9KB) -- zero config
Entry animations:     CSS @starting-style (no JS needed)
```

### GSAP Is Now 100% Free
All plugins including ScrollTrigger, SplitText, MorphSVG, ScrollSmoother, DrawSVG, Flip -- all free after Webflow acquisition. Note: license restricts use in tools competing with Webflow.

### Motion (Framer Motion) -- For React Components
MIT license (irrevocable, no restrictions). Best for:
- Layout animations, AnimatePresence (exit animations)
- Gesture handling (whileHover, whileTap, whileDrag)
- Spring physics
- useScroll + useTransform for scroll-linked

### CSS-Native (No JS Needed)
- `animation-timeline: scroll()` -- scroll-driven animations (baseline 2025)
- `animation-timeline: view()` -- trigger when element enters viewport
- View Transitions API -- smooth page transitions
- `@starting-style` -- entry animations for dialogs/popovers

---

## Component Libraries for Wow Factor

### Aceternity UI (200+ animated components)
Best for hero sections and landing page wow-factor:
- Hero Parallax, 3D Card Effect, Spotlight, Sparkles
- Aurora Background, Beam Effects, Vortex
- Floating Dock (macOS style)
- Infinite Moving Cards (testimonials)
- Bento Grid, Wavy Background, Lamp Effect
- Text: Typewriter, Flip Words, Text Generate Effect
- **Install**: Copy from ui.aceternity.com + `npm install framer-motion clsx tailwind-merge`

### Magic UI (150+ animated components)
Best for marketing sections with refined motion:
- Marquee (infinite scroll logos)
- Animated List, Bento Grid
- Orbiting Circles, Globe
- Word Rotate, Blur In, Fade Up
- Number Ticker, Shimmer Button
- Device Mockups (browser, phone frames)
- **Install**: `npx magicui-cli@latest add <component>`

### Motion Primitives (30+ animated components)
Best for adding motion to existing shadcn/ui:
- Text Morph, Text Scramble, Text Shimmer
- Morphing Dialog, Magnetic, Tilt, Dock
- Glow Effect, Spotlight, Progressive Blur
- **Install**: Copy from motion-primitives.com

### shadcn/ui Blocks
Pre-built complete sections: dashboards, sidebars, login, marketing sections
- **Install**: `npx shadcn@latest add <block>`

---

## Background & Visual Depth

### Mesh Gradients
- fffuel.co/ffflux -- fluid gradient mesh SVGs
- MagicPattern mesh gradient generator
- CSS: layer 2-3 radial-gradient() calls at different positions

### Noise/Grain Texture
- fffuel.co/gggrain -- grain over gradients (analog feel)
- SVG filter: `<feTurbulence>` for CSS-only grain

### Patterns
- Hero Patterns (heropatterns.com) -- 80+ repeatable SVG patterns
- fffuel.co -- entire collection of SVG generators

### Atmospheric Backgrounds (CSS pattern)
```css
.bg-atmosphere {
  background:
    radial-gradient(ellipse at 20% 50%, oklch(0.25 0.08 250 / 0.6), transparent 50%),
    radial-gradient(ellipse at 80% 20%, oklch(0.20 0.06 300 / 0.4), transparent 40%),
    oklch(0.12 0.02 260);
}
```

---

## 3D & WebGL (When Appropriate)

### Spline -- No-code 3D for designers
- Browser-based 3D tool, embeddable via React component
- Best for: product viewers, interactive hero backgrounds
- `npm install @splinetool/react-spline`

### React Three Fiber -- Full 3D control
- Three.js in React JSX, separate render loop from DOM
- Drei: 200+ helpers (materials, cameras, controls)
- Best for: immersive experiences, particle systems, shader effects
- Heavy -- only use when 3D is central to the experience

### Unicorn Studio -- No-code WebGL effects
- 60+ GPU-accelerated 2D effects (gradients, blur, ripple, distortion)
- Embed in any site via script tag
- Best for: hero section visual effects without Three.js overhead

---

## Layout Patterns

### Award-Winning Layout Techniques
- **Bento grids** -- asymmetric tile layouts (Apple-inspired)
- **Full-bleed hero -> constrained content** -- alternating widths
- **Horizontal scroll within vertical** -- pinned showcase sections
- **Overlapping elements** -- break the grid intentionally
- **Generous whitespace** -- more than feels comfortable
- **Asymmetric two-column** -- text left, visual right (or vice versa), offset vertically

### Section Types for Marketing Sites
1. **Hero** -- full-viewport, atmospheric background, large serif headline, minimal CTA
2. **Social proof** -- logo marquee (Magic UI Marquee) or floating testimonial cards
3. **Features** -- bento grid or alternating left-right with scroll animations
4. **How it works** -- numbered steps with scroll-triggered reveals
5. **Testimonials** -- carousel or infinite moving cards (Aceternity)
6. **Pricing** -- 2-3 tier cards with generous whitespace
7. **CTA** -- dark/accent background, large text, single button
8. **Footer** -- minimal, dark, organized columns

---

## Hosting & Deployment

### Cloudflare Pages (recommended for static/Astro)
- Unlimited bandwidth, unlimited sites, free
- 500 builds/month free
- Workers for edge compute ($5/mo)
- D1 for database if needed
- Deploy: `npx wrangler pages deploy`

### Vercel (recommended for Next.js)
- Best Next.js support (they built it)
- Preview deployments on every PR
- $20/user/month (Pro)
- Deploy: `npx vercel --prod`

---

## Anti-Patterns to Avoid (AI Slop Markers)

- Inter, Roboto, Arial, Open Sans -- use distinctive fonts instead
- Purple gradient hero on white background
- Identical rounded card grids
- Generic "Get Started" / "Learn More" CTAs with no personality
- Stock photo circles for avatars
- Bland gray sidebar with blue highlights
- Perfectly symmetric everything
- Same gradient direction on every element
- Cookie-cutter feature grids with Heroicons
