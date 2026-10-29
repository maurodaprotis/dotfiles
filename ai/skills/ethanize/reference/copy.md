# COPY — sentence case, canonical capitalization, and the strings he rewrites

Full version with rationale and 70 examples: `copy-full.md`. Machine-readable term list: `copy-allowlist.md`.

**Already documented — cite, never restate:** `airy-rules/copy.md` (Airy-registry protected) is law for sentence case · canonical capitalization · acronyms · CTA verbs · Oxford commas · punctuation and periods-in-labels · numbers, currency, % · units · dates, times, relative time. `skills/airy-skills/ux-copy-review/SKILL.md` (**protected path — never edit or duplicate**) owns the process: file selection, changed-strings-only scoping, read-surrounding-code, the five escalation triggers and their `1. Local fix / 2. Shared formatter / 3. Backend normalization / Recommended path:` template, validation, reporting. A copy issue in any of those categories → **run `$ux-copy-review`**, don't give a second opinion. `src/components/ui/` is out of scope (Airy-protected).

**The gap this file fills:** neither doc names `aria-label`, `placeholder`, `<Page title>`, `CommandGroup heading`, or code comments quoting UI strings as copy surfaces — he sweeps all of them. Neither covers the ellipsis character, typographic quotes, the middot separator, `&`, inline pluralization, or compound-modifier hyphenation. And neither provides the Title Case term list or a single worked example.

---

## Rules — autofixable

### C1 — Capitalize a lowercase `aria-label`
- **Detect:** `rg -n --pcre2 'aria-label="[a-z]' -g '*.tsx'`
- **Fix:** capitalize the first letter. `aria-label="delete"` → `aria-label="Delete"`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6257. "Sentence case does **not** mean all lowercase. Standalone copy still starts with a capital letter."

### C2 — Sentence-case a Title Case `aria-label`, and match it to the visible text
- **Detect:** `rg -n --pcre2 'aria-label="([A-Z][a-z]+ )+[A-Z][a-z]+' -g '*.tsx'`
- **Fix:** lowercase every word after the first. `aria-label="Close Sub Actions"` → `aria-label="Close sub actions"`. When a control has both a visible label and an `aria-label`, they must read identically.
- **Except:** terms on the §Reference allowlist.
- **Tag:** auto
- **Evidence:** bp2#6257, bp2#6530, bp2#6363, memo#667 (`aria-label="Slide Styling"` → `"Slide styling"`).

### C3 — Sentence-case Title Case inside any copy-bearing attribute
- **Detect:** `rg -n --pcre2 '\b(label|title|heading|placeholder|aria-label|content|subLabel|ariaLabel|emptyMessage|description)="([A-Z][a-z]+ )+[A-Z][a-z]+' -g '*.tsx' -g '*.ts'` and `rg -n --pcre2 "\b(label|title|heading|name):\s*'([A-Z][a-z]+ )+[A-Z][a-z]+" -g '*.ts' -g '*.tsx'`
- **Fix:** lowercase every word after the first, then restore allowlist terms.
- **Except:** `value:` / `id:` / `data-*` / `href` / `type=` / GraphQL enum strings / route paths / file extensions / allowlist terms / any string that is a user-entered value at runtime.
- **Tag:** auto
- **Evidence:** bp2#6257 — the highest-volume rule in the corpus: 1994 of 2070 changed string pairs were pure casing.

### C4 — Sweep the copy surfaces neither doc names
- **Detect:** `read the component` — check `<Page title>`, `CommandGroup heading`, and code comments that quote a UI string
- **Fix:** same sentence-case treatment. `<Page title="Lev | Compose Email">` → `"Lev | Compose email"`; `{/* Contact Type */}` → `{/* Contact type */}`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6257, bp2#6146 — swept comments and mock data too "so nothing reintroduces Title Case."

### C5 — Replace `...` with the ellipsis character `…`
- **Trigger:** `...` inside a `label`/`title`/`placeholder`/`description`/`content` attribute, or a `'…ing...'` pending label
- **Detect:** `rg -n --pcre2 '(?<!\.)\.\.\.(?!\.)' -g '*.tsx' -g '*.ts' | rg -v 'import|spread|\.\.\.\w'`
- **Fix:** `…` inside string literals and JSX text.
- **Except:** JS spread syntax, `...rest`, code samples, regex. And drop the ellipsis entirely when it is a lead-in completed by visible controls — memo#665: `Type / to add content or...` → `Type / to add content or`.
- **Tag:** auto
- **Evidence:** bp2#7205 (`'Deleting…'`), bp2#7225 (`'Adding…'`), bp2#7558, bp2#7200 (`Preparing export…`), memo#665.

