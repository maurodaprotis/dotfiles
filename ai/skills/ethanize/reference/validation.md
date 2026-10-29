# Validating the ethanize ruleset against real PRs

## Method, and a methodological problem you should know about first

The test: take a `feat:` PR by a **non-Ethan** author, treat its diff as the input, and ask whether the mined rules would have flagged the things Ethan actually changed in his follow-up polish PR days later.

**Every Ethan PR in `prs.txt` was mined into `findings/`.** So there is no true holdout. Every case below is therefore scored **leave-one-out**: for case N, the findings file for Ethan's own follow-up PR is excluded from the ruleset, and only the other ~80 files count. Where a rule that *would* have hit lives only in the held-out file, it is scored a MISS and labeled `[held out]`. This is the honest version; scoring with the target's own file included would put every case near 90% and mean nothing.

Second constraint: Ethan's polish PRs routinely touch files the original never did. Scoring is restricted to the **intersection of changed files**. Out-of-scope changes are listed separately, because they say something useful about where the ruleset is strong.

**Overall: 10 of 33 in-scope changes flagged — 30%.**

---

## Case 1 — bp2#6806 → bp2#6824

- **Original:** #6806 `feat(LEV-1537): pipeline table row quick actions on hover` — @andresdicamil, merged 2026-06-26
- **Ethan's follow-up:** #6824 `fix(DES-326): polish table action overlays` — merged 2026-06-30 (4 days)
- **Held out:** `bp2-6824.md`
- **In-scope files (6):** `AllDealsTable.tsx`, `PipelineRowQuickActions.tsx`, `PipelineTableCellSkeleton.tsx`, `buildPipelineTableColumns.tsx`, `pipelineTableColumnLayout.ts`, `TableCells.tsx`
- **Hit rate: 1.5 / 8 ≈ 19%** — the worst of the four, and the most instructive.

| # | What Ethan changed | Flagged? | Which rule / why not |
|---|---|---|---|
| 1 | `actions: 'w-[9.5rem] min-w-[9.5rem]'` / `152` → `w-0 min-w-0` / `0`; actions become a zero-width sticky overlay | **MISS** | No rule says hover-only row actions must not reserve column width. Worse — see noise list |
| 2 | `getPipelineTableMinWidth(['select', ...viewColumns, 'actions'])` → drop `'actions'` | **MISS** | Consequence of #1 |
| 3 | Actions-column skeleton (4 × `size-7` chips) → `return null` | **MISS** `[held out]` | Rule exists only in `bp2-6824.md` |
| 4 | Reveal conditions: adds `group-focus-within/table-row:`, `group-has-[[data-state=open]]/table-row:`, `group-data-[selected]/table-row:`, `pointer-coarse:`, and `pointer-events-none → auto` | **HIT** | `bp2-7724`: "Row action reveals key off the shared `group/table-row` scope and go `pointer-events-none` → `auto`, not a bare `group-hover`." + `bp2-6548`: "…appears on hover, focus-within, or while its menu is open — and stays visible on touch" |
| 5 | Gradient scrim behind the overlay (`before:bg-gradient-to-r … via-background/95`, `color-mix` swap on hover/selected) | **MISS** | Absent |
| 6 | `'border-beam-hover gradient-ai-hover'` → `'border-beam-hover [border-color:transparent] hover:bg-transparent dark:hover:bg-transparent'` | **MISS** | Absent — two hover treatments fighting is invisible in a diff |
| 7 | `usesMiddleAlignment ? 'align-middle' : 'align-top'` → `align-middle` everywhere | **MISS** | Absent |
| 8 | `overlay` prop plumbed through `ActionsCell`/`TableCells` | **½ HIT** | Only as the mechanical carrier of #4 |

