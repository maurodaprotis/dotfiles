# VISUAL — Ethanize ruleset

Domain: `spacing`, `radius`, `border`, `shadow`, `color-token`, `typography`, `icon`, `density`.
Source: ~302 visual rules extracted from all 84 findings files (`bp2-*`, `memo-*`, `ethan-review-comments`, `ethan-own-pr-replies`, `ethan-voice-and-principles`).
Repos: `bp2` = `levco/borrower-portal-v2` (Airy/shadcn, Tailwind v4), `memo` = `levco/memo`.

> Cross-checked against `REPO_CONVENTIONS.md` (§7 tokens, §3 `agents/tailwind-4.md`, §4 `agents/shadcn-ui.md`).
> Where the repo's own docs already state a rule, **cite them, don't restate**: `agents/tailwind-4.md`
> owns `border`-without-`border-border`, the 12px font floor, the no-arbitrary-`text-[Npx]` rule, and
> the z-index tokens; `airy-rules/design-system-rules.md` owns protected paths and semantic-tokens-only.
> Everything below is the part those docs *don't* cover — or where his practice is narrower than the doc.

**Real token vocabulary** (from `REPO_CONVENTIONS.md` §7):
- Shadcn families: `background foreground card popover primary secondary muted accent destructive success border input ring chart-1..5 sidebar{,-primary,-accent,-border,-ring}` (each with its `-foreground` where one exists), plus `cta` / `cta-hover`.
- **Semantic trios** — each has `-foreground` / `-background` / `-border`: `banner-default-*`, `info-*`, `ai-*`, `warning-*`, `levender-*`, `success-*`, `error-*`.
- `--radius: 0.625rem` (10px) → `rounded-sm` **6px**, `rounded-md` **8px**, `rounded-lg` **10px**, `rounded-xl` **14px**, `2xl` 18px, `3xl` 22px, `4xl` 26px, `full` 9999px.
- Text scale `text-3xs`(9) `text-2xs`(10) `text-xs`(12) `text-sm`(14) `text-base`(16) `text-lg`(18) `text-xl`(20) `text-2xl`(24) `text-3xl`(30). **`text-2xs`/`text-3xs` are off-limits** — `agents/tailwind-4.md` rule 6 sets a 12px floor.
- Shadow scale `shadow-2xs xs sm md lg xl 2xl`.
- `--font-sans` IBM Plex Sans · `--font-mono` IBM Plex Mono · `--font-handwriting` Caveat.
- Theme `--space-*` steps: 0,1,2,3,4,5,6,8,10,12,16,20,24 — **no 7, 9, 11, 14**. Tailwind's `.5` half-steps (`gap-1.5`, `p-3.5`, `py-2.5`) are used freely.
- z-index: `--z-sticky` 20 · `--z-floating` 30 · `--z-panel` 40 · `--z-overlay/modal/popover/tooltip` 50 · `--z-chat` 60 · `--z-chat-overlay`/`--z-sidebar-nav` 70 · `--z-external` 1000.
- Utility classes: `.surface-glass` (24 hits — the most-used non-token helper; hooks `--glass-tint`, `--glass-blur`, `--glass-saturation`), `.surface-ai`, `.border-beam(-hover)`, `.lev-shimmer`, `.gradient-ai-text`.
- memo-only: `bg-design-canvas` (`--design-canvas-background`), `--primitive-{neutral,deep-abyss,emerald}-*`.
- `--error-*` **does exist** as a registered trio — but bp2#6363 migrated *failure/destructive* styling off it onto `destructive`. Use `destructive` for failures; leave existing `error-*` banners alone.
- **`levender` is an intentional misspelling of the brand colour** — *"I'm being cheeky with our brand colors"*. Never "correct" it to `purple`/`lavender`.

---

## Rules — autofixable

Tag `auto`: a grep-able detection plus an exact replacement — apply silently.

### V1 — Square boxes use `size-*`
- **Detect:** `\bw-(\d+(?:\.\d+)?|\[[^\]]+\])\s+h-\1\b` · `\bh-(\d+(?:\.\d+)?|\[[^\]]+\])\s+w-\1\b`
- **Fix:** `size-$1`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#664 `w-8 h-8` → `size-8`. Also drop inline `style={{ width: '2rem' }}` → `w-8` (bp2#5824).