### C6 — Use typographic apostrophes and quotes in product prose
- **Detect:** `rg -n --pcre2 "(can't|won't|don't|isn't|didn't|they'll|you've|it's|deal's)" -g '*.tsx'`
- **Fix:** `'` → `’`; a quoted user value `"{name}"` → `“{name}”`.
- **Except:** JS string delimiters, `className`, non-copy attributes, `<code>` blocks.
- **Tag:** auto
- **Evidence:** bp2#7205 (`“{draft.name}” will be permanently deleted. This can’t be undone.`), bp2#7200 (`they’ll`), memo#798 (`deal’s`).

### C7 — Spell out `&` as "and"
- **Detect:** `rg -n --pcre2 '(label|title|heading|aria-label)="[^"]*\s&\s' -g '*.tsx'`
- **Fix:** `Import deals & contacts` → `Import deals and contacts`
- **Except:** `&&`, `&amp;`, HTML entities, brand names.
- **Tag:** auto
- **Evidence:** bp2#6530.

### C8 — Pluralize every generated count inline
- **Detect:** `rg -n --pcre2 '\{\w*[Cc]ount\}\s+\w+s\b' -g '*.tsx'` and `rg -n --pcre2 '\(\{?\w*[Cc]ount\}?\)' -g '*.tsx'`
- **Fix:** `{n} {n === 1 ? 'file' : 'files'}`, or `pluralize(n, 'switch', 'switches')`. Never `(n)`, never `1 tables`.
- **Except:** a demonstrative can't go through `pluralize` — spell it out: `{count === 1 ? 'this placement' : 'these placements'}`.
- **Tag:** auto
- **Evidence:** bp2#7724, bp2#7225, bp2#6620, memo#798.

### C9 — Join compact metadata with a middot, dropping the separator alongside an absent part
- **Detect:** `rg -n --pcre2 "\{' '\}\{\w+\.(secondaryText|subtitle|meta)" -g '*.tsx'`
- **Fix:** `[distance, result.secondaryText || null].filter(Boolean).join(' · ')`. Never an empty separator or a placeholder.
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#7222, bp2#7724, memo#673. "distance is absent for an unanchored search, so the separator has to disappear with it."

### C10 — Hyphenate compound modifiers
- **Detect:** `rg -n --pcre2 '\b(As Is|In Place|Lev Generated|Lev recommended|already unlocked|followups|Follow Up|Multi-Family|Sub-Type)\b' -g '*.tsx' -g '*.ts'`
- **Fix:** `As-is` · `In-place` · `Lev-generated` · `Lev-recommended` · `already-unlocked` · `follow-ups` · `Follow-up` · `multifamily` · `Subtype`
- **Except:** follow the dictionary, not a blanket rule — `Sub-Type` closes up to `Subtype` while `Sub-task` keeps its hyphen.
- **Tag:** auto
- **Evidence:** bp2#6257, bp2#7520, bp2-nits. "every new/edited string in the diff uses `Lev-recommended` and `already-unlocked`; only the untouched legacy line keeps `Lev recommended`."

### C11 — Add an API-lowercased acronym to the `ACRONYMS` map
- **Detect:** `rg -n --pcre2 "'(faq|noi|dscr|ltv|ltc|irr|roi|arv|cam|gla|psf|reit|lihtc|egi|gpr|nnn|msa|sqft)'" -g '*.ts'`
- **Fix:** add to the map. `faq` → `FAQ`; `sqft` → `sq ft`. A case-detection heuristic cannot infer an acronym the API sends lowercase.
- **Except:** sentence case still applies to the rest of the string — `dscr_summary` → `DSCR summary`, **not** `DSCR Summary`.
- **Tag:** auto
- **Evidence:** bp2#7711, memo#790. "That exposed a copy bug `uppercase` had masked — the FAQ head rendered 'Faq'."

