# /ethanize — detection harness

Mechanics shared by both modes. Every command below was executed in
`/Users/maurodaprotis/orca/workspaces/borrower-portal-v2/ethanize`
(ripgrep 14.1.1, git, bun). Counts are real.

---

## 0. Two traps, verified — read before writing any command

**Trap 1: never put rg globs in a shell variable.**

```bash
EX="-g !src/components/ui/**"
rg -l -g '*.{tsx,ts}' $EX 'z-50' src | grep -c 'components/ui/'   # -> 5   LEAK
rg -l -g '*.{tsx,ts}' -g '!src/components/ui/**' 'z-50' src | grep -c 'components/ui/'  # -> 0
```

The variable form silently leaks protected files into the review. Write globs
inline, or use a shell function:

```bash
app() { rg "$@" \
  -g '*.{tsx,ts,css}' \
  -g '!src/components/ui/**' \
  -g '!src/components/airy-blocks/**' \
  -g '!src/components/lev-assets/**' \
  -g '!src/styles/airy-theme/**' \
  -g '!airy-rules/**' \
  -g '!**/*.test.*' -g '!**/*.spec.*' \
  src; }
```

**Trap 2: never `git checkout` to inspect a commit.** The skill runs in the
user's live worktree. Grep the diff text instead (§1.3) — same answer, no state
change. Verify with `git status --porcelain` before and after; it must stay empty.

**Protected paths (CLAUDE.md).** `src/components/ui/`, `src/components/airy-blocks/`,
`src/components/lev-assets/`, `src/styles/airy-theme/`, `airy-rules/` are installed
from the Airy registry. The skill must **never edit them and never report findings
in them**. If a finding's root cause lives there, report it as "route around":
wrapper component, `className` override, variant, CSS var, or `data-slot` selector
from outside the protected path.

---

## 1. Scoping the review

### 1.1 Pick the base

```bash
git rev-parse --abbrev-ref HEAD              # -> maurodaprotis/ethanize
git status --porcelain                       # empty = nothing uncommitted
BASE=$(git merge-base HEAD main)             # -> acf50e9f892682531bbedfaf697febcd67a76161
```

Choose the range by what exists, in this order:

| situation | range |
|---|---|
| `git status --porcelain` non-empty | `HEAD` (unstaged+staged vs HEAD) |
| clean, and `HEAD != BASE` | `"$BASE"...HEAD` (whole branch vs main) |
| clean and `HEAD == BASE` | nothing to review — say so and stop |

If both uncommitted work *and* branch commits exist, review
`"$BASE"` with no `...HEAD` — that spans committed **and** working-tree changes in
one pass. Announce which range you picked; the user may have meant the other.

### 1.2 Changed files, filtered

```bash
git diff --name-only --diff-filter=ACMR "$RANGE" \
  | grep -E '\.(tsx|ts|css)$' \
  | grep -vE '^(src/components/(ui|airy-blocks|lev-assets)/|src/styles/airy-theme/|airy-rules/)' \
  | grep -vE '\.(test|spec)\.[tj]sx?$|\.graphql\.ts$|/generated/'
```

`--diff-filter=ACMR` drops deletions (nothing to review in a deleted file).

Verified the exclusion bites: on commit `83a66900e`, `git diff --name-only ... -- 'src/*.tsx'`
returns 1 `components/ui/` file; adding `':(exclude)src/components/ui/*'` returns 0.

### 1.3 Added lines only — the core of the harness

Report only on lines this change **introduced**. The repo has real pre-existing
debt (430 `border border-border` hits, 209 files) — surfacing it would bury the
actual review.

```awk
# /tmp/addedlines.awk
/^\+\+\+ b\//   { f=substr($0,7); next }
/^@@/           { if (match($0, /\+[0-9]+/)) { s=substr($0,RSTART+1,RLENGTH-1); n=s+0 } next }
/^\+/           { print f ":" n ":" substr($0,2); n++; next }
```

```bash
git diff -U0 "$RANGE" -- 'src/*.tsx' 'src/*.ts' 'src/*.css' \
  ':(exclude)src/components/ui/*' ':(exclude)src/components/airy-blocks/*' \
  ':(exclude)src/components/lev-assets/*' ':(exclude)src/styles/airy-theme/*' \
  ':(exclude)*.test.*' ':(exclude)*.spec.*' ':(exclude)*.graphql.ts' \
  | awk -f /tmp/addedlines.awk > /tmp/ethanize_added.txt
```

