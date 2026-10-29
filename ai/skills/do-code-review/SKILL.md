---
name: do-code-review
description: Revisión objetiva de una o varias PRs (o un stack), con findings en español y comentarios de GitHub en inglés.
disable-model-invocation: true
---

# do-code-review

The user passes one or more PR URLs or numbers. Review them one at a time, objectively. Each finding comes with a concrete **failure scenario**: inputs or state, then the wrong result. Talk to the user in Spanish. Write every GitHub comment in English.

**Focus:** logic, business logic, and data fetching. Leave visuals, spacing, copy, and a11y polish out unless the user asks for them.

## 1. Map the PRs

Run `gh pr view <n> --json title,body,baseRefName,headRefName,headRefOid,additions,deletions,files` for each PR.

If the PRs form a stack (one PR's base is another PR's head), put them in merge order, starting from the PR that targets `main`. Tell the user the order. If the PR they handed you first is not the base, point that out.

Done when: you know the review order and roughly what each PR touches.

## 2. Review one PR

1. **Read the diff.** Get it with `gh pr diff <n>` and save it to the scratchpad. Split source from tests and read the source first. In a stack, each diff is incremental against its parent PR.
2. **Read full files at the PR head**, not only the hunks:
   ```bash
   H=$(gh pr view <n> --json headRefOid -q .headRefOid); git fetch -q origin "$H"; git show "${H}:path/to/file"
   ```
   In zsh, write `"${H}:path"` with braces. Without them, `$H:s…` is read as a zsh modifier and the command breaks.
3. **Trace every changed function to its callers and to the code that consumes its data.** Check claims against the source of truth:
   - `schema.graphql` for return types. A query and a mutation can return different node types (for example `PropertyNode` vs `BorrowerPropertyNode`). In that case Apollo does not update the cache automatically.
   - Mutation input semantics, for example `replaceTypes` and `desiredTypes`.
   - The backend repo, when one is available.
4. **Apply the lens.** Look for:
   - Data loss or overwrites. Watch whole-array writes, and stale fields carried over (ids, extensions) when an empty or legacy record is reused.
   - Display and editor resolving to different records.
   - Edge cases with legacy, null, empty, or whitespace data, and with typed vs untyped records.
   - Apollo issues:
     - an update mutation that doesn't return the fields the query reads;
     - a `refetchQueries` the cache makes unnecessary, which gets worse when it runs on every autosave;
     - a create mutation without `cache.evict` + `cache.gc()`;
     - queries that run on mount before anyone opens the UI that needs them.
   - Race conditions with rapid actions or switching entities, refs written during render, and orphaned records when a create step succeeds but the follow-up step fails.
   - Permission or role gating, and analytics that fire on failure or fire twice.
   - Client-side filtering or sorting over data that should be filtered or sorted on the backend.
   - Edits to the repo's protected paths (see `CLAUDE.md`).
5. **Decide what is intentional.** When the PR body or the user says a behavior change is on purpose (for example a field becoming read-only), record it as a note, not a finding.

Done when: every changed source file has been read at the head, and every finding has a file:line and a failure scenario you traced yourself.

## 3. Report the PR (in Spanish), then stop

Use this format:

- **What it changes:** one or two lines on the logic.
- **Lo que está bien:** only when it's useful, for example the data fetching is correct.
- **Findings,** most severe first. Each one gets a short title, file:line, the failure scenario, and whether it blocks. Mark minor ones as menor or nit.
- **Comentarios propuestos:** the full text of each one, in English, one or two lines, ending in a clear action item. Prefix non-blocking ones with `nit: `. Say which line each one goes on.
- **Verdict:** aprobar / aprobar con nits / pedir cambios.

End by asking which comments to post and whether to approve.

Done when: the user can see the exact comment text before anything gets posted. Post and approve only after the user answers in chat. Approval for one PR covers that PR only.

## 4. Post what the user approved

Inline comment, anchored to the PR head:

```bash
H=$(gh pr view <n> --json headRefOid -q .headRefOid)
gh api repos/<owner>/<repo>/pulls/<n>/comments -f commit_id="$H" -f path=<file> -F line=<line> -f side=RIGHT -f body="<comment>" -q .html_url
```

Find `<line>` by grepping the file at `$H`, never from the diff hunk numbers. Approve with `gh pr review <n> --approve`. Return the comment links to the user, then move to the next PR.

## Several PRs at once

When the user asks to delegate, send the remaining PRs to one `reviewer` subagent in the background. Its prompt should include:

- this lens and the same output format;
- any known findings to re-verify;
- an explicit instruction not to post, approve, or modify anything.

Before relaying its findings, spot-check its strongest claims in the code. Then report in the step-3 format and ask, as in step 3.

## Follow-ups

When the author replies "Fixed in `<sha>`", run `git fetch origin <sha>` and `git show <sha>`. Verify the fix against the original failure scenario before approving.

When the user asks how the review stands, rebuild the status table:

```bash
gh pr view <n> --json reviewDecision,mergeable
```

Show `#`, PR, review state (open comments and whether the author replied), and GitHub state. Then list what is still left to fix or approve.
