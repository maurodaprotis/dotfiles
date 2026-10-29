# PATTERNS — structural rules

Synthesized from 81 findings files (127 merged PRs, `levco/borrower-portal-v2` + `levco/memo`).
Domain: `hierarchy` (120 rules), `interaction-pattern` (86), `component-choice` (61), `overflow` (55),
`loading` (30), `empty-state` (22), `responsive` (15). **389 source rules → 369 high-confidence, 37 medium.**

The single sentence under all of it, in his words: **"A sentence can't express a shape. Show the shape."**
Its structural corollary — **delete the control that shouldn't have existed** — accounts for more of his
diff volume than any addition.

---

## 1. Component-choice decision rules

### P1 — Modal → toast / inline / nothing

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** Component-choice: 9% autofixable by this file's own measurement. Deleting a modal or rerouting a flow is a product decision — propose the row, never apply it.

- **Tag:** ask
- **Blast radius:** flag

- **Trigger:** a dialog component whose form fields are **all optional** (no `required`, no validation gate on submit) and whose submit handler calls a mutation that is safe to repeat; **or** a handler that branches on a "first time" condition (`if (!lastPublishedDate)`, `if (!hasEverX)`) to decide whether to open a dialog.
  - Sub-trigger, fully mechanical: **`<AlertDialog>` guarding an action with no destructive mutation and no irreversible side effect** → rg `<AlertDialog` in a file with no `delete`/`remove`/`archive` mutation. Reserve `AlertDialog` for genuine one-way doors.

The governing test, stated directly in memo#798:

> **"If the action can succeed without an answer from the user, do it — then confirm."**
> A modal that gathers *optional* input before an irreversible-but-safe action is a blocking step
> that shouldn't exist.

| Situation | He picks | Why |
|---|---|---|
| Action needs input, but the input has a sane default (usually "none") | **Do it now; confirm in a toast; offer the input inside the toast as a `ghost` secondary opening a popover in place** | memo#798: publish stopped asking for Vaults first. "It publishes straight away and confirms with a toast." The work the modal did is still one click away, blocking nothing |
| The button has *two code paths* — first-run vs. every other time | **Delete the first-run path** | "Two code paths for the same button is the smell that the first-run step is unnecessary." `handlePublish` no longer branches on `lastPublishedDate` |
| A create action that opens a setup dialog to collect name + options | **Build a sensible default (`'Untitled map'`) and drop straight into the editor, where every option already lives** | bp2#7196 deleted a 487-line `MapSetupDialog` + 207-line combobox. "drops straight into the editor, where every option lives" |
| A review/confirm step whose destination is already editable in place | **Write straight through and toast the count** | "The review step is dropped: pairs now save straight to the deal, where each one is already editable" |
| A confirm dialog guarding an action with nothing to lose | **Skip the dialog** | `[interaction-pattern] Skip the confirm dialog when there is nothing to lose` |
| A yes/no you genuinely cannot take back | **`AlertDialog`** | reserved for exactly this |
| Consequential but recoverable, *with choices to review* | **`Dialog` + `showCloseButton={false}`** | bp2#6620: "`AlertDialog` is for a yes/no you can't take back. This screen asks the user to pick a strategy and read a receipt" |
| Native `window.confirm` / `beforeunload` for in-app navigation | **In-app `AlertDialog`; keep `beforeunload` only for real tab close** | two separate PRs |
| Success | **Silent** — the result on screen is the feedback | "A clean full success stays silent — the pins landing on the map say it" |
| Dead end, shortfall, or a required instruction | **Always surfaced** | "an add that found nothing looked identical to a broken button" |