Output is `path:line:content`, one added line each — feed it straight to `rg`.

**Line numbers verified exact.** On `9bbe7d69f`:
- harness claimed `…/CampaignSequence/CampaignSequenceStepList.tsx:224`
- `git show 9bbe7d69f:<path> | sed -n '224p'` → the same
  `'inline-flex size-6 … rounded-full border border-border bg-background …'` line.

826 added lines in scope on that commit.

---

## 2. Grep checks — measured on this codebase

All counts from the app-owned tree (2,430 files) with correct exclusions.
"FP" = false positives found by eyeballing the hits.

### 2.1 SURVIVED — run these

#### C1 · `w-N h-N` → `size-N` — **24 hits, 0 FP** · autofixable
```bash
app --pcre2 -n --no-heading '\b(?:w-(\d+(?:\.\d+)?) h-\1|h-(\d+(?:\.\d+)?) w-\2)(?![\w./-])'
```
Backreference needs `--pcre2`. The `(?![\w./-])` tail is load-bearing: without it
`h-4 w-4/5` matches (fraction width, not square) — that FP was in the first draft
and is now gone. Catches both orders. Sample: `h-3.5 w-3.5`, `h-7 w-7`, `h-4 w-4`.

Not covered by the linter — see §5.3.

#### C2 · redundant `border-border` — **430 hits, 0 FP** · autofixable
```bash
app -n --no-heading '\bborder(?:-[trblxy])? border-border\b'
```
Grounded: `src/styles/globals.css:196,208` set `border-color: var(--border)` globally,
so `border-border` is always a no-op next to a structural border. CLAUDE.md states the
rule directly. Every one of the 430 is genuinely redundant — the volume is repo debt,
which is exactly why C2 must run on **added lines only**.
Fix: delete the ` border-border` token, keep `border` / `border-b` / `border-t`.

