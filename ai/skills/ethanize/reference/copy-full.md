# Copy rules for `/ethanize`

## 0. What to defer vs what to own

Two things already exist in this repo and `/ethanize` must not duplicate, restate, or modify either:

| Artifact | Path | Status |
|---|---|---|
| The ruleset | `airy-rules/copy.md` (134 lines) | Airy-registry protected. Source of truth. |
| The review workflow | `skills/airy-skills/ux-copy-review/SKILL.md` | **Protected Airy path.** Invoked as `$ux-copy-review`. |

**`/ethanize`'s copy step is: run or cite `$ux-copy-review` for everything below in "Defer", then apply only §2–§5 of this file.**

### Defer — cite, do not re-implement

`airy-rules/copy.md` already covers these exhaustively. One line, not a section:

> Capitalization and sentence case · canonical capitalization for Lev/Memo/Vault/CRE terms/roles/plans/permissions/documents/statuses · established acronyms · CTA verbs (New, Add, Save/Update, Delete/Remove, View/Open, Cancel, Dismiss) · Oxford commas · punctuation incl. no periods in labels/buttons/headings, em dashes, quote nesting, semicolons · numbers, currency, percentages · units of measure · date, time, duration, and relative-time formats — **all law already. See `airy-rules/copy.md`.**

`ux-copy-review/SKILL.md` already owns the *process*. `/ethanize` must not re-specify:

- Which files to look at (merge-base diff; the include/skip lists — which already name "tests with user-visible assertions, locale/message/config files, fixtures that seed visible UI")
- Scoping to newly added or modified strings only, and not re-litigating existing copy
- Reading surrounding code before judging whether a string is user-facing, derived, or intentionally canonical
- The escalate-don't-rewrite rule, its five triggers, and its `1. Local display fix / 2. Shared formatter / 3. Backend normalization / Recommended path:` template
- "Do not silently choose an intense rewrite just to satisfy copy rules"
- Validation and reporting format

If `/ethanize` finds a copy issue in any deferred category, the correct move is **"run `$ux-copy-review`"**, not a second opinion.

### Own — uncovered by both

Everything in §2–§5 below. These are the only copy rules `/ethanize` carries. Each is absent from `airy-rules/copy.md`
*and* from `ux-copy-review/SKILL.md`, and each is grounded in a shipped diff.

The two genuinely new contributions, which no existing doc provides at all:
- **§4 — the Title Case allowlist.** `copy.md` gives categories and a handful of examples; it does not give the
  product's actual term list, and it gives no "these look canonical but aren't" list at all. That list is where
  reviewers get it wrong.
- **§5 — 70 verbatim before/after pairs.** `copy.md` teaches by rule; nothing in the repo teaches by example.

### Correction to a common assumption

The deferred-surface list is *not* complete. `copy.md` enumerates copy surfaces as "buttons, field names, labels,
descriptions, headings, empty states, dialogs, menus, table headers, filter names, toast messages, tooltips, and helper
text", and `SKILL.md` adds tests and fixtures. Neither names **`aria-label`, `placeholder`, `<Page title>`,
`CommandGroup heading`, or code comments that quote UI strings** — all of which he sweeps as copy. That gap is §2.1.

---

## 1. Detection patterns (operational aid for deferred rules)

The rules below are owned by `airy-rules/copy.md`; only the runnable pattern is `/ethanize`'s contribution. Use them to
*find* candidates, then hand the verdict to `$ux-copy-review`. Every pattern is `rg --pcre2`, verified to run against
`src/`. Each produces candidates, not verdicts — the exclusion note is part of the pattern.

