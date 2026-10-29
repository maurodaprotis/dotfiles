# Adversarial review of the `/ethanize` ruleset

Reviewed: `synth/{interaction,visual,patterns,copy,principles,workflow}.md` (re-listed 2026-08-25 12:15; 6 files).
Autofix inventory attacked: **~116 rules** — interaction A1–A28 (28), visual A1–A40 (40), patterns §6.1 (~38), copy §2.1–2.10 (10).
All counts below are from the live checkout at `/Users/maurodaprotis/orca/workspaces/borrower-portal-v2/ethanize` (read-only).

Verdicts: `keep` · `keep-with-exception` · `downgrade-to-ask` · `downgrade-to-flag` · `scope-to-<surface>` · `delete`.
Ordered by **damage if shipped as-is**.

---

## TIER 1 — will corrupt working code or change behavior

### F1. The whole autofix layer has no protected-path exclusion — **the single largest defect**
**Rules:** visual A5, A6, A7, A9, A14, A16, A17, A19, A20, A24, A25, A30, A31; interaction A1, A4, A19, A21; every copy rule.
**Attack:** `CLAUDE.md` and `airy-rules/design-system-rules.md:31,43,83,107,150,212–224` forbid editing `src/components/ui/`, `src/components/airy-blocks/`, `src/components/lev-assets/`, `src/styles/airy-theme/`, `airy-rules/`. Not one autofix rule names an exclusion. Live blast radius:
- `transition-all` → **34 hits, 7 of them inside `src/components/ui/`** (`button.tsx`, `sidebar.tsx`, `accordion.tsx`, `badge.tsx`, `switch.tsx`, `tabs.tsx`, `progress.tsx`).
- interaction A4 (`ring-2` → `ring-3`) → **17 hits in `src/components/ui/*.tsx`**. The *only* place that rule makes sense is `button.tsx`, which is the file the design-system doc names explicitly as un-editable (`:83`).
- visual A25 (dialog scrim) can only be applied by editing `ui/dialog.tsx`.
- visual A19/A20/A6/A7 (glyph + icon sizing) target primitives.

**Worse: the corpus itself teaches the violation.** bp2#7228 edits `src/components/ui/slider.tsx` **and** `src/styles/airy-theme/overrides.css` — both protected. Any rule extracted from that PR ("the primitive forwards ARIA to its thumb", the `html[data-slider-dragging]` cursor override) instructs an agent to do the thing the repo forbids. Ethan can do this because he also owns the Airy registry; other agents cannot.

**Verdict: `keep-with-exception` — global, hard.**
> Every autofix carries: *skip `src/components/ui/**`, `src/components/airy-blocks/**`, `src/components/lev-assets/**`, `src/styles/airy-theme/**`, `airy-rules/**`.* A hit inside those paths is reported as **"belongs upstream in the Airy registry"**, never edited. Rules sourced from bp2#7228 get an explicit note that their landing site is protected.

---

### F2. `getBoundingClientRect().width` → `offsetWidth` (patterns §6.1)
**Attack:** these are **not equivalent** and the swap silently changes measurements.
- `getBoundingClientRect()` returns fractional, **transform-inclusive** layout; `offsetWidth` returns a **rounded integer** excluding transforms.
- `offsetWidth` does not exist on `SVGElement` — the swap throws `undefined` on any SVG measurement.
- It excludes the scrollbar differently, and returns `0` for `display: contents`.