### C12 — Route enum display through the right named formatter, not a naive title-caser
- **Detect:** `rg -n 'humanReadable\(' -g '*.tsx'` · `rg -n --pcre2 '\.charAt\(0\)\.toUpperCase\(\)' -g '*.tsx'` · `replace(/\b\w/g, c => c.toUpperCase())`
- **Fix:** `humanReadableSentenceCase()` for statuses, categories, and activity types; `formatLenderType()` for lender and company types (canonical Title Case, falling back to `humanReadable` so a new enum member never renders raw). Fix it at the formatter, not string by string.
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6257 (30+ call sites), bp2#6824, bp2#7031, bp2#6072.

### C13 — Capitalize the product noun in prose, leaving the generic modifier down (bp2 only)
- **Detect:** `rg -n --pcre2 "(?<![\w/.'\"-])(vault|vaults|memo|memos)\b" -g '*.tsx' | rg -v "type=|'/|\.memo|href|data-|query|Query"`
- **Fix:** `Failed to add company to vault` → `…to Vault`. The product noun keeps its cap, the generic modifier does not: `Vault Link` → `Vault link`.
- **Except:** **never** `type="memo"`, `/vaults`, `.memo`, GraphQL enums, or route paths — a blind replace breaks routing and GraphQL. And see C30 for the `memo` repo.
- **Tag:** auto
- **Evidence:** bp2#6257 — the most common uppercasing in the PR (85 `Vault` + 22 `Vaults` + 13 `Memo`).

### C14 — Restore Title Case on a canonical document or report type
- **Detect:** `rg -n --pcre2 '\b(term sheets?|tear sheets?|rent rolls?|operating statements?|offering memorand(um|a)|marketing status report)\b' -g '*.tsx' -g '*.ts'`
- **Fix:** Title Case, even mid-sentence, in placeholders, and in AI prompt examples.
- **Except:** a generic finance phrase in the same string stays lowercase — `Upload files (e.g. Offering Memorandum, sources and uses)`.
- **Tag:** auto
- **Evidence:** bp2#6257.

### C15 — Trim before validating and before sending
- **Detect:** `rg -n --pcre2 'if \(!(\w*[Vv]alue|query|name)\) return' -g '*.tsx' -g '*.ts'`
- **Fix:** `const trimmed = value.trim(); if (!trimmed) return` … then send `trimmed`.
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6804. "whitespace is not a query."

### C16 — Rename a test or doc comment that describes the old casing
- **Detect:** `rg -n 'title case|title casing|titleCase' -g '*.test.ts' -g '*.ts'`
- **Fix:** `applies title case` → `applies sentence case`
- **Except:** —
- **Tag:** auto
- **Evidence:** bp2#6257. Same discipline as his comment-updating elsewhere — the description must not outlive the behavior.

---

## Rules — judgment

### C17 — Delete a string that restates what is already on screen
- **Trigger:** a `DialogDescription` / `<p className="text-muted-foreground">` directly under a title, whose content restates the title, the control beside it, or the trigger that opened it; also any second line added in the same hunk as the first
- **Detect:** `read the component` — does it restate the label above, the control beside it, or the trigger that opened it?
- **Fix:** delete. Evidence set: `Select one` under a chip group · `Skip if it's just you for now` next to a Skip button · `Write one or more question and answer pairs` above the editors that say so · a dialog `<h2>` repeating the panel header · a blurb echoing its own label (`Deal / Deal`) · `Open the editor to try again.` → `Try again.`
- **Except:** when you delete a `DialogDescription`, set `aria-describedby={undefined}` so Radix doesn't warn — and keep `DialogTitle`/`DialogDescription` as `sr-only` if the accessible name was the only thing it provided.
- **Tag:** ask
- **Evidence:** bp2#6056, bp2#7558, bp2#7679, bp2#6987.

### C18 — Give a full sentence its period; leave a noun-phrase fragment without one
- **Trigger:** a headline/label ending in `.`, or an explanatory sentence that doesn't
- **Detect:** `read the component` — is the string a sentence or a fragment?
- **Fix:** headline `Content may be clipped` (no period) over body `Move content within the safe area to avoid clipping at certain export dimensions.` (period). Blurbs `Metadata, tables, and FAQ` (none). Card description `…in seconds.` (period).
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7343 ("Confirmed against `airy-rules/copy.md:54`"), bp2#7679, bp2#6530, bp2#7724. Sharper than the doc's blanket "no periods in labels".

