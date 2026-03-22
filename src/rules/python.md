# Python Rules

## Dependency Management

- **Package manager**: uv
- **ALWAYS use `uv add`** to add dependencies — never edit pyproject.toml directly
- Dev dependencies: `uv add --dev` or `uv add --group=<group>`

## Project Structure

- **Packages/libraries**: src layout (`src/package_name/`), include `py.typed` marker
- **Applications/ad-hoc projects**: Flat structure, no src layout needed

## Code Style

- **Python version**: 3.13+
- **Union syntax**: `X | None`, not `Optional[X]`
- **Line length**: 120 characters
- **Data**: Pydantic for all structured data — no raw dicts

## Tooling

- **Linting/Formatting**: Ruff
- **Type checking**: pyright
- **Testing**: pytest with pytest-asyncio (auto mode)
- **Run tests**: `uv run pytest`
