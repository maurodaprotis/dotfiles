# boundary-conflicts — checks that would "fix" a deliberate decision

Cross-check of `checklist.md` (48 checks) and the domain files against the 13 boundaries in
`his-words.md` §1 (`QB1–QB13`). **Scope: boundary violations only** — cases where a check, run
faithfully and correctly, reverses something Ethan decided on purpose and defended in words.
Rule over-generalization (a check that is too broad but doesn't cross a stated boundary) is
`adversarial.md` / ethan-05's lane; where the two touch, this file cites and does not restate.

**8 actionable conflicts** (5 need an `Except:`, 3 need a `[auto]` → `[ask]`/`[flag]` downgrade),
plus **4 latent risks** with no conflicting check — those are covered by the pre-flight list at the end.

Live counts below are from the `ethanize` worktree at `maurodaprotis/ethanize`.

---

## BC1 — #35 tells the agent to edit a protected primitive · violates QB1 · `[auto]`

**Check as written:** *"A single-select `ToggleGroup` must reject deselect (`if (next) onChange(next)`);
**a menu item is `cursor-pointer`, fixed in the primitive**; a chip that opens a picker needs
`transition-colors hover:bg-muted`."*

**Boundary:** `QB1` — never edit `src/components/ui/`, even to fix a real bug. *"installed from the Airy
registry and is a protected path — per AGENTS.md we don't edit it in the consuming app… Real fix belongs
upstream in Airy if we want it."*

**Where it goes wrong:** `rg -c 'cursor-pointer' src/components/ui/*.tsx` returns **zero hits**. So
"fixed in the primitive" is not describing an existing state — it is instructing the agent to *add*
`cursor-pointer` to `src/components/ui/dropdown-menu.tsx` (and `select.tsx`, `command.tsx`). This is the
only check in the corpus that **names the forbidden action as the fix**. #1 flags protected-path edits,
but #1 is `[flag]` and runs on the *incoming* diff — it will not stop a fix the skill itself authors,
and an agent resolving the two will reasonably conclude #35 is the specific rule that beats #1's general
one.

**Fix:** split the clause out of #35 and reword to the route-around, `[flag]` only:

> **[flag]** A menu item that isn't `cursor-pointer` is an upstream Airy defect. Do not edit
> `src/components/ui/*`; report it as *"belongs upstream in the Airy registry"*, or add
> `[&_[data-slot=dropdown-menu-item]]:cursor-pointer` on an app-owned wrapper if it must ship now.

**Also add to #35:** `Except: never as an edit inside a protected path.`

---

## BC2 — #23's unanchored `backdrop-blur` strips deliberate glass · violates QB1 + loses V-rule scope · `[auto]`

**Check as written:** *"Sticky chrome takes the shared z token and is fully opaque: no `backdrop-blur`,
no translucency; its divider is an inset cell shadow."*
Grep: `rg -n --pcre2 'sticky[^"]*\bz-(10|20|30|40|50)\b|backdrop-blur'`

**Boundary:** `QB1` (the blur lives in registry-owned `glass.css`, whose hooks are `--glass-tint`,
`--glass-blur`, `--glass-saturation`) — and the source rule's own scope. `visual.md:203` states it
correctly: *"`backdrop-blur` … **on a scrim or a sticky table header**"*. The checklist dropped that
qualifier, and the regex alternative `|backdrop-blur` is unanchored — it matches every occurrence in
the repo regardless of what element it's on.

**Where it goes wrong:** **21 files** carry `backdrop-blur`; only a minority are sticky headers or
scrims. Faithfully applied, `[auto]` would strip:
- `.surface-glass`, the most-used non-token helper (**20 files**, `visual.md:22`) — and `visual.md:400`
  and the V-table row 47 (`shadow-md` → `surface-glass`) *prescribe* it for anything floating over
  map tiles, imagery, or video.
- The `Spotlight` coach mark's `backdrop-blur-[2px]` (`patterns.md:60`) — the shared onboarding
  component.
- `LockedSectionBlur.tsx` (**4 hits**) — the blurred locked-value preview, which is his own
  paywall-honesty pattern from bp2#6804 (`MarketTermLockedCell`, `blur-[3px]`).
- The `surface-glass` badge he shipped in bp2#6691, which pairs glass with a `shadow-xs!` override
  precisely *because* glass.css is protected and exposes no shadow hook.

**Fix:** anchor the pattern to the surface it's about, and name the carve-outs:

> Grep: `rg -n --pcre2 '(sticky|fixed)[^"]*(backdrop-blur|bg-\w+/\d+)'` — the blur must be on the same
> element as `sticky`/`fixed`.
> `Except:` `.surface-glass` and its dark companion · `Spotlight` / coach-mark scrims ·
> `LockedSectionBlur` and any deliberate paywall blur · anything inside a protected path (report, don't edit).

---

## BC3 — #47 would delete the available-vs-active count badge · violates QB3 · `[flag]`

**Check as written:** *"A bare count or badge beside a value reads as 'N problems here': use
`ChevronsUpDown` and let the panel explain."* (Source: `visual.md:412` — *"Default: no badge"*, and
V-table row 37, which replaces `<Badge>{observationCount}</Badge>` with a bare `ChevronsUpDown`.)

**Boundary:** `QB3` — a bulk-action count badge shows what is *available*, not what the current choice
would do. *"this is intentional -- we want to show the count of available mutations."*

**Where it goes wrong:** the evidence behind #47 is bp2#7711 — a **per-row source count** where every
row read `1 source` and a user mistook "3" for three unresolved problems. The bulk-action badge in
`PlacementsBulkActions.tsx` is a different object: it is inventory for an action the user is about to
take, and he refused a bot that asked him to make it track the active choice. An agent applying #47 to
a bulk toolbar deletes the number, and an agent applying the *bot's* framing "syncs" it — both reverse
him. #47 is only `[flag]`, which limits the damage to a wrong report, but a wrong report on a decision
he defended by name is exactly the credibility cost the skill can't afford.

**Fix:**

> `Except:` a count on a **bulk-action** control is inventory, not a status — leave it, and never
> propose making it reflect the active selection (QB3). The rule is about a count sitting beside a
> **single value** in a row.

---

## BC4 — #34 / F90's submit-guard symmetry generalizes into the paid-action boundary · violates QB12 · `[auto]`

**Checks as written:** #34 — *"Submit guards match their handler: add `|| !x.trim()` to **both** the
`disabled` prop and the early return — whitespace is not input, and an enabled submit that does nothing
is worse than a disabled one."* And `flows.md` F90 — *"Disable the submit until its required free-text
input is non-empty, and make the handler's guard identical."*

**Boundary:** `QB12` / `Q1` — fail closed on paid actions; never gate a submit on an entitlement check.
*"Fact extraction is a paid action, so while the sponsor check is still pending we should fail closed
and allow an ordinary upload rather than wait and later send files with extraction enabled. That keeps
extraction from occurring unless the user has actually seen the eligible extraction UI and cost state."*

**Where it goes wrong:** both checks are correct for *whitespace*. But their stated rationale — "an
enabled submit that does nothing is worse than a disabled one", "make the guard identical" — reads
directly onto the shape two separate bots filed against him: an upload button left enabled while
`DocumentUploadDialogDealSponsorQuery` resolves, where the enabled submit *does* something (an ordinary
upload) that differs from what it would do once the query lands. An agent extending "guards must match
the handler" to `disabled={isCheckingSponsorRequirement}` implements exactly the change he refused
twice, the second time with *"this is intentional bro."* The other tempting fix — defer the paid/free
decision to the server — is worse: it bills without the user having seen the cost state.

**Fix (both #34 and F90):**

> `Except:` never extend this to an **entitlement, eligibility, or credit** query. A submit stays
> enabled while such a check is pending and the action proceeds in its **free** form (QB12). Do not
> propose `disabled={isChecking…}`, and never propose moving the paid/free decision server-side.
> The user must have seen the cost state before anything bills.

---

## BC5 — #33's disabled-trigger wrapper fires on 42 files · violates QB9 · `[auto]`

**Check as written:** *"A disabled control states its reason (tooltip or inline banner) and drops its
live hover; a disabled button used as a Tooltip trigger needs a `<span className="inline-flex">`
wrapper, since `disabled:pointer-events-none` eats the hover."*
Grep: `rg -n --pcre2 '<Tooltip[^>]*>\s*<Button[^>]*\bdisabled'`

**Boundary:** `QB9` — *"These toolbar buttons are only disabled while the whole editor is disabled…
at which point the toolbar isn't shown or hoverable anyway, so a missing tooltip on a disabled button
has no real user impact. **Not worth adding `disabled:pointer-events-auto` across the shared toolbar
buttons for that edge case.**"*

**Where it goes wrong:** the grep matches **42 files**. `checklist.md`'s Excluded section already
records his verdict and even scopes the check — *"#33 applies to a single disabled trigger, not a
wholesale toolbar sweep"* — but that qualifier lives 150 lines away from the `[auto]` check itself, in
a section an agent under budget pressure will skip. The discriminator is also not in the grep: nothing
in `<Tooltip><Button disabled` distinguishes "explains *why* this is unavailable" from "restates the
button's own name while nobody can hover it".

**Fix:** downgrade and inline the test.

> **[ask]** — propose the `<span className="inline-flex">` wrapper **only** when both hold: (a) the
> tooltip explains *why* the control is unavailable, not just what it does — his model case is
> `content="No phone numbers registered"`; and (b) the surface is reachable and hoverable while
> disabled. Never as a sweep across a shared toolbar (QB9).

---

## BC6 — #30 prescribes `role="button"`, which he was made to abandon · conflicts with QL5, risks QB7 · `[auto]`

**Check as written:** *"An icon-only button gets an `aria-label` naming the action … **a clickable
`div` gets `role="button" tabIndex={0}`**, Enter + Space, and a focus ring."*

**Boundaries:** `QL5` — a human reviewer told him *"use button instead of role=\"button\" please"* and
he complied: *"the card now renders as a native `<button>` (via a new `onCardClick` prop on
NoteActivityContent, paired with `toggleOutside` so the See more button is never nested inside it)."*
And `QB7` — the plain `or` inside a clickable card must stay non-interactive: *"Wrapping the full phrase
in a button would reintroduce the hover affordance on 'or', which we explicitly removed."*

**Where it goes wrong:** two ways. (a) The check enshrines the pattern he was corrected *out of*, so an
`[auto]` fix installs `role="button" tabIndex={0}` where the house answer is now a native `<button>`
plus `toggleOutside` for any nested control. (b) On the pitch empty-state card, an agent making the
card properly keyboard-operable can reasonably decide the descendant text describing the two actions
should also be interactive — which is precisely the bot proposal he rejected.

**Fix:**

> Prefer a native `<button>`; `role="button" tabIndex={0}` is the fallback only when the element
> genuinely cannot be a button (a table row, a label wrapper). When promoting a container, use
> `toggleOutside`-style extraction so no interactive descendant ends up nested (Q17/QL5).
> `Except:` never promote a **non-interactive descendant** of an already-clickable container —
> plain connector text inside a click target stays plain, deliberately (QB7).

---

## BC7 — #48's "control with no visible effect" catches two deliberate absences · violates QB3 + QB5 · `[ask]`

**Check as written:** *"Delete the control that shouldn't exist: one whose two options are two
spellings of one value, one another control already decides, **one with no visible effect**, or a
heading restating the page title above it."*

**Boundaries:** `QB5` — *"A non-document identity fallback (matching on `sourceType` or other row
attributes) is exactly the heuristic that was removed, because two user-input observations are
indistinguishable by attributes and a shared-type key ticks both."* And `QB3`.