### C19 — Name the operations that will actually run, derived from counts, not from a mode enum
- **Trigger:** covered by F16 — a mode-derived label: a confirm CTA whose text is selected by a mode enum rather than computed from operation counts
- **Detect:** a confirm label computed from a `mode`/enum rather than from counts of what this selection will do
- **Fix:** derive from operation counts. `Unlock and switch for all selected` / `Unlock all selected` / `Switch all selected` are three labels, not one. **The money-spending verb appears only when money is spent.**
- **Except:** preserve a hand-tuned special case with an explicit predicate rather than letting the generic path swallow it — `isSingleFreeRecommendedContactSwitch(choice)` keeps `'Switch to Lev-recommended contacts and launch'`.
- **Tag:** ask
- **Evidence:** bp2#7520. The mode enum said "unlock and launch" when nothing would be charged — that shipped as a bug (MEMO-2383).

### C20 — Reserve absolute quantifiers for when they are literally true
- **Trigger:** covered by F17 — an absolute quantifier (`all selected`, `only missing`, `every`, `all of`) in a label with no predicate gating it
- **Detect:** `read the component` — does "all selected" / "only missing" cover every selected item?
- **Fix:** gate on a predicate (`coversEverySelectedPlacement`); fall back to operation-only wording when anything is excluded.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7520. "unavailable recommendations, untouched launch-ready placements, and `missing_only` placements whose existing contacts stay put all fall back to operation-only copy."

### C21 — Append a navigation or outreach consequence to the operation label
- **Trigger:** covered by F18 — a CTA that navigates away or triggers outreach with no consequence suffix
- **Detect:** a CTA that navigates away or triggers outreach without saying so
- **Fix:** append `, then launch` rather than replacing the operation label.
- **Except:** don't append what the adjacent description already says — option card titles stay bare, only the footer CTA carries the suffix.
- **Tag:** ask
- **Evidence:** bp2#7520. "Option card titles are unchanged (no suffix) since their descriptions already end in 'then launch'."

### C22 — Write empty-state copy for the state it actually is
- **Trigger:** a first-run empty state whose title names the absence (`No maps yet`, `No X found`, `Nothing here`) rather than the outcome — a no-results state should stay terse; only the first-run state sells the outcome
- **Detect:** `read the component` — first run, no results, in flight, or failed?
- **Fix:** first run sells the outcome (title = the user's goal, description = what they'll do with the result): `No maps yet` / `Create a map to start editing.` → `Showcase your property's nearby POIs` / `Show your property and the area around it, then drop the map straight into your memos and presentations.` No-results stays terse and factual. Prefer the positive phrasing over the terse negative: `In no vaults` → `Not in any Vaults`.
- **Except:** re-read the string when a feature is removed — `No visible pins to order yet.` → `No pins to order yet.` ("visible" became a lie once hide/show was deleted).
- **Tag:** ask
- **Evidence:** bp2#7193, bp2#7219, bp2#6257.

### C23 — Rename an internal model name to the user's word
- **Trigger:** a user-facing string containing a schema/domain-model noun that isn't the user's word — `placement`, `entity`, `node`, `record`, `resource`, `mutation`
- **Detect:** `read the component` — would a user recognize this noun?
- **Fix:** `Delete placement` → `Remove from deal` · `AI fact extraction` → `Extract facts into Index` · `Point of interest` → `Subject property` · `Missing only` → `Unlock missing contacts` (a filter name is not a CTA) · `Create in editor` → `Create from scratch` · `Rename` → `Rename file`
- **Except:** **do not rename a vendor's or the domain's own vocabulary.** Google's `featureType: 'poi'` and `point_of_interest` keys must match the API exactly, and "nearby POIs" is ordinary CRE vocabulary in a sentence — rename the symbol beside it, not the sentence.
- **Tag:** ask
- **Evidence:** bp2#6824, bp2#6183, bp2#7229, bp2#6620, memo#673, bp2#7513.

