# INTERACTION — synthesized ruleset

Domain: `state`, `hover`, `focus`, `keyboard`, `a11y`, `motion`, `perf-felt`.
Source: 438 tagged rules across 84 findings files (`state` 166, `motion` 94, `a11y` 62, `hover` 51, `perf-felt` 34, `keyboard` 19, `focus` 11).

The through-line: **every state a control can be in must be reachable, visible, and reversible by both pointer and keyboard — and the feedback for it must never move layout.** Ethan's corrections cluster on four failures: a hover-only affordance, a state with no keyboard/touch equivalent, an animation that replays or reflows, and a disabled control with no stated reason.

---

## Rules — pattern-detectable (I1–I36)

Each has a mechanical detection pattern and an exact fix. **The `Tag:` field is
authoritative, not this heading** — 20 are `auto`, 15 are `ask` because they change
behaviour rather than appearance (a11y roles, focus management, event or keyboard
handlers), and I19 is `flag` because its fix lands in a protected path.

### I1 — Never ship `transition-all`; enumerate the properties that change
- **Detect:** `transition-all` in any className.
- **Fix:** replace with `transition-[<the properties that actually change>]`, e.g. `transition-[color,background-color]`, `transition-[opacity,scale,box-shadow]`, `transition-[max-width,opacity,margin]`.
- **Except:** `transition-all duration-200` survives on `bp2-6548`'s selection bar where translate+scale+opacity all animate together and no layout property exists on the element.
- **Tag:** auto
- **Evidence:** `bp2-5824` — "With the padding change, `transition-all` would have animated tab width on hover — the exact layout shift the PR is removing." Also `memo-663`: "and never `transition-all`."

### I2 — Mirror every hover-reveal with focus, focus-within, and coarse-pointer states
- **Detect:** `group-hover:opacity-100` / `group-hover:flex` / `hover:w-…` on an element whose class list has no `focus-visible:`, `group-focus-within:`, or `focus-within:` counterpart.
- **Fix:** add the mirror for every hover state:
  `group-hover/X:opacity-100 group-focus-within/X:opacity-100 focus-visible:opacity-100 pointer-coarse:opacity-100`
  and, if the element also has a menu, `group-has-[[data-state=open]]/X:opacity-100` or `isMenuOpen && 'opacity-100'`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-6548` names all four reveal conditions; `bp2-7513` — "Both stay permanently visible on coarse pointers, which have no hover state and would otherwise lose the labels and the menu entirely."

### I3 — Make a hover-revealed control unclickable while it is invisible
- **Detect:** `opacity-0` + `group-hover:opacity-100` with no `pointer-events-none`.
- **Fix:** `pointer-events-none … group-hover:pointer-events-auto group-[:has(:focus-visible)]:pointer-events-auto pointer-coarse:pointer-events-auto`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-5824` — "An invisible-but-clickable overlay steals clicks meant for the tab."

### I4 — Focus and invalid rings on interactive primitives are `ring-3`
- **Detect:** `focus-visible:ring-2` or `aria-invalid:ring-2` on a `Button`/interactive primitive.
- **Fix:** `ring-3` for both.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-nits` — "Improved button focus ring visibility by changing from `ring-2` to `ring-3`."

### I5 — Give every clickable non-button a keyboard path, a focus ring, and a label
- **Detect:** `onClick` on a `div`/`span`, or a `<button>` with no `aria-label` and only an icon child.
- **Fix:** for the div: `role="button" tabIndex={0}` + `onKeyDown` handling `Enter` and `' '` with `preventDefault()` + `focus-visible:ring-2 focus-visible:ring-ring/50 focus-visible:outline-none`. For the icon button: add `aria-label` describing the **action** (`'Zoom in'`), and for a toggle the action not the state (`config.interactionsLocked ? 'Unlock map' : 'Lock map'`).
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7130`, `bp2-7205`, `bp2-7513`.

### I6 — Interpolate row data into a repeated icon-only action's label
- **Detect:** the same literal `aria-label` string inside a `.map()`.
- **Fix:** interpolate the row's own data — `` aria-label={`Remove ${displayName}`} ``, `` aria-label={`View table ${formatSourcePages(version.sourcePages)}`} ``.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-6183`, `bp2-7724` — "twelve buttons all labelled 'View table' are useless in a screen-reader list."

### I7 — Associate every visible label with its control
- **Detect:** `<Label>` or `<label>` as a sibling of an `Input`/`Select`/`Checkbox`, or a `<label>` wrapping both with no `htmlFor`.
- **Fix:** `const id = useId()` → `<Label htmlFor={id}>` + `<Input id={id}>`; for buttons/`role="group"`, `const labelId = useId()` + `aria-labelledby={labelId}`. **Delete the now-redundant `aria-label`.**
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7226` — "the `aria-label` I put on the input covered the screen-reader half while leaving the visible label dead to a click"; `bp2-6363`, `bp2-7219`.

### I8 — Hide decorative elements from assistive tech at one node
- **Detect:** an `<svg>`, illustration wrapper, spacer, scrim, mask, ring, or separator glyph with no `aria-hidden`.
- **Fix:** `aria-hidden` on the outermost decorative node (one node, not each part), plus `pointer-events-none` on anything that overlays a click target.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7193` ("The whole decorative illustration is one `aria-hidden` node — don't label its parts"), `bp2-7031`, `bp2-6987`, `bp2-6691`.

### I9 — Match live-region severity to the outcome
- **Detect:** `role="alert"` on anything that is not a genuine failure.
- **Fix:** `role="status"` for informational outcomes; `role={banner.isError ? 'alert' : 'status'}` when one component renders both; `role="note"` for a static non-interactive callout; `role="tooltip" aria-live="polite"` for a provenance/hover card.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7225` — "A dead end is a status, not an alert — only genuine failures should interrupt a screen reader." `bp2-7343`, `bp2-6043`, `memo-790`.

### I10 — Give every animation a reduced-motion escape that lands on the finished state
- **Detect:** any `animate-*`, `@keyframes` consumer, `motion.*` transition, or `transition-[…]` added for polish, with no `motion-reduce:` / `useReducedMotion()` / `prefers-reduced-motion` branch.
- **Fix:** CSS → `motion-reduce:transition-none` or `motion-reduce:animate-none`; Framer → `transition={shouldReduceMotion ? { duration: 0 } : STEP_TRANSITION}`; WAAPI → early-return before `.animate()`. **Critical corollary:** the reduced-motion branch must land on the **finished** state, not the start state — `animation: none; stroke-dashoffset: 0`, `opacity: 1`, `background-image: none !important`. A frozen shimmer parked mid-sweep is worse than no shimmer.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-6636` ("applied uniformly to all three animations introduced in this PR, no exceptions"), `bp2-6363`, `bp2-7343`, `memo-783`.

### I11 — Replace `Skeleton` on a `bg-muted` surface with the sweeping shimmer
- **Detect:** `<Skeleton />` inside a container whose background is `bg-muted`.
- **Fix:** use the sweeping `.lev-shimmer` (transform-based, `linear`) instead.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-7343` — "identical fill, and pulsing opacity on a colour that matches its own backdrop is invisible."

### I12 — Drive shimmer with `transform`, never `background-position`
- **Detect:** `@keyframes` animating `background-position` percentages.
- **Fix:** `transform: translateX(-100% → 100%)` on an `::after` overlay, `linear` easing, and `background-repeat: no-repeat` if `background-size` exceeds 100%.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-7343` (percentages resolve against container − background-size); `memo-783` ("at `240%` background-size the gradient tiled, so a second highlight entered from the left near the end of every cycle").