```bash
# Title Case inside a copy-bearing attribute  (highest volume: 1994 of 2070 pairs in bp2#6257)
rg -n --pcre2 '\b(label|title|heading|placeholder|aria-label|content|subLabel|ariaLabel|emptyMessage|description)="([A-Z][a-z]+ )+[A-Z][a-z]+' -g '*.tsx' -g '*.ts'
rg -n --pcre2 "\b(label|title|heading|name):\s*'([A-Z][a-z]+ )+[A-Z][a-z]+" -g '*.ts' -g '*.tsx'
#   exclude: value:/id:/data-*/href/type=/GraphQL enums/route paths/file extensions/§4 allowlist/runtime user values

# Missing Oxford comma
rg -n --pcre2 '\w+, \w+ and \w+' -g '*.tsx' -g '*.ts'

# Trailing period on a label, button, or single-sentence headline
rg -n --pcre2 '(label|title|heading|aria-label|placeholder)="[^"]*[a-z]\."' -g '*.tsx'
#   keep the period when the string is 2+ sentences — and see §3.2 for the fragment-vs-sentence split

# Spelled-out number with a unit  (a word fallback inside a numeric interpolation is also a latent bug)
rg -n --pcre2 "'(One|Two|Three|Four|Five|Six|Seven|Eight|Nine)'" -g '*.ts' -g '*.tsx'
rg -n --pcre2 '\b(One|Two|Three|Four|Five|Six|Seven|Eight|Nine) (day|days|deal|deals|file|files|slide|slides)\b' -g '*.tsx'

# Naive title-casing on a display path — fix at the formatter, not string by string
rg -n 'humanReadable\(' -g '*.tsx'
rg -n --pcre2 "replace\(/\\\\b\\\\w/g, \(c\) => c\.toUpperCase\(\)\)" -g '*.ts'
rg -n --pcre2 '\.charAt\(0\)\.toUpperCase\(\)' -g '*.tsx'
#   → humanReadableSentenceCase() for statuses/categories/activity types
#   → formatLenderType() for lender & company types (canonical Title Case; falls back to humanReadable so a new
#     enum member never renders raw)

# Product-noun casing in prose (bp2 only — see §3.7)
rg -n --pcre2 "(?<![\w/.'\"-])(vault|vaults|memo|memos)\b" -g '*.tsx' | rg -v "type=|'/|\.memo|href|data-|query|Query"
#   NEVER touch type="memo", /vaults, .memo, GraphQL enums, route paths — a blind replace breaks routing

# Canonical doc/report type lowercased
rg -n --pcre2 '\b(term sheets?|tear sheets?|rent rolls?|operating statements?|offering memorand(um|a)|marketing status report)\b' -g '*.tsx' -g '*.ts'
#   in the same string, "sources and uses" STAYS lowercase — generic finance phrase, not a canonical name

# Capital after a colon mid-sentence
rg -n --pcre2 ': [A-Z][a-z]+ [a-z]' -g '*.tsx'
#   exclude: proper nouns, acronyms, and `Name | Type` category labels
```

`src/components/ui/` is out of scope — Airy-registry protected; he explicitly left it untouched in the app-wide sweep.

---

## 2. Autofixable rules `/ethanize` owns

Mechanical, absent from both existing docs. Apply without asking.

### 2.1 `aria-label` and `placeholder` are copy — both casing directions
Named in neither doc. `aria-label` Title Case is wrong; so is all-lowercase.
```bash
rg -n --pcre2 'aria-label="[a-z]' -g '*.tsx'                        # → capitalize first letter
rg -n --pcre2 'aria-label="([A-Z][a-z]+ )+[A-Z][a-z]+' -g '*.tsx'    # → sentence case
```
`aria-label="delete"` → `aria-label="Delete"` · `aria-label="Add Company"` → `aria-label="Add company"`
**Also:** when a control has both, `aria-label` must match the visible text exactly. And sweep `<Page title>`,
`CommandGroup heading`, and code comments that quote a UI string (`{/* Contact Type */}` → `{/* Contact type */}`).

### 2.2 `...` → `…`
`copy.md`'s punctuation section covers periods, em dashes, quotes, and semicolons — never ellipses.
```bash
rg -n --pcre2 '(?<!\.)\.\.\.(?!\.)' -g '*.tsx' -g '*.ts' | rg -v 'import|spread|\.\.\.\w'
```
**Exclude:** JS spread, `...rest`, code samples, regex.

### 2.3 Typographic apostrophes and quotes in product prose
`copy.md` mandates double quotes for quotations but never straight-vs-curly.
```bash
rg -n --pcre2 "(can't|won't|don't|isn't|didn't|they'll|you've|it's|deal's)" -g '*.tsx'
```
`'` → `’` in rendered strings; quoting a user value `"{name}"` → `“{name}”`.
**Exclude:** JS delimiters, `className`, non-copy attributes, `<code>` blocks.

### 2.4 `&` → `and`
```bash
rg -n --pcre2 '(label|title|heading|aria-label)="[^"]*\s&\s' -g '*.tsx'
```
**Exclude:** `&&`, `&amp;`, entities, brand names.

