# Refreshing the ethanize ruleset

Run this when the ruleset has fallen behind Ethan's merged work. Assume no memory of the original mine; everything you need is in `skills/ethanize/`.

## 1. Read the watermark

`skills/ethanize/reference/watermark.md` records what the ruleset was mined from.

```
| repo | highest PR mined | merged        | mined on   |
|------|------------------|---------------|------------|
| bp2  | 7724             | 2026-08-24    | 2026-08-25 |
| memo | 798              | 2026-08-22    | 2026-08-25 |

mined PRs: 127 (see reference/prs.txt)
validation baseline: 30% (10/33 in-scope, leave-one-out — see reference/validation.md)
```

Store **both** the number and the merge date: the number is the exact resume point and
dedupes, the date catches a long-lived branch that merged *after* a higher-numbered one
and would otherwise be skipped forever. Rewrite this file at the end of every refresh — it
is the only state that matters.

## 2. Mine incrementally

```bash
# --search is the reliable date filter; -L is a ceiling, not a target.
for r in borrower-portal-v2:2026-08-24 memo:2026-08-22; do
  gh pr list --repo "levco/${r%%:*}" --author ethanrblank --state merged \
    --search "merged:>=${r##*:}" -L 100 --json number,title,mergedAt,files
done
```

Drop anything already in `reference/prs.txt`, then filter:

- **Mine** if the title carries `feat:`, `fix:`, `style:`, or `refactor:` **and** the changed files include `.tsx`, `.css`, or a `*Settings|*Panel|*Menu|*Card` module.
- **Skip** anything touching only `.claude/`, `.cursor/`, `.codex/`, `worktree-*.sh`, `AGENTS.md`, `*.yaml`, `bun.lock`, `.npmrc`, `agents/*.md`, `documentation/`. Tooling and hook PRs carry no taste (bp2#7105, #7714, memo#795 are the pattern).
- **Skip** pure backend/GraphQL gating, and reverts.
- **Always mine** a `DES-*` PR, however small. Those are pure taste.

Extract per the brief at `skills/ethanize/reference/BRIEF.md` — the original mining
instructions, output format, and category list. **On the first refresh, copy `BRIEF.md`
into the skill directory if it isn't there**; it currently lives only in a scratchpad and
will not survive. One findings file per PR → `reference/findings/<repo>-<pr>.md`; append
the PR to `reference/prs.txt`.

Read his **review-thread replies** as well as PR bodies (`gh api
repos/levco/<r>/pulls/<n>/comments`) — his replies to bot review comments are the densest
rationale in the corpus, and where he states rules outright.

## 3. Land new rules

| Category | File | ID prefix |
|---|---|---|
| spacing, radius, border, shadow, color-token, typography, icon, density | `reference/visual.md` | `V` |
| state, hover, focus, keyboard, a11y, motion, perf-felt | `reference/interaction.md` | `I` |
| hierarchy, interaction-pattern, component-choice, overflow, loading, empty-state, responsive | `reference/patterns.md` | `P` |
| copy | `reference/copy.md` (+ `copy-allowlist.md` for new Title Case terms) | `C` |
| consequential actions, confirmation, receipts, multi-step, forms | `reference/flows.md` | `F` |
| his own framing, verbatim | `reference/his-words.md` | `Q` |

**Append. Never renumber.** The checklist cites IDs, and so does every dry-run report a
human has already read — renumbering silently invalidates both. Mark a superseded rule
`SUPERSEDED by <id>` in place and leave it.

> **One-time normalization owed.** The prefixes above are the intended scheme, applied
> unevenly at authoring time: `visual.md` numbers its rules `C1…` (collides with copy);
> `flows.md` and `his-words.md` use `F`/`Q` correctly; `interaction.md`, `patterns.md`, and
> `copy.md` have no IDs. Normalize once, before the first append, recording the old→new
> mapping at the top of each file. Not piecemeal.

New rules arrive with a **trigger clause** — "fires when the diff contains X" — not just a
destination. Endpoint-only rules are the ruleset's largest fixable gap (`validation.md`
§G2); a rule with no trigger is not detectable and cannot enter the checklist.

## 4. Re-rank the checklist

`reference/checklist.md` holds **48 checks in 5 tiers — a budget, not a coincidence.** An
unbounded checklist is an ignored checklist. Rank by expected value: **frequency × how much he cares × how cheaply it's detected.**
Frequency = how many findings files carry the rule. Cares = whether he explained it in
prose or repeated it across PRs. Detection cost = whether one `rg` finds it.

- A new rule enters at the tier its expected value earns, **not** Tier 1 because it is new.
- **Promoting into Tier 1 (1–12) requires demoting something out of it.** Name both in the refresh summary.
- A rule that fires where Ethan demonstrably declined (`validation.md` §N2) gets a scope clause naming where it does *not* apply, or it is deleted. Precision before recall: a check that tells you to add the skeleton he would delete is worse than silence.
- Never add a check for anything tooling enforces, or that `airy-rules/*` / `agents/*.md` already own. Cite those; don't restate.

## 5. Re-validate

Re-run the leave-one-out method in `reference/validation.md`, adding one or two cases:

1. Find a `feat:` PR by a **non-Ethan** author that Ethan polished in a follow-up days later.
2. Exclude the findings file for **his** follow-up. Scoring with it included puts every case near 90% and means nothing.
3. Score only the **intersection of changed files**; list his out-of-scope changes separately.
4. Count: of the changes he actually made, how many would the ruleset have flagged?

**The current honest baseline is 30% (10 of 33 in-scope).** State the new number in
`watermark.md` next to the old one.

**If a refresh does not move that number up, the new rules are noise — revert them.** If it
moves *down*, a new rule is firing wrongly: find it, scope it, or delete it. Never ship a
refresh on the grounds that it added rules. Rule count is not the metric.

Some misses are permanent: rendered-layout mechanics that only exist in a browser (~40% of
misses) and product-flow judgment. `validation.md` declares both out of scope — keep them
there rather than chasing them.

## 6. Cadence and cost

**Monthly, or once ~15 new mineable PRs have accumulated — whichever comes first.** Weekly
is churn: one polish PR rarely changes a rule's rank, and re-validating costs more than it
returns.

The initial mine ran ~28 agent-batches over ~90 PRs — about one batch per three PRs, plus
synthesis. An incremental refresh is a fraction. Budget **8–12 agents**:

- 4–5 mining agents, ~3 PRs each, writing straight into `reference/findings/`.
- 1 per reference file the new findings actually touch (usually 2–4 of 6).
- 1 to re-rank the checklist and report the Tier 1 swaps; 1 to re-validate and rewrite `watermark.md`.

If a refresh needs more than 12, the watermark was left too long — shorten the interval rather than growing the batch.
