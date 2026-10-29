# his-words — Ethan in his own voice

Load on demand. Everything here is a **first-person statement by `ethanrblank`**, not an inference
from a diff. Source: 128 inline review-thread replies + 8 PR-level comments across 36 of his own PRs
in `levco/borrower-portal-v2`, plus the 7 comments he left on PRs he did not author. (`levco/memo`:
zero review comments by him anywhere.)

Two jobs:
1. **§1 stops the skill's worst failure mode** — "correcting" something he did on purpose.
2. **§4–5 tell the skill how to argue** when two options are both defensible.

ID namespace: `QB*` boundaries · `Q*` stated rules · `QL*` held loosely. (Note: `Q1–Q5` in
`workflow.md` are per-report question labels in a sample output, a different namespace — cite these
as `his-words Q7`, not bare `Q7`, in any report that also numbers questions.)

---

## 1. Boundaries — do not "fix" these

Each of these **looks like a defect** to a linter, a correctness bot, or a well-meaning polishing
agent. He was asked to change every one and refused. If the skill finds one of these shapes, it is
`[flag]` at most, and usually silent.

### QB1 — Never edit an Airy registry path, even to fix a real bug
- **Shape:** a genuine defect inside `src/components/ui/`, `src/components/airy-blocks/`, `src/components/lev-assets/`, `src/styles/airy-theme/`, or `airy-rules/`. He was shown two in one PR: a `[min, max]` uncontrolled-slider fallback that renders a phantom second thumb, and a hardcoded `bg-white` thumb.
- **Why deliberate:** these files are installed from the registry; the consuming app is not their owner. Route around from outside (wrapper, `className`, CVA variant, `data-slot` selector, `!` important override) or propose upstream.
- **His words:** *"`src/components/ui/slider.tsx` is installed from the Airy registry and is a protected path — per AGENTS.md we don't edit it in the consuming app… Real fix belongs upstream in Airy if we want it."* · *"Not ours to change in this repo… Leaving open so it can be raised with Airy if the design team disagrees."*
- **Note the two extra moves:** he *establishes provenance* before declining (`git log -S` showed the line predated his work), and he *bounds the impact* (*"all six `<Slider>` callers in this repo pass a defined `value` array, so the fallback is unreachable today"*). And he still argues the substance while refusing: *"a white thumb against a dark track has more contrast in dark mode than the `bg-background` it replaced, which went dark-on-dark and leaned on `border-primary` to stay visible. It reads as a deliberate knob treatment rather than a theming miss."*
- **Skill behavior:** flag, name the escape hatch, never edit. Leave the thread open for a human.

### QB2 — `levender` is spelled that way on purpose
- **Shape:** `levender-background`, `levender-foreground`, `--levender-*`. Reads as a typo for "lavender".
- **His words:** *"levender is an intentional misspelling 😆 I'm being cheeky with our brand colors"*
- **Skill behavior:** never rename, never spell-correct, never flag. Also: the token is `levender`, not `purple` — when replacing a raw `purple-*` utility, the semantic target is `bg-levender-background text-levender-foreground`.

### QB3 — A bulk-action count badge shows what's *available*, not what the current choice would do
- **Shape:** a count next to a bulk button that is the maximum across all choices, so it can exceed what clicking right now would affect. A bot filed this as "the badge can overstate how many placements the button will launch."
- **Why deliberate:** the number is inventory, not a preview of the pending mutation.
- **His words:** *"this is intentional -- we want to show the count of available mutations"*
- **Skill behavior:** silent. Do not "sync the badge to the active selection."

### QB4 — Attribution is all-or-nothing; there is no timestamp-only fallback
- **Shape:** a "Generated … by Lev Agent" line gated entirely on content, so a failed or empty generation shows **nothing** — not even the timestamp. A bot filed this against the Linear issue's own wording.
- **His words:** *"a failed/empty pitch has nothing to attribute, so the entire 'Generated … by Lev Agent' line is gated on content — there is deliberately no timestamp-only fallback (a bare timestamp over a pitch that was never written is just as misleading)."*
- **Skill behavior:** silent. Generalize it: **partial metadata about a thing that doesn't exist is worse than no metadata.**

