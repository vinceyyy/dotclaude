# TypeScript Rules

## Tooling

- **Linting/Formatting**: Biome (replaces ESLint + Prettier)
- **Testing**: Vitest (unit), Playwright (E2E)
- **Package manager**: npm or pnpm (project preference)

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