### I13 — Reject the empty value from a single-select `ToggleGroup`
- **Detect:** `<ToggleGroup type="single" onValueChange={onChange}>`.
- **Fix:** `onValueChange={(next) => { if (next) onChange(next as T) }}`.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7200`, `bp2-7343` — "a required setting must not have an empty state."

### I14 — Include required free-text fields in the submit guard
- **Detect:** a submit `disabled` expression that omits the required free-text field.
- **Fix:** add `|| !prompt.trim()` to **both** the `disabled` prop and the handler's early return.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7031` — "an enabled submit that does nothing is worse than a disabled one. `.trim()` — whitespace is not input."

### I15 — State the reason a control is disabled and kill its live hover
- **Detect:** `disabled={…}` with no adjacent tooltip/banner explaining why, or a disabled trigger whose class list still has `hover:underline` / `hover:bg-*`.
- **Fix:** add `disabled:cursor-not-allowed disabled:text-muted-foreground/50 disabled:hover:no-underline`; and either a `TooltipContent` naming the reason (`'Radial gradients have no angle'`) or an inline banner naming the missing prerequisite with the fix as a link.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-6457`, `memo-776` — "a disabled one that explains itself teaches the model."

### I16 — Wrap a disabled button in a span before using it as a Tooltip trigger
- **Detect:** `<Tooltip …><Button disabled … /></Tooltip>`.
- **Fix:** `<Tooltip asChild …><span className="inline-flex"><Button disabled … /></span></Tooltip>`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-6715` — "our disabled `Button` includes `disabled:pointer-events-none`, so … Radix never receives hover/focus pointer events and the tooltip will not open."

### I17 — Never `asChild` onto a `TabsTrigger` or a fragment-rendering child
- **Detect:** `<Tooltip asChild><TabsTrigger …/></Tooltip>`, or any overlay measuring a fragment-rendering child.
- **Fix:** wrap in `<span className="inline-flex">` instead.
- **Except:** —
- **Tag:** auto
- **Evidence:** `memo-668` — "`TabsTrigger` via `asChild` would overwrite the tab's `data-state` styling." `bp2-7314` — the span "keeps `DealActions` (a fragment) intact while giving the spotlight a box to measure."

### I18 — Stop a popover opened from a text input from stealing the caret
- **Detect:** a `PopoverContent`/`DropdownMenuContent` opened from a text input that has no `onOpenAutoFocus`.
- **Fix:** `onOpenAutoFocus={(event) => event.preventDefault()}` and, when the panel annotates a live surface, `onCloseAutoFocus={(event) => event.preventDefault()}` too.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-nits` — "the address popover on the create deal card yanked your keyboard focus -- which interrupted you mid input. it was SO ANNOYING!!"; `bp2-7317`, `memo-668`.

### I19 — Menu rows and clickable handles are `cursor-pointer`
- **Detect:** `cursor-default` in `components/ui/dropdown-menu.tsx` or on any menu row.
- **Fix:** `cursor-pointer`. Fix it in the primitive, not per call site. Related: a drag handle you also click is `cursor-pointer`, not `cursor-grab` (`memo-nits`); a mark that answers to hover is `cursor: help` (`memo-790`); a resize separator is `col-resize` (`memo-678`).
- **Except:** —
- **Tag:** flag
- **Evidence:** `bp2-4894`, `memo-nits`, `memo-790`, `memo-678`.

### I20 — Give any chip or pressable surface a hover state
- **Detect:** an element that opens a picker or menu with no `hover:` background.
- **Fix:** `transition-colors hover:bg-muted`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-7031` — "a chip that opens a picker must look pressable; without a hover state it reads as a static label."

### I21 — Back destructive text on a ghost button with destructive hover and focus states
- **Detect:** `className="text-destructive"` on a ghost/icon button.
- **Fix:** `text-destructive hover:bg-destructive/10 hover:text-destructive focus-visible:bg-destructive/10 focus-visible:text-destructive`. For menu items, use the primitive's `variant="destructive"` instead of an ad-hoc color.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-6824`, `memo-668`.

### I22 — Collapse hover and active-index highlighting into one state in a keyboard-navigable list
- **Detect:** `hover:bg-*` on a row that also has an `activeIndex`/`isSelected`/`data-highlighted` concept.
- **Fix:** delete the `hover:` class; drive one class off the single active state — `cn('…', isActive && 'bg-foreground/5')` — and sync it on `onMouseMove`, never `onMouseEnter`. In Radix menus, pair `hover:` with `data-[highlighted]:` identically.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7377` — "there is never a hovered row and a separately highlighted one arguing about which Enter would take"; and "arrowing scrolls a row under a stationary pointer and `mouseenter` fires, snapping the highlight back." `memo-665`, `bp2-6549`.

### I23 — Guard `onDragLeave` against child-boundary flicker
- **Detect:** `onDragLeave={() => setIsDraggingOver(false)}`.
- **Fix:** `onDragLeave={(e) => { if (!e.currentTarget.contains(e.relatedTarget as Node | null)) setIsDraggingOver(false) }}`, and set `e.dataTransfer.dropEffect = 'copy'` in `onDragOver`.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-6183`.

### I24 — Namespace SVG `<defs>` ids per instance
- **Detect:** a literal string id on a `<linearGradient>`/`<mask>` in a reusable component.
- **Fix:** `` const gradientId = `${useId().replaceAll(':', '')}-<name>` ``.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-6363`.

### I25 — Fix the height of a text line that swaps under `AnimatePresence mode="wait"`
- **Detect:** a swapping `<motion.p>` inside an auto-height parent.
- **Fix:** wrap in `<div className="flex h-5 items-center">`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-7558` — "or the block collapses and rebounds on every swap."

### I26 — Reset scroll offset before measuring after a content swap
- **Detect:** a `useEffect` keyed on the previewed item id that measures but does not reset scroll.
- **Fix:** `const el = scrollRef.current; if (el) { el.scrollTop = 0; el.scrollLeft = 0 }` before measuring.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7724` — "React reuses the scroll container, so the offset survived the content swap … My code comment claiming the scroller resets was simply wrong."

### I27 — Sort before trimming
- **Detect:** `.slice(0, limit)` followed by, or in place of, a sort.
- **Fix:** `[...mapped].sort(cmp).slice(0, limit)`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-7222` — "Sort before trimming, or the nearest result could be the one cut."

### I28 — Delete `console.log` from components
- **Detect:** `console.log` in a component
- **Fix:** delete it.
- **Except:** —
- **Tag:** auto
- **Evidence:** `memo-663`.

### I29 — Center an icon beside single-line text instead of nudging it
- **Detect:** `flex items-start` + `mt-0.5` on an icon beside single-line text
- **Fix:** `items-center`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-6072`.

### I30 — A `<video>` demo autoplays silently and fills its frame
- **Detect:** `<video>` demo
- **Fix:** `autoPlay loop muted playsInline` + `object-cover aspect-video`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-7031`.

### I31 — A hover lift raises by one stacking step, not ten
- **Detect:** `zIndex` on a hover lift — `hover:z-10`
- **Fix:** `hover:z-[1]`, not `hover:z-10`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-6535`: "`z-10` made a hovered list row compete with page overlays".

### I32 — Give a repeatedly fired toast a stable id
- **Detect:** Toast fired repeatedly
- **Fix:** give it a stable `id` so it replaces rather than stacks.
- **Except:** —
- **Tag:** auto
- **Evidence:** `memo-798`.

### I33 — Fall back to a default icon instead of rendering nothing
- **Detect:** Unmapped dynamic icon — `return null`
- **Fix:** `?? FALLBACK_ICON`, never `return null`.
- **Except:** —
- **Tag:** auto
- **Evidence:** `bp2-7679`.

### I34 — Hide an empty `aria-live` container
- **Detect:** `aria-live` container that can be empty
- **Fix:** add `empty:hidden`.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7343`.

