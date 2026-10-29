# Validation 2 — did the trigger-clause pass buy anything?

Same four cases, same leave-one-out method, same intersection-of-changed-files denominators as `validation.md`. The only change is that the ruleset now includes `triggers-visual-patterns.md` and `triggers-interaction-flows-copy.md`.

## Headline

| | in-scope hits | rate |
|---|---|---|
| Validation 1, as reported | 10 / 33 | 30% |
| **Corrected baseline** (same pre-trigger rules, scoring error fixed) | **11 / 33** | **33%** |
| **Post-trigger, strict** | **11 / 33** | **33%** |
| Post-trigger, lenient | 12 / 33 | 36% |
| Noise (raw FP count) | 8 → **7** | — |
| Noise (inversions — the dangerous kind) | 3 → **0** | — |

**The recall number did not move.** Strictly scored, the trigger pass converted zero misses. I said in `validation.md` that this pass was "worth more than any new mining" and I was wrong about *why* — it bought precision and reliability, not coverage. Details below, including two corrections to my own first pass that I have to disclose before the delta means anything.

---

## Two corrections to validation 1

### C1 — I scored validation 1 against the wrong artifact
Validation 1 scored against `findings/` (the raw per-PR extractions). It should have scored against `synth/*.md` (the synthesized rulesets), which is what the skill will actually carry. `patterns.md` §P15/§P16 already contained a triggered filename rule — *"`truncate` on a filename — always wrong"*, sourced from **bp2#7711**, plus *"put the full string in a `title` whenever you truncate in JS."* Both are outside my four cases and both fire on case 2.

Case 2 #3 (middle-truncation) was scored MISS and should have been HIT. Case 2 #4 (`title=`) was scored ½ and should have been 1. **Case 2's baseline is 4/7, not 3/7.** The corrected baseline is therefore **11/33 = 33%**, and that — not 30% — is what the trigger pass has to beat.

### C2 — Rules I mined *from the test cases* cannot score on them
The trigger brief asked me to close the G4 holes by mining `bp2-6715, bp2-6824, bp2-6520, bp2-7317` directly. Three of those are validation cases. So:

| New rule | Mined from | Held out for |
|---|---|---|
| D1 (hover-actions column reserves no width) | bp2#**6824** | case 1 |
| D2 (dead sibling cell → `colSpan`) | bp2#**6520** | case 3 |
| D3 (disabled sorts last) | bp2#**6520** | case 3 |
| D4 (filename middle-truncation) | bp2#**6070** | case 2 |
| D5, D10, D11 (cell fill, height tween, reserved edge) | bp2#**7558** | case 4 |
| §1.5 chips-vs-cards reconciliation | authored *from case 4's answer* | case 4 |
| F51–F53 (long-run status) | memo#783, but authored after seeing case 4 | flagged, scored both ways |

D1 alone would "convert" four of case 1's eight misses. Counting it would put case 1 at 5.5/8 (69%) and the total at 15/33 (45%). **That number is the model scoring itself on its own training data and I am not reporting it as a result.** Legitimate rules mined from non-case PRs — D6/D8 (bp2#6890, bp2#7317), D9 (memo#783) — are counted normally; none of them happen to fire on these four inputs.

---

## 1. Per-case, post-trigger

### Case 1 — bp2#6806 → bp2#6824 · **1.5 / 8 (19%) — unchanged**
- **#4 reveal triad** — still the only hit. `patterns.md` §6.1 already carried the trigger (*"A row-action reveal using bare `group-hover` + `opacity-0` → shared `group/table-row` scope, `pointer-events-none` → `auto`"*). The trigger pass didn't improve it.
- **#1/#2/#3/#5** — D1 covers all four; **held out**. Still MISS.
- **#7 (`align-middle` everywhere)** — I expected V27's rewritten trigger (*"a ternary that picks alignment per column is the smell"*) to convert this. **It doesn't:** `rg -E '^[-+].*(align-top|usesMiddleAlignment)' o1.diff` returns **0 hits**. #6806 never touched alignment; Ethan fixed pre-existing code the original didn't include. Correctly out of scope, correctly a MISS.
- **#6, #8** — still MISS.