### QB5 — A selection tick is ID-matched or absent; never inferred from attributes
- **Shape:** a menu of sources where the currently-selected row shows **no checkmark** because the underlying record has no id yet. A bot proposed "add a unique non-document identity fallback."
- **Why deliberate:** the attribute-matching fallback *was* the bug — it ticked two rows.
- **His words:** *"A non-document identity fallback (matching on `sourceType` or other row attributes) is exactly the heuristic that was removed, because two user-input observations are indistinguishable by attributes and a shared-type key ticks both."*
- **Skill behavior:** silent. Generalize it: **absent state beats wrong state.** Never propose a "reasonable fallback" that could match more than one row.

### QB6 — A spinner and a typing animation are different claims; do not unify them
- **Shape:** a `<LoaderCircle />` on a submit button in a product that otherwise uses `<AnimatedTypingDots />` for AI work. A *human* reviewer asked for the swap on a house-style grounds — *"i want to get rid of all spinning loaders"* — and this is the one design question where he pushed back against a person.
- **Why deliberate:** spinner = "request submitted"; typing dots = "text is being composed **here**". The composing moment lives elsewhere on the page.
- **His words:** *"this click only submits the request to the backend, and the AI-composing moment happens later in the pitch section where the streaming animation plays. Typing dots in the popover would suggest text is being composed there. Happy to revisit if we standardize a non-spinner submit treatment."*
- **Skill behavior:** `[ask]` at most, and only if the surface genuinely composes text in place. Note the open door — a *standardization* argument might win where a local one won't.

### QB7 — Non-interactive text inside a click target stays non-interactive
- **Shape:** `generate … or write it manually`, where only `write it manually` is a `<button>` and clicking `or` routes to generate. Filed by a bot as a click misfire.
- **His words:** *"'or' is deliberately plain, non-interactive text within it — clicking it behaves like clicking any other empty spot on the card (routes to generate). Only the underlined 'write it manually' opens the manual editor. Wrapping the full phrase in a button would reintroduce the hover affordance on 'or', which we explicitly removed."*
- **Skill behavior:** silent. The test is the **hover affordance**: if a span doesn't do its own thing, it must not look like it does.

### QB8 — A hover action may cover static metadata rather than displace it
- **Shape:** an absolutely-positioned "View table" button that overlays the `p. N · R×C` line on hover.
- **His words:** *"Covering the `p. N · R×C` metadata rather than displacing it was an explicit design decision: an in-flow action reflows every row under the pointer, and the metadata comes straight back the instant the pointer leaves."*
- **But:** the same reply fixed the half that *was* a bug — *"`pointer-coarse:flex` shows the action unconditionally, and touch devices have no hover to take it away again, so 'covered while hovering' became 'covered permanently.'"* → added `pointer-coarse:static`.
- **Skill behavior:** never propose reserving space or moving the overlay in flow for fine pointers. **Always** check the `pointer-coarse` branch drops it back into flow. His own model answer for a split finding: *"Half valid, so half fixed."*

### QB9 — A tooltip on a disabled control isn't worth plumbing when nobody can reach it
- **Shape:** `<Tooltip asChild>` wrapping a `disabled` Button, where `disabled:pointer-events-none` means the tooltip never opens. A bot asked for `disabled:pointer-events-auto` across a shared toolbar.
- **His words:** *"These toolbar buttons are only disabled while the whole editor is disabled (e.g. during pitch generation), at which point the toolbar isn't shown or hoverable anyway, so a missing tooltip on a disabled button has no real user impact. Not worth adding `disabled:pointer-events-auto` across the shared toolbar buttons for that edge case."*
- **Contrast, and this is the actual rule:** where a *single* disabled button had real information to give, he built the wrapper — *"The span gives Tooltip a non-disabled hover target while keeping the actual button disabled, and `inline-flex` keeps the wrapper sized/aligned like the icon button instead of introducing an inline text baseline box."* (`<span className="inline-flex">` around a disabled `<Button>`, tooltip `"No phone numbers registered"`.)
- **Skill behavior:** propose the wrapper only when the tooltip explains **why** the control is disabled AND the surface is reachable while disabled. Otherwise silent.

### QB10 — Hiding a feature is a legitimate outcome; the ticket gets updated, not the code
- **Shape:** a diff that removes a UI path the linked issue says to *relocate*. Bot filed it as lost functionality contradicting the ticket.
- **His words:** *"It was built that way first; on seeing it in the menu, the call was to hide it instead because it did not earn its space there… MEMO-2267 now records that decision explicitly, so the ticket stops contradicting the code. Not changing the implementation."*
- **Skill behavior:** never report "diff diverges from the ticket" as a defect on its own. A removal with the code left intact (`PasteAddressesField` and `useBulkAddressAdd` both untouched) is a deliberate, reversible hide.

