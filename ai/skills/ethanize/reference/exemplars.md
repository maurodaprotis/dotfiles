# Exemplars — 40 before/after pairs from ethanrblank's merged PRs

Teach-by-example corpus for `/ethanize`. Each entry is a mistake a competent engineer
plausibly ships, the correction Ethan made, and the class of situation it generalizes to.
Code is verbatim from the diffs. Copy/wording rules are owned elsewhere and excluded here.

Grouped by what you'd be *doing* when you'd hit it.

---

## Building a list or table

### Hover-revealed row action with only `group-hover`
Seen in: bp2#6548
Before:
```tsx
'relative -mr-1 flex size-5 items-center justify-center rounded-md text-muted-foreground transition-colors duration-150 after:absolute after:-inset-1 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground focus-visible:ring-2 focus-visible:ring-sidebar-ring focus-visible:outline-none'
```
After:
```tsx
opacity-0 transition-[opacity,background-color,color] group-focus-within/pipelines-heading:opacity-100 group-hover/pipelines-heading:opacity-100 group-has-[[data-state=open]]/pipelines-heading:opacity-100 focus-visible:opacity-100 pointer-coarse:opacity-100
```
Why: all four reveal conditions matter — `group-has-[[data-state=open]]` keeps the trigger visible while its own dropdown is open (otherwise moving toward the menu hides the trigger), the focus pair makes it keyboard-reachable, and `pointer-coarse:` means touch devices never lose the action. In bp2#6824 the same reveal also needed `pointer-events-none` → `group-hover:pointer-events-auto`, because `opacity-0` alone leaves an invisible click-eater over the cells beneath.
Generalizes to: every hover-revealed row affordance. The naive `opacity-0 group-hover:opacity-100` breaks keyboard, breaks touch, hides itself under its own open menu, and still swallows clicks.

### Hover and selected sharing one background
Seen in: bp2#6549
Before:
```tsx
'group-hover/table-row:bg-accent first:pl-4 last:pr-4 group-data-[selected]/table-row:bg-accent first:group-data-[selected]/table-row:shadow-[inset_3px_0_0_0_var(--foreground)] transition-shadow'
```
After:
```tsx
'first:pl-4 last:pr-4 group-data-[selected]/table-row:bg-muted/50 first:group-data-[selected]/table-row:shadow-[inset_3px_0_0_0_var(--foreground)] transition-shadow'
```
Why: "`bg-accent` on both hover and selected made the two states indistinguishable while the cursor was over the selected row; the `inset_3px` left bar is the real selection marker and `bg-muted/50` is just a soft tint behind it."
Generalizes to: any surface carrying both hover and selected states — they must stay separable while the pointer is on the selected item.

### `hover:` styling on a keyboard-navigable list
Seen in: bp2#7377
Before:
```tsx
'flex w-full items-center gap-3 rounded-lg px-3 py-2 text-left hover:bg-foreground/5'
```
After:
```tsx
cn('flex w-full items-center gap-3 rounded-lg px-3 py-2 text-left', isActive && 'bg-foreground/5')
onMouseMove={() => setActiveIndex(index)}
```
Why: "*Hover fought the keyboard.* Arrowing scrolls a row underneath a stationary pointer and `mouseenter` fires on that, snapping the highlight back to wherever the mouse was resting. It syncs on `mousemove` instead, so the mouse only takes over when it actually moves." One visual state, one class, "so there is never a hovered row and a separately highlighted one arguing about which Enter would take."
Generalizes to: comboboxes, command palettes, autocomplete menus — any list navigable by both arrow keys and pointer.

### The checkbox as the click target for a row
Seen in: memo#798
Before:
```tsx
<Checkbox checked={isSelected} onCheckedChange={() => onVaultSelect(vault.id)} />
```
After:
```tsx
// The whole row is the control, so the label carries the click rather than
// asking for a precise hit on the checkbox.
<label
  key={vault.id}
  className={cn(
    'flex cursor-pointer items-center gap-2.5 rounded-md px-1.5 py-2 transition-colors',
    isSelected ? 'bg-muted' : 'hover:bg-muted/60'
  )}
>
```
Why: his comment, verbatim above. Selected takes `bg-muted`, hover the lighter `bg-muted/60`, so the two never collide.
Generalizes to: any selectable list row built around a checkbox or radio — wrap in `<label>`, make the whole row the hit target.