### Case 2 — bp2#6042 → bp2#6070 · **4 / 7 (57%) — unchanged from corrected baseline**
- **#1** chip button sizing — HIT (unchanged).
- **#3** middle-truncation — HIT via **P15** (bp2#7711). This is a **correction**, not a conversion. D4 restates it with a `rg`-able trigger and an inversion guard, but P15 already covered it.
- **#4** `title=` — HIT via **P16** (bp2#7711): *"put the full string in a `title` whenever you truncate in JS."* Also a correction.
- **#5** empty `aria-live` row — HIT (unchanged).
- **#2, #6, #7** — still MISS.

### Case 3 — bp2#6477 → bp2#6520 · **2.5 / 8 (31%) — unchanged**
- **#1** demote the add-row trigger, **#4** extract the duplicated shortcut — both still HIT.
- **#8** `colSpan` — D2 covers it; **held out**. Stays a NEAR-MISS at ½.
- **#7** disabled-sorts-last — D3 covers it; **held out**. Still MISS.
- **#2/#3/#5/#6** — all now explicitly labelled `out-of-scope` (G3) in the triggers file. Correct classification; still MISS.

### Case 4 — bp2#7522/#7545 → bp2#7558 · **3 / 10 (30%) strict · 4 / 10 lenient**
- **#3** MorphingLev, **#6** placeholders — still HIT. F71–F78 Trigger B and C-J10 make #6 more *reliably* fireable (see §5), but it was already a hit.
- **#2** cycling status — **F51–F53** fires: *"any request that can exceed ~30s whose waiting state is a spinner or a single fixed line of text."* #7545's pending branch is exactly `{isGenerating ? (<div…><MorphingLev…/><p className="text-sm text-muted-foreground">…</p></div>) : …}`. Substance comes from memo#783 (not a case), but I wrote the generalization after reading case 4's answer. **Scored MISS strict, HIT lenient.**
- **#4** RadioGroup — still **direction-only**, per your constraint. §1.5's new reconciliation ("values get chips, outcomes get cards") would upgrade it to a full hit, but I authored that reconciliation *from this exact conflict*. Held out.
- **#1, #5, #7, #8, #9, #10** — still MISS.

---

## 2. Which misses the triggers converted, and what style of trigger did it

**Strictly: none.** Honest accounting of what would have converted, had the rule come from outside the test set — this is still the useful signal about *trigger style*:

| Would-be conversion | Trigger style that does it | Transferable lesson |
|---|---|---|
| Case 1 #1/#2/#3/#5 (D1) | **Named source-shape in a specific file kind** — `rg 'actions: .w-\[' in *ColumnLayout.ts` + `'actions'` inside a min-width array | The highest-yield style by far: one trigger, four changes. Works because the anti-pattern has a **canonical spelling** in this codebase |
| Case 4 #2 (F51–F53) | **Trigger on the *shape of the wait*, not on the component that was fixed** — "a >30s request whose status content is constant" | The G2 rewrite done properly. The old rule named a `PixelCard`; the new one names a *class of situation*. This is the style to copy |
| Case 3 #8 (D2) | **Self-closing element with no children** — `<TableCell[^>]*p-0[^>]*/>` | Structural-absence triggers ("an element that renders nothing") are cheap and precise |
| Case 3 #7 (D3) | **Comparator-clause ordering** — `.sort((a,b)` in a file with a `disabled` field | Works on *logic* shape, not markup. Rare in this corpus and worth more of |

The pattern across all four: **triggers that name a source shape convert; triggers that name a rendered outcome do not.** Every trigger I wrote as `read-the-component — <question>` behaves exactly like the `**Detect:** read the component` it replaced.

---

