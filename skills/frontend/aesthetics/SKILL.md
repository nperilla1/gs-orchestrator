---
name: frontend-aesthetics
description: Apply distinctive, anti-AI-slop frontend aesthetics to any UI work. Injects typography, color, motion, and background design principles that prevent generic-looking UIs. Auto-invokes when building React/Next.js/frontend components to ensure every interface is bold and distinctive. Covers font pairing, OKLCH color systems, framer-motion patterns, atmospheric backgrounds, layout rules, and 10 named aesthetic directions. Flags AI slop indicators like Inter font, purple gradients, and symmetric card grids.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Frontend Aesthetics -- Anti-AI-Slop Design System

You MUST commit to a BOLD aesthetic direction BEFORE writing any UI code. Never default to generic patterns.

## Typography Rules

**NEVER use:** Inter, Roboto, Arial, Open Sans, Lato, system-ui defaults
**USE instead:**

| Category | Fonts | Pairing With |
|---|---|---|
| Code/Technical | JetBrains Mono, Fira Code, IBM Plex Mono | Space Grotesk, IBM Plex Sans |
| Editorial | Playfair Display, Fraunces, Crimson Pro | Source Sans 3, Libre Franklin |
| Modern/Startup | Clash Display, Satoshi, Cabinet Grotesk | General Sans, Switzer |
| Luxury | Cormorant Garamond, Tenor Sans | Montserrat (light weights) |
| Playful | Bricolage Grotesque, Syne | DM Sans |

**Pairing rules:**
- High contrast: display serif + monospace body
- Extreme weight differences: 100 vs 900 in the same family
- 3x+ size jumps between heading levels (e.g., 14px body -> 48px h1)

**Concrete example -- Editorial direction:**
```css
/* DO: Bold contrast pairing */
h1 { font-family: 'Playfair Display', serif; font-weight: 900; font-size: 4rem; letter-spacing: -0.02em; }
body { font-family: 'IBM Plex Mono', monospace; font-weight: 400; font-size: 0.875rem; }

/* DON'T: Safe, forgettable pairing */
h1 { font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem; }
body { font-family: 'Inter', sans-serif; font-weight: 400; font-size: 1rem; }
```

## Color Rules

**NEVER use:** Purple gradient on white, blue-to-purple gradients, generic teal/coral
**DO use:**
- One dominant color with sharp accents (80/20 rule)
- oklch color space for P3 display vibrancy
- CSS custom properties for consistency
- Draw from: IDE themes (Dracula, Monokai, Nord), cultural aesthetics, nature

**Color system template:**
```css
:root {
  --bg-primary: oklch(0.15 0.02 250);      /* Deep, not pure black */
  --bg-surface: oklch(0.20 0.02 250);      /* Elevated surface */
  --text-primary: oklch(0.93 0.01 250);    /* Off-white */
  --accent: oklch(0.75 0.18 160);          /* Vivid accent */
  --accent-muted: oklch(0.45 0.10 160);    /* Subtle accent */
}
```

**Concrete example -- Dracula-inspired palette:**
```css
:root {
  --bg-primary: oklch(0.16 0.02 280);      /* Deep purple-black */
  --bg-surface: oklch(0.22 0.03 280);      /* Slightly lifted */
  --text-primary: oklch(0.95 0.01 280);    /* Near-white */
  --accent: oklch(0.78 0.20 330);          /* Electric pink */
  --accent-alt: oklch(0.72 0.16 145);      /* Cyber green */
  --accent-muted: oklch(0.55 0.12 250);    /* Soft purple */
}
```

## Motion Rules

**Use Motion (framer-motion) for React.** Focus on:
1. ONE high-impact orchestrated page-load with staggered reveals
2. `animation-delay` cascades for list/grid entry
3. Subtle hover state transitions (scale 1.02, shadow lift)
4. Scroll-triggered reveals (intersection observer or scroll-driven CSS)

**Pattern -- staggered page reveal:**
```tsx
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ delay: index * 0.08, duration: 0.5, ease: [0.25, 0.46, 0.45, 0.94] }}
/>
```

**Pattern -- hover lift with glow:**
```tsx
<motion.div
  whileHover={{ y: -4, boxShadow: '0 20px 40px oklch(0.75 0.18 160 / 0.15)' }}
  transition={{ type: 'spring', stiffness: 400, damping: 25 }}
/>
```

**One well-orchestrated moment beats scattered micro-interactions.**

## Background Rules

**NEVER use:** Solid white, solid gray, plain dark backgrounds
**DO use:**
- Layered CSS gradients (2-3 radial gradients with different positions)
- Noise/grain textures (via SVG filter or CSS)
- Subtle geometric patterns
- Dramatic shadows for depth
- Mesh gradients for hero sections

**Pattern -- layered background:**
```css
.bg-atmosphere {
  background:
    radial-gradient(ellipse at 20% 50%, oklch(0.25 0.08 250 / 0.6), transparent 50%),
    radial-gradient(ellipse at 80% 20%, oklch(0.20 0.06 300 / 0.4), transparent 40%),
    oklch(0.12 0.02 260);
}
```

**Pattern -- noise overlay:**
```css
.bg-grain::after {
  content: '';
  position: fixed;
  inset: 0;
  background: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
  opacity: 0.03;
  pointer-events: none;
  z-index: 1;
}
```

## Layout Rules

- Asymmetric grids over uniform grids
- Generous whitespace (more than feels comfortable)
- Break the grid intentionally for visual interest
- Full-bleed sections alternating with constrained content
- Cards with subtle border + shadow, not flat colored boxes

## Aesthetic Directions (pick ONE per project)

1. **Brutally minimal** -- monospace everything, raw borders, high contrast
2. **Editorial/magazine** -- serif headings, asymmetric layout, dramatic type scale
3. **Retro-futuristic** -- CRT effects, scanlines, neon on dark, pixel fonts
4. **Organic/natural** -- earth tones, rounded shapes, natural textures
5. **Luxury/refined** -- thin serif fonts, gold accents, generous spacing
6. **Glassmorphism** -- frosted glass panels, depth layers, subtle blur
7. **Cyberpunk/terminal** -- green-on-black, monospace, terminal UI metaphors
8. **Art deco** -- geometric patterns, gold/black, sharp angles
9. **Solarpunk** -- warm greens/golds, organic shapes, optimistic palette
10. **Neobrutalist** -- thick borders, bright blocks, deliberate roughness

## Anti-Patterns (AI Slop Indicators)

If you catch yourself doing any of these, STOP and redesign:
- Using Inter or Roboto
- Purple gradient hero section
- Identical card grids with rounded corners
- Generic "Get Started" CTA with no personality
- Stock photo placeholder circles for avatars
- Bland gray sidebar with blue active states
- Perfectly symmetric layouts everywhere
- Using `bg-white` or `bg-gray-100` as the page background
- Rounded-xl cards with drop-shadow-sm on a flat white page

$ARGUMENTS