### 2.5 Pluralize every generated count inline
Never `(n)`, never `1 tables`.
```bash
rg -n --pcre2 '\{\w*[Cc]ount\}\s+\w+s\b' -g '*.tsx'
rg -n --pcre2 '\(\{?\w*[Cc]ount\}?\)' -g '*.tsx'
```
→ `{n} {n === 1 ? 'file' : 'files'}` or `pluralize(n, 'switch', 'switches')`.
A demonstrative can't go through `pluralize` — spell it out: `{count === 1 ? 'this placement' : 'these placements'}`.

### 2.6 Middot for compact metadata, with the separator dropping alongside an absent part
```bash
rg -n --pcre2 "\{' '\}\{\w+\.(secondaryText|subtitle|meta)" -g '*.tsx'
```
→ `[distance, result.secondaryText || null].filter(Boolean).join(' · ')`. Never an empty separator or a placeholder.

### 2.7 Hyphenate compound modifiers
```bash
rg -n --pcre2 '\b(As Is|In Place|Lev Generated|Lev recommended|already unlocked|followups|Follow Up|Multi-Family|Sub-Type)\b' -g '*.tsx' -g '*.ts'
```
→ `As-is` · `In-place` · `Lev-generated` · `Lev-recommended` · `already-unlocked` · `follow-ups` · `Follow-up` ·
`multifamily` · `Subtype`. **Follow the dictionary, not a blanket rule** — `Sub-Type` closes up to `Subtype` while
`Sub-task` keeps its hyphen.

### 2.8 Lowercase acronym reaching a sentence-case helper
`copy.md` says preserve established acronyms; it can't help when the API sends one lowercase, because a case-detection
heuristic cannot infer it.
```bash
rg -n --pcre2 "'(faq|noi|dscr|ltv|ltc|irr|roi|arv|cam|gla|psf|reit|lihtc|egi|gpr|nnn|msa|sqft)'" -g '*.ts'
```
→ add to the `ACRONYMS` map. `faq` → `FAQ`; `sqft` → `sq ft`. And `dscr_summary` → `DSCR summary`, **not**
`DSCR Summary` — sentence case still applies to the rest.

### 2.9 Untrimmed input reaching validation or the wire
```bash
rg -n --pcre2 'if \(!(\w*[Vv]alue|query|name)\) return' -g '*.tsx' -g '*.ts'
```
→ `const trimmed = value.trim(); if (!trimmed) return`. Whitespace is not a query.

### 2.10 Test name or doc comment describing the old casing
```bash
rg -n 'title case|title casing|titleCase' -g '*.test.ts' -g '*.ts'
```
`applies title case` → `applies sentence case`. The description must not outlive the behavior.

---

## 3. Judgment rules `/ethanize` owns

Propose, don't apply. None of these have any counterpart in `copy.md` or `SKILL.md`.

> Where a judgment call turns out to need a backend/GraphQL/shared-formatter change, **stop and hand it to
> `$ux-copy-review`'s escalation template** — do not re-implement that flow here.

### 3.1 Does this string need to exist at all?
The most common call after casing, and almost always "no".
- **Ask:** does it restate the label above it, the control beside it, or the trigger that opened it?
- **Default: delete.** Evidence: `Select one` under a chip group · `Skip if it's just you for now` next to a Skip
  button · `Write one or more question and answer pairs` above the editors that say so · a dialog `<h2>` repeating the
  panel header · a blurb echoing its own label (`Deal / Deal`) · `Open the editor to try again.` → `Try again.`
- **When you delete a `DialogDescription`, set `aria-describedby={undefined}`** so Radix doesn't warn — and keep
  `DialogTitle`/`DialogDescription` as `sr-only` if the accessible name was the only thing it provided.

### 3.2 Terminal period: sentence or fragment?
Sharper than `copy.md`'s "no periods in labels".
- **Default:** a full sentence takes its period; a noun-phrase fragment does not. Headline `Content may be clipped`
  (none) over body `Move content within the safe area to avoid clipping at certain export dimensions.` (period).
  Blurbs `Metadata, tables, and FAQ` (none). Card description `…in seconds.` (period).

### 3.3 Does the label name the operation that will actually happen?
- **Ask:** is the label derived from a mode/enum, or from counts of what *this* selection will do?
- **Default:** derive from operation counts. A `mode` enum said "unlock and launch" when nothing would be charged —
  that shipped as a bug (MEMO-2383). **The money-spending verb appears only when money is spent**:
  `Unlock and switch for all selected` / `Unlock all selected` / `Switch all selected` are three labels, not one.
