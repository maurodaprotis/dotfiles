---
name: ethanize
description: >
  Reviews a diff for UX/UI polish against the taste of Lev's designer (Ethan Blank)
  and either reports the findings or applies them. Dry run by default; `fix` applies.
  Trigger: When polishing a UI change before review, finishing a UI feature, or when
  asked to "ethanize", "make this look right", "polish this before Ethan sees it",
  or "check this for design nits".
license: Apache-2.0
metadata:
  author: lev
  version: '1.0'
  scope: [root]
  auto_invoke:
    - 'Ethanize this diff'
    - 'Polish this UI change before review'
    - 'Check my changes for design nits'
    - 'Make this surface look right'
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, AskUserQuestion, Task
---

# /ethanize

Approximates the polish pass Lev's designer runs on every UI PR, so his review time goes
to judgment calls instead of nits. Reports by default; applies on `fix`; asks when a call
is genuinely his to make.

## What it is worth — read this before trusting a run

Measured, not estimated (`reference/validation.md`, `reference/adversarial.md`).

- **~30% recall.** Replayed against real PRs it flagged **10 of 33** changes Ethan actually made.
  A first pass, not a substitute for him.
- **Strong on copy, a11y, loading-state choice, and reveal-state class strings; weakest on
  layout and pixel mechanics.**
- **Autofix was overstated at extraction.** Of ~116 rules tagged autofixable, **~19% were safe
  unattended as written**; after the remediation baked into `CHECKLIST.md` that is **~60%**, and
  the residue is `refactor` (reviewable), not `flag`.
- **It cannot see a surface it hasn't opened.** Every visual claim is unverified until a browser
  check runs. A skill that overstates itself gets run once and distrusted — say these numbers in
  the report.

## Pre-flight — stop before you "fix" a deliberate decision

**If the change you are about to make is one of these, leave it alone** — reversing something he
decided on purpose is this skill's worst failure mode. Reasoning: `reference/his-words.md` §1.

1. Editing any file under `src/components/ui/`, `src/components/airy-blocks/`,
   `src/components/lev-assets/`, `src/styles/airy-theme/`, `airy-rules/` — report it as
   upstream Airy, even for a real bug.
2. "Correcting" `levender` to `lavender` or `purple`. It is a deliberate brand misspelling.
3. Disabling a submit while an entitlement, eligibility, or credit check is pending — or
   moving the paid/free decision server-side. Fail closed; the user sees the cost state first.
4. Making a bulk-action count badge track the active choice, or deleting it. It reports
   availability.
5. Adding a timestamp (or any partial metadata) to an attribution line whose content is empty
   or failed.
6. Adding a "reasonable" selection tick, checkmark, or highlight that matches on attributes
   rather than an id. Absent beats wrong.
7. Replacing a `Loader2` with `MorphingLevIcon` / typing dots on a control that only
   *submits* — the animation belongs where the text will appear.
8. Making plain connector text inside a click target interactive, or wrapping the whole
   phrase in a button.
9. Reserving space or moving a hover overlay into flow for fine pointers. (Do check its
   `pointer-coarse:` branch drops into flow.)
10. Stripping `backdrop-blur` from `surface-glass`, a Spotlight scrim, or a deliberate
    paywall blur. The rule is sticky headers and scrims only.
11. Restoring a UI path a diff deliberately hid, or reporting "this doesn't match the ticket"
    when the PR names a follow-up issue.
12. Proposing a `role="button"` where a native `<button>` would do.

When one of these is genuinely wrong in context, the move is `flag` with his own reason
quoted back — never an edit.

## How he thinks

Ten principles, ranked by how much they predict. Apply to anything `CHECKLIST.md` doesn't cover.

1. **The UI makes a promise; a promise that isn't true is the bug, not the styling.** State it as a sentence and try to falsify it.
2. **Judge what an element *reads as*, not what it is.** Two states 5% apart read as an accident.
3. **A sentence can't express a shape.** Group, sort, or draw a relationship instead of describing it.
4. **Controls that are peers get one scale.** A panel that feels tall is a preview card beside a bare dot, not spacing.
5. **Success is silent; a dead end never is.** A shortfall or empty result must say so, or the feature looks broken.
6. **Delete the control that shouldn't exist** — one another control already decides, or one picking between two spellings of the same thing.
7. **The ticket is a hypothesis.** Measure it; contradicting it with evidence is expected. Then update the ticket.
8. **Drive it before you believe it, and name what you didn't drive.** Half the real findings only appear under the pointer.
9. **Ambiguity renders as absence, never a confident guess.** No tick beats a wrong tick.
10. **Geometry and tokens move as a set** — the outer element and every nested layer sharing that edge.

