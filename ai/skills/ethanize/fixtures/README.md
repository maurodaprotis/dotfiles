# /ethanize regression fixtures

20 files: **14 cases** with seeded defects, **6 boundaries** that must produce nothing.
No test framework, no runner, no dependencies — a manual procedure that still works in a year.

## What this is for

The skill's only evidence today is one smoke test and a hand-run 30% validation. Neither tells
the next person whether a rule edit helped or hurt. This does. Change a rule → re-run → compare
to `baseline.md`.

**The negatives matter as much as the positives.** Half the value here is `boundaries/` and the
MUST-NOT-FIRE lines in `expected.md` — they catch a rule getting greedy, which is the failure
mode that costs the skill its credibility with Ethan.

## Running it

### 1. Point the skill at the fixture directory in dry-run mode

The fixtures are standalone `.tsx` files, not a git branch, so the added-lines harness in
`detection.md` §1.3 has nothing to diff. Treat **every line as an added line**:

```bash
cd <this directory>
# the file list the skill would normally get from `git diff --name-only`
ls cases/*.tsx boundaries/*.tsx
```

Then run the checklist against those files. For the grep tier this is direct — substitute the
fixture paths for `src`:

```bash
rg -n --no-heading --pcre2 '<pattern from checklist.md>' cases boundaries
```

For `read-the-component` checks (`#3`, `#10`, `#30`, `#33`, `#41`, `#44`, and everything in
`triggers-*.md` marked so), open the file and apply the reading procedure. That step is a model
judgement, not a command — record what you concluded.

### 2. Diff against `expected.md`

For each case, three questions:

- Did every **MUST FIRE** rule fire? A miss is a **false negative**.
- Did any **MUST NOT FIRE** rule fire? That is a **mis-fire** — worse than a miss.
- For `boundaries/`, did *anything* fire? Any finding is a **boundary violation**.

A case **passes** only if all three are clean. Partial detection is a fail: catching two of a
case's three defects means the third rule is broken and nobody will notice in production.

### 3. Report

Write the result in the shape of `baseline.md`: per-case pass/fail, then three lists — rules
that **missed**, rules that **mis-fired**, rules that were **not exercised**. Update
`baseline.md` only when the new number beats the old one, and say which rule change moved it.

## Rules for editing fixtures

- **Seed from the trigger, never from the `after:` value.** Write the mistake a real developer
  would ship, then check the rule catches it. A fixture built backwards from a known fix passes
  trivially and proves nothing — that's the extraction bias that inflated the autofix tier.
- **Keep them plausible.** These read as code someone would actually ship: no defect is signposted,
  several files carry a correct-looking version of a nearby defect, and the boundary files are
  real patterns lifted from merged PRs.
- **Never delete a boundary fixture.** Add to them. Each one is a decision Ethan defended in
  words; the fixture is the only thing stopping a future rule from reversing it.
- Adding a case? Add its MUST NOT FIRE lines too. A case with only positives can't catch greed.

## Known limitations — read before trusting a run

- **These files do not compile.** Imports point at repo paths that don't resolve from here.
  That's fine: they are *detection* fixtures, not build fixtures. Do not run `tsc` against them.
- **No diff means no diff-scoping.** Checks that are explicitly "diff-scoped only" (`#2`, `#7`)
  behave here as if everything changed. That is the intended stress: it shows their raw
  precision without the scoping that normally hides it.
- **Prevalence is not realistic.** Defects are far denser here than in a real branch. Use this
  for *did the rule fire*, never for *how noisy is the rule* — `detection.md` has the real
  whole-repo counts for that.
- **`needs-rendering` checks cannot be exercised at all.** Anything requiring a browser
  (layout pump, replay-on-rerender, felt latency) is out of scope here and stays untested.