### I35 — Clear drag-suppression flags on `keyup` too
- **Detect:** a drag-suppression flag cleared only on `pointerup`/`pointercancel`
- **Fix:** Clear a drag-suppression flag on `keyup` as well as `pointerup`/`pointercancel`.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7219`.

### I36 — Cap per-frame `dt`
- **Detect:** `ts - last` used as a raw frame delta
- **Fix:** Cap per-frame `dt`: `Math.min(ts - last, 64)`.
- **Except:** —
- **Tag:** ask
- **Evidence:** `memo-678`.

---

## Rules — judgment (I37–I46)

Propose, don't apply. Each is a question with a recommended default. All `ask`.

### I37 — Decide between disabling, hiding, and explaining by why the control cannot act
- **Trigger:** a control rendered with `disabled={…}` where the *reason* is a feature flag or a mode, rather than a transient condition
- **Detect:** read the component — a `disabled={…}` control, or a control rendered in a mode where it cannot act
- **Fix:** **Question:** the control can't act right now. Which? **Default ladder:**
  1. **Behind a feature flag → render nothing.** `if (!hasFlag) return null`. Never a disabled shell for a feature the user doesn't have.
  2. **Meaningless for the current mode → hide.** A locked map has no zoom to grey out; an `Image fit` control under `photo` "did nothing".
  3. **Meaningless for the current *type*, in a toolbar → disable + tooltip.** "a control that disappears per type makes the toolbar shift."
  4. **Blocked by missing data → stay visible, disable the controls, name the prerequisite, and put the fix inline** as a link opening the real flow.
  5. **Cannot ever exist → omit at the source with a comment stating the product reason** (`// The subject property is the map's reason for existing, so it has no delete.`).
  6. **Check still in flight → disable with NO reason.** `disabled` and `disabledReason` are separate props. "an explanation that might be wrong is worse than none."
  > And: an action that would silently no-op is worse than an absent one — guard on the data (`documentId != null ? <Delete/> : null`), don't pass an empty array.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-6457`, `bp2-7205`, `memo-776`, `bp2-7513`.

### I38 — Push state toward more persistence, never less
- **Trigger:** per-item UI state declared in a **list** component and passed down — `useState` in a parent whose value is threaded into a `.map()` child as `isXOpen`/`activeId`; a dismissal/seen flag in `useState` or at module scope where it should survive reload; or `Boolean(cookie)` / `!!cookie` on a persisted preference, collapsing "unset" and "prefers closed"
- **Detect:** read the component — `useState` for UI state that a remount, route change, or reload would reset
- **Fix:** **Question:** must it survive a remount? a route change? a reload? **Default ladder:**
  - Per-item UI state → **in the item component.** Lifting it to the list leaks one item's open state onto its siblings.
  - "Which menu is open" across a list → **hoist to the list**, so opening one closes the others. (The one deliberate exception to the line above.)
  - Survives remount, resets on reload → module-level flag + `useSyncExternalStore`. Preferred over a context provider: "a module-level store is both smaller and stickier."
  - Survives reload → **cookie via `useCookieState`**, value `'true'`, `expires: 365`, named after the card in kebab-case, compared as `seen !== 'true'`.
  - **The direction is always toward more persistence, never less.** #7130's module flag was superseded by #7161's cookies one PR later.
  - Persisted booleans are **tri-state**: `'true' → true`, `'false' → false`, anything else → `undefined` (never set). `Boolean(cookie)` makes "unset" and "prefers closed" behave alike, and the smart default becomes unreachable.
  - **Only the user's own action writes the preference.** An automatic expand must not record one.
- **Except:** "Which menu is open" across a list is the one deliberate exception to keeping per-item state in the item component — hoist it to the list.
- **Tag:** ask
- **Evidence:** `bp2-7130` → `bp2-7161` → `bp2-7314`, `memo-nits`, `bp2-6460`, `bp2-7226`.

### I39 — Keep the write authoritative; put the optimism into rendering
- **Trigger:** a mutation with `optimisticResponse`, or a UI state set before the `await` resolves
- **Detect:** read the component — an optimistic mutation, or a mutation whose UI moves before the server confirms
- **Fix:** **Question:** should the UI move before the server confirms? **Default:** *no optimistic mutation.* Ethan's pattern is different — the **write stays authoritative, but the paint doesn't wait on React**:
  - Progress lives on the button that started it (spinner + present-participle label); the toast only appears **on success** — no interstitial "publishing…" toast (`memo-798`).
  - A dialog that owns an expensive write **holds its loader until the write lands and stays open on failure** — `await onGenerated(…)` in a `try`, `catch { return }`, keeping the instructions so the run can be retried without retyping (`bp2-7558`).
  - A destructive confirm is a state machine: pending label, inline error, stays open on failure, `onOpenChange` returns early while in flight (`bp2-7205`).
  - Snapshot the data the confirmation will show **at the moment of the action**, not in the success callback — "reading the editor again in `onSuccess` would preview any edits made while the request was in flight" (`memo-798`).
  - Clear the input on success; **keep it on failure** so the user can retry (`memo-783`).
  > The optimism goes into *rendering*, not into *pretending the write succeeded*. See §5.
- **Except:** —
- **Tag:** ask
- **Evidence:** `memo-798`, `bp2-7558`, `bp2-7205`, `memo-783`.

### I40 — Lock the whole choice group during an in-flight action, but never the escape control
- **Detect:** read the component — `disabled={isBusy}` / `disabled={isUnlocking}` on a subset of a choice group, or on a Cancel control
- **Fix:** **Default:** the whole choice group, not just the confirm button — `<RadioGroup disabled={isUnlocking}>` — because "changing the strategy mid-request would apply a plan the user no longer sees" (`bp2-6620`).
- **Except:** **But** drop `isBusy` gating from *escape* controls: "a disabled Cancel is a trap" (`memo-613`).
- **Tag:** ask
- **Evidence:** `bp2-6620`, `memo-613`.

### I41 — A batch action leaves the selection alone
- **Trigger:** a batch handler that calls `setSelected(...)` / `setActiveId(...)` after adding more than one item
- **Detect:** read the component — a bulk/batch add that calls a selection setter
- **Fix:** **Default: no.** A single add selects the new item; a batch add leaves selection alone — "with several pins arriving at once there's no meaningful 'the one you just added'" (`bp2-7225`). An empty batch is a no-op that must not mark the draft dirty.
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7225`.

### I42 — Pick the selected-state marker to fit the surface, and never stack two
- **Trigger:** `ring` used as a selection marker on a colour swatch; the **same** class driving both hover and selected on a row
- **Detect:** read the component — a selected-state class such as `ring`, `border-primary`, `bg-accent`, or a `<Check>` marker
- **Fix:** **Default:**
  - Swatch / color → **checkmark on the swatch**, tinted by perceived luminance (`0.299r + 0.587g + 0.114b`, threshold `0.6`). Never a ring — "a ring reads as focus and disappears on light swatches."
  - Card / radio card → `border-primary bg-primary/5 ring-1 ring-primary/40 hover:bg-primary/10` + an absolutely-positioned `<Check className="absolute top-3 right-3 size-4 text-primary" />` + `aria-pressed`.
  - Table row → `inset_3px` left bar as the real marker, `bg-muted/50` as a soft tint. **Never `bg-accent` for both hover and selected** — the two become indistinguishable under the cursor.
  - **Two selection indicators must never stack** — suppress the coarser one while the finer is showing.
- **Except:** —
- **Tag:** ask
- **Evidence:** `memo-663`, `bp2-6620`, `bp2-7558`, `bp2-6549`.

### I43 — Render no tick rather than possibly the wrong one
- **Trigger:** an identity comparison for a selected/current marker that falls back to a non-unique field — `name ===`, `fileName ===`, `value ===`, `label ===` — or an id that can be `null` in production
- **Detect:** read the component — a selected/ticked comparison on filename, value, or any non-id field
- **Fix:** **Default: render nothing rather than possibly the wrong thing.** Match by ID; when no ID exists, match on content identity (normalized markup) and tick **only on an unambiguous match** — `matches.length === 1 ? … : null` — and collapse the tick gutter when nothing can be ticked (`bp2-7711`, `bp2-7724`, `memo-776`). Never compare filenames or values: "duplicate filenames (re-uploads) and identical values can both tick the wrong row."
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7711`, `bp2-7724`, `memo-776`.