### Negative margin used to enlarge a row's hover surface
Seen in: bp2#6530
Before:
```tsx
<div className="group/deal-row relative flex … rounded-md border border-transparent px-1 py-1.5 transition-colors duration-200 hover:border-border hover:bg-muted">
```
After:
```tsx
<div className="group/deal-row relative isolate -mx-2 flex min-w-0 items-center justify-between gap-2 rounded-md border border-transparent px-3 py-0.5 transition-colors duration-200 before:pointer-events-none before:absolute before:inset-x-0 before:-inset-y-1 before:z-0 before:rounded-md before:border before:border-transparent before:transition-colors before:duration-200 before:content-[''] hover:z-10 hover:before:border-border hover:before:bg-muted">
```
Why: the reviewer caught it — "`-my-2` on the `<li>` causes adjacent rows to overlap vertically. Since the `Link` uses `before:absolute before:inset-0` as a click target, clicking the bottom portion of a visible deal row can inadvertently trigger navigation to the next deal." (In the follow-up he also dropped `hover:z-10` to `hover:z-[1]` — a hovered row only needs to beat its siblings, not page overlays.)
Generalizes to: any row whose hover fill must bleed past its box. Use a `pointer-events-none` pseudo-element; never negative margins over a stretched-link click target.

---

## Building a panel or popover

### A hand-rolled absolute dropdown
Seen in: bp2#7317
Before:
```tsx
<div className="relative shrink-0"> … {open && (<div className="surface-glass absolute top-full left-0 z-10 mt-1.5 max-h-72 w-80 overflow-y-auto rounded-2xl p-1.5">…</div>)}</div>
```
After:
```tsx
<Popover open={open} onOpenChange={setOpen}><PopoverAnchor asChild>…</PopoverAnchor><PopoverContent align="start" className="surface-glass max-h-96 w-80 gap-0 overflow-y-auto rounded-2xl p-1.5" sideOffset={6} …>
```
Why: "The open/close transition comes from `popover.tsx` instead of being restated. There's no shared animation token in the design system — the `animate-in fade-in-0 zoom-in-95 slide-in-from-top-2 duration-100` recipe is copy-pasted into every Airy primitive — so consuming the component *is* the sharing mechanism." A hand-rolled panel also never gets an exit animation, focus management, or collision handling.
Generalizes to: every `{open && <div className="absolute">}` dropdown, menu, or tooltip.

### `PopoverTrigger` around a text field, held open by a blur timeout
Seen in: bp2#7317
Before:
```tsx
onBlur={() => window.setTimeout(() => setFocused(false), 150)}
```
After:
```tsx
<PopoverAnchor asChild> + onInteractOutside={(event) => { if (pillRef.current?.contains(event.target as Node)) { event.preventDefault() } }}
```
Why: "A Trigger renders a `<button>` (can't wrap the input) and toggles on click, so clicking back into your own search would close the panel. The anchor means Radix counts the pill as *outside*, hence the `onInteractOutside` guard."
Generalizes to: any combobox or search popover anchored to an input — and any `onBlur` + `setTimeout` race used to keep a panel alive.

### A shadow used to lift a control off content you don't control
Seen in: bp2#7205
Before:
```tsx
<Button
  className="absolute top-3 left-3 z-40 shadow-md"
```
After:
```tsx
<Button
  className="surface-glass absolute top-3 left-3 z-40"
```
Why: the issue said it plainly — "Give these buttons the glass treatment so that they become visible." A shadow does nothing over map tiles, imagery, or video. He then applied it to every control in the cluster, not just the one that was reported.
Generalizes to: controls floating over maps, photos, video, or user-uploaded backgrounds.