### QB11 — Deferral to a named sibling ticket is a real answer
- **Shape:** a half-migration — the toggle removed but the rendering path still present; a control moved but its new home not built yet.
- **His words:** *"Deliberate and tracked. MEMO-2255 removes the legend toggle from the design menu; moving the legend into the export flow is MEMO-2254, which is filed as a sibling subissue of MEMO-2145. Ripping out `MapLegend` rendering here would break maps already saved with `showLegend: true`, and there is nowhere to put the controls until the export entry point exists."* · *"I'm making iterations to the onboarding in a subsequent PR — will address this there."*
- **Skill behavior:** if the diff or PR body names a follow-up ticket for the gap, don't file it. Migration residue guarded by a default (`showLegend` defaults to `false` with no UI to enable it) is finished work.

### QB12 — Fail closed on paid actions
- **Shape:** a submit button left **enabled** while an entitlement/eligibility query is still loading, so the action proceeds in its free form. Two separate bots filed this as "silently skips extraction for an eligible deal."
- **His words:** *"Fact extraction is a paid action, so while the sponsor check is still pending we should fail closed and allow an ordinary upload rather than wait and later send files with extraction enabled. That keeps extraction from occurring unless the user has actually seen the eligible extraction UI and cost state."* · (to the second bot, in full) *"this is intentional bro"*
- **Skill behavior:** silent. Never propose disabling a submit button to wait on an entitlement check, and never propose deferring the paid/free decision to the server. **The user must have seen the cost state before anything bills.** No diff would ever reveal this rule — only this comment does.

### QB13 — Consistency with the adjacent surface outranks a theoretical scaling fix
- **Shape:** a hardcoded page size / cap that a bot can prove is too small in the limit.
- **His words:** *"The scalar source picker this sits beside uses the same 100 cap, so changing one and not the other would just make them inconsistent."*
- **Caveat — this is the one boundary he later abandoned.** See `QL9`. Treat it as `[ask]`, not silent: raise it *with* the sibling surface named, so the fix covers both or neither.

---

## 2. Stated rules

His preferences, asserted in prose. All `confidence: high` — first-person statements.

- **Q1 [state] Fail closed on paid actions; the user sees the cost state before anything bills.**
  *"Fact extraction is a paid action, so while the sponsor check is still pending we should fail closed… That keeps extraction from occurring unless the user has actually seen the eligible extraction UI and cost state."* → also `QB12`.

- **Q2 [empty-state] An error is not an empty state. Read `error`, show it, offer `Try again`.**
  "No tables available" on a failed request *"reads as a field with no alternatives rather than something retryable."*

- **Q3 [state] Silence is the success signal. Notify only on shortfall, dead end, or owed instruction — from an explicit flag, never by pattern-matching the message text.**
  *"A clean full success still stays silent, because the pins landing on the map are the feedback."* And on why not a regex: *"the bar was inferring intent from English text, so any message a pattern didn't anticipate got swallowed… Adding `^Added \d+ of \d+` would have fixed the one case and left the mechanism in place."* Shape: `(message, { error?: boolean; notify?: boolean })`, with `notify: failedCount > 0 || found.length === 0`.

- **Q4 [copy] A summary counts exactly what it judged; `All N` is reserved for when it is literally all.**
  *"It now counts only what was judged: 'The 2 comparable sources agree on this value.' when some sources cannot be compared, with 'All N' reserved for when every source was."* Sibling: bulk-action copy says "all selected" only when the choice covers every selected row, else operation-only wording.

- **Q5 [copy] Numerals with countable nouns, even below ten.**
  *"`airy-rules/copy.md` spells out one–nine in body text but its stated exception is 'Always use numerals with units (5 days, 3 deals)' — and '3 sources' is the same countable-noun construction as '3 deals'."* Plus the consistency half: *"'All nine sources agree' next to 'All 12 sources agree' would drift row to row."*

- **Q6 [copy] No full stop in a headline or a label.** He cites the guide by line: *"Confirmed against `airy-rules/copy.md:54`; the headline is now 'Content may be clipped' with no full stop."* · *"`airy-rules/copy.md` prohibits periods in labels. Removed."*

- **Q7 [state] A CVA variant on the shared component, not classes at the call site — and delete a `className` the `size` prop already covers.**
  *"added a `muted` variant to `TagButton` via CVA"* · *"removed the className entirely; the size prop covers it"*.

