# TypeScript Rules

## Tooling

- **Toolchain**: Vite+ (`vp`) — unified CLI for dev server, builds, linting, formatting, testing, and package management
- **Linting/Formatting**: Oxlint + Oxfmt (included in Vite+, replaces ESLint + Prettier + Biome)
- **Testing**: Vitest (unit, included in Vite+), Playwright (E2E)
- **Type checking**: `vp check` runs formatting, linting, and type checking in one command
- **Package manager**: `vp install` / `vp add` (built into Vite+)
- **Config**: `vite.config.ts` using `defineConfig` from `vite-plus`
- **Docs**: Vite+ is new — always use Context7 MCP to fetch current docs before using `vp` commands or configuring `vite-plus`

## UI & Styling

- **UI Library**: shadcn/ui (Radix primitives)
- **Icons**: Lucide (`lucide-react`)
- **Styling**: Tailwind CSS v4
- **Class composition**: `cn()` utility (clsx + tailwind-merge)

## React Patterns

- **State**: Zustand for global state, `useShallow()` for re-render optimization
- **Hooks**: Extract reusable logic into custom hooks (`usePolling`, `useApi`)

## Project Structure

- **Path aliases**: `@/` maps to `src/`
- **File naming**: PascalCase for components, camelCase for utilities
- **Organization**: Group by feature (`components/chat/`, `components/layout/`)
