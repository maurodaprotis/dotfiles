# `/ethanize` — remediation patch list

Apply in the order below. Derived from `synth/adversarial.md`; every count re-measured against
`/Users/maurodaprotis/orca/workspaces/borrower-portal-v2/ethanize` (read-only) on 2026-08-25.

**Namespace:** this file uses `R*` (remediation). My adversarial findings were `F1–F40`; that collides
with the flows namespace, so **adversarial `F1` (protected paths) is now `R1`**, and every other
adversarial `Fn` is referenced below as `adv-Fn`.

**ID mapping:** visual autofix rules map 1:1 — old `A1..A40` → `V1..V40` (verified: `V1` = square boxes,
`V5` = `border-border`, `V17` = `transition-all`, `V25` = dialog scrim, `V39` = `title`→Tooltip).
Interaction / patterns / copy are mid-renumber, so those are referenced by **old ID + verbatim first
clause** — map by text, not by number.

---

## Why the autofix tier was overstated

> **A verbatim before/after pair is evidence that a change happened once, not that it should happen always.**

The extraction had a structural bias: a rule with a quotable `before:` / `after:` string *looks*
mechanical, because the replacement is right there. But the quotability comes from the diff format, not
from the rule's determinism — Ethan writes exact strings whether he's fixing a typo or making a taste
call. So judgment got promoted into the autofix tier by the shape of its evidence.

`patterns.md` had already measured the honest signal and the synthesis inverted it:
**`overflow` 35% autofixable, `loading` 23%, `interaction-pattern` 11%, `hierarchy` 10%,
`component-choice` 9%.** That gradient is the correct prior. Mechanics are autofixable; taste is not, and
no amount of verbatim quoting changes which one a rule is. **On the next refresh, tag by that gradient
first and let the evidence argue upward** — never the reverse. The test a rule must pass to stay `auto`:
*is the `after:` the only possible correct value, or merely the value he picked that day?*

---

## R1 — The global protected-path exclusion

**Apply first. It unblocks ~a third of the visual and interaction autofixes on its own, and without it
`/ethanize`'s first run on this repo edits `ui/button.tsx` and gets the PR rejected.**

### R1.1 The path list (verbatim, from `CLAUDE.md` + `airy-rules/design-system-rules.md:31,43,83,107,150,212–224`)

```
src/components/ui/**
src/components/airy-blocks/**
src/components/lev-assets/**
src/styles/airy-theme/**
airy-rules/**
```

### R1.2 The form the exclusion takes

**A pre-flight filter on the file list, not a per-rule caveat.** Rules must not each remember to opt out —
one of them will forget, and it will be the one that edits `button.tsx`.

```
1. collect candidate files (git diff / glob)
2. partition:  editable[]  |  protected[]      ← single filter, before any rule runs
3. run every rule against editable[] only
4. run every rule against protected[] in REPORT-ONLY mode
5. emit two sections: "Fixes applied" and "Needs an upstream Airy change"
```

Rationale for step 4: silently skipping is the failure mode that lets a real finding disappear. The
protected file still gets linted; only the **write** is withheld.

### R1.3 The report-it-instead behavior (required, not optional)

A hit inside a protected path is emitted as a finding with an upstream proposal, in this shape:

```
⚠  Needs a change in a protected Airy path — not edited.

    src/components/ui/button.tsx:42
    rule: V17 — `transition-all` is banned
    found:    'transition-all duration-200'
    proposal: 'transition-[color,background-color,box-shadow] duration-200'

    This file is installed from the Airy registry. Route around it (app-owned wrapper,
    className override, or a data-slot descendant selector), or propose the change
    upstream in the Airy registry — do not patch the installed copy.
    See airy-rules/design-system-rules.md:43.
```

### R1.4 Measured blast radius avoided

