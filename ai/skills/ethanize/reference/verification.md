# Browser verification

The one thing this skill cannot do by reading code. Ethan's own standard:
> "All of the above confirmed in the running app rather than reasoned about."
> "Two things that only showed up once I drove it."

Commands below are verified against `orca` v1.4.188 on this machine unless marked UNVERIFIED.

## 1. When it's worth it

Drive the app when the diff touches any of:
- a **hover / focus / active / disabled** treatment, or a `group-hover:` / `opacity-0` reveal
- **motion** — a transition, keyframe, enter/exit, or anything with a duration
- a **layout that can reflow** — flex/grid changes, `truncate`, `min-w-0`, sticky, overflow
- an **empty state**, a **loading state**, or a **skeleton**
- a **z-index, portal, or stacking** change
- any finding you would otherwise have to mark `Not verified`

Skip it for: copy-only edits, token renames with no computed-value change, `aria-*`/`htmlFor`
additions, type-only refactors, and pure deletions of dead code. Say you skipped it and why.

## 2. Procedure

**a. Is the runtime up?**
```bash
orca status --json          # result.runtime.state == "ready"
```

**b. Is the dev server up?** Per `CLAUDE.md`, run `bun run dev:portless` (not `bun run dev`).
The main worktree serves `https://app.localhost`; a linked worktree serves
`https://<slug>.app.localhost`, slug derived from the branch name.

```bash
curl -s -o /dev/null -w '%{http_code}\n' -k https://app.localhost --max-time 4
```
A **404 is not success** — the portless proxy answers 404 for a slug it has no app for.
Only a 200/302 means this worktree's server is actually serving. If it isn't up, start it in a
background terminal and wait; if you cannot, go to §5 rather than guessing.

**c. Log in** (first run only). Auth0 with the borrower test account in `.env` —
`TEST_LOGIN_USERNAME` / `TEST_LOGIN_PASSWORD`. Never print, echo, or paste those values;
read them into a shell variable and pass with `--value "$VAR"`. Two known gotchas:
`bun run secrets` wipes them from `.env`, and a freshly derived `https://<slug>.app.localhost`
may not be a registered Auth0 callback (shows as a callback-mismatch at the end of the flow) —
fall back to `bun run dev` on `http://localhost:3000`, which is registered.

**d. Reach the surface and drive it.**
```bash
orca tab create --url https://app.localhost/<path> --json   # → result.browserPageId
orca goto --url <url> --json                                # existing tab
orca wait --load networkidle --json
orca snapshot --json                                        # a11y tree with refs @e1, @e2…
```
Refs are per-tab and **invalidated by navigation** — re-snapshot after anything that changes the
page. For concurrency, pass `--page <browserPageId>` on every command.

```bash
orca hover   --element @e7 --json
orca click   --element @e7 --json
orca focus   --element @e7 --json
orca fill    --element @e5 --value "$LONG_STRING" --json
orca keypress --key Tab --json          # also Enter, Escape, Shift+Tab
orca scroll  --direction down --amount 1000 --json
orca eval    --expression "getComputedStyle(document.querySelector('.x')).outlineWidth" --json
orca console --limit 50 --json          # React warnings, thrown errors
```

### The driving checklist — this is where the findings actually come from

1. **Hover every revealed affordance.** Then move the pointer *toward where its menu would open*
   and check it doesn't vanish en route (`group-has-[[data-state=open]]`).
2. **Tab through the whole surface.** Every interactive element must take focus, show a visible
   ring, and be reachable — hover-only reveals are keyboard-invisible.
3. **Open a menu/popover from inside the surface**, then Escape. Check focus returns somewhere sane
   and nothing beneath it moved.
4. **Go narrow.** `orca set device --name "iPhone 16"` (see the caveat below). Watch for a
   horizontal scrollbar on `body`, a crumb that disappears entirely, or a row that wraps.
5. **Put a long string in.** A 120-char name with no spaces, and one with spaces. Does it truncate,
   wrap, or push its siblings off the edge?
6. **Empty the data.** Filter to zero matches; confirm the empty copy distinguishes
   "nothing yet" from "nothing matched". Force an error path if you can reach one.
7. **Watch the transition, not the end state.** Trigger it and screenshot mid-flight if the
   duration allows; look for a count hitting zero mid-exit, a one-way enter with no exit, and
   anything that shifts layout under the pointer.
8. **Check both themes** where colors changed: `orca set media --color-scheme dark` /
   `light` (UNVERIFIED — listed in `orca --help`, not exercised here).

**Narrow-viewport caveat (verified):** `orca set device` accepts only
`iPhone 15, iPhone 16, iPhone 16 Pro, iPhone 17, iPad, iPad Pro, Pixel 9, Galaxy S25`.
There is **no arbitrary width and no desktop reset** — `--name "Desktop Chrome"` errors. Do
narrow testing in a **throwaway tab** and `orca tab close --page <id> --json` when done, or you
leave a mobile-emulated tab behind. (`iPhone 16` gave `window.innerWidth === 390`.)

**e. Clean up.** Close tabs you opened. Leave other worktrees' tabs alone.

## 3. What to capture

`orca screenshot --json` returns **base64 in `result.data`** — there is no `--path`, and the
non-JSON form only prints `Screenshot captured (png, 127120 bytes)`. Save it yourself:

```bash
orca screenshot --format png --json | python3 -c \
  "import sys,json,base64;d=json.load(sys.stdin);open('/tmp/ethanize/after-hover.png','wb').write(base64.b64decode(d['result']['data']))"
```
`orca full-screenshot --json` is the same shape for a full-page capture.

Convention: write to `/tmp/ethanize/<pr-or-branch>/<surface>-<state>-<before|after>.png`, e.g.
`/tmp/ethanize/vault-2238/map-controls-hover-after.png`. Report the paths; do not embed base64.

**A screenshot is not always the right artifact.** Ethan's own PR bodies say:
> "N/A — motion/hover states are best verified live."

For motion, focus order, and hover-reveal behavior, the deliverable is a **written confirmation of
what was driven** — "tabbed the row: menu trigger takes focus and stays visible; hovered toward the
open menu without it vanishing; narrow at 390px shows no horizontal scroll." Capture a still only
when there is a visual difference a still can actually show.

## 4. Honest reporting (required)

Never imply a browser check happened when it didn't. Every run ends with one of these blocks,
verbatim in shape:

```
Verified in the running app (https://<url>, <n> screenshots at /tmp/ethanize/<dir>/):
- <finding> — <what was driven and what was observed>

Not verified — needs eyes:
- <finding> — <the exact interaction that would confirm it>
```

Rules: a finding is `Verified` only if you personally drove that interaction in this session.
Reading the computed CSS via `orca eval` is verification of a *value*, not of an *appearance* —
say which one you did. If you drove the surface but the finding never reproduced, report that too;
a non-reproducing finding is a finding about the finding.

## 5. No dev server available

Do not fake it and do not silently downgrade. Lead the report with:

```
Not verified in a browser — no dev server was running for this worktree.
The findings below are from reading the diff. These need eyes before merge:
- <finding> — <the interaction to drive>
```

Then list every finding in the trigger categories from §1. Offer the one-line fix: `bun run
dev:portless`, then re-run. Code-level findings (a token, an inherited `text-decoration`, a
missing `min-w-0`) can still be stated with confidence — say so, and keep them separate from the
visual ones.
