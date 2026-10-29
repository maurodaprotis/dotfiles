# FLOWS & FORMS — F* ruleset

Domain: consequential actions, confirmation, receipts/outcomes, multi-step flows, form UX.
Rule IDs `F1`–`F122`. Tags: `auto` = mechanical and safe to apply · `ask` = needs a product/implementation choice, present options · `flag` = report, never edit.

Sources: bp2#6016 #6043 #6056 #6146 #6183 #6363 #6457 #6474 #6548 #6620 #6636 #6642 #6804 #7031 #7130 #7196 #7200 #7205 #7225 #7226 #7317 #7520 #7558 #7679 #7724, memo#613 #783 #798, `ethan-voice-and-principles.md`.

**Already documented — cite, never restate:** Formik + Yup is the mandated stack in bp2, no `enableReinitialize`, no `Formik<Values>` generic, delay render until initial values are ready (`agents/react-19.md`). Four UI states handled explicitly; `MorphingLevIcon` + `shimmer` for AI waits, `Skeleton` for ordinary fetches (`agents/react-19.md`). `sonner` for top-level outcomes, `FormMessage` for inline errors, every input labelled, `sr-only` not `display:none` (`airy-rules/design-system-rules.md`). Dialog needs Title + Description; disabled-button tooltips need a non-disabled wrapper (`agents/shadcn-ui.md`). CTA verbs, sentence case, no terminal periods on labels (`airy-rules/copy.md`). This file is the UX layer above all of that.

---

## Rules — autofixable

### F7 — `AlertDialog` only for a yes/no you cannot take back; a flow with choices to review is a `Dialog`; `window.confirm` is never right.
- **Trigger:** an `AlertDialogContent` containing a `RadioGroup`, `Tabs`, `Select`, a cost/receipt table, or more than two action buttons; or `window.confirm(` / `window.alert(` anywhere in `src/`
- **Detect:** `AlertDialogContent` containing a `RadioGroup`, a list, or more than one paragraph; `window.confirm(` / `window.alert(` anywhere in `src/`
- **Fix:** `Dialog` / `<DialogContent showCloseButton={false}>` / `<DialogClose asChild><Button variant="outline">Cancel</Button></DialogClose>` + a plain `<Button>`
- **Except:** only `window.confirm`/`window.alert` removal is mechanical — the `AlertDialog`→`Dialog` downgrade is a judgment call, present it. And `beforeunload` stays for real tab close — bp2#7200 keeps `useBeforeUnload` and routes only in-app navigation through `UnsavedChangesGuard` on `router.events` `routeChangeStart`, because "browsers don't allow a custom dialog there"
- **Tag:** auto
- **Evidence:** bp2#6620 — "This screen asks the user to *pick a strategy* and read a receipt — it needs normal dialog semantics and normal buttons." bp2#7205 — "native popups break the product's visual language and can't hold error or pending state"

### F9 — Destructive confirmations name the object in typographic quotes, put the irreversibility in the body, keep the title short.
- **Trigger:** banned openers and generic button pairs on a confirm surface — `Are you sure`, `OK`/`Cancel` as a pair, `Please` — or a straight `"` or `'` inside a `DialogDescription` / `AlertDialogDescription` / toast `description` string
- **Detect:** straight `"` or `'` inside `AlertDialogDescription` / `DialogDescription` / toast `description` literals; a title carrying the consequence
- **Fix:** title `Delete map?`; body `"{draft.name}" will be permanently deleted. This can't be undone.` — curly `" " '`
- **Except:** only the quote characters are mechanical — moving the consequence out of the title into the body is a judgment call
- **Tag:** auto
- **Evidence:** bp2#7205

### F13 — When the user can't afford it, strike the number through — color alone doesn't say "doesn't apply".
- **Trigger:** `text-destructive` on a numeric row in a summary with no `line-through`
- **Detect:** a `text-destructive` on a numeric receipt row with no `line-through`
- **Fix:** `rightClassName={cn('font-normal', !canAfford && 'text-destructive line-through')}`, and swap the label (`Balance after unlock` → `Shortfall`) in the same slot
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6620 — "`line-through` says 'this number doesn't apply' — color alone doesn't, and fails for color-blind users"

### F15 — Render the footnote region only when there are footnotes.
- **Trigger:** a cost summary rendered as an undifferentiated list of label/value rows — every row the same weight, no `border-t` between line-items / totals / footnotes; or an always-rendered footnote container (`min-h-*` + `bg-muted/*`) not gated on content length
- **Detect:** an always-present filler block (`min-h-*` + a background) below a receipt
- **Fix:** `{receiptFootnotes.length > 0 && (…)}`, filtering to the charge-affecting note type only
- **Except:** non-charge notes still render — on the choice cards, not in the receipt
- **Tag:** auto
- **Evidence:** bp2#6620 — "an empty gray band under a receipt reads as a loading failure"

### F30 — A bulk-action button that acts on N items shows N inline and in its `aria-label`.
- **Trigger:** a bulk-action count derived from the *currently selected* mode (`plan.selectedChoice.x.length`, `mode === 'a' ? n : m`) rather than across all choices; or a button rendering `{count}` whose `aria-label` omits it
- **Detect:** a bulk button rendering `{count}` whose `aria-label` omits it, or an icon-only bulk button
- **Fix:** `<Button aria-label={\`Launch ${bulkLaunchCount} placements\`} className="gap-2 px-2" size="sm" variant="ghost"><Rocket size={16} /><span className="text-xs text-muted-foreground">{bulkLaunchCount}</span></Button>`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6620 — Ethan to a bot flag: "@Cubic this is intentional -- we want to show the count of available mutations"

### F31 — Build a metrics row from a filtered data array, not hand-written conditional JSX per metric.
- **Detect:** `{count > 0 && (<>…<span aria-hidden>|</span></>)}` chains
- **Fix:** an array `.filter((m) => m.placements.length > 0)` then `{metrics.map((m, i) => (<Fragment key={m.key}>{i > 0 && <span aria-hidden>|</span>}…))}`, with `if (metrics.length === 0) return null`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6620 — "the separator logic becomes `index > 0` — no leading or trailing `|` is possible"