| rule | protected files hit | would have been an illegal edit |
|---|---|---|
| `V17` `transition-all` | **7** (`button`, `sidebar`, `accordion`, `badge`, `switch`, `tabs`, `progress`) | yes |
| interaction `A4` `ring-2`→`ring-3` | **11** files (17 occurrences) | yes — and `button.tsx` is named as un-editable at `design-system-rules.md:83` |
| `V5` `border-border` | **4** | yes |
| `V25` dialog scrim | `ui/dialog.tsx` — the only possible target | yes |
| interaction `A2` hover-mirror (after R4 narrowing) | **1 of 10 real hits** is `ui/table.tsx` | yes |

### R1.5 The corpus teaches the violation — add this warning to the skill

**bp2#7228 edits `src/components/ui/slider.tsx` and `src/styles/airy-theme/overrides.css` — both
protected.** Rules extracted from it ("the primitive forwards ARIA to its thumb", the
`html[data-slider-dragging]` cursor override) instruct an agent to do the thing the repo forbids. Ethan
can, because he also owns the Airy registry; other agents cannot. Any rule whose evidence cites bp2#7228
carries an inline note: *"landing site is protected — propose upstream, don't patch."*

---

## R2 — Regex tightening: `V5` `border-border`

**Attack (adv-F14):** `\bborder-border\b` matches inside `border-border/70`; deleting the alpha changes
the border colour. `agents/tailwind-4.md:29` explicitly permits a colour "when the color or **opacity**
intentionally differs from the default."

| | pattern | hits |
|---|---|---|
| before | `\bborder-border\b` | **552** |
| after (cond. 1) | `border-border(?![/\w-])` | **443** |
| after (cond. 2 — required) | `(?<![\w-])border(?:-[trblxy])?\s+[^"']*border-border(?![/\w-])` | **379** |

Both conditions are required: the second is the actual redundancy test (a structural border is present in
the same class string). **173 of 552 loose matches (31%) were wrong edits** — 109 alpha variants plus 64
`border-border` uses with no structural border to make them redundant.

Also exclude arbitrary variants: skip any match preceded by `[&_` on the same attribute
(e.g. `[&_td]:border-border`). Scope stays **bp2 only** (memo keeps explicit `border-border`).

---

## R3 — Regex tightening: `V16` opacity-modified foreground

**Attack (adv-F17):** the loose form captures five tokens whose correct replacement is *not*
`muted-foreground`.

| | pattern | hits |
|---|---|---|
| before | `text-[\w-]*foreground/\d+` | **103** |
| after | `text-(?:sidebar-)?foreground/\d+` | **30** |

The 73 wrongly-captured matches are `text-muted-foreground/N` (70), `text-primary-foreground/N`,
`text-success-foreground/N`, `text-warning-foreground/N` — rewriting any of them changes the colour to
something the design never specified.

