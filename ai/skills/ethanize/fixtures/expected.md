# Expected results

Rule IDs are `checklist.md` numbers (`#1`–`#48`), `flows.md` (`F*`), `interaction.md` (`A*`/`J*`),
`detection.md` (`C*`), and section refs for prose rules (`§3.5`, `§4.1`).

**MUST FIRE** — the seeded defect. A miss is a false negative.
**MUST NOT FIRE** — a rule that has a plausible hook in this file and must stay silent.
Those negatives are the point: they catch a rule getting greedy.

Every defect was written from the **trigger** clause (the mistake), never from an `after:` value.
Nothing here was built backwards from a known fix.

---

## cases/

### 01-DealSummaryCard.tsx
- MUST FIRE: `#12` (`text-foreground/60` → `text-muted-foreground`) · `#14` (`text-gray-500` → `text-muted-foreground`) · `#17` (`hover:shadow-md` → `hover:shadow-sm`)
- MUST NOT FIRE: `#13` (no `w-N h-N`) · `#4` · `#2` (no Title Case string)
- Acceptable extra: `#30` — the `Card` is clickable with no keyboard path. Real, not seeded; do not count as a mis-fire.

### 02-FilterBar.tsx
- MUST FIRE: `#4` (`transition-all`) · `#19` (`text-[13px]` → `text-sm`) · `§3.3` (`hover:px-4` animates layout on hover — with `transition-all` present this is bp2#5824 exactly)
- MUST NOT FIRE: `#12` · `#14` · `#18` (`hover:bg-muted` is already the correct hover surface)

### 03-ResourceRow.tsx
- MUST FIRE: `#5` (hover reveal, no `focus-visible`/`group-focus-within`/`pointer-coarse` mirror) · `#6` (`opacity-0` with no `pointer-events-none`)
- MUST NOT FIRE: `#30` — `aria-label="Download"`/`"Delete"` are generic-looking but **not inside a `.map()`**, so #30's own confirmation step must reject them. This is the negative that keeps #30 from firing on every singleton.

### 04-LenderRow.tsx
- MUST FIRE: `#15` (`text-green-600` → `text-success`) · `#3` (two `truncate` spans inside `flex-1` with no `min-w-0`; `Badge` and icon lack `shrink-0`)
- MUST NOT FIRE: `#4` · `#12` · `#21`

### 05-ExportMenu.tsx
- MUST FIRE: `#22` (`MoreVertical` → `MoreHorizontal`) · `#2` **three times** — `aria-label="Export Options"`, and the two menu-item text nodes `Download Spreadsheet` and `Export Deal Report`
- MUST NOT FIRE: `#35`'s primitive clause — this is app code consuming the shared wrapper; nothing here licenses an edit to `src/components/ui/dropdown-menu.tsx`

### 06-PitchPanel.tsx
- MUST FIRE: `patterns:262` / `BC8` (text renders **in this element**, so the wait belongs to `MorphingLevIcon`, not `Loader2`) · `F53` (a multi-minute AI wait showing one frozen line) · `#25` (`Generating your pitch...` → `…`)
- MUST NOT FIRE: `#7` — `animate-spin` is explicitly exempted from the reduced-motion sweep. If #7 fires here it is over-firing on every spinner in the repo.
- MUST NOT FIRE: `#4`

### 07-VaultEmptyState.tsx
- MUST FIRE: `#10` (`filesQuery` never reads `error`/`isError`, so a failed request renders as "No files yet") · `C-J4` (first-run empty state names the absence and offers no CTA)
- MUST NOT FIRE: `#2` — `Memos`, `Vaults`, `AI` are all on the Title Case allowlist. A #2 hit here means the allowlist filter is not being applied.

### 08-SyncBanner.tsx
- MUST FIRE: `#32` (`role="alert"` on an informational outcome → `role="status"`) · `#26` (`{syncedCount} contacts synced` renders "1 contacts synced")
- MUST NOT FIRE: `#16` · `#12` · `#84` (nothing has failed; `Info` in muted tones is correct here)

### 09-AttachmentActions.tsx
- MUST FIRE: `#30` (`aria-label="View document"` / `"Remove document"` repeated inside a `.map()` — interpolate `attachment.displayName`) · `#20` (`className="w-6 p-0"` hand-sizes a `Button` that has no `size` prop) · `#21` (`size-4` icon beside `text-xs` text → `size-3.5`)
- MUST NOT FIRE: `#5` · `#6` (no hover reveal in this file)

### 10-RenameVaultDialog.tsx
- MUST FIRE: `#44` / `F1` (the dialog's only field is optional — create and confirm with a toast instead of blocking) · `F8` (`OK` as a button label; both outcomes must be verbs) · `F73` (`placeholder="Add a note"` — no `…`, and no `Optional.` on a skippable field)
- MUST NOT FIRE: `#2` on `Create a Vault` — `Vault` is allowlisted. A hit means the allowlist isn't consulted.
- MUST NOT FIRE: `#34` (no free-text field is required)

### 11-CreditsFooter.tsx
- MUST FIRE: `#16` (`text-error-foreground` → `text-destructive`) · `F42` (`Something went wrong` is banned) · `F82` (`purchase more credits` names a remedy with no click path) · `F83` (destructive colour is on the `<p>`; it belongs on the icon only)
- MUST NOT FIRE: `#34` — there is no required free-text input, so the submit-guard symmetry rule has nothing to say. (`BC4`: never extend #34 to an entitlement or credit check.)

### 12-TeamTable.tsx
- MUST FIRE: `#13` (`w-4 h-4` → `size-4`) · `C2` **twice** (`border border-border`, `border-b border-border` — `globals.css` already sets the default border colour) · `#25` (`Invite...` → `Invite…`) · `#2` (`Team Members` → `Team members`)
- MUST NOT FIRE: `#22` — `UserPlus` is the correct plain lucide glyph, not a `2` variant

### 13-StepNav.tsx
- MUST FIRE: `#7` (`<motion.div>` with no `shouldReduceMotion` branch) · `§3.5` (`AnimatePresence` without `initial={false}` — a mount is treated as an entrance) · `F66` (pixel slide offsets `x: ±80` while the container recenters; should be `±110%`)
- MUST NOT FIRE: `#4` (no `transition-all` class present)

### 14-PlaceSearchDropdown.tsx
- MUST FIRE: `#29` (`PopoverContent` opened from a text input with no `onOpenAutoFocus` — "he swore about this one") · `§4.1` (`activeIndex` starts at `0`, preselecting the first row; must start at `-1`) · `#36` (`hover:bg-muted` on rows that also have an active index; and `onMouseEnter` must be `onMouseMove`) · `F102` (`PopoverTrigger` wrapping an `<Input>` — must be `PopoverAnchor`)
- MUST NOT FIRE: `#5` · `#6`

---

## boundaries/

**Expected result for every file below: zero findings, zero proposed edits.**
A skill that "fixes" any of these is worse than one that does nothing.

### B1-levender-badge.tsx — QB2
Must not rename, spell-correct, or flag `levender-background` / `levender-foreground`.
Specific risk: `#14` and `#15` (token-normalising sweeps) put an agent inside these exact strings.
> *"levender is an intentional misspelling 😆 I'm being cheeky with our brand colors"*

### B2-bulk-launch-count.tsx — QB3
Must not delete the count badge (`#47`), and must not propose making it track the active choice.
The number is **inventory**, deliberately `Math.max` across all choices.
> *"this is intentional -- we want to show the count of available mutations"*

### B3-submit-only-spinner.tsx — QB6 / BC8
Must not swap `Loader2` for `MorphingLevIcon`. The placement test decides: **does text appear in
this element?** It does not — the click only submits; composing happens later, elsewhere.
This is the one design pushback he won against a human reviewer.
> *"Typing dots in the popover would suggest text is being composed there."*

### B4-absent-selection-tick.tsx — QB5 / BC7
Must not flag the un-ticked row as "a control with no visible effect" (`#48`), and must not
propose an attribute-based identity fallback. The absence **is** the feature.
> *"A non-document identity fallback … is exactly the heuristic that was removed, because two
> user-input observations are indistinguishable by attributes and a shared-type key ticks both."*

### B5-attribution-gated-on-content.tsx — QB4
Must not propose restoring a timestamp-only fallback when content is empty.
> *"a bare timestamp over a pitch that was never written is just as misleading."*

### B6-menu-item-cursor-BC1.tsx — BC1 / QB1
The menu item does inherit `cursor-default` from the Airy primitive. The **only** acceptable
outputs are (a) silence, (b) a `[flag]` reading "belongs upstream in the Airy registry", or
(c) an app-owned wrapper override such as
`[&_[data-slot=dropdown-menu-item]]:cursor-pointer`.

**Automatic failure** if the skill proposes or applies any edit to
`src/components/ui/dropdown-menu.tsx`. `#35` currently names that forbidden action as its fix
("a menu item is `cursor-pointer`, **fixed in the primitive**"), and `#1` cannot stop it — #1 is
`[flag]` and runs on the *incoming* diff, not on fixes the skill itself authors.
This fixture exists so that clause can never regress back in.
