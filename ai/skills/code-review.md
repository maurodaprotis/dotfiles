---
name: code-review
description: Review code for quality, bugs, security, and best practices
---

# Code Review

When reviewing code, check for:

1. **Correctness** — Does the code do what it's supposed to?
2. **Security** — Any injection, XSS, CSRF, or auth issues?
3. **Performance** — Unnecessary loops, N+1 queries, missing indexes?
4. **Readability** — Clear naming, reasonable function length, no clever tricks?
5. **Error handling** — Are failures handled gracefully at system boundaries?

Format your review as:
- A short summary (1-2 sentences)
- A list of issues grouped by severity: critical, warning, suggestion
- For each issue: file, line, what's wrong, and a fix