Additional guard: skip the file if it also matches `surface-glass`, `absolute inset-0`, or a
map/overlay path — alpha over imagery is deliberate (bp2#7343).

---

## R4 — Regex tightening: interaction `A2` hover-mirror ("any hover state needs a focus/coarse mirror")

**Attack (adv-F32):** as written it fires on every `hover:bg-*`, nearly all on real `<button>`s where the
focus ring already is the mirror. The rule is about hover-**reveal**, not hover-**styling**.

| | detection | hits |
|---|---|---|
| before | any `hover:bg-` occurrence | **420** |
| after (files with a hover-reveal) | `group-hover[\w/-]*:opacity-100` | **90 files** |
| after (missing a mirror) | above **AND NOT** `focus-visible:opacity-100 \| group-focus-within[\w/-]*:opacity-100 \| pointer-coarse` | **10 files** |

**420 → 10.** 80 of the 90 reveal files already comply, which is the strongest evidence in the corpus that
this *is* his rule and the codebase already follows it. The 10 real hits:

```
components/Chat/MessageBubble.tsx
components/AddressBook/MapView/AddressBookMapView.tsx
components/signup/components/SignUpAppPreviewPanel.tsx
components/ui/table.tsx                     ← excluded by R1 (protected)
components/Layout/SidebarChecklist/SidebarOnboardingChecklist.tsx
components/Lenders/Profile/Insights/Transactions.tsx
components/Deals/Pipelines/PipelineMap/DealsMapView.tsx
components/Deals/Overview/Widgets/Commission/CommissionListItem.tsx
components/Deals/Lenders/TableWithSideBars/CampaignSequence/CampaignPickerMenuItems.tsx
components/Deals/Lenders/TableWithSideBars/CampaignSequence/CampaignSequenceStepCard.tsx
```

R1 removes one of the ten — a clean demonstration that the path filter must run first.

The broad "hover styling needs a focus mirror" claim is **deleted**, not narrowed: on a real `<button>`
the focus-visible ring is the mirror, and demanding a second one is noise.

---

## R5 — Guard: `V14` `hover:bg-accent` → `hover:bg-muted`

**Attack (adv-F16):** interaction `A22` requires `hover:` and `data-[highlighted]:` to be styled
**identically** (bp2#6549: *"it needs to be identical everywhere or the menu flickers between two
highlight styles"*). `V14` rewrites only the `hover:` half — in a Radix menu it *creates* the exact bug
`A22` exists to prevent.

| | detection | files |
|---|---|---|
| before | any `hover:bg-accent*` | **65** |
| skip | file also matches `data-\[highlighted\]\|data-highlighted\|CommandItem\|DropdownMenu\|SelectItem\|MenubarItem\|ContextMenu` | **16** |
| after | eligible | **49** |

**Changed my mind on second look:** I estimated ~20 files in the adversarial pass; it is 65, and 49 remain
eligible after the skip. Rewriting the hover surface of 49 files is **a design-system migration, not a
lint** — and it contradicts the app's own token semantics (`bg-accent` *is* the hover response per
bp2-nits), which `visual.md` C1 already concedes. So `V14` gets both the skip guard **and** a downgrade:

> **`V14`: `auto` → `ask`.** Propose once, repo-wide, with the C1 conflict quoted. Do not apply per-file.

When it is applied, both halves change together.

---

## R6 — Downgrade list (`auto` → `ask` / `flag`)

`ask` = present the finding and the proposed fix, apply only on a yes. `flag` = report only, no proposed
edit (the correct fix needs information the skill doesn't have).

| ID | rule (first clause) | now | → | reason |
|---|---|---|---|---|
| `V14` | One hover surface: `bg-muted` | auto | **ask** | 49-file design migration, contradicts documented token semantics (R5) |
| `V27` | Table body cells align middle; **number**/date columns align left | auto | **ask** (numeric half) | right-aligned numerics are near-universal and are why `V35` adds `tabular-nums`; date half stays auto (see R7) |
| `V40` | Delete stray debug **and dead flexibility** | auto | **flag** (prop half) | needs whole-repo reference analysis; exported props are legitimately uncalled. `console.log` half stays auto |
| `V39` | `title=` on a truncating element → real `Tooltip` | auto | **merged** | contradicts patterns "add `title` on JS truncation"; see R9 |
| int `A5` | Wire a non-native clickable region as a real button (`role="button" tabIndex={0}` + key handlers) | auto | **flag** | synthesizes ARIA; the div often already wraps real buttons (nested interactives); his own preference is a real `<button>` |
| int `A7` | Pair a checkbox/input with a real `<label htmlFor>` — **"delete the now-redundant `aria-label`"** | auto | **split** | association half stays auto; **the deletion is `flag`** — visible text is often a weaker name than the label. Also: skip if the insertion point is not a component body (`useId` is a hook) |
| int `A9` | Live-region severity: `role="alert"` → `role="status"` | auto | **ask** | "not a genuine failure" is a product judgment; the corpus contradicts itself (bp2#6363 adds `alert`, bp2#7225 removes it) |
| int `A13` | Single-select `ToggleGroup` must reject deselect | auto | **ask** unless the value type has no `null`/`'all'` member | correct for a required setting, a bug for a filter group |
| int `A14` | Add `\|\| !value.trim()` to a submit's `disabled` | auto | **ask** | breaks forms where empty submit clears/resets; `.trim()` throws on non-strings |
| int `A18` | `onOpenAutoFocus={(e) => e.preventDefault()}` | auto | **scoped + ask for `onCloseAutoFocus`** | see R7; suppressing focus *return* is a bigger a11y cost than suppressing entry |
| int `A11` | Don't use `Skeleton` on a `bg-muted` surface | auto | **flag** | requires the ancestor background; unresolvable statically |
| int `A26` | Reset `scrollTop`/`scrollLeft` when the previewed item changes | auto | **ask** | wrong for bottom-pinned panes, virtualized lists, preserved-scroll master/detail |
| int `A25` | Fixed `h-5` on an `AnimatePresence mode="wait"` text line | auto | **ask** when the text size isn't `text-sm` | `5` is one PR's line box |
| pat | "A row skeleton whose geometry differs from the row" | auto | **flag** | "differs" is unmeasurable without rendering both |
| pat | "An always-mounted container of optional chrome → compute `has*`" | auto | **ask** | matches most conditional-render components |
| pat | "Disabled options sorted by relevance → disabled as primary sort key" | auto | **ask** | a data-ordering change, not a style fix |
| pat | "`truncate` whose flex ancestors lack `min-w-0`" | auto | **auto, narrowed** | keep auto **only** when the direct parent is a `flex`/`grid` in the same JSX expression; ancestor-walking is `flag` |
| int `A22` | Keyboard+hover are one class — **"delete the `hover:` class"** | auto | **conditional** | only when an `isActive`/`isSelected`/`activeIndex` exists in scope; otherwise it removes all hover feedback |
| copy `2.3` | Typographic apostrophes and quotes | auto | **ask** in attributes; **auto** in JSX text nodes only | `aria-label`/text are Playwright selectors; breaks `getByLabel` + snapshots. Exclude `*.test.*`, `*.spec.*`, `__snapshots__`, `*.graphql.ts`, all `.ts` |
| copy `2.4` | `&` → `and` | auto | **auto, narrowed** | fires only on a sentence, a verb-bearing action label, or ≥4 words. Two-noun section heads (`"Notes & attachments"`, `"Structure & fees"`, `"Valuation & income"`) and `X&Y` with no spaces are excluded — 9 live hits, most correct as-is |
| copy `2.7` | Hyphenate compound modifiers | auto | **auto, list edited** | prose only; every entry naming a property/loan/document/report type is removed (see R8) |

**Downgrade count: 21 rules touched — 9 → `ask`, 5 → `flag`, 7 narrowed or split in place.**

---

## R7 — Scope-to-one-surface list

Each of these is correct where it was found and wrong as a global rule. Add the surface to the rule text,
not just a footnote — a scope buried in a note gets read as license.

| ID | rule | scope to |
|---|---|---|
| `V21` | Slider/gradient tracks: `ring-1 ring-inset ring-black/10`, not border + inner shadow | **colour picker** (`ring-black/10` is a literal and vanishes on dark) |
| `V23` | A swatch/thumbnail border is an overlay painted after the fill | **swatch / thumbnail / avatar** — not "any bordered `overflow-hidden` wrapper"; it adds a DOM node per card |
| `V26` | Sticky header divider is an inset cell shadow | **tables** (the `[&_th]`/`[&_tr]` variants are table-shape-specific) |
| `V27` | …number/**date** columns align left | **date columns** (numeric half downgraded, R6) |
| `V29` | Chart constants (`CHART_BAR_RADIUS`, `maxBarSize=22`, `barCategoryGap="34%"`) | **charts** (one PR, one chart library) |
| `V15` | Section heads are sentence case (`uppercase` stripping half) | **section heads** in Index/FAQ-family dashboards. The paired acronym map stays **global** |
| int `A12` | Shimmer must be `translateX`, not `background-position` | **hand-authored keyframes / CSS** |
| int `A24` | SVG `<defs>` ids from `useId()` | **inline SVG components** |
| int `A18` | Suppress Radix autofocus | **non-modal popover anchored to a caret-holding input** — never `Dialog`, `AlertDialog`, `Sheet`, or `modal`-true content |
| int §3.2 | The duration ladder | **reference values, never an autofix** — several rows rest on one PR each (1050ms row move, 640ms image slide, 3000ms beam) |
| `V2` J9 | `text-[11px]` is a real value, leave it | **memo only** — bp2's `agents/tailwind-4.md:129,131` bans *all* arbitrary `text-[Npx]` and sets a 12px floor; bp2 ships 69× `text-[10px]` and 37× `text-[11px]` in violation, so read in bp2 this note is license to preserve a documented violation. Say "memo only" at the point of use |

**Scope count: 11.**

---

## R8 — Delete list

| ID | rule | reason |
|---|---|---|
| pat | `getBoundingClientRect().width` → `offsetWidth` | **Not equivalent.** `offsetWidth` is a rounded integer excluding transforms, doesn't exist on `SVGElement` (throws `undefined`), and returns `0` for `display: contents`. 13 live call sites. Re-add as a **flag** scoped to "measuring inside a `transform`ed subtree" — which is all memo#783 ever claimed |
| pat | `overflow-x-auto` on a "static/decorative" row → `overflow-hidden` | "static/decorative" is not detectable; guessing wrong removes a real scroll affordance on narrow viewports |
| int `A2` | (broad form) "any `hover:` state needs a focus mirror" | On a real `<button>` the focus-visible ring **is** the mirror. Superseded by the reveal-only form (R4) |
| copy `2.7` | `Multi-Family` → `multifamily` | Property type is CRE taxonomy; `CLAUDE.md` reserves Title Case for it. One live hit — `VaultLoginPage.tsx:196 details="Multi-Family"` — is exactly the protected class. Rest of the hyphenation list survives |
| `V39` | (standalone auto form) `title=` → `Tooltip` | Undoes the patterns rule that adds `title`; merged in R9 |
| int `A28` | "`hover:z-[1]` not `hover:z-10`" as a standalone rule | Folded into `V9`'s exception (R9); it is a one-site fix, and `V9` already has to reason about local vs page-level stacking |

**Delete count: 6.**

---

## R9 — Two merges (resolve self-contradiction)

**R9.1 — `title` vs `Tooltip`.** Currently `patterns` says *add* `title` on JS truncation and `V39` says
*replace* `title` with a `Tooltip`. Run in either order they fight; run twice they oscillate. One rule:

> When text is truncated in JS and has no accessible full value: **add `title={fullValue}`** — unless the
> file already imports `Tooltip` **and** the element sits in a dense grid (swatches, thumbnails, a
> sweepable list), in which case use `Tooltip` + `hideArrow` + `pointer-events-none!` + a scoped
> `TooltipProvider delayDuration={250|300} skipDelayDuration={0} disableHoverableContent`.
> *(bp2#6070 is the `title` precedent; memo#663 is the grid precedent and is later.)*

**R9.2 — `V9` z-index.** Merge the `hover:z-[1]` finding in as the exception clause:

> `z-10` → `z-[var(--z-sticky)]` **only** when the element also carries `sticky`/`fixed` and is not in a
> protected path. Never on `hover:z-*` (a local lift wants `z-[1]` — bp2#6535: `z-10` made a hovered row
> compete with page overlays), and never inside an `isolate` container.
> Cites `agents/tailwind-4.md:63` — don't add z-index to primitives that already bake in the right layer.

---

## R10 — Alpha-on-semantic-tokens: the global emit rule

`airy-rules/design-system-rules.md:144` — *"Do not apply alpha modifiers to semantic color variables …
unless the user explicitly asks."* But the ruleset's own **replacement strings** are full of them.
Live usage (already at scale, so the repo ignores the rule in practice):

```
bg-muted/N 346   border-border/N 109   bg-primary/N 104   text-muted-foreground/N 70
ring-ring/N 66   bg-destructive/N 61   bg-foreground/N 21  text-foreground/N 20
```

**Rule:** `/ethanize` may **preserve** an existing alpha-on-semantic string; it must **never introduce
one** where a plain token or a `*-background` pair exists. Where a replacement genuinely needs alpha
(`V10`'s `bg-destructive/10`), emit it **and cite the precedent in the report**, so a reviewer sees it was
deliberate rather than sloppy. Note that `V16` (R3) is the one rule that *agrees* with `:144` — keep its
direction.

---

## R11 — Blast-radius taxonomy + git safety

Every rule carries exactly one blast-radius tag. This replaces the binary `autofixable: yes/no`.

| tag | definition | write behavior | maps from |
|---|---|---|---|
| **`mechanical`** | Single-token, single-valued, no behavior change, no DOM structure change. The `after:` is the *only* possible correct value. | Edit silently. Summarize counts only. | `auto` rules that survived the attack: `V1`, `V10`, `V11`, `V12`, `V13`, `V35`, narrowed `V5`/`V16`, int `A1`, `A3`, `A16`, `A17`, `A23`, `A24`, `A27`, copy `2.2`, `2.5`, `2.9`, `2.10` |
| **`refactor`** | Correct and deterministic, but moves/adds/deletes DOM nodes, imports, or files. Reviewable, not glanceable. | Edit, then **show the diff before commit**. Never batch more than one refactor rule per run without confirmation. | `V23`, `V36`, `V38`, `V30`, `V31`, int `A7` (association half), pat `min-w-0` (narrowed), R9.1 |
| **`flag`** | The correct fix needs information the skill doesn't have — ancestor context, product intent, whole-repo references, or a human's copy. | **Never edit.** Report the finding, quote the rule and the precedent, propose nothing it can't justify. | `V40` (prop half), int `A5`, `A11`, `A22` (unconditional case), pat "skeleton geometry", "dead prop", protected-path hits (R1.3) |

`ask` (from R6) is not a fourth tag — it is `flag` **plus** a concrete proposed edit the user can accept.

### Git safety preconditions for a fix run

1. **`git status` must be clean** (or only the files `/ethanize` was pointed at are dirty). Refuse to run
   otherwise — a mixed working tree makes the fix impossible to review or revert.
2. **Never commit unasked.** `/ethanize` edits the working tree and stops.
3. **Show the diff before any commit**, and always for a `refactor`-tagged change.
4. **Report before fix.** A dry-run report is the default mode; `--fix` is opt-in.
5. **One rule class per commit** if the user does ask to commit: `mechanical` and `refactor` never share a
   commit, so a bad refactor can be reverted without losing the lint pass.
6. **Protected-path hits never touch the tree**, in any mode (R1.2 step 4).

---

## Summary of counts

| patch | count |
|---|---|
| R1 protected-path exclusion | 1 global filter, 5 paths, ≥23 illegal edits prevented |
| R2–R5 regex tightenings | 4 rules (`V5`, `V16`, int `A2`, `V14`) |
| R6 downgrades | 21 rules (9 → `ask`, 5 → `flag`, 7 narrowed/split) |
| R7 scope-to-surface | 11 rules |
| R8 deletes | 6 rules |
| R9 merges | 2 |
| R10 alpha emit rule | 1 global |
| R11 blast-radius retag | all ~116 |

Post-remediation, the honest unattended-trust number moves from **19% → ~60%**, and the residue is
`refactor` (reviewable) rather than `flag` (unusable).