Two more decide *where* a fix goes: **consume the primitive, fix it upstream when it's wrong**,
and **fix it where all callers route through** — two copies of a rule is how one gets a bug the
other doesn't.

His working vocabulary — *honest / a promise*, *reads as*, *readable at a glance*,
*one control scale*, *a real lever*, *sheet on a canvas*, *glass*, *a beat*, *spotlight* —
is defined operationally in `reference/principles.md`. Load it before using any of those words.

## The checklist

**`CHECKLIST.md` is the checklist** — ranked, pattern-corrected, remediated. It **wins over any
summary of it**, including anything in this file. Load it every run. Each check carries one
blast-radius tag, replacing the old binary autofixable flag: **`mechanical`** (the `after:` is the
only possible correct value — edit, summarize counts) · **`refactor`** (deterministic but moves
DOM nodes, imports, or files — edit, then show the diff; never batch more than one per run
unconfirmed) · **`flag`** (never edit) · **`ask`** (`flag` plus a proposed edit).

## Modes and scope

| Form | Mode | Scope |
|---|---|---|
| `/ethanize` | dry run | `git diff main...HEAD` (three-dot, vs merge-base) |
| `/ethanize fix` | fix run | same diff |
| `/ethanize <path>` | dry run | that file or directory, in the diff or not |
| `/ethanize fix <path>` | fix run | that file or directory |
| `/ethanize --full` | dry run | force band B3 (below) |

Bare `/ethanize` is a **dry run**: a report costs a read, a silent design edit costs a review
cycle. Resolve scope first and print it — an empty diff fails there, not three findings later.
Mechanics: `reference/detection.md`. **Run the protected-path partition before any rule
runs** — as a pre-flight filter, not a per-rule caveat: one rule will forget, and it will be
the one that edits `button.tsx`.

### Sizing the run

48 checks on a 3-line diff is why nobody runs it. Four bands ration **reading**, not grepping:
**B0** copy-only (hand to `$ux-copy-review`) · **B1** nit, ≤40 added lines / ≤2 files / no new
component (10-check fast pass) · **B2** feature, ≤400 added and no `.css` (checks 1–27 plus
triggered) · **B3** new component, >400 added, >10 files, or any `.css` (all 48, plus a browser
pass). Any escalation trigger promotes the band; bands never demote. A `.css` change goes
straight to B3 — a token you touch is a token every surface reads. The band table, the
fast-pass ten, and the escalation triggers are in `CHECKLIST.md` §Bands.

**Never skip silently.** Name the band, the checks run *by number*, the checks skipped, the
triggers evaluated that did **not** fire, and that no band below B3 opens a browser. A check that
errored is "errored", never "0 findings".

## The dry-run report

Group by **what the reader does next**, mirroring his own PR structure — not by severity, which
would put a Title Case nit and a silent-failure bug in the same tier. **`FIX NOW`** mechanical,
one right answer · **`DECIDE`** a real fork the fix run would ask about · **`LEAVE ALONE`** found,
deliberately unchanged, with the reason · **`NOT VERIFIED`** what needs a browser. Order within a
group by `CHECKLIST.md` rank. Each finding is one line of claim + `file:line`, then `before:` /
`after:` / `why:` / `auto:`. No prose paragraphs.

```
/ethanize — band B2, 11 findings across 6 files (feat/memo-2612 vs main)
Ran 27 of 48 · skipped 21 · triggers fired: new empty state

FIX NOW (6)
  1  Count badge reads as a problem count            MapPinBar.tsx:214
     before  <Badge variant="secondary">{sources.length}</Badge>
     after   <ChevronsUpDown className="size-4" aria-label="Switch source" />
     why     a "3" beside a field reads as 3 unresolved problems, not 3 options
     auto    mechanical
DECIDE (3)
  7  Search results are keyboard-dead — arrows and Enter do nothing on a list of
     clickable rows. MapPinBar.tsx:430 → Q1                          auto  ask
LEAVE ALONE (2)
 10  ui/slider.tsx track has no cursor — registry-protected. Route around from
     PinAppearanceTab, or file a DES ticket against levco/airy. Not edited.
NOT VERIFIED
  Row height at 320px, hover/selected in dark mode. Not seen in a browser.

Next: /ethanize fix   (applies 1-6, asks Q1-Q3, leaves 10-11)
```

**Zero findings is a valid, good result.** Print
`/ethanize — no findings (band, range, N files, M added lines)` and stop. **Do not manufacture
findings to fill the report.** On a clean PR one finding is the honest output.

