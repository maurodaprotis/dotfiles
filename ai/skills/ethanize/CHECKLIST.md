# /ethanize — the checklist

48 checks, ranked by **frequency × how much he cares × detection cost**. Run top-down; stop when
the budget runs out and the cheap high-frequency ones are done.

**Every pattern here has been executed against this repo.** Six were broken as originally written
and are fixed below; four are demoted to `flag`; four cannot be grepped at all and are
read-the-component. Counts are real, from `src/` on a clean tree.

**Tags (blast radius, not severity).** `mechanical` = the `after:` is the only possible correct
value; edit and summarize. `refactor` = deterministic but moves DOM nodes, imports, or files;
edit, then show the diff. `ask` = propose the edit, apply on a yes. `flag` = report only; the
correct fix needs information the skill doesn't have.

Domains: `visual` `copy` `interaction` `patterns` `flows`.

---

## Pre-flight — run these two before any check

**1. Partition the file list.** Not a per-rule caveat — a single filter, before any rule runs.
One rule will forget the exclusion, and it will be the one that edits `button.tsx`.

```
collect candidates (git diff / glob)
partition:  editable[]  |  protected[]
run every rule against editable[]         → may edit
run every rule against protected[]        → REPORT ONLY, never write
emit two sections: "Fixes applied" and "Needs an upstream Airy change"
```

Protected: `src/components/ui/**`, `src/components/airy-blocks/**`,
`src/components/lev-assets/**`, `src/styles/airy-theme/**`, `airy-rules/**`.

Measured blast radius this prevents: `transition-all` hits **7** protected files
(`button`, `sidebar`, `accordion`, `badge`, `switch`, `tabs`, `progress`); the `ring-2`→`ring-3`
rule hits **11**; `border-border` hits **4**; the dialog-scrim rule's only target *is*
`ui/dialog.tsx`. ≥23 illegal edits, from four rules.

A protected hit is reported like this, never silently skipped:

```
⚠  Needs a change in a protected Airy path — not edited.
    src/components/ui/button.tsx:42
    rule: #4 — `transition-all` is banned
    found:    'transition-all duration-200'
    proposal: 'transition-[color,background-color,box-shadow] duration-200'
    Route around it (app-owned wrapper, className override, data-slot descendant
    selector), or propose upstream. See airy-rules/design-system-rules.md:43.
```

Rules mined from **bp2#7228** carry an inline note: *its landing site is protected — he also owns
the Airy registry; you don't.*

**2. Read SKILL.md's pre-flight list.** Twelve things that look like defects and are deliberate.
That list is the guard against this skill's worst failure mode.

---

## Bands — how many checks to run

Bands ration **reading**, not grepping: 48 greps over one added-lines file cost about what 10 do.

```bash
ADDED=$(wc -l < /tmp/ethanize_added.txt)
FILES=$(git diff --name-only "$RANGE" -- 'src/*.tsx' 'src/*.ts' 'src/*.css' | wc -l)
NEWCOMP=$(git diff --diff-filter=A --name-only "$RANGE" -- 'src/components/*.tsx' 'src/features/**/*.tsx' | wc -l)
CSSCHG=$(git diff --name-only "$RANGE" -- 'src/*.css' | wc -l)
```

| Band | Condition | Checks | Reads |
|---|---|---|---|
| **B0 · copy-only** | string-only diff | copy checks, then `$ux-copy-review` | 0 |
| **B1 · nit** | `ADDED ≤ 40`, `FILES ≤ 2`, `NEWCOMP = 0` | the fast-pass ten | ≤1 |
| **B2 · feature** | `ADDED ≤ 400`, `NEWCOMP = 0`, `CSSCHG = 0` | 1–27 + triggered 28–43 | 2–5 |
| **B3 · new surface** | `NEWCOMP ≥ 1` or `ADDED > 400` or `FILES > 10` or `CSSCHG ≥ 1` | all 48 | 5–12 |

Thresholds are tuned, not measured — the *conditions* are the contract. Bands never demote.

**Fast-pass ten (B1):** 1, 2, 3, 4, 12, 13, 14, 17, 18, 25. Chosen for measured-zero-FP greps
against the highest-frequency families. Deliberately out: 16, 22, 26, and 5/6 — 5 and 6 are Tier 1
but only fire on a diff that *adds* a hover state, which the escalation table promotes instead.

**Escalation triggers** (run against the added lines; any hit promotes the band):