**Where it goes wrong:** a source menu where the selected row shows **no checkmark** presents exactly
as "a control with no visible effect" — you open it, the current value isn't marked, selecting appears
to do nothing visible. The correct reading is the opposite: the tick is *deliberately absent* because
it can only be ID-matched. Same shape for a bulk badge whose number doesn't move when the choice
changes. Because #48 is `[ask]`, the failure mode is a confidently-worded question proposing to delete
or "fix" a decision he already litigated.

**Fix:**

> `Except:` an intentionally-absent state is not a missing effect — a selection tick that is
> ID-matched-or-absent (QB5) and a bulk count that reports availability rather than the active choice
> (QB3) both look inert and are correct. Before proposing deletion, check whether the absence is the
> feature.

---

## BC8 — the spinner/`MorphingLevIcon` discriminator is too soft to protect QB6 · `patterns.md:262–263`, `flows.md` F51/F56

**Rules as written:** `patterns.md` — *"An AI / Lev Agent action → **`MorphingLevIcon` / `MorphingLev` +
`animate-morphing-rotate`** — never the generic `Loading` spinner"* (row 262), against *"Ordinary data
fetching, form submit, table loading → the generic `Loading` spinner"* (row 263). F51's `Except:` and
`checklist.md`'s contradiction log both record bp2#7558 using **both**.

