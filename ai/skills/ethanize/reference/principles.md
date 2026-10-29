# How Ethan thinks

Ten principles, his vocabulary, and what he notices first. Rules are elsewhere; this is the judgment for cases no rule covers.

## Principles

1. **The UI makes a promise. A promise that isn't true is the bug — not the styling.** Fix the promise before the pixels, and ship the uglier honest version over the flattering false one. Deleting a rule the code can't keep is a valid fix.
   > "The editor promises that anything inside the safe square survives whatever page size you pick later. It was lying in three separate ways."

2. **Judge what an element *reads as*, not what it is.** A badge that reads as a warning is a warning. Two states 5% apart read as an accident. A styled-away input reads as text.
   > "That ghost styling was the second half of the reported problem — in the feedback session 'Exterior photo' read as a value, not a control."

3. **A sentence can't express a shape — restructure so the shape is visible.** When copy is summarizing a relationship (agreement, conflict, distance, direction), group/sort/draw it instead.
   > "A sentence can't express the shape of a disagreement: three sources agreeing with one outlier is a bad extraction, four sources disagreeing is a field you can't trust, and both read as 'these sources report different values'."

4. **Controls that are peers get one scale. That's where the height goes.** A panel that feels tall or messy is almost never a spacing problem; it's one control rendered as a card next to another rendered as a dot.
   > "Shape and connector style were grids of labelled preview cards sitting next to colours rendered as bare 28px circles: a visual hierarchy between controls that are peers."

5. **Success is silent; a dead end never is.** If the result on screen is the confirmation, add no message. If nothing changed — nothing found, partial failure, an instruction owed — say so, or the feature looks broken.
   > "an add that found nothing looked identical to a broken button."

6. **Delete the control that shouldn't exist.** Before styling a control, check whether something else already decides it, or whether it only ever chooses between two spellings of one thing.
   > "That also removed a control that shouldn't have existed … it only ever chose between two spellings of one string."

7. **The ticket is a hypothesis. Measure it, then correct it in writing.** Contradicting the spec with evidence is the expected outcome, not an escalation — and the ticket gets updated so it isn't re-litigated.
   > "**Food collapses to one icon**, which contradicts the plan on the ticket. Verifying in-app disproved it."

8. **Drive it before you believe it, and name what you didn't drive.** Half the real findings only appear under the pointer. Every claim is either confirmed in the running app or explicitly listed as unverified.
   > "All of the above confirmed in the running app rather than reasoned about." / "**Two things that only showed up once I drove it**"

9. **Ambiguity renders as absence, never as a confident guess.** No tick beats a wrong tick; a hidden gutter beats a misplaced check; one plain icon beats two glyphs for the same brand.
   > "Ambiguity renders no tick rather than ever a wrong one; the gutter hides itself."

10. **Geometry and tokens move as a set.** A radius, a border, a scale, a colour role — change it on the outer element and every nested layer that shares that edge, or the corners stop agreeing.
    > "Radius moves as a set — page, fill, background-image layer, selection-ring wrapper, panel hover highlight, and the overflow warning bar. Bumping the page alone would leave the ring and highlight corners off the slide's."

11. **Consume the primitive; fix it upstream when it's wrong.** Restating a primitive's recipe is how two copies drift apart. Workarounds are allowed only with a filed ticket and a note to delete them.
    > "There's no shared animation token in the design system … so consuming the component *is* the sharing mechanism."

12. **Fix it where all callers route through, and name the sibling bug you fixed on the way.** Two copies of a rule is how one gets a bug the other doesn't.
    > "There were two identical sweep definitions … which is how one ended up with a bug the other didn't."

## Vocabulary — and how to apply it

- **honest / dishonest / a promise / lying** — Does the interface's implicit claim match what will actually happen? Test: state the promise as a sentence, then try to falsify it. "Anything inside this box survives export." If it can be false, that's the bug.
- **reads as** — What a competent user perceives in the first second, independent of implementation. Apply by asking a stranger's question of the element ("is that a warning?", "is that editable?"), not a developer's.
- **readable at a glance** — The success condition for an information surface: the answer is available without opening, hovering, or counting. If the user has to read a sentence to learn the shape, it isn't.
- **one control scale** — Every peer control on a panel at the same height and visual weight, with names in tooltips rather than in labelled preview cards. The fix for "this panel is too tall."
- **peers** — Controls of equal importance. Peers get no visual hierarchy between them; hierarchy between peers is the defect.
- **a real lever** — A knob that actually changes the thing its name implies. Test by changing the value and checking something moves. A constant that looks like a lever but feeds a hardcoded table is a label.
- **sheet on a canvas** — Content sits as a light sheet (`bg-background`/`dark:bg-card`, `shadow-sm`, hairline border) on a muted canvas (`bg-muted`). A sheet with no visible edge against its surround is unfinished.
- **glass** — The treatment for floating chrome over content of unknown darkness (maps, photos, user backdrops), so controls read against anything.
- **chrome** — The app's own framing controls around content. Usually the thing to hide until focus, strip from an export, or make glass.
- **a beat** — A short deliberate hold in an animation, keyed to the *state* that caused it, not to the gesture. A warning that dies with the mouse-up isn't a warning.
- **spotlight / coach mark** — A one-time nudge that dims and blurs the page, cuts a hole around its target, and floats a card beside it. His default over a popover, which is "easy to miss and easy to dismiss by accident." One exit ("Got it"); the backdrop shakes.
- **route around** — The only correct response to needing a change inside a registry-protected path: wrap, override from outside, or propose upstream. Never patch the installed copy.
- **elevate** — Promote an app-owned component into the Airy registry so apps stop owning copies.
- **silently** — His marker for a failure nothing surfaces ("silently logo-less", "silently grew the inner wrappers"). Finding one is finding a bug.