- **Q8 [interaction-pattern] A `contains`-based outside-click guard is wrong when any child renders in a portal.**
  *"the context-chip pickers (address autocomplete, type dropdowns) render in portals outside the popover's subtree, so `contains` returns false for exactly the interactions that should keep the popover open."* Guard by selector scoped to those portals instead.

- **Q9 [a11y] A visible label must be a real label — `useId` + `htmlFor`/`id`. An `aria-label` beside a visible label is redundant.**
  *"with a real association they were a second name for the same control."* Non-labelable controls (a `button` swatch, a `role="group"`) take `aria-labelledby` pointing at the visible text *"rather than duplicating the string into an `aria-label`."* He treats a dead visible label as a regression, not a missing nicety, and verifies by measurement: *"clicking a row label lands focus on that row's input."*

- **Q10 [a11y] Quantify dead hit-target area before fixing it, then hand the caret over from the whole container.**
  *"the input is a 276×20 box inside a 320×44 pill, so the magnifier, the left padding and the strips above and below the text are 61% of the target, all dead."* Also: opening must be explicit in the handler, not a side effect of `onFocus`, which *"only fires on a change of focus."*

- **Q11 [icon] Key icon lookups on the backend's stable slug, and degrade a missing icon to a neutral circle — never `null`.**
  *"labels are copy and get reworded, the slug is the contract."* · *"a rename costs the right glyph instead of blanking the row."*

- **Q12 [border] Frame an avatar or logo with an `::after` overlay, not an inset box-shadow.**
  *"inset box-shadow paints above the background but below in-flow content, and the `Image` fills the 16px box opaquely, so it covered the frame. (It did still show for the initials fallback, which is transparent, which is why I missed it.)"* → *"matching how `UserAvatar` already frames avatars: painted above both the logo and the initials, still no layout cost, so the image stays a true 16px."*

- **Q13 [color-token] Scoping `dark` to a subtree does not re-theme inherited text; re-declare `text-foreground` alongside `dark`.**
  *"`body` sets `color: var(--foreground)`, which resolves once at the body, and `color` then inherits as a computed value — descendants inside a nested `.dark` never re-evaluate the variable. Backgrounds re-resolve because `bg-background` sits on the element itself. The chips and popovers escaped it only because each carries its own `text-*` utility; anything that merely inherits… did not."*

- **Q14 [color-token] An alpha ramp fades to a zero-alpha stop of the same hue, never the keyword `transparent`.**
  *"the CSS keyword `transparent`… is transparent black, so the track dragged through grey and misrepresented the color being adjusted."*

- **Q15 [state] A color picker's `onChange` fires for live preview AND for cancel — never write persistent state from it.**
  And note the move: *"Rather than gate the write I retired `syncBorderWithConnector` entirely, since silently redirecting the connector color to the border is what made this control a no-op to begin with."*

- **Q16 [motion] Drive "animation finished" off `transitionend`, not a timer; settle immediately under reduced motion and when mounting already-open.**
  *"Reduced motion settles immediately since `motion-reduce` removes the transition entirely — it was clipping focus rings for 200ms for nothing."*

- **Q17 [interaction-pattern] Nested interactives get moved out, not propagation-stopped.**
  *"See more/less now lives on the attribution row below the pitch, so a missed click can't land in the editor. This also resolves the nested-interactive issue of a button inside the `role='button'` wrapper."*

- **Q18 [state] Autosave restores its dirty flag on failure so the next blur retries; and it doesn't save when nothing changed.**
  *"the dirty flag is now restored in the `catch`, so blurring again after a failed autosave retries the save (matching the 'Please try again' toast)"* · *"we snapshot the editor content on open and only save if it actually changed on close."*

- **Q19 [state] A destructive dialog stays open on failure showing the error; it closes only on confirmed success — including when the API resolves `false` instead of throwing.**
  *"I propagate the boolean through `deleteMap`/`onDelete` and only close the dialog when the map was actually deleted."*

- **Q20 [state] Every dialog exit path goes through one shared `close()` that resets sub-state.**
  *"`Cancel` and the successful-save path called `onOpenChange(false)` directly, skipping the reset that Escape and the overlay went through."* Verified in the browser: *"expand instructions → Cancel → reopen now comes back on the keep/replace step with no textarea mounted."*

- **Q21 [state] Never reserve layout for an empty fragment — gate on the *formatted string*, not on array length.**
  *"`formatSourcePages` returns an empty string when every entry is null, while the guard only checked array length, so an empty suffix still took part in the measured layout."*