**Boundary:** `QB6` — *"this click only submits the request to the backend, and the AI-composing moment
happens later in the pitch section where the streaming animation plays. Typing dots in the popover would
suggest text is being composed there."* Note this is the **one design pushback against a human**:
ksliao asked for the swap on house-style grounds (*"i want to get rid of all spinning loaders"*) and
still lost.

**Where it goes wrong:** the split exists, but the discriminator is *"is this an AI action?"* — and a
submit button inside an AI panel (`DealPitchAIPanel.tsx`) satisfies both rows at once. Row 262's
"never" is the stronger phrasing, so an agent resolving the tie replaces the spinner and reverses him.
`checklist.md` says "kept both, scoped by role" without stating the test for the role.

**Fix:** replace the discriminator with a placement test, in all three files.

> The question is **not** "is this AI work?" but **"does text appear in this element?"**
> `MorphingLevIcon` / typing dots belong where the output will render. A control that *submits* a
> request and waits for output to appear **elsewhere** keeps a plain `Loader2` (QB6). If both are on
> screen, both are correct — bp2#7558 ships exactly that pairing.

---

## Latent risks — no conflicting check, guard only

These four boundaries have nothing in the checklist pointing at them. They're in the pre-flight list
because the instinct, not a check, is what causes the violation.