## 3. Which misses survived, and are they reachable

22 of 33 in-scope changes still missed. Reclassified:

| Class | Count | Examples | Reachable? |
|---|---|---|---|
| **G1 `needs-rendering`** | 8 | case 1 #5 scrim appearance, #6 two hover treatments fighting; case 2 #6 vertical rhythm; case 4 #7 button layout, #8 animated list height, #9 hover box stopping short | **No.** Correctly labelled in the triggers file |
| **G3 `out-of-scope`** | 6 | case 3 #2 `'This page'`, #3 label composition, #5 fallback chain, #6 icon precedence; case 4 #1 delete-the-review-step, #5 collapsible optional sections | **No.** Correctly labelled |
| **Held out by C2** (rule exists, contaminated) | 7 | case 1 #1/#2/#3/#5, case 3 #7/#8, case 4 #2 | **Already written.** Would need a fresh test set to score |
| **Still just missing a rule** | 1 | case 4 #10 (`aria-describedby={undefined}` after removing `DialogDescription`) | **Yes**, trivially — a Radix-correctness lint |

**This is the real result of the pass:** the residual is now almost entirely *classified* rather than unexplained. Before, 22 misses were an undifferentiated pile. Now 14 are provably out of reach, 7 are covered by rules I can't fairly score, and exactly 1 is a genuine coverage hole. That is worth something even though the percentage didn't move.

---

## 4. New false positives

Re-ran the noise check against the same four original diffs.

### Suppressed — 5 of 8

| Old FP | Fixed by |
|---|---|
| **INV** "skeleton mirrors the real layout" blessing #6806's 4-chip actions skeleton | D1's inversion guard scopes it to content columns |
| **INV** bp2-6072's fixed-width actions column blessing `w-[9.5rem]` | V61's inversion guard + D1 |
| **INV** "truncate each line independently" blessing `max-w-[120px] truncate` on filenames | D4's inversion guard |
| **FP** "destructive hover button → ellipsis menu" on #6806's four bare icon buttons | V56's guard: *"restrict the trigger to components not inside a `<TableRow>`/`<TableCell>`"* — verified: `size="icon"` matches 3× on #6806 and the guard suppresses all three |
| **FP** `after:-inset-1` hit-target expansion on every `size-7` | The other file **deletes F104** outright: *"the measurement ritual is not a rule"* |

**All three inversions are closed.** That is the most valuable thing in this pass — an inversion tells you to add exactly what he would delete, which is worse than saying nothing.

*(Caveat: these guards were written knowing the answers, same as C2. Unlike recall, a suppressed FP is directly observable on the diff, so I count them — but they are fitted and should be re-tested on a fresh case.)*