- **Q22 [keyboard] Don't steal a text field's caret keys. Remove the shortcut rather than gate it.**
  *"they belong to the caret in an editable field, and the list caps at 6, so they bought ~2 arrow presses and cost the text field its jump keys."*

- **Q23 [shadow] Elevation runs one step lower than instinct: `shadow-xs` at rest, `hover:shadow-sm`.**
  His only styling instruction to another engineer, given twice on one line: *"can you swap shadow-sm to shadow-xs?"* / *"and hover:shadow-md -> hover:shadow-sm"*.

- **Q24 [hover] A persistent control sitting in a hover region should reveal on hover like its neighbours.**
  *"I wonder if we can make the `...` only show when hovering in that area too? what do you think"* — note the form: a question, not a directive.

- **Q25 [color-token] Match a named reference rather than inventing a value, and say which reference.**
  *"I mimicked the old windy version"* · *"it seems like our outline button uses old code. I just copied and pasted whatever shadcn has for the outline button currently https://ui.shadcn.com/docs/components/button"*

- **Q26 [perf-felt] Verify in the running product and report the numbers.**
  *"Verified against the network: a five-source picker issues a single request with `pageSize: 5`."* · *"Verified under coarse-pointer emulation: `position: static`, action starts at x=363, metadata ends at x=355, no overlap."* · *"Verified locally with format, type-check, lint, and browser screenshots."* And he states what he could **not** verify: *"Not independently verified: the partial-failure string itself, since it needs a Place Details call to fail mid-batch and I can't induce that on demand."*

- **Q27 [state] Fix the mechanism, not the reported case.**
  *"the regex is the root cause… Adding `^Added \d+ of \d+` would have fixed the one case and left the mechanism in place."* · *"Fixed by migrating once up front and using that list for both `center` and `pins`, rather than teaching the centre lookup to understand legacy values — the same bug would otherwise reappear for any future field derived from pins before migration."*

---

## 3. Held loosely — propose, don't apply

His first instinct lost these. The skill should surface them as `[ask]`, and should expect him to
accept a simpler alternative than either side proposed.

- **QL1 — Bespoke measurement code.** He shipped a hidden probe + binary search to find a six-line clamp; on request it became *"a plain CSS max-height clamp with a gradient mask, plus a small ResizeObserver that only decides whether the toggle is needed."* **Changed his mind:** ksliao — *"can we remove all debugging stuff? would be great if you could clean and simplify everything since it's over-engineered right now."*
- **QL2 — Extra classes beside a sized primitive.** *"Done — trimmed to `border-beam-hover` plus the variant."* / *"removed the className entirely; the size prop covers it."* **Changed his mind:** *"why do we need all these extra custom classes? it should be a reusable Button as is."* He kept exactly one and documented why: *"One class had to stay: `border-0`, because twMerge parses `border-beam-hover` as a border-color utility and drops the variant's `border-transparent`, leaving a visible 1px border."*
- **QL3 — Hoisted single-use constants.** *"Done — inlined the toggle, prose, and mask class strings at their use sites (they each had a second consumer in the old measurement probe, which is what originally justified hoisting them). Kept the numeric constants since they encode the six-line budget math."* **Changed his mind:** *"can we not abstract variables unless it's used in multiple places? should be used directly where it's used so we avoid needing to lookup back and forth."*
- **QL4 — Parallel `Record`s and multiple hooks for one concern.** Four keyed `Record`s → one `MAP_PAGE_SIZE_DEFS`; three effect/state machines → `useExportFrameState(map)`, where *"the escaped-content measurement drops out as a plain function since it was never stateful."* **Changed his mind:** phwebi, on repetition.
- **QL5 — `role="button"` on a card.** → a native `<button>` *"paired with `toggleOutside` so the See more button is never nested inside it."* **Changed his mind:** andresdicamil — *"use button instead of role=\"button\" please."*
- **QL6 — Custom over primitive.** He keeps custom only with a stated gap: *"We looked at `Collapsible`, but it doesn't support a partially-visible collapsed state (the six-line peek with a fade)."* Everything around it still got deleted. **Propose the primitive; expect a named gap or a concession.**
- **QL7 — Label-pattern lookups against backend strings.** → slug-keyed with a fallback icon. **Changed his mind:** maurodaprotis — *"⛏️ picky comment. this is brittle as F. If backend renames one of this nodes or section this logic stops working."* Brittleness against a contract he doesn't own always wins.
- **QL8 — Control placement he can't reproduce a problem with.** A screenshot or a repro flips him instantly: *"the button click is tricky where it's currently positioned - when i try to click it, it clicks into the editor instead"* → moved. Likewise a screenshot of overlapping columns restructured the whole scroll container.
- **QL9 — Any cap, page size, or magic number defended with "the worst real case we have is N".** The single clearest example of him overturning himself, four times on one thread: refused ("the worst real case we have is 14") → *"Reopening this — you were right that 100 was arbitrary, and I was wrong to wave it off."* → shipped a `totalItems` truncation check → *"Simplified again on the second look — you were right that the truncation check was still working around the problem rather than removing it. The row already knows how many observations it has… it now asks for exactly that many, once. No page-size guess, no `totalItems` comparison, no follow-up request."* → then the backend limit: *"you are right that 150 caps a request, not a field, so clamping to it was still truncating."*
- **QL10 — His own weak argument.** He will reverse the *reasoning* while keeping the conclusion: *"Investigated properly this time rather than arguing from the mount tree. Still declining."* **The skill should expect its argument to be audited even when its conclusion is accepted.**