### A panel that grows past the viewport
Seen in: memo#668
Before:
```tsx
<DropdownMenuContent align="end" className="w-56">
```
After:
```tsx
<div className="max-h-(--radix-popover-content-available-height) overflow-y-auto overscroll-contain">
```
Why: with `collisionPadding={{ top: 56, right: 16, bottom: 16, left: 16 }}` — "the panel never grows past the screen and its scroll never chains out to the document behind it. `collisionPadding` keeps it clear of the toolbar it opens from."
Generalizes to: any popover whose content length is data-driven.

### `AlertDialog` for a flow with choices to review
Seen in: bp2#6620
Before:
```tsx
<AlertDialog> / <AlertDialogContent> / <AlertDialogTitle> / <AlertDialogCancel> / <AlertDialogAction>
```
After:
```tsx
<Dialog> / <DialogContent showCloseButton={false}> / <DialogTitle> / <DialogClose asChild><Button variant="outline">Cancel</Button></DialogClose> / plain <Button>
```
Why: "`AlertDialog` is for a yes/no you can't take back. This screen asks the user to *pick a strategy* and read a receipt — it needs normal dialog semantics and normal buttons."
Generalizes to: choosing between `AlertDialog` and `Dialog`. Content with inputs, choices, or a receipt is never an alert.

---

## Adding an empty state

### One empty state for two different situations
Seen in: memo#798
Before:
```tsx
<p className="text-muted-foreground px-1.5 py-6 text-center text-xs">No vaults</p>
```
After:
```tsx
<p className="text-muted-foreground px-1.5 py-6 text-center text-xs">
  {vaults.length === 0 ? 'No vaults on this deal yet' : 'No vaults match that search'}
</p>
```
Why: "nothing exists yet" and "your filter matched nothing" call for different next actions. One string can't serve both.
Generalizes to: every searchable list. Empty-because-new, empty-because-filtered, and empty-because-failed are three states.