### V2 — Off-scale font sizes and paddings
- **Detect:** `text-\[\d+px\]` · `p[xytblr]?-\[\d+px\]` · `text-2xs` / `text-3xs`
- **Fix:** snap to the nearest scale class — `text-[13px]|text-[15px]→text-sm`, `text-[17px]→text-base`, `p-[8px]→p-2`; `text-2xs`/`text-3xs` → `text-xs`
- **Except:** hard rule in **bp2**. In **memo**, `text-[11px]` is his own established panel-chrome value (memo#668) — leave it. See V58 / C8.
- **Tag:** auto
- **Evidence:** `agents/tailwind-4.md` rules 6 and 8 (**12px floor**, never arbitrary `text-[Npx]`); bp2#6056 `text-[13px]` → `text-sm`.

### V5 — Redundant `border-border` (bp2 only)
- **Detect:** `\bborder(-[trblxy])?(?=\s)(?![-\w])[^"']*?\bborder-border\b` — practically: `border` (or `border-t/-b/-l/-r/-x/-y`) and a bare `border-border` in the same class string
- **Fix:** delete `border-border`
- **Except:** *"unless the color/opacity intentionally differs"* — never strip `border-border/70`, `border-destructive/20`, or an arbitrary variant like `[&_td]:border-border`. · `bp2` only. `memo` writes `border-border` explicitly (39 after-side hits).
- **Tag:** auto
- **Evidence:** `agents/tailwind-4.md` § Theme Token Ownership and project `CLAUDE.md`, verbatim: *"use structural `border`/`border-b`/`border-t` without `border-border`"*. Confirmed in practice: bp2#6530 `border-t border-info-border bg-neutral-50` → `border-t bg-muted`; bp2#6620 `border border-dashed` → `border`.

### V6 — Overflow menu glyph is horizontal
- **Detect:** `\b(MoreVertical|EllipsisVertical)\b`
- **Fix:** `MoreHorizontal` (bp2 lucide) / `Ellipsis` (bp2#6668 chart panels); render at `size={16}`; align the content `start`
- **Except:** bp2#6549 keeps a `triggerIcon?: 'horizontal' | 'vertical'` prop defaulting to `'horizontal'` — an explicit `triggerIcon="vertical"` is intentional.
- **Tag:** auto
- **Evidence:** bp2#6548 (`MoreVertical`/`EllipsisVertical` → `MoreHorizontal`, `size={16}`), bp2#6668 (`EllipsisVertical` → `Ellipsis`, `align="end"` → `align="start"`).

### V7 — Plainer lucide glyph over its `2` variant
- **Detect:** `\b(Undo2|Redo2|FilePlus2)\b`
- **Fix:** `Undo` / `Redo` / `Plus`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo-nits (`Undo2`/`Redo2` → `Undo`/`Redo`), bp2#6399 (`FilePlus2` → `Plus`, *"Reuse the same 'add' glyph for every create action"*).

### V11 — `success` fill uses `--success`, not `--success-foreground`
- **Detect:** `(text-success-foreground|var\(--success-foreground\))` used as a **fill/icon colour**
- **Fix:** `text-success` / `var(--success)`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6668, verbatim rule.

### V14 — One hover surface: `bg-muted`
- **Detect:** `hover:bg-accent/\d+` · `bg-accent/50` · the pair `isActive ? 'bg-accent …' : '… hover:bg-accent/50'`
- **Fix:** `hover:bg-muted` (+ `dark:hover:bg-muted/50`); selected → `bg-muted font-medium text-foreground`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7711 — *"`bg-accent/50` and `bg-accent` — 5% vs 10% black washes, close enough to look accidental."* Confirmed as current in memo#776 (`hover:bg-muted … dark:hover:bg-muted/50`, `data-[state=active]:bg-muted`). **See C1 for the conflict with the token-semantics rule.**

### V16 — Opacity-modified foreground → `muted-foreground`
- **Detect:** `text-(sidebar-)?foreground/\d+`
- **Fix:** `text-muted-foreground` (keep the `!` if one was there)
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6399 — `text-sidebar-foreground/80|/70|/70!` → `text-muted-foreground(!)`.

### V19 — Icon size follows the control and the text
- **Detect:** `size=\{20\}` (or `size-5`) inside a `size="sm"` button or dropdown item · `size-4` immediately beside `text-xs`
- **Fix:** `size={16}` / `size-4` · `size-3.5`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7007 (`<CloudUpload size={20} />` → `<Upload size={16} />`), bp2#6520 (`<Plus className="size-4 shrink-0" />` → `size-3.5`).

### V21 — Slider/gradient tracks: inset ring, not border + inner shadow
- **Detect:** `border border-gray-\d+ shadow-inner` on a track · `shadow-inner` on any gradient element
- **Fix:** `ring-1 ring-inset ring-black/10` (and `h-2 rounded` → `h-3 rounded-full`)
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#663 — a border eats a pixel of the gradient, `shadow-inner` muddies the hue.

### V22 — Image hairlines use `outline`, never an inset shadow or `ring-inset`
- **Trigger:** `shadow-[inset_0_0_0_1px…]` or `ring-1 ring-inset` on an `<img>`, `<canvas>`, `<video>`, or an element with `object-contain`/`object-cover`.
- **Detect:** `shadow-\[inset_0_0_0_1px_var\(--border\)\]` · `ring-1 ring-inset` on an `<img>`/preview/replaced element
- **Fix:** `outline-1 -outline-offset-1 outline-[var(--border)]` (bp2 pane variant: `outline-1 -outline-offset-1 outline-foreground/20`)
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#783 — *"an inset shadow paints beneath replaced content, so the bitmap covers it. Outline paints above content and follows the radius."* bp2#7343 same conclusion for a preview on a `bg-muted` pane.

### V24 — Small square avatars/boxes are `rounded-sm`
- **Detect:** `rounded-md` on `size-4` / `size-5` · `rounded-lg` on `size-5` / `size-8`
- **Fix:** `size-4|5 → rounded-sm` · `size-5 → rounded-sm`, `size-8 → rounded-md`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6668 (`!size-4 rounded-md` → `rounded-sm`), bp2#7031 (`xs: 'size-5 rounded-lg'` → `rounded-sm`; `sm: 'size-8 rounded-lg'` → `rounded-md`) — *"A fixed-pixel radius token becomes a circle at small sizes."*

### V25 — Dialog scrim
- **Detect:** `bg-black/10` on an overlay · `backdrop-blur` / `supports-backdrop-filter:backdrop-blur-xs` on a scrim or a sticky table header
- **Fix:** `bg-black/30 dark:bg-black/50`; delete the blur
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2-nits (scrim), bp2#6715 (*"Sticky headers are fully opaque … No translucency, no `backdrop-blur`."*).

### V27 — Table body cells align middle; number/date columns align left
- **Trigger:** `align-top` on a `TableCell`, or a ternary that picks alignment per column; or `text-right`/`ml-auto` in a numeric or date column's header, skeleton, or cell.
- **Detect:** `align-top` on body cells · `text-right` on a date/number column header, cell, or its `Skeleton` (`ml-auto`)
- **Fix:** `align-middle` · drop `text-right` and `ml-auto`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6824 (both).

### V28 — Error rows: destructive on the icon only
- **Detect:** `text-destructive` on the `<p>`/row that also contains an `AlertTriangle`
- **Fix:** row → `text-foreground`; icon → `text-destructive` (`mt-0.5 size-3.5 shrink-0`)
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6620, verbatim.

### V32 — A hover-revealed border needs a transparent border at rest
- **Detect:** `hover:border-border` with no `border-transparent` in the same string
- **Fix:** add `border border-transparent` (+ `transition-colors`) and the compensating `-mx-2 -my-1 px-2 py-1`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7031, verbatim rule.

### V33 — Icon + text metadata rows are `gap-2`
- **Detect:** `items-center gap-1` on a row whose children are an icon and a text label
- **Fix:** `gap-2`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2-nits (four call sites), bp2#7679 (sidebar rows `gap-1` → `gap-2`).

### V34 — Hex/monospace inputs drop `font-mono`
- **Detect:** `font-mono` on a hex/opacity picker input
- **Fix:** remove (keep `text-sm`)
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#663 (`text-sm font-mono border-border focus:border-border focus:ring-0` → `w-full min-w-0 bg-transparent text-sm outline-none`). — - **inverse, do not strip:** `font-mono tabular-nums` on **chart values** (bp2#6668) and on **cited/stored data cells** (memo#790) is deliberate.

### V35 — Numeric readouts that stack get `tabular-nums`
- **Detect:** a `text-xs`/`text-sm` span rendering a count, dimension, `N of M`, or a slider value without `tabular-nums`
- **Fix:** add `tabular-nums`; for a slider readout also `w-9 text-right`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7724, bp2#6549, bp2#7228, memo#673.

### V40 — Delete stray debug and dead flexibility
- **Detect:** `console\.log\(` · a component prop with no remaining caller
- **Fix:** delete
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#663 (`console.log('🚀 ~ ColorSelector …')`), bp2#7317 (*"Delete a component prop once its last caller is gone rather than leaving it as dead flexibility."*).

### V41 — The elevation ramp is one step lower than you think ★
- **Detect:** `shadow-sm` at rest on a small control · `hover:shadow-md` on a small control
- **Fix:** `shadow-xs` at rest · `hover:shadow-sm`
- **Except:** —
- **Tag:** auto
- **Evidence:** `ethan-review-comments.md` — verbatim, two comments on the same line of someone else's PR: *"can you swap shadow-sm to shadow-xs?"* and *"and hover:shadow-md -> hover:shadow-sm"*. **This is the only styling change he ever asked another engineer for in either repo**, which makes it the single most literal statement of his taste in the whole corpus. Treat it as the highest-authority visual rule here.

### V42 — Refresh spins clockwise
- **Detect:** `\bRefreshCcw\b`
- **Fix:** `RefreshCw` (and pair with `animate-spin` only while pending)
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#613 — `animate-spin` rotates clockwise, so a counter-clockwise glyph reads as spinning backwards.

### V44 — A scoped `.dark` subtree must re-declare `text-foreground`
- **Detect:** a `dark` class applied to a subtree (`cn('dark', …)`) with no `text-foreground` in the same class string
- **Fix:** add `text-foreground` alongside `dark`
- **Except:** —
- **Tag:** auto
- **Evidence:** `ethan-review-comments.md`, verbatim mechanism: *"`body` sets `color: var(--foreground)`, which resolves once at the body, and `color` then inherits as a **computed** value — descendants inside a nested `.dark` never re-evaluate the variable. Backgrounds re-resolve because `bg-background` sits on the element itself."* Measured result of the bug: `oklch(0.2046 0 0)` text on `oklab(0.2068 …)` — *"effectively black on near-black."*

### V45 — Popover/panel max-height comes from the Radix available-height var
- **Trigger:** a fixed `max-h-[\d+px]`/`max-h-\d+` on a `PopoverContent`, `DropdownMenuContent`, or `SelectContent`.
- **Detect:** `max-h-\[\d+px\]` or `max-h-\[\d+vh\]` on a `PopoverContent` / panel scroll region
- **Fix:** `max-h-(--radix-popover-content-available-height)`, or `max-h-[min(<cap>,var(--radix-popover-content-available-height))]` when an upper bound is wanted; add `overscroll-contain`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#668 (`max-h-(--radix-popover-content-available-height) overflow-y-auto overscroll-contain`), memo#635 (`max-h-[500px]` → `max-h-[min(660px,var(--radix-popover-content-available-height))]` — *"lets the picker use a tall window and still fit a short one; the `min()` keeps it from becoming unwieldy"*).

### V46 — Never "fix" `levender`
- **Detect:** an edit renaming `levender-*` → `lavender-*` / `purple-*`, or `bg-secondary text-secondary-foreground` standing in for the brand tint
- **Fix:** `bg-levender-background text-levender-foreground`
- **Except:** —
- **Tag:** auto
- **Evidence:** `ethan-review-comments.md`, verbatim: *"levender is an intentional misspelling 😆 I'm being cheeky with our brand colors."*

### V48 — A supporting glyph sits well below the text it annotates
- **Detect:** `size-3.5`/`size-4` on a glyph that is punctuation beside a `text-xs` numeral
- **Fix:** `size-2.5`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#619 (`<ArrowDown className="size-2.5 text-muted-foreground" />` beside `text-xs` digits) — *"so it reads as punctuation, not a second element."*

---

## Rules — judgment

Tag `ask`: the detection is reliable but the replacement needs a product/design decision, so propose options. Tag `flag`: report it, don't edit — it cannot be resolved without seeing the running app.

### V3 — Raw palette greys → tokens
- **Detect:** `\b(text|bg|border|fill|stroke|ring|outline|divide)-(gray|slate|zinc|stone)-\d{2,3}\b`
- **Fix:** `bg-gray-50|100 → bg-muted` · `bg-white → bg-background` · `text-gray-*/border-gray-* → text-muted-foreground` / `border-border`
- **Except:** deliberate over-map / over-photo overlays keep literal greys and flip on `isDark` (bp2#7343). Do not autofix inside a map/deck.gl overlay file.
- **Tag:** ask
- **Evidence:** bp2-nits (mapbox chrome) `bg-gray-100`→`bg-accent`, `bg-white hover:bg-gray-50`→`bg-background hover:bg-muted dark:bg-card dark:hover:bg-accent`; memo#665 dropped `bg-white` from a shared surface *"so it inherits the themed popover background"*; memo#674 deleted a 5-entry hardcoded-hex `previewTones` table for `bg-neutral-200/100`.

### V4 — Named-color icons → tokens
- **Detect:** `text-(red|green|blue|emerald|amber|yellow)-\d{3}` on an icon
- **Fix:** `text-destructive` / `text-success` / `text-muted-foreground`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6072 deleted a local file-icon switch using `text-green-600` / `text-red-500` in favour of `<FileTypeIcon />`.

### V8 — Switcher affordance is `ChevronsUpDown`
- **Detect:** `ChevronDown` inside a component that *selects among values* (a source/deal/value switcher), not a disclosure
- **Fix:** `ChevronsUpDown`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7711 — *"`ChevronsUpDown` is the switcher affordance now"*. `ChevronDown` stays correct as a **dropdown-trigger trailing chevron** (`ml-1`, `size={16}` — bp2#7007) and for disclosure.

### V9 — Sticky/layer z-index uses the shared token
- **Detect:** `\bz-(10|20|30|40|50)\b` on `sticky` chrome
- **Fix:** `z-[var(--z-sticky)]` (panels `--z-panel`, popovers `--z-popover`, modals `--z-modal`, tooltips `--z-tooltip`)
- **Except:** that table permits raw values **under 20** inside an isolated component or a table's own stacking context. Only autofix page-level sticky/floating chrome, and never add a z-index to a primitive that already bakes in the right layer.
- **Tag:** ask
- **Evidence:** bp2#6715 `z-10` → `z-[var(--z-sticky)]`; token table in `agents/tailwind-4.md`.

### V10 — Failure states use `destructive`, not the `error-*` trio
- **Detect:** `\b(text|bg|border)-error-(foreground|background|border)\b` on a *failure / insufficient / blocked* state
- **Fix:** `text-destructive` · `bg-destructive/10` · `border-destructive/20`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6363 `text-error-foreground` → `text-destructive`, `bg-error-background` → `bg-destructive/10`. — `error-*` **is** a registered trio in `airy.css` — this is a semantics fix, not a dead-token cleanup. Leave an existing `error-*` *banner* alone; only migrate destructive/insufficient styling.

### V12 — A `*-foreground` token is never white/black
- **Detect:** `--\w+-foreground:\s*(#fff(fff)?|#000(000)?|white|black)\s*;`
- **Fix:** the tinted ink value for that state (bp2-nits restored `--warning-foreground: #b57b24` light / `#eec785` dark; bp2#4894 flipped `--success-foreground` from `#ffffff` to `#107435`)
- **Except:** —
- **Tag:** ask
- **Evidence:** *"A `*-foreground` token is the readable ink for that state, not white."* Pair it with a `*-background`, never an alpha on the solid token (`bg-warning/90` → `bg-warning-background`).

### V13 — Never style a semantic surface from a chart token
- **Detect:** `\b(bg|text|border)-chart-[1-5](/\d+)?\b` outside a chart/legend component
- **Fix:** the matching semantic trio (`bg-warning-background` / `text-warning-foreground`)
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2-nits, verbatim rule.

### V15 — Section heads are sentence case on `bg-muted`
- **Detect:** `uppercase` together with `tracking-wide(r)?` on a `text-xs font-semibold text-muted-foreground` head; and `bg-foreground/5` on that head
- **Fix:** drop `uppercase` and `tracking-wider`; `bg-foreground/5` → `bg-muted`; sentence-case the label
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7711 (`bg-foreground/5 py-3 text-xs font-semibold tracking-wider text-muted-foreground uppercase` → `bg-muted py-3 text-xs font-semibold text-muted-foreground`, applied in **both** `KeyValueMetrics` and `FaqDashboard`), bp2#7679 (sidebar headers → `text-xs font-medium text-muted-foreground`, sentence case). — Paired fix: removing `uppercase` exposes casing bugs (`faq` → "Faq"). Add the lowercase-acronym map (`FAQ NOI DSCR LTV LTC ARV IRR ROI REIT GLA PSF CAM LIHTC`, `sqft→sq ft`) rather than reinstating `uppercase`.

### V17 — `transition-all` is banned
- **Detect:** `\btransition-all\b`
- **Fix:** enumerate: `transition-colors` / `transition-transform` / `transition-opacity` / `transition-[grid-template-rows,opacity]`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#5824 — *"so a layout property can't be animated by accident."*

### V18 — Separators are solid, individual, and vertically centered
- **Detect:** `divide-x` (+ `divide-dashed`) on a flex row · `border-l border-dashed` on a separator · `border border-dashed` on a bar
- **Fix:** `<div aria-hidden className="h-5 shrink-0 self-center border-l" />` per gap; bar → `border`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6548 introduced the dashed form; **bp2#6620 reverts it to solid.** 6620 is later → solid wins (see C2).

### V20 — Sidebar icons are one size, forced
- **Detect:** per-call-site `size-3` / `size-4` / `size={16}` on sidebar nav glyphs
- **Fix:** the shared constant at `size-3.5`, applied with `!` — `[&>svg:first-child]:size-3.5!`, `[&>svg]:size-3.5!`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6399, verbatim.

### V23 — A swatch/thumbnail border is an overlay painted after the fill
- **Detect:** `overflow-hidden` + `border` on a wrapper whose child is `absolute inset-0` (or `object-cover`)
- **Fix:** move the border to a sibling **after** the fill: `<div className="pointer-events-none absolute inset-0 rounded-sm border border-border" />`
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#664 + memo#663 (identical comment: *"Painted after the fill (in DOM order) so it always sits on top instead of being covered by it"*), memo#667 (image thumbnail), bp2#7679 (`::after` variant: `after:absolute after:inset-0 after:rounded-sm after:border after:border-border/70 after:mix-blend-darken dark:after:mix-blend-lighten`, because *"border-box shrinks a 16px image to 14px"*).

### V26 — Sticky header divider is an inset cell shadow
- **Detect:** a `sticky top-0` `thead` whose `tr` carries `border-b`
- **Fix:** `[&_th]:bg-background [&_th]:shadow-[inset_0_-1px_0_0_var(--border)] [&_tr]:border-b-0`
- **Except:** this is a descendant selector into a `ui/` primitive, which `agents/shadcn-ui.md` rule 10 forbids in general. It is sanctioned here because it is passed *in* as `className` on the `Table`'s own `thead`, not written inside `src/components/ui/`. Do not generalise it into deeper `[&_x]` hacks on protected primitives.
- **Tag:** ask
- **Evidence:** bp2#6715.

### V29 — Chart constants
- **Detect:** `radius=\{(4|\[4, ?4, ?0, ?0\])\}` inline · `maxBarSize=\{(2[3-9]|[3-9]\d)\}` · `stroke-border/50` on gridlines
- **Fix:** `CHART_BAR_RADIUS = 4` constant (with `radius={0}` on segments + one rounded clip path over the stack) · `CHART_BAR_MAX_SIZE = 22` + `barCategoryGap="34%"` · `stroke-border`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6668.

### V30 — Delete hand-tuned overrides of a sized primitive
- **Detect:** `className` on a `<Button>`/`<InputGroup>` containing `h-7` together with `text-xs`/`gap-1.5` while a `size` prop is already set
- **Fix:** delete the overrides, keep/raise the `size` prop (`h-7` search field → `h-8`; icons back to default)
- **Except:** memo's panel chrome deliberately hand-sets `h-7 … text-[11px]` (memo#668) — see V58.
- **Tag:** ask
- **Evidence:** bp2#6072 (`<CreateMemoButton className="h-7 gap-1.5 text-xs" size="sm" />` → `<CreateMemoButton size="sm" />`).

### V31 — Do not ghost a form control
- **Trigger:** `border-0`, `bg-transparent`, `shadow-none`, or `focus-visible:ring-0` on an `<Input>`, `<Textarea>`, `<Select>`, or `<SelectTrigger>`.
- **Detect:** `border-0` + `bg-transparent` + `shadow-none` on an `Input`/`Textarea`
- **Fix:** strip all three (and the `hover:bg-muted/50 focus-visible:bg-muted/50 focus-visible:ring-0 dark:bg-transparent …` train), keep only sizing/typography
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7513 — *"users read the value as static text."* (Distinct from bp2#7031, where a *dialog* input is borderless at rest but reveals `hover:border-border` from a `border border-transparent` base — that is the sanctioned form.)

### V36 — Never inline SVG for an icon that exists in the icon set
- **Detect:** a component file whose body is `<path d="…">` markup, or `lucide-react` imports in a Hugeicons surface
- **Fix:** `import { XIcon } from '@hugeicons-pro/core-stroke-rounded'` + `<HugeiconsIcon className="size-4" icon={XIcon} />`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7679 (deleted 252 lines of inlined Hugeicons artwork). Stroke variants, never duotone. Sanctioned lucide holdout in that surface: the collapse `ChevronRight`.

### V37 — Text-initial toggles → real icons
- **Detect:** `\{[\w.?]+\?\.\[0\]` / `name?.[0]` rendered as a toggle label
- **Fix:** an `icon` field on the option and `<option.icon size={14} />`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2-nits (`"L"`/`"S"` → `Map` / `Earth`).

### V38 — File-kind glyphs route through the shared component
- **Detect:** a local `if (ext === 'pdf') return <FileText …>` switch · a hand-composed branded badge div for a file kind
- **Fix:** `<FileTypeIcon extension={ext} size={16} className="shrink-0" />`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6072, bp2#4894. memo#790 goes further: per-format **branded inline SVGs**, because *"tinted Lucide glyphs … lost the per-format identity people recognise at a glance."*

### V39 — `title=` on a truncating element → a real `Tooltip`
- **Trigger:** `title={` on an element that also has `truncate` / `line-clamp-*`.
- **Detect:** `title=\{` on a swatch/row in a dense grid
- **Fix:** `<Tooltip>` with `hideArrow`, `pointer-events-none!`, and a scoped `<TooltipProvider delayDuration={250|300} skipDelayDuration={0} disableHoverableContent>`
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#663. (bp2#6070 keeps `title` as the recovery path when truncation happens **in JS** and no tooltip is in play — so only autofix where a `Tooltip` already exists in the file.)

### V43 — An alpha ramp fades to a zero-alpha stop of the same hue
- **Detect:** a gradient ending in the CSS keyword `transparent` where the other stop is a *user-chosen colour*
- **Fix:** `rgba(r,g,b,0)` derived from the active colour
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7219 + `ethan-review-comments.md`, verbatim: *"the CSS keyword `transparent`… is transparent **black**, so the track dragged through grey and misrepresented the color being adjusted."* — `to-transparent` in an ordinary muted fade-out is fine — this is only about ramps over a chosen colour.

### V47 — A missing icon degrades to a neutral circle, and lookups key on the slug
- **Detect:** an icon resolver that can `return null`, or one keyed on a display label
- **Fix:** key on the backend's stable snake_case slug (`ICON_BY_SECTION_SLUG`) and add a `FALLBACK_ICON`
- **Except:** —
- **Tag:** ask
- **Evidence:** `ethan-review-comments.md` — *"labels are copy and get reworded, the slug is the contract"*; *"a rename costs the right glyph instead of blanking the row."*

### V49 — A bordered card inside a bordered dialog is two frames
- **Detect:** `rounded-md border` on a scroll region or card that is a direct child of a padded `DialogContent`
- **Fix:** bleed the region to the frame — `-mx-6 flex min-h-0 flex-col overflow-y-auto border-y` — and delete the inner card's `rounded-md border`
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#613 — *"the negative margin turns the region into a band of the dialog itself."*

### V50 — Which surface token?
- **Trigger:** a `bg-background` on an element that is a direct child of another `bg-background` **or** sits inside a `.map(` over a list; or any `bg-card` at page/route level; or a `bg-white`/`bg-gray-50` anywhere.
- **Detect:** read the component — is this thing a *sheet of content*, a *resting de-emphasis*, or the *page*?
- **Fix:** content sheet → `bg-background dark:bg-card` **with** `shadow-sm`, sitting on a `bg-muted` padded canvas. A card in a list → `bg-card` (never `bg-background` — *"A card must not share its background with the surface behind it"*). Page/canvas → `bg-background`, or memo's `bg-design-canvas`.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7706 (table-as-sheet, borrowed from the deal Notepad), bp2-nits (kanban `bg-background` → `bg-card`, column `dark:bg-background`), memo-nits (`bg-background` → `bg-design-canvas`).

### V51 — Radius when nesting
- **Trigger:** a diff that changes **one** `rounded-*` value where the file contains two or more `rounded-*` on nested elements; or a `rounded-lg` inside a `rounded-lg` with a `border` between them.
- **Detect:** read the component — how many layers share this corner, and is there a border between them?
- **Fix:** step **down** one rung per nesting level, and change every layer in the same commit. With a 1px border between layers, the inner radius is `calc(var(--radius-lg) - 1px)`, not the same value. If two independently-drawn layers would each need a radius kept in sync, use square corners instead.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6530 (nested mock `rounded-lg` → `rounded-md`), bp2#7130 (outer `rounded-lg`→`rounded-xl` while inner `rounded-xl`→`rounded-lg`, *"inner radius + bezel padding ≈ outer radius"*), memo-nits (*"Radius moves as a set"*; `calc(var(--radius-lg)-1px)`; repeat every `print:rounded-none`), bp2#7343 (*"two numbers to keep in step for no gain"*).

### V52 — Shadow, border, outline, or glass?
- **Trigger:** three distinct source shapes, each with its own answer —
  (a) `shadow-*` on an element positioned over a map/canvas/image (`absolute` + a sibling `<canvas>`, `mapbox`, `deck.gl`, `<img>`);
  (b) `shadow-[inset_0_0_0_1px…]` or `ring-inset` on an `<img>`/`<canvas>`/`<video>`;
  (c) a `border` + `shadow` pair on something inside an already-bordered container.
- **Detect:** read the component — what is behind this element, and is it replaced content?
- **Fix:** pick by what is behind it:
  - floating over **unpredictable content** (map tiles, imagery, video) → `surface-glass` + the dark-surface companion class, **not** a shadow;
  - hairline on **replaced content** (`img`, `canvas`, `video`) → `outline-1 -outline-offset-1`;
  - hairline on a **fill** → an overlay div/`::after` painted after the fill;
  - a **card/page** → `border border-border` **and** `shadow-lg` (both);
  - a **sheet on a canvas** → `shadow-sm` only.
  Elevation states are mutually exclusive: `shadow-xs` at rest → `shadow-lg` expanded → a beam glow that *replaces* the shadow.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7205, bp2#7343, memo#783, memo-nits, bp2#7706, bp2#6804.

### V53 — Does this count deserve a badge?
- **Trigger:** `<Badge` whose only child is a number, a `{…length}`, or a `{count}` interpolation.
- **Detect:** read the component — does the number distinguish anything, and could it read as "N problems"?
- **Fix:** **Default: no badge.** A count beside a value reads as a defect count. Use a plain right-aligned `text-xs font-normal text-muted-foreground tabular-nums`, and suppress it entirely when every item is 1. Carry the number in the `aria-label`.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7711 (*"the '3' a JL user took for '3 unresolved problems'"*), bp2#6549 (`Badge` deleted, import removed), bp2#7711 (`showSourceCounts`).

### V54 — Icon or word for an option set?
- **Trigger:** an options array of ≥3 entries where each has an `icon`/`Icon` field and **no** `label`, or a `TabsTrigger`/`ToggleGroupItem` whose only child is an icon component.
- **Detect:** read the component — does the shape carry the meaning?
- **Fix:** icons only where the glyph is guessable; words otherwise; a "sum" option is composed from its parts' glyphs (`<ImageIcon/><Plus/><Type/>`). If the options differ by *proportion*, draw them at their real proportions (`aspectRatio` + a pinned long edge) and strip every decorative detail that dies at 48px.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7226 (*"Words, not icons: 'Auto' and 'Placeholder' have no glyph anyone would guess, and there are four of them."*), bp2#7343.

### V55 — Should a layout choice be a thumbnail?
- **Trigger:** a `<Select>`, `RadioGroup`, or list of `<Button>`s whose option labels name a **spatial arrangement** — `/(left|right|top|bottom|split|two.?column|full.?bleed|grid|stack|landscape|portrait)/i`.
- **Detect:** read the component — is the thing being chosen spatial?
- **Fix:** **Default: yes, draw a miniature** from real tokens — `aspect-video w-full overflow-hidden rounded-md border border-border bg-background` + `shadow-md`, content lines as `Skeleton … animate-none`, selection as `border-2 border-primary bg-primary/5` with a filled check badge. Never a screenshot; never a `Skeleton` that still pulses.
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#667/#668 (`SlideSkeleton`), memo#668 (`border-2 border-transparent` at rest so selecting doesn't shift layout).

### V56 — Collapse row actions into `⋯`?
- **Trigger:** ≥2 sibling `<Button size="icon"…>` inside one row/card component.
  - ⚠ Inversion guard: this fires on `PipelineRowQuickActions`' four bare icon buttons in bp2#6806 — and Ethan **kept all four**. The rule is **card-scoped**, not table-row-scoped: a table row's actions are already a hover overlay in a dedicated column, so they stay as buttons. Restrict the trigger to components that are **not** inside a `<TableRow>`/`<TableCell>`.
- **Detect:** read the component — are there ≥2 always-present row actions?
- **Fix:** **Default: yes**, one `MoreHorizontal` trigger labelled `"<Thing> actions"`, with `aria-expanded:opacity-100` so it stays visible while open, and any dialogs it owns rendered **outside** the menu.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7724.

### V57 — Does this section need a head or a divider?
- **Trigger:** a heading element whose text is a near-duplicate of the nearest ancestor's title/`DialogTitle`/tab label; or a `border-b`/`border-t` on a block whose parent already draws one; or a `border-t` on the *first* item of a `.map(`.
- **Detect:** read the component — does the divider separate the block from something it *belongs to*?
- **Fix:** **Default: delete it.** Drop section chrome when a block is embedded under another section's title, but keep the accessible name on `aria-label`. A collapsible header's `border-b` is conditional on `isExpanded` whenever the wrapper already draws a divider. A rule *above* the first row reads as the table's own edge — use `not-first:border-t`.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7130, bp2#7706 (both `ImportedTableSectionHeader` and `MetricTableSectionHeader`), memo#790.

### V58 — Sub-`text-xs` chrome
- **Trigger:** `text-[11px]` / `text-2xs` / `text-3xs`.
- **Detect:** read the component — is this memo panel chrome inside a ≤320px panel?
- **Fix:** `text-xs` is the floor in bp2. In memo's settings/styling panels, `text-[11px] text-muted-foreground` on `h-7` ghost buttons and tab labels is his own established value — leave it, and don't autofix it up.
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#668 (`h-7 gap-1.5 px-2 text-[11px] text-muted-foreground`, `text-[11px] font-medium` select items) vs bp2#6056 (`text-[13px]` → `text-sm`).

### V59 — Max-width containment
- **Trigger:** a new page/tab route component whose root has no `max-w-*`, in a directory whose siblings have one; or a `max-w-*` added to a page body but not to its header.
- **Detect:** read the component — is this a reading surface?
- **Fix:** opt in per surface, not globally — `mx-auto w-full max-w-[1200px]` (bp2 deal/company overview), `max-w-[1440px]` (memo page + its header, matched). Expose it as a `contained?: boolean` prop rather than wrapping every tab.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2-nits, memo#674.

### V60 — Type step-up
- **Trigger:** `text-xs` on a table's *root*/column-def level, or on a paragraph of prose; or a secondary line with **no** explicit size class (relying on inheritance); or `line-clamp-2` on a description.
- **Detect:** read the component — is this body copy people actually read, or metadata?
- **Fix:** body/card copy → `text-sm leading-5`; a reading section (pitch, prose) → `text-base leading-[1.7]`; metadata and secondary lines → explicit `text-xs`. Never set a whole table to `text-xs`; never rely on inheritance for the secondary line. Drop a `line-clamp-2` on a description and let it wrap.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6530, bp2#6804 (nine columns `text-xs`→`text-sm`, each sub-line gains explicit `text-xs`), bp2#7130 (`text-sm`→`text-base`, and the em-derived clamp constant updated in step: `23.8` → `27.2`).

### V61 — Table cell padding
- **Trigger:** a `className` on `TableHead`/`TableCell` written inline at the call site rather than resolved from a single `getXCellClassName(columnId)`; or header/skeleton/body cells for the same column carrying **different** class strings.
  - ⚠ Inversion guard: the related `bp2-6072` rule ("constrain an unbounded-text column to a fixed width so it can't push the actions column off-screen") applies to **content** columns only. It must not fire on the actions column — see **D1**, which zeroes it.
- **Detect:** read the component — is this column compact, or is it the action column?
- **Fix:** `px-4`; compact columns `px-2`; the row-action column `sticky right-2 z-10 w-0 p-0 last:pr-0`. Express it as one `getXCellClassName(columnId)` function applied identically to header, skeleton, and body.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6804, bp2#6824 (`actions: 'w-0 min-w-0'`, `COLUMN_WIDTH_PX actions: 0`).

### V62 — Fixed vs content-sized dialogs
- **Trigger:** a `DialogContent` whose height is unset (content-sized) in a dialog that renders a preview/canvas; **or** a `max-w-*` with no `sm:` counterpart; **or** a dialog whose width is a single constant while a prop conditionally removes one of its panes.
- **Detect:** read the component — is the point of this dialog a preview?
- **Fix:** a preview dialog is **wide and fixed-height**, split into a scrolling control rail and a full-bleed pane, and must not resize as options change (`h-[min(44rem,calc(100dvh-4rem))] max-w-[min(64rem,calc(100vw-4rem))] gap-0 overflow-hidden p-0` + `grid min-h-0 flex-1 md:grid-cols-[19rem_1fr]`). But when an entry point removes a pane, shrink the dialog to fit what's left. A success modal with one preview is sized to the preview (`max-w-[586px]`, not `max-w-[992px]`).
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7343, memo#783, memo-nits.

### V63 — Should a decorative constant scale?
- **Trigger:** a module-level numeric constant (offset, radius, spread, stroke) consumed by a component that also accepts a `size`/`variant` prop.
- **Detect:** read the component — does this component render at more than one size?
- **Fix:** yes — offsets, fan spread, and radius all take a size variant. *"What reads right at 440px is too round on a 92px thumbnail."*
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#798 (`TOAST_OFFSETS` vs `BACK_OFFSETS`, `radius?: 'lg' | 'md'`).

### V64 — Threshold before adding chrome
- **Trigger:** a `SearchInput`/filter field, pagination, or a sort control rendered unconditionally inside a list whose length is unbounded and often small.
- **Detect:** read the component — does scanning still work without this control?
- **Fix:** gate it. `const SEARCH_THRESHOLD = 5` — *"Below this, a search field is more chrome than help."* Same instinct: show fewer preview items rather than shrinking them to fit (`.slice(0, 2)`).
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#798, bp2#6530.

### V65 — Where does padding live?
- **Trigger:** a wrapper `<div>` whose **only** className is padding, around a single child that also has padding; or `space-y-*` on a list whose items are of different kinds.
- **Detect:** read the component — which component owns this gutter?
- **Fix:** the leaf/primitive owns it. Delete the parent's duplicate wrapper (`<div className="p-4 pt-2">` around a grid that now pads itself); put sidebar padding on `Header`/`Content` (`p-3.5`), not on the lists inside. In a panel, the shell is `p-0` and the sections carry `px-4`. Set spacing per item (`mt-4` / `mt-2.5`) instead of `space-y-*` when items differ in kind.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7706, memo-nits, memo#668, memo#790.

### V66 — Optical vs box alignment
- **Trigger:** a ghost/icon button as the **last** child of a flex row that has container padding, with no negative margin; or a selected/active row inside a padded scroll container with no `-mx-*` bleed.
- **Detect:** read the component — is the thing being aligned a ghost button or an ellipsized label?
- **Fix:** align the **glyph**, not the box — offset a ghost button's invisible padding with a negative margin (`-mr-2.5`, `pr-1.5`). Bleed a selected row out by the container's own padding (`-mx-4 … pl-4`) so its band reaches the walls, and put the bleed on the scroll container so it can't spawn a horizontal scrollbar.
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#776 (both comments verbatim).

### V67 — Chart palette and the residual bucket
- **Trigger:** a chart series/`fill` array containing a literal hex, a `-200`/`-300`/`-400` Tailwind shade, or a slot named `other`/`Other`/`residual`/`unknown` assigned a `chart-N` token.
- **Detect:** read the component — is this slot a real category?
- **Fix:** the 5-slot palette is **orange / green / abyss-or-cyan / red / purple**, same hue order in light and dark, no 200–400 pastels. An "Other"/residual bucket is not a palette colour: `color-mix(in srgb, var(--color-neutral-400) 45%, transparent)` fill with a dashed muted stroke, drawn inset by half the stroke width on top+sides only.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6668.

### V68 — Annotating someone else's content
- **Trigger:** a `text-*` colour class, `opacity-*`, or a background wash applied to an element that renders user-authored content (an editor node, a comment body, a memo block, `dangerouslySetInnerHTML`).
- **Detect:** read the component — is this text authored by the user?
- **Fix:** never change the author's text colour or wash a media block. Carry the mark on `background-color` + a dotted underline, derived with `color-mix(… , currentColor)` so it contrasts in the same direction the text does. Underline only inline runs (`text-decoration` inherits into every cell) — trace blocks with an inset dotted `outline` instead. A hairline needs a deeper shade than a fill (*"emerald-500 is a fill colour, and at one physical pixel on white it reads as grey"*).
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#790 (5 rules).

### V69 — Where does a new value come from?
- **Trigger:** any **new** numeric or colour literal in a diff that isn't a token, a scale class, or a copy of an existing value in the same file.
- **Detect:** read the component — does a canonical implementation of this already exist?
- **Fix:** **Default: copy it, and name your source in the PR.** He does not invent values — *"I just copied and pasted whatever shadcn has for the outline button currently https://ui.shadcn.com/docs/components/button"*, and when challenged on a colour: *"I mimicked the old windy version"* with a screenshot attached. A reviewer asking "why this value?" should be answerable with a link, not a justification. Corollary: when a token change has an unfixed consequence, **state it** rather than papering over it.
- **Except:** —
- **Tag:** ask
- **Evidence:** `ethan-own-pr-replies.md`, bp2-nits.

---

## Reference

The scales he actually uses.

### Spacing — `gap`
| Context | Value |
|---|---|
| Grouped icon buttons (one control) | `gap-0` |
| Joined input halves | `gap-0.5` |
| Tight metadata / shrunken hint row | `gap-1` |
| Chip internals, icon+label inside a truncating span | `gap-1.5` |
| **Icon + text metadata row (default)** | **`gap-2`** |
| Swatch grid | `gap-1.5` (grid `grid-cols-6`) |
| Chart tooltip rows | `gap-2` / container `gap-2.5` |
| Setting row (label ↔ control) | `gap-3` |
| Title + subtitle pair | `gap-1` inside a `gap-3` parent |
| Section-to-section in a panel | `gap-5` (`space-y-4` within) |
| Header control cluster ↔ label | `gap-5` |
| Page section stack | `gap-6` / `gap-8` |

### Spacing — padding & heights
- Row padding: compact list `px-2 py-1.5` · list `px-3 py-2` · table section head `px-4 py-2` · sidebar row `px-1.5 py-1`.
- Panel: shell `p-0`, sections `px-4`, vertical `py-4`, section stack `gap-5`.
- Panel chrome rows: `min-h-12 px-2 sm:px-3` (not a flat `px-4`/`min-h-10`).
- Sidebar `Header`/`Content`: `p-3.5`.
- **Control heights:** `h-7` (panel/dense control, ghost panel button) · `h-8` (standard field, joined input, tab trigger) · `h-9` (form field, add-row button) · `h-11` mobile → `sm:h-8`/`sm:h-9`.
- **Row min-heights:** `min-h-7` setting row · `min-h-8` label/control row · `min-h-10` file row · `min-h-12` panel chrome.
- Sizes: `size-7` swatch · `size-8` preview swatch / eyedropper · `size-[18px]` slider knob · `size-2.5` knob dot · `size-1` metadata dot.
- Fixed widths: `w-[220px]` picker popover · `w-56` action menu · `w-72`/`w-80` settings popover · `w-80` control panel & search pill · `w-9` slider readout · `w-24` slider track.
- Hover regions extend symmetrically into margins: `-mx-2 -my-2 … px-2 py-2`. Never `-my-1` against `py-1` if corners clip.
- The theme's `--space-*` scale skips 7, 9, 11 and 14 — treat `gap-7`/`p-9`/`m-11`/`p-14` as off-scale. Half-steps (`1.5`, `2.5`, `3.5`) are in constant use and are fine.
- Contact-sheet grids are `grid grid-cols-N gap-0.5` with square, radius-less tiles — *"`gap-3` + `rounded-lg` made it read as N separate cards"* (memo#635).

### Radius ladder
Base `--radius: 0.625rem` (10px). Steps are `calc(--radius ± 4px)`, so each rung is 4px apart.

| Rung | px | Use |
|---|---|---|
| `rounded-full` | 9999 | pills, circles, sliders, knobs, dots, drop lines |
| `rounded-2xl` | 18 | glass surfaces floating over a map |
| `rounded-xl` | 14 | outer dialog/bezel when something is nested inside it |
| `rounded-lg` | 10 | card, page sheet, panel, popover, chart tooltip |
| `rounded-md` | 8 | inner box, control, thumbnail, menu item, `size-8` avatar |
| `rounded-sm` | 6 | swatch, `size-4`/`size-5` avatar, tiny box, list row inside a card |
| `rounded-xs` | 4 | 12–14px swatch inside another control (gradient stop marker) |
| `rounded-none!` | 0 | a component embedded flush inside another surface |
Nesting: inner = outer − 1 rung, or `calc(var(--radius-lg) - 1px)` across a border. Repeat every `print:rounded-none` on every layer that rounds itself.

### Shadow scale
**The ramp is shallow — this is the rule he enforced on someone else's PR:** a small control is
`shadow-xs` at rest and `hover:shadow-sm`. Never `shadow-sm` at rest or `hover:shadow-md`.

`shadow-2xs` hairline lift · `shadow-xs` chip / control at rest · `shadow-sm` control on hover, sheet on a canvas, image on a pane · `shadow-md` thumbnail, slider knob, `drop-shadow-md` marker · `shadow-lg` expanded panel, page card · `shadow-xl` chart tooltip · `shadow-none` inner element inside a bordered group.
**Decision rule:** border for a *boundary*, shadow for *elevation*, outline for a hairline over replaced content, `surface-glass` for anything over unpredictable content. A card gets border **and** shadow; a sheet gets shadow only; a swatch gets an overlay border only (no shadow). Never two shadows for two states at once.

### Surfaces
| Token | Meaning |
|---|---|
| `bg-background` | the page / the sheet's own light ground (light mode) |
| `bg-card` | a card in a list; the sheet's ground in **dark** mode (`dark:bg-card`) |
| `bg-muted` | the canvas *under* a sheet; a section head; **the hover surface**; a resting de-emphasis |
| `bg-muted/50` | a secondary hover inside a surface that is already `bg-muted` (rail rows) |
| `bg-accent` | reserved for a *distinct* hover/active response where `muted` is already taken |
| `bg-popover` | popover/menu ground |
| `surface-glass` | any control floating over map/imagery/video — apply to **every** control in the cluster |
| `bg-design-canvas` | memo's editor canvas behind the page card |
Colour-judging surfaces (swatch, gradient) are **never** glass. Sticky headers are fully opaque. Translucent fills over photographic backgrounds become opaque.

### Icon sizing
| Size | Use |
|---|---|
| `size-1` | a metadata *kind* — a dot, not a glyph (`rounded-full bg-blue-500/70`) |
| `size-2.5` | knob dot, check inside a `size-4` badge |
| `size-3` | chip remove `X`, inline metadata glyph |
| **`size-3.5`** | **the default UI glyph** — sidebar nav, `text-xs` labels, row actions, panel buttons |
| `size-4` / `size={16}` | menu-row icon, `size="sm"` button icon, dropdown trigger chevron |
| `size-5` | section icon slot (`flex size-5 items-center justify-center [&_svg]:size-4`) |
Never `size={20}`/`size-5` for a glyph inside a `size="sm"` button. Icons are `shrink-0` and `text-muted-foreground` when the label carries the emphasis. One icon set per surface (Hugeicons **stroke** in bp2's Index sidebar, lucide elsewhere); one glyph per verb; overflow is horizontal; specific-before-generic in any type→icon priority list, with a neutral fallback.

### Type scale & pairings
| Role | Classes |
|---|---|
| Success-moment title | `text-3xl font-semibold leading-[30px]` |
| Success-moment subline | `text-xl font-medium leading-[28px] text-muted-foreground` |
| Empty-state title | `text-lg font-semibold text-foreground` |
| Empty-state description | `text-base text-muted-foreground` |
| Dialog title | `text-base leading-none font-medium` |
| Reading section (prose/pitch) | `text-base leading-[1.7]` |
| Card / table body primary | `text-sm leading-5` (+ `font-medium text-foreground` for a name) |
| Feature-row title | `text-sm font-medium` |
| Field label in a row | `text-sm font-normal` |
| **Section label** | **`text-xs font-medium text-muted-foreground`** |
| Section head in a table | `text-xs font-semibold text-muted-foreground` on `bg-muted`, sentence case |
| Secondary / metadata line | `text-xs text-muted-foreground` (always explicit, never inherited) |
| Quiet chrome action | `text-xs font-normal text-muted-foreground` → `hover:text-foreground` |
| Numeric readout | `text-xs text-muted-foreground tabular-nums` (`w-9 text-right` when it changes) |
| Chart value / cited data | `font-mono font-medium tabular-nums` |
| Stat number | `font-semibold tabular-nums` + muted unit beside it, pluralized from the value |
| Panel chrome (**memo only** — bp2's floor is `text-xs`) | `text-[11px] font-medium text-muted-foreground` |
| Off-limits | `text-2xs` (10px), `text-3xs` (9px) — registered tokens, but below the 12px floor |
Weight, not colour, carries emphasis inside a row (`font-semibold` matched vs `font-normal` unmatched). A selected state differs by **weight + text colour**, not a second background wash. Sentence case everywhere; only proper nouns and established acronyms keep capitals. A display heading that changes size gets an explicit `line-height` so the box doesn't jump. When you change a type size, update any em-derived constant in the same commit.

### Conflicts across PRs

- **C1 — `accent` vs `muted` for hover.** bp2-nits states the token semantics: *"`accent` is the hover/active response, `muted` is a resting de-emphasized state"* (and moved `--accent` off `--muted`'s value so hover is distinguishable). But bp2#7711 makes **both** hover and selected `bg-muted`, and memo#776 (the newest evidence) uses `hover:bg-muted dark:hover:bg-muted/50` + `data-[state=active]:bg-muted`. **Prefer the newer behaviour: `bg-muted` is the hover surface**, `bg-accent` only where `muted` is already the resting surface and a second step is genuinely needed. Rule V14 encodes this.
- **C2 — dashed vs solid separators.** bp2#6548 introduced `border-l border-dashed` separators and a `border border-dashed` bar; **bp2#6620 reverts both to solid.** 6620 is later → solid. Dashed survives only for *chart gridlines* (`strokeDasharray="4 4"`), the "Other" bucket stroke (`3 3`), and annotation traces (`outline: 1.5px dotted`).
- **C3 — off-scale font sizes.** bp2#6056 bans them (`text-[13px]` → `text-sm`); memo#668 and memo#776 use `text-[11px]` freely for panel chrome. Not a real contradiction — 13px sits *between* steps, 11px sits *below* the smallest. Autofix only 13/15/17px (V2); leave `text-[11px]` (V58).
- **C4 — `border-border`.** bp2's `CLAUDE.md` calls it redundant and bp2 diffs use bare `border`/`border-t`; memo diffs keep `border-border` explicitly (39 after-side hits). Repo-scope the autofix (V5).
- **C5 — `title` vs `Tooltip`.** bp2#6070: *"Put the full string in a `title` whenever you truncate in JS."* memo#663 replaces `title={color.name}` with a real `Tooltip` (*"Native `title` is too slow and unstyleable for a grid you sweep across"*). memo#663 is later and more specific → in a **dense grid**, use `Tooltip` with `hideArrow` + `pointer-events-none!`; `title` remains acceptable as a last-resort recovery path elsewhere.
- **C6 — `EllipsisVertical`.** bp2#6548/#6668 replace it with the horizontal glyph; bp2#6549 keeps a `triggerIcon="vertical"` escape hatch. Treat horizontal as the default and an explicit prop as intentional.
- **C7 — alpha on semantic tokens.** `airy-rules/design-system-rules.md` says *no alpha on semantic tokens*. His practice contradicts it constantly and deliberately: `bg-muted/50`, `bg-destructive/10`, `bg-primary/5`, `border-border/70`, `bg-foreground/25`, `bg-warning-background/60`, `text-muted-foreground/40`. **Do not flag those.** The doc's real target is narrower, and he enforces exactly that narrow case: never use an alpha to *fake a tinted surface that already has a `*-background` token* (`bg-warning/90` → `bg-warning-background`), and never derive a hover shade with an opacity step when `color-mix` against `--foreground` is available (`hover:bg-secondary/80` → `color-mix(in oklch, var(--secondary), var(--foreground) 5%)`). Flag those two shapes only.
- **C8 — `text-[Npx]`.** `agents/tailwind-4.md` rule 8 bans arbitrary font sizes outright and rule 6 sets a 12px floor; memo#668/#776 use `text-[11px]` as settled panel chrome. Repo-split it: hard rule in bp2, accepted value in memo. (Note `text-2xs` = 10px exists as a token but is *also* below the floor — neither repo should reach for it in body or label copy.)
- **C9 — descendant selectors into primitives.** `agents/shadcn-ui.md` rule 10 forbids reaching into a shared component's internals; several of his own diffs do exactly that (`[&_th]:shadow-[inset_…]`, `[&_td]:border-border`, `[&>svg]:size-3.5!`, `[&>div]:h-full`). The distinction that reconciles them: passing an arbitrary variant **in as `className`** on a primitive you are rendering is fine; **editing** `src/components/ui/` or copy-pasting its internal classes is not. `RichTextEditor` lives in `src/components/shared/` (app-owned), so `[&>div]:h-full` there is legal. Never present these as a licence to hack protected primitives.
- **C10 — spinners for AI waits.** `agents/react-19.md` mandates `MorphingLevIcon` + `shimmer` for AI work; bp2#7558 uses `<Loader2 className="size-4 animate-spin" />` on a Generate-FAQs submit button. Not a contradiction: the in-button spinner is *secondary* to a `MorphingLevIcon` status block in the same view. Never use a spinner as the primary AI wait indicator.

---

## Before → after

Verbatim before/after pairs.

| # | before | after | src |
|---|---|---|---|
| 1 | `relative w-8 h-8 flex-shrink-0 overflow-hidden rounded-md border border-border shadow-xs` | `relative size-8 flex-shrink-0 overflow-hidden rounded-sm` + `<div className="pointer-events-none absolute inset-0 rounded-sm border border-border" />` | memo#664 |
| 2 | `text-[13px]` | `text-sm` | bp2#6056 |
| 3 | `bg-foreground/5 py-3 text-xs font-semibold tracking-wider text-muted-foreground uppercase` | `bg-muted py-3 text-xs font-semibold text-muted-foreground` | bp2#7711 |
| 4 | `isActive ? 'bg-accent font-medium text-accent-foreground' : 'text-muted-foreground hover:bg-accent/50 hover:text-foreground'` | `isActive ? 'bg-muted font-medium text-foreground' : 'text-muted-foreground hover:bg-muted hover:text-foreground'` | bp2#7711 |
| 5 | `w-full overflow-x-auto p-4 … [&_table]:rounded-lg [&_table]:border [&_table]:border-border [&_table]:text-sm` | `w-full overflow-x-auto bg-muted p-4 … [&_table]:bg-background [&_table]:shadow-sm dark:[&_table]:bg-card` | bp2#7706 |
| 6 | `sticky top-0 z-10 bg-background` | `sticky top-0 z-[var(--z-sticky)] bg-background [&_th]:bg-background [&_th]:shadow-[inset_0_-1px_0_0_var(--border)] [&_tr]:border-b-0` | bp2#6715 |
| 7 | `border-b border-border` (always) | `cn('… bg-background px-4 py-2', isExpanded && 'border-b border-border')` | bp2#7706 |
| 8 | `<div aria-hidden className="h-5 shrink-0 self-center border-l border-dashed" />` | `<div aria-hidden className="h-5 shrink-0 self-center border-l" />` | bp2#6620 |
| 9 | `divide-x divide-dashed divide-border` | explicit `<BulkActionsBarSeparator />` per gap | bp2#6548 |
| 10 | `relative h-2 rounded cursor-pointer hue-gradient border border-gray-200 shadow-inner` | `relative h-3 rounded-full cursor-pointer hue-gradient ring-1 ring-inset ring-black/10` | memo#663 |
| 11 | `w-3 h-3 bg-white border border-gray-300 rounded-full shadow-xs cursor-grab transition-transform duration-150 hover:scale-110 active:scale-125` | `flex size-[18px] items-center justify-center rounded-full bg-white shadow-md ring-1 ring-black/10 cursor-grab active:cursor-grabbing` | memo#663 |
| 12 | `w-full max-w-[280px]` + `w-full h-[140px] rounded-md border border-border shadow-xs` | `w-full max-w-[220px]` + `w-full aspect-square bg-clip-padding rounded-md relative cursor-crosshair border border-border shadow-xs` | memo#663 |
| 13 | `shadow-[inset_0_0_0_1px_var(--border)]` | `rounded-lg outline-1 -outline-offset-1 outline-[var(--border)]` | memo#783 |
| 14 | `ring-1 ring-inset` / `border-border` on an image | `outline-1 -outline-offset-1 outline-foreground/20` | bp2#7343 |
| 15 | `flex size-4 shrink-0 … overflow-hidden rounded-sm border border-border/70 bg-muted` | `relative flex size-4 … rounded-sm bg-muted after:absolute after:inset-0 after:rounded-sm after:border after:border-border/70 after:mix-blend-darken dark:after:mix-blend-lighten` | bp2#7679 |
| 16 | `xs: 'size-5 rounded-lg'`, `sm: 'size-8 rounded-lg'` | `xs: 'size-5 rounded-sm'`, `sm: 'size-8 rounded-md'` | bp2#7031 |
| 17 | `!size-4 rounded-md` | `!size-4 rounded-sm` (+ `iconClassName="!size-2.5"`) | bp2#6668 |
| 18 | `relative aspect-video w-full max-w-[200px] overflow-hidden rounded-lg …` | `… rounded-md …` | bp2#6530 |
| 19 | `w-[calc(100vw-2rem)] max-w-[28rem] gap-0 overflow-hidden rounded-lg p-0` + inner `rounded-xl … p-2.5` | `… rounded-xl p-1.5` + inner `rounded-lg border … p-2` | bp2#7130 |
| 20 | `rounded-sm` (page wrapper, Scale wrapper, highlight, `rounded-b-sm` bar) | `rounded-lg` on all, `rounded-b-lg` on the bar; inner fills `rounded-[calc(var(--radius-lg)-1px)] print:rounded-none` | memo-nits |
| 21 | `group/page w-full flex bg-white shadow-lg rounded-sm print:rounded-none print:shadow-none overflow-hidden` | `group/page w-full flex bg-white border border-border shadow-lg rounded-lg print:rounded-none print:border-0 print:shadow-none overflow-hidden` | memo-nits |
| 22 | `group/kanban-board-card shadow-xs rounded-lg border bg-background p-3` | `… border bg-card p-3` (+ `Column` gains `dark:bg-background`) | bp2-nits |
| 23 | `bg-black/10 duration-100 supports-backdrop-filter:backdrop-blur-xs fixed inset-0 isolate z-50` | `bg-black/30 dark:bg-black/50 duration-100 fixed inset-0 isolate z-50` | bp2-nits |
| 24 | `cn('leading-none font-medium', className)` | `cn('text-base leading-none font-medium', className)` | bp2-nits |
| 25 | `text-xs font-medium text-foreground` / `text-xs whitespace-nowrap text-muted-foreground` (9 columns) | `text-sm leading-5` primaries + explicit `text-xs text-muted-foreground` sub-lines | bp2#6804 |
| 26 | `text-xs leading-4 font-medium` / `line-clamp-2 … text-xs leading-4` | `text-sm leading-5 font-medium` / `text-sm leading-5` (clamp dropped) | bp2#6530 |
| 27 | `'-mx-2 min-h-24 rounded-lg px-2 py-3 text-sm'` + `pitchLineHeightPx = 23.8` | `'relative -mx-2 min-h-24 rounded-lg px-2 py-3 text-base'` + `pitchLineHeightPx = 27.2` | bp2#7130 |
| 28 | `flex h-9 w-full items-center gap-2 text-left text-sm font-medium text-primary … hover:text-primary/80` | `… text-xs font-normal text-muted-foreground … hover:text-foreground` | bp2#6520 |
| 29 | `<Plus className="size-4 shrink-0" />` | `<Plus className="size-3.5 shrink-0" />` | bp2#6520 |
| 30 | `<CloudUpload size={20} />` | `<Upload size={16} />` (+ `<ChevronDown className="ml-1" size={16} />`) | bp2#7007 |
| 31 | `const navIconClassName = 'size-3 text-sidebar-foreground/80'`; `[&_svg]:size-3!` | `const sidebarIconSizeClassName = 'size-3.5'`; `[&>svg:first-child]:size-3.5!`; `text-muted-foreground!` | bp2#6399 |
| 32 | `<UserPen className="size-3.5 shrink-0 text-muted-foreground" />` | `<span className="size-1 shrink-0 self-center rounded-full bg-blue-500/70" />` | bp2#6072 |
| 33 | `<MapPin className="size-4 shrink-0 text-muted-foreground" />` (every row) | `const ResultIcon = getPlaceTypeIcon(result.types)` → `<ResultIcon className="size-4 shrink-0 text-muted-foreground" />` | bp2#7222 |
| 34 | `<div className="flex size-4 … rounded-[3.5px] bg-primary text-white"><LevAI className="size-2.5" /></div>` | `<FileTypeIcon extension="memo" />` | bp2#4894 |
| 35 | `<FileText className={cn(className, 'text-[#B30B00]')} />` | branded per-format inline SVG | memo#790 |
| 36 | `<Badge variant="outline">{group.subRows.length}</Badge>` | `<span className="pr-2 text-xs font-normal text-muted-foreground tabular-nums">{group.subRows.length}</span>` | bp2#6549 |
| 37 | `<Badge className="h-4 px-1.5 text-[10px]" variant="secondary">{observationCount}</Badge><ChevronDown className="size-3 shrink-0" />` | `<ChevronsUpDown className="size-3 shrink-0" />` | bp2#7711 |
| 38 | `<p className="flex … text-xs text-destructive"><AlertTriangle className="mt-0.5 size-3.5 shrink-0" />` | `<p className="… text-xs text-foreground"><AlertTriangle className="mt-0.5 size-3.5 shrink-0 text-destructive" />` | bp2#6620 |
| 39 | `<AlertTriangle className="mt-0.5 size-3.5 shrink-0 text-error-foreground" />`; `bg-error-background` | `text-destructive`; `bg-destructive/10` | bp2#6363 |
| 40 | `--warning-foreground: #ffffff;` | `--warning-foreground: #b57b24;` / dark `#eec785;` | bp2-nits |
| 41 | `bg-warning/90 … text-warning-foreground` | `bg-warning-background px-4 py-2 text-center text-xs text-warning-foreground` | bp2-nits |
| 42 | `bg-chart-4/10 … text-chart-4` | `bg-warning-background … text-warning-foreground` | bp2-nits |
| 43 | `text-sidebar-foreground/80` | `text-muted-foreground` | bp2#6399 |
| 44 | `border-t border-info-border bg-neutral-50 px-2 py-1.5 text-xs text-muted-foreground` | `border-t bg-muted px-2 py-1.5 text-xs text-muted-foreground` | bp2#6530 |
| 45 | `activeStyle === style.value ? 'bg-gray-100' : 'bg-white hover:bg-gray-50'` | `… ? 'bg-accent dark:bg-accent' : 'bg-background hover:bg-muted dark:bg-card dark:hover:bg-accent'` | bp2-nits |
| 46 | `className="tiptap-suggestion-menu bg-white"` | `className="tiptap-suggestion-menu"` | memo#665 |
| 47 | `className="absolute top-3 left-3 z-40 shadow-md"` | `className="surface-glass absolute top-3 left-3 z-40"` | bp2#7205 |
| 48 | `<Input className="h-8 px-2 text-sm font-mono border-border focus:border-border focus:ring-0" />` (×2, separate) | joined `rounded-l-md bg-muted px-2 focus-within:ring-1 focus-within:ring-ring` + `<Hash className="size-3.5 shrink-0 text-muted-foreground" />` / `rounded-r-md … <Percent … />`, inputs `w-full min-w-0 bg-transparent text-sm outline-none` | memo#663 |
| 49 | `<div className="border-t border-border" />` + `size="sm"` Cancel/Save | no divider, `size="xs"` | memo#663 |
| 50 | `'flex flex-wrap gap-2 p-0.5 relative'` with `size-6 rounded-full` swatches | `'grid w-full grid-cols-6 justify-items-start gap-1.5'` with `size-7 … rounded-sm` | memo#663 |
| 51 | `selectedLibraryColor?.id === color.id ? 'ring' : 'border-border hover:ring'` | `<Check className={cn('size-4', isLightColor(color) ? 'text-foreground' : 'text-white')} strokeWidth={3} />` + `hover:scale-110 active:scale-95` | memo#663 |
| 52 | `'group relative flex items-center rounded-md pl-2.5 pr-6 py-1.5 text-xs …'` | `'group relative flex items-center rounded-md px-2.5 py-1.5 text-xs …'` | bp2#5824 |
| 53 | `'absolute top-0 right-0 bottom-0 flex items-center justify-end rounded-r-md pr-1.5 …'` + `style={{ width: '2rem' }}` | `'… flex w-8 items-center justify-center rounded-r-md …'` | bp2#5824 |
| 54 | `'flex min-h-10 items-center justify-between gap-3 px-4'` | `'flex min-h-12 items-center justify-between gap-3 px-2 sm:px-3'` | bp2#6668 |
| 55 | `<div className="flex items-center gap-3">` (section header cluster) | `<div className="flex items-center gap-5">` | bp2#6715 |
| 56 | `'flex min-w-0 items-center gap-1 text-muted-foreground'` | `gap-2` | bp2-nits |
| 57 | `px-2 py-1 … gap-1`, `<DynamicIcon className="size-4" />` | `min-w-0 … gap-2 overflow-hidden rounded px-1.5 py-1`, `<DynamicIcon className="size-3.5 shrink-0" />` | bp2#7679 |
| 58 | `SidebarHeader → p-2`, `ThreadList → flex flex-col gap-2.5 p-2` | `SidebarHeader → p-3.5`, `SidebarContent → overflow-auto p-3.5`, `ThreadList → flex flex-col gap-2.5` | memo-nits |
| 59 | `<div className="p-4 pt-2"><ImportedTableGrid htmlContent={htmlContent} /></div>` | `<ImportedTableGrid htmlContent={htmlContent} />` | bp2#7706 |
| 60 | `className="flex items-center py-5 absolute -top-20 right-0 …"` | `className="flex items-center py-3 absolute -top-14 right-0 …"` (+ `scroll-mt-16` on the slide) | memo#667/#668 |
| 61 | `<DialogContent className="max-w-[992px]">` | `<DialogContent className="max-w-[586px]">` | memo-nits |
| 62 | `<DialogTitle className="text-2xl font-semibold">` | `<DialogTitle className="text-3xl font-semibold leading-[30px]">` | memo-nits |
| 63 | `<div className="flex flex-col gap-6 p-4 pb-20">` | `<div className="mx-auto flex w-full max-w-[1200px] flex-col gap-6 p-4 pb-20">` | bp2-nits |
| 64 | `usesMiddleAlignment ? 'align-middle' : 'align-top'` | `cn('overflow-hidden', 'align-middle', …)` | bp2#6824 |
| 65 | `header: () => <div className="text-right">Last reply date</div>`, `<Skeleton className="ml-auto h-4 w-15" />` | `header: 'Last reply date'`, `<Skeleton className="h-4 w-15" />` | bp2#6824 |
| 66 | `actions: 'w-[9.5rem] min-w-[9.5rem]'` / `COLUMN_WIDTH_PX actions: 152` | `actions: 'w-0 min-w-0'` / `actions: 0` | bp2#6824 |
| 67 | `maxBarSize={useSliceVisuals ? 40 : 56}` | `const CHART_BAR_MAX_SIZE = 22` + `barCategoryGap="34%"` | bp2#6668 |
| 68 | `radius={index === segmentColumns.length - 1 ? [4, 4, 0, 0] : 0}` | `radius={0}` + one `clipPathPath` over the whole stack, `CHART_BAR_RADIUS = 4` | bp2#6668 |
| 69 | `[&_.recharts-cartesian-grid_line[stroke='#ccc']]:stroke-border/50` | `…]:stroke-border` | bp2#6668 |
| 70 | `'grid min-w-32 items-start gap-1.5 rounded-lg border border-border/50 bg-background px-2.5 py-1.5 text-xs shadow-xl'` | `'grid min-w-56 items-start gap-2.5 … px-3 py-2.5 text-xs shadow-xl'` + rows `grid-cols-[auto_minmax(0,1fr)_auto] gap-x-3 gap-y-1` | bp2#6668 |
| 71 | light `--chart-1: var(--color-purple-300) … --chart-5: var(--color-yellow-200)` | light `orange-400, green-500, abyss-600, red-500, purple-500`; dark `orange-400, green-500, cyan-800, red-300, purple-400` | bp2#6668 |
| 72 | `case 'icon_5': return 'var(--success-foreground)'` | `return 'var(--success)'` | bp2#6668 |
| 73 | `-mx-2 h-11 w-[calc(100%+1rem)] border-0 bg-transparent px-2 shadow-none hover:bg-muted/50 focus-visible:ring-0 sm:h-8 dark:bg-transparent …` | `h-11 w-full sm:h-9` | bp2#7513 |
| 74 | `'group relative min-w-0 w-full rounded-xs outline-offset-4 focus-within:outline hover:outline'` | `'group relative -mx-2 -my-1 min-w-0 rounded-md border border-transparent px-2 py-1 transition-colors hover:border-border'` | bp2#7031 |
| 75 | `Dropcursor.configure({ color: '#3b82f6', width: 2 })`; `'position:absolute; z-index:50; pointer-events:none;'` | `width: 4`; `'… border-radius: 9999px; border: 1px solid #93c5fd; box-sizing: border-box;'` | memo#678 |
| 76 | `<span className="text-error-foreground">Delete slide</span>` | `Delete slide` (uncoloured; menu placement + confirm carry the weight) | memo#667 |
| 77 | `default TabsList variant` (track + raised active trigger) | `'h-auto w-full gap-1 bg-transparent p-0'` + `'data-[state=active]:bg-muted data-[state=active]:text-foreground data-[state=active]:shadow-none!'` | memo#776 |
| 78 | `previewTones` — 5 hardcoded hexes (`bg-[#0d5362]`, …) indexed by `templateId % n` | `bg-neutral-200` / `bg-neutral-100` / `bg-neutral-400` | memo#674 |
| 79 | `<tr>` with a rule above the first row | `<tr className="border-border/50 not-first:border-t">`; header `bg-muted/70 border-border border-y` | memo#790 |
| 80 | `bg-secondary text-secondary-foreground hover:bg-secondary/80` | `hover:bg-[color-mix(in_oklch,var(--secondary),var(--foreground)_5%)]` | bp2-nits |
| 81 ★ | `shadow-sm … hover:shadow-md` (a `size-7 rounded-full` icon button) | `shadow-xs … hover:shadow-sm` | review comment |
| 82 | `purple: 'bg-secondary text-secondary-foreground-foreground'` | `levender: 'bg-levender-background text-levender-foreground'` | review comment |
| 83 | `<div className="flex w-full flex-wrap gap-3">` + tiles `size-40 … rounded-lg` | `'grid w-full grid-cols-3 gap-0.5'` + tiles `aspect-square min-w-0 … p-0` (no radius) | memo#635 |
| 84 | `className="p-0 w-[382px] max-h-[500px] overflow-hidden flex flex-col"` | `className="flex max-h-[min(660px,var(--radix-popover-content-available-height))] w-[382px] flex-col gap-0 overflow-hidden p-0"` | memo#635 |
| 85 | `className="w-full justify-start gap-2 bg-gradient-to-r from-green-600 to-emerald-700 text-white hover:from-green-700 hover:to-emerald-800 shadow-sm"` | `--lev-ai-gradient-color-1..4` + `--lev-ai-gradient-color-weight: 50%` (`70%` in `.dark`), stops via `color-mix(in srgb, var(--lev-ai-gradient-color-N) var(--…-weight), currentColor)` | memo#635 |
| 86 | `<p className="font-medium text-foreground">From:</p>` … `To:` stacked | `<span className="flex min-w-0 items-center gap-1 text-xs leading-5"><span className="min-w-0 truncate">…</span><ArrowRight className="h-3 w-3 shrink-0 text-muted-foreground" /><span className="min-w-0 truncate">…</span></span>` | memo#613 |
| 87 | `<div className="flex min-h-0 flex-col gap-3 overflow-y-auto pr-1">` + inner `rounded-md border` card | `<div className="-mx-6 flex min-h-0 flex-col overflow-y-auto border-y">`, inner border deleted | memo#613 |
| 88 | `import { RefreshCcw } … <RefreshCcw className="h-4 w-4" />` | `RefreshCw` + `cn('h-4 w-4', isPending && 'animate-spin')` | memo#613 |
| 89 | proportional figures in a count badge | `text-xs font-medium tabular-nums text-muted-foreground` | memo#619 |
| 90 | `<TooltipContent>` with two run-together lines | `<TooltipContent className="max-w-sm space-y-1.5">` with each line a `<span className="block …">` | memo#619 |
| 91 | fixed `gap-4 p-6` on a container that can be empty | `showEmptyWorkspace ? 'gap-0 p-0' : 'gap-4 p-6'` | memo#635 |
| 92 | `dark` on a panel subtree (text stayed `oklch(0.2046 0 0)`) | `cn('dark', 'text-foreground', …)` → `oklch(0.9702 0 0)` | review comment |

---

## Merged out

_(pending — the editor fills this in)_