Toast anatomy, when a toast is the answer (memo#798 is the reference implementation):

1. **A preview of the artifact that was made** — it stands in for the status icon and sits *beside* the
   copy, not above it, so the text column shares one left edge. "A green check says nothing a preview
   of the actual artifact doesn't say better."
2. **A one-line title**, plain statement of fact, sentence case: `Your memo is published`.
3. **A sentence saying where it now lives** — not that it succeeded.
4. **Actions**: primary → the artifact (`View in resources`, `target="_blank"` so the editor is never
   lost); the optional step the modal used to demand → `ghost` secondary whose label reflects state
   (`Add vault` → `Add more vaults`).
5. **Never auto-redirect the user away from what they were doing as the reward for finishing.**
6. Errors from the same button land in **the same toaster, same corner, same enter/exit** — not at the
   opposite end of the screen.
7. Interactive toast ⇒ `duration: Infinity`, dismissal driven off the countdown bar's `animationend`
   (one clock, so bar and dismissal cannot drift), paused while tab hidden / window blurred / hovered /
   popover open. Stable `id` so repeating replaces rather than stacks.

### P2 — Which explainer surface

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** Decision table; picking a row is a judgment call.

- **Tag:** ask
- **Blast radius:** flag

- **Trigger (a):** a `<Button size="icon">`/`<DropdownMenuTrigger>` with an icon child and **no** wrapping `<Tooltip>`. rg: `size="icon"` with no `Tooltip` within the enclosing element.
- **Trigger (b):** `<p className="text-xs text-muted-foreground">` rendered directly beneath a form field. → should be a `HoverCard` on a `CircleHelp` instead.
- **Trigger (c):** a second `<Dialog>` in a file whose purpose is to explain a row in the first one (names containing `Debug`, `Details`, `Info`, `Why`).
- **Trigger (d):** a `CircleHelp` **next to a toggle/checkbox**.

| Situation | He picks |
|---|---|
| Naming an icon-only control | **`Tooltip`**, terse — the shortest true name (`content="Bold"`, `aria-label="Bold text"`). Every icon-only toolbar button gets one |
| Explaining an *optional feature* beside its control | **`HoverCard` on a small `CircleHelp`** — not helper text under the field |
| Reasoning you need *while deciding* (why this change, what's in this count) | **`HoverCard` on the row** (`openDelay={150} closeDelay={100}`), never a separate dialog/debug modal — "must not cost a modal round-trip" |
| A **feature relocation** or a **new feature** the user must see once | **`Spotlight` coach mark** — page dims + `backdrop-blur-[2px]`, a ring cuts around the target, a card floats beside it. Same shared component for every intro (`CampaignFeatureIntro`, `DealPitchFeatureIntro`, deal-settings-moved) |
| A must-see announcement | `Spotlight` + **`dismissOnBackdropClick={false}`** — the button is the only exit; a backdrop click **shakes the card** (`translate3d` 0→−10→9→−6→4→0, 320ms, `cubic-bezier(0.36,0.07,0.19,0.97)`), skipped under `prefers-reduced-motion` |
| A passive tip | `Spotlight` keeping backdrop dismissal |
| A blocked state on a card | **A footer *of that card*** — bled to its edges, sharing its rounding — not a separate alert floating above or below |
| A non-blocking background failure | **Plain inline warning row** (downgraded from a `Banner` component), or a toast whose title names what failed and whose body says the work survived and where to fix it |
| An "explanation" that exists only to justify a toggle | **Delete the toggle.** bp2#7130 deleted a `Checkbox` + `HoverCard` + `CircleHelp` outright — "an affordance that requires a `CircleHelp` is a smell" |

Spotlight mechanics he standardized: prefer the **sides** of the target, shrinking to
`CARD_MIN_SIDE_WIDTH = 280` before falling back below → above → clamped corner, every position clamped
to `VIEWPORT_MARGIN = 24`; card `340px` (down from 400); union several rects into **one** hole and one
ring; `SPOTLIGHT_PADDING = 8` / `SPOTLIGHT_RADIUS = 8`; halo is an outward white ring
(`shadow-[0_0_0_4px_rgb(255_255_255/0.86)]`), never a colored outline; keep the **last measured rect**
during brief target handoffs or the coach mark "appears to dismiss itself"; gate on the user **focusing
the field it explains**, not on the container opening; return focus to that field on dismiss; persist
dismissal per-card in a 365-day cookie, with a hard-coded `RETIRE_AFTER` date so the nudge deletes
itself after the transition window.

### P3 — Menu vs. panel vs. palette

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** Decision table. The `DropdownMenuSub` → panel case is greppable (`checklist.md` #45, 3 hits) but the replacement is a rebuild.

- **Tag:** ask
- **Blast radius:** flag

- **Trigger (a), fully mechanical:** `DropdownMenuSub` / `DropdownMenuSubTrigger` / `DropdownMenuSubContent`.
- **Trigger (b), fully mechanical:** `{open && <div className="absolute` — a hand-rolled floating panel.
- **Trigger (c):** a `DropdownMenuContent` containing a `Switch`, `Slider`, `Select`, `Tabs`, or `Input`.
- **Trigger (d):** a `PopoverTrigger` whose child contains an `<input>`.
- **Trigger (e):** `onClick` on a `DropdownMenuItem` that sets a dialog open.

> **"A menu is for choosing one thing and leaving; a settings panel is for adjusting several and staying."**
> "A menu can only offer items; a panel can offer a *state*, so switches, tabs, selects and thumbnails
> all become legal."

| Situation | He picks |
|---|---|
| Pick one thing and go | `DropdownMenu` |
| More than one *kind* of control (switch + slider + preview + tabs) | **`PopoverContent` panel** (`w-80 p-0`, panel owns its own padding so separators run edge to edge). **Never** a nested dropdown with `DropdownMenuSub`/`SubTrigger`/`SubContent` |
| A hand-rolled `{open && <div className="absolute …">}` | **The Airy `Popover` primitive.** "consuming the component *is* the sharing mechanism" — and you get a real exit animation the hand-rolled panel never had |
| A popover whose anchor **contains an input** | **`PopoverAnchor`, not `PopoverTrigger`** — then guard `onInteractOutside` so clicking back into the anchor doesn't close it |
| A magic keyword typed into a document (`/generate`) | **A real `/` slash palette on `@tiptap/suggestion`** — the same mechanism as @-mentions — not whole-document string matching. Rows carry icon + bold label + muted one-line description + keywords, and an explicit `No commands` empty string |
| Filter/search that used to hide behind an icon-button reveal | **Search *is* the filter** — one expanding text field at the head of the filter bar, hoisted up to the page's filter nav |
| A dialog opened from a menu item | Render it **outside** the menu, controlled `open`/`onOpenChange` (selecting an item unmounts anything the menu owns); trigger with `onSelect` + `event.preventDefault()`, never `onClick` |
| One catch-all menu accumulating unrelated concerns | **Split into one floating control per concern**, mirroring the platform convention already on screen |
| Two menus for the same thing | **Delete the hand-rolled duplicate and point its entry at the real one** |
| >2 sibling buttons on a bubble menu | Collapse into one `Edit` dropdown (`SquarePen` + `ChevronDownIcon`) |

### P4 — Tabs vs. sections vs. accordion vs. toggle group

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** Decision table; splitting tabs by what the user is looking at needs the surface, not the diff.

- **Tag:** ask
- **Blast radius:** flag

- **Trigger (a):** ≥2 sibling `<Collapsible>`/`<Accordion>` blocks in one panel.
- **Trigger (b):** a hand-rolled two-state switcher — a bordered `<div>` of `<Button variant={x === v ? 'secondary' : 'ghost'}>`.
- **Trigger (c):** a `<Collapsible>` with exactly one child.
- **Trigger (d):** a `ToggleGroup type="multiple"` styled as a joined segment, or `Tabs` used to filter rather than to switch views.

| Situation | He picks | Why |
|---|---|---|
| The user only ever wants one group open | **Tabs** replacing a stack of accordions | bp2#7226: 3 `Collapsible` blocks → 3 tabs |
| Splitting those tabs | **By what the user is looking at, not by which object owns the setting** | "A marker/card/line split would have kept the old imbalance (two tabs holding two controls each, one holding eight)." Pin + its leader line are one visual object you tune together |
| A two-state **view** switcher | `Tabs` + `TabsList`/`TabsTrigger` — never a hand-rolled bordered div of `variant="secondary" \| "ghost"` buttons ("the primitive already handles keyboard nav, roles, and the active indicator") |
| A two-option **filter** inside a panel | **`ToggleGroup type="single" variant="outline"`** — "tabs imply switching views, a toggle implies filtering one" |
| An exclusive icon-only choice (alignment) | `Tabs`/`TabsList` of square `size-7` triggers with `aria-label`s — "the shared track makes the group read as one control" |
| Pick exactly one | Joined segmented group |
| Multi-select | **Separate bordered pills** — "a joined segment group is the convention for picking exactly one, so borrowing it for a multi-select misreads no matter how the on-state is styled" |
| A second authoring mode (solid/gradient) | **A tab pair on the existing control**, never a separate control — "a second entry point would double the surface area to learn" |
| A disclosure hiding its own only child | **No disclosure** |
| Two rows under a sub-heading at label weight | **No sub-heading — adjacency is enough** |

### P5 — Visual choices are pictures, never words

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** Building a preview thumbnail from real tokens is authored work, not a substitution.

- **Tag:** ask
- **Blast radius:** refactor

- **Trigger:** covered by **V55**. Additional mechanical shape: a `<RadioGroup>` with exactly 2 items whose labels describe consequences (`replace`, `keep`, `overwrite`, `merge`).
  - ⚠ Inversion guard: `bp2-6016`'s rule says a short single-select becomes an **inline chip row**, not bordered radio cards. Validated case 4 shows both rules fire on the same `RadioGroup` and disagree about the destination. Reconcile by consequence: **chips when the options are values** (a type, a status, a period); **cards when the options are outcomes the user must understand before choosing** (`Keep them` / `Replace them`).

- A **two-option visual choice** is a preview radio card, not a `<Select>`.
- A **layout choice** is a thumbnail preset with a `border-2` selection frame and a filled check badge.
- Build those thumbnails **from the real design tokens at miniature scale** — `aspect-video`, `Skeleton`
  bars with `animate-none`, a 1px `bg-border` divider — not screenshots, not icons.
- A **two-way consequential choice** is side-by-side selectable option cards (icon + title +
  consequence sentence), not radio rows.
- **Size** is discrete named steps (XS/S/M/L/XL), not a continuous range. A **bounded magnitude** gets a
  slider with its value printed on the label row; a **small integer** gets a stepper.
- Make the whole option card the `<label>` so the entire card is the hit target.

### P6 — Dedicated button vs. overflow menu

- **Tag:** ask
- **Blast radius:** refactor

- **Tag:** ask
- **Blast radius:** refactor

- **Trigger (a):** a hover-revealed `<Button>` whose only action is destructive (`Trash2`, `handleDelete`) on a card.
- **Trigger (b):** a capability reachable only from an icon inside an already-open viewer/panel (an `Info`/`Settings` toggle with no counterpart on the object itself).
- **Trigger (c):** a nav/header-level button for a feature that operates on a selected object.
- **Trigger (d):** an `isHovered` prop, enter/exit delay constants, or `aria-hidden` + `tabIndex={-1}` used to hide a still-actionable control.

| Situation | He picks | Why |
|---|---|---|
| A destructive action as the only hover affordance on a card | **Ellipsis menu with `variant="destructive"` alongside the non-destructive items** | bp2#7513: "Delete is no longer a one-click destructive action on hover." A single hover affordance that is only delete "makes the card's whole action budget destructive" |
| A capability reachable only via a bare icon inside a viewer | **A named menu item on the object itself** | "so relabeling a photo is discoverable instead of hidden behind a bare info icon" |
| Two-of-N inserts used constantly, N−2 rarely | **Promote the two to labelled icon buttons; leave the long tail behind `+ Add item`** |
| A secondary route in an overflow menu that answers the same question as a primary control | **Move it under the primary control's own click** — don't hide it in the menu |
| A top-level nav button for a feature that only makes sense in context | **Delete it; reach the feature from the object it acts on** | "A global button for an image tool forces a source-picking step that the in-context entry point skips" |
| Destructive actions repeated per settings section | **Once, in the panel header** |
| A still-actionable affordance behind hover | **Render it.** bp2#7679 retired an entire reveal apparatus (`isHovered` prop, enter/exit delay constants, `isRevealReady` state, `aria-hidden`, `tabIndex={-1}`) for `if (!canAdd) return null` |

And when an action *does* open a detail surface: **land the user on the exact field they came for**, not
on the surface's default state (the menu item sets `setIsInfoPanelOpen(true)` *and*
`setIsViewerOpen(true)`; a plain card click keeps the quieter default).

### P7 — Same thing twice ⇒ one shared thing

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** Promoting to `components/shared/` changes an exported API. `adversarial.md` adv-F36 downgrades the sibling 'prop with no caller → delete' rule to flag for the same reason.

- **Tag:** ask
- **Blast radius:** refactor

- **Trigger:** two or more **structurally identical** JSX blocks or `const` definitions across files — same component name defined twice, the same 3+ class-string, the same keyframe, the same placeholder literal.

Recurring, high-confidence, and always in the same direction:

- The same AI control in three flows → **one shared component**.
- Six hand-copied floating selection toolbars → **one `BulkActionsBar`**; features pass only their
  buttons as children.
- A feature-named one-off → **promote to `components/shared/` with a `children` slot the moment a second
  use appears**, and delete the baked-in placeholder art (`DealPitchIntroSpotlight` → `Spotlight`).
- Repeated `Tabs`/`TabsList`/`TabsContent` scaffolding → one `ImageSourcePicker`/`ImageSourceGallery`
  pair **exporting the shared placeholder string and grid class too** — "copy and layout are shared, not
  just markup."
- Sticky table headers → the shared `<TableHeader sticky>` prop, never a per-call-site
  `className="sticky top-0 z-10 bg-background"`.
- Extend a registry primitive with an **additive optional prop** (`hideArrow` defaulting to `false`)
  rather than forking it; make a shared component's canvas overridable via `className` rather than
  forking; escape hatches are `*ClassName` props plus a spread `statusProps`, not forked variants.
- When a shared asset replaces a local one, **delete the local component and its test mock in the same PR**.
- Every entry point into a flow opens **the same dialog** — a dropzone with its own inline form gets
  rewired to hand its files to the shared one.
- When one surface has an "Add content" menu, the sibling surface's bare Upload button becomes **the same
  dropdown with the same items**.

---

## 2. Empty states — the anatomy

- **Trigger, fully mechanical (the exact anti-pattern):** a `rounded-lg border … p-8 text-center` container holding an icon with `mx-auto size-8 text-muted-foreground`, an `h3`/`p` at `text-sm font-medium`, and a `<Button>`.
- **Second mechanical trigger:** the same action rendered **twice** in one surface — once in the empty state, once in the page toolbar.

The reference implementation is bp2#7193 (maps), which replaced this exact anti-pattern:

```
✗ <div className="rounded-lg border bg-background p-8 text-center">
    <MapIcon className="mx-auto size-8 text-muted-foreground" />
    <h3 className="mt-3 text-sm font-medium">No maps yet</h3>
    <p className="… max-w-sm text-sm text-muted-foreground">Create a map to start editing.</p>
    <Button className="mt-4" onClick={onCreate}><Plus />New map</Button>
  </div>
```

**Must be present**, in this order:

1. **A hero illustration of the artifact being created** — bespoke, built from Tailwind + a few local
   components, no new dependency and no imported SVG asset. Never an icon-in-a-rounded-box tile
   (bp2#6987 deleted `public/assets/megaphone.png` and the Hugeicons imports outright).
2. **`<hgroup>` with `text-lg font-semibold text-foreground` title + `text-base text-muted-foreground`
   description.** Title = the user's *goal*; description = what they'll be able to do with the result.
   `Showcase your property's nearby POIs`, not `No maps yet`.
3. **Exactly three `FeatureCards` rows** — imperative verb-phrase title (`text-sm font-medium`) + one
   sentence (`text-xs text-muted-foreground`) — ordered as the real workflow: **start → enrich → ship**
   (`Plot your property` / `Add nearby properties` / `Add it to your memo`).
4. **The primary action**, in an `EmptyStateActions` row.

Geometry: container `max-w-md`, text block `max-w-sm`, `flex-1 flex-col items-center justify-center
gap-4 px-4 py-10 text-center`.

**Must NOT be present:**

- A bordered card with `p-8 text-center` around the whole thing.
- A `text-sm` heading — an empty state's title is `text-lg`.
- **A second copy of the CTA.** The primary action lives in the page's standard toolbar chrome
  (`Page.FiltersNav`) present in *both* the empty and populated states — not duplicated inside the
  empty-state card *and* again in a bespoke page header. Delete the section-header CTA when the empty
  state carries one, and vice versa; when an editor toolbar *and* an empty state both offer the action,
  the section-header copy goes.
- A page-level `<h1>` + subtitle that only restates the tab you're on.
- A container that only ever holds optional chrome — compute `hasContextChips` and omit the whole row
  (an empty `p-2` flex row still eats 16px).
- An empty filler block reserved for footnotes that may not exist ("an empty gray band under a receipt
  reads as a loading failure").
- `None provided.` — omit the optional line entirely.
- A "select something to begin" state, once the surface can't render without a selection.

**Editable fields are the exception to all of the above.** An editable field's empty state is the
*document itself*: delete the fixed-height tinted panel with a button in it, render an inline
placeholder prompt in the real text style (`text-base leading-[1.7] text-muted-foreground`), clickable
anywhere to start typing (`role="button" tabIndex={0}`, Enter + Space, visible `focus-visible` ring).
The prompt then **persists as an `aria-hidden` overlay once focused** — it must look identical before
and after focus, never swapping to a plain CSS placeholder. Note bp2#7130 kept the old decorated panel
on the read-only branch: the CTA card is only wrong where the user can actually type.

**Optional inputs** are titled rows with a description and an `Add` action, not empty fields sitting on
screen; the label flips to `Remove` once filled, and removing clears the value. An empty *required*
field's affordance is a `Plus`, not an empty avatar or a chevron.

**Layout:** lay the illustration **beside** the copy in a horizontal row (`gap-8`/`gap-10`), not stacked
above centered text — "the illustration becomes a scene element rather than a bullet above the text."
In-state CTAs stack **primary full-width above a ghost secondary separated by a small muted "or"** — not
two equal-weight outline buttons side by side. Mobile gets a taller hit target that shrinks on `sm`.

**Animation:** staged entrance in **narrative order** — container settles, then focal element, then
connectors, then satellites — via the Web Animations API, siblings staggered by an index-derived delay
(`surface 500ms` → `pop(pin, 260)` → `lines 560 + i*120` → `cards 820 + i*150`). A "pop" is a
three-keyframe overshoot (`scale from → 1.12 @ offset 0.7 → 1`, `460ms ease-out fill: both`), not a
linear fade. Lines are drawn by measuring (`getTotalLength()` → `strokeDasharray`, animate
`strokeDashoffset` to 0). Pieces start hidden via a **scoped** CSS rule (`.maps-illustration [data-anim]
{ opacity: 0 }`) and the reduced-motion branch **reveals them imperatively** — skipping the effect would
leave reduced-motion users an invisible illustration. The whole illustration is one `aria-hidden` node;
don't label its parts.

**Four distinct states, never conflated:**

| State | Copy |
|---|---|
| Nothing exists | `No vaults on this deal yet` |
| Nothing matches | `No vaults match that search` |
| Not yet (in flight) | A shaped placeholder at the real aspect ratio — **not words**. "'Nothing here' is the wrong sentence for 'not yet'" |
| Failed | Read `error`/`refetch` and render a **retry** state — never the empty copy |

Two more: a search dropdown's empty state is **an opportunity, not a blank** — put the bulk/alternate
route there and swap it for results once the user types. And widen a deliberately tight search **once**
rather than showing an empty list, *merging* the wider response instead of replacing it.

---

## 3. Loading — skeleton vs. spinner vs. nothing vs. optimistic

- **Trigger (a), mechanical:** `<LoadingDots`, `<Loader2`, or `<Spinner` in a file that also matches `/ai|agent|generate|enrich|screen|extract|cortex/i`.
- **Trigger (b), mechanical:** a `<Skeleton` inside a column definition whose `id`/`accessorKey` is `actions`.
- **Trigger (c):** a `<Skeleton className="bg-muted` or any `<Skeleton>` rendered on a `bg-muted` parent.
- **Trigger (d), mechanical:** a spinner rendered as a **sibling** of the button that triggered the mutation (`{isPending && <Loader2 …/>}<Button>`), rather than inside it.
- **Trigger (e):** a `setOpen(false)` in the same handler as an `await mutate(…)`.
- **Trigger (f):** a `useEffect(…, [])` that measures an element, next to a `src`/`url` prop that can change.
- **Trigger (g):** `getBoundingClientRect()` used for a size in a subtree that has a `transform`/`scale` class or animation.
- **Trigger (h):** an `aria-live` region with no `empty:hidden`.
- **Trigger (i):** **any awaited call whose expected duration exceeds ~30s** (an agent/LLM/generation/export mutation) rendering a status indicator whose *content is constant* — a spinner alone, or a single `<p>` of fixed text.

### P8 — The decision

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** Decision table. 'Would this skeleton resemble the empty state?' compares two designs side by side.

- **Tag:** ask
- **Blast radius:** flag

| Situation | Treatment |
|---|---|
| A skeleton that would resemble the empty state | **Render nothing.** `if (isLoading) return null`. "a skeleton that looks like 'nothing here' is worse than a blank frame" — he deleted the skeleton grid outright |
| Structured content whose shape is known (rows, cards, a form) | **Skeleton, mirroring the real geometry exactly** |
| A single control's own mutation | **Spinner *in that control*, in place** |
| A whole-UI reshaping operation | **Masking overlay + spinner + present-participle label** |
| An AI / Lev Agent action | **`MorphingLevIcon` / `MorphingLev` + `animate-morphing-rotate`** — never the generic `Loading` spinner |
| Ordinary data fetching, form submit, table loading | The generic `Loading` spinner — explicitly *out of scope* for the morphing icon |
| A long generative wait | **The real product view doing the work**, with the user's own content on screen, animating continuously |
| A background job | **The real product view**, with the not-yet-possible CTA hidden — not a spinner step |
| Re-querying with results already on screen | **Keep the stale results.** Show "Searching…" only from empty. Never replace a populated list with a status row on every keystroke |
| An actions column | **`null`** — actions are an overlay, so the skeleton cell renders nothing |

### P9 — Skeleton rules (all high-confidence, all the same rule)

- **Tag:** flag
- **Blast radius:** flag
- **Note:** **Not statically resolvable.** `adversarial.md` adv-F27: Skeleton-on-`bg-muted` 'requires knowing the ancestor background — grep sees the `<Skeleton />`, not its container.' adv-F34: 'a row skeleton whose geometry differs' is 'unmeasurable without rendering both.' `checklist.md` #41 agrees (read-the-component). The one mechanical clause here — `aria-live` gets `empty:hidden` — is carried by `checklist.md` #32 instead.

- **Tag:** auto
- **Blast radius:** mechanical

- **A skeleton mirrors the real layout's shape, not a generic block stack** — and shrinks when the real
  layout does.
- Row skeletons: **same icon box, same text width, same padding** as the row they replace
  (`<div className="flex items-center gap-2.5 px-1.5 py-2"><Skeleton className="size-4" /><Skeleton
  className="h-3 w-28" /></div>`).
- Two bars sized for a first and last name, not one.
- A loading state **occupies the exact same box** as the state it replaces — reuse the identical
  positioning wrapper and the identical `<img>` classes, don't re-derive them. A placeholder shares the
  real thing's aspect/size resolver rather than hardcoding dimensions.
- A collapsing skeleton must collapse **with** the content it stands in for (`group-data-[collapsible=icon]:hidden`
  on the `Skeleton` as well as the value, or the icon rail shows a stray grey bar).
- **Don't reach for `Skeleton` on a `bg-muted` surface** — it *is* `bg-muted` + `animate-pulse`, so it's
  invisible against its own backdrop. Use a sweeping shimmer (`.lev-shimmer`) built from
  `--foreground`/`--background` via `color-mix`.
- A missing asset renders a **labeled dashed placeholder box at the final aspect ratio**, not a
  collapsed slot.
- `aria-live` status regions get **`empty:hidden`** so they don't reserve space when silent.

### P10 — In-flight control rules

- **Tag:** ask
- **Blast radius:** mechanical
- **Note:** The icon/label/disabled swap is mechanical once a human confirms the control owns the operation.

- **Tag:** ask
- **Blast radius:** refactor

- **The in-flight button swaps its own icon for `Loader2` and its label for a present participle, and
  disables itself.** Not a spinner beside it, not a silent disable.
- **Keep the popover open and spin the button that was clicked** until the operation resolves — "never
  close on click and leave the outcome elsewhere." "Closing immediately meant a slow add looked like
  nothing had happened."
- An in-flight destructive action replaces **its own glyph** with a spinner in place — not a separate overlay.
- Progress lives on the button that started it; **the toast only appears on success** — no interstitial
  "publishing…" toast.
- Let an action callback return `void | Promise<void>` so the form can await it — widen the type rather
  than firing and forgetting.
- A multi-minute run gets **cycling status copy on a fixed-height line**, a spinner on the submit
  button, and a warning not to leave the tab — never one frozen line.
- While a query runs, keep the submitted query visible: swap the live input for a truncated
  `aria-hidden` echo, put the real input in `sr-only`, clear it in `finally`.

### P11 — Reuse the feature's own vocabulary

- **Tag:** flag
- **Blast radius:** flag
- **Note:** **Guidance, not a check.** 'One visual identity across empty → loading → filled' cannot be detected; it is a design instruction for authoring.

- **Tag:** ask
- **Blast radius:** flag

`DealPitchLoading`'s `<LoadingDots />` became `<SpeechBubble variant="dots" />` — the same object the
empty state shows now "types" while generating. **One visual identity across empty → loading → filled.**
Same instinct at the extreme end: bp2#7130 replaced a centered spinner panel with an in-place *agent
presence* state — typed thoughts + a collaboration-cursor caret **in the content's own type scale and
box** (`text-base leading-[1.7]`, `role="status"` + one `sr-only` line, everything visual `aria-hidden`).

### P12 — Measurement traps he documents

- **Tag:** flag
- **Blast radius:** flag
- **Note:** **Reference, not a check.** A list of measurement traps to read before writing a measuring effect.

- **Tag:** flag
- **Blast radius:** flag

- **Pin a preview's height** rather than letting a measured child settle into it — "anything measuring
  this element on mount (sonner caches a toast's height once) would otherwise record that transient size."
- "Painted" means image count **stopped changing** *and* nothing pending — with a hard timeout
  (`READY_TIMEOUT_MS = 1500`, `SETTLE_QUIET_MS = 120`) so a slow asset can't hold the UI shut.
- Never animate a half-assembled thing: gate the entrance on `onReady`.
- A `loadingFallback` cross-fades out on load and **re-arms whenever `src` changes** — "a skeleton that
  never clears (or never re-arms) is the same 'frozen' failure."
- Build a **fixture route rendering every state** of a complex component, with a theme toggle, so states
  can be reviewed without the live data source. A hover card has four states, **each its own
  component**: skeleton, error, unavailable, body.

---

## 4. Overflow & truncation

### P13 — `min-w-0` — the most-repeated mechanical rule in the corpus

- **Tag:** auto
- **Blast radius:** mechanical
- **Note:** The corpus's most-repeated mechanical rule. Gated per `adversarial.md` adv-F37: apply **only when the direct parent is a `flex`/`grid` in the same file and expression** — 'implemented naively it adds `min-w-0` to the wrong node and changes layout.' Note `checklist.md` #3 demotes this to `[flag]` read-the-component; adversarial overrides, with the guard.

- **Tag:** auto
- **Blast radius:** mechanical

> **"Every flex item in a chain that can receive text needs `min-w-0` — flex items default to
> `min-width: auto`, so one unbroken string silently widens each ancestor past its container."**

- `truncate` is **inert** unless every flex ancestor can shrink. Add `min-w-0` at *every* level.
- `shrink-0` the trailing indicator (icon, chevron, badge, count) so it's never the thing that gets cut.
- Pair `min-w-0` with **`break-words` on the text node itself** — constraining width only helps if the
  string is allowed to break.
- Also needed on: `<fieldset>` (defaults to `min-inline-size: min-content`), every grid item that can
  receive unbreakable content, and an auto-sizing input's invisible sizer (which needs `overflow-hidden`
  to zero its automatic minimum size).
- Two-pane layouts need `min-h-0` / `min-w-0` at **every** flex/grid level plus `truncate` on every text
  cell — "every free-text field here is unbounded."
- Table cells with variable-length text: `min-w-0` + `overflow-hidden`. Cells holding popovers/badges:
  `min-w-0` + **`overflow-visible`** instead.
- Truncate long inline text with `truncate` + `min-w-0`, **not `whitespace-nowrap`**.

### P14 — What gives way

- **Tag:** ask
- **Blast radius:** mechanical
- **Note:** Which element yields is the judgment. This file's own §6.2: 'a linter can spot a missing `min-w-0`; it cannot know whether the first name or the initial should shrink.'

- **Tag:** auto
- **Blast radius:** mechanical

Never "everything truncates." Exactly one element is designated to yield:

| Content | Designated to yield |
|---|---|
| Two-part label (primary + disambiguator) | **The disambiguator.** `shrink-0` the primary segment and the separator; `min-w-0 truncate` the secondary |
| Compact name (first name + initial) | **The first name.** `min-w-0 truncate` on it, `shrink-0` on the initial, baseline-aligned with an em-relative gap |
| Chart tooltip row | **The series label.** Never the value |
| Breadcrumbs | **One designated crumb.** `min-w-0` at every level, `shrink-0` on the icons |
| Section title in a flex header | **Truncates; never wraps** — `min-w-0 truncate` |
| Multi-line descriptive copy in a menu item | **Wraps (`whitespace-normal`); never truncates** |
| A hero heading fed user text | **Scale down first**, then degrade to a shorter form of the same content. "Truncation is the last resort, not the first" |
| A record row in a dropdown | Let the row **wrap** (`items-start whitespace-normal`); `truncate` only the title span, `shrink-0` the status badge |
| One long value in a panel | Cap the **item** (`max-w-xs` on the value), never the panel — "one long value must not stretch the container" |

### P15 — Filenames — middle-truncate, always

- **Tag:** auto
- **Blast radius:** refactor
- **Note:** One correct answer (measured middle-truncation), but the fix swaps in a component and an invisible sizer — show the diff.

- **Tag:** auto
- **Blast radius:** mechanical

The extension is the most identifying part of a filename, and CSS truncation always eats it. Three
successive refinements, ending at measurement:

1. `truncate` on a filename — **always wrong**.
2. `middleTruncateFileName(name, { maxLength, prefixLength })`, budgets tuned **per surface** (chip
   `18/7`, dropdown row `34/16`, table cell `22/9`) and **shrunk when siblings join the cell**
   (`14/6` once a chevron and count appear).
3. bp2#7711's final form: **measure with canvas `measureText`**, Finder-style — `context.font =
   getComputedStyle(node).font` + binary search over code points. "Names were cut differently on every
   row — `.pdf` rendered as `.p` on some, `.pc` on others, from a fixed character budget fighting a CSS
   clamp." "CSS `text-overflow` couldn't do this — it leaves up to a character of blank after the
   ellipsis, and a visible space when the cut lands after one."

Two mechanical consequences of measured truncation:

- **Render an invisible full-width copy** of the text so table auto-layout keeps the column stable —
  "without it, each shortening lets the column shrink, which re-truncates smaller — a ratchet."
- Render the label's **trailing metadata (page, chevron) *inside* the truncating component as a measured
  `suffix`** (`SUFFIX_GAP = 6 /* Matches the gap-1.5 */`), so truncation slack never opens a gap before
  `(p. 1)`.

### P16 — Tooltip-on-truncate

- **Tag:** auto
- **Blast radius:** mechanical
- **Note:** Adding `hidden={!isTruncated}` is a substitution. **Collides with `visual.md` V39** (`title=` → a real `Tooltip`); `adversarial.md` adv-F13 requires the two to ship as one merged rule or they undo each other on a second run.

- **Tag:** auto
- **Blast radius:** mechanical

- **Put the full string in a `title` whenever you truncate in JS** — the tooltip is the recovery path.
- **Only when it actually truncated**: `hidden={!isTruncated}` / `hidden={!isClamped}`. "A tooltip
  repeating a value that is already fully visible is noise."
- **Decide "is this clamped?" by measuring the rendered DOM, never by a character-count heuristic** —
  and measure on **`onPointerEnter`**, not on mount: "keeps it off the render path and out of an effect
  — the tooltip's open delay is longer than the measurement."
- Cursor follows the truth: `isClamped ? 'cursor-pointer' : 'cursor-default!'`.

### P17 — Long lists — cap, then escape hatch

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** Caps are per-surface and measured, never global — three chips in the create-deal dialog, more in the upload dialog.

- **Tag:** ask
- **Blast radius:** refactor

- **Trigger:** a `.map(` over an unbounded array inside a container with a fixed `max-h-*` and `overflow-y-auto`, with no fade/border edge affordance and no "show all" escape.

- **Cap a list at a fixed number of visible rows and move the rest into a popover — never scroll an
  unbounded list inside a dialog.** Say the ratio in words next to the escape hatch.
- A growable list inside a panel **scrolls past a fixed row count** rather than growing the panel — and
  the negative-margin bleed goes on the **scroll container**, not the rows.
- A picker **lists every option and scrolls** — never rely on a server page size, never let the list run
  off screen.
- Cap a growable rich-text field's height and scroll it internally rather than letting the dialog grow.
- Chips that must fit one row **measure and shed themselves**: start at a max, shrink `visibleFileCount`
  while `scrollWidth > clientWidth + 1`, reset on resize. Caps are per-surface (three in the narrower
  create-deal dialog vs. more in the upload dialog).
- Body text clamps at `line-clamp-6` with a See more / See less toggle **that only renders when it
  actually clamps**.
- A panel that can outgrow the viewport scrolls **inside itself**, bounded by Radix's own
  available-height var, with `overscroll-contain`.
- A rounded box with square children needs `overflow-hidden` on the rounded box — **and the scroll must
  live on an inner element**, not the rounded one.
- Filter chips **progressively drop at container-query breakpoints** rather than letting the row scroll.

### P18 — Narrow columns

- **Tag:** auto
- **Blast radius:** mechanical
- **Note:** `colgroup` plus matching `TableHead`/`TableCell` widths, including the skeleton row. One right answer.

- **Tag:** ask
- **Blast radius:** refactor

Constrain a table column holding unbounded text via `colgroup` **and** matching `TableHead`/`TableCell`
classes (`w-[280px] max-w-[280px]`) — **including the skeleton row** — then truncate inside it, so it
can't push the actions column off screen. Give a horizontally-scrolling table an explicit `min-w-[…]`
so columns can't collapse when a sidebar opens.

### P19 — Edge affordances

- **Tag:** ask
- **Blast radius:** mechanical
- **Note:** `adversarial.md` adv-F33 **deletes** one clause of this rule: `overflow-x-auto` on a 'static/decorative' row is not detectable, and guessing wrong removes a real scroll affordance. The rest (mask over gradient, bottom padding for the scrollbar) is sound.

- **Tag:** ask
- **Blast radius:** refactor

- **Trigger:** a `.map(` over an unbounded array inside a container with a fixed `max-h-*` and `overflow-y-auto`, with no fade/border edge affordance and no "show all" escape.

- **Mask the content, don't overlay a gradient**: `mask-image` edge fade computed from live scroll offsets.
- Scroll-edge affordances are **borders reserved as transparent and coloured per side**, bled past the
  content — never a shadow that appears and shifts layout.
- An overflow-indicator hook must re-check on **content** change, not just resize — `ResizeObserver`
  misses `scrollWidth` changes.
- Give a horizontally scrolling row **bottom padding** so its scrollbar doesn't sit on the content.
- **Bleed a table to the card's edges so the crop reads as continuation**; fade only the bottom; say an
  omission outright with a `…` gutter rather than a side gradient.
- Preview art running off its frame is **cropped honestly** (`rounded-t-md border-b-0`, `justify-end`)
  rather than drawn as a complete card floating in space. Same instinct in the intro miniatures: let the
  frame bleed off the right and bottom to imply more content.
- A **decorative/static** preview row uses `overflow-hidden`, not `overflow-x-auto` — "a fake scrollbar
  in a mock is chrome the user can't use."
- An affordance promising a **fixed guarantee** must be a fixed size and *overflow* a small viewport
  rather than shrinking to fit and under-promising.
- Keep `overflow-visible` in **edit** mode on purpose and clip only in read-only — "overflowing content
  has to stay reachable while you're editing it."

### P20 — Stacking (the z-index sub-domain)

- **Tag:** auto
- **Blast radius:** mechanical
- **Note:** Fix on the ancestor that is genuinely a sibling; delete the ineffective inner z-index. Per `adversarial.md` adv-F19 the `z-10` → `z-[var(--z-sticky)]` half fires **only** on an element that is also `sticky`/`fixed` and outside `src/components/ui/`, never on `hover:z-*`.

- **Tag:** auto
- **Blast radius:** mechanical

- **Fix sibling stacking on the ancestor that is actually a sibling of the competing element.** Raising
  z-index on an inner wrapper cannot beat an outer sibling — bp2#6535's whole point.
- **Delete the inner z-index once the correct ancestor carries it.** A `calc()` on a z-index that
  provably had no effect is worse than none — it reads as deliberate ordering to the next reader.
- A hover-lift uses the **smallest value that wins locally** (`hover:z-[1]`), not a scale value
  (`z-10`) that can outrank real overlays.
- To let a child overlay escape: `overflow-visible` + `relative` on the ancestor, then order the stack
  **explicitly** (`z-[calc(var(--z-chat-overlay)_-_1)]` on the wrapper, `+2` on the card) so toolbar
  dropdowns still win. Popover z comes from the `--z-popover` token, never a raw number.
- Give a sticky footer/CTA block an explicit stacking context (`relative z-20`) so animated step content
  can't paint over the controls.
- **Verify the whole stacking neighborhood, not just the reported symptom** — bp2#6535's test plan
  checks the overlay above Deals, the Connectors menu above the overlay, *and* chat passing under the
  sticky breadcrumb.
- Delete the scrim behind a lightweight hover preview — "a hover-summoned panel isn't modal."

---

## 5. Hierarchy & density

### P21 — "Readable at a glance" — what he actually means

- **Tag:** flag
- **Blast radius:** flag
- **Note:** **Guidance, not a check.** Four operational tests for reading a surface ('ask what the element *reads as*'). Nothing here is detectable; it is what to think with.

- **Tag:** flag
- **Blast radius:** flag

Four operational tests, each grounded:

1. **Two things that differ must look different.** "Two choices differing by two placements would
   otherwise render identical avatar strips. Show the delta first so the choices look different at a
   glance" — the logo strip leads with the *relative complement* against the sibling choice, then fills
   from the rest, counting `+N` against the true total. Same instinct: aggregate `Other` buckets get
   alpha fill + softer inset dashed borders so they read as "not a real category"; `muted/regular`
   placeholders become `medium/foreground` once a value is set, because "weight and color are how a
   glance distinguishes 'filled in' from 'placeholder'."
2. **Ask what the element *reads as*, not what it is.** The load-bearing quote: *"Dropped the count
   Badge (the '3' a JL user took for '3 unresolved problems')."* A number beside a field reads as "N
   problems here" — so the count becomes a `ChevronsUpDown` affordance and the panel does the
   explaining. Also: "in the feedback session 'Exterior photo' read as a value, not a control."
3. **A sentence can't express a shape — show the shape.** "All 3 sources agree on this value" became
   rows grouped under the distinct values they report, most-backed first: *"three sources agreeing with
   one outlier is a bad extraction, four sources disagreeing is a field you can't trust, and both read
   as 'these sources report different values'."* And: the tick "shows the selected value is the
   *minority*, which no sentence or count could say."
4. **Controls that are peers are rendered at one scale.** "Shape and connector style were grids of
   labelled preview cards sitting next to colours rendered as bare 28px circles: a visual hierarchy
   between controls that are peers." → **"One control scale."**

### P22 — What gets promoted

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** §6.2: 'order records by meaning requires knowing what the records mean.'

- **Tag:** ask
- **Blast radius:** flag

- **Blocked / action-required items** out of their lifecycle status and into a dedicated group at the
  top — but *only* when genuinely still actionable (gate on lifecycle status, not just the missing data).
- **Unavailable/locked options sort last** — disabled state is the primary sort key, **ahead of relevance**.
- **The create action to the top of a records list**, separated, with records then ordered *by meaning*:
  primary → published → recency → alphabetical tiebreak (four levels, deterministic, so the list never
  reorders between renders).
- **Cheapest/safest option first**, pinned in a test so the list can't reshuffle between selections.
- **A count headline** = a big number + a small muted unit, not one sentence at one size.
- **A "see all" link** into the section header beside the heading, not centred beneath the grid.
- **An overflow menu next to the thing it acts on** (the title + count), not parked in the far-right
  action cluster.
- **A `Beta` badge everywhere the capability is entered** — the menu item (right-aligned) *and* the
  modal title, at the identical `Badge variant="secondary" className="px-1.5 py-0 text-[10px]
  leading-4"` spec in both. "Once the count stops being a badge, the badge slot is free for the thing
  that actually needs a chip."

### P23 — What gets demoted or deleted

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** The largest group in the corpus and the one that most needs the page above the diff. §6.2: 'Is this heading redundant? needs the page above it.' The one signal a linter may raise is the same action rendered twice in one surface (`checklist.md` #9) — flag it, let a human pick which copy dies.

- **Tag:** ask
- **Blast radius:** flag

- **Trigger:** a heading whose text duplicates an ancestor title; ≥3 `<Badge>` in one card; a stat tile row; a `<Label>` above a self-describing value (a name, an address); an `<h3>` + `<p>` pair where the `<p>` restates the `<h3>`.

The largest single group in the corpus. **Deletion is the default move.**

- **A section heading whose content is self-evident from the page title above it.**
- **A page `<h1>` + subtitle that restates the tab you're on.**
- **A panel heading + description when the trigger already says what it is and the tabs say what's inside.**
- **A dialog header that only restates the trigger** — open straight onto the first field, keep
  `DialogTitle`/`DialogDescription` as `sr-only` for the accessible name.
- **A section header left holding only a title** once its trailing action moved — and collapse the
  now-single-child `justify-between gap-3` flex row.
- **Any duplicated action**: the sidebar footer when the content header has it; the section-header CTA
  when the empty state has it; the always-visible CTA when the toolbar has it.
- **A control with no visible effect** — and the hidden flag that made another control a no-op.
- **A control whose two options are two spellings of the same value.** ("a pin whose name is really its
  address is *built* with the address in `name`, so it only ever chose between two spellings of one string")
- **Hide/show when delete already exists**; a "custom label" override once the canonical field became
  directly editable.
- **The concept the removed screen existed to explain** — "a concept that only ever surfaced in the step
  you deleted was never a real concept."
- **Decorative icons from table column headers** (a header is a plain muted label) and **per-row
  decorative badge icons** (the value is the content).
- **A live result-count pill** when the filter bar needs the space and the results bar already says it.
- **Stat tiles** on a card: demote metadata badges into one dot-separated meta line, move the rest into a
  hover card. "Don't spend card area on stat tiles."
- **Metadata badges, headings at label weight, sub-headings over two rows** — adjacency is enough.

### P24 — What gets grouped

- **Tag:** ask
- **Blast radius:** refactor

- **Tag:** ask
- **Blast radius:** flag

- **One question in one place.** Per-field visibility toggles that answer the same question as a
  settings group belong *in* that group, not scattered on each field. Collapse a stack of boolean
  `SwitchRow`s that answer one question ("what's on the card?") into a single multi-select — patching
  only what flipped so untouched fields keep inheriting the global default.
- **One row = one setting.** "The ticket asked for border colour + width folded into one row. Built it,
  and it reads as though the number belongs to the colour — two settings behind one label. Every row is
  one control now, which costs nothing at 32px rows."
- **A captioned rule between classes of decision**, not a second heading: `<div className="h-px flex-1
  bg-border" /><span>Unlock and launch</span><div className="h-px flex-1 bg-border" />` — "says *these
  below cost money* without adding a second heading."
- **Separator computed from the neighbour**, not by rendering two mapped lists:
  `isPrimary && nextMemo && !nextMemo.primary`.
- **Destructive/admin dropdown items behind a `Separator`, gated on role** — not interleaved with
  everyday actions.
- **A shared attribute named once as a group heading**, each option carrying only what differs.
- **Group label = small muted heading / uppercase micro-eyebrow**; section chrome = a **full-bleed 1px
  rule that cancels the container padding**, not a bordered card, not a filled bar. Hide a section with
  no items.
- Group overlay actions into **one cluster per corner**.
- **Metrics rows from a filtered data array**, never hand-written conditional JSX per metric — the
  separator becomes `index > 0`, so no leading/trailing `|` is possible, and a zero metric simply isn't
  shown (`if (metrics.length === 0) return null`).

### P25 — Row and card shape (the recurring geometry)

- **Tag:** ask
- **Blast radius:** mechanical
- **Note:** Row geometry is stated exactly enough to apply, but which shape a row should take is the call.

- **Tag:** ask
- **Blast radius:** refactor

- **Trigger:** a row rendering a name and its metadata concatenated on **one** truncating line; or a row whose children lack `min-w-0` on the flexible part and `shrink-0` on the fixed parts.

- **Two-line row**: name on line 1; `{distance} · {secondaryText}` in muted `text-xs` on line 2. Never
  name-and-address concatenated on one truncating line. Stack with `grid gap-0.5` + `min-w-0 flex-1`,
  truncating each line independently.
- **Record row**: title + status badge on the title line, muted metadata beneath.
- **Every setting row shares one shape**: optional muted icon → label taking the leftover → control
  pinned right, with a minimum row height so rows line up whatever the control. Factor these into named
  primitives with fixed geometry rather than repeating flex classes.
- **Nested/dependent control** → a small elbow glyph, not indentation alone.
- **Icon + two-line message**: icon in its own column with `mt-0.5` so the detail aligns to the
  headline's first letter. **Icon + one sentence**: inline, so it doesn't own a full-height gutter.
- **Name + subtitle in one column, action cluster beside it** — don't let actions share a row with only
  the title.
- **Wrapping menu item text** → top-align the trailing badge with `self-start`.
- **A selected row's highlight band reaches the panel walls**: bleed out by the panel's own padding, pad
  the content back. Active vs. hover are distinct surfaces: `bg-muted` active, `hover:bg-muted/50` hover.
- **Pin card preview art to the bottom (`mt-auto`)** so previews align across a grid of variable-length
  copy, with the same `pt-3` top inset everywhere.
- **Pin a metrics row absolutely to the card's bottom-right and reserve space with `pb-8`** — `mt-auto`
  made the metrics jostle the description as choices changed length.
- **Go cardless** where the artifact's own preview can be the object: drop border/bg/shadow, and the
  card becomes a hover target with padding rather than a frame. Make the whole card clickable with a
  stretched absolute link, real interactive bits above it on a higher `z`.
- **Footer**: secondary action left, primary pair right, `justify-between` with a `<span />` placeholder
  when the left slot is conditional so the primary buttons don't shift. Where actions aren't peers,
  replace `DialogFooter` with an in-rail block: secondaries share a `grid-cols-2` row, the primary gets
  `w-full` beneath.

### P26 — Chrome ownership

- **Tag:** ask
- **Blast radius:** refactor
- **Note:** Moving chrome between a canvas and its shell is a restructure.

- **Tag:** ask
- **Blast radius:** flag

- **Trigger:** the same control (search field, count pill, CTA) rendered inside **both** an empty branch and a populated branch of one component; or per-surface chrome that a parent already provides.

- **Filter/search/toolbar chrome sits OUTSIDE the table's scroll container** so the header pins directly
  below it; the results bar and empty state stay **inside** with the table.
- **Grouped table section headers are NOT sticky** — only the column header row is.
- **Hoist shared chrome above the empty/populated branch** so the two states differ only in content.
- **A canvas component renders the canvas; the editor shell owns the chrome.** Float the tool panel over
  the canvas rather than reserving a fixed sidebar column that steals canvas width. An editing canvas is
  **full-bleed** — don't letterbox the work area to a print aspect while the user is still editing.
  Output-format settings (paper size, orientation) move out of the always-open drawer into the
  export/publish dialog. Slide chrome is absolutely positioned **out of the content's layout flow**.
- **One code path for embed and page chrome** — don't fork the layout on `isEmbed`.
- **A panel that moves between hosts owns its own footer and padding**; the host passes `p-0`.
- **Move information out of a side panel and onto the thing it describes**: a per-page citations panel
  became a document-wide mode marking each citation in place.
- **Own an onboarding tour from the component it points at**, not from an unrelated neighbour.
- Keep doc comments truthful when behavior moves — **update the comment in the same diff**.

### P27 — Density thresholds (his actual numbers)

- **Tag:** flag
- **Blast radius:** flag
- **Note:** **Reference values, not a check.** `SEARCH_THRESHOLD = 5`, the `13rem–17rem` list column, three-vs-more chips — measured per surface. Cite them; never enforce them.

- **Tag:** flag
- **Blast radius:** flag

- **Trigger:** any hardcoded list-cap, column-width, or chip-count literal (`slice(0, N)`, `max-w-[Npx]`, `SEARCH_THRESHOLD`) introduced without a comment.

- **Search field appears at ≥5 items**: `const SEARCH_THRESHOLD = 5 /** Below this, a search field is
  more chrome than help. */`
- **Two panes when a review list exceeds a handful**: list column pinned `13rem–17rem`, `bg-muted/20` to
  recede the navigation half. "A single scrolling list of every change is not reviewable."
- **>2 sibling buttons on a bubble menu** → collapse into one dropdown.
- **Decorative constants scale with component size** — "a fan tuned for a 440px preview is wrong at
  92px, and so is its radius." A `radius?: 'lg' | 'md'` prop, not one value.
- **Group changes by the user's mental unit (the page), not a synthetic dedupe key** — "a change that
  appears on two pages is two things to approve, not one."
- **Sentence → structure** whenever the sentence would flatten a shape (§5.1.3).

---

## 6. Autofixable vs. judgment

**63 of 389 (16%) autofixable; 343 judgment.** By category:

| Category | autofixable | judgment | % auto |
|---|---|---|---|
| `overflow` | 20 | 37 | **35%** |
| `loading` | 7 | 24 | 23% |
| `responsive` | 4 | 11 | 27% |
| `empty-state` | 4 | 20 | 17% |
| `interaction-pattern` | 10 | 78 | 11% |
| `hierarchy` | 12 | 114 | **10%** |
| `component-choice` | 6 | 59 | **9%** |

The gradient is the finding: **`overflow` is nearly all mechanics; `component-choice` and `hierarchy`
are nearly all taste.** A skill should lint the former aggressively and only ever *ask* about the latter.

### P28 — Autofixable — with detection patterns

- **Tag:** flag
- **Blast radius:** flag
- **Note:** **This is an index, not a rule.** It is the detection table for the overflow/loading rules above (P13–P20) and duplicates rows now owned by `visual.md`, `interaction.md`, and `copy.md`. Read it to find a pattern; never treat a row as a separate check. Two rows must not be applied at all: `getBoundingClientRect().width` → `offsetWidth` (`adversarial.md` adv-F2 — 'not equivalent… a correctness regression'; `offsetWidth` does not exist on `SVGElement`) and the `overflow-x-auto` row (adv-F33).

- **Tag:** auto
- **Blast radius:** mechanical

These have a grep-able trigger and a single correct replacement.

| Detection | Fix |
|---|---|
| `truncate` on an element whose flex ancestors lack `min-w-0` | add `min-w-0` at every level; `shrink-0` the trailing icon/badge |
| `whitespace-nowrap` used to shorten text | `truncate` + `min-w-0` |
| `min-w-0` on a text node without `break-words` | add `break-words` |
| `<fieldset>` inside a flex/grid row | add `min-w-0` |
| A filename rendered with `truncate` | middle-truncate (measured); never right-truncate |
| JS truncation with no `title` attr | add `title={fullValue}` |
| `<Tooltip content={x}>` around a value that may be fully visible | add `hidden={!isTruncated}` / `!isClamped`, measured on `onPointerEnter` |
| `className="sticky top-0 z-10 bg-background"` on a `TableHead` | use `<TableHeader sticky>` |
| `overflow-x-auto` on a static/decorative row | `overflow-hidden` |
| Two z-index declarations for one stacking fix | delete the inner one |
| A horizontally scrolling row with no bottom padding | add it, so the scrollbar clears the content |
| A rounded container whose scroll lives on the rounded element | move scroll to an inner element; `overflow-hidden` on the rounded box |
| A panel that can exceed the viewport with no internal scroll | scroll inside itself, bounded by Radix's available-height var, `overscroll-contain` |
| `getBoundingClientRect().width` for layout measurement | `offsetWidth` (survives transformed ancestors) |
| `w-[…]` on `DialogContent` | `max-w-[…]` — **and repeat it at `sm:`**, or the base Dialog's own `sm:max-w-lg` silently wins |
| Hand-picked breakpoint column counts | `auto-fill` grid with a `min()` floor inside a max-width container |
| A mutation with a spinner rendered *beside* its button | swap the button's own icon for `Loader2`, label → present participle, disable it |
| A skeleton cell in an actions column | render `null` |
| A row skeleton whose geometry differs from the row | mirror icon box, text width, padding |
| An `aria-live` region with no `empty:hidden` | add it |
| `"None provided."` / an always-rendered optional line | omit the line |
| An always-mounted container of optional chrome | compute `has*` and omit the container |
| One empty-state string covering both cases | split "nothing exists" vs. "nothing matches" |
| A `<Label>` inside a `<div>` beside a radio/checkbox | wrap the whole row in `<label>` |
| `onClick` on a `DropdownMenuItem` that opens a dialog | `onSelect` + `event.preventDefault()`, dialog rendered outside the menu |
| A row-action reveal using bare `group-hover` + `opacity-0` | shared `group/table-row` scope, `pointer-events-none` → `auto` |
| A row-action `Tooltip` without `disableHoverableContent` | add it + `className="pointer-events-none"` on the content |
| A count `Badge` beside a value | `ChevronsUpDown`; let the panel explain |
| Decorative icons in `TableHead` | plain muted label |
| A `variant="outline"` full-width "add another" in a form | `variant="ghost"` |
| A `Button variant="link"` for "see more" | muted inline text link + trailing `ArrowRight className="size-3.5"` + `underline-offset-4 … hover:text-foreground hover:underline` |
| `Button` + `Sparkles` for a primary AI action | shared `LevAIActionButton` |
| A `DialogHeader` restating the trigger | `sr-only` `DialogTitle`/`DialogDescription`, open onto the first field |
| A wrapping menu item with a vertically centered trailing badge | `self-start` |
| `index === arr.length - 1` recomputed inline in a `.map` | extract the row component, pass `isLast` |
| Disabled options sorted by relevance | disabled state as the primary sort key |

### P29 — Judgment — ask, never auto-apply

- **Tag:** flag
- **Blast radius:** flag
- **Note:** **This is a meta-section, not a rule.** It states why the rules above are judgment calls. Nothing to detect.

- **Tag:** ask
- **Blast radius:** flag

These require knowing the product, the user, and what the surface is *for*. A skill should flag them as
questions with the rule quoted, never rewrite them.

- **Any §1 decision**: modal→toast, dialog deletion, menu→panel, tabs vs. toggle, dedicated button vs.
  overflow menu, tooltip vs. spotlight vs. banner. Every one of these depends on whether the input has a
  sane default, whether the action is recoverable, and whether the user must see it once — none of which
  is visible in the diff.
- **Every deletion in §5.3.** "Is this heading redundant?" needs the page above it. The one recoverable
  signal a linter *can* raise: **the same action rendered in two places within one surface** — flag it,
  let a human pick which copy dies. (He himself reversed one of these across two PRs: bp2#7130 embedded
  the quick-actions chromeless under the title, bp2#7147 put them back as a titled section below — and
  deleted the `chromeless`/`belowTitle` plumbing rather than leaving it dead.)
- **Promotion order and sort keys** — "order records by meaning" requires knowing what the records mean.
- **Empty-state copy** (title = goal, description = outcome) and the three feature rows in workflow
  order. Detectable only as *shape*: flag a bordered-card empty state with a `text-sm` heading; the
  replacement copy is a human's.
- **Illustration and staged-entrance choreography** — narrative order is authored, not derived.
- **Which element is designated to yield** in a truncation chain. A linter can spot a missing `min-w-0`;
  it cannot know whether the first name or the initial should shrink.
- **Truncation budgets** and density thresholds (`SEARCH_THRESHOLD = 5`, `13rem–17rem` list column,
  three-vs-more chips per surface) — measured per surface, not global.
- **Skeleton vs. nothing.** "Would this skeleton resemble the empty state?" is a judgment about the two
  designs side by side. Same for "does this loading state occupy the same box as what it replaces."
- **Density and scale peer judgments** (§5.1.4) — "controls that are peers must be rendered at one scale"
  requires knowing which controls are peers.
- **Anything where he overrode the ticket.** Two documented instances in the corpus: the folded
  colour+width row ("Built it, and it reads as though the number belongs to the colour") and the
  marker/card/line tab split. Both were built, looked at in the running app, and rejected. That loop —
  build → drive it → correct the premise in writing — is not automatable, and it's the part of his
  process that produces the rules above.