### A skeleton indistinguishable from the empty state
Seen in: bp2#7196
Before:
```tsx
{isLoading ? (<div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">{Array.from({ length: 3 }).map((_, index) => (<div key={index} className="h-56 animate-pulse rounded-lg border bg-background" />))}</div>) : …}
```
After:
```tsx
if (isLoading) return null
```
Why: "dropped the misleading loading skeleton that resembled the old empty state." A skeleton that reads as "nothing here" is worse than a blank frame. The alternative he ships elsewhere (memo#798) is a skeleton that mirrors the real row exactly — `<div className="flex items-center gap-2.5 px-1.5 py-2"><Skeleton className="size-4" /><Skeleton className="h-3 w-28" /></div>` — reusing the row's own padding and gaps so nothing shifts on arrival.
Generalizes to: any list or grid placeholder. Either mirror the real row precisely, or render nothing — never a shape that reads as emptiness.

### An empty avatar as the "nothing selected" affordance
Seen in: bp2#6549
Before:
```tsx
<UserAvatar size="sm" />
<ChevronDown className="text-muted-foreground transition-colors group-hover/primary-contact-select:text-foreground" size={14} />
```
After:
```tsx
<Plus className="text-muted-foreground transition-colors group-hover/primary-contact-select:text-foreground" size={14} />
```
Why: "an empty avatar looks like a *loaded* record with no photo; a `Plus` says 'nothing here, add one'. The chevron was redundant next to a control that already reads as a picker."
Generalizes to: empty slots in table cells and inline pickers. Placeholder chrome that mimics loaded content reads as data, not as an invitation.

### A failed request rendered as an empty state
Seen in: bp2#7724
Before:
```tsx
versions.length === 0 ? 'No tables available'
```
After:
```tsx
error ? (<div className="flex flex-col items-center gap-2 px-3 py-4 text-center text-xs text-muted-foreground">Couldn&apos;t load the other tables<Button size="xs" variant="outline" onClick={() => void refetch()}>Try again</Button></div>) : versions.length === 0 ? …
```
Why: "`error` was never read, so a failed request rendered 'No tables available', which reads as a field with no alternatives rather than something retryable."
Generalizes to: every list, picker, or panel branching on `data.length === 0` without reading `error` — and the sibling case, showing empty copy while still loading.

### The action bar hidden exactly when the section is empty
Seen in: bp2#4894
Before:
```tsx
{hasResources && (<div className="flex items-center gap-2 animate-in fade-in">… Upload … </div>)}
```
After:
```tsx
<div className="flex items-center gap-2 animate-in fade-in">… Upload …</div>
```
Why: an empty section is exactly when "Upload" is needed. Gating the action bar on the collection being non-empty strands the user with nothing to click.
Generalizes to: any section header whose create/upload/add controls are conditioned on having content.

---

## Wiring an action

### Asking a question the action doesn't need answered
Seen in: memo#798
Before:
```tsx
const handlePublish = async () => {
  const isFirstTimePublishing = !memo?.lastPublishedDate

  if (isFirstTimePublishing) {
    setShowVaultLinkModal(true)
  } else {
```
After:
```tsx
// Publishing always lands the Memo in the deal's resources; Vaults are opt-in from
// the confirmation toast, so every publish behaves the same way.
const handlePublish = () => {
```
Why: "Publishing a Memo no longer asks you to pick Vaults first. It publishes straight away and confirms with a toast." The picker was a question whose answer had a sane default, so it moved inside the confirmation.
Generalizes to: any blocking step in front of a safe action. The tell is a branch on "have they done this before" — two paths for one button means the first-run step is unnecessary.

### Confirming with a native browser popup
Seen in: bp2#7205
Before:
```tsx
const deleteMap = async (draftId: string) => {
  if (!window.confirm('Delete this map?')) return
  await deleteDraft(draftId)
}
```
After:
```tsx
<AlertDialogContent>
  <AlertDialogHeader>
    <AlertDialogTitle>Delete map?</AlertDialogTitle>
```
Why: "Confirmation is handled in-app by the card's AlertDialog. Return the repository result so the dialog can keep itself open on a failed delete." A native popup can't hold pending or error state — that's what forces the change, not just the styling.
Generalizes to: every `window.confirm` for an in-app decision. Only a real tab close keeps the native prompt, because browsers allow nothing else there.

### A confirm dialog that closes whether or not the action worked
Seen in: bp2#7205
Before:
```tsx
<AlertDialogAction variant="destructive" onClick={onDelete}>
  Delete
</AlertDialogAction>
```
After:
```tsx
const handleConfirmDelete = async (event: MouseEvent) => {
  // Prevent AlertDialog's default close so we only dismiss on success and can
  // keep the dialog open (to retry) on failure.
  event.preventDefault()
  setIsDeleting(true)
  setDeleteFailed(false)
  try {
    // deleteDraft resolves false (not throws) when the delete fails, so check
    // the result — don't treat a failed delete as success.
    const deleted = await onDelete()
    if (deleted) setConfirmOpen(false)
    else setDeleteFailed(true)
  } catch {
    setDeleteFailed(true)
  } finally {
    setIsDeleting(false)
  }
}
```
Why: "`deleteDraft` resolves `false` on failure (doesn't throw), so I propagate the boolean … and only close the dialog when the map was actually deleted; otherwise it stays open with the error."
Generalizes to: every confirm/submit dialog on an async handler. The dialog is a state machine — pending label, disabled cancel, inline error, close only on success.

### Only the submit button disabled while the request is in flight
Seen in: bp2#6620
Before:
```tsx
// footer buttons disabled; RadioGroup and per-item remove still interactive
```
After:
```tsx
<RadioGroup disabled={isUnlocking} …>
const removePlacementHandler = isUnlocking ? undefined : onRemovePlacement
```
Why: "changing the strategy mid-request would apply a plan the user no longer sees. Same for removing a placement from the receipt."
Generalizes to: any submitting form or dialog — disable every input that feeds the in-flight payload, not just the submit control.

### A popover that closes before the action it fired resolves
Seen in: bp2#7225
Before:
```tsx
onClick={() => { if (category) { onAdd(...) } onDone() }}
```
After:
```tsx
onClick={async () => { if (!category) return; setIsAdding(true); try { await onAdd(...) } finally { setIsAdding(false); onDone() } }}
```
Why: "Stays open and spins until the add resolves, so the feedback is where the click was. Closing immediately meant a slow add looked like nothing had happened."
Generalizes to: any async action fired from a popover, dropdown, or dialog that dismisses itself on click.

### Opening a dialog from a menu item with `onClick`
Seen in: bp2#7205
Before:
```tsx
<DropdownMenuItem
  className="text-destructive focus:text-destructive"
  onClick={onDelete}
>
```
After:
```tsx
onSelect={(event) => {
  // Keep the menu's focus-return from swallowing the dialog open.
  event.preventDefault()
  setConfirmOpen(true)
}}
```
Why: the menu restores focus to its trigger as it closes, dismissing the dialog you just opened. Related, from bp2#7724: the dialog must also render *outside* the menu — "selecting an item closes it, which would unmount a dialog owned by that item before it could open."
Generalizes to: confirm dialogs, sheets, and popovers launched from any Radix menu item.

### A popover that steals focus from the input that opened it
Seen in: bp2#6890
Before:
```tsx
<Popover.Content
  align="start"
  className="z-[var(--z-popover)] hidden w-full group-focus-within:flex"
>
```
After:
```tsx
<Popover.Content
  align="start"
  className="z-[var(--z-popover)] hidden w-full group-focus-within:flex"
  onOpenAutoFocus={(event) => event.preventDefault()}
>
```
Why: "the address popover on the create deal card yanked your keyboard focus -- which interrupted you mid input. it was SO ANNOYING!!"
Generalizes to: every suggestion, autocomplete, or typeahead surface opened while the user is still typing.

---

## Adding motion

### A JS timer racing the progress bar that depicts it
Seen in: memo#798
Before:
```tsx
const COUNTDOWN_CLASS = 'animate-[toast-countdown_10s_linear_forwards]'
```
After:
```tsx
<div
  className={cn('bg-primary absolute inset-x-0 bottom-0 h-0.5 origin-left', COUNTDOWN_CLASS)}
  style={{ animationPlayState: isCountdownPaused ? 'paused' : 'running' }}
  onAnimationEnd={() => toast.dismiss(toastId)}
/>
```
Why: "The bar's `animationend` is what dismisses the toast, so the visual and the clock can't drift." `duration: Infinity` hands the whole clock to the element, and pausing the animation pauses the dismissal for free — on hover, on blur, on tab-hidden, and while the nested popover is open.
Generalizes to: any countdown, auto-advance, or auto-dismiss with a visual depiction. One clock, and it's the one you can see.

### A `filter` left on an animation with a fill mode
Seen in: bp2#6595
Before:
```css
@keyframes lev-sparkle-morph-in {
  0% {
    opacity: 0;
    filter: blur(2px);
    transform: scale(0.58);
  }
```
After:
```css
/* Blur lives in its own animations with the default `none` fill mode so it is
   only applied while actively morphing. */
@keyframes lev-sparkle-blur-in {
  0% {
    filter: blur(2px);
  }

  100% {
    filter: blur(0);
  }
}
```
Why: "A persisted `filter` (even blur(0)) keeps the element on a filter-backed layer that Safari rasterizes once at the animated scale and never refreshes, leaving the SVG permanently blurry."
Generalizes to: `filter`, `backdrop-filter`, and `will-change` inside any `forwards`/`both` animation — split them out so the resting computed style is `none`.

### Animating a size change by swapping `max-w-*` classes
Seen in: bp2#6636
Before:
```tsx
isUnlockMode || showLaunchReceipt ? 'sm:max-w-4xl' : 'sm:max-w-lg'
```
After:
```tsx
'gap-0 overflow-hidden p-0 sm:max-w-none sm:transition-[width] sm:duration-200 sm:ease-out motion-reduce:sm:transition-none'
'sm:w-[min(calc(100vw-2rem),var(--bulk-unlock-dialog-width))]'
style={{ '--bulk-unlock-dialog-width': strategyDialogWidth } as CSSProperties}
```
Why: "`max-width` swaps snap — the box jumps to the new constraint and content reflows in one frame. A variable-driven `width` is a single interpolable value." Note `sm:max-w-none` to get the constraint out of the way, and `min(calc(100vw-2rem), …)` so the animated width still respects the viewport.
Generalizes to: any size change you want animated — transition one interpolable property driven by a variable, never a swap between two constraint classes.

### `transition-all` sitting next to a layout property
Seen in: bp2#5824
Before:
```tsx
'… cursor-pointer select-none shrink-0 transition-all duration-200'
```
After:
```tsx
'… cursor-pointer select-none shrink-0 transition-[color,background-color] duration-200'
```
Why: with `transition-all`, the padding change added in the same PR would have animated the tab's width on hover — the exact layout shift the PR existed to remove.
Generalizes to: any interactive element with hover styling. Enumerate the animated properties so a later padding or width change can't silently become an animation.

### A live count rendered while the container animates out
Seen in: bp2#6548
Before:
```tsx
<div … data-open={…}>  // each surface rendered its own `{count} selected` span from the live selection
```
After:
```tsx
<BulkActionsBar count={totalCount || prevTotalCount.current} open={!!totalCount} onClearSelection={onClearSelection}>{actions}</BulkActionsBar>
```
Why: "the selection hits 0 the instant the user clears it, but the bar is still on screen for 200ms — rendering '0 selected' mid-exit is the artifact this pattern exists to prevent."
Generalizes to: anything that animates out while its content derives from the state that just emptied — toasts, drawers, selection bars, filter chips.

---

## Laying out a form

### A `<Select>` where a preview would decide it
Seen in: bp2#7200
Before:
```tsx
<SelectField
  label="Orientation"
  options={ORIENTATION_SELECT_OPTIONS}
  value={orientation}
  onChange={onOrientationChange}
/>
```
After:
```tsx
<ToggleGroupItem
  key={orientation}
  className="group flex h-auto flex-col items-center justify-center gap-2 rounded-md px-3 py-4 text-muted-foreground data-[state=on]:border-primary data-[state=on]:bg-primary/5 data-[state=on]:text-primary"
  value={orientation}
>
```
Why: "Orientation is now a page-preview radio card styled like the maps empty state." Show the shape rather than name it — and note he kept Paper size as a `Select`, because many options with no meaningful preview are still a select.
Generalizes to: two-to-four visual options (orientation, density, theme, layout). Radio cards with a miniature of the result.

### A controlled input rewritten under the user mid-keystroke
Seen in: memo#664
Before:
```tsx
value={hexValue.replace(/^#/, '')}
onChange={(e) => setHexValue(`#${e.target.value.replace(/^#/, '')}`)}
```
After:
```tsx
const [hexDraft, setHexDraft] = useState<string | null>(null)
value={hexDraft ?? hexValue.replace(/^#/, '')}
onFocus={() => setHexDraft(hexValue.replace(/^#/, ''))}
onBlur={() => setHexDraft(null)}
```
Why: "typing e.g. `C70F0F` would get clobbered mid-keystroke — at `C70` the 3-digit shorthand validated and the commit rewrote the controlled input to the expanded 6-digit form, making characters 'appear from nowhere.'"
Generalizes to: any controlled field whose committed value is normalized — phone, currency, dates, hex. Hold a focused draft, commit on blur.

### A focus ring on the inner input of a composed field
Seen in: memo#663
Before:
```tsx
<Input className="h-8 px-2 text-sm font-mono border-border focus:border-border focus:ring-0" />
```
After:
```tsx
<div className="flex h-8 flex-1 items-center gap-1.5 rounded-l-md bg-muted px-2 focus-within:ring-1 focus-within:ring-ring"><Hash className="size-3.5 shrink-0 text-muted-foreground" /><input … aria-label="Hex color" placeholder="000000" /></div>
```
Why: "the ring must surround the whole control including the affix icon, not just the text box." The inner input goes `bg-transparent … outline-none`, and keeps an `aria-label` since the visible label was dropped.
Generalizes to: any input with a prefix or suffix affix — icon, unit, currency symbol, or a joined pair of fields.

### A border that only exists on hover
Seen in: bp2#7031
Before:
```tsx
'group relative min-w-0 w-full rounded-xs outline-offset-4 focus-within:outline hover:outline'
```
After:
```tsx
'group relative -mx-2 -my-1 min-w-0 rounded-md border border-transparent px-2 py-1 transition-colors hover:border-border'
```
Why: a border added on hover alone shifts layout by 1px. The transparent border reserves the geometry, and the `-mx-2 -my-1` + `px-2 py-1` pairing puts the hover border *around* the text without reflowing it.
Generalizes to: every hover- or focus-revealed border on borderless inputs, inline-editable fields, chips, and cards.

---

## Handling long or missing content

### `truncate` on a child whose flex ancestors can't shrink
Seen in: bp2#6399
Before:
```tsx
<div className="group/membership relative flex items-center">
<span className="flex-1 truncate">{label}</span>
<Check className={isSelected ? 'opacity-100' : 'opacity-0'} size={16} />
```
After:
```tsx
<div className="group/membership relative flex min-w-0 items-center">
<span className="min-w-0 flex-1 truncate">{label}</span>
<Check className={cn('shrink-0', isSelected ? 'opacity-100' : 'opacity-0')} size={14} />
```
Why: "`truncate` is inert unless every flex ancestor can shrink below content width." The trailing indicator needs `shrink-0` or it collapses instead of the text. In memo#672 the same chain also needed `break-words` — constraining the width only helps if the string is allowed to break.
Generalizes to: every flex row ending in truncated text plus a trailing icon or badge — menu items, list rows, table cells.

### A flex row of crumbs with no designated truncator
Seen in: memo#790
Before:
```tsx
<div className="flex items-center justify-between w-full mr-4">
  <Breadcrumb className="flex-1">
    <BreadcrumbList>
```
After:
```tsx
{/* `flex-1`, not `w-full`: NavMain renders the user menu as a sibling, so a full-width
    row overflows the header by that menu's width plus this margin at every viewport. */}
<div className="mr-4 flex min-w-0 flex-1 items-center justify-between">
  <Breadcrumb className="min-w-0 flex-1">
    <BreadcrumbList className="min-w-0 flex-nowrap">
```
Why: `min-w-0` at every level, `shrink-0` on the icons, `truncate` on the one crumb that gives way — plus `min-w-24` on it, because "without it a zero flex-basis surrenders every pixel under pressure and the title disappears entirely."
Generalizes to: breadcrumbs, toolbars, table headers. Decide which child truncates and give it a floor.

### Deciding "is it clamped?" from a character count
Seen in: bp2#7031
Before:
```tsx
const shouldTruncate = getNotePreviewText(content).length > NOTE_PREVIEW_LENGTH
```
After:
```tsx
setIsOverflowing(element.scrollHeight - element.clientHeight > 1)
```
Why: "Whether the clamped preview overflows depends on wrapping at the rendered width, so it has to be measured from the DOM rather than derived from the content string." Note the 1px tolerance for sub-pixel rounding, and the `ResizeObserver` re-run.
Generalizes to: every "See more", fade, or overflow-indicator decision. Measure the rendered box; never estimate from the source string.

### Truncating a filename from the end
Seen in: memo#790
Before:
```tsx
<span className="truncate">{source.sourceFileName}</span>
```
After:
```tsx
const truncated = middleTruncateFileName(fileName, {
  maxLength: FILE_NAME_MAX_LENGTH,
  prefixLength: FILE_NAME_PREFIX_LENGTH,
})
```
Why: "End-truncation would hide the extension, which is exactly the part that pairs with a file-type icon."
Generalizes to: filenames, paths, ids, hashes — anything whose tail carries meaning. Truncate the middle.

### A lookup that returns `null` for an unknown key
Seen in: bp2#7679
Before:
```tsx
if (!name || !isValidIconName(name)) return null
```
After:
```tsx
const FALLBACK_ICON = CircleIcon
const icon = ICON_BY_TAXONOMY_NAME[name] ?? FALLBACK_ICON; return <HugeiconsIcon icon={icon} {...props} />
```
Why: "`DynamicIcon` now degrades to a neutral circle rather than returning `null`, so a rename costs the right glyph instead of blanking the row."
Generalizes to: any lookup keyed on backend-supplied strings — icons, colors, labels, badges — where a miss currently collapses layout instead of degrading.

---

## Styling a surface, mark, or token

> This heading is an addition to the seven briefed — these are token/contrast decisions an
> engineer makes while building any of the surfaces above. Fold into the other sections if
> the skill's structure needs exactly seven.

### An opaque highlight that erases light text
Seen in: memo#790
Before:
```css
background-color: var(--source-highlight-bg);
color: var(--source-highlight-text);
```
After:
```css
--source-mark: color-mix(in oklab, var(--source-highlight) 60%, currentColor);
background-color: color-mix(in oklab, var(--source-mark) var(--source-mark-rest), transparent);
```
Why: "so they contrast in the same direction the text does — legible over light text, dark text, photos and solid fills alike. The previous opaque `emerald-100` made white text on a photo disappear." The accent keeps the majority so it still reads green, not grey — and the author's own text color is never touched.
Generalizes to: highlights, selections, mention chips, diff marks — anything painted over content whose background you don't control.

### Emphasis added as more fill behind the text
Seen in: memo#790
Before:
```css
--source-mark-hover: 55%;
```
After:
```css
/* 40%, not the 55% this started at: the wash is composited *under* the text, so on a
   dark slide with light text every extra percent eats the text's own contrast. Measured
   against white-on-navy the hovered mark ran 4.24:1 at 55% and 6.15:1 at 40%. */
--source-mark-hover: 40%;
```
Why: his comment, verbatim — with the numbers measured, not guessed. The emphasis he removed from the fill moved onto the underline, "which sits beside the glyphs rather than behind them."
Generalizes to: hover and active emphasis on marked text. Fill costs contrast directly; borders, underlines, and outlines cost none.

### Cards painted with the page background
Seen in: bp2#6320
Before:
```tsx
'group/kanban-board-card shadow-xs rounded-lg border bg-background p-3',
```
After:
```tsx
'group/kanban-board-card shadow-xs rounded-lg border bg-card p-3',
```
Why: in light mode `--card` and `--background` coincide, so the mistake stays invisible until a real elevation ramp lands — here the Deep Abyss dark theme. In the same PR, `isCompleted && 'bg-accent'` → `'bg-muted'`: `accent` is the hover response, `muted` is a resting de-emphasized state.
Generalizes to: anything reading as a card, popover, or raised surface — and any resting "done/selected/disabled" tint. Never `bg-background`, never `accent` at rest, even when they currently look identical.

### An inset box-shadow used as a hairline on an image
Seen in: memo#783
Before:
```tsx
shadow-[inset_0_0_0_1px_var(--border),0_18px_45px_rgb(15_23_42/0.18),0_2px_8px_rgb(15_23_42/0.12)]
```
After:
```tsx
rounded-lg … outline-1 -outline-offset-1 outline-[var(--border)] shadow-[0_18px_45px_rgb(15_23_42/0.18),0_2px_8px_rgb(15_23_42/0.12)]
```
Why: "an `inset` box-shadow paints beneath replaced content, so the image bitmap covered it. Switched to `outline-1 -outline-offset-1`, which paints above content and follows the radius." The drop shadow stays in `shadow-[…]`; only the hairline moves.
Generalizes to: bordering any replaced element — `img`, `video`, `canvas`, `iframe`. (memo#664 solves the same problem structurally, with a `pointer-events-none absolute inset-0` border div painted after the fill.)