### C24 — Prefix a foreign field with its owner when it collides with one of ours
- **Detect:** two fields differing by one character that mean unrelated things — `pin.type` (ours) beside `pin.types` (Google's)
- **Fix:** `PinData.types` → `PinData.googlePlaceTypes`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7229. "it gives the next place-derived field an obvious convention instead of repeating this collision."

### C25 — Name the actor `Lev Agent`, and keep the company name out of benefit copy
- **Detect:** `rg -n 'Lev AI' -g '*.tsx'`; and any benefit sentence containing "Lev"
- **Fix:** `Lev AI` → `Lev Agent`. `A pitch helps Lev create more tailored memos` → `A pitch helps create more tailored memos`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7130, bp2#7558, bp2#6987. "Removed the 'Lev' mention from the empty-state copy."

### C26 — Grep for copy that promised the old behavior when a flow changes
- **Detect:** after deleting a step or a navigation, grep for the verbs it used ("send you to", "you'll be taken", "then choose")
- **Fix:** `…This will send you to your Vault…` → `…Publishing adds it to the deal’s resources, and you can add it to any Vault…`
- **Except:** branch the copy when the exit differs per route — `Returning to the gallery will discard it.` vs `Closing the studio will discard it.`
- **Tag:** ask
- **Evidence:** memo#798, memo#783.

### C27 — Announcement copy names the state, not the event
- **Detect:** announcement or coach-mark copy explaining why the team made a change
- **Fix:** `Settings moved here` / `Deal settings live in this menu now — we cleared the tab bar to make room for Inbox and Campaigns.` → `Settings have moved` / `Deal-level settings now live in the additional actions menu.`
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7314. "The old body explained *why the team did it*; the new one just says where the thing is." Sentence case, no exclamation, no "we" narrative.

### C28 — Make a disabled button state the state it is already in
- **Trigger:** a button whose label describes the *action* while the button is permanently disabled in that state — `Use this table` on an already-in-use table
- **Detect:** a `disabled` button whose label doesn't say why
- **Fix:** `Currently in use` vs `Use this table`; `Add more vaults` once one is added vs `Add vault` before.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#7724, memo#798. "Disabled alone doesn't say why." / "the button tells you it worked without a separate confirmation."

### C29 — Show relative time for recent records, an absolute date for old ones
- **Detect:** a timestamp rendered with one format regardless of age
- **Fix:** `< 10 days` → relative (`21 minutes ago`); older → `MMM D, YYYY`. Render `tabular-nums`; store UTC, display local (`.utc().local()`).
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#4894. `airy-rules/copy.md` gives both formats but no cutoff.

### C30 — Match the file for product-noun casing in the `memo` repo
- **Detect:** `vault` / `memo` in `levco/memo` product strings
- **Fix:** match the surrounding file; ask before a repo-wide flip. Treat `bp2` as the strict surface (C13).
- **Except:** the divergence is real and documented — memo#798 ships `Your memo is published` alongside `The Memo is now live in your Vaults` in the same app, and memo#790 states "Copy in the memo app is sentence case."
- **Tag:** flag
- **Evidence:** memo#798, memo#790, memo-nits.

### C31 — Preserve user-entered casing; whitespace-normalize only
- **Trigger:** a user-entered value passed through a case transform (`.toUpperCase()`, `charAt(0).toUpperCase()`, `humanReadable(`) or trimmed with anything other than whitespace normalization
- **Detect:** a user-entered value passed through `formatDisplayName` or a title-caser
- **Fix:** `.replace(/\s+/g, ' ').trim()` and render as-is. Reserve `formatDisplayName` for raw enum/slug fallbacks.
- **Except:** if you relabel a displayed string, add the new label to the option's search text — after relabeling to `This page`, searching the visible string would otherwise return nothing.
- **Tag:** ask
- **Evidence:** bp2#6520. "title-casing a user's own entity name ('123 main St LLC') is a corruption."

### C32 — Break a line manually only in a centred fixed-width block
- **Trigger:** `<br />` inside a copy string
- **Detect:** a `<br />` inside product copy
- **Fix:** allowed for a centred two-line block at a fixed max width — `The Memo is now live in your Vaults<br />to send to lenders.` reads better balanced on a clause than on a measure.
- **Except:** never in a fluid container — it is brittle at narrow widths.
- **Tag:** flag
- **Evidence:** memo-nits, bp2#6987.

### C33 — Escalate a copy fix that needs a backend, shared-formatter, or schema change
- **Trigger:** a copy fix that would require editing a shared formatter, a GraphQL enum, a backend string, or any protected path
- **Detect:** the compliant fix would touch GraphQL, an enum map, a shared formatter, or the API contract
- **Fix:** hand it to `$ux-copy-review`'s escalation template. Never silently rewrite the UI to satisfy a copy rule.
- **Except:** —
- **Tag:** ask
- **Evidence:** bp2#6909. "Do not silently choose an intense rewrite just to satisfy copy rules."

---

## Reference

### Title Case allowlist

Anything not here, in a `bp2` product-UI string, is sentence case. Machine-readable form: `copy-allowlist.md`.

**Products / features / surfaces** — `Lev` `Lev Agent` `Lev Agents` `Lev CRM` `Lev Pro` `Lev Memo` `Lev Vault` `Deal Assist` `Import Hub` `Support Center` `Memo` `Memos` `Memo Editor` `Vault` `Vaults` `Vault Checklist` `Index`
> Banned as a name: `Lev AI`. The actor is `Lev Agent` (C25).

**Named Vault/Memo surfaces** — `Recent Memos` `Recent Vaults` `Untitled Memo` `Create new Vault` `Deal Room Vault` `Private Vault` `Intake Vault` `Shared Vault`

**Document / report types** — `Term Sheet(s)` `Tear Sheet(s)` `Rent Roll(s)` `Operating Statement(s)` `Offering Memorandum(s)` `Marketing Status Report`

**CRE taxonomy** — `Office Condo` `General Multifamily` `First Mortgage Loan` `Preferred Equity` `Bridge` `Construction` `Permanent`

**Loan/capital-position abbreviations** (joined ` - `) — `Perm` `Const` `Bridge` `Predev` `Land` `TBD` `Acq` `Refi` `Mezz` `Pref` `Subr` `1st` → `Perm - Refi - 1st`, `Bridge - 1st`

**Roles / personas** *(as a category value only)* — `Debt Broker` `Investment Sales Broker` `Insurance Broker` `Finance Broker` `Lender Contact` `Admin` `Editor`

**Company / lender types** *(same restriction)* — `Commercial Bank` `Community Bank` `Regional Bank` `Debt Fund` `Bridge Lender` `Hard Money Lender` `Life Insurance Company` `Credit Union Service Organization` `Non-US Bank`

**Plans / permissions** — `Pro` `Enterprise` `Lev Pro` `Pay As You Go` `Legacy Plan` `Full Access` `View Only` `Invite Only` `Limited Access` `Read-Only`

**Legal** — `Privacy Policy` `Terms of Service`

**Geographic** — `New York` `San Francisco` `United States` `Los Angeles County`; street addresses as entered (`215 W 45th St`)

**Third-party** — `Google` `Microsoft` `Google Slides` `PowerPoint` `Street View` `Acrobat`

**Acronyms** — `API` `AI` `ARV` `AUM` `CAM` `CRM` `DSCR` `EGI` `FAQ` `GLA` `GPR` `HQ` `HVAC` `IRR` `LIHTC` `LLC` `LOI` `LTC` `LTV` `MSA` `MSR` `NNN` `NOI` `OM` `PDF` `PNG` `POI` `PPTX` `PSA` `PSF` `REIT` `ROI` `SF` `T3` `T12` `TI` `YOY` `YTD`
> Special case: `sqft` → `sq ft`, lowercase.

### NOT Title Case — the traps

Every one is a correction he shipped. This list exists nowhere else in the repo.

`Recent terms` (plural common noun, plural verb: `Recent terms include…`) · `sources and uses` · `Deal owner` · `Company owner` · `Contact owner` · `Make deal owner` · `Admin tools` · `Admin: impersonate user` · `Pending invite` · `Vault link` · `MSR report` · `Full access to Lev CRM` · `the team members page` · `Term Sheet received` · `First Mortgage Loan is required` · `Mixed-use` · `multifamily` · `Value add` · `Medical office` · `Subtype` · `Terms received` · `Lender passed` · `Deal created` · `Preparing materials` · `Reaching out to lenders` · `Under contract` · `Google search` · `Social media` · `Referral from a colleague` · `Conference or event` · `Rate min` · `Last contact` · `Added by` · `Contact type`

> **`Recent terms` is the sharpest trap:** `airy-rules/copy.md` lists `Recent Memos`/`Recent Vaults` as Title Case while its own sentence-case example is "Recent terms access is currently limited" — the two rules point opposite ways on adjacent strings.

### The call the allowlist can't settle

Category value or prose? A value in a filter, table cell, profile metadata, or search-result label → Title Case (`Morgan Stanley | Commercial Bank`). Inside a sentence → lowercase (`a debt broker at Morgan Stanley`). It can flip inside one string: `Term Sheet received`, `Full access to Lev CRM`. `airy-rules/copy.md` was rewritten in bp2#7307 specifically to make this answerable — the rewrite replaced "when used as named types" with a surface list plus a worked example of each direction.

Related, and named by `cubic.yaml` as its own failure mode ("Inline or rotating text fragments that should begin lowercase"): template-literal tails, ternary word substitutions, rotating word lists, and comma-separated verb runs are fragments → lowercase (`Prospect, Research, Enrich` → `Prospect, research, enrich` — one phrase, not three labels). Sentence case is not all-lowercase; a standalone string still starts with a capital.

---

## Before → after

Verbatim from merged diffs. `D` = a deferred category (find it, hand it to `$ux-copy-review`).

| Before | After | Rule |
|---|---|---|
| `aria-label="delete"` | `aria-label="Delete"` | C1 |
| `ariaLabel="How Did You Hear About Us?"` | `ariaLabel="How did you hear about us?"` | C2 |
| `{/* Contact Type */}` | `{/* Contact type */}` | C4 |
| `label: 'Vault Link'` | `label: 'Vault link'` | C13 |
| `{ value: 'debt_broker', label: 'Debt broker' }` | `{ value: 'debt_broker', label: 'Debt Broker' }` | allowlist — category value goes **up** |
| `{ label: 'Term Sheet Received' }` | `{ label: 'Term Sheet received' }` | trap |
| `Full Access to Lev CRM` | `Full access to Lev CRM` | trap |
| `Recent Terms includes anonymized loan terms…` | `Recent terms include anonymized loan terms…` | trap + plural verb |
| `'Upload OMs, rent rolls, and financials.'` | `'Upload OMs, Rent Rolls, and financials.'` | C14 |
| `Upload files (e.g. offering memorandum, sources and uses)` | `Upload files (e.g. Offering Memorandum, sources and uses)` | C14 + generic stays down |
| `<span className="gradient-ai-text">Prospect, Research, Enrich </span>` | `Prospect, research, enrich ` | fragment, not three labels |
| `Import deals & contacts` | `Import deals and contacts` | C7 |
| `*This will not clone any Lev Generated Memos.` | `*This will not clone any Lev-generated Memos.` | C10 |
| `` `Next Auto Follow Up: ${daysDiff \|\| 'Two'} days after Launch` `` | `` `Next auto follow-up: ${daysDiff \|\| 2} days after launch` `` | C10 + D numbers |
| `Content may be clipped.` | `Content may be clipped` | C18 |
| — | `Delete map?` / `“{draft.name}” will be permanently deleted. This can’t be undone.` | C6 |
| — | `Leave without saving?` / `Keep editing` + `Leave without saving` | C6 |
| `No maps yet` / `Create a map to start editing.` | `Showcase your property's nearby POIs` / `Show your property and the area around it, then drop the map straight into your memos and presentations.` | C22 |
| `No visible pins to order yet.` | `No pins to order yet.` | C22 |
| `placeholder="What do you want answered?"` | `placeholder="Add a question about this deal…"` | C5 |
| `title: 'Missing only'` | `title: 'Unlock missing contacts'` | C23 |
| `aria-label="Delete placement"` | `aria-label="Remove from deal"` | C23 |
| `A pitch helps Lev create more tailored memos and better outreach.` | `A pitch helps create more tailored memos<br />and better outreach.` | C25 + C32 |
| `'faq'` rendering as `Faq` | `ACRONYMS = { …, faq: 'FAQ', sqft: 'sq ft' }` → `DSCR summary` | C11 |
| `it('strips underscores and applies title case', …)` | `it('… applies sentence case', …)` | C16 |

> Known miss, do not cite as precedent: bp2#4894 shipped `<Tooltip content="Featured File">` in Title Case.

---

## Merged out

_(pending — the editor fills this in)_