| Trigger | → | Adds |
|---|---|---|
| `git diff --diff-filter=A` includes a component `.tsx` | B3 | all 48 — a new component has no prior review |
| any `src/*.css` changed, or a `--[a-z-]+:` declaration added | B3 | all 48 + browser check |
| `\banimate-(?!none)\|motion\.\|transition-\[\|@keyframes\|useReducedMotion` | B3 | 7, 43 |
| `group-hover:\|hover:opacity\|\bopacity-0\b` | B2 | 5, 6, 43 |
| `No \w+ (available\|yet\|found)\|<EmptyState\|emptyMessage` | B2 | 10, 11 |
| `<Skeleton\|isLoading\|loading \?` | B2 | 41, 42 |
| `role="alert"\|aria-live\|window\.(confirm\|alert)` | B2 | 32, 37 |
| `PopoverContent\|DropdownMenu\.Sub\|DropdownMenuSub\|<Dialog` | B2 | 29, 45 |
| `useEffect\(` | B2 | model read M2 |
| `aria-label\|role="button"\|tabIndex` added, or an icon-only `<Button>` | B2 | 28, 30, 31 |
| ≥1 finding already `ask`/`flag` in the fast pass | B2 | the rest of Tier 2 — one taste miss predicts others |

Protected-path hits are a **hard stop**, not an escalation: report, change nothing.

**Never skip silently.** Name the band, the checks run *by number*, the checks skipped, the
triggers evaluated that did **not** fire, and that no band below B3 opens a browser. A check that
errored is reported as "errored", never as "0 findings".

---

## Tier 1 — run on every diff (1–12)

1. **`flag` `patterns`** — Never edit `src/components/ui/`, `airy-blocks/`, `lev-assets/`,
   `src/styles/airy-theme/`, `airy-rules/`; route around and propose upstream.
   `git diff --name-only "$RANGE" | rg '^src/components/(ui|airy-blocks|lev-assets)/|^src/styles/airy-theme/|^airy-rules/'` · **0 hits** on a clean tree.

2. **`flag` `copy`** — Product UI strings are sentence case; Title Case only for the allowlist
   (product nouns, CRE taxonomy, canonical doc names, roles, plans, legal titles).
   **Three-part and diff-scoped — repo-wide it is a rename project.**
   ```bash
   git diff "$RANGE" -U0 -- '*.tsx' '*.ts' | rg '^\+' \
     | rg -n --pcre2 '\b(label|title|heading|placeholder|aria-label|content|emptyMessage|description)="([A-Z][a-z]+ )+[A-Z][a-z]+' \
     | rg -v 'Lev AI|Lev Agent|Memo|Vault|Tear Sheet|Term Sheet|Rent Roll|Operating Statement|Offering Memorandum|Google|Auth0|Property Type|Loan Type|Deal Team'
   ```
   Repo-wide: **52** hits, **~40% precision** on a hand-triaged sample. The `rg -v` is the
   operational form of `reference/copy-allowlist.md`, not a replacement for it. The grep finds
   candidates; `$ux-copy-review` / `airy-rules/copy.md` issues the verdict. **Never batch-fix.**

3. **`flag` + read-the-component `visual`** — Every flex/grid item in a chain ending in `truncate`
   needs `min-w-0`; the trailing icon/badge needs `shrink-0`; the text node needs `break-words`.
   **`rg` cannot walk ancestors** and bare `truncate` is **782 hits**. Two-step:
   ```bash
   git diff "$RANGE" -U0 -- '*.tsx' | rg '^\+.*\btruncate\b' -l   # candidates only
   ```
   then read each from the truncating node up to its nearest layout ancestor and verify (a) every
   flex/grid ancestor between them has `min-w-0`, (b) the trailing sibling has `shrink-0`,
   (c) the text node has `break-words` if it can receive an unbroken string.
   **`mechanical` only** when the direct parent is a `flex`/`grid` in the same JSX expression;
   ancestor-walking is `flag`. Stays at rank 3 — the most-repeated mechanical rule in the corpus.

4. **`mechanical` `interaction`** — `transition-all` is never correct; enumerate the properties.
   `rg -n 'transition-all' -g '*.tsx' -g '*.css' src --glob '!src/components/ui/**'` · **38 hits**.
   His own code names properties without exception (`transition-[gap]`, `transition-colors`,
   `transition-[opacity,transform,padding]`, `transition-[width]`). Which properties is the
   author's call, so the *edit* is `ask` unless only colour/background change in the same string.