### F34 — Guard an async action against double-fire: a ref released only on failure, or per-item pending state.
- **Trigger:** an async submit/create handler with no in-flight guard — no `if (pending) return`, no ref check — where the button is not disabled during the request
- **Detect:** an async `onClick` with no in-flight guard
- **Fix:** a ref released only on failure when success navigates away (bp2#7196); or `const [pending, setPending] = useState<Provider | null>(null)` + `if (pending) return` when several items share the handler (bp2#6016)
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7196, bp2#6016 — label becomes `'Connecting…'` for the pending item only

### F39 — Both outcomes of one button land in the same corner with the same treatment.
- **Detect:** a success path using a custom toaster and its error path using the default one
- **Fix:** same `toasterId` for both — `toast.error('Unable to publish', { toasterId: MEMO_PUBLISH_TOASTER_ID, description: 'Please try again later', classNames: { icon: 'text-destructive' } })`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#798 — "Same toaster as the success card, so both outcomes of Publish arrive in the same corner with the same enter/exit rather than at opposite ends of the screen"

### F45 — A toast carrying interactive controls sets `duration: Infinity`.
- **Trigger:** a `toast(` whose JSX children contain a `<Button>` or `<a>` and no `duration: Infinity`
- **Detect:** a `toast(` whose JSX contains a `<Button>`/`<a>`/input and no `duration: Infinity`
- **Fix:** add it, and dismiss only via a countdown the toast controls (F46)
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#798 — "an auto-dismiss would pull the vault picker out from under the user mid-selection"

### F48 — Give a repeatable action's toast a stable `id` so it replaces rather than stacks.
- **Trigger:** `toast.success(`/`toast.error(` in a handler reachable more than once with no `id`
- **Detect:** `toast.success(`/`toast.error(` in a handler reachable more than once with no `id`
- **Fix:** `const MEMO_PUBLISHED_TOAST_ID = 'memo-published'`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#798 — "publishing again replaces the card rather than stacking a second one"

### F50 — Clip a progress stroke with a full-size overlay carrying the card's radius.
- **Detect:** `rounded-*` applied to a element under ~4px tall
- **Fix:** wrap in `<div className="pointer-events-none absolute inset-0 overflow-hidden rounded-lg">`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#798 — "a 2px-tall box cannot hold a 10px radius, so rounding the stroke's own wrapper left its corners poking past the card's curve"

### F51 — Progress lives on the button that started it: spinner plus present-participle label. No interstitial in-progress toast.
- **Trigger:** a request that can exceed ~30s whose waiting state is a spinner, a `<Skeleton>`, or a **single fixed line of text** — one `<p>` inside `{isGenerating && …}` with no `AnimatePresence`, no message array, no interval
- **Detect:** a `toast.loading(` / `toast('…ing')` paired with a mutation that also toasts on success
- **Fix:** `{isPublishing && <Loader2 className="size-4 animate-spin mr-2" />}{isPublishing ? 'Publishing…' : 'Publish'}`, toast from `onSuccess` only
- **Except:** an AI/agent wait uses `MorphingLevIcon` per `agents/react-19.md` + `cubic.yaml`; bp2#7558 pairs a `MorphingLevIcon` status block with a plain `Loader2` in the submit button, which the cubic rule's own carve-out permits ("Do not flag ordinary data-fetching, form submit, or table loading spinners")
- **Tag:** auto
- **Evidence:** memo#798 — "the in-place button state covers the wait, the toast covers the result"

### F52 — Pending labels use the "-ing" verb plus the ellipsis character `…`, never three dots.
- **Trigger:** a request that can exceed ~30s whose waiting state is a spinner, a `<Skeleton>`, or a **single fixed line of text** — one `<p>` inside `{isGenerating && …}` with no `AnimatePresence`, no message array, no interval
- **Detect:** regex `'\w+ing\.\.\.'` in a label or children position
- **Fix:** `'Deleting…'`, `'Publishing…'`, `'Connecting…'`, `'Generating'`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7205, memo#798, bp2#6016, bp2#7558

### F60 — A destructive choice starts unanswered on every run; never inherited from the last one.
- **Trigger:** `initialValues` giving a **destructive** choice a non-null default (`existingMode: 'replace'`, `overwrite: true`)
- **Detect:** `initialValues` giving a destructive option a non-null default
- **Fix:** `existingMode: null`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7558 — "replace deletes the deal's FAQs and shouldn't be inherited"

### F61 — Step and disclosure state living outside the remounted form resets through one `close()` used by every exit path — Cancel and the success path included.
- **Trigger:** more than one call site passing `onOpenChange(false)` directly in a component that also holds disclosure state
- **Detect:** more than one call site invoking `onOpenChange(false)` directly
- **Fix:** `const close = () => { setIsChangingMode(false); setIsWritingInstructions(false); onOpenChange(false) }`, called from `handleOpenChange`, Cancel, and post-submit
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7558 — Ethan: "`Cancel` and the successful-save path called `onOpenChange(false)` directly, skipping the reset"

### F64 — Closed, the whole disclosure row is the trigger; open, only the action label is.
- **Detect:** one `<button>` wrapping both heading and content in an open disclosure
- **Fix:** open → `<div className="flex items-start justify-between gap-3">{heading}<button …>{actionLabel}</button></div>`; closed → `<button className="group flex w-full items-start justify-between gap-3 …">{heading}{actionLabel}</button>`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7558 — "clicking into the editor can't tear it back down"

### F67 — Give the sticky footer/CTA block its own stacking context.
- **Trigger:** a breakpoint-based decision about where secondary copy goes (`isDesktop ? <Footer/> : <Inline/>`); a step slide expressed as a pixel offset (`x: 80`, `x: -20`) while the container also recenters; an absolutely-positioned footer with no stacking context
- **Detect:** a footer sibling to animated step content with no `z-*`
- **Fix:** `relative z-20`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6056

### F68 — On the last step the primary CTA takes the full footer width.
- **Trigger:** a breakpoint-based decision about where secondary copy goes (`isDesktop ? <Footer/> : <Inline/>`); a step slide expressed as a pixel offset (`x: 80`, `x: -20`) while the container also recenters; an absolutely-positioned footer with no stacking context
- **Detect:** a terminal-step CTA at intrinsic width beside a Back button
- **Fix:** `isLastStep && 'flex-1'`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6056

### F72 — Placeholders are labelled examples with realistic domain values.
- **Detect:** placeholder values that are bare fake names (`Jane`, `Doe`, `Acme Capital`)
- **Fix:** `"e.g., Sarah"`, `"e.g., Chen"`, `"e.g., Bridgepoint Capital"`, `"e.g., (555) 123-4567"`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6016

### F73 — A placeholder ends in the ellipsis character `…` and says "Optional." explicitly when the field can be skipped.
- **Trigger:** a free-text *instructional* `placeholder` not ending in `…` — a labelled example such as `placeholder="e.g., Sarah"` is correct without one
- **Detect:** a free-text `placeholder` ending in `...` or in no terminator
- **Fix:** `"Add a question about this deal…"` / `"Optional. Leave blank to answer later…"`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7558

### F75 — Delete helper text that only restates what the control makes obvious.
- **Trigger:** helper text under a control that restates what the control's own affordance shows (`Select one` under a single-select, `One per line` under a placeholder that already demonstrates it)
- **Detect:** a `suggestion`/description prop reading "Select one", "Choose an option", or restating the control's affordance
- **Fix:** remove it
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6056 removed `suggestion={<span …>Select one</span>}` from two chip-group `FormField`s. bp2#7317 collapsed a `Label` + helper paragraph into `or paste a list of addresses` — "the placeholder already demonstrates one-per-line"

### F79 — Custom controls mark their field touched on blur; errors surface through `touched && errors`, never per keystroke.
- **Trigger:** free text sent without `.trim()`; a raw error object rendered into the UI (`{error.message}`, `JSON.stringify(error)`)
- **Detect:** a custom control (`role="radio"` button, chip) wired to `setFieldValue` with no `setFieldTouched`
- **Fix:** `onBlur={() => formik.setFieldTouched('referralSource', true)}`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6016; nothing in the corpus validates live-per-keystroke

### F80 — Trim before validating and before sending.
- **Trigger:** free text sent without `.trim()`; a raw error object rendered into the UI (`{error.message}`, `JSON.stringify(error)`)
- **Detect:** `if (!value) return` immediately followed by sending `value`, where `value` is free text
- **Fix:** `const trimmedQuery = query.trim(); if (!trimmedQuery) return` … `query: trimmedQuery`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6804 — "whitespace is not a query"

### F83 — An error row keeps body text at `text-foreground` and puts destructive color on the icon only.
- **Trigger:** `text-destructive` on a `<p role="alert">` that also contains an icon
- **Detect:** `<p className="…text-destructive…" role="alert">` whose child is an icon plus text
- **Fix:** move `text-destructive` onto the icon
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6620 — "all-red body text is less readable and drowns out the inline link inside it; the icon carries the severity"

### F85 — Inline links inside body copy are underlined text buttons with a visible focus ring, not styled `Button`s.
- **Detect:** a `<Button variant="link">` inside a sentence
- **Fix:** `className="rounded-sm font-medium underline underline-offset-2 focus-visible:ring-2 focus-visible:ring-ring/50 focus-visible:outline-none"`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6363

### F86 — A blocking warning is announced with `role="alert"`; informational guidance uses `role="note"`.
- **Trigger:** a paragraph containing `AlertTriangle` + blocking text with no `role`
- **Detect:** a paragraph containing `AlertTriangle` plus blocking text and no `role`
- **Fix:** `<p className="flex items-start gap-1.5 pl-3 text-xs leading-snug text-foreground" role="alert">`; guidance callouts get `role="note"`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6363 (`role="alert"`), bp2#6043 (`role="note"`)

### F87 — Insufficient and failure states use `destructive` tokens, never bespoke `error-*` ones.
- **Trigger:** bespoke error tokens — `text-error-foreground`, `bg-error-background`, `border-error-border`
- **Detect:** `text-error-foreground`, `bg-error-background`, `border-error-border` in app-owned code
- **Fix:** `text-destructive`, `bg-destructive/10`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6363

### F88 — Keep the input's content after a failure so the user can retry; clear it only on success.
- **Trigger:** a reset call (`setPrompt('')`, `form.reset()`, `setValue('')`) placed after the mutation call rather than inside its success branch
- **Detect:** an input cleared in a `finally`, or before the request resolves
- **Fix:** `setPrompt('')` in the success branch only
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#783 — "The prompt has been consumed — clear it so the composer is ready for the next edit. Failures below deliberately keep it around for a retry"

### F90 — Disable the submit until its required free-text input is non-empty, and make the handler's guard identical.
- **Detect:** a `disabled={…}` expression that omits a `!x.trim()` present in the handler's guard, or vice versa
- **Fix:** `if (disabled || isLoading || isSubmitting || !prompt.trim()) return` **and** `disabled={disabled || isLoading || isSubmitting || !prompt.trim()}`
- **Except:** a submit blocked by an unanswered *step question* is hidden instead — F59
- **Tag:** auto
- **Evidence:** bp2#7031 — "an enabled submit that does nothing is worse than a disabled one"

### F94 — Blocked-by-prerequisite is `Info` in muted tones, not `AlertTriangle` in destructive ones.
- **Detect:** `AlertTriangle` + `text-destructive` on a state where nothing has failed
- **Fix:** `<Info className="mt-0.5 size-3.5 shrink-0" />` on `bg-muted/60 text-muted-foreground`
- **Except:** insufficient credits keeps `AlertTriangle` / `text-destructive` — that is a failure
- **Tag:** auto
- **Evidence:** bp2#6457 — "nothing has gone wrong, a step is simply missing"

### F95 — Feature-flagged off renders nothing; blocked-by-missing-data stays visible and explains itself.
- **Detect:** a flagged feature rendering a disabled shell
- **Fix:** `if (!hasDealDataDashboard) return null`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6457

### F96 — Zero out the derived numbers when a feature is gated, and re-enforce the gate at the payload boundary.
- **Trigger:** a feature gate applied to controls but not to the derived numbers beside them (a price/count still rendered while the feature is off), or a payload field not re-gated at the boundary
- **Detect:** counts/pricing computed unconditionally while the controls are disabled; a submit payload reading a stale checkbox
- **Fix:** `const enabledFileCount = !hasFlag || isDisabled ? 0 : documents.filter(…).length`; `includeInExtraction: factExtractionEnabled && (doc.includeInExtraction ?? false)`, plus `if (!factExtractionEnabled) return` at the top of each toggle handler
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6457 — "so the card never advertises credits it won't charge"

### F97 — A disabled trigger loses its hover affordance explicitly, not just its pointer.
- **Detect:** a `hover:underline` / `hover:text-*` class on an element that also takes `disabled=` and has no `disabled:` classes
- **Fix:** `disabled:cursor-not-allowed disabled:text-muted-foreground/50 disabled:hover:no-underline`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6457

### F100 — Autofocus the field a disclosure just revealed; never the first field of a step or dialog on open.
- **Detect:** `autoFocus` on the first field of a dialog; or a revealed editor with no `autoFocus`
- **Fix:** `<Textarea autoFocus …>` inside the `Reveal`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7558; no corpus instance autofocuses a step's first field

### F101 — When a popover holds the caret, prevent both of Radix's autofocus moves.
- **Detect:** `PopoverContent` containing an `<input>`/`<textarea>` with neither `onOpenAutoFocus` nor `onCloseAutoFocus`
- **Fix:** `onOpenAutoFocus={(event) => event.preventDefault()}` **and** `onCloseAutoFocus={(event) => event.preventDefault()}`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7317 — "Radix focuses content on open and hands focus back to the trigger on close. Both are prevented so the caret stays in the search input — the anchor isn't focusable anyway"

### F105 — The whole row or card is the control: wrap it in a `<label>`.
- **Detect:** a `<div>` containing a `Checkbox`/`RadioGroupItem` and a text sibling, with `htmlFor` absent or on an inner element only
- **Fix:** make the wrapper the `<label>` — `<label className={cn('flex cursor-pointer items-center gap-2.5 rounded-md px-1.5 py-2 transition-colors', isSelected ? 'bg-muted' : 'hover:bg-muted/60')}>`; pair a visible-text checkbox with `htmlFor` via `useId()`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#798 — "The whole row is the control, so the label carries the click rather than asking for a precise hit on the checkbox." bp2#6016 made the whole option card the `<Label>`. bp2#6363 — "don't rely on `aria-label` alone when there's visible text"

### F106 — Repeated identical inputs each get an `sr-only` label plus an `aria-hidden pointer-events-none` leading icon.
- **Detect:** ≥2 sibling `<Input>`s from one `Array.from`/`.map` with no `<Label>`
- **Fix:** `<Label className="sr-only" htmlFor={id}>Teammate email {index + 1}</Label>` and `<Mail aria-hidden="true" className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground" />` with `<Input className="pl-9" …>`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6016

### F107 — Row action labels name the row.
- **Detect:** a generic `aria-label` ("Remove document", "Delete row") inside a `.map()`
- **Fix:** `` aria-label={`Remove ${displayName}`} ``
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6183

### F109 — Distinguish "nothing exists" from "nothing matches" — and both from "the request failed".
- **Trigger:** one empty-state string used for both "nothing exists" and "nothing matches"; or an empty state rendered without reading `error`/`isError`
- **Detect:** one empty-state string used for all three; an empty state rendered without reading `error`
- **Fix:** `{vaults.length === 0 ? 'No vaults on this deal yet' : 'No vaults match that search'}`; read `error`/`refetch` and render a retry state
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#798, bp2#7724

### F110 — "Select all" selects only what is visible; its label flips to "Clear" once something is picked; Save is disabled until it can do something.
- **Trigger:** a "Select all" handler mapping over the **unfiltered** source array while the list renders a filtered one
- **Detect:** a select-all handler reading the unfiltered collection
- **Fix:** `onSelectAll(matches.map((v) => v.id))`; `{hasSelection ? 'Clear' : 'Select all'}`; `<Button size="sm" onClick={onSave} disabled={!hasSelection || isSaving}>`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#798 — "Receives the ids currently visible, so a filtered list can't select what it hides"

### F112 — Once the dropzone is gone, the list becomes the drop target — with an explicit `Add files` button beside it.
- **Detect:** a review list with no drag handlers; an `onDragLeave` without a containment check
- **Fix:** wrapper `'-m-1 shrink-0 rounded-lg border border-transparent p-1 transition-colors'` + `isDraggingOver && 'border-dashed border-border bg-muted/50'`; `onDragLeave={(event) => { if (!event.currentTarget.contains(event.relatedTarget as Node | null)) setIsDraggingOver(false) }}`; set `dataTransfer.dropEffect = 'copy'` on drag over
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6183 — without the containment check, moving over a child flickers the highlight off

### F116 — An excluded item stays visible, struck through and greyed; its check fades rather than mounting.
- **Detect:** an excluded item hidden from the list, or a check that mounts/unmounts
- **Fix:** `text-muted-foreground line-through` with the icon at `opacity-40 grayscale`; `<Check aria-hidden className={\`size-4 text-primary transition-opacity ${on ? 'opacity-100' : 'opacity-0'}\`} />`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6183

### F117 — Default a new item's opt-in from its eligibility, and make a bulk toggle skip ineligible items.
- **Detect:** `includeInExtraction: showExtraction` — a default that ignores eligibility; a bulk toggle mapping every item
- **Fix:** `includeInExtraction: showExtraction && isFileEligibleForFactExtraction(file)`; `onToggleAll` maps `!isEligible(doc.file) ? doc.includeInExtraction : value`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6183

### F120 — Row skeletons mirror the row they replace: same icon box, same text width, same padding.
- **Detect:** a generic `<Skeleton className="h-10 w-full" />` standing in for a structured row
- **Fix:** `<div className="flex items-center gap-2.5 px-1.5 py-2"><Skeleton className="size-4" /><Skeleton className="h-3 w-28" /></div>`
- **Except:** —
- **Tag:** auto
- **Evidence:** memo#798

---

## Rules — judgment

### F1 — Delete a step that asks a question with a sane default; do the action, then offer the optional input in the confirmation.
- **Trigger:** a dialog or step whose only required input is optional, or whose submit handler would run correctly with an empty/default payload — the mutation call inside it passes a literal `''`, `null`, `[]`, or a variable that is never validated as non-empty; reliably, a `Dialog`/`Modal` that opens *before* a mutation and whose submit is `mutate({ …, instruction: value })` with no `if (!value) return` anywhere
- **Detect:** a modal whose only required field is optional, or whose submit could run with an empty payload; a handler that opens a picker before the mutation it gates
- **Fix:** run the mutation unconditionally, move the optional input into the success confirmation as a secondary control
- **Except:** an irreversible destructive action, or a strategy choice where a cost must be read before committing (see F6)
- **Tag:** ask
- **Evidence:** memo#798 — "Publishing a Memo no longer asks you to pick Vaults first. It publishes straight away and confirms with a toast." memo#613 — "the optional free-text instruction was a blocking step in front of a yes/no question." bp2#7558 — `"Review generated FAQs"` dialog deleted

### F2 — Two code paths for one button — first-run vs. every other time — means the first-run step is unnecessary.
- **Trigger:** a handler whose only branch condition is a "has this happened before" field (`lastPublished*`, `hasSeen*`, `isFirst*`, `firstTime*`, `hasEver*`) and whose arms differ by an extra modal
- **Detect:** a handler whose only branch condition is a "has this happened before" field (`lastPublishedDate`, `hasSeen*`, `isFirst*`) and whose arms differ by an extra modal
- **Fix:** collapse to the non-first-run path
- **Except:** —
- **Tag:** flag
- **Evidence:** memo#798 — "`handlePublish` no longer branches on `lastPublishedDate` — every publish behaves the same way." `VaultLinkModal` and `VaultSubsequentPublishModal` both deleted

### F3 — Delete the concept that only existed to be explained by the step you removed.
- **Trigger:** a diff deletes a dialog/step, and a domain noun that appeared **only** inside it survives elsewhere in the codebase
- **Detect:** a domain term appearing only inside the deleted screen's copy
- **Fix:** remove the term from types, copy and docs alongside the screen
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#798 — "Dropped the 'featured file' concept along with that screen"; `<DialogDescription>This document will be marked as the Vault's featured file.</DialogDescription>` deleted

### F4 — When a flow changes, grep for copy that promised the old behavior.
- **Trigger:** a diff removes a `router.push`, a navigation, or a step, and leaves strings elsewhere describing that navigation — `send you to`, `take you to`, `you'll be taken`, `then choose`, `next you'll`
- **Detect:** after deleting a navigation or step, grep for its verbs — "send you to", "you'll be taken", "then choose", "before it is saved"
- **Fix:** rewrite the stale sentence to describe the new flow
- **Except:** —
- **Tag:** flag
- **Evidence:** memo#798 — `'This will send you to your Vault where you can share your Memo…'` → `'Publishing adds it to the deal's resources, and you can add it to any Vault…'`; "Updated the stale welcome-modal copy"

### F5 — Never auto-redirect the user away from what they were doing as the reward for finishing.
- **Trigger:** `router.push(` / `router.replace(` inside an `onSuccess`, `onCompleted`, or the resolve branch of a submit handler — navigating *back to a list after a delete* is fine; navigating *away from the thing the user just made* is the defect
- **Detect:** `router.push` / `window.location` inside a mutation's `onSuccess`
- **Fix:** delete the navigation; offer the destination as an anchor in the confirmation with `target="_blank" rel="noopener noreferrer"`
- **Except:** a flow whose whole purpose is to land you somewhere new — bp2#7196's create-draft navigates on success, and its double-fire guard releases only on failure
- **Tag:** ask
- **Evidence:** memo#798 — `useRouter` import deleted; "nothing auto-redirects you to a Vault"

### F6 — Confirm only two things: an irreversible destructive action, and a strategy choice whose cost must be read first.
- **Trigger:** a dialog or step whose only required input is optional, or whose submit handler would run correctly with an empty/default payload — the mutation call inside it passes a literal `''`, `null`, `[]`, or a variable that is never validated as non-empty; reliably, a `Dialog`/`Modal` that opens *before* a mutation and whose submit is `mutate({ …, instruction: value })` with no `if (!value) return` anywhere
- **Detect:** a confirmation step that is neither
- **Fix:** remove the step per F1
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6620 (strategy + receipt), bp2#7205 (delete), against memo#798 / memo#613 / bp2#7558 (all removed)

### F8 — Confirmation buttons name the two outcomes as verbs; the safe choice is phrased as an action, never as a dismissal.
- **Trigger:** banned openers and generic button pairs on a confirm surface — `Are you sure`, `OK`/`Cancel` as a pair, `Please` — or a straight `"` or `'` inside a `DialogDescription` / `AlertDialogDescription` / toast `description` string
- **Detect:** `AlertDialogCancel`/`AlertDialogAction` whose children are `Cancel`, `OK`, `Yes`, `No`, `Confirm`
- **Fix:** name both outcomes — `Keep editing` / `Leave without saving`
- **Except:** a plain dismissal in a non-destructive `Dialog` footer keeps `Cancel` (bp2#6620, bp2#7558)
- **Tag:** ask
- **Evidence:** bp2#7200 — title `Leave without saving?`, body `You have unsaved changes to this map. If you leave now, they'll be lost.`

### F10 — Every number in a cost summary is an inspectable list with a titled header; a bare count is not a disclosure.
- **Trigger:** a numeric count rendered as bare text inside a confirmation, receipt, or choice card — `{items.length}`, `{count}`, `{n} placements` — with no `HoverCard`, `Tooltip`, `Popover`, or expandable list wrapping it
- **Detect:** a numeric span inside a confirmation with no hover/expand affordance, or a hover card with no header
- **Fix:** make `title` a **required** prop and render it — `<div className="border-b px-3 py-2 text-xs font-medium text-muted-foreground">{title}</div>`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6620 — every call site names its list (`"Unlocks"`, `"Switches"`, `"Launches"`, `"Total placements"`, `"Already unlocked"`, `"No contact available"`); "before spending money the user must be able to answer 'which ones?' for every number on screen"

### F11 — Surface the free part as its own named metric; hiding it inside the paid one makes the action look more expensive than it is.
- **Trigger:** a numeric count rendered as bare text inside a confirmation, receipt, or choice card — `{items.length}`, `{count}`, `{n} placements` — with no `HoverCard`, `Tooltip`, `Popover`, or expandable list wrapping it
- **Detect:** a count that sums chargeable and free items under one label
- **Fix:** split into named metrics — bp2#6620 added `Switches` between `Unlocks` and `Launches`, `pluralize(n, 'switch', 'switches')`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6620 — "the user needs to see that some of the selection costs nothing — it changes whether the choice looks expensive"

### F12 — Order a cost receipt line items → totals → footnotes, split by `border-t border-dashed`, footnotes on `bg-muted/40`.
- **Trigger:** a cost summary rendered as an undifferentiated list of label/value rows — every row the same weight, no `border-t` between line-items / totals / footnotes; or an always-rendered footnote container (`min-h-*` + `bg-muted/*`) not gated on content length
- **Detect:** a cost breakdown with no visual separation between items and totals
- **Fix:** block 1 `space-y-2 border-t border-dashed px-4 py-5` with `{costPerContact} × {n}` and free items as **`0 × {n}`**; block 2 `Total`, `Credits available`, then `Balance after unlock` **or** `Shortfall`; block 3 footnotes. Subordinate rows `font-normal text-muted-foreground`; only `Total` at full weight
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6620 — the `0 ×` shape "uses the same shape as a charged line so the user can see it's counted but not billed"

### F14 — A footnote about something the user won't be charged for says so explicitly: bolded finding, then consequence.
- **Trigger:** a cost summary rendered as an undifferentiated list of label/value rows — every row the same weight, no `border-t` between line-items / totals / footnotes; or an always-rendered footnote container (`min-h-*` + `bg-muted/*`) not gated on content length
- **Detect:** a receipt footnote that names an excluded item without stating the billing consequence
- **Fix:** `<span className="font-medium text-foreground">No contact available</span> for …{count} placements. You will not be charged for {count === 1 ? 'this placement' : 'these placements'}.`
- **Except:** a demonstrative can't go through `pluralize`, so spell both forms out
- **Tag:** ask
- **Evidence:** bp2#6620

### F16 — Derive the confirmation label from counts of the operations that will actually run, never from a `mode` enum.
- **Trigger:** a confirm CTA, option title, or description whose text is selected by a mode enum rather than computed from operation counts — `mode === 'x' ? 'A'`, `get*Label(mode)`, or absolute quantifiers such as `all selected` / `only missing` / `every` / `all of`
- **Detect:** `getBulkLaunchConfirmLabel(selectedChoice.mode)`-shaped `getXLabel(choice.mode)`, or a `switch (mode)` producing user-facing text
- **Fix:** `getOperationAwareLabel({ unlockCount, switchCount, mode, coversEverySelection })`; three distinct labels for three operations — `'Unlock and switch for all selected'` / `'Unlock all selected'` / `'Switch all selected'`. The money-spending verb appears only when money is spent
- **Except:** preserve a hand-tuned special case behind an explicit predicate — bp2#7520's `isSingleFreeRecommendedContactSwitch(choice)` → `'Switch to Lev-recommended contacts and launch'`, checked first
- **Tag:** flag
- **Evidence:** bp2#7520 — the enum said "unlock and launch" when everything was already unlocked and nothing would be charged. bp2#6620 — `title: 'Missing only'` → `'Unlock missing contacts'`, "'Missing only' is a filter name; the user is about to spend credits and needs the verb"

### F17 — Reserve absolute quantifiers ("all selected", "only missing") for when they are literally true.
- **Trigger:** a confirm CTA, option title, or description whose text is selected by a mode enum rather than computed from operation counts — `mode === 'x' ? 'A'`, `get*Label(mode)`, or absolute quantifiers such as `all selected` / `only missing` / `every` / `all of`
- **Detect:** an "all"/"every"/"only" label not gated on a coverage predicate
- **Fix:** `coversEverySelection ? 'Unlock and switch for all selected' : 'Unlock and switch contacts'`, gated on `coversEverySelectedPlacement(selectedPlacements, appliedPlacements)`
- **Except:** —
- **Tag:** flag
- **Evidence:** bp2#7520 — "unavailable recommendations, untouched launch-ready placements, and `missing_only` placements whose existing contacts stay put all fall back to operation-only copy"

### F18 — A CTA that navigates away or triggers outreach appends that consequence; the adjacent description must not already say it.
- **Detect:** a footer CTA that omits a navigation the action performs; or an option title repeating a suffix its own description ends with
- **Fix:** `` `${operationLabel}, then launch` `` on the CTA only; option card titles stay bare
- **Except:** a label that already names the launch keeps its wording — `Launch ready contacts`, `Switch to Lev-recommended contacts and launch`
- **Tag:** ask
- **Evidence:** bp2#7520 — "Option card titles are unchanged (no suffix) since their descriptions already end in 'then launch'"

### F19 — Lead a choice description with its verbs in execution order; never bury the destructive half in a trailing clause.
- **Detect:** a description whose destructive verb appears after a subordinate clause
- **Fix:** `'Unlock Lev recommended contacts for these placements and replace existing contacts, then launch.'` → `'Unlock and replace existing contacts with Lev recommended contacts, then launch.'`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6620 — "the original buried 'replace existing contacts' — the consequential half"

### F20 — Description copy matches the state, not the mode.
- **Trigger:** a confirm CTA, option title, or description whose text is selected by a mode enum rather than computed from operation counts — `mode === 'x' ? 'A'`, `get*Label(mode)`, or absolute quantifiers such as `all selected` / `only missing` / `every` / `all of`
- **Detect:** one description string shared across modes with different preconditions
- **Fix:** branch on the mode — `missing_only` gets `'Use already-unlocked Lev-recommended contacts for placements without an assigned contact.'`, not "replace selected contacts"
- **Except:** —
- **Tag:** flag
- **Evidence:** bp2#7520 — review flagged "describes an already-unlocked recommendation on a contactless placement as replacing selected contacts, which is inaccurate"

### F21 — Extract confirmation copy into a sibling `*Copy.ts` of pure label functions with a test pinning exact strings.
- **Trigger:** the same user-facing phrase appearing as a string literal in two files (an option card and a footer CTA), with no shared `*Copy.ts`
- **Detect:** confirmation labels inlined in the dialog component, with the option title and CTA built separately
- **Fix:** one module feeding both — bp2#7520's `bulkLaunchContactsCopy.ts` + `bulkLaunchContactsCopy.test.ts`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7520 — "title and CTA drifting apart was the reported symptom"

### F22 — Warn in-product when the environment makes the consequences fake.
- **Trigger:** a money/credit/quota surface rendered without checking an impersonation or sandbox flag — `useCredits()` destructured without `isImpersonating`, or `impersonatedBy` referenced nowhere in a billing-adjacent component
- **Detect:** a balance/ledger surface with no impersonation or sandbox notice
- **Fix:** title = the fact, subtitle = the mechanic — `Credit charges are simulated while impersonating` / `The visible balance can change for testing, but billing ledger events are only recorded outside impersonation.`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6620 — backed by `isImpersonating: currentUser.impersonatedBy !== null` on the credits context

### F23 — When two options produce the same effective outcome, show only the simpler-scoped one.
- **Trigger:** a planner/selector returning a fixed list of choices with no equivalence check — every branch pushes its option unconditionally; no `haveEquivalent*`, `dedupe`, or collapse step before render
- **Detect:** two choices in one list whose applied sets are equal
- **Fix:** `if (meaningfulChoices.length === 2 && haveEquivalentUnlockEffects(a, b)) return [withUnavailablePlacementsFromEquivalentChoice(a, b)]` — the narrower scope survives (`missing_only`), not the broader
- **Except:** —
- **Tag:** flag
- **Evidence:** bp2#6642 — "two choices that unlock the same contacts for the same price is a fake decision — it costs the user attention and invites second-guessing on a paid action"

### F24 — Judge "equivalent" on the effects the user is charged for and that get applied — not on incidental skipped items.
- **Trigger:** a planner/selector returning a fixed list of choices with no equivalence check — every branch pushes its option unconditionally; no `haveEquivalent*`, `dedupe`, or collapse step before render
- **Detect:** an equality predicate comparing skipped/unavailable sets
- **Fix:** delete that clause — bp2#6642 removed `haveSamePlacementIds(first.unavailablePlacements, second.unavailablePlacements)`
- **Except:** —
- **Tag:** flag
- **Evidence:** bp2#6642 — "two options that unlock exactly the same contacts but skip a different unavailable recommendation are, to the user, the same option"

### F25 — Collapsing is a display simplification, never a scope reduction: union the discarded option's caveats into the survivor and regenerate its disclosures.
- **Trigger:** a planner/selector returning a fixed list of choices with no equivalence check — every branch pushes its option unconditionally; no `haveEquivalent*`, `dedupe`, or collapse step before render
- **Detect:** a collapse that returns one choice without merging the other's notes
- **Fix:** union `unavailablePlacements` and re-run `getReceiptNotes({ mode, existingContactPlacements, alreadyUnlockedPlacements, unavailablePlacements })`; return the original object untouched when nothing was added
- **Except:** —
- **Tag:** flag
- **Evidence:** bp2#6642 — test asserts both `plan.choices` length 1 **and** the surviving `unavailable_recommendation` footnote

### F26 — Pin option order in a test: cheapest and safest first.
- **Trigger:** a planner/selector returning a fixed list of choices with no equivalence check — every branch pushes its option unconditionally; no `haveEquivalent*`, `dedupe`, or collapse step before render
- **Detect:** an option list whose order is derived and untested
- **Fix:** `expect(plan.choices.map((c) => c.mode)).toEqual(['launch_ready', 'missing_only'])`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6642 — free "launch what's ready" always precedes paid "unlock first", and the list can't reshuffle between selections

### F27 — Label a class of options with a captioned rule between them, not by lumping them in one list.
- **Trigger:** a list of choice cards whose preview strips are built from the same source array (`choice.launchPlacements`, `items.slice(0, 5)`) for every choice; or a paid option rendered in the same visual run as free ones with no separator
- **Detect:** free and paid options in one undifferentiated `RadioGroup`
- **Fix:** `BulkLaunchUnlockSeparator`, rendered only at the `launch_ready → paid` boundary — `<div className="flex items-center gap-3 py-1 text-xs font-medium text-muted-foreground"><div className="h-px flex-1 bg-border" /><span>Unlock and launch</span><div className="h-px flex-1 bg-border" /></div>`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6620 — "says *these below cost money* without adding a second heading"

### F28 — Two choices differing by a small delta must look different: show the relative complement first in any preview strip, and count overflow against the true total.
- **Trigger:** a list of choice cards whose preview strips are built from the same source array (`choice.launchPlacements`, `items.slice(0, 5)`) for every choice; or a paid option rendered in the same visual run as free ones with no separator
- **Detect:** two option cards rendering identical avatar/logo strips
- **Fix:** `getBulkLaunchChoiceLogoPlacements(choice, plan.choices)` puts the complement against the sibling first; `overflowCount = Math.max(0, totalCount - previewPlacements.length)` where `totalCount = choice.launchPlacements.length`
- **Except:** —
- **Tag:** flag
- **Evidence:** bp2#6620 — "two choices differing by two placements would otherwise render identical avatar strips"

### F29 — Derive a bulk-action count from the maximum across all choices, so the badge shows what the action could do.
- **Trigger:** a bulk-action count derived from the *currently selected* mode (`plan.selectedChoice.x.length`, `mode === 'a' ? n : m`) rather than across all choices; or a button rendering `{count}` whose `aria-label` omits it
- **Detect:** a count built with `||` fallbacks or read off the currently-selected mode
- **Fix:** `const bulkUnlockCount = Math.max(...choices.map((c) => c.appliedPlacements.length), 0)` — count what will be **affected**, not what will be **billed**
- **Except:** —
- **Tag:** flag
- **Evidence:** bp2#6620 — "the `||` fallback made the badge flicker to a different number as the selected mode changed, before the user had even opened the dialog"

### F32 — Disable the whole choice group, not just the confirm button.
- **Trigger:** an `isSubmitting`/`isDeleting`/`isUnlocking` flag applied to **only** the confirm button, while sibling inputs stay live; **or** the same flag applied to a Cancel/Close control
- **Detect:** a submit with `disabled={isPending}` while the inputs that decide the payload stay live
- **Fix:** `<RadioGroup disabled={isUnlocking}>`, and neutralize row-level mutators — `removePlacementHandler = isUnlocking ? undefined : onRemovePlacement`
- **Except:** never the exit — see F33
- **Tag:** ask
- **Evidence:** bp2#6620 — "changing the strategy mid-request would apply a plan the user no longer sees"

### F33 — Never disable the escape hatch. A disabled Cancel is a trap.
- **Trigger:** an `isSubmitting`/`isDeleting`/`isUnlocking` flag applied to **only** the confirm button, while sibling inputs stay live; **or** the same flag applied to a Cancel/Close control
- **Detect:** `disabled={isBusy}` on a Cancel/Close control
- **Fix:** remove it; gate only the inputs that change the pending outcome
- **Except:** the brief window of a genuinely irreversible delete — bp2#7205 keeps `AlertDialogCancel disabled={isDeleting}`
- **Tag:** ask
- **Evidence:** memo#613 — `disabled={isBusy}` deliberately removed from Cancel once the blocking operation was gone

### F35 — A destructive confirm dialog is a state machine: pending label, inline error, stays open on failure.
- **Trigger:** a destructive confirm whose action handler calls the mutation and closes unconditionally — `onClick={() => { mutate(); onOpenChange(false) }}` — with no `event.preventDefault()`, no pending label, no error branch
- **Detect:** an `AlertDialogAction` that closes unconditionally, or a delete handler with no error branch
- **Fix:** `event.preventDefault()` in the action handler; `{isDeleting ? 'Deleting…' : 'Delete'}`; failure renders `<p className="rounded-md border border-destructive/30 bg-destructive/10 px-3 py-2 text-sm text-destructive">Couldn't delete this map. Please try again.</p>`; `onOpenChange` returns early while `isDeleting`
- **Except:** an API that resolves `false` instead of throwing needs the boolean propagated — bp2#7205: "`deleteDraft` resolves `false` on failure (doesn't throw), so I propagate the boolean … and only close the dialog when the map was actually deleted"
- **Tag:** ask
- **Evidence:** bp2#7205

### F36 — Snapshot the data the confirmation will display at the moment of the action, not in the success callback.
- **Trigger:** a success callback reading live state that the user could have changed during the request — `onSuccess: () => { …editor.getJSON()… }`, or a success toast interpolating `form.values.*`
- **Detect:** a success handler re-reading a live editor/form to build its confirmation
- **Fix:** `const publishedDoc = editor?.getJSON()` before `.mutate`, passed to both the mutation and the toast
- **Except:** —
- **Tag:** flag
- **Evidence:** memo#798 — "reading the editor again in `onSuccess` would preview any edits made while the request was in flight rather than the version that was actually published"

### F37 — Clean success is silent when the result is on screen; a dead end never is. Carry an explicit `notify` flag from the call site.
- **Trigger:** `toast.success(` fired after an action whose result is already visible on screen (an item appearing in a list, a pin on a map, a row in a table); **or** a notification layer deciding what to show by pattern-matching rendered English (`message.includes(`, `text.match(`, `msg.startsWith(`)
- **Detect:** a notifier that filters by success/error (`if (!options?.error) return`), or one that infers intent by pattern-matching English message text
- **Fix:** `{ notify: failedCount > 0 || foundPins.length === 0 }` decided at the call site
- **Except:** a full clean success stays silent — "the pins landing on the map say it"
- **Tag:** flag
- **Evidence:** bp2#7225 — "'No new places found' was being discarded, so an add that found nothing looked identical to a broken button"; "the regex is the root cause: the bar was inferring intent from English text, so any message a pattern didn't anticipate got swallowed"

### F38 — Feedback belongs where the click was.
- **Trigger:** a handler that closes its own popover/dialog *before* awaiting the mutation — `onClick={() => { setOpen(false); mutate() }}`
- **Detect:** a dialog that closes before its action resolves; a hint rendered under the field rather than in the control it describes
- **Fix:** keep the surface open and spinning until the action resolves; put the hint inside the button
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7225 — "Stays open and spins until the add resolves, so the feedback is where the click was. Closing immediately meant a slow add looked like nothing had happened." memo#783 — "The hint lives inside the button rather than under the field, so it reads as a label for that action instead of another line of instructions"

### F40 — Toasts state the outcome, not the operation, and pluralize on the count. The zero case is a success, not an empty result.
- **Trigger:** a hardcoded plural or a count-free batch message — `toast.success(`/`toast.error(` with `{count}` followed by a literal `s`, or with a bare `items`/`files`/`records`/`places`
- **Detect:** a toast naming the operation (`Could not compare memo to deal data`) rather than the finding; a zero-result path that only ever errors
- **Fix:** `toast.success('Index is up to date')` at `changeCount === 0`; `` toast.success(`${n} ${n === 1 ? 'update' : 'updates'} available from Index`) ``; `toast.error('Could not check Index', { description: 'Unable to compare the memo to the Index right now.' })`
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#613 — "the zero case is a *success* ('up to date'), not an empty result. The old flow could only ever report failure"

### F41 — Report a partial failure as `Added N of M …`; add everything that resolved rather than failing the whole batch.
- **Trigger:** a hardcoded plural or a count-free batch message — `toast.success(`/`toast.error(` with `{count}` followed by a literal `s`, or with a bare `items`/`files`/`records`/`places`
- **Detect:** a batch handler that throws on first failure, or a success message that ignores `failedCount`
- **Fix:** `failedCount > 0 ? \`Added ${foundPins.length} of ${selectedResults.length} nearby places.\` : \`Added ${foundPins.length} nearby ${foundPins.length === 1 ? 'place' : 'places'}.\``
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7225 — "**Partial failure:** add everything that resolved and report the shortfall ('Added 4 of 5') … rather than failing the whole batch"

### F42 — A non-blocking background failure names what failed, then says the work survived and where to fix it.
- **Trigger:** banned generic error copy (`Something went wrong`), or a `toast.error` with a title and no `description`
- **Detect:** `toast.error('Something went wrong')` after a `Promise.allSettled` of optional side-effects
- **Fix:** `<what failed>` / `The <thing> was created; <what to do>.` — `toast.error('Description was not saved as a note', { description: 'The deal was created; add the note from the deal page.' })`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7031 — "Neither failure blocks deal creation"

### F43 — A confirmation toast carries four things: a preview of the artifact, a one-line title, a sentence saying where it now lives, and the actions. The preview replaces the status icon.
- **Detect:** a success toast whose only ornament is a check glyph
- **Fix:** `<div className="bg-popover text-popover-foreground ring-border relative flex w-full gap-3 rounded-lg p-3.5 shadow-lg ring-1">` with `<p className="pr-5 text-sm leading-tight font-semibold">Your memo is published</p>` + `<p className="text-muted-foreground text-xs">This version is live in your deal resources and any vaults you've added it to.</p>`
- **Except:** a short outcome toast with no artifact keeps the default sonner card
- **Tag:** ask
- **Evidence:** memo#798 — "The stack stands in for a status icon, so it sits beside the copy rather than above it — everything in the column below shares one left edge"

### F44 — The primary toast action goes to the artifact; the optional step the deleted modal demanded becomes a `ghost` secondary opening a popover in place, labelled for the state it's in.
- **Detect:** a confirmation toast with no route back to the thing it made
- **Fix:** `<Button size="xs" asChild><a>View in resources</a></Button>` then `<Button size="xs" variant="ghost" disabled={vaults.length === 0}><Plus />{linkedVaults.length > 0 ? 'Add more vaults' : 'Add vault'}</Button>`
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#798 — "the label becomes 'Add more vaults'… The button tells you it worked without a separate confirmation"

### F46 — Drive auto-dismiss from the countdown animation's `animationend`, never a parallel JS timer.
- **Trigger:** a countdown/progress bar animated in CSS alongside a `setTimeout`/`setInterval` that dismisses it — two clocks
- **Detect:** a `setTimeout(() => toast.dismiss(...))` alongside a progress bar
- **Fix:** `const COUNTDOWN_CLASS = 'animate-[toast-countdown_10s_linear_forwards]'` on `<div className={cn('bg-primary absolute inset-x-0 bottom-0 h-0.5 origin-left', COUNTDOWN_CLASS)} style={{ animationPlayState: isCountdownPaused ? 'paused' : 'running' }} onAnimationEnd={() => toast.dismiss(toastId)} />`
- **Except:** —
- **Tag:** flag
- **Evidence:** memo#798 — "the bar's `animationend` is what dismisses the toast, so the visual and the clock can't drift"

### F47 — Pause the countdown whenever the user can't be reading it or is mid-interaction: tab hidden, window blurred, card hovered, popover open.
- **Detect:** a countdown with no pause conditions, or one checking only `visibilityState`
- **Fix:** `const isCountdownPaused = !isTabActive || isHovered || isPopoverOpen` with `document.visibilityState === 'visible' && document.hasFocus()` bound to `visibilitychange`/`focus`/`blur`
- **Except:** —
- **Tag:** flag
- **Evidence:** memo#798 — "a visible-but-unfocused tab still isn't being read"

### F49 — A tall interactive toast gets its own `<Toaster>`.
- **Detect:** a large custom toast rendered through the app's default toaster
- **Fix:** a second `<Toaster id={…} expand position="top-right" …>` beside the default
- **Except:** —
- **Tag:** ask
- **Evidence:** memo#798 — "`expand` is a Toaster prop, not a per-toast one… Separate toasters also mean the tall card never stacks against them at all"

### F53 — A multi-minute wait gets cycling status copy on a fixed-height line, plus a warning if navigating away loses the result.
- **Trigger:** a request that can exceed ~30s whose waiting state is a spinner, a `<Skeleton>`, or a **single fixed line of text** — one `<p>` inside `{isGenerating && …}` with no `AnimatePresence`, no message array, no interval
- **Detect:** one static string as the only feedback for an operation that can exceed ~30s
- **Fix:** six `GENERATING_MESSAGES` at `MESSAGE_INTERVAL_MS = 4000` inside `<div className="flex h-5 items-center">` with `<AnimatePresence initial={false} mode="wait">`; plus `<p className="text-center text-xs font-medium text-foreground">Do not leave or close this browser tab while FAQs are generating.</p>`
- **Except:** the fixed height is load-bearing — `mode="wait"` unmounts before mounting, so an unpinned block collapses and rebounds on every swap
- **Tag:** ask
- **Evidence:** bp2#7558 — "One frozen line reads as a hang; these cycle to show it is still working, roughly in the order the agent does"

### F54 — While a background job runs, show the real product view doing the work rather than a spinner step — and hide the CTA that isn't possible yet.
- **Trigger:** a wizard/dialog step that renders a bespoke "scanning…" illustration while a background job runs, when the product already has a view of that job
- **Detect:** a bespoke progress screen duplicating a view that already exists
- **Fix:** render the real component and omit the prop that gates the impossible action
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6016 — "`onImportAll` is intentionally omitted… Without that prop the feed hides its 'Import all' CTA, so the user just watches the scan run and continues the wizard. Review happens later, in the workspace"

### F55 — An AI opt-in earns a real explainer card, not a one-line strip.
- **Detect:** an AI toggle whose explanation lives only in a tooltip
- **Fix:** `'flex w-full min-w-0 flex-col gap-6 rounded-lg border border-border bg-sidebar p-4 shadow-xs'` — illustration + name + a full sentence of what it does and why, controls on a separate row below a `border-t`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6363

### F56 — Any operation that visibly reshapes the UI gets a masking overlay with a spinner and a present-participle label.
- **Detect:** a layout-changing async operation with no masking state
- **Fix:** an overlay over the reshaping region
- **Except:** AI-driven waits use `MorphingLevIcon` (see F51's Except)
- **Tag:** ask
- **Evidence:** bp2#7200

### F57 — One blocking question per step, and that step owns the dialog title.
- **Trigger:** a step component whose body is a heading + subheading + exactly one `FormField`/`RadioGroup`
- **Detect:** a dialog title that stays generic while the body asks a blocking question
- **Fix:** retitle for the step — `This deal already has {n} {question|questions}…` / `How do you want to proceed?` — reverting once answered
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7558

### F58 — An answered step collapses to a summary row with a `Change` action that re-expands in place; never rewind to step one.
- **Trigger:** an answered step that remains fully expanded, or a `Change`/`Edit` action that calls `setStep(0)` / `goToStep(1)` rather than re-expanding in place
- **Detect:** a "back" control that unmounts the later steps
- **Fix:** `<OptionalSection title="Existing FAQ" description={\`${existingMode === 'replace' ? 'Replacing' : 'Keeping'} ${questionCount} …\`} action={isChangingMode ? 'Done' : 'Change'}>` re-showing the cards with the current answer marked selected
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7558 — "the rest of the form stays put"

### F59 — Gate the submit on the blocking answer by hiding it, not disabling it.
- **Trigger:** a submit `disabled={!hasAnswered…}` where the answer is a *blocking* question — should be hidden, not disabled
- **Detect:** a submit rendered `disabled` because an earlier question is unanswered
- **Fix:** `const hasAnsweredExisting = !hasExisting || existingMode != null` gating `{hasAnsweredExisting && (<Button type="submit">…)}`
- **Except:** a submit blocked only by an empty *input* stays rendered and disabled — see F90
- **Tag:** ask
- **Evidence:** bp2#7558 — "Generate is not rendered until it's answered"

### F62 — Collapse a step whose only content is one question.
- **Trigger:** a step component whose body is a heading + subheading + exactly one `FormField`/`RadioGroup`
- **Detect:** a step component whose body is a heading, a subhead, and one field
- **Fix:** delete the step; move the field into an adjacent step as one `FormField`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6016 — `StepReferral.tsx` deleted, "How did you hear about us?" folded into `StepPersonalInfo`

### F63 — Optional input is a titled row with a description and an `Add` action, not an empty field on screen.
- **Detect:** an always-rendered optional `Textarea`/file input with a `Label` reading "Optional"
- **Fix:** `<OptionalSection action={isOpen ? 'Remove' : 'Add'} description="Tell Lev Agent what to focus on." title="Custom instructions" onAction={…}>`; `Remove` clears the value
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7558 — "Custom instructions and the reference question list sit behind explicit Add rows instead of empty fields"

### F65 — Decide where secondary copy lives by measuring, not by guessing a breakpoint.
- **Trigger:** a breakpoint-based decision about where secondary copy goes (`isDesktop ? <Footer/> : <Inline/>`); a step slide expressed as a pixel offset (`x: 80`, `x: -20`) while the container also recenters; an absolutely-positioned footer with no stacking context
- **Detect:** a fixed `sm:`/`lg:` branch placing a one-line notice inline vs. in a footer
- **Fix:** an invisible probe — `<div ref={termsProbeRef} aria-hidden="true" className="pointer-events-none invisible absolute top-0 right-0 left-0 pt-1">` — `ResizeObserver`d alongside the step content, driving `shouldPlaceTermsInline`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6016 — a single line of legal copy must never be what makes the step scroll

### F66 — A step slide must out-run the layout shift it coexists with.
- **Trigger:** a breakpoint-based decision about where secondary copy goes (`isDesktop ? <Footer/> : <Inline/>`); a step slide expressed as a pixel offset (`x: 80`, `x: -20`) while the container also recenters; an absolutely-positioned footer with no stacking context
- **Detect:** a fixed-pixel slide offset (`x: 80`) on a step whose container also resizes
- **Fix:** percentages of the container — `x: direction > 0 ? '110%' : '-110%'`, easing `[0.32, 0.72, 0, 1]` at `0.7`, with `filter: 'blur(4px)'` on enter/exit
- **Except:** the terminal step fades and scales instead — `exit: { opacity: 0, scale: 0.98 }` at `{ duration: 0.3, ease: [0.23, 0.86, 0.39, 0.96] }`
- **Tag:** flag
- **Evidence:** bp2#6016 — "We need |translate| > recenter shift + a margin so the LEAVING content reads as clearly off-screen before the new content enters"

### F69 — Resume a multi-step tour at the first unseen step: one cookie per card, named after the card, kebab-case.
- **Detect:** a single `hasSeenTour` flag gating a multi-card tour
- **Fix:** `useState<TourStep>(() => { if (pitchIntroSeen !== 'true') return 'pitch'; if (notesIntroSeen !== 'true') return 'notes'; return 'done' })`
- **Except:** the tour backdrop is not dismissible by clicking it — only its button advances
- **Tag:** ask
- **Evidence:** bp2#7130 — "A user who saw step 1 and reloaded gets step 2, not step 1 again"

### F70 — If a field can't be edited, don't render a field; if the fact isn't needed either, don't render the fact.
- **Trigger:** `<Input disabled`, `<Textarea disabled`, or `readOnly` on a field displaying a value the user cannot change
- **Detect:** `<Input disabled` bound to a form value
- **Fix:** render the value as labelled read-only text; then ask whether the fact is needed at all
- **Except:** —
- **Tag:** ask
- **Evidence:** the signup escalation — bp2#6056 replaced `<Input disabled placeholder="jane@company.com" {...formik.getFieldProps('email')} />` with read-only text plus a `Go back` link; **bp2#6146 then deleted the whole block**, because a mid-form logout link destroys the in-progress form and the field wasn't editable anyway. (bp2#6056's link also needed a keyboard fix: a form-level Enter handler must bail on `e.target.closest('a,button')`)

### F71 — The placeholder names the shape of the input; the label names the field. Never both.
- **Trigger:** a panel/section `h2`/`h3` immediately above a single field whose `placeholder` or `<Label>` says the same thing
- **Detect:** a placeholder repeating its label, or a panel heading repeating the field labels beneath it
- **Fix:** add `placeholder="Property name"` / `"Street address"` / `"Pin label"` **and delete** the redundant `h2` above them
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7226 — "the panel header already names the surface"

### F74 — A placeholder must name what to paste if pasting is the field's real job.
- **Detect:** a large textarea whose placeholder names only the field
- **Fix:** `"Add a description…"` → `"Add some details about the deal or paste notes…"`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7031 — "the field's real job is to accept raw pasted notes; the placeholder has to say so or nobody pastes"

### F76 — Inside a dropdown or popover, a field label reads as a continuation of the primary control: lowercase, conversational, `text-xs text-muted-foreground`.
- **Detect:** a Title Case section header inside a ≤320px popover
- **Fix:** `<Label className="text-xs text-muted-foreground" htmlFor="bulk-add-properties">or paste a list of addresses</Label>`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7317 — "two lines of chrome … above a textarea in a 320px popover"

### F77 — An editable field's empty state looks like the document, not a decorated CTA card — and the prompt looks identical before and after focus.
- **Detect:** a fixed-height tinted panel with a button inside it (bp2#7130 deleted an `h-[160px] bg-muted/30` panel), on a surface the user can type into; a library CSS `placeholder` that replaces a styled empty state on focus
- **Fix:** `<div aria-label="Write deal pitch" className="relative -mx-2 min-h-24 cursor-text rounded-lg px-2 py-3 text-base leading-[1.7] focus-visible:ring-2 focus-visible:ring-ring/50 focus-visible:outline-none" role="button" tabIndex={0}>` with the prompt in the real text style; keep it as an `aria-hidden` overlay once focused
- **Except:** the read-only branch keeps the decorated panel — "the CTA card is only wrong where the user can actually type"
- **Tag:** ask
- **Evidence:** bp2#7130

### F78 — Default a new object to a placeholder name rather than demanding one up front.
- **Trigger:** a create mutation requiring a name with no default (`if (!name) return` guarding `createX`)
- **Detect:** a create dialog whose only required field is a name
- **Fix:** `createDraft({ name: 'Untitled map', config })`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7196

### F81 — Never surface a raw validation or schema dump; map known failures to a sentence that says what to do next.
- **Trigger:** free text sent without `.trim()`; a raw error object rendered into the UI (`{error.message}`, `JSON.stringify(error)`)
- **Detect:** a `catch` passing `error.message` straight into `toast.error`'s description
- **Fix:** a `describeXError(message)` mapper — `'timed out'` → `'Lev AI took too long. Try narrowing the instructions.'`; `'returned invalid data'` → `'Lev Agent didn't return usable FAQs. Try running it again.'`
- **Except:** an unrecognised message still falls through verbatim rather than being replaced by "Something went wrong"
- **Tag:** ask
- **Evidence:** bp2#7558 — "None of that is the user's to read, and a rerun usually succeeds"

### F82 — An error message that names a remedy makes that remedy clickable in place.
- **Trigger:** an error string naming a remedy in prose with no `<button>`/`<a>` in the same element — `purchase more credits`, `contact your admin`, `upgrade your plan`
- **Detect:** error copy containing an imperative the UI can perform ("purchase more credits", "add a sponsor", "connect your email")
- **Fix:** thread the handler down and render the phrase as `<button className="underline underline-offset-2 hover:text-muted-foreground" type="button" onClick={onTopUp}>`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6620 — "telling the user to do it without a path is a dead end"; `onTopUp` was added as a prop purely for this

### F84 — An error sentence leads with a bolded diagnosis, then the remedies: the fix the user controls first, the one that costs money second.
- **Detect:** a single interpolated error constant with no emphasis
- **Fix:** `<span className="font-medium">Insufficient credits for fact extraction</span>. Disable fact extraction or <button …>purchase more credits</button>`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6363

### F89 — A warning collapses to its icon at narrow widths with the sentence moving into a tooltip, rather than wrapping.
- **Detect:** a long inline warning sentence in a constrained row
- **Fix:** `<Tooltip content="Remove files or turn off fact extraction for some files before uploading."><span className="flex items-center gap-1 text-xs text-destructive"><AlertTriangle className="size-3.5 shrink-0" /><span className="hidden sm:inline">Not enough credits</span></span></Tooltip>`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6183

### F91 — Separate `disabled` from `disabledReason`; while a prerequisite check is in flight, disable and show no reason.
- **Trigger:** a single `disabled` prop covering both "blocked" and "still checking", with one `disabledReason`/tooltip for both
- **Detect:** one prop carrying both the disabled state and its explanation
- **Fix:** `factExtractionDisabled?: boolean` and `factExtractionDisabledReason?: ReactNode` as distinct props; `const isDisabled = disabled || !!disabledReason`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6457 — "an explanation that might be wrong is worse than none"

### F92 — A blocked state names the specific missing prerequisite and puts the fix inline as a link that opens the real flow.
- **Trigger:** a disabled control whose explanation is generic — `contact support`, `not available`, `You do not have permission` — with no named prerequisite and no inline fix
- **Detect:** a disabled control with no reason, or copy reading "contact support" / "not available"
- **Fix:** `<SponsorSelectTrigger …><button className="… text-primary underline-offset-2 hover:underline …">Add a sponsor</button></SponsorSelectTrigger>{' '}to enable fact extraction for this deal.`
- **Except:** fixing it inline must run the same confirmation and invalidation as the real flow — bp2#6457 calls `useConfirmDealEdit`'s `confirmEditIfNeeded()` then `markSearchResultsStale()`, no shortcut mutation
- **Tag:** ask
- **Evidence:** bp2#6457

### F93 — The blocked banner is a footer of the card it disables: bled to its edges, sharing its rounding.
- **Detect:** an alert sibling above or below the card it explains
- **Fix:** `'-mx-4 -mb-4 flex items-start gap-2 rounded-b-lg border-t border-border bg-muted/60 px-4 py-2.5 text-xs font-normal leading-4 text-muted-foreground'`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6457

### F98 — Prefer an invisible placeholder to a visibly-disabled control in a repeated row.
- **Trigger:** an always-`disabled` control inside a `.map()` — a greyed checkbox on every ineligible row
- **Detect:** a `<Checkbox disabled>` rendered on every row of a state class
- **Fix:** `<Checkbox aria-hidden="true" aria-label="Term already unlocked" checked={false} className="invisible pointer-events-none shadow-none" tabIndex={-1} />`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6804 — "a greyed checkbox on every already-unlocked row is visual noise implying a disabled action; an invisible spacer keeps column alignment without inviting a click, and it leaves the tab order"

### F99 — Disabled inputs should not exist.
- **Trigger:** `<Input disabled`, `<Textarea disabled`, or `readOnly` on a field displaying a value the user cannot change
- **Detect:** `<Input disabled` / `<Textarea disabled` bound to a value the user can never change
- **Fix:** render the value as text (then apply F70)
- **Except:** an input disabled *transiently* during submit is fine — `disabled={formik.isSubmitting}` is used throughout
- **Tag:** ask
- **Evidence:** bp2#6056 → bp2#6146 — "a disabled input reads as broken"

### F102 — Use `PopoverAnchor`, not `PopoverTrigger`, when the anchor contains an input — then guard `onInteractOutside` against the anchor.
- **Detect:** `PopoverTrigger` wrapping an input; or an `onBlur` + `setTimeout` pattern keeping a panel alive
- **Fix:** `<PopoverAnchor asChild>` plus `onInteractOutside={(event) => { if (pillRef.current?.contains(event.target as Node)) { event.preventDefault() } }}`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7317 — "A Trigger renders a `<button>` (can't wrap the input) and toggles on click, so clicking back into your own search would close the panel"

### F103 — Open a panel explicitly in the click handler; never rely on the input's `onFocus` alone.
- **Detect:** panel visibility derived only from a `focused` state set by `onFocus`/`onBlur`
- **Fix:** `setOpen(true)` in the container's `onMouseDown` **and** the input's `onFocus`
- **Except:** —
- **Tag:** flag
- **Evidence:** bp2#7317 — "opening was a side effect of the input's `onFocus`, which only fires on a *change* of focus — so after Escape … clicking the field again did nothing"

### F104 — If a control looks like a field but the real input is a small box inside it, hand the caret over on `mousedown` across the dead area — and measure the dead fraction.
- **Detect:** an input whose rendered box is materially smaller than the padded/decorated container around it
- **Fix:** `onMouseDown={(event) => { if (disabled) return; if (!(event.target as HTMLElement).closest('input, button')) { event.preventDefault(); inputRef.current?.focus() } setOpen(true) }}`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7317 — "the input is a 276×20 box inside a 320×44 pill, so the magnifier, the left padding and the strips above and below the text are **61% of the target**, all dead"

### F108 — Show a search field only past the threshold where scanning stops working.
- **Trigger:** a search input rendered unconditionally above a list, with no length threshold
- **Detect:** a search input above a list that is usually short
- **Fix:** `const SEARCH_THRESHOLD = 5`; `const showSearch = vaults.length >= SEARCH_THRESHOLD`
- **Except:** the number is surface-specific; the rule is that a threshold exists
- **Tag:** ask
- **Evidence:** memo#798 — "Below this, a search field is more chrome than help"

### F111 — A picker has two states: the full dropzone only while empty, replaced entirely by a compact review list once items are selected.
- **Detect:** a persistent dropzone stacked above a file list
- **Fix:** `{hasFiles ? <SelectedFilesList … /> : <DocumentUpload … />}`; the dialog title becomes a live count (`Upload {n} {file|files}`) and the generic subtitle disappears at the same moment
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6183

### F113 — Cap a list at a fixed row count and move the rest into a popover rendering the same row component; state the ratio in words next to the escape hatch.
- **Trigger:** a `.map()` over an unbounded array inside a `DialogContent` with an `overflow-y-auto`/`max-h-*` wrapper and no cap constant
- **Detect:** an unbounded `overflow-y-auto` list inside a dialog
- **Fix:** `MAX_VISIBLE_UPLOAD_FILES = 7`; `Showing 7 of {n}` + `View {hidden} more` opening `<PopoverContent align="end" className="max-h-72 w-96 max-w-[calc(100vw-2rem)] overflow-y-auto p-1 shadow-lg">`
- **Except:** narrower surfaces cap lower — `MAX_VISIBLE_CREATE_DEAL_FILES = 3` "because the surface is narrower"
- **Tag:** ask
- **Evidence:** bp2#6183, bp2#6363

### F114 — A per-item opt-in with a "some are on" state is a tri-state `Checkbox`, not a `Switch`.
- **Detect:** a header `<Switch>` controlling a list of per-row switches
- **Fix:** `const state = priceableFileCount === 0 ? false : allOn ? true : enabledCount > 0 ? 'indeterminate' : false`, with the indeterminate styling in one shared class constant
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6183

### F115 — Ineligible items leave the toggle list entirely and get one summarizing footer line with a count.
- **Detect:** permanently-disabled rows inside a toggle list
- **Fix:** filter them out; `{imageCount} {imageCount === 1 ? 'image' : 'images'} not eligible for fact extraction` in a `border-t bg-muted/30` footer
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6183

### F118 — Eligibility, pricing and affordability each get one named predicate or hook in a shared module.
- **Detect:** an `isImageFile`-style predicate duplicated across components; affordability recomputed locally
- **Fix:** `src/utils/factExtraction.ts` exporting `isFileEligibleForFactExtraction`; `useFactExtractionCreditGate` returning `{ showPricing, totalCredits, hasPriceableFiles, canAfford, isInsufficientCredits, openTopUpForFactExtraction }`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6183, bp2#6363

### F119 — Every entry point into a flow opens the same dialog.
- **Detect:** a second surface owning its own `Dialog.Root` + form + validation for an action that already has a dialog
- **Fix:** hand the input to the shared dialog — `handleDocumentUpload` sets `initialDocuments` and opens `<DocumentUploadDialog …>`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6363 — "Make the resources dropzone open the same upload dialog as the other upload entry points"

### F121 — Keep one question in one place, then delete the prop whose last caller is gone.
- **Trigger:** the same user-facing question answered by controls in two locations (a per-row toggle *and* a settings group); or a secondary route buried in a `…` overflow menu that answers the same question as a primary control
- **Detect:** per-field toggles answering the same question a settings group already answers; a prop with no remaining call sites
- **Fix:** move the toggle into the group (`showName` joins `CARD_CONTENT_FIELDS`); delete the `visibility` prop, its wrapper, and the now-pointless `flex-1`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7317 — "They were eyes on the header fields, which split one question — *what goes on the card?* — across two places and made each line three controls wide"

### F122 — Don't hide a secondary route in an overflow menu when it answers the same question as a primary control; relocate it to the point of intent. The empty state of a search dropdown is an opportunity, not a blank.
- **Trigger:** the same user-facing question answered by controls in two locations (a per-row toggle *and* a settings group); or a secondary route buried in a `…` overflow menu that answers the same question as a primary control
- **Detect:** a feature in a "…" menu duplicating a primary control's purpose; a dropdown gated on `query.length > 0`
- **Fix:** move it under the primary control's own click — `{!hasQuery && !statusLabel && (<PasteAddressesField … />)}` with the result branches gated on `hasQuery`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7317 — "the search field is where you go to put a place on the map, so the bulk route belongs behind the same click rather than buried in an overflow menu"; the fix for "doesn't earn its space" is relocation, not deletion

---

## Reference

### Domain map

The rules were synthesized in five groups; this is where each came from.

- **1. Consequential actions** — the decision rule (F1–F6) · which primitive (F7–F9) · what a confirmation must state (F10–F22) · collapsing equivalent options, bp2#6642 the direct evidence (F23–F31) · while the action is in flight (F32–F36)
- **2. Receipts and outcomes** — the core asymmetry (F37–F39) · toast content (F40–F50) · progress on a long action (F51–F56)
- **3. Multi-step flows** — F57–F70
- **4. Forms** — label vs. placeholder vs. helper text (F71–F78) · validation timing and error presentation (F79–F89) · disabled state policy (F90–F99) · autofocus and hit targets (F100–F107) · selection panels and pickers (F108–F122)

### Which primitive

`AlertDialog` only for a yes/no you cannot take back. A flow with choices to review is a `Dialog`. (F7–F9)

- bp2#6620: the whole `AlertDialog*` family → `Dialog` / `<DialogContent showCloseButton={false}>` / `<DialogClose asChild><Button variant="outline">Cancel</Button></DialogClose>` + a plain `<Button>`. "This screen asks the user to *pick a strategy* and read a receipt — it needs normal dialog semantics and normal buttons." Note `showCloseButton={false}` keeps the exit deliberate even so.
- bp2#7205, bp2#7200: `window.confirm` → in-app `AlertDialog`, because "native popups break the product's visual language and can't hold error or pending state."
- bp2#7200: `beforeunload` is kept **only** for real tab close; in-app navigation gets `UnsavedChangesGuard` intercepting `router.events` `routeChangeStart`. "browsers don't allow a custom dialog there."

### Receipt-block anatomy

Order a cost receipt like a real receipt: line items → totals → footnotes, separated by `border-t border-dashed`, footnotes on `bg-muted/40`. bp2#6620: block 1 `{costPerContact} × {n}` plus an `Already unlocked` line at **`0 × {n}`** — free items use the same shape as a charged line so they read as counted-but-not-billed; block 2 `Total`, `Credits available`, then `Balance after unlock` **or** `Shortfall`; block 3 footnotes. Subordinate lines are `font-normal text-muted-foreground`; only `Total` stays at full weight. (F12–F15)

### The core asymmetry

Clean success is silent when the result is on screen. A dead end never is. bp2#7225: `showMessage` dropped every non-error message (`if (!options?.error) return`) → `{ notify: failedCount > 0 || foundPins.length === 0 }`. Ethan: "'No new places found' was being discarded, so an add that found nothing looked identical to a broken button." / "A clean full success stays silent — the pins landing on the map say it."

- Corollary (bp2#7225): **never infer intent from rendered text.** "the regex is the root cause: the bar was inferring intent from English text, so any message a pattern didn't anticipate got swallowed." Carry an explicit `notify` flag from the call site that knows. (F37–F39)

### What he removed from the signup flow, and why

| Removed | PR | Reason |
|---|---|---|
| A whole step (`StepReferral`) | #6016 | one question doesn't earn a page (F62) |
| Terms-acceptance **checkbox** → passive notice | #6016 | creating the account *is* the consent; a checkbox is a step |
| Party-popper icon on the final CTA + its whole `useImperativeHandle`/ref apparatus | #6056 | decorative hover animation on a CTA; deleting it deleted 172 lines |
| `"Select one"` helper text under two `ChipGroup`s | #6056 | the control already reads as single-select |
| `"Skip if it's just you for now."` | #6056 | the Skip button says it |
| The whole email-confirmation block + `Go back` logout link | **#6146** | **strongest signal:** a mid-form logout link destroys the in-progress form, and the field it explained wasn't editable anyway |
| `overflow-x-auto` on a static preview tab row | #6056 | a fake scrollbar in a mock is chrome the user can't use |

The escalation is visible across #6016 → #6056 → #6146: a disabled `<Input disabled>` for email became read-only text + a `Go back` escape hatch (#6056), and then the whole block was deleted (#6146). Terminal rule: F70. Note #6056's link also required a keyboard fix — a form-level Enter handler must bail on `e.target.closest('a,button')` or Enter on the link submits the step instead.

### Tag summary

**`auto` (44):** F7, F9, F13, F15, F30, F31, F34, F39, F45, F48, F50, F51, F52, F60, F61, F64, F67, F68, F72, F73, F75, F79, F80, F83, F85, F86, F87, F88, F90, F94, F95, F96, F97, F100, F101, F105, F106, F107, F109, F110, F112, F116, F117, F120
**`ask` (62):** F1, F3, F5, F6, F8, F10, F11, F12, F14, F18, F19, F21, F22, F26, F27, F32, F33, F35, F38, F40, F41, F42, F43, F44, F49, F53, F54, F55, F56, F57, F58, F59, F62, F63, F65, F69, F70, F71, F74, F76, F77, F78, F81, F82, F84, F89, F91, F92, F93, F98, F99, F102, F104, F108, F111, F113, F114, F115, F118, F119, F121, F122
**`flag` (16):** F2, F4, F16, F17, F20, F23, F24, F25, F28, F29, F36, F37, F46, F47, F66, F103

Source classification carried forward: every rule in the synthesized ruleset's "Autofixable — mechanical, with a detection pattern" table is `auto` (F7, F9, F13, F30, F45, F48, F52, F73, F80, F83, F86, F87, F90, F97, F101, F105, F106, F107); every rule in its "Judgment — flag for a human, never auto-apply" list is `ask` or `flag` (F1, F2, F6, F16, F17, F23, F24, F25, F32, F33, F37, F58, F59, F63, F65, F70, F92, F99, F108, F113). The remaining `auto` tags are rules the source listed in neither, promoted on the strength of a greppable `Detect` and a mechanical `Fix`.

### Tensions to surface, not silently resolve

1. **F32 (disable the group in flight) vs. F33 (a disabled Cancel is a trap).** Corpus resolution: disable inputs that change the pending outcome; keep the exit reachable — except during a genuinely irreversible delete (bp2#7205).
2. **Alpha modifiers.** F12, F15, F35, F93, F98, F105 depend on `bg-muted/40`, `bg-muted/60`, `bg-muted/30`, `bg-destructive/10`, `ring-ring/50`, `text-muted-foreground/50` — which `airy-rules/design-system-rules.md` bans on semantic tokens "unless the user explicitly asks". These are the observed house patterns; state the conflict, don't recommend new alpha usage.
3. **F51 (spinner in the button) vs. `agents/react-19.md` + `cubic.yaml` (`MorphingLevIcon` for AI waits).** bp2#7558 uses both. The cubic rule's own carve-out settles it: "Do not flag ordinary data-fetching, form submit, or table loading spinners."

---

## Merged out

_(pending — the editor fills this in)_