- **Absolute quantifiers ("all selected", "only missing") must be literally true** — gate on a predicate
  (`coversEverySelectedPlacement`) and fall back to operation-only wording when anything is excluded.
- **A CTA that navigates away or triggers outreach names that:** append `, then launch` rather than replacing the
  operation label. Don't append what the adjacent description already says — option titles stay bare, the CTA carries
  the consequence.

### 3.4 Confirm-dialog wording
- **Default:** title = the decision; description = the consequence; the two buttons are the two outcomes as verbs.
  `Leave without saving?` / `You have unsaved changes to this map. If you leave now, they’ll be lost.` /
  `Keep editing` + `Leave without saving`. Framing as "keep" puts the user's intent first:
  `Which panel would you like to keep?` / `The other panel and its contents will be removed.`
- **Banned:** "Are you sure" · `OK`/`Cancel` as the pair · a description that only re-asks the title · "Please".
- **Pending label** is the `-ing` verb plus `…` (`Deleting…`); the dialog stays open on failure with an inline error.

### 3.5 Error and failure copy
- **Default:** `<what failed>` as the title; `The <thing> was created; <what to do>.` as the body. **Never "Something
  went wrong."** e.g. `toast.error('Description was not saved as a note', { description: 'The deal was created; add
  the note from the deal page.' })`.
- **Never surface a raw validation/schema dump** — map known failures to a plain sentence naming the next step:
  `Lev Agent didn’t return usable FAQs. Try running it again.`
- **If the message names a remedy, make the remedy clickable in place** — an inline `font-medium underline
  underline-offset-2` button, not a styled `Button`.
- **Lead with a bolded diagnosis, then remedies, free fix before paid:** `**Insufficient credits for fact
  extraction**. Disable fact extraction or [purchase more credits]`.
- **Partial failure:** add everything that resolved and report the shortfall — `Added 4 of 5 nearby places.`

### 3.6 Empty-state wording
- **First run:** sell the outcome. Title = the user's goal, description = what they'll do with the result.
  `No maps yet` / `Create a map to start editing.` → `Showcase your property's nearby POIs` / `Show your property and
  the area around it, then drop the map straight into your memos and presentations.`
- **No results:** stay terse and factual — `No places found`.
- **When a feature is removed, re-read the empty state.** `No visible pins to order yet.` → `No pins to order yet.`
- Prefer the positive phrasing over the terse negative: `In no vaults` → `Not in any Vaults`.

### 3.7 Product-noun casing in the `memo` repo
`copy.md` says Memo and Vault stay capitalized as product nouns. **The `memo` repo does not follow this consistently** —
memo#798 ships toast title `Your memo is published` alongside `The Memo is now live in your Vaults` in the same app,
and memo#790 states flatly "Copy in the memo app is sentence case."
- **Default:** treat `bp2` as the strict surface. In `memo`, match the file you're in and ask before a repo-wide flip.

### 3.8 Placeholder content
- **Default:** name the concrete thing, end with `…`, prefix `Optional.` when the field can be skipped.
  `What do you want answered?` → `Add a question about this deal…`
- **Label example values:** `placeholder="Jane"` → `placeholder="e.g., Sarah"`, with realistic domain-specific values
  (`e.g., Bridgepoint Capital`, not `Acme Capital`).
- **If the field's real job isn't obvious from its label, the placeholder says it:** `Add a description…` →
  `Add some details about the deal or paste notes…`

### 3.9 Product concept or internal model name?
- **Default:** rename to the user's word. `Delete placement` → `Remove from deal` · `AI fact extraction` →
  `Extract facts into Index` · `Point of interest` → `Subject property` · `Missing only` → `Unlock missing contacts`
  (a filter name is not a CTA).
- **But do not rename a vendor's or the domain's own vocabulary.** Google's `featureType: 'poi'` and
  `point_of_interest` keys must match the API exactly; "nearby POIs" is ordinary CRE vocabulary in a sentence. Rename
  the symbol beside it, not the sentence.