5. **`mechanical` `interaction`** — Every `hover:`/`group-hover:` **reveal** needs its
   `focus-visible:`/`group-focus-within:` mirror plus `pointer-coarse:`, and
   `group-has-[[data-state=open]]` when it owns a menu.
   ```bash
   rg -n --pcre2 '"[^"]*group-hover:(opacity-100|flex)[^"]*"' -g '*.tsx' src | rg -v 'focus|pointer-coarse'
   ```
   **39 raw → 10 after the filter**, and 80 of the 90 reveal files already comply — the strongest
   evidence in the corpus that this is his rule. **Scoped to hover-*reveal*, not hover-*styling*:
   the broad "any `hover:` needs a focus mirror" form is deleted** — on a real `<button>` the
   focus-visible ring *is* the mirror (it fired on 420 occurrences, nearly all correct).

6. **`mechanical` `interaction`** — A hover-revealed control must be `pointer-events-none` at rest,
   not merely `opacity-0` — an invisible clickable overlay steals clicks from the cells beneath.
   `rg -n --pcre2 'opacity-0(?=[^"]*group-hover:opacity-100)(?![^"]*pointer-events)' -g '*.tsx' src` · **28 hits, clean**.

7. **`flag`, diff-scoped only `interaction`** — Every animation needs a reduced-motion escape, and
   that branch must land on the **finished** state (`opacity: 1`, `stroke-dashoffset: 0`), never
   the start.
   ```bash
   git diff "$RANGE" -U0 -- '*.tsx' '*.css' | rg '^\+' \
     | rg --pcre2 '\banimate-(?!none|spin|pulse|caret-blink)[a-z]|<motion\.' | rg -v 'motion-reduce|shouldReduceMotion'
   ```
   Repo-wide this is **132 hits / 81 files** — a project, not a check. Per-diff it is near-zero.

8. **`mechanical` `copy`** — `aria-label` and `placeholder` are copy: sentence case, capitalized
   first letter, matching the visible text exactly when both exist.
   `rg -n --pcre2 'aria-label="[a-z]' -g '*.tsx' src` · **7 hits, clean**.

9. **`ask` `patterns`** — One action, one place: the same action rendered twice in one surface
   (section-header CTA + empty-state CTA, toolbar + bespoke page header). No pattern by design.

10. **`flag` `flows`** — A failed request renders an error with `Try again`, never the empty-state
    copy. Two-step composite — the single grep is **141 hits**, nearly all legitimate:
    ```bash
    rg -l --pcre2 'No \w+ (available|yet|found)' -g '*.tsx' src | xargs rg -l --files-without-match 'error|refetch|isError'
    ```
    Still `flag`: the error path often lives in a parent.

11. **`ask` `flows`** — Success is silent when the result is on screen; a dead end, shortfall, or
    owed instruction is never silent — and the decision comes from an explicit flag, never from
    pattern-matching English. No pattern by design.

12. **`mechanical` `visual`** — Opacity-modified foreground tokens become `muted-foreground`; a
    `*-foreground` token is never white or black.
    `rg -n --pcre2 'text-(sidebar-)?foreground/\d+' -g '*.tsx' src` · **30 hits, clean**
    `rg -n --pcre2 '\-\-\w+-foreground:\s*(#fff|#000|white|black)' src` · **0** (preventive).
    **Tightened:** the loose `text-[\w-]*foreground/\d+` form captured **103**, of which **73 were
    wrong** — `text-muted-foreground/N` (70), `primary-`, `success-`, `warning-foreground/N`, whose
    correct replacement is *not* `muted-foreground`. Skip the file if it also matches
    `surface-glass`, `absolute inset-0`, or a map/overlay path — alpha over imagery is deliberate.
    This is the one rule that *agrees* with `design-system-rules.md:144`; keep its direction.

## Tier 2 — mechanical token & geometry sweeps (13–27)

13. **`mechanical` `visual`** — Square boxes use `size-*`.
    `rg -n --pcre2 '\bw-(\d+(?:\.\d+)?)\s+h-\1\b|\bh-(\d+(?:\.\d+)?)\s+w-\2\b' -g '*.tsx' src` · **25, clean**.
    The same-value form only — `w-7 h-4` etc. are deliberate rectangles.

14. **`mechanical` `visual`** — Raw palette greys become tokens (`bg-gray-50|100`→`bg-muted`,
    `bg-white`→`bg-background`, `text-gray-*`→`text-muted-foreground`); exempt map/photo overlay files.
    `rg -n --pcre2 '\b(text|bg|border|fill|stroke|ring)-(gray|slate|zinc|stone)-\d{2,3}\b' -g '*.tsx' src` · **1**.