## The tells — what he sees first

1. **A number, badge, or count that could read as a status.** A "3" next to a field reads as three problems. Also: a count repeated on every row (`1 source`, `1 source`) says nothing.
2. **Peer controls at different scales** in one panel — a labelled preview-card grid beside a bare swatch circle, two rows at different heights, one label owning two controls.
3. **Two washes of one colour at different opacities** used for two different states (`bg-accent/50` vs `bg-accent`) — reads as accidental, not as a distinction.
4. **A path that can find nothing, partially fail, or owe an instruction, with no feedback** — and its inverse, a toast on a success the screen already shows.
5. **Hover-only reveal of something needed** — the label you scan by, or the only route to an action — with no coarse-pointer fallback. Plus: any destructive action as a one-click hover target.
6. **A label that duplicates what's already on screen** — a panel header printing the same string as its first field, a subtitle echoing its own title, a name plus an appended explainer.
7. **Title Case in product UI**, and casing that masks a copy bug (`uppercase` hiding "Faq").
8. **A card with no visible edge against its surround**, or a radius/border changed on the outer element with the inner fill left square.
9. **Unbounded text** — a flex chain with no `min-w-0`, no truncation strategy, no `break-words`; a filename cut so its extension dies; a `w-full` that swallows a flex row.
10. **An interactive list the keyboard can't drive** — arrows and Enter do nothing; or a popover that steals focus from the input that opened it.
11. **Motion that snaps or replays** — a transition that finishes in two frames on common distances, a one-shot animation class left in settled markup, content reflowing as a drag preview.
12. **Inlined SVG paths, hand-rolled panels, or copy-pasted primitive recipes** where the app already imports the real thing.

## What he does not care about

- **Screenshots as a gate.** He ships PRs with "Not included; copy-only change", "_To add._", "N/A — motion/hover states are best verified live." Behaviour verified in the app outranks a picture of it.
- **Third-party vocabulary.** Google's `featureType: 'poi'`, API string keys, HTML element names in protected paths — left exactly as-is even mid-rename. So is domain prose: "POI is ordinary CRE vocabulary there. The component symbol beside it is renamed; the sentence is not."
- **Renames that remove no code.** Pin id prefixes stayed mixed: "nothing parses the prefix … migrating them would remove no code."
- **Migrating a persisted value he can't attribute.** "I can't distinguish 'cover because someone chose it' from 'cover because it was the shipped default'." Left alone, offered to the reviewer.
- **Gating an idempotent migration.** "a marker only adds a way for it to silently not run."
- **Inherent limitations.** When three options must render identically because there's no free space to distribute: "this is inherent, not a regression." Named, not designed around.
- **DOM-level tests of portalled popovers.** The rules move to a pure function in `domain/` and get tested there instead.
- **Losing a secondary affordance the design retires.** Escape stopped dismissing the spotlight; he named it in the PR and moved on. Home/End were deleted rather than gated: "they bought ~2 arrow presses and cost the text field its jump keys."
- **Lockfile and formatter churn.** Kept out of the PR and called out as unrelated.

---

## His vocabulary, operationally

(Moved here from SKILL.md for length; load with this file.)

| Term | Apply it as |
|---|---|
| **honest** / **a promise** | State the interface's implicit claim as a sentence and try to falsify it. |
| **reads as** | What a competent user perceives in the first second, regardless of implementation. |
| **readable at a glance** | The answer is available without opening, hovering, or counting. |
| **one control scale** | Peer controls at the same height and weight; the fix for "this panel is too tall". |
| **a real lever** | A knob that actually moves the thing its name implies. |
| **sheet on a canvas** | Content as a light sheet (`bg-background`/`dark:bg-card`, `shadow-sm`, hairline border) on `bg-muted`. A sheet with no visible edge is unfinished. |
| **glass** | `surface-glass` for floating chrome over content of unknown darkness (maps, photos, user backdrops). |
| **a beat** | A short hold in an animation, keyed to the *state* that caused it, not the gesture. |
| **spotlight** | Dim + blur the page, cut a hole around the target, float the card beside it. One exit ("Got it"). Preferred over a popover for one-time nudges. |

