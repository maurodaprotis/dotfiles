# Baseline — first run against the current ruleset

Run date: 2026-08-25 · ripgrep 14.1.1 · ruleset: `checklist.md` (48 checks) + `triggers-*.md`
Method: every `rg` pattern below was executed against `cases/` and `boundaries/`; the
`read-the-component` checks were applied by reading each file.

## Headline

| | pass | total | rate |
|---|---|---|---|
| cases | 8 | 14 | **57%** |
| boundaries | 5 | 6 | **83%** |
| **overall** | **13** | **20** | **65%** |

**This is the number a future change has to beat.**

Of 14 cases, every failure is a **false negative** — a seeded defect the ruleset walked past.
Only one **mis-fire** exists in the whole run, and it is on a boundary file (B2), which is the
expensive kind.

---

## Per case

| case | verdict | detail |
|---|---|---|
| 01-DealSummaryCard | **PASS** | `#12` `#14` `#17` all fired; negatives clean |
| 02-FilterBar | **PASS** | `#4` `#19` fired; `§3.3` caught on read |
| 03-ResourceRow | **PASS** | `#5` `#6` fired; `#30` correctly silent (not in a `.map()`) |
| 04-LenderRow | **PASS** | `#15` fired; `#3` caught on read |
| 05-ExportMenu | **FAIL** | `#22` ✓, `#2` caught **1 of 3** — missed both JSX text nodes |
| 06-PitchPanel | **FAIL** | `BC8` ✓ `F53` ✓ (read); `#25` **missed** `Generating your pitch...` |
| 07-VaultEmptyState | **PASS** | `#10` `C-J4` on read; `#2` correctly silent on allowlisted nouns |
| 08-SyncBanner | **PASS** | `#32` `#26` both fired |
| 09-AttachmentActions | **FAIL** | `#30` ✓ `#20` ✓ (read); `#21` **missed** |
| 10-RenameVaultDialog | **FAIL** | `#44` ✓ `F73` ✓ (read); `F8` **missed** as written |
| 11-CreditsFooter | **PASS** | `#16` `F42` fired; `F82` `F83` on read; `#34` correctly silent |
| 12-TeamTable | **FAIL** | `#13` ✓ `C2` ✓×2; `#25` **missed**, `#2` **missed** |
| 13-StepNav | **PASS** | `#7` ✓ `§3.5` ✓ `F66` on read |
| 14-PlaceSearchDropdown | **FAIL** | `§4.1` ✓ `#36` ✓ `F102` ✓; `#29` **missed** as written |

## Per boundary

| boundary | verdict | detail |
|---|---|---|
| B1-levender | **PASS** | no check matched; `#14`/`#15` correctly did not touch `levender-*` |
| B2-bulk-launch-count | **FAIL** | **`#26` mis-fired** — see below |
| B3-submit-only-spinner | **PASS** | `#7` correctly exempts `animate-spin`; nothing else matched |
| B4-absent-selection-tick | **PASS** | no check fired |
| B5-attribution | **PASS** | no check fired |
| B6-menu-item-cursor (BC1) | **PASS, but see below** | grep tier silent — passed by luck, not by design |

---

## Rules that MISSED (false negatives) — ranked by cost

**1. `#2` Title Case — attribute-only, blind to JSX text nodes.** The biggest gap in the run.
The pattern anchors on `label=|title=|placeholder=|aria-label="…"`, so it caught
`aria-label="Export Options"` but walked past `Download Spreadsheet`, `Export Deal Report`
(case 05) and `Team Members` (case 12) — all Title Case UI copy rendered as JSX children.
Copy is the highest-volume finding class; missing the most common shape of it matters.
Add a companion pattern:
```bash
rg -n --pcre2 '>([A-Z][a-z]+ )+[A-Z][a-z]+<|^\s*([A-Z][a-z]+ )+[A-Z][a-z]+\s*$'
```
Verified: recovers all three misses. Must stay allowlist-filtered and added-lines-scoped.