15. **`mechanical` `visual`** — Named-color icons become semantic (`text-red-500`→`text-destructive`).
    `rg -n --pcre2 'text-(red|green|blue|emerald|amber|yellow)-\d{3}' -g '*.tsx' src` · **9**.

16. **`mechanical` `visual`** — Legacy `error-*` tokens become `destructive`; a `success` **fill**
    uses `--success`, never `--success-foreground`.
    `rg -n --pcre2 '\b(text|bg|border)-error-(foreground|background|border)\b' -g '*.tsx' src` · **18**.

17. **`mechanical` `visual`** — Elevation runs one step lower than instinct: `shadow-xs` at rest,
    `hover:shadow-sm`. The only styling change he ever asked another engineer for.
    `rg -n 'hover:shadow-md' -g '*.tsx' src --glob '!src/components/ui/**'` · **5**.

18. **`ask`, repo-wide `visual`** — Hover surface is `bg-muted` (+ `dark:hover:bg-muted/50`); never
    two opacities of one colour for two states.
    `rg -n --pcre2 'hover:bg-accent/\d+|bg-accent/50' -g '*.tsx' src` · **38**.
    **Skip** any file also matching
    `data-\[highlighted\]|data-highlighted|CommandItem|DropdownMenu|SelectItem|MenubarItem|ContextMenu`
    (**16 of 65** `hover:bg-accent*` files) — rewriting only the `hover:` half in a Radix menu
    *creates* the flicker that #35's identical-styling rule exists to prevent. **Downgraded to `ask`:**
    49 eligible files is a design-system migration, not a lint, and it contradicts the documented
    token semantics (`accent` = hover response). Propose once, repo-wide, quoting the conflict.
    When applied, both halves change together.

19. **`mechanical` `visual`** — Off-scale font sizes snap to the step: `text-[13px]`/`text-[15px]`→
    `text-sm`, `text-[17px]`→`text-base`.
    `rg -n --pcre2 'text-\[(13|15|17)px\]' -g '*.tsx' src` · **13**.
    13/15/17 sit *between* steps; 11px sits below the smallest. **`text-[11px]` is memo-only
    license** — bp2's `agents/tailwind-4.md:129,131` bans all arbitrary `text-[Npx]` and sets a
    12px floor.

20. **`ask` `visual`** — Delete hand-tuned overrides of an already-sized primitive
    (`className="h-7 gap-1.5 text-xs"` beside `size="sm"`); raise the `size` prop instead.
    `rg -n --pcre2 'className="[^"]*\bh-7\b[^"]*text-xs' -g '*.tsx' src` · **28**.

21. **`mechanical` (text-adjacency half only) `visual`** — Icon size follows its adjacent text.
    `rg -n --pcre2 'size-4[^"]*\btext-xs\b|text-xs[^"]*\bsize-4\b' -g '*.tsx' src` · **4, clean** → `size-3.5`.
    **The original pattern is replaced**: `size-5` returns **223** and `size={20}` **75**, both
    usually correct. The control-adjacency half (`size={20}` inside a `size="sm"` button) is
    read-the-component.

22. **`ask` `visual`** — Overflow menus use the horizontal glyph (`MoreHorizontal`/`Ellipsis`), a
    value switcher uses `ChevronsUpDown`, and plain lucide beats its `2` variant.
    `rg -n --pcre2 '<(MoreVertical|EllipsisVertical|Undo2|Redo2|FilePlus2)[\s/>]' -g '*.tsx' src` · **40**
    (80 raw including import lines, which duplicate the usage hit).

23. **`mechanical` `visual`** — Sticky chrome takes the shared z token and is fully opaque; its
    divider is an inset cell shadow.
    `rg -n --pcre2 'sticky[^"]*\bz-(10|20|30|40|50)\b' -g '*.tsx' src` · **31**
    `rg -n --pcre2 '(sticky|Overlay|scrim)[^"]*backdrop-blur' -g '*.tsx' src` · **5, clean**.
    **The blur must be on the same element as `sticky`/`fixed`.** An unanchored `backdrop-blur`
    matches **21 files** and would strip `surface-glass` (20 files, and the *prescribed* treatment
    for anything over map tiles or imagery), the `Spotlight` coach mark, and `LockedSectionBlur`.
    `Except:` `surface-glass` and its dark companion · Spotlight/coach-mark scrims · any deliberate
    paywall blur · anything in a protected path.

24. **`ask` `visual`** — Never inline SVG paths or hand-roll a file-kind icon switch when the icon
    set or `FileTypeIcon` already has it.
    `rg -nl --pcre2 '<path d="' -g '*.tsx' src/components src/features` · **14 files**.