### Surviving — 3 of 8
- **Sentence-case on `'Compare Terms'` / `'Market Comps'` / `'Find Similar Properties'`** (#6806). Still fires; still Title Case on `main` today. No scope clause was added for controlled action-launcher labels. *(Copy is the other domain — flagging, not fixing.)*
- **"Strip decorative icons from headers"** would still flag #6806's per-action `HugeiconsIcon`. Nothing distinguishes a decorative glyph from an action's own glyph.
- **Terminal-period conflict:** C-J2 (no terminal period on labels) vs F71–F78 (*"say `Optional.` when skippable"*). Both fire on #7545's `placeholder="Optional. e.g. Focus on loan terms…"`. Neither file reconciles them — and now the conflict spans **two** files instead of one, which is marginally worse.

### New — 4, measured on the originals

| New trigger | Fires on originals | Ethan acted on | Verdict |
|---|---|---|---|
| **V69** "any new numeric/colour literal → name your source" | **16** hits (12 on #6477: `[10px]`×2, `[180px]`×2, `[280px]`×8; 4 on #6042) | **0** | **The single largest new noise source.** It will fire on essentially every diff. It is a PR-description note, not a code finding — must not be emitted as a finding |
| **V31** "do not ghost a form control" | 2 on #6477 — `bg-transparent` on a command-palette search input, `border-0 shadow-none` on a button | **0** | Needs a scope clause: **`CommandInput` and search-inside-a-popover are chromeless by design.** Real new FP |
| **D6** "popover near an input needs `onOpenAutoFocus`" | 2 on #6477 | **0** | Unconfirmed. bp2#6890 shows he cares about this pathology in one component; whether it generalizes to every `PopoverContent` beside an input is untested |
| **V60 vs ghost geometry** | Both fire on #6477's add-row trigger, in **opposite directions** — V60 says step *up* from `text-xs`; the ghost-geometry rule (which produced case 3's only clean hit) says step *down* to `text-xs`/`text-[11px]` for low-frequency panel chrome | Ethan stepped **down** | **New inversion risk.** Not yet a wrong-direction firing on these cases, but the two rules contradict and neither cites the other |

### Net noise
Raw count **8 → 7**. Composition changed materially: **3 inversions → 0**, and **+4 volume/scope FPs**, three of which are one scope clause away from being fixed (V69 demoted out of findings; V31 exempting `CommandInput`; V60/ghost-geometry cross-referenced).

**Was the pass a net loss?** No — but not because recall improved. Trading three inversions for one over-broad rule and two missing scope clauses is a good trade, because inversions actively damage a diff and volume noise merely gets skimmed. If V69 ships as a finding rather than a PR-description note, that judgment flips.

---

## 5. What the pass actually bought — and how to measure it next time

Recall was the wrong metric for this pass, and my validation harness cannot see the thing that changed.

Both validations score **"would a careful reader holding the ruleset catch this?"** Before the pass, ~20 of the visual rules and every `patterns.md` §1–§5 decision table had no trigger at all — they'd fire only if a model happened to notice the right thing while reading. After the pass, **41 rules carry an `rg` pattern.** The same hit is now *deterministic* rather than *lucky*. Case 4 #6 (placeholders) is the clearest illustration: it was a hit in validation 1 and it's a hit now, but validation 1's hit depended on a model recalling one prose line, and now `app --pcre2 'placeholder="[^"…]*[a-z]"'` finds it every time.

**The right metric is fire-reliability, not recall**, and it needs a different harness: run each trigger's `rg` pattern against the original diff and check it matches the line Ethan changed. I did that spot-wise here (V27 → 0 hits, correctly; V56 → 3 hits, correctly suppressed; V31 → 2 hits, incorrectly) and it was more informative per unit of effort than the recall scoring. **Recommend that as validation 3, on a fresh set of pairs the ruleset has never seen.**

Also worth noting, since it argues against more trigger-writing: the other file's *"Rules I'd now delete as unfireable"* section — six rules removed, with reasons — plausibly did more for precision than any trigger it added. F104's deletion alone closed one of the eight FPs.

---

## 6. Verdict

The ruleset is worth running, in a narrower band than the trigger pass makes it look. Strictly scored it still catches about a third of what Ethan changes, and the trigger pass moved that number not at all — what it moved was the *reliability* of the hits it already had (41 rules went from "notice this" to a grep), the *precision* of the surrounding noise (all three inversions closed, which matters more than the raw count suggests, because an inversion instructs you to add what he'd delete), and the *legibility* of the failures (14 of 22 residual misses are now provably out of reach rather than unexplained, and exactly one is a genuine coverage hole). Ship it as a mechanical linter over copy, a11y, state classes, loading-state choice, and the overflow family, with V69 demoted out of findings and scope clauses added to V31 and V60 before it runs on anyone's diff — and ship it saying out loud that rendered layout and product-flow judgment are not checked, because that is 14 of its 22 misses and pretending otherwise is how a tool at 33% gets mistaken for one at 90%. The honest next step is not another trigger pass; it is a fresh set of author→Ethan pairs the ruleset has never seen, scored on whether each trigger's grep actually matches the line he changed.
