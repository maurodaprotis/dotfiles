---
name: refactor
description: Refactor code while preserving behavior
---

# Refactor

When refactoring:

1. **Preserve behavior** — No functional changes unless explicitly requested
2. **Small steps** — One transformation at a time, each independently verifiable
3. **No gold-plating** — Don't add features, abstractions, or "improvements" beyond the ask
4. **Test coverage** — Ensure existing tests still pass; add tests only if coverage is missing for the refactored path
5. **Explain trade-offs** — If the refactor has downsides, call them out