## The fix run

1. Resolve scope and **re-run detection**. Never fix from a stale report.
2. **Ask every question up front, in one batch** (`AskUserQuestion`) — answers change step 4.
3. Apply `mechanical`, smallest diff that works — **and report** one line per edit.
4. Apply `refactor` items showing the diff; apply answered `ask` items.
5. Never edit a protected path. Route around, **report the routing as a finding**, name the
   upstream ticket. A workaround with no filed ticket is an unfinished fix.
6. Re-run detection; report what's left. Then verify.

**Git safety.** Refuse `fix` on a dirty tree unless the dirty files are the ones you were pointed
at. Never commit unasked; if asked, `mechanical` and `refactor` never share a commit.
**Question shape:** recommended option first, labelled `(Recommended)`; each stated as what will
concretely be in the file; never ask what `CHECKLIST.md` settles.

## What it must not do

**Never edit a protected path.** `src/components/ui/`, `airy-blocks/`, `lev-assets/`,
`src/styles/airy-theme/`, `airy-rules/`, `skills/airy-skills/`. Route around from outside or
propose upstream. **No exception** — some mined rules come from PRs where *he* edited these; he
also owns the Airy registry, you don't.

**Never restate what the repo owns** — cite it: `airy-rules/copy.md`,
`airy-rules/design-system-rules.md`, `agents/{tailwind-4,shadcn-ui,react-19}.md`,
`skills/mobile-first-design/`. Copy work beyond the allowlist goes to
`skills/airy-skills/ux-copy-review` — hand off, don't duplicate.

**Never introduce an alpha modifier on a semantic token** where a plain token or a
`*-background` pair exists. Preserving an existing one is fine; cite the precedent when a
replacement genuinely needs alpha.

**Report, do not change** — third-party vocabulary (API keys, Google's `types`, HTML element
names) · domain prose (CRE language is not a casing bug) · renames that remove no code · a
persisted value you can't attribute · idempotent migrations · inherent limitations · design
decisions you'd be inventing · backend-shaped problems (never write the client-side workaround).

**Screenshots are not a gate.** He ships "Not included; copy-only change". Behaviour verified in
the app outranks a picture of it.

## Verification

```bash
bun run ci:check       # format:check + lint + type-check
bun run test <paths>   # only suites covering touched files
```

Report each as pass/fail with real numbers, then state — required, never softened:

> Not verified without a browser: every visual claim in this run. `ci:check` proves the code
> compiles and lints, not that the surfaces read correctly. Specifically unverified: `<list>`.
> Run `bun run dev:portless`, open `<surface>`, check `<the specific thing>` — in dark mode too
> if a colour token moved.

Name every hover, focus, and motion state the run touched: no static check reaches them, and they
are most of what this skill changes. Procedure, driving checklist, and the verified `orca` browser
commands: `reference/verification.md`.

## Reference files

Long by design. Load on demand — never inline one.

| File | Load when |
|---|---|
| `CHECKLIST.md` | **Every run.** The ranked checks, their patterns, their tags, the bands. |
| `reference/visual.md` | Spacing, radius, border, shadow, colour tokens, typography, icons, density. |
| `reference/interaction.md` | Hover, focus, keyboard, a11y, motion, perceived performance. |
| `reference/patterns.md` | Component choice, empty/loading states, overflow, truncation, hierarchy. |
| `reference/flows.md` | A consequential action, confirmation, receipt, multi-step flow, or form. |
| `reference/copy.md` | Any user-facing string changed. `copy-allowlist.md` for the Title Case allowlist; `copy-full.md` only if a call needs its rationale. |
| `reference/his-words.md` | Before overriding anything that looks deliberate. Boundaries first. |
| `reference/exemplars.md` | Unsure whether something is a finding. 40 before/after pairs. |
| `reference/principles.md` | This summary isn't enough; also holds the vocabulary definitions. |
| `reference/detection.md` | Scoping, added-lines extraction, the corrected grep harness. |
| `reference/verification.md` | Driving the app in a browser, and what to report when you can't. |
| `reference/validation.md` · `adversarial.md` | The measured recall and the attack on the autofix tier — basis for the numbers above. |
| `reference/refresh.md` | Re-mining the corpus when his PRs move on. |

## Portability

One skill, here, with a per-repo adapter — not two. `levco/memo` installs the same `airy-rules/`,
`src/styles/airy-theme/`, and five `agents/*.md`; what differs is short and enumerable (form
stack, data layer, router, z-index system, PR title format). Vendor by copying this directory
**and** adding its `skills-lock.json` entry, or it drifts silently.