#### C3 · raw hex in a `className` — **12 hits, 0 FP** · review
```bash
app --pcre2 -n --no-heading 'className=(?:"|\{?`|\{")[^"`]*#[0-9a-fA-F]{3,8}'
```
Must be className-scoped. The unscoped `#[0-9a-fA-F]{3,8}` version returns **484**
hits dominated by `src/features/maps/domain/*` (marker SVGs, brand colors,
Google map styles) and tests — legitimate, non-Tailwind color data. Scoping to
className drops it to 12 real ones (`text-[#D97757]`, `bg-[#4A5D4A]`).
Review, not autofix: some are third-party brand colors that must not be tokenized.

#### C4 · off-palette grays — **7 hits, 0 FP** · review
```bash
app -n --no-heading '\b(?:text|bg|border|fill|stroke|ring|divide)-(?:gray|slate|zinc|neutral|stone)-\d{2,3}'
```
Should be `muted-foreground` / `muted` / `border` / `foreground`.
Sample: `text-gray-600/80`, `bg-neutral-950`, `dark:text-neutral-50`.

#### C5 · `transition-all` — **38 hits** · review
```bash
app -n --no-heading '\btransition-all\b'
```
Ethan's own code names properties explicitly, without exception:
`transition-[gap]`, `transition-transform`, `transition-colors`,
`transition-[opacity,transform,padding]`, `transition-[grid-template-columns]`,
`transition-[padding,margin]`, `transition-[border]`, `transition-[width]`,
`transition-[height,opacity,padding]`, `transition-[opacity,background-color,color]`.
Not autofixable — only the author knows which properties should animate.
Caveat for the report: the one `transition-all` in `BulkActionsBar` is his, but it
was carried verbatim from the six bars he merged (#6548), not authored.

#### C6 · `truncate` on a flex child with no `min-w-0` — **9 hits, 0 FP** · review
```bash
app --pcre2 -n --no-heading 'className=(?:"|`)(?![^"`]*(?:min-w-0|overflow-hidden))[^"`]*\b(?:flex-1|flex-grow|grow)\b[^"`]*\btruncate\b'
```
A flex item defaults to `min-width:auto`, so `truncate` silently does nothing.
The `overflow-hidden` exclusion is required by spec — `min-width:auto` only applies
while `overflow` is `visible`, so an element that already has `overflow-hidden` is
not affected. (This is why the brief's "`overflow-hidden` without `min-w-0`" phrasing
inverts the real bug — see §2.2 R3.)

#### C7 · Title Case in a UI string — **30 hits, ~60% TP** · review
```bash
app --pcre2 -n --no-heading '(?:aria-label|title|label|content|placeholder|triggerLabel)="(?:[A-Z][a-z]+ ){1,}[A-Z][a-z]+"'
```
True: `aria-label="Property Type"`, `aria-label="Share Vault"`,
`label="Update Tear Sheet"`, `aria-label="Toggle Columns"`, `title="Program Coverage"`.
False: `title="Google Tag Manager"`, `placeholder="New York"`, `content="Lev Agent"`,
`placeholder="My Notion"` — proper nouns and product names, which CLAUDE.md explicitly
exempts along with CRE taxonomy and controlled loan/document/report type values.
The grep narrows the field; the model decides each one. Never batch-autofix.

### 2.2 REJECTED — do not ship these

| # | pattern | why killed |
|---|---|---|
| R1 | `\bw-\d+ h-\d+` (any values) | 3 hits, **all FP** — `w-7 h-4`, `w-9 h-5`, `w-11 h-6` in `Toggle.tsx` are deliberate rectangles. Only the same-value form (C1) is a defect. |
| R2 | `#[0-9a-fA-F]{3,8}` unscoped | 484 hits, overwhelmingly `features/maps/domain/*` + tests. Unusable. Replaced by C3. |
| R3 | `overflow-hidden` on a flex child w/o `min-w-0` | 78 hits, **~all FP**. Per CSS spec `overflow-hidden` *already* resolves `min-width:auto` to 0 — this combination is not a bug. Replaced by C6, which flags the case that actually breaks. |
| R4 | high raw `z-*` (`z-50`/`z-[60]`+) | 5 hits, **~0 actionable**. All deliberate stacking above modals — incl. the repo's own `shared/Spotlight.tsx:268` (`z-[60]`) and `PhoneVerificationDialog.tsx:220` which carries a comment explaining it. The repo has a real `--z-*` scale (13 tokens) but `z-10`/`z-0` inside a local stacking context is fine, so the broad `z-\d+` form is 220 hits of nothing. |
| R5 | `hover:border-*` with no rest border | **0 hits.** Correct rule (from #7031's `border border-transparent … hover:border-border`), zero signal here. My first draft returned 13 — all FP, because the lookahead only excluded `border-transparent` instead of any rest border. |
| R6 | `rounded-lg/xl` on `size-1..6` | **0 hits.** The #7031 avatar-radius fix already landed and nothing else does it. |
| R7 | `group-hover:animate-*` | 3 hits, **all FP** — all `SpeechBubble.tsx`, where a keyframe typing effect is the correct tool. Would fire only on Ethan's own code. |
| R8 | `onClick` on `div`/`span` w/o `role`/`tabIndex` | 181 raw → 103 after excluding `stopPropagation`/`preventDefault`-only handlers. Still too imprecise to *assert*: canvas surfaces and the deliberate "whole card forwards to an inner button" pattern (#6987, #6549) are legitimate. Demoted to a model read — §3 M1. |
| R9 | `useEffect` → derived state | 88 hits (after excluding `[]` mount-only deps). Genuine antipattern but needs judgment: controlled-input sync vs external sync vs derivable-during-render. Demoted to a model read — §3 M2. |

### 2.3 Running the checks

```bash
rg --pcre2 -n --no-heading '<PATTERN>' /tmp/ethanize_added.txt
```

Hits come back as `path:line:content` already. Re-verified end-to-end on
`9bbe7d69f`: C2 → 1 hit at `CampaignSequenceStepList.tsx:224`, all other checks 0.

---

## 3. What can't be grepped — model reads

Grep finds *tokens*. Everything below needs the component read, because the
defect is a relationship between things, not a string.

**Reading procedure.** For each changed component, in this order:

1. **Deleted lines first.** `git diff "$RANGE" -- <file> | grep '^-'`. What the
   author reached for and someone removed is the strongest signal in the diff.
2. **Empty / loading / error states.** Do they share the surface, radius, and
   height of the filled state? (#6987: loading went `rounded-md border border-input`
   → `rounded-lg bg-muted/30 min-h-[160px]` to match the empty state so the
   section stops jumping between states.)
3. **Interactive elements — one pass per element.** Rest → hover → focus →
   disabled → in-flight. Does hover shift layout? Is there a `transition-`? Does
   a hover-revealed border have a `border-transparent` at rest? Does an
   in-flight action disable the *choices* or only the confirm button?
4. **Copy strings.** Sentence case; verbs in execution order; does a named remedy
   have a click path; does a failure toast say what survived and where to fix it.
5. **Counts and summaries.** Is every number inspectable? Does it say which items?
6. **Decorative nodes.** `aria-hidden` + `pointer-events-none` on illustrations,
   masks, gradients, spacers.

The specific model-only checks:

- **M1 · clickable non-button** (was R8). Read the element: is there *any*
  keyboard path to the same action? A card that forwards clicks to a real inner
  `<button>` is correct and deliberate; a `div` with `onClick` and no inner
  control is a defect. Locate candidates with the R8 grep, then read each.
- **M2 · `useEffect` for derived state** (was R9). Read the effect: can the value
  be computed during render? Is it syncing a controlled input (usually a real
  smell) or reading an external/browser source (fine)?
- **M3 · duplicate CTA.** Is the same action offered in a section header *and* an
  empty state *and* a toolbar? Requires knowing all three render conditions.
- **M4 · hover/highlight corner clipping.** Negative margins must be symmetric
  under an `overflow-hidden` parent (`-mx-2 -my-1` under `overflow-hidden`
  shears rounded corners; `-mx-2 -my-2` does not).
- **M5 · animation stability.** Is hidden animating content still contributing
  height to a grid/flex row? Is a `max-w-*` class being swapped where a
  `width` transition is needed? Does the inner content have a pinned width so it
  slides instead of reflowing?
- **M6 · state grammar.** Do chips/labels read muted+regular when empty and
  foreground+medium when set, or is `font-medium` hardcoded regardless?
- **M7 · equivalent choices.** Are two options presented that produce the same
  outcome? Requires reading the planner.
- **M8 · protected-path root cause.** If the right fix is inside
  `src/components/ui/` etc., say so and propose the route-around.

---

## 4. Dry-run output format

Terminal-printed, not published. Group by severity, most severe first.
One blank line between findings. Keep each to 4 lines.

```
ethanize — 7 findings across 4 files   (range: acf50e9f...HEAD, added lines only)

HIGH  src/components/Deals/Foo/FooCard.tsx:224
      Redundant `border-border` next to `border` — globals.css already sets
      border-color: var(--border) (CLAUDE.md: Theme Token Ownership).
      fix: `border border-border bg-background` -> `border bg-background`
      auto: yes

MED   src/components/Deals/Foo/FooRow.tsx:88
      `truncate` on a flex child with no `min-w-0` — flex min-width:auto means
      this never truncates.
      fix: add `min-w-0` to the same class string
      auto: yes

MED   src/components/Deals/Foo/FooBar.tsx:31
      `transition-all` — name the properties that should animate.
      fix: `transition-all duration-200` -> `transition-[opacity,transform] duration-200`
      auto: no  (which properties?)

LOW   src/components/Deals/Foo/FooMenu.tsx:57
      Title Case in a UI string; sentence case is the default for product UI.
      fix: aria-label="Toggle Columns" -> aria-label="Toggle columns"
      auto: no  (confirm not a proper noun / CRE taxonomy)

READ  src/components/Deals/Foo/FooCard.tsx:140-172
      Clickable <div> with no inner button and no role/tabIndex — no keyboard
      path to this action. (model read, not a grep match)
      fix: make the target a <button>, or add an inner focusable control
      auto: no

  4 auto-applicable · 3 need a decision
  run `/ethanize fix` to apply the 4 and be asked about the rest
```

Rules for the list:
- **severity**: `HIGH` breaks a documented repo rule or a real interaction
  (C2, C6); `MED` is a taste/consistency rule with a clear fix (C1, C3, C4, C5);
  `LOW` is copy and judgment (C7); `READ` is a model finding with no grep behind it.
- `file:line` is always clickable and always points at an **added** line.
- `fix:` shows the exact before → after string, never a description.
- `auto:` is `yes` only when the edit is a pure mechanical string substitution
  with no semantic choice. C1, C2, C6 qualify. Nothing else does.
- **Zero findings is a valid, good result** — print
  `ethanize — no findings (range: …, N files, M added lines)` and stop. Do not
  manufacture findings to fill the report.
- Never report a finding whose file is under a protected path. If the root cause
  is there, emit a single `READ` finding describing the route-around.

Fix mode uses the same list: apply every `auto: yes`, then present each
`auto: no` as one question with the recommended option first.

---

## 5. Verification after fixing

Ground truth from `package.json` (verified present in `node_modules/.bin`:
tsc 5.9.3, prettier 2.8.8, eslint 8.28.0, next, jest).

### 5.1 Fast, per-file — while iterating

```bash
node_modules/.bin/next lint --file <path> [--file <path> …]
node_modules/.bin/prettier --check <path>
```

Both verified working, multi-file included. `next lint` prints a deprecation
banner ("`next lint` is deprecated and will be removed in Next.js 16") — harmless.

**Omit `--quiet` here.** `bun run lint` is `next lint --quiet` = errors only, and
every Tailwind rule in this repo reports at *warning* level, so `--quiet` hides
exactly the class of problem an ethanize fix could introduce.

### 5.2 Full gate — before handing back

```bash
bun run ci:check    # = format:check && lint && type-check
```

Or individually: `bun run format:check`, `bun run lint`,
`bun run type-check` (`NODE_OPTIONS=--max_old_space_size=12288 tsc --pretty --noEmit`
— whole-project, slow, needs the memory bump).

`bun run test` (jest, `--passWithNoTests`) only if the change touched a file with
a sibling test.

Compare warning counts against a **baseline captured before the edits** — this
repo has pre-existing lint warnings, so "warnings exist" is not a regression;
"more warnings than before" is.

### 5.3 The linter does NOT cover these checks — verified

`.eslintrc.cjs` extends `plugin:tailwindcss/recommended` with
`eslint-plugin-tailwindcss@4.0.0-beta.0` against `tailwindcss@4.1.11`
(`settings.tailwindcss.config` → `src/styles/globals.css`). Probed via stdin:

```bash
printf 'export const A = () => <div className="w-4 h-4 p-2 px-3" />\n' \
  | node_modules/.bin/eslint --stdin --stdin-filename src/components/Probe.tsx --format unix
# -> Invalid Tailwind CSS classnames order  [Warning/tailwindcss/classnames-order]
```

- `classnames-order` **is active** → after any className edit, class order may
  drift. Re-run lint on the touched files.
- `enforces-shorthand` **does not fire** on `h-4 w-4`, even forced on via
  `--rule '{"tailwindcss/enforces-shorthand":"warn"}'`. So **C1 is not redundant
  with the linter** — the grep earns its place.
- No `prettier-plugin-tailwindcss` is installed (`.prettierrc` is only
  `singleQuote`, `printWidth: 80`, `trailingComma: es5`, `semi: false`).
  Prettier will **not** reorder classes for you. Keep className edits surgical:
  change the one token, leave the rest of the string byte-identical.

### 5.4 Visual changes need a browser

Typecheck and lint cannot see a hover state, a corner clip, a layout shift, or
dark mode. Anything touching spacing, radius, borders, color tokens, motion, or
empty/loading states must be looked at:

```bash
bun run dev:portless          # https://app.localhost
```

Sign in with `TEST_LOGIN_USERNAME` / `TEST_LOGIN_PASSWORD` from `.env`
(never print the values). Check the changed surface in **both light and dark**,
and at a narrow width if any `sm:` class was touched. If a browser check isn't
possible, say so in the report rather than implying the change is verified.

### 5.5 Leave no trace

The skill must not commit, stash, or check out. Confirm before and after:

```bash
git status --porcelain    # must be empty in dry-run mode
git rev-parse --abbrev-ref HEAD
```

In fix mode the only diff should be the applied fixes — no branch change,
no new files, and nothing under a protected path.