25. **`mechanical` in JSX text nodes · `ask` in attributes · `copy`** — `...`→`…`, straight
    quotes/apostrophes→typographic, no trailing period on a label, button, or single-sentence headline.
    `rg -n --pcre2 '(placeholder|label|title|content|description)="[^"]*\.\.\."' -g '*.tsx' src` · **94**
    `rg -n --pcre2 '(label|title|heading|aria-label|placeholder)="[^"]*[a-z]\."' -g '*.tsx' src` · **7, clean**.
    **The original `(?<!\.)\.\.\.(?!\.)` returned 3998** — it matched every JS/JSX spread
    (`{...props}`, `...filters`). It must be scoped to copy-bearing attributes.
    **Attributes are `ask`:** `aria-label` and visible text are Playwright selectors, so a
    typographic apostrophe breaks `getByLabel` and snapshots. Exclude `*.test.*`, `*.spec.*`,
    `__snapshots__`, `*.graphql.ts`, and all `.ts`.
    **`&`→`and` is narrowed** to a sentence, a verb-bearing action label, or ≥4 words — two-noun
    section heads (`"Notes & attachments"`, `"Structure & fees"`) and `X&Y` are correct as-is.

26. **`mechanical` `copy`** — Pluralize every generated count inline; never `(n)`, never `1 files`.
    `rg -n --pcre2 '\{\w*[Cc]ount\}\s+\w+s\b|\(\{\w*[Cc]ount\}\)' -g '*.tsx' src` · **20, clean**.
    (The original's optional braces matched plain calls like `getFilesLabel(fileCount)` — 70 hits.)

27. **`ask` (numeric) · `mechanical` (date) `visual`** — Numeric readouts that stack get
    `tabular-nums`; table **date** columns align left. **The numeric-alignment half is `ask`** —
    right-aligned numerics are near-universal and are the reason `tabular-nums` exists.
    `font-mono` comes off hex/opacity inputs, stays on chart values and cited data cells.

## Tier 3 — state, a11y, and keyboard (28–37)

28. **`refactor` (association) · `flag` (deletion) `interaction`** — A visible label is a real
    label: `useId()` + `htmlFor`/`id` (or `aria-labelledby` for a `button`/`role="group"`).
    `rg -n --pcre2 '<Label[\s>](?![^>]*(htmlFor|aria-labelledby|\bid=))' -g '*.tsx' src` · **39, clean**
    (the original lacked a word boundary and matched `<LabelsInfoButton />`; 102 hits).
    **Deleting the now-redundant `aria-label` is `flag`** — visible text is often a weaker name.
    Skip if the insertion point isn't a component body: `useId` is a hook.

29. **`mechanical`, scoped `interaction`** — A popover or suggestion panel opened from a text input
    must not steal the caret: `onOpenAutoFocus={(e) => e.preventDefault()}`. He swore about this one.
    `rg -n -A4 'PopoverContent' -g '*.tsx' src | rg -c '<(input|textarea|Input|Textarea)'` · **2, clean**.
    **Scope: a non-modal popover anchored to a caret-holding input — never `Dialog`, `AlertDialog`,
    `Sheet`, or `modal`-true content.** `onCloseAutoFocus` is `ask`: suppressing focus *return* is a
    bigger a11y cost than suppressing entry.

30. **`flag` `interaction`** — An icon-only button gets an `aria-label` naming the **action**,
    interpolated with the row's own data inside a `.map()`.
    `rg -n --pcre2 'aria-label="(View|Remove|Delete|Edit|Open) \w+"' -g '*.tsx' src` · **41**, most
    singletons outside any map and therefore correct. Only a finding inside a `.map(`/`.flatMap(`
    body, which needs the enclosing block read.
    **Prefer a native `<button>`; `role="button" tabIndex={0}` is the fallback only when the element
    genuinely cannot be one** — a human reviewer corrected him out of the `role` form. When
    promoting a container, use `toggleOutside`-style extraction so no interactive descendant ends up
    nested. `Except:` never promote a **non-interactive descendant** of an already-clickable
    container — plain connector text inside a click target stays plain, deliberately.

31. **`mechanical` `interaction`** — Decorative SVGs, illustrations, scrims, masks, and separator
    glyphs get one `aria-hidden` on the outermost node — not one per part — plus
    `pointer-events-none` when they overlay a target.

32. **`ask` `interaction`** — `role="alert"` is for genuine failures only; informational outcomes are
    `role="status"`, static callouts `role="note"`; an `aria-live` container that can be empty gets
    `empty:hidden`. `rg -n 'role="alert"' -g '*.tsx' src` · **12, clean**.
    `ask`, not auto: "not a genuine failure" is a product judgment, and the corpus contradicts
    itself (bp2#6363 adds `alert`, bp2#7225 removes it).

33. **`ask` + read-the-component `interaction`** — A disabled control states its reason; a disabled
    button used as a Tooltip trigger needs a `<span className="inline-flex">` wrapper, since
    `disabled:pointer-events-none` eats the hover.
    **No grep form works** — single-line returns 0 (real cases have newlines between the tags), `-U`
    returns 269–339 with spans crossing unrelated components. Grep `<Tooltip` files, then check
    whether the trigger child takes `disabled`.
    **Propose only when both hold:** (a) the tooltip explains *why* the control is unavailable, not
    just what it does — his model case is `content="No phone numbers registered"`; and (b) the
    surface is reachable and hoverable while disabled. **Never as a sweep across a shared toolbar**
    (the bare grep matches 42 files) — his own verdict: *"if the whole surface is disabled and
    unhoverable, skip it."*

34. **`ask` `interaction`** — Submit guards match their handler: add `|| !x.trim()` to **both** the
    `disabled` prop and the early return.
    `rg -n --pcre2 'if \(!(\w*[Vv]alue|query|searchTerm|prompt|instructions|name)\)\s*return' -g '*.tsx' src` · **36**.
    `ask`, not auto: it breaks forms where an empty submit clears or resets, and `.trim()` throws on
    non-strings.
    **`Except:` never extend this to an entitlement, eligibility, or credit query.** A submit stays
    enabled while such a check is pending and the action proceeds in its **free** form. Do not
    propose `disabled={isChecking…}`, and never move the paid/free decision server-side — the user
    must have seen the cost state before anything bills. He refused this twice, the second time with
    *"this is intentional bro."*

35. **`ask` `interaction`** — A single-select `ToggleGroup` must reject deselect
    (`if (next) onChange(next)`); a chip that opens a picker needs `transition-colors hover:bg-muted`.
    `rg -n 'type="single"' -g '*.tsx' src` · **25** (two-step; the guard check needs reading).
    `ask` unless the value type has no `null`/`'all'` member — correct for a required setting, a bug
    for a filter group.
    **The "a menu item is `cursor-pointer`, fixed in the primitive" clause is split out and is
    `flag` only.** `rg -c 'cursor-pointer' src/components/ui/*.tsx` returns **zero** — so "fixed in
    the primitive" was instructing an edit inside a protected path. Report it as an upstream Airy
    defect, or add `[&_[data-slot=dropdown-menu-item]]:cursor-pointer` on an app-owned wrapper.

36. **`ask`, conditional `interaction`** — In a keyboard-navigable list, delete the `hover:` class and
    drive one highlight off the active index, synced on `onMouseMove` (never `onMouseEnter`).
    **Only when an `isActive`/`isSelected`/`activeIndex` already exists in scope** — otherwise it
    removes all hover feedback.

37. **`refactor` `interaction`** — Replace `window.confirm`/`window.alert` with an in-app
    `AlertDialog`; keep `beforeunload` only for real tab close.
    `rg -n 'window\.(confirm|alert)\(' src` · **1 hit — `PreventUnload.tsx`, the sanctioned
    `beforeunload` case. Named exception; not a finding.**

## Tier 4 — overflow, loading, and layout stability (38–43)

38. **`refactor` `patterns`** — Middle-truncate filenames so the extension survives — measured
    (canvas `measureText`), with an invisible full-width copy so the column can't ratchet.
    `rg -n --pcre2 'truncate[^"]*"[^>]*>\{[^}]*(fileName|displayName)' -g '*.tsx' src` · **12, clean**.

39. **`ask` `patterns`** — Show the full value **only when it actually truncated**
    (`hidden={!isTruncated}`), decided by measuring the DOM on `onPointerEnter` — never a
    character-count heuristic, never an always-on tooltip.
    `rg -n --pcre2 'Tooltip[^>]*content=\{(\w+\.)?(fileName|value|label)\}' -g '*.tsx' src` · **13, clean**.
    **Merged with the `title=`→`Tooltip` rule, which contradicted it** (one added `title`, the other
    removed it; run in either order they fight). One rule: when text is truncated in JS and has no
    accessible full value, **add `title={fullValue}`** — unless the file already imports `Tooltip`
    **and** the element sits in a dense grid (swatches, thumbnails, a sweepable list), in which case
    use `Tooltip` + `hideArrow` + `pointer-events-none!` + a scoped
    `TooltipProvider delayDuration={250|300} skipDelayDuration={0} disableHoverableContent`.

40. **`ask` `patterns`** — Fix sibling stacking on the ancestor that is genuinely a sibling of the
    competing element, and delete the ineffective inner z-index.
    `rg -n 'hover:z-10' -g '*.tsx' src` · **2, clean**.
    `z-10`→`z-[var(--z-sticky)]` **only** when the element also carries `sticky`/`fixed` and is not
    in a protected path. **Never on `hover:z-*`** — a local lift wants `hover:z-[1]`; `z-10` made a
    hovered row compete with page overlays. Never inside an `isolate` container.

41. **`flag` + read-the-component `patterns`** — `Skeleton` never sits on a `bg-muted` surface (it
    *is* `bg-muted` + pulse); use the transform-based `.lev-shimmer`, and never animate a shimmer
    with `background-position`.
    **No grep form works** — `-B3 | rg bg-muted` returns 98 by counting sibling classNames three
    lines up; a bounded `-U` gave 106. The real question is the Skeleton's *container* background.

42. **`flag` `patterns`** — A skeleton mirrors the real row's geometry — same icon box, text width,
    padding — occupies the same box as what it replaces, and renders `null` for an actions column.
    "Differs" is unmeasurable without rendering both.

43. **`ask` `interaction`** — An expanding or revealing control must not reflow the page: reserve the
    collapsed footprint with a `relative` wrapper and overlay the expanded box absolutely; a swapping
    text line gets a fixed height. **The `h-5` constant is one PR's line box** — `ask` when the text
    size isn't `text-sm`.

## Tier 5 — structural judgment (44–48)

44. **`ask` + read-the-component `flows`** — If the action can succeed without an answer from the
    user, do it and confirm — a modal collecting *optional* input before a safe action is a blocking
    step. Tell: a modal whose only field is optional, or a button with two code paths (first-run vs
    every other time).
    **The original grep returned 0** — it was written from one PR's exact expression
    (`!memo?.lastPublishedDate`), which no longer exists. Candidate finder only:
    `rg -n --pcre2 'if \(!\w+(\?\.)?\w*(last|first|has)\w*\)' -g '*.tsx' src`.

45. **`ask` `patterns`** — A settings surface with more than one *kind* of control is a
    `PopoverContent` panel, never a `DropdownMenu` with submenus — a menu offers items, a panel
    offers a state.
    `rg -n 'DropdownMenuSub\b|DropdownMenu\.Sub\b' -g '*.tsx' src --glob '!src/components/ui/**'` · **3**.
    **Both forms are required**: this repo re-exports a namespaced `DropdownMenu.Sub`, and the bare
    `DropdownMenuSub` grep returns zero on files that use it.

46. **`flag` `visual`** — Peer controls in one panel share a height and a visual weight; a labelled
    preview-card grid beside a bare swatch circle is the defect, and it's where the panel's height
    went. One row, one setting — never two controls behind one label.

47. **`flag` `patterns`** — A bare count or badge beside a **single value** reads as "N problems
    here": use `ChevronsUpDown` and let the panel explain. And when copy is summarizing a *shape*
    (agreement, conflict, distance), group and sort it instead of writing the sentence.
    **`Except:` a count on a bulk-action control is inventory, not a status** — leave it, and never
    propose making it reflect the active selection. *"this is intentional -- we want to show the
    count of available mutations."*

48. **`ask` `patterns`** — Delete the control that shouldn't exist: one whose two options are two
    spellings of one value, one another control already decides, one with no visible effect, or a
    heading restating the page title above it. Delete the prop plumbing, the dead flag, and the
    concept the removed screen existed to explain — same diff, comments included.
    **`Except:` an intentionally-absent state is not a missing effect.** A selection tick that is
    ID-matched-or-absent, and a bulk count that reports availability rather than the active choice,
    both look inert and are correct. Before proposing deletion, check whether the absence is the
    feature.
    **The "dead prop" half is `flag`** — exported props are legitimately uncalled; it needs
    whole-repo reference analysis. The `console.log` half is `mechanical`.

---

## Deleted rules — do not re-add

| Rule | Why |
|---|---|
| `getBoundingClientRect().width` → `offsetWidth` | Not equivalent. `offsetWidth` is a rounded integer excluding transforms, doesn't exist on `SVGElement`, returns `0` for `display: contents`. 13 live call sites. Survives only as a `flag` scoped to "measuring inside a `transform`ed subtree". |
| `overflow-x-auto` on a "static/decorative" row → `overflow-hidden` | "Decorative" is not detectable; guessing wrong removes a real scroll affordance on narrow viewports. |
| "Any `hover:` state needs a focus mirror" (broad form) | On a real `<button>` the focus-visible ring *is* the mirror. Superseded by #5's reveal-only form. |
| `Multi-Family` → `multifamily` | Property type is CRE taxonomy; `CLAUDE.md` reserves Title Case for it. |
| `title=` → `Tooltip` (standalone) | Undid the rule that adds `title`. Merged into #39. |
| `hover:z-[1]` not `hover:z-10` (standalone) | Folded into #40's exception clause. |

## Scoped to one surface

Correct where found, wrong as a global rule — the scope belongs in the rule text, not a footnote.

`ring-1 ring-inset ring-black/10` on tracks → **colour picker only** (the literal vanishes on
dark) · overlay-painted swatch border → **swatch / thumbnail / avatar only** (it adds a DOM node
per card) · sticky-header inset divider → **tables** · `uppercase`-stripping section heads →
**Index/FAQ-family dashboards** (the paired acronym map stays global) · chart constants
(`CHART_BAR_RADIUS`, `maxBarSize=22`, `barCategoryGap="34%"`) → **charts** (one PR, one library) ·
`translateX` shimmer → **hand-authored keyframes** · `useId()` SVG `<defs>` ids → **inline SVG
components** · the duration ladder → **reference values, never an autofix** (several rows rest on
one PR each).

## Conflicts the skill must state rather than silently resolve

- **Alpha on semantic tokens.** `airy-rules/design-system-rules.md:144` bans them; live usage is
  `bg-muted/N` 346, `border-border/N` 109, `bg-primary/N` 104, `ring-ring/N` 66. **Never introduce
  one; never autofix toward one; leave existing house values alone.** The one direction that *is* a
  fix: an alpha standing in for a missing token (`bg-warning/90`→`bg-warning-background`,
  `text-foreground/70`→`text-muted-foreground`). Say so in the report.
- **`bg-accent` vs `bg-muted` for hover.** Token semantics say `accent` is the hover response; the
  newest PRs make both hover and selected `bg-muted`. Newest evidence wins (#18), but it is `ask`.
- **Spinner vs `MorphingLevIcon`.** The discriminator is **not** "is this AI work?" but **"does text
  appear in this element?"** `MorphingLevIcon` / typing dots belong where the output will render; a
  control that *submits* and waits for output elsewhere keeps a plain `Loader2`. If both are on
  screen, both are correct — bp2#7558 ships exactly that pairing.
- **Solid vs dashed separators.** Solid wins. Dashed survives only for chart gridlines, the "Other"
  bucket stroke, and annotation traces.
- **`border-border`.** Redundant in bp2, deliberate in memo (39 hits). Repo-scoped, which is why it
  is not a numbered check. If run in bp2: the pattern is
  `(?<![\w-])border(?:-[trblxy])?\s+[^"']*border-border(?![/\w-])` — **both** conditions, because
  the loose `\bborder-border\b` form matched **552** and **173 (31%) were wrong edits**: 109 alpha
  variants (`border-border/70`, where opacity is intentional per `agents/tailwind-4.md:29`) plus 64
  uses with no structural border to make them redundant. Skip `[&_` arbitrary variants.

## Never flag

Missing screenshots · third-party vocabulary (`featureType: 'poi'`, API string keys, HTML element
names) · domain prose ("POI is ordinary CRE vocabulary there") · `levender`, a deliberate brand
misspelling · renames that remove no code · un-attributable persisted values · gating an idempotent
migration · inherent limitations · DOM-level tests of portalled popovers · a secondary affordance
the design retires · a tooltip on a disabled button across a whole shared toolbar.

## Already enforced elsewhere — cite, don't re-implement

`useEffect`/`useMemo` hygiene, Apollo no-destructuring, `*.graphql.ts` naming, named exports →
`CLAUDE.md` + `agents/*.md` + `documentation/RULES.md` · backend-side filtering →
`agents/nextjs-15.md` · formatter and lockfile churn → Prettier + the pre-commit hook · import
order, unused imports, `console.log` → lint · the full Title Case allowlist, Oxford commas,
number/date/unit formatting → `reference/copy-allowlist.md` and `$ux-copy-review` · mobile-first
breakpoints → the `mobile-first-design` skill · CVA variant authoring → the `shadcn-ui` skill ·
PR title/Linear IDs → the `pr` skill.