---

## 4. How he argues — ranked by frequency

When two options are both defensible, this is the appeal he reaches for. Reach for them in this
order; the top two carry almost every contested call.

1. **Honesty of the UI (~9 uses).** *Does the screen claim something untrue?* — Use this whenever the change is about what the interface tells the user: attribution over absent content, an error dressed as an empty state, a count that includes what it didn't judge, a tick that could match two rows, a spinner that implies composing, a gradient that misrepresents a color. **His strongest and most consistent appeal. When in doubt, argue from what the UI is asserting.**
2. **Reachability, measured (~7).** *Can this actually happen in the shipped product, and how often?* — Use it in both directions: to kill a finding (*"unreachable today"*, *"the worst real case we have is 14"*, *"no real user impact"*) and to justify one (*"61% of the target, all dead"*, *"219,519 bytes of server HTML… 0"*). **Never raise a finding without it; he will check.**
3. **Root cause over reported case (~7).** *Would this fix recur elsewhere?* — Use it when the proposed patch is narrower than the mechanism: a regex that anticipates one message, a guard on a write that shouldn't exist, a lookup taught to understand legacy values. His preferred move is to **retire the mechanism**, not gate it.
4. **Scope and ownership (~8, but rarely about design).** *Whose repo, whose ticket?* — Protected paths, upstream Airy, a named sibling issue. Frequent, but it settles *who* fixes a thing, not *what is right*. Don't lead with it on a taste question.
5. **Consistency with an adjacent surface (~6).** *Does this make two neighbouring surfaces disagree?* — The strongest available argument against a decision he has already made deliberately: name the sibling that would now differ (*"the scalar source picker this sits beside uses the same 100 cap"*, *"matching how `UserAvatar` already frames avatars"*, *"would drift row to row"*). **If the skill must challenge an aesthetic call, this is the argument to use.**
6. **Restraint / earning attention (~5).** *Is this worth the user's attention or the space it takes?* — *"it did not earn its space there"* · *"A clean full success still stays silent"* · *"an in-flow action reflows every row under the pointer"* · Home/End *"bought ~2 arrow presses and cost the text field its jump keys."* Use it for additions, density, and notification decisions.
7. **Cost / entitlement safety (~2, but absolute).** *Could this bill someone who hasn't seen the price?* — Rare, and never traded away. See `Q1`/`QB12`.
8. **Code simplicity (~4).** Almost always *conceded* rather than asserted — it is the reviewers' argument, and it beats his. Which makes it the skill's best lever; see §5.

---

## 5. The reviewer asymmetry

- **He refutes bots on reachability.** Every design-question refusal in the corpus is against `cubic-dev-ai` / `greptile-apps` / `graphite-app`, and the refusal is almost always "this can't happen in the product" plus a measurement. A correctness-shaped finding that can't prove it fires gets closed.
- **He concedes to humans on simplicity.** Nearly every concession is to `ksliao`, `phwebi`, `maurodaprotis`, or `andresdicamil`, and nearly every one is *"this is over-engineered"*, *"why all these extra classes"*, *"can we not abstract variables unless it's used in multiple places"*, *"use button instead of role=button"*, *"this is brittle as F"*. He rewrites without argument, and often lands simpler than asked.
- **So: a simplicity objection is the one he actually yields to.** When the skill's proposal deletes code, removes a constant, drops a class, or replaces bespoke measurement with a CSS primitive, **say so explicitly and quantify it** — fewer lines, one class instead of five, no follow-up request. Framed as polish it gets debated; framed as *less code* it gets applied.