### I44 — Gate a migration that rewrites a user's deliberate choice; run a pure rename ungated
- **Trigger:** a normalization/migration running on load that writes a field the user can choose, with no persisted marker guarding it
- **Detect:** read the component — a data migration running on load
- **Fix:** **Question:** does the migration rewrite a value the user could have deliberately chosen?
  - **Yes → gate it behind a persisted marker** (`logoFitMigrated`). Without it, "a deliberate `cover` was rewritten on the next load, making the option impossible to keep."
  - **No (a pure rename) → run it ungated on every load.** "a rename is idempotent and a marker only adds a way for it to silently not run" (`bp2-7229`, `bp2-7219`).
- **Except:** —
- **Tag:** ask
- **Evidence:** `bp2-7229`, `bp2-7219`.

### I45 — Reshape a surface in place instead of swapping its content
- **Trigger:** a state change implemented by swapping which component mounts (`{isEmpty ? <EmptyCard/> : <FilledCard/>}`) where the two share a footprint
- **Detect:** read the component — a state change that unmounts one subtree and mounts another
- **Fix:** **Question:** should the state change swap content, or reshape it? **Default:** reshape in place. A dropzone becomes a filled row (dashed frame → borderless); a failed item shows its failure **in place of** its content, centered, with the alert glyph swapping to the recovery action on hover; a hidden-but-animating panel keeps its geometry via `data-*` + `opacity: 0; pointer-events: none` rather than unmounting (`memo-673`, `memo-674`, `memo-668`).
- **Except:** —
- **Tag:** ask
- **Evidence:** `memo-673`, `memo-674`, `memo-668`.

### I46 — Key a warning to the violating state, not the gesture that revealed it
- **Trigger:** a warning/invalid state keyed to a gesture handler (`onDragEnd`, `onPointerUp`, `onMouseLeave`) rather than to the condition that caused it
- **Detect:** read the component — a warning shown off a gesture handler (`onDrag`, `onMouseDown`, `onResize`)
- **Fix:** If the condition persists after the interaction ends, the warning must too — keyed to the **violating state**, not to the gesture, then eased to a resting tint rather than held at full strength or dropped (`bp2-7343`).
- **Except:** If the condition is momentary, it can be tied to the gesture.
- **Tag:** ask
- **Evidence:** `bp2-7343`.

---

## Reference

### 3. His motion system

#### 3.1 The easing vocabulary

| Curve | Name | Used for |
|---|---|---|
| `cubic-bezier(0.22, 1, 0.36, 1)` | easeOutQuint | **The house curve.** Entrances that land softly, collapsibles, sidebar labels, step transitions, list transitions, staggered chips. `STEP_TRANSITION = { duration: 0.28, ease: [0.22, 1, 0.36, 1] }` |
| `cubic-bezier(0.23, 1, 0.32, 1)` | expo-out | Pops, expansions, toolbar entrances, the AI-button press, per-word text reveal. "an expo-out curve makes a size change feel like it settles rather than stops." |
| `cubic-bezier(0.16, 1, 0.3, 1)` | expo-out (softer) | Overlay panels, card hover lift, welcome animation |
| `cubic-bezier(0.4, 0, 0.2, 1)` | standard/material | **Travel between two positions** — image slides, line draws |
| `cubic-bezier(0.32, 0.72, 0, 1)` | — | Long step slides (0.7s), full-width page changes |
| `cubic-bezier(0.45, 0, 0.55, 1)` | symmetric ease-in-out | A row that starts *and ends* at rest (cross-group row move) |
| `cubic-bezier(0.36, 0.07, 0.19, 0.97)` | — | The rejection shake, only |
| `ease-out` | — | Default for most Tailwind transitions |
| `ease-in-out` | — | **Pulses that reverse** (a breathing glow) |
| `linear` | — | **Directional sweeps** — shimmer, countdown bars, drop-indicator glide. "a travelling highlight that accelerates reads as a stutter." |
| plain `ease` | — | Exits of small repeated items |

#### 3.2 The duration ladder