- **QB4 — timestamp-only attribution.** Nothing prescribes timestamps (`copy.md:95` and
  `copy-full.md §3.12` govern *format*, not presence). The risk is the generic instinct "an
  attribution line lost its timestamp — restore it", which reintroduces exactly what he removed:
  *"a bare timestamp over a pitch that was never written is just as misleading."*
- **QB2 — `levender`.** `checklist.md`'s "never flag" list covers it, but the token-normalizing sweeps
  (#14 raw palette → token, #15 named-colour icons → semantic) put an agent inside those exact
  strings. Any drive-by "correction" of `levender-background` → `lavender`/`purple` breaks the build
  *and* the joke. Zero-tolerance line in the pre-flight.
- **QB10 / QB11 — ticket divergence and named deferrals.** No check compares the diff to the linked
  issue, and `patterns.md:710` already reserves "anything where he overrode the ticket" as out of
  scope. The risk is a report volunteering *"this diff doesn't do what MEMO-xxxx says"* — his answer
  is to update the ticket (*"the ticket was the thing out of date, so I have updated it"*) or to name
  the sibling issue (*"MEMO-2254, which is filed as a sibling subissue of MEMO-2145"*).
- **QB8 — hover overlay covering metadata.** Nothing currently proposes reserving space (#43 pushes
  the *same* direction — overlay, don't reflow). Keep the positive half of the boundary live instead:
  always verify the `pointer-coarse:` branch drops the action back into flow, since that half *was*
  a real bug and he fixed it in the same breath. His model form for a split finding: *"Half valid, so
  half fixed."*

## Aligned, one refinement

- **`patterns.md:404`** — *"A picker lists every option and scrolls — never rely on a server page
  size"* — appears to contradict `QB13` (*"The scalar source picker this sits beside uses the same 100
  cap, so changing one and not the other would just make them inconsistent"*), but it matches his
  **final** position after he reversed himself four times (`QL9`): *"it now asks for exactly that many,
  once. No page-size guess, no `totalItems` comparison, no follow-up request."* No change needed —
  except to raise it as `[ask]` **naming the sibling picker**, so the fix lands on both surfaces or
  neither. That framing is the one he accepts; a one-sided fix is the one he refused.

---

## Pre-flight — read before applying anything

> **If the change you are about to make is one of these, stop and leave it alone.**
>
> 1. Editing any file under `src/components/ui/`, `src/components/airy-blocks/`, `src/components/lev-assets/`, `src/styles/airy-theme/`, `airy-rules/` — report it as upstream Airy, even for a real bug.
> 2. "Correcting" `levender` to `lavender` or `purple`. It is a deliberate brand misspelling.
> 3. Disabling a submit while an entitlement, eligibility, or credit check is pending — or moving the paid/free decision server-side. Fail closed; the user sees the cost state first.
> 4. Making a bulk-action count badge track the active choice, or deleting it. It reports availability.
> 5. Adding a timestamp (or any partial metadata) to an attribution line whose content is empty or failed.
> 6. Adding a "reasonable" selection tick, checkmark, or highlight that matches on attributes rather than an id. Absent beats wrong.
> 7. Replacing a `Loader2` with `MorphingLevIcon` / typing dots on a control that only *submits* — the animation belongs where the text will appear.
> 8. Making plain connector text inside a click target interactive, or wrapping the whole phrase in a button.
> 9. Reserving space or moving a hover overlay into flow for fine pointers. (Do check its `pointer-coarse:` branch drops into flow.)
> 10. Stripping `backdrop-blur` from `surface-glass`, a Spotlight scrim, or a deliberate paywall blur. The rule is sticky headers and scrims only.
> 11. Restoring a UI path a diff deliberately hid, or reporting "this doesn't match the ticket" when the PR names a follow-up issue.
> 12. Proposing a `role="button"` where a native `<button>` would do.
>
> When one of these is genuinely wrong in context, the move is `[flag]` with his own reason quoted back — never `[auto]`.
