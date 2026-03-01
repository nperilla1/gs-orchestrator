---
name: scaffold-frontend
description: Scaffold a new frontend project with the recommended 2026 stack. Sets up Next.js 15 or Vite + React 19 with Tailwind CSS v4, shadcn/ui, Motion (framer-motion), TypeScript strict mode, Biome linting, and proper project structure. Use when starting any new frontend project, dashboard, or web application from scratch.
allowed-tools: Bash, Write, Edit, Read, Glob
---

# Scaffold Frontend Project

Create a production-ready frontend project with the recommended stack.

## Arguments
$ARGUMENTS
(Expected: project name, and optionally: framework choice, aesthetic direction)

## Framework Selection

Ask the user if not specified:
- **Next.js 15** (default) -- SSR, App Router, Server Components, best for full apps
- **Vite + React** -- SPA, faster dev server, best for dashboards/tools/internal apps

## Scaffold Steps

### 1. Create Project

**Next.js:**
```bash
npx create-next-app@latest $PROJECT_NAME --typescript --tailwind --app --src-dir --import-alias "@/*" --turbopack
cd $PROJECT_NAME
```

**Vite + React:**
```bash
npm create vite@latest $PROJECT_NAME -- --template react-ts
cd $PROJECT_NAME
npm install
```

### 2. Tailwind CSS v4

For Vite projects (Next.js already includes Tailwind):
```bash
npm install tailwindcss @tailwindcss/vite
```

Update `vite.config.ts`:
```ts
import tailwindcss from '@tailwindcss/vite'
export default defineConfig({
  plugins: [react(), tailwindcss()]
})
```

Create/update `src/index.css`:
```css
@import "tailwindcss";

@theme {
  /* Override with project-specific tokens */
  --font-display: "Playfair Display", serif;
  --font-body: "Space Grotesk", sans-serif;
  --font-mono: "JetBrains Mono", monospace;
}
```

### 3. shadcn/ui

```bash
npx shadcn@latest init
```

Select: TypeScript, default style, CSS variables for colors.

Add essential components:
```bash
npx shadcn@latest add button card input label dialog dropdown-menu separator sheet toast
```

### 4. Motion (Animation)

```bash
npm install motion
```

### 5. AutoAnimate (List Animations)

```bash
npm install @formkit/auto-animate
```

### 6. Icons

```bash
npm install lucide-react
```

### 7. TypeScript Strict Mode

Ensure `tsconfig.json` has:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

### 8. Biome (Linting + Formatting)

```bash
npm install --save-dev @biomejs/biome
npx biome init
```

Update `biome.json`:
```json
{
  "formatter": { "enabled": true, "indentStyle": "space", "indentWidth": 2 },
  "linter": { "enabled": true },
  "javascript": { "formatter": { "quoteStyle": "single", "semicolons": "asNeeded" } }
}
```

Add to `package.json` scripts:
```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --fix .",
    "format": "biome format --write ."
  }
}
```

### 9. Fonts (Google Fonts)

**Next.js:**
```ts
// src/app/layout.tsx
import { Playfair_Display, Space_Grotesk, JetBrains_Mono } from 'next/font/google'

const display = Playfair_Display({ subsets: ['latin'], variable: '--font-display' })
const body = Space_Grotesk({ subsets: ['latin'], variable: '--font-body' })
const mono = JetBrains_Mono({ subsets: ['latin'], variable: '--font-mono' })

export default function RootLayout({ children }) {
  return (
    <html className={`${display.variable} ${body.variable} ${mono.variable}`}>
      <body>{children}</body>
    </html>
  )
}
```

**Vite:** Add Google Fonts link to `index.html`.

### 10. Project Structure

```
src/
├── app/                    # Next.js App Router (or pages/)
│   ├── layout.tsx          # Root layout with fonts + providers
│   ├── page.tsx            # Home page
│   └── globals.css         # Tailwind + theme tokens
├── components/
│   ├── ui/                 # shadcn components (auto-generated)
│   ├── layout/             # Header, Footer, Sidebar, Nav
│   └── shared/             # Reusable project components
├── hooks/                  # Custom React hooks
├── lib/                    # Utilities, API client, constants
└── types/                  # TypeScript type definitions
```

### 11. Create CLAUDE.md for the Project

Write a `.claude/` directory with project-specific rules so future Claude Code sessions know the stack.

### 12. Verify Setup

```bash
npm run dev
# Verify at http://localhost:3000 (Next.js) or http://localhost:5173 (Vite)
```

Use `/ui-verify` to take a screenshot and confirm everything renders correctly.