| ms | What |
|---|---|
| 100 | Hover-card entrance (`animate-in fade-in-0 zoom-in-95 duration-100`) — "short enough not to lag the pointer" |
| 140 | Drop-indicator glide (fixed **duration**, not speed) |
| 150 | Control-level reveal, swatch scale, sidebar preview entrance |
| 160 | AI-button `active:scale(0.97)`; illustration stagger step |
| 180 | Floating toolbar entrance (`0.18s`, opacity + 5% scale, directional `origin-*`) |
| **200** | **The default for control-level motion.** Sidebar label collapse, selection bar, pill expand, dialog width, `grid-template-columns`, tab-panel height, animated collapsible |
| 240 | Collapsible height (`0.24`, matched to the platform sidebar's submenus); beam height |
| 250 | A highlight moving between targets (`PANEL_HIGHLIGHT_ANIMATION_MS`) |
| **280** | **The default for step/reveal transitions.** `STEP_TRANSITION`, `LIST_TRANSITION`, slide-in panel *enter* |
| 300 | Illustration hover transforms; card lift |
| 320 | Rejection shake (`REJECT_SHAKE_DURATION_MS`) |
| 360 / 260 | Suggestion-chip enter / exit |
| 380–460 | Illustration line-draw / pop |
| 420 | Slide-in panel **exit** (`REPORT_EXIT_DURATION`) |
| 500 | Container settle; a stack dealing itself out; a warning easing to its resting tint |
| 640 | Image-to-image slide *through* the frame |
| 700 | Full-step slide (offset `±110%`) |
| 900 | A glow that lingers; `HIDE_DELAY_MS` for a frame staying up after a gesture |
| 1000 | The slow half of an asymmetric fade |
| 1050 | Cross-group row move |
| 1400 | **The loop period.** Shimmer and generating-pulse are phase-locked to the same `1.4s` |
| 3000 | A timed hint that then gets out of the way (border beam) |

#### 3.3 When something animates vs. appears instantly

**Trigger:** `animate-*` on a **hover** state — a keyframe doing a transition's job (`group-hover:animate-`, `hover:animate-`); or hover classes that move layout on a list row (`hover:translate-x-`, `hover:scale-`, `hover:-translate-`).

**Transitions are for single state changes** (rest → hover, open → closed). **Keyframes are for looping and entrance.** `bp2-7007`: `group-hover:animate-bubble-swap` → `transition-transform duration-300 ease-out group-hover:scale-110 group-hover:rotate-3`.

Animate:
- Anything that changes **size or position of a container** — otherwise it snaps.
- The **arrival of new content** in a list or step.
- A **warning** appearing or receding.

Do **not** animate:
- **Layout on hover.** "Hover may fade colors; it must not move the row." Delete translate/scale/blur/y nudges on list rows (`bp2-7679`).
- A **drag knob under the pointer** — a knob that grows moves the thing you are aiming at; express grab state through the cursor only (`memo-663`).
- The **size** of a moving indicator — animate its position, snap its size, "or the line visibly stretches between different-width spots" (`memo-678`).
- Anything **at rest**. "nothing loops at rest; only the always-running loading indicator animates unprompted, and that one is `motion-safe`-gated" (`bp2-6987`).
- A decorative loop that competes with a sibling — the "always-on" beam fades out when a sibling is hovered (`bp2-6183`).

Exit timing is **asymmetric, in the direction the surface's meaning implies**:
- A **dismissed panel** exits *slower* than it enters (`0.28` → `0.42`): "a fast exit reads as a glitch; a slower exit reads as dismissal."
- A **small repeated item** exits *faster* than it enters (`360` → `260`): "leave quickly, arrive gracefully."
- A **state-driven glow**: fast to ignite, slow to fade (`duration-200` on, `duration-1000` off) — "like a flame burning out."

#### 3.4 Layout shifts

**Trigger:** an animated dimension implemented by swapping `max-w-*` / `w-*` classes; a grid column class applied conditionally on "is it showing now" rather than "could it ever show", so the template exists on only one side and nothing interpolates; a hidden-but-mounted panel with `opacity-0` and no `absolute`.

The recurring bug is a container that snaps or pumps while its contents animate. His fixes:

| Problem | Fix |
|---|---|
| Dialog width jumps | Animate a real `width` driven by a CSS variable; `sm:max-w-none` to get `max-width` out of the way; `min(calc(100vw-2rem), var(--w))` so it still respects the viewport. **Never swap `max-w-*` classes** — "the box jumps to the new constraint and content reflows in one frame." |
| Column opens/closes | Transition `grid-template-columns` to a `0rem` track. The template must exist on **both** sides; gate on `hasReceiptChoice` (could it *ever* show) not `showReceipt` (is it showing *now*). |
| Hidden column still adds height | `absolute` + `pointer-events-none` + `aria-hidden` while collapsed; `relative` when shown; put the padding (`px-6 → px-0`) in the transition list too. |
| Content re-wraps while its column shrinks | **Freeze the inner width** (`sm:w-[19rem] sm:min-w-[19rem]`) so it slides instead of reflowing. "each rewrap changes its height, and the modal pumps." |
| Content blanks mid-exit | Keep a **fallback value** rendered for the duration of the exit (`selectedUnlockPlan ?? plan.choices.find(…)`). |
| Panel height snaps between tabs | `AnimatedHeight`: `transition-[height] duration-200 ease-out motion-reduce:transition-none`, height `null` until measured "so the first paint lays out at natural height instead of animating up from zero", measure the inner layer not the scroller, `borderBoxSize` not `offsetHeight` ("a 1px jitter loop on some zoom levels"). |
| Modal trails its own contents | Tween **only on step changes** (`isNewStep.current`); otherwise track measured height frame-for-frame at `{ duration: 0 }`. |
| Sidebar appears instantly instead of sliding | Always render the `<aside>` and transition `w-[…] → w-0`; hold the inner content at `min-w-[…]` so it doesn't reflow while sliding. |
| Slide fights a simultaneous recentering | Express the offset as a **percentage of the container that clearly exceeds the layout shift** (`±110%`), not a pixel nudge. |
| Focus ring clipped | `overflow-hidden` **only while the height transition is actually running** — settle from `onTransitionEnd`/`onAnimationComplete`, not a timer. "the focus ring is an outer box-shadow and these wrappers are exactly as wide as the rows inside them." |
| Panel flashes at its origin | `style={{ visibility: 'hidden' }}` on mount; reveal only once the winning placement lands. |
| Panel walks across the screen to a new anchor | `key={anchor.id}` so React tears it down and rebuilds — "reading as one menu wandering rather than two separate ones." |

#### 3.5 Stopping re-animation on re-render — the explicit contract

**Trigger:** a one-shot entrance class (`animate-in`, `animate-*-in`, `fade-in`) on markup that persists after the animation settles, with no settle step stripping it; or `<AnimatePresence>` without `initial={false}`.

1. **Strip the one-shot animation, keep the layout wrappers.** `settlePitchFloatInHtml` removes `animate-pitch-float-in` and the inline `animation-delay` from every word span but leaves the `inline-block` spans in place. Both halves matter: keep the spans (no sub-pixel snap on relayout), drop the animation (no replay on remount). — `bp2-7161`
2. **Never swap back to the plain markup** once an animation settles. "swapping back to the plain HTML would relayout the text by a sub-pixel hair (inline-block words accumulate widths differently) and read as a snap." — `bp2-7130`
3. **`AnimatePresence initial={false}`** so a mount is not an entrance.
4. **`data-open` attribute over conditional mounting.** The selection bar is always mounted so it can animate *out*; `pointer-events-auto` only at `data-open=true` keeps the invisible bar from eating clicks. — `bp2-6548`
5. **`animation-fill-mode: both`** on staggered items, "so each element stays hidden through its delay." Collapse N near-identical keyframes into one keyframe + N `animation` shorthands differing only in `animation-delay`.
6. **Paint the collapsed state for one frame first** — two nested `requestAnimationFrame`s — or there is nothing to transition from.
7. **Keep `filter` out of any animation with a fill mode.** "A persisted `filter` (even `blur(0)`) keeps the element on a filter-backed layer that Safari rasterizes once at the animated scale and never refreshes, leaving the SVG permanently blurry." Split blur into its own non-filling animation.
8. **Back every `transitionend` listener with a `duration + 50ms` timeout**, so an interrupted transition can't strand the element. The timeout is the fallback, never the primary signal.
9. **A moving highlight scales+fades in on *first* appearance only**; subsequent moves just transition position — "an element that is already on screen should slide, not re-pop."
10. **Transform only a wrapper; keep all paint on a static inner element.** A layer that also paints (mask, opacity, shadow) snaps instead of tweening.

---

### 4. His keyboard contract

Clearest evidence: `bp2-7377` (map place search), plus `bp2-7724`, `memo-635`, `memo-667`, `memo-790`.

#### 4.1 Combobox / suggestion list under a text input

**Trigger:** a list of suggestions rendered under a text input where the rows have `onClick`/`onMouseEnter` but the input has no `onKeyDown`; or `role="combobox"` / `role="listbox"` present with no `aria-activedescendant`; or an `activeIndex` initialised to `0`.
A mouse-only dropdown is a bug, not a scope boundary.

| Key | Behaviour |
|---|---|
| `↓` / `↑` | Move the highlight. **Wraps at both ends.** "Nothing highlighted" sits *before* the first row, so `↑` on a fresh list lands on the **last** result. |
| `↓` on a closed panel | **Reopens it and does not move the highlight** — "the press is spent opening." Not `preventDefault`ed: "reopening a dismissed list is a side effect of the press, not a replacement for it." |
| `Enter` | Commits, gated on `open && activeIndex >= 0 && activeIndex < resultCount`. |
| `Escape` | Closes the panel, **leaves the caret where it is**, and clears the highlight. |
| `Home` / `End` | **Deliberately not bound.** "They belong to the caret in an editable field — you press Home to fix a typo at the start of what you typed." |

- **Never preselect the first row.** `activeIndex` starts at `-1`. "Enter on a half-typed query should do nothing rather than commit whatever Google ranked first — the standard non-autoselect combobox behaviour, and the safer default when the action is a mutation."
- **Reset the highlight when the result set changes**, keyed on the *results identity*, not the query string — "the list arrives a request later than the typing."
- **Closing clears the highlight**, "so Escape-then-↓ doesn't resume on a dismissed row — and `aria-activedescendant` would meanwhile be pointing at an option that no longer exists."
- **Focus never leaves the input.** ARIA: `role="combobox" aria-expanded aria-controls={open ? listboxId : undefined} aria-autocomplete="list" autoComplete="off"` on the input; `role="listbox"` wrapper; `role="option" aria-selected id={…}` rows; point with `aria-activedescendant`, never by moving focus. Rows **stay `<button>`s**, so a plain click still works with no extra handler.
- **`aria-controls` / `aria-activedescendant` must be conditional on the node existing.**
- `optionRefs.current[activeIndex]?.scrollIntoView({ block: 'nearest' })` — "scrolls only far enough to reveal the row, so arrowing through the middle of a long list doesn't jump the viewport on every press."
- **Hover syncs on `onMouseMove`, never `onMouseEnter`** — and the keyboard highlight and the hover highlight are **one class**.

#### 4.2 Dialogs
- Arrow keys page through browsable content (`ArrowRight`/`ArrowDown` → next, `ArrowLeft`/`ArrowUp` → previous, with `preventDefault()`), **and the footer advertises it** with `<kbd>` chips — "a shortcut nobody is told about doesn't exist."
- Focus on open: the default Radix behaviour, **except** when the dialog/popover annotates a live surface holding the caret — then `onOpenAutoFocus` **and** `onCloseAutoFocus` both `preventDefault()`.
- Focus on close: return it to the field the surface was *about* — after a coach mark, `descriptionEditorRef.current?.commands.focus('end')`, "so the user can start typing right where 'Got it' points them." After an autocomplete completes one field, move focus to the next field the user must fill.
- A modal that must be acknowledged sets `dismissOnBackdropClick={false}`; the backdrop then **shakes** the card rather than doing nothing silently. Note the cost in the PR (`Escape` no longer closes).
- Every overlay still needs a keyboard-reachable exit: a full-width `Got it` button, or a full-bleed `<button aria-label="Dismiss" className="absolute inset-0 cursor-default">`.

#### 4.3 Text inputs & editors

**Trigger:** `Enter` bound to submit inside a `<Textarea>`; a hardcoded `⌘` glyph; a global browser shortcut hijacked.
- **In a multi-line textarea, `Enter` stays a newline.** Bind submit to `⌘/Ctrl+Enter`, accepting **both** modifiers on both platforms — "Accepting Ctrl on a Mac costs nothing and covers external PC keyboards."
- Derive the modifier glyph from `useIsMacOS()`; never hardcode `⌘`.
- Put the shortcut hint **inside** the button it belongs to, absolutely positioned against the trailing edge, and **only once the action is enabled** — "a shortcut advertised against a disabled button does nothing when pressed."
- A form-level `Enter`-to-advance handler must bail when the target is a link or button: `if (e.target instanceof HTMLElement && e.target.closest('a,button')) return`.
- **Never hijack a global browser shortcut** (`⌘F`) for an in-page field — and delete the keycap chrome that existed only to justify it.
- Editor overrides fire **only on the exact matching selection**; any partial selection falls through to the default.
- When only one instance of a global hotkey may exist, give the other an explicit `enabled: !disableHotkey` opt-out and name the owner in a comment.

#### 4.4 Custom drag controls

**Trigger:** `onPointerDown`/`onMouseDown`-driven positioning on an element that is not a `<button>` and has no `onKeyDown`, or a slider-like control with no `role="slider"` + `aria-valuenow`.
A drag-only control is unusable without a pointer.
- A draggable marker is a real `<button>` with `←`/`→` nudging and a `shiftKey` coarse step.
- Full slider semantics: `role="slider"`, `aria-label`, `aria-valuemin/max/now`, and `aria-valuetext` where the raw number isn't the user-facing unit (`'40%'`). A 2-D area is `role="application"` with a label and a `focus-visible` ring.
- Row selection layered over the row's own focusable controls is driven by `onPointerDown` **and** `onFocusCapture` — don't nest a button in a button.
- Every state a pointer path exits, a keyboard path must exit too — clear suppression flags on `keyup` as well as `pointerup`.

---

### 5. Perceived performance

His model: **the paint never waits on React, and React never re-renders for something invisible.**

#### 5.1 Local echo / synchronous typing

**Trigger:** a controlled input whose `value` is a normalized/derived form of what the user typed, with no focused-draft state; an object with fresh identity per event stored in state or context; a live-preview CSS custom property written to `document.documentElement`; a measurement forcing sync reflow inside a per-keystroke handler (`getBoundingClientRect`, `offsetHeight`, `scrollHeight` in `onChange`/`onInput`).
- **A drag must not round-trip through React state to paint.** Have the updater *return* the computed value synchronously, fire the preview callback with it immediately, and schedule the state commit on `requestAnimationFrame` (one commit per frame, plus a `flushCommit()` on save). — `memo-663`
- **While dragging, the DOM position is the source of truth.** Guard the position-syncing effect with `isDraggingRef` so React state can't fight the pointer.
- **Focused draft state for any input whose committed value is normalized.** While focused, render exactly what was typed; commit only at a *complete* value (hex: length 3 or 6). "at `C70` the 3-digit shorthand validated and the commit rewrote the controlled input to the expanded 6-digit form, making characters 'appear from nowhere.'" Doubly required when the committed value also drives a live preview.
- **Sanitize at the `onChange` boundary** so typing and paste share one guard: `e.target.value.replace(/[^0-9a-fA-F]/g, '').slice(0, 6)`.
- **Type animations in chunks against a fixed time budget**, not one character per tick: `TICK_MS = 16`, `BUDGET_MS = 240`, `charsPerTick = ceil(len / maxTicks)`. "Each tick is a React state update on the full modal, so fewer, bigger ticks beat one char at a time."
- **Reveal generated text with one render of CSS-delayed word spans**, not per-tick re-renders that re-truncate the HTML.

#### 5.2 Never re-render for something invisible

**Trigger:** a controlled input whose `value` is a normalized/derived form of what the user typed, with no focused-draft state; an object with fresh identity per event stored in state or context; a live-preview CSS custom property written to `document.documentElement`; a measurement forcing sync reflow inside a per-keystroke handler (`getBoundingClientRect`, `offsetHeight`, `scrollHeight` in `onChange`/`onInput`).
- **Never store an object with a fresh identity per transaction in state or context** — track a stable primitive id. "typing produces a new node object on every transaction, and storing it in state re-rendered every context consumer per keystroke."
- **Delete the state rather than memoizing it** where nothing needs it: "the cheapest re-render is the one that never has a reason to happen."
- **Bail out inside the setter** when nothing *visible* changed — return `prev`. The equality check must cover **every rendered field**, or it silently swallows real updates.
- **Handlers on per-keystroke events bail before doing any work** unless the thing they care about actually changed.
- **Throttle (leading + trailing), never debounce-only**, any measurement that forces a synchronous reflow off a per-keystroke event — "so typing stays responsive on multi-page memos while the page still grows during sustained typing."
- **Never write a live-preview CSS custom property on `document.documentElement`** — an inherited custom property invalidates styles for the whole document. Scope the write to the consuming nodes and cache them. **Measured 57.9ms → 0.33ms per mousemove, ~175×.**
- **`React.memo` anything hosting a second heavy runtime instance** (a read-only editor per thumbnail).
- **A perf fix that removes a re-render cascade obliges you to re-subscribe everything that silently depended on it** — audit all consumers, don't wait for the bug report. Re-subscribe with a **deep-comparing selector** (`useEditorState`) so the win is preserved, and pull *everything* the component reads during render into that one selector, including values previously fetched by helpers called inline in JSX.

#### 5.3 Don't do work the user can't see
- **Don't mount or fetch for a closed dialog.** Gate the portal on `open` and thread an `enabled` flag into the data hook's `skip`.
- **Preview at the cheap fidelity; reserve the expensive one for the real action** when the difference is invisible on screen.
- **Move overlays with `transform: translate3d(...)`, not `top`/`left`.**
- **Pause a countdown whenever the user can't be reading it** — tab hidden, window blurred, card hovered, popover open. Both `visibilityState` **and** `hasFocus()`: "a visible-but-unfocused tab still isn't being read."
- **Drive auto-dismiss from the animation's `animationend`, never a parallel JS timer** — one clock, so the bar and the dismissal cannot drift.
- **Deferred mount for expensive content so the animation is actually seen:** `useDeferredValue(isExpanded)` — "mounting a table sanitizes and parses its HTML in that same commit, which blocks the paint, so on expand the browser only painted once the rotation was already finished." **Collapse stays synchronous.**

#### 5.4 Correctness under concurrency

**Trigger:** an unbounded `Promise.all` over user-supplied items; a debounced async search with no sequence guard; per-item timers in a single ref.
- **Guard debounced async searches with a request sequence number**, so a slow earlier query can't overwrite a newer one.
- **One dispatch per batch**, not one per item — a per-item add also re-ran the fit-to-bounds effect N times.
- **Cap concurrency on rate-limited APIs** (6) rather than an unbounded `Promise.all`, and return results in **input order** so items land in the order the user chose them.
- **Serialize mutually-destructive operations through one promise chain**, swallowing rejections on the chain so one failure doesn't reject everything queued behind it.
- **Per-item animation timers are keyed `Map`s that clear-and-replace**, never one shared timeout — "two rows resolving at once must not cancel each other's animation."
- **Scope per-drag state to the current drag and clear it on `dragend`/`drop`**, or a rapid second drag inherits it. Restore hidden DOM on document-level `dragend`, not `drop` — "`dragend` also fires for cancelled drags, where `drop` never does."
- **Navigate to the *resolved* final URL a preload discovered**, so the destination paints from cache instead of re-running the redirect chain.
- **Fix the stale cache so a create/upload flips the empty state immediately** — never require a refresh.

#### 5.5 Make the wait legible

**Trigger:** a re-sort/re-group triggered directly by a state change, with the row moving in the same frame the condition clears.
- **Hold a row in its old position briefly after it becomes ready** (`CONTACT_ASSIGNED_GROUP_HOLD_MS = 900`), then animate the move — "fixing the blocker re-sorts the table instantly, the row vanishes from where the user was looking and reappears elsewhere with no connection between the two."
- **Keep showing the last non-zero count while a bar animates out** — "rendering '0 selected' mid-exit is the artifact this pattern exists to prevent."
- **Never animate a half-assembled thing** — fire `onReady` after the images settle, then run the entrance.
- **A celebratory reveal needs a deliberate minimum dwell**, plus a **max hold** so a slow load never strands the user.
- **Show when the data was last checked**, and give an inline way to re-check without leaving.

---

### Applying this as a check

Run in this order — the first three are pure lint, the rest need a diff read:

1. `transition-all` → enumerate properties (I1).
2. Any `hover:` / `group-hover:` state with no `focus-visible` / `focus-within` / `pointer-coarse` mirror (I2, I3).
3. Any new animation with no `motion-reduce:` branch, and any reduced-motion branch that lands on the *start* state (I10).
4. Any `disabled` with no stated reason, and any `disabled` control that still has live hover classes (I15).
5. Any icon-only control with no `aria-label`, and any `<Label>` not wired by `htmlFor`/`useId` (I5–I7).
6. Any list with an active index that also carries a `hover:` class (I22).
7. Any one-shot entrance whose markup persists after settling (§3.5).
8. Any state that resets on reload but shouldn't (I38).

---

## Before → after

| # | Before | After | Source |
|---|---|---|---|
| 1 | `transition-all duration-200` | `transition-[color,background-color] duration-200` | bp2-5824 |
| 2 | `'… opacity-0 transition-opacity group-hover:opacity-100'` | `'pointer-events-none … opacity-0 transition-opacity group-hover:pointer-events-auto group-hover:opacity-100 group-[:has(:focus-visible)]:pointer-events-auto group-[:has(:focus-visible)]:opacity-100'` | bp2-5824 |
| 3 | `focus-visible:ring-2 focus-visible:ring-ring/50 … aria-invalid:ring-2` | `focus-visible:ring-3 focus-visible:ring-ring/50 … aria-invalid:ring-3` | bp2-nits |
| 4 | `'relative flex cursor-default select-none items-center gap-2 …'` | `'relative flex cursor-pointer select-none items-center gap-2 …'` | bp2-4894 |
| 5 | `'cursor-grab active:cursor-grabbing',` | `'cursor-pointer',` | memo-nits |
| 6 | `transition-transform duration-150 hover:scale-110 active:scale-125` | `cursor-grab active:cursor-grabbing` (no transform, no transition) | memo-663 |
| 7 | `[data-slot='slider-thumb']:active { cursor: grabbing; }` | `html[data-slider-dragging], html[data-slider-dragging] * { cursor: grabbing !important; }` | bp2-7228 |
| 8 | `aria-label="Remove document"` | `` aria-label={`Remove ${displayName}`} `` | bp2-6183 |
| 9 | `<label className="grid gap-2 text-sm">Address<Input …/></label>` | `const id = useId()` … `<Label htmlFor={id}>{label}</Label><Input id={id} …/>` | bp2-7219 |
| 10 | `<Tooltip content="No phone numbers registered"><Button disabled {...props} /></Tooltip>` | `<Tooltip asChild content="…"><span className="inline-flex"><Button disabled {...buttonProps} /></span></Tooltip>` | bp2-6715 |
| 11 | `<Popover.Content align="start" className="… group-focus-within:flex">` | same **+** `onOpenAutoFocus={(event) => event.preventDefault()}` | bp2-nits |
| 12 | `role="alert"` (unconditional) | `role={banner.isError ? 'alert' : 'status'}` | bp2-7225 |
| 13 | `'flex w-full items-center gap-3 rounded-lg px-3 py-2 text-left hover:bg-foreground/5'` | `cn('flex w-full items-center gap-3 rounded-lg px-3 py-2 text-left', isActive && 'bg-foreground/5')` | bp2-7377 |
| 14 | `className="... hover:bg-foreground/5"` (CSS hover) | `onMouseMove={() => setActiveIndex(index)}` | bp2-7377 |
| 15 | `if (results.length && (event.key === 'Home' \|\| event.key === 'End')) { … }` | branch deleted — "Deliberately no Home/End." | bp2-7377 |
| 16 | `<p className="truncate text-sm font-medium text-foreground underline-offset-3 group-hover/deal-row:underline">` | `<p className="truncate text-sm font-medium text-foreground">` | bp2-6530 |
| 17 | `group-hover:animate-bubble-swap` (keyframe) | `transition-transform duration-300 ease-out group-hover:scale-110 group-hover:rotate-3` | bp2-7007 |
| 18 | `'… motion-safe:animate-in motion-safe:duration-200 motion-safe:fade-in-0 motion-safe:slide-in-from-top-1'` | `<AnimatePresence initial={false}><motion.section initial={{opacity:0,scale:0.98,y:-4}} animate={{opacity:1,scale:1,y:0}} exit={{opacity:0,scale:0.98,y:-4}} transition={{duration:0.18, ease:[0.16,1,0.3,1]}}>` | bp2-6530 |
| 19 | `isUnlockMode \|\| showLaunchReceipt ? 'sm:max-w-4xl' : 'sm:max-w-lg'` | `'sm:max-w-none sm:transition-[width] sm:duration-200 sm:ease-out motion-reduce:sm:transition-none'` + `'sm:w-[min(calc(100vw-2rem),var(--bulk-unlock-dialog-width))]'` | bp2-6636 |
| 20 | `showReceipt && 'sm:grid-cols-[minmax(0,1fr)_minmax(18rem,22rem)]'` | `hasReceiptChoice && 'sm:grid-cols-[minmax(0,1fr)_minmax(0,var(--bulk-launch-receipt-width))] sm:transition-[grid-template-columns] …'` | bp2-6636 |
| 21 | `setSettledPitchHtml(revealHtml)` | `setSettledPitchHtml(settlePitchFloatInHtml(revealHtml))` — removes `animate-pitch-float-in` + `animation-delay`, keeps the spans | bp2-7161 |
| 22 | `let tourDismissedThisSession = false` (module scope) | `const [pitchIntroSeen, setPitchIntroSeen] = useCookieState(PITCH_INTRO_COOKIE)` with `expires: 365` | bp2-7161 |
| 23 | `} else if (storedSidebarState === undefined) { setOpen(true) }` | `} else { setOpen(storedSidebarOpen ?? true) }` | bp2-6460 |
| 24 | `<Switch checked={allExtractionOn} size="sm" onCheckedChange={onToggleAll} />` | `checked={priceableFileCount === 0 ? false : allExtractionOn ? true : enabledFileCount > 0 ? 'indeterminate' : false}` on a `<Checkbox>` | bp2-6183 |
| 25 | `includeInExtraction: doc.includeInExtraction ?? false` | `includeInExtraction: factExtractionEnabled && (doc.includeInExtraction ?? false)` | bp2-6457 |
| 26 | `if (disabled \|\| isLoading \|\| isSubmitting) return` | `if (disabled \|\| isLoading \|\| isSubmitting \|\| !prompt.trim()) return` | bp2-7031 |
| 27 | `existingMode: 'keep'` | `existingMode: null` + `{hasAnsweredExisting && (<Button type="submit">…)}` | bp2-7558 |
| 28 | `value={hexValue.replace(/^#/, '')}` | `value={hexDraft ?? hexValue.replace(/^#/, '')}` with `onFocus`/`onBlur` draft | memo-664 |
| 29 | `e.target.value.replace(/^#/, '')` | `e.target.value.replace(/[^0-9a-fA-F]/g, '').slice(0, 6)` | memo-664 |
| 30 | `const [selectedNode, setSelectedNode] = useState<ProseMirrorNode \| null>(null)` | `const [currentPageId, setCurrentPageId] = useState<string \| null>(null)` | memo-667 |
| 31 | `setElementColorPreviews((prev) => ({ ...prev, [elementId]: color }))` (var on `documentElement`) | cached `elementPreviewNodesRef` + `node.style.setProperty(...)` per consuming node | memo-663 |
| 32 | `updateSaturationBrightness(s, b)` (void) + `useEffect` → callback | `const nextColor = updateSaturationBrightness(s, b); onColorChangeRef.current?.(nextColor)` + rAF commit | memo-663 |
| 33 | `(predictions ?? []).slice(0, resultLimit).map(...)` | `setResults([...mapped].sort(byDistance).slice(0, resultLimit))` | bp2-7222 |
| 34 | `const observer = new MutationObserver(update); observer.observe(document.body, { childList: true, subtree: true })` | on-demand `querySelectorAll` + `aria-hidden !== 'true' && rect.width > 0 && rect.height > 0` | bp2-6434 |
| 35 | `window.setTimeout(typeNextCharacter, 10)` | `TICK_MS = 16`, `BUDGET_MS = 240`, `charsPerTick = Math.ceil(len / maxTicks)` | memo-783 |
| 36 | `const [isExpanded, setIsExpanded] = useState(true)` … `{isExpanded && …}` | `const deferredExpanded = useDeferredValue(isExpanded)` … `{isExpanded && deferredExpanded && …}` | bp2-7706 |
| 37 | `'relative flex … px-1 py-1.5 hover:border-border hover:bg-muted'` (+ `-my-2` on the `<li>`) | `'relative isolate -mx-2 … before:absolute before:inset-x-0 before:-inset-y-1 … hover:z-10 hover:before:border-border hover:before:bg-muted'` | bp2-6530 |
| 38 | `hover:z-10` on a list-row hover plate | `hover:z-[1]` | bp2-6535 |
| 39 | `selectedLibraryColor?.id === color.id ? 'ring' : 'border-border hover:ring'` | `<Check className={cn('size-4', isLightColor(color) ? 'text-foreground' : 'text-white')} strokeWidth={3} />` on the swatch | memo-663 |
| 40 | `'group-hover/table-row:bg-accent … group-data-[selected]/table-row:bg-accent …'` | `'… group-data-[selected]/table-row:bg-muted/50 first:group-data-[selected]/table-row:shadow-[inset_3px_0_0_0_var(--foreground)]'` | bp2-6549 |
| 41 | `const isSelected = obsId === observationId` (`observationId` null in prod) | `matches.length === 1 ? Number(matches[0]!.id) : null` + `hasSelection && <Check … />` | bp2-7711 |
| 42 | `useEffect(measureEdges, [activeObservationId, open])` | `el.scrollTop = 0; el.scrollLeft = 0` then `measureEdges()` | bp2-7724 |
| 43 | `<Popover open={open} onOpenChange={setOpen}>` | `onOpenChange={(next) => { setOpen(next); if (!next) setActiveIndex(-1) }}` | bp2-7377 |
| 44 | `const handleKeyDown = (e) => { if (e.key === 'Enter') { e.preventDefault(); handleNext(formik) } }` | `if (e.key !== 'Enter') return; if (e.target instanceof HTMLElement && e.target.closest('a,button')) return; …` | bp2-6056 |
| 45 | `useHotkeys(['ctrl+f','meta+f'], (e) => { e.preventDefault(); inputRef.current?.focus() })` + keycap chrome | all removed | memo-635 |
| 46 | `filter: blur(0)` inside a `both`/`forwards` animation | blur split into its own non-filling `lev-sparkle-blur-out`/`-in` | bp2-nits |
| 47 | `@keyframes` sweeping `background-position` `-60% → 160%`, `ease-in-out` | `@keyframes lev-shimmer { to { transform: translateX(100%); } }`, `1.4s linear infinite` | bp2-7343 |
| 48 | single `transition={{ duration: 0.28, ease: REPORT_EASE }}` | `REPORT_ENTER_DURATION = 0.28` / `REPORT_EXIT_DURATION = 0.42`, nested per phase | bp2-6668 |
| 49 | `transition={{ duration: 0.15 }}` | `transition={{ duration: 0.15, ease: [0.23, 1, 0.32, 1] }}` | bp2-6804 |
| 50 | `<AnchoredSettingsPanel heading={…} location={selectedPin.location}>` | `<AnchoredSettingsPanel key={selectedPin.id} …>` | bp2-7317 |
| 51 | `const [focused, setFocused] = useState(false); const open = focused && query.trim().length > 0` | `const [open, setOpen] = useState(false)` with `setOpen(true)` in **both** `onMouseDown` and `onFocus` | bp2-7317 |
| 52 | `<CollapsibleContent asChild forceMount><div className="grid … transition-[grid-template-rows,opacity] …">` + 2 effects, 2 rAFs, a 200ms timeout, an `onTransitionEnd` | `<AnimatePresence initial={false}>{open && <motion.div initial={{height:0,…}} animate={{height:'auto',…}} exit={{height:0,…}} transition={{duration:0.24, ease:[0.22,1,0.36,1]}}>}` (−66 lines) | bp2-7706 |
| 53 | `<SidebarAnimatedCollapsibleContent open={isExpanded}>` (bare div) | `<CollapsibleContent asChild forceMount><div aria-hidden={!open} …>` — "I measured 10 of 10 triggers with `aria-controls` pointing at a nonexistent id." | bp2-7679 |
| 54 | `animate={{ filter: 'blur(1px)', scale: isVisible ? 1 : 0.985, y: isVisible ? 0 : -6 }}` on list rows | `<div className="pt-0.5">` | bp2-7679 |
| 55 | `const [isInfoPanelOpen, setIsInfoPanelOpen] = useState(false)` in `PhotoLibrary`, passed to every card | the same state **inside** `PhotoCard`; both props deleted | bp2-7513 |
| 56 | `<Button variant="outline" onClick={() => handleClose(false)} disabled={isBusy}>` | `<Button variant="outline" onClick={() => handleClose(false)}>` | memo-613 |
| 57 | `console.log('🚀 ~ ColorSelector ~ designLibrary:', designLibrary)` | (removed) | memo-663 |

---

## Merged out

_(pending — the editor fills this in)_