**2. `#25` ellipsis — same attribute-only blindness.** `(placeholder|label|title|content|
description)="[^"]*\.\.\."` missed `Invite...` (case 12) and `Generating your pitch...`
(case 06), both JSX text. Companion: `rg -n --pcre2 '>[^<]*\w\.\.\.<'` — verified, recovers both.

**3. `#29` popover-steals-caret — searches the wrong direction.** The check is
`rg -A6 'PopoverContent' | rg '<Input'`. The input that owns the caret is almost always the
**trigger or anchor**, which *precedes* `PopoverContent`. Case 14 has exactly that shape and the
check found nothing. Fix: `rg -n -B6 -A6 'PopoverContent'` — verified, fires correctly.
This is his most-sworn-about rule ("it was SO ANNOYING!!"); worth getting right.

**4. `F8` OK/Cancel — needs `-U`.** `>\s*(OK|Okay)\s*<` is line-oriented and JSX puts the label
on its own line. Verified: adding `-U` fires on case 10. One flag, no downside.

**5. `#21` icon-size-vs-text — same-string only.** The pattern requires `size-4` and `text-xs`
in one className. The real shape is an icon element beside a text element (case 09). Same-string
co-occurrence is the rarer case. Needs promotion to `read-the-component`, or a sibling-aware
pattern; as written it will miss most real instances.

## Rules that MIS-FIRED (the expensive kind)

**`#26` pluralization fired on B2 — a QB3-protected fixture.**
`aria-label={\`Launch ${bulkLaunchCount} placements\`}` matches `\{\w*[Cc]ount\}\s+\w+s\b`.

Worth being precise about the nuance: on pure copy grounds #26 is arguably *right* — that string
does render "Launch 1 placements" at a count of 1. But this is **Ethan's own shipped code from
bp2#6620**, and B2's entire purpose is "does the skill leave his shipped code alone". It doesn't.

Two defensible resolutions; someone should pick one rather than leave it ambiguous:
- narrow `#26` to **visible** copy and exempt `aria-label` (the screen-reader string is a label,
  not prose); or
- accept the hit as a genuine latent bug and change B2 to reflect what he'd actually want.

Until then, this counts as a boundary failure.

## Boundary passing by luck, not by design

**B6 / BC1.** No grep fired, so the file "passes" — but the hazard is in `#35`'s **rule text**,
not its pattern. #35 reads "a menu item is `cursor-pointer`, **fixed in the primitive**", which
names an edit to `src/components/ui/dropdown-menu.tsx` — the one forbidden action. Its grep is
`type="single"`, which doesn't match B6, so the fixture never puts the clause under pressure.

**This is not a real pass.** An agent reading #35 while reviewing any file with a dropdown will
still reach the forbidden conclusion, and `#1` won't stop it (#1 is `[flag]` and runs on the
incoming diff, not on fixes the skill authors). Apply BC1's recommended rewording, then B6 will
pass for the right reason. Re-check this specific line on every future run.

## Not exercised by this fixture set

Honest gaps — nothing here tests them, so a regression in any of these is invisible:

- All `needs-rendering` checks: layout pump (`§3.4`), replay-on-rerender (`§3.5` visual half),
  felt latency (`§5.1`), whether two option cards actually look alike (`F28`).
- `#33` (disabled-trigger tooltip), `#41` (Skeleton on `bg-muted`), `#45`, `#46`, `#47`, `#48` —
  no case carries their shape.
- The `[ask]` tier's *question quality*. Fixtures verify a rule fires, not whether the question
  it asks is well-formed or recommends the right default.
- Diff-scoping itself. These are loose files; the added-lines harness is untested here and needs
  its own check against a real branch.

## What a good next run looks like

Applying the five verified pattern fixes above (`#2` companion, `#25` companion, `#29` `-B6`,
`F8` `-U`, `#21` demotion) should convert cases 05, 06, 09, 10, 12, 14 → PASS, taking cases to
**14/14** and overall to **19/20 (95%)**, with B2 the only remaining failure pending the `#26`
decision. Any change claiming to improve the ruleset should be measured against **65%**.