**Out of scope, but the ruleset would have caught these** (Ethan reached into files #6806 never touched): `aria-label="Call recipient"` on the *Add note* button → `"Add note"` (`bp2-7513` a11y rule for icon-only triggers); `'Add Recipients'` → `'Add recipients'` (`bp2-6257`); missing `Tooltip` on icon-only actions (`memo-613`); `humanReadable` → `humanReadableSentenceCase` (`bp2-6257`). **The ruleset is far stronger on copy and a11y than on layout mechanics.**

---

## Case 2 — bp2#6042 → bp2#6070

- **Original:** #6042 `feat: update the chat scope chips and add sources` — @ksliao, merged 2026-04-30
- **Ethan's follow-up:** #6070 `KTN-5646 Polish chat input attachment context UI` — merged 2026-05-03 (3 days)
- **Held out:** `bp2-6070.md`
- **In-scope files (2):** `ChatInput.tsx`, `VaultSearchContent.tsx`
- **Hit rate: 3 / 7 ≈ 43%** — the best of the four.

| # | What Ethan changed | Flagged? | Which rule / why not |
|---|---|---|---|
| 1 | Chip remove button `className="group ml-auto w-fit p-1 hover:bg-transparent"` + `size="icon"` + `<X size={12}>` → `ml-0.5 -mr-1.5 size-[18px] rounded-full p-0` + `size="icon-xs"` | **HIT** | `bp2-7513`: icon-only buttons take a square `icon-*` size, not a text size with hand-tuned padding; `bp2-6183` / `memo-798` use `icon-xs` for chip-scale controls |
| 2 | Chips gain `border-border bg-background` | **MISS** `[held out]` | |
| 3 | `max-w-[120px] truncate` → `middleTruncateFileName(…, {maxLength: 18, prefixLength: 7})`; dropdown at 34/16 | **MISS** | No middle-truncation rule outside the held-out file. Worse — see noise list |
| 4 | `title={attachment.displayName}` / `title={doc.fileName}` added so the full name is recoverable | **WEAK HIT** | No explicit "truncated text needs a `title`" rule; it's implied by several two-line-row rules but would not reliably fire. Counted as ½ |
| 5 | Whole `aria-live="polite"` chip row now gated on `hasContextChips` instead of always rendering an empty `p-2` band | **HIT** | `bp2-6987`: "`aria-live` status regions get `empty:hidden` so they don't reserve space when silent" — near-exact, and the original literally is an `aria-live` region |
| 6 | Placeholder/textarea vertical rhythm: `top-4` → `top-2` + `leading-6`; `pt-4` → `pt-2` | **MISS** | Needs the rendered composer |
| 7 | `AttachmentChips` takes props instead of calling `useChatFeatures()` itself | **MISS** | Enabler for #5, not a design rule |

---

## Case 3 — bp2#6477 → bp2#6520

- **Original:** #6477 `feat(deal-data): add row picker with temporal period support` — @maurodaprotis, merged 2026-06-03
- **Ethan's follow-up:** #6520 `fix(deal-data): polish add row picker targets` — merged 2026-06-04 (**next day**)
- **Held out:** `bp2-6520.md`
- **Hit rate: 2.5 / 8 ≈ 31%**

| # | What Ethan changed | Flagged? | Which rule / why not |
|---|---|---|---|
| 1 | Add-row trigger `text-sm font-medium text-primary hover:text-primary/80` → `text-xs font-normal text-muted-foreground hover:text-foreground`; `Plus` `size-4` → `size-3.5` | **HIT** | `bp2-7724`: "Give a ghost/secondary panel button explicit compact geometry: `h-7`, small horizontal padding, `text-[11px] text-muted-foreground`, `size-3.5` icon" |
| 2 | Current-page target label → `'This page'` with `icon: null` | **MISS** `[held out]` | Nothing generic covers "don't repeat the surface's own name back at the user" |
| 3 | Off-page targets → `Section \| Entity`, entity in `text-muted-foreground/80` | **MISS** `[held out]` | |
| 4 | `TargetShortcut` duplicated in `AddMetricRow.tsx` and `AddMetricRowValueForm.tsx` → extracted `AddMetricRowTargetShortcut.tsx` | **HIT** | `memo-783`: "If two identical definitions exist, delete one — duplication is how one copy ends up with a bug the other doesn't"; `memo-635` / `bp2-6548` extraction rules |
| 5 | Label normalization: `.replace(/\s+/g, ' ').trim()`, entity label preferred over section, `formatDisplayName` fallback chain | **MISS** | Absent |
| 6 | Icon precedence `entityNode?.icon ?? targetNode.icon` → `targetNode.icon ?? categoryNode?.icon ?? entityNode?.icon` | **MISS** | Absent |
| 7 | Disabled options sort last (`if (a.disabled !== b.disabled) return a.disabled ? 1 : -1`) | **MISS** | No ordering rule anywhere in the corpus |
| 8 | **The headline fix:** `<TableCell className="w-6 p-0" />` + `<TableCell className="py-0">` → one `colSpan={2}` cell, so the click target spans the row; portal mounts only when `open` | **NEAR-MISS** | `bp2-7317` is conceptually identical ("the input is a 276×20 box inside a 320×44 pill… 61% of the target, all dead") and `bp2-6548` has `after:-inset-1` hit-target expansion — but neither would fire on a `w-6 p-0` sibling cell without rendering it. Counted as ½ |

---

## Case 4 — bp2#7522 + #7545 → bp2#7558

- **Originals:** #7522 `feat: add FAQ section to the Deal Index` (Aug 12) and #7545 `feat: add generate FAQ modal` (Aug 12) — @maurodaprotis
- **Ethan's follow-up:** #7558 `MEMO-2445 | feat: polish the deal FAQ surfaces` — merged 2026-08-13 (**next day**)
- **Held out:** `bp2-7558.md`
- **Hit rate: 3 / 10 = 30%**

| # | What Ethan changed | Flagged? | Which rule / why not |
|---|---|---|---|
| 1 | **Deleted the review-dialog step.** Generated pairs write straight to the deal + a toast (`Added 6 questions to the FAQ` / `Replaced the FAQ with 6 questions`). "The run is the confirmation, and every pair stays editable in the table afterwards" | **MISS** | The single biggest change in the PR, and a pure product-flow judgment. Nothing in the corpus approaches it |
| 2 | Cycling status copy during the run — `'Reading the deal…'` → `'Polishing the wording…'`, 6 messages at `MESSAGE_INTERVAL_MS = 4000`, `AnimatePresence mode="wait"` on a fixed `h-5` line | **MISS** `[held out]` | `memo-783`'s "never a frozen waiting state" is about a *canvas that stops animating*, not a static text line. See gap list — this one is closable |
| 3 | `LoadingDots` on submit → `Loader2 animate-spin`; `Sparkles` + plain `Button` → `LevAIActionButton`; `MorphingLev` with `animate-morphing-rotate` | **HIT** | `bp2-7303` / `copy-review-skill`: "AI/agent in-progress states use `MorphingLevIcon`/`MorphingLev` with `animate-morphing-rotate`, never the generic `Loading` spinner." Fires directly on `{isGenerating ? <LoadingDots /> : <LevAI size={14} />}` |
| 4 | `RadioGroup` + two `RadioGroupItem`+`Label` rows → two selectable cards with icon/title/description, `aria-pressed`, `Check` badge | **HIT (direction only)** | `bp2-6016`: "For a short single-select list inside a form, use an inline chip row, not a stack of bordered radio cards." Correctly flags the `RadioGroup`; **prescribes the wrong replacement** (chips, not cards) |
| 5 | Always-visible `Label` + `Textarea` and `Label` + file input → collapsible `OptionalSection` rows (title + description + `Add`/`Remove` action) | **MISS** | Absent |
| 6 | Placeholders: `"What do you want answered?"` → `"Add a question about this deal…"`; `"Leave blank to answer later"` → `"Optional. Leave blank to answer later…"`; instructions placeholder rewritten to end in `…` | **HIT** | `bp2-nits`: "Placeholders describe the concrete thing to type, end in an ellipsis character (`…`), and say 'Optional.' explicitly when a field can be skipped." **The single cleanest prediction in the whole validation** — it fires on the literal strings in the original diff and names all three fixes |
| 7 | Empty state: two peer buttons → full-width primary + muted `or` + ghost secondary | **MISS** | Needs the rendered empty state |
| 8 | Height-animated dialog body; `ScrollList` with reserved-transparent edge borders gated on the measured cap | **MISS** | Absent |
| 9 | `h-px` table-cell fill trick + `[&>div]:h-full` so the editor's hover box covers the whole cell | **MISS** | Invisible without rendering — the bug is "a box that stops at its last line reads as a stray input" |
| 10 | `aria-describedby={undefined}` after dropping `DialogDescription` | **MISS** | Absent |

---

# The gap list

What the ruleset structurally cannot catch, ranked by how much of the miss volume each accounts for.

### G1. Layout mechanics that only exist once rendered — **~40% of all misses, and mostly unclosable**
Misses: 1.5, 1.7, 2.6, 3.8, 4.7, 4.8, 4.9. Every one is a fact about pixels, not about source text. `<TableCell className="w-6 p-0" />` looks fine in a diff; it is a dead 24px gutter on screen. `top-4` vs `top-2` on a placeholder is invisible until the caret sits next to it. `h-px` + `[&>div]:h-full` is a CSS trick you reach for only after seeing a hover box stop mid-cell.

**Closable portion:** a small family of *named-pathology* rules, each keyed to a source pattern that reliably predicts a rendered failure:
- "A clickable row must not have a sibling `TableCell` with `p-0` and a fixed sub-2rem width — merge it with `colSpan` so the whole row is the target." (from case 3)
- "A hover/focus box inside a table cell needs `h-px` on the cell and `h-full` down through every wrapper, or it stops at the content's last line."
- "A field whose control is smaller than its visually clickable container must hand focus down on `mousedown` from the dead area." (already exists as `bp2-7317`; it just needs a *source-pattern trigger* rather than a prose description)

The rest — vertical rhythm, animated heights, edge borders — needs a screenshot. **A skill that reads diffs will never get these. Say so up front rather than pretending.**

### G2. The rules describe the destination, not the trigger — **the biggest fixable gap**
Case 4 #2 is the clearest example. `memo-783` says *"a generative waiting state must keep the user's content on screen and animate it continuously — never a decorative canvas that stops."* That is written as a fix for one specific `PixelCard`. Generalized to its trigger — **"any request that can exceed ~30s must have a status indicator whose *content* changes over time, not just a spinner or one fixed line"** — it fires cleanly on #7545's `<p className="text-sm text-muted-foreground">` inside `{isGenerating ? … }`.

Same shape elsewhere:
- Case 1 #1 has no rule, but the *principle* is in the corpus as `bp2-7724`'s overlay-actions treatment. It was recorded as "here is what the class string became," not as **"a column that only ever holds hover-revealed controls must not reserve width — make it `w-0 min-w-0` sticky with a scrim."**
- Case 2 #3: several rules bless `truncate` + `min-w-0`; none says **"a filename is not prose — truncate it in the middle so the extension survives, and carry the full value in `title`."**

**Every rule in `findings/` should be re-read once with the question "what pattern in someone else's diff makes this fire?" and given an explicit trigger clause.** That single pass is worth more than any new mining.

### G3. Product-flow judgments — **unclosable, and should be declared out of scope**
Case 4 #1 (delete the review step; the run is the confirmation), case 3 #2 (`'This page'`), case 3 #7 (disabled sort last). These are decisions about what the feature *is*. No amount of diff-reading produces them. The skill should not pretend to; a rule that tried would be pure noise.

### G4. Where the corpus is thin
`colSpan` appears in zero rules. Sort/ordering appears in zero rules. Focus/height/measurement mechanics appear only as one-off implementation notes inside PR-specific findings, never as a rule. These are real coverage holes, not structural limits.

---

# The noise list

Rules that fire on the original diffs where Ethan changed **nothing**. These matter as much as the hits — a skill at 30% recall and high precision is usable; at 30% recall and low precision it gets turned off.

### N1. Inverted rules — the ruleset would have *blessed* what Ethan deleted. Worst category.

| Rule | Fires on | Ethan actually did |
|---|---|---|
| "A skeleton mirrors the real layout's shape, not a generic block stack" (`bp2-6474`, `bp2-6530`) | #6806's new 4 × `size-7` chip skeleton for the actions column — a textbook application | **Deleted it entirely** (`return null`) |
| "Constrain a table column that holds unbounded text to a fixed width… so it can't push the actions column off-screen" (`bp2-6072`) | #6806's `actions: 'w-[9.5rem] min-w-[9.5rem]'` — presupposes a fixed-width actions column | **Zeroed it to `w-0 min-w-0`** and made actions an overlay |
| "Stack two-line row content with `grid gap-0.5` and `min-w-0 flex-1`, truncating each line independently" (`bp2-6399`) | #6042's `max-w-[120px] truncate` on filenames | **Replaced end-truncation with middle-truncation** |

Three of the four cases contain a rule that actively endorses the thing being polished away. This is the sharpest signal in the validation: **rules mined from a fix are stated as the fix, so they generalize backwards onto contexts where the opposite is right.** Each needs a scope clause ("…for prose; filenames truncate in the middle", "…for content columns; a hover-actions column reserves no width").

### N2. Grounded false positives — rule fires, Ethan demonstrably declined

- **Sentence-case (`bp2-6257`) on #6806's agent-action labels.** The original added `label: 'Compare Terms'`, `label: 'Market Comps'`, `label: 'Find Similar Properties'`. The rule fires on all three. Ethan's #6824 touched *neither* — and **all three are still Title Case in `dealOverviewActions.ts` on `main` today, ~2 months later**, even though the same PR *did* fix `'Add Recipients'` → `'Add recipients'` two files over. The copy rule as written is stricter than Ethan is in practice. Either these are a deliberate exception (agent-launcher labels as named actions) or he simply doesn't sweep past the file he's in — `skills/airy-skills/ux-copy-review/SKILL.md` says exactly that: *"Keep changes scoped to the changed surface."* **The skill must inherit that scoping or it will nag about every string in the blast radius.**
- **"Never leave a destructive action as a bare one-click hover button… put it in an ellipsis menu" (`bp2-7513`)** fires on #6806's row of four bare hover icon buttons. Ethan kept all four as bare buttons and only changed how they reveal. The rule is real but card-specific; applied to table rows it is wrong.
- **`after:absolute after:-inset-1` hit-target expansion (`bp2-6548`)** fires on every `size-7`/`h-8` control in #6806. Ethan added none.
- **"Strip decorative icons from table headers / drop per-row decorative badge icons" (`bp2-7724`)** would flag #6806's per-action `HugeiconsIcon`. Those icons *are* the control, not decoration. A mechanical check cannot tell the difference.
- **"No terminal period on labels" (`bp2-nits`)** fires on #7545's `placeholder="Optional. e.g. Focus on loan terms…"`. Ethan kept the period-led `Optional.` construction — his own placeholder rule *requires* it. Two rules in the corpus contradict each other here.

### N3. No-ops that read as findings
`memo-619`'s "repeat `max-w-*` at the `sm:` breakpoint" fires-and-passes on both FAQ dialogs (`sm:max-w-xl`, `sm:max-w-2xl` already correct). Harmless, but a check that reports "verified" on every dialog is volume without signal.

---

# What this implies for the skill

1. **State the recall honestly in the skill's own description.** ~30% of a polish pass, concentrated in copy, a11y, loading-state choice, and reveal-state class strings. It is a first pass, not a substitute for Ethan.
2. **Fix precision before chasing recall.** N1 is more damaging than any miss: a reviewer that tells you to add the skeleton Ethan would delete is worse than one that stays quiet. Every rule needs a scope clause naming where it does *not* apply.
3. **Re-write rules as triggers.** G2 is the cheapest large win available and needs no new PR mining — just a pass over `findings/` adding "fires when the diff contains X."
4. **Inherit `SKILL.md`'s scoping.** Only flag lines the PR added or modified. `'Compare Terms'` proves Ethan himself works this way.
5. **Declare G1 and G3 out of scope in writing**, and make the skill's output say so — "checked: copy, a11y, state classes, component choice; not checked: rendered layout, spacing rhythm, product flow." A tool honest about its blind spots gets trusted with the part it does well.