- **Prefix a foreign field with its owner on collision:** `PinData.types` (Google's) → `PinData.googlePlaceTypes`,
  beside our `PinData.type`.
- **`Lev AI` is not a name — the actor is `Lev Agent`.** And **cut the company name out of benefit copy**:
  `A pitch helps Lev create more tailored memos` → `A pitch helps create more tailored memos`.

### 3.10 Does the copy still describe what the flow does?
- **Default:** when a flow changes, grep for copy that promised the old behavior. `…This will send you to your Vault…`
  → `…Publishing adds it to the deal’s resources, and you can add it to any Vault…`
- **Branch the copy when the exit differs:** `Returning to the gallery will discard it.` vs `Closing the studio will
  discard it.` — describing a screen that doesn't exist on that route is worse than being vague.
- **Announcement copy names the state, not the event**, and never explains why the team did it.
  `Settings moved here` / `…we cleared the tab bar to make room for Inbox and Campaigns.` → `Settings have moved` /
  `Deal-level settings now live in the additional actions menu.`

### 3.11 Does the button state the state it's already in?
- **Default:** say it. `Currently in use` vs `Use this table`. `Add more vaults` once one is added, `Add vault` before.
  Disabled alone leaves the user guessing why.

### 3.12 Relative vs absolute timestamps
`copy.md` gives both formats but no cutoff.
- **Default:** `< 10 days` → relative (`21 minutes ago`); older → `MMM D, YYYY`. Render `tabular-nums`; store UTC,
  display local (`.utc().local()`).

### 3.13 Operational detail on preserving user-entered casing
`copy.md` owns the principle. The mechanics are ours:
- **Whitespace-normalize only** (`.replace(/\s+/g, ' ').trim()`); reserve `formatDisplayName` for raw enum/slug
  fallbacks. Title-casing `123 main St LLC` is a corruption.
- **If you relabel a displayed string, add the new label to the search text** — after relabeling to `This page`,
  searching the visible string would otherwise return nothing.

### 3.14 Manual line breaks
- **Default:** only in a centred block at a fixed max width. `The Memo is now live in your Vaults<br />to send to
  lenders.` reads better balanced on a clause than on a measure — but it is brittle at narrow widths. Never in a
  fluid container.

---

## 4. The Title Case allowlist

**The primary contribution of this file.** `copy.md` gives categories and a few examples; it does not give the
product's term list, and it gives no trap list at all. Anything not here, in a `bp2` product-UI string, is sentence case.

**Products, apps, features, surfaces**
`Lev` · `Lev Agent` · `Lev Agents` · `Lev CRM` · `Lev Pro` · `Lev Memo` · `Lev Vault` · `Deal Assist` · `Import Hub` ·
`Support Center` · `Memo` · `Memos` · `Memo Editor` · `Vault` · `Vaults` · `Vault Checklist` · `Index` (the Deal Index)
> Banned as a name: `Lev AI`.

**Named Vault/Memo surfaces**
`Recent Memos` · `Recent Vaults` · `Untitled Memo` · `Create new Vault` · `Deal Room Vault` · `Private Vault` ·
`Intake Vault` · `Shared Vault`

**Document, template, and report types**
`Term Sheet`/`Term Sheets` · `Tear Sheet`/`Tear Sheets` · `Rent Roll`/`Rent Rolls` ·
`Operating Statement`/`Operating Statements` · `Offering Memorandum`/`Offering Memorandums` ·
`Marketing Status Report`

**CRE taxonomy values**
`Office Condo` · `General Multifamily` · `First Mortgage Loan` · `Preferred Equity` · `Bridge` · `Construction` ·
`Permanent`

**Controlled loan/request/capital-position abbreviations** (joined with ` - `)
`Perm` · `Const` · `Bridge` · `Predev` · `Land` · `TBD` · `Acq` · `Refi` · `Mezz` · `Pref` · `Subr` · `1st`
— e.g. `Perm - Refi - 1st`, `Perm - Acq - 1st`, `Bridge - 1st`

**Role / persona / relationship types** — *only as a category value; lowercase in prose*
`Debt Broker` · `Investment Sales Broker` · `Insurance Broker` · `Finance Broker` · `Lender Contact` · `Admin` ·
`Editor`

**Company / lender types** — *same restriction*
`Commercial Bank` · `Community Bank` · `Regional Bank` · `Debt Fund` · `Bridge Lender` · `Hard Money Lender` ·
`Life Insurance Company` · `Credit Union Service Organization` · `Non-US Bank`

**Plans, packages, permissions**
`Pro` · `Enterprise` · `Lev Pro` · `Pay As You Go` · `Legacy Plan` · `Full Access` · `View Only` · `Invite Only` ·
`Limited Access` · `Read-Only`

**Legal / policy documents**
`Privacy Policy` · `Terms of Service`

**Geographic proper nouns**
`New York` · `San Francisco` · `United States` · `Los Angeles County` — and street addresses as entered (`215 W 45th St`)

**Third-party names**
`Google` · `Microsoft` · `Google Slides` · `PowerPoint` · `Street View` · `Acrobat`

**Acronyms and initialisms** (preserved; the sentence around them is still sentence case)
`API` `AI` `ARV` `AUM` `CAM` `CRM` `DSCR` `EGI` `FAQ` `GLA` `GPR` `HQ` `HVAC` `IRR` `LIHTC` `LLC` `LOI` `LTC` `LTV`
`MSA` `MSR` `NNN` `NOI` `OM` `PDF` `PNG` `POI` `PPTX` `PSA` `PSF` `REIT` `ROI` `SF` `T3` `T12` `TI` `YOY` `YTD`
> Special case: `sqft` → `sq ft`, lowercase.

### NOT Title Case — the traps
These look canonical and are not. Every one is a correction he actually shipped. **This list is where reviewers get it
wrong, and it exists nowhere else.**

`Recent terms` (plural common noun — and it takes a plural verb: `Recent terms include…`) · `sources and uses` ·
`Deal owner` / `Company owner` / `Contact owner` / `Make deal owner` · `Admin tools` · `Admin: impersonate user` ·
`Pending invite` · `Vault link` (product noun keeps its cap, generic modifier doesn't) · `MSR report` ·
`Full access to Lev CRM` (permission inside a longer phrase) · `the team members page` (a reference to another screen
is not a proper noun) · `Term Sheet received` (canonical noun keeps caps, status verb doesn't) ·
`First Mortgage Loan is required` · `Mixed-use` · `multifamily` · `Value add` · `Medical office` · `Subtype` ·
`Terms received` · `Lender passed` · `Deal created` · `Preparing materials` · `Reaching out to lenders` ·
`Under contract` · `Google search` · `Social media` · `Referral from a colleague` · `Conference or event` ·
`Rate min` · `Last contact` · `Added by` · `Contact type`

> **`Recent terms` is the sharpest trap:** `copy.md` lists `Recent Memos` and `Recent Vaults` as Title Case, while its
> own sentence-case example is "Recent terms access is currently limited". The two rules point opposite ways on
> adjacent strings.

### The one call the allowlist can't settle
Category value or prose? The same words are Title Case as a controlled value and lowercase in a sentence — `copy.md`
was rewritten (bp2#7307) specifically to make this answerable.
- **Ask:** is the string a value in a filter, table cell, profile metadata, or search-result label — or inside a sentence?
- **Default:** value → Title Case (`Morgan Stanley | Commercial Bank`, `Debt Broker`). Prose → lowercase
  (`I am a debt broker at Morgan Stanley`).
- **It can flip inside one string.** `Term Sheet received`. `Full access to Lev CRM`.

Related, and named by `cubic.yaml` as its own failure mode ("Inline or rotating text fragments that should begin
lowercase"): template-literal tails, ternary word substitutions, rotating word lists, and comma-separated verb runs are
fragments → lowercase. `Prospect, Research, Enrich` → `Prospect, research, enrich` (one phrase, not three labels).
Sentence case is **not** all-lowercase — a standalone string still starts with a capital.

---

## 5. Before / after — verbatim pairs

**The second primary contribution.** Nothing in the repo teaches copy by example. Every string is copied exactly from a
merged diff. `D` = deferred category (find it, hand it to `$ux-copy-review`); `§` = a rule `/ethanize` owns.

| # | Before | After | Rule |
|---|---|---|---|
| 1 | `title="Change Deal Owner"` | `title="Change deal owner"` | D casing |
| 2 | `heading="No Companies Found with Location Data"` | `heading="No companies found with location data"` | D casing |
| 3 | `label="Phone Number (Work)"` | `label="Phone number (work)"` | D casing |
| 4 | `<Page title="Lev \| Compose Email">` | `<Page title="Lev \| Compose email">` | §2.1 |
| 5 | `aria-label="delete"` | `aria-label="Delete"` | §2.1 |
| 6 | `aria-label="Close Sub Actions"` | `aria-label="Close sub actions"` | §2.1 |
| 7 | `ariaLabel="How Did You Hear About Us?"` | `ariaLabel="How did you hear about us?"` | §2.1 |
| 8 | `{/* Contact Type */}` | `{/* Contact type */}` | §2.1 |
| 9 | `toast.error('Failed to add company to vault')` | `toast.error('Failed to add company to Vault')` | D + §4 |
| 10 | `Are you sure you want to delete this memo?` | `Are you sure you want to delete this Memo?` | D + §4 |
| 11 | `label: 'Vault Link'` | `label: 'Vault link'` | §4 trap |
| 12 | `Share Vaults with Any Company` | `Share Vaults with any company` | D casing |
| 13 | `Add File from Vault` | `Add file from Vault` | D casing |
| 14 | `'Compare the term sheets I received last week'` | `'Compare the Term Sheets I received last week'` | §4 |
| 15 | `'Upload OMs, rent rolls, and financials.'` | `'Upload OMs, Rent Rolls, and financials.'` | §4 |
| 16 | `Upload files (e.g. offering memorandum, sources and uses)` | `Upload files (e.g. Offering Memorandum, sources and uses)` | §4 + trap |
| 17 | `{ value: 'term_sheet_received', label: 'Term Sheet Received' }` | `{ value: 'term_sheet_received', label: 'Term Sheet received' }` | §4 trap |
| 18 | `{ value: 'debt_broker', label: 'Debt broker' }` | `{ value: 'debt_broker', label: 'Debt Broker' }` | §4 (value goes **up**) |
| 19 | `Full Access to Lev CRM` | `Full access to Lev CRM` | §4 trap |
| 20 | `Recent Terms includes anonymized loan terms…` | `Recent terms include anonymized loan terms…` | §4 trap |
| 21 | `'You can add them later from the Team Members page.'` | `'You can add them later from the team members page.'` | §4 trap |
| 22 | `Secure by design: Your email stays private and encrypted.` | `Secure by design: your email stays private and encrypted.` | D punctuation |
| 23 | `<span className="gradient-ai-text">Prospect, Research, Enrich </span>` | `<span className="gradient-ai-text">Prospect, research, enrich </span>` | §4 fragments |
| 24 | `'Leads',` `'Companies',` `'Properties',` | `'leads',` `'companies',` `'properties',` | §4 fragments |
| 25 | `Import deals & contacts` | `Import deals and contacts` | §2.4 |
| 26 | `You can now customize your brand colors, fonts and design library` | `You can now customize your brand colors, fonts, and design library` | D Oxford |
| 27 | `term="As Is Value"` | `term="As-is value"` | §2.7 |
| 28 | `*This will not clone any Lev Generated Memos.` | `*This will not clone any Lev-generated Memos.` | §2.7 |
| 29 | `'Unlock Lev recommended contacts for placements that do not yet have a contact assigned.'` | `'Unlock Lev-recommended contacts for placements that do not yet have a contact assigned.'` | §2.7 |
| 30 | `description="Enable automations such as followups and deal terms extractions."` | `description="Enable automations such as follow-ups and deal terms extractions."` | §2.7 |
| 31 | `` `Next Auto Follow Up: ${daysDiff \|\| 'Two'} days after Launch` `` | `` `Next auto follow-up: ${daysDiff \|\| 2} days after launch` `` | D numbers + §2.7 |
| 32 | `No table to preview.` | `No table to preview` | D punctuation |
| 33 | `Content may be clipped.` | `Content may be clipped` | §3.2 |
| 34 | `Type <span …>/</span> to add content or...` | `Type <span …>/</span> to add content or` | §2.2 + §3.1 |
| 35 | `Added ${addedCount} nearby ${addedCount === 1 ? 'place' : 'places'}.` | `` `Added ${foundPins.length} of ${selectedResults.length} nearby places.` `` | §3.5 |
| 36 | `Insufficient credits to unlock these contacts. Select fewer placements or purchase more credits.` | `… Select fewer placements or <button …>purchase more credits</button>.` | §3.5 |
| 37 | `{generationErrorMessage} Open the editor to try again.` | `{generationErrorMessage} Try again.` | §3.1 |
| 38 | `A pitch helps Lev create more tailored memos and better outreach.` | `A pitch helps create more tailored memos<br />and better outreach.` | §3.9 |
| 39 | `No maps yet` / `Create a map to start editing.` | `Showcase your property's nearby POIs` / `Show your property and the area around it, then drop the map straight into your memos and presentations.` | §3.6 |
| 40 | `No visible pins to order yet.` | `No pins to order yet.` | §3.6 |
| 41 | `placeholder="What do you want answered?"` | `placeholder="Add a question about this deal…"` | §3.8 + §2.2 |
| 42 | `placeholder="Leave blank to answer later"` | `placeholder="Optional. Leave blank to answer later…"` | §3.8 |
| 43 | `placeholder="Jane"` | `placeholder="e.g., Sarah"` | §3.8 |
| 44 | `placeholder="Add a description…"` | `placeholder='Add some details about the deal or paste notes…'` | §3.8 |
| 45 | `aria-label="Delete placement"` | `aria-label="Remove from deal"` | §3.9 |
| 46 | `AI fact extraction` | `Extract facts into Index` | §3.9 |
| 47 | `title: 'Missing only'` | `title: 'Unlock missing contacts'` | §3.9 |
| 48 | `Create in editor` | `Create from scratch` | §3.9 |
| 49 | `<Pencil size={16} />Rename` | `<Pencil size={16} />Rename file` | §3.9 |
| 50 | `'Unlock all selected'` (for every `unlock_and_set`) | `'Unlock and switch for all selected'` / `'Unlock all selected'` / `'Switch all selected'` | §3.3 |
| 51 | `'Unlock Lev recommended contacts for these placements and replace existing contacts, then launch.'` | `'Unlock and replace existing contacts with Lev recommended contacts, then launch.'` | §3.3 |
| 52 | — | `Leave without saving?` / `You have unsaved changes to this map. If you leave now, they’ll be lost.` / `Keep editing` + `Leave without saving` | §3.4 + §2.3 |
| 53 | — | `Delete map?` / `“{draft.name}” will be permanently deleted. This can’t be undone.` | §3.4 + §2.3 |
| 54 | — | `Which panel would you like to keep?` / `The other panel and its contents will be removed.` | §3.4 |
| 55 | `'Deleting...'` | `'Deleting…'` · `'Adding…'` · `Preparing export…` | §2.2 |
| 56 | `Copy PNG` · `Download PNG` · `Publish` | `Copy` · `Download` · `Add to resources` | §3.9 |
| 57 | `Settings moved here` / `Deal settings live in this menu now — we cleared the tab bar to make room for Inbox and Campaigns.` | `Settings have moved` / `Deal-level settings now live in the additional actions menu.` | §3.10 |
| 58 | `'… make sure to publish your Memo! This will send you to your Vault where you can share your Memo with lenders and download it. …'` | `'… Publishing adds it to the deal’s resources, and you can add it to any Vault to share with lenders and download it. …'` | §3.10 |
| 59 | `Looking to join an existing Lev Account? Reach out to your admin to invite you.` | `Looking for your team? Ask a teammate to invite you from their workspace settings.` | §3.10 |
| 60 | `Try Lev free` | `Activate your free Lev account` | §3.9 |
| 61 | `if (valid.length === 1) return ' (page ' + valid[0] + ')'` | `' (p. ' + valid[0] + ')'` | §2.6 |
| 62 | `{' '}{result.secondaryText}` | `[distance, result.secondaryText \|\| null].filter(Boolean).join(' · ')` | §2.6 |
| 63 | `In no vaults` | `Not in any Vaults` | §3.6 |
| 64 | `{ value: 'hard_money', label: 'Hard Money' }` | `{ value: 'hard_money', label: 'Hard Money Lender' }` | §3.9 |
| 65 | `'faq'` rendering as `Faq` | `ACRONYMS = { …, faq: 'FAQ', sqft: 'sq ft' }` → `DSCR summary` | §2.8 |
| 66 | `it('strips underscores and applies title case', …)` | `it('strips underscores and applies sentence case', …)` | §2.10 |
| 67 | `<DialogDescription>Write one or more question and answer pairs. They are added to the FAQ together.</DialogDescription>` | deleted; `aria-describedby={undefined}` | §3.1 |
| 68 | `suggestion={<span …>Select one</span>}` | prop removed | §3.1 |
| 69 | `Bring your colleagues into the same workspace so you can collaborate on deals together. Skip if it&apos;s just you for now.` | `Bring your colleagues into the same workspace so you can collaborate on deals together.` | §3.1 |
| 70 | `<Tooltip content="Featured File">` | *(shipped as-is — a known miss; should be `Featured file`. Do not cite as precedent.)* | — |