13 live call sites. The source rule (memo#783) is narrowly correct — *"offsetWidth/Height, not getBoundingClientRect: the pulse scales this subtree, and a transformed rect would get scaled a second time"* — i.e. it applies **only when measuring inside a transformed ancestor**. Generalized, it is a correctness regression.
**Verdict: `delete` as an autofix. Re-add as a flag:** "measuring inside a `transform`ed subtree — consider `offsetWidth`", detected by a `transform`/`scale`/`rotate` class on an ancestor.

---

### F3. interaction A18 — blanket `onOpenAutoFocus={(e) => e.preventDefault()}`
**Attack:** stated as "a `PopoverContent`/`DropdownMenuContent` opened from a text input". Applied to a **modal `Dialog`** it breaks WCAG 2.4.3 / the dialog focus contract — focus stays behind the overlay and keyboard users are stranded outside a modal. Ethan's own evidence is scoped: `bp2-7317` ("the caret stays in the search input"), `memo-668` ("the panel edits the document behind it"). `bp2-nits` is a *suggestion popover over an input*. None is a modal.
**Verdict: `scope-to-non-modal-popover-anchored-to-a-caret-holding-input`.** Never fires on `Dialog`, `AlertDialog`, `Sheet`, or any content with `modal` unset/true. And `onCloseAutoFocus` gets its own gate — suppressing focus *return* is a bigger a11y cost than suppressing focus *entry*.

---

### F4. interaction A5 — auto-adding `role="button" tabIndex={0}` + key handlers to a clickable `div`
**Attack:** three failure modes a grep can't see:
1. The div frequently **already contains** a `<button>`/`<a>` (bp2#6987's card is exactly this shape — a clickable card wrapping real buttons). `role="button"` on an ancestor of interactive content is an ARIA violation and makes the inner controls unreachable in some AT.
2. `Enter`/`Space` handlers added to a container swallow those keys from a nested input.
3. It is the wrong fix. Ethan's own preference is to make the thing a real `<button>` (memo#635: `<div className="cursor-pointer">` → `<button type="button" disabled aria-label=…>`), and to keep connective words *outside* the interactive element (bp2#6987 rejected wrapping the whole phrase).
**Verdict: `downgrade-to-flag`.** Report "clickable non-button — should this be a `<button>`?" and let a human choose. Never synthesize roles.

---

### F5. interaction A7 — "**delete** the now-redundant `aria-label`" after wiring `htmlFor`
**Attack:** the wiring half is right; the deletion half is lossy. A visible label is often shorter or more ambiguous than the intended accessible name (`"Size"` visible vs `aria-label="Card size: M"`). Ethan does both in the same corpus — bp2#7226 deletes the label, bp2#7228 *adds* a richer one (`Card size: ${active.label}`) alongside visible text. Which applies depends on whether the visible text is a complete name. Secondary hazard: the fix injects `useId()`, which is a hook — auto-inserting it into a non-component helper or a `.map()` callback breaks rules-of-hooks and won't be caught until runtime.
**Verdict: `keep-with-exception`** — auto-apply the `htmlFor`/`id` association only; **never auto-delete an existing `aria-label`** (flag it as "possibly redundant"). Skip entirely if the insertion point is not a component body.

---

### F6. interaction A9 — `role="alert"` → `role="status"`
**Attack:** the trigger is *"anything that is not a genuine failure"*, which is a product judgment, not a pattern. 10 live `role="alert"` sites. Getting it wrong in either direction is a real a11y defect: downgrading a genuine error makes it silent; the rule offers grep no way to tell. This is also self-contradictory in the corpus — bp2#6363 **adds** `role="alert"` to the insufficient-credits line while bp2#7225 **removes** it from a dead-end banner.
**Verdict: `downgrade-to-ask`.** Quote both precedents and let the human pick.

---

### F7. interaction A13 — single-select `ToggleGroup` must reject deselect
**Attack:** `if (next) onChange(next)` is correct for a *required setting* (page size, orientation). It is a **bug** for a **filter** toggle group, where clearing the selection is how you say "all" — and for any group whose empty state is meaningful. Both source PRs (bp2#7200, bp2#7343) are export-dialog settings.
**Verdict: `keep-with-exception`.** Fires only when the value has no `null`/`'all'` member in its type and is written straight into a config object. Otherwise flag.

---

### F8. interaction A14 — add `|| !value.trim()` to a submit's `disabled`
**Attack:** behavior change. Breaks any form where empty submit is meaningful (clearing a filter, saving a deliberately-blank field, a search that resets on empty). Also, `.trim()` on a value that is not a string throws.
**Verdict: `keep-with-exception`** — only when the same handler already early-returns on other falsy guards *and* the field is typed `string`. Otherwise `downgrade-to-ask`.

---

### F9. interaction A26 — reset `scrollTop`/`scrollLeft` on item change
**Attack:** correct for a preview pane; wrong for a chat/log pane pinned to the bottom, a virtualized list restoring position, or a master-detail view that deliberately preserves scroll. The rule is grounded in exactly one PR (bp2#7724) about a table preview.
**Verdict: `keep-with-exception`** — only where the effect already exists and only measures. Never insert a new scroll reset into a component with `scrollIntoView`, `scrollHeight`, or a stored offset.

---

### F10. copy §2.7 — `Multi-Family` → `multifamily`
**Attack:** `CLAUDE.md` reserves Title Case for *"CRE taxonomy and controlled loan/request/document/report type values."* Property type **is** CRE taxonomy. One live hit: `VaultLoginPage.tsx:196 details="Multi-Family"` — a displayed property type, i.e. exactly the protected class. Lowercasing it is a copy regression and, if the same string is ever compared to an enum, a functional one. The same list contains `Sub-Type → Subtype`, which is right, so the rule can't be split by heuristic.
**Verdict: `keep-with-exception`** — the hyphenation list applies to **prose only**; every entry that names a property type, loan type, document type, or report type is excluded. `Multi-Family` specifically: `delete` from the list.

---

### F11. copy §2.3 — straight → curly apostrophes/quotes
**Attack:** the highest-collateral copy rule.
- `aria-label` and visible text are **test selectors**. Playwright's `getByLabel`/`getByText` and every snapshot break on `'` → `’`.
- Inside a JSX attribute delimited by `'`, the replacement changes quoting and can produce invalid JSX; inside a `.ts` string it's silent but changes wire payloads if the string is ever sent.
- The provided regex `(can't|won't|…)` cannot distinguish rendered copy from a comment, a test name, or a GraphQL description.
**Verdict: `downgrade-to-ask`** for anything in an attribute; `keep` only for JSX **text nodes** (`>…<`) in `.tsx`, with `*.test.*`, `*.spec.*`, `__snapshots__`, `*.graphql.ts` excluded. Never in `.ts`.

---

### F12. copy §2.4 — `&` → `and`
**Attack:** 9 live hits, and most are *correct as `&`*: `"Notes & attachments"`, `"Structure & fees"`, `"Valuation & income"`, `"Add & edit fields"` are two-noun **section heads**, where `&` is idiomatic and shorter — precisely the density Ethan optimizes for elsewhere. The genuine fixes in the corpus (`Import deals & contacts`, `Manage Intake & Closing Checklists`) are **sentences/actions**, not heads. Canonical finance phrases (`P&L`, `R&D`, `Sources & Uses`) must never be touched.
**Verdict: `keep-with-exception`** — fires only when the string is a sentence, an action label with a verb, or ≥4 words. Two-noun heads and `X&Y` with no spaces are excluded.

---

### F13. patterns §6.1 contains two autofixes that undo each other
**Attack:** *"JS truncation with no `title` attr → add `title={fullValue}`"* (patterns) vs visual **A39** *"`title=` on a truncating element → a real `Tooltip`"*. Run in either order, `/ethanize` fights itself; run twice, it oscillates. `synth/visual.md` C5 documents the conflict but both rules still ship as auto.
**Verdict:** encode the resolution as one rule — **`title` is the fix unless the file already imports `Tooltip` and the element is inside a dense grid, in which case use `Tooltip` + `hideArrow` + `pointer-events-none!`.** Delete the standalone A39 auto-form.

---

## TIER 2 — will corrupt appearance

### F14. visual A5 — the `border-border` deletion regex eats alpha
**Attack:** `\bborder-border\b` matches inside `border-border/70`. **109 live `border-border/N` usages.** Deleting the alpha variant changes the border colour on every one — the opposite of the intent, since `tailwind-4.md:29` explicitly permits a `border-*` colour "when the color or **opacity** intentionally differs from the default."
**Verdict: `keep-with-exception`** — require `border-border` **not followed by `/`**, and exclude arbitrary variants (`[&_td]:border-border`).

### F15. visual A3 — `bg-white` → `bg-background`
**Attack:** 23 live hits, and the ones that matter are deliberate: `color-picker/HueSlider.tsx:108` and `AlphaSlider.tsx:127` ship `bg-white` knobs, and `ui/slider.tsx:102` ships a `bg-white` thumb that Ethan **kept after a reviewer flagged it for theming**. A knob riding a hue ramp must stay white in both themes — that is the point. Same class of exception as the map-overlay carve-out the rule already has, and the same as the memo page (`bg-white` for print fidelity).
**Verdict: `keep-with-exception`** — never inside a colour-picker, a knob/thumb, a print/PDF/export surface, or an overlay on imagery.

### F16. visual A14 — `hover:bg-accent` → `hover:bg-muted` desynchronizes Radix menus
**Attack:** interaction **A22** requires `hover:` and `data-[highlighted]:` to be styled **identically** (`bp2-6549`: "it needs to be identical everywhere or the menu flickers between two highlight styles"). A14 rewrites only the `hover:` half. Applied to a menu, it *creates* the exact bug A22 exists to prevent. Live: ~20 files with `hover:bg-accent`, several in menu/list surfaces. The rule also contradicts the app's own token semantics (`bg-accent` = hover response), which visual.md's C1 concedes.
**Verdict: `keep-with-exception`** — never fires in a file containing `data-[highlighted]`, `data-highlighted`, `CommandItem`, `DropdownMenu`, or `SelectItem`; when it does fire, both halves change together.

### F17. visual A16 — `text-foreground/NN` → `text-muted-foreground`
**Attack:** these are different colours, not a lint. 20 live hits. Loose matching also captures `text-primary-foreground/80`, `text-sidebar-accent-foreground/70`, and `text-card-foreground/60`, none of which have `muted-foreground` as their correct replacement. Over an image/map the alpha is deliberate.
**Verdict: `keep-with-exception`** — exact tokens `text-foreground/N` and `text-sidebar-foreground/N` only; skip files that also match `surface-glass`, `absolute inset-0`, or a map/overlay path. (Direction is right: it's the one rule that *agrees* with `design-system-rules:144`.)

### F18. The alpha-on-semantic-token conflict is bigger than flagged
**Attack:** `airy-rules/design-system-rules.md:144` — *"Do not apply alpha modifiers to semantic color variables, such as `text-foreground/60` or `border-border/50`, unless the user explicitly asks."* But the ruleset's own **replacement strings** are full of them: `bg-destructive/10` and `border-destructive/20` (visual A10), `outline-foreground/20` (visual A22 / interaction), `bg-primary/5 ring-primary/40` (interaction J6), `hover:bg-foreground/5`, `bg-muted/50`, `after:border-border/70`, `focus-visible:ring-ring/50`. Live counts: `bg-muted/N` 346, `bg-primary/N` 104, `border-border/N` 109, `text-muted-foreground/N` 70, `ring-ring/N` 66, `bg-destructive/N` 61. The codebase already ignores the rule at scale — but `/ethanize` **writing new violations** hands a reviewer a legitimate objection to every fix.
**Verdict: `keep-with-exception` (global).** `/ethanize` may **preserve** an existing alpha-on-semantic string; it must **never introduce one** where a plain token or a `*-background` pair exists. Where a replacement needs alpha (A10's `bg-destructive/10`), emit it and cite the precedent in the report so the reviewer sees it was deliberate.

### F19. visual A9 — `z-10` → `z-[var(--z-sticky)]`
**Attack:** `agents/tailwind-4.md:63` — *"Do not add custom z-index classNames to components that already have the correct default z-index baked in."* And bp2#6535 is the counter-precedent: a hover-lift's z-index was pushed **down** to `z-[1]` precisely so it wouldn't outrank page overlays. `z-10` on a locally-isolated stack is correct; the token is for page-level chrome.
**Verdict: `keep-with-exception`** — only on an element that also has `sticky` or `fixed` **and** is not inside `src/components/ui/`. Never fires on `hover:z-*` or on a `z-*` inside an `isolate` container.

### F20. visual A27 — "number/date columns align left"
**Attack:** right-aligning numbers is a near-universal table convention (it makes magnitudes scannable and is why `tabular-nums` exists — a rule the same document adds in A35). The evidence (bp2#6824) removes `text-right` from a **date** column, which is defensible; generalizing it to *numbers* contradicts A35's own purpose.
**Verdict: `scope-to-date-columns`.** Drop the numeric half, or `downgrade-to-ask` for it.

### F21. visual A24 — radius by box size
**Attack:** the detect (`rounded-md` on `size-4`/`size-5`) will fire on circular avatars and brand marks where the sibling class is `rounded-full`, and on any `size-5` icon slot deliberately matched to a `rounded-md` parent. Also a `size-8` inside a `rounded-sm` group should not step *up*.
**Verdict: `keep-with-exception`** — skip if `rounded-full` is present in the same string; skip inside `lev-assets`.

### F22. interaction A25 — hardcoded `h-5` for an `AnimatePresence` swap line
**Attack:** `5` is the line box of one `text-sm` string in one PR. On `text-base` or a two-line label it clips.
**Verdict: `keep-with-exception`** — insert a fixed height matching the rendered line-height, and flag rather than guess when the text size isn't `text-sm`.

---

## TIER 3 — one-offs dressed as patterns (scope them)

| # | Rule | Attack | Verdict |
|---|---|---|---|
| F23 | visual A29 chart constants (`CHART_BAR_RADIUS`, `maxBarSize`, `barCategoryGap="34%"`) | Single PR (bp2#6668), single chart library, single visual language. `22`/`34%` are that chart's numbers. | `scope-to-charts` |
| F24 | visual A21 (`ring-1 ring-inset ring-black/10` tracks) | memo#663 colour-picker only. `ring-black/10` is a literal, and on a dark theme it vanishes. | `scope-to-color-picker` |
| F25 | visual A26 (sticky `thead` inset shadow) | One PR (bp2#6715); the `[&_th]`/`[&_tr]` arbitrary variants are table-shape-specific. | `scope-to-tables` |
| F26 | visual A23 (border as an overlay after the fill) | Correct for swatches/thumbnails; wrong as a general "any bordered `overflow-hidden` wrapper" rewrite — it adds a DOM node to every card. | `scope-to-swatch-thumbnail-avatar` |
| F27 | interaction A11 (`Skeleton` on `bg-muted`) | Requires knowing the **ancestor** background. Grep sees the `<Skeleton />`, not its container. Unresolvable statically. | `downgrade-to-flag` |
| F28 | interaction §3.2 duration ladder | Presented as a system; several rows rest on one PR each (1050ms row move, 640ms image slide, 3000ms beam hint, 1400ms loop). They are reference values, not rules. | `keep` as reference; never autofix a duration |
| F29 | interaction A12 shimmer mechanics, A24 SVG `useId`, motion `pathLength` rules | All from 3 map/AI-illustration PRs. Correct, but they only ever fire on hand-authored SVG/keyframe code. | `scope-to-svg-and-keyframes` |
| F30 | visual A15 "section heads are sentence case" + the acronym map | The paired acronym map (`FAQ NOI DSCR…`) is real and reusable; the `uppercase`-stripping half rests on two PRs in one surface family (Index/FAQ dashboards) and would strip legitimate uppercase (legal, `sr-only` codes). | `scope-to-section-heads`; keep the acronym map globally |
| F31 | interaction A28 sub-bullets (`hover:z-[1]`, toast `id`, `Math.min(dt,64)`) | Each is a single-site fix presented as a general rule. Harmless but they'll fire almost never — cost is report noise, not damage. | `keep`, low priority |

---

## TIER 4 — unfalsifiable / noise generators

| # | Rule | Attack | Verdict |
|---|---|---|---|
| F32 | **interaction A2** — "any `hover:` state with no focus/coarse mirror" | As written it fires on **420** `hover:bg-*` occurrences, nearly all on real `<button>`s where the focus ring already provides the mirror. Narrowed to hover-*reveal* (`opacity-0` + `group-hover:*:opacity-100`) it fires on **95 files, of which 82 already have a mirror — 13 real hits.** That is the rule; the broad form is a noise generator. | `keep-with-exception` — **reveal only**, never hover *styling* |
| F33 | patterns §6.1 "`overflow-x-auto` on a static/decorative row → `overflow-hidden`" | "Static/decorative" is not detectable, and guessing wrong removes a real scroll affordance on a narrow viewport. | `delete` |
| F34 | patterns §6.1 "A row skeleton whose geometry differs from the row" | "Differs" is unmeasurable without rendering both. | `downgrade-to-flag` (report the file pair; don't judge) |
| F35 | patterns §6.1 "An always-mounted container of optional chrome → compute `has*` and omit" | Matches most conditional-render components in the app. | `downgrade-to-ask` |
| F36 | patterns §6.1 / visual A40 "a component prop with no remaining caller → delete" | Requires whole-repo reference analysis; and exported-component props are legitimately uncalled inside the repo. Deleting one is an API break. | `downgrade-to-flag` |
| F37 | patterns §6.1 "`truncate` on an element whose flex ancestors lack `min-w-0`" | The *detection* is sound and this is the corpus's most-repeated mechanical rule — but "every level" requires walking JSX ancestors, which grep can't do. Implemented naively it adds `min-w-0` to the wrong node and changes layout. | `keep-with-exception` — only when the direct parent is a `flex`/`grid` in the same file and expression |
| F38 | patterns §6.1 "Disabled options sorted by relevance → disabled state as primary sort key" | One PR, and it's a data-ordering change, not a style fix. | `downgrade-to-ask` |
| F39 | interaction A22's second clause "delete the `hover:` class" | Only correct when an `isActive` concept exists. If it doesn't, the fix removes all hover feedback from the row. | `keep-with-exception` — require an existing active-index/`isSelected` in scope |
| F40 | visual A2 exception (`text-[11px]` is fine) vs `agents/tailwind-4.md:129,131` | The repo rule is absolute: *"Minimum font size is 12px… never custom sizes below"* and *"Never use arbitrary `text-[Npx]` values."* Live bp2 has **69× `text-[10px]`, 37× `text-[11px]`**, plus `text-[5px]`–`text-[9px]`. So J9's "leave `text-[11px]`" is a **memo-only** carve-out that, read in bp2, tells an agent to preserve a documented violation. | `scope-to-memo` explicitly, and say so at the point of use, not only in a footnote |

---

## What survives untouched

These I tried to break and could not. They are exact, mechanical, single-valued, and I found zero false positives in the live tree:

- **visual A1** (`w-N h-N` → `size-N`) — **0 false positives** across the repo; no `w-full h-full` pairs to mangle.
- **visual A10** (`error-*` → `destructive`) — legacy token, one-way migration, no live counter-use.
- **visual A11/A12/A13** (foreground token is ink not white; never a chart token on a semantic surface) — these are token-definition invariants, checkable in CSS.
- **visual A35** (`tabular-nums` on stacked numerics) — additive, no behavior change.
- **visual A36/A38** (inline SVG → icon set; file glyphs → `FileTypeIcon`) — additive dedup, though the *edit* is a refactor, so run as `flag` in a fix run.
- **copy 2.2** (`...` → `…`) with its stated exclusions, **2.5** (pluralize counts), **2.9** (trim before validating), **2.10** (test name describes old behavior).
- **interaction A1** (`transition-all`) — outside protected paths, and with the ruleset's own bp2#6548 exception already stated.
- **interaction A3** (`opacity-0` reveal with no `pointer-events-none`), **A16** (disabled tooltip trigger wrapper), **A17** (`asChild` on `TabsTrigger`), **A23** (`onDragLeave` `relatedTarget` guard), **A24** (SVG `useId`), **A27** (sort before slice) — all narrow, mechanical, and correct.

---

## Closing verdict — how much do I trust unattended?

Of the **~116** rules currently tagged autofixable across all five domains:

| | count | share |
|---|---|---|
| **Trust unattended, as written today** | **~22** | **19%** |
| Trust once the stated exception is coded (mostly the protected-path exclusion + a regex tightening) | ~48 | 41% |
| Must become `ask`/`flag` — behavior, a11y, or judgment | ~29 | 25% |
| Must be scoped to one surface before they're safe | ~11 | 9% |
| Delete | ~6 | 5% |

**The honest number is 19% today, ~60% after one pass of remediation.** Two changes buy most of that jump:

1. **One global protected-path exclusion** (F1) unblocks roughly a third of the visual and interaction autofixes on its own. Without it, `/ethanize`'s very first run on this repo edits `ui/button.tsx` and gets the PR rejected.
2. **Regex tightening on four rules** — F14 (`border-border` vs `border-border/N`), F17 (exact foreground tokens), F32 (reveal, not styling), F16 (skip Radix-highlight files) — converts four noise generators into four precise linters.

The deeper structural point: the extraction inverted the corpus's own gradient. `patterns.md` measured it honestly — **`overflow` is 35% autofixable, `component-choice` 9%, `hierarchy` 10%** — yet the synthesis promoted judgment calls into the autofix tier anyway, because a rule with a quotable `before:`/`after:` *looks* mechanical. **A verbatim before/after pair is evidence that a change happened once, not that it should happen always.** The rules that survived my attack are the ones where the `after:` is the *only* possible correct value; the ones that failed are the ones where the `after:` was merely the value Ethan picked that day.

Last: `/ethanize` should never run a fix pass without `git status` clean and a diff shown before commit — several `keep` rules above (A36, A38) are refactors, and the ruleset has no notion of blast radius per rule. Add one: `mechanical` (edit silently), `refactor` (edit, show diff), `flag` (never edit).
