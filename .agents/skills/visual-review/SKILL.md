---
name: visual-review
description: Check the running UI against acceptance criteria and usability, with screenshots and optional videos. Use after changes to screens, interactions, or server behavior that affects the UI, and for requested visual reviews. Skip internal-only changes.
---

# Visual review

## Choose the checks

Build a checklist from the task, spec, or issue. Use the diff, including uncommitted work, to
find affected screens. For standalone reviews, use the requested pages and flows. Derive missing
criteria from the task, label assumptions, and ask only when ambiguity changes what counts as success.

If no visible behavior changes, explain why visual review is not applicable and stop before
setup. Server changes can affect existing screens without changing UI files. Mark internal-only
criteria outside visual scope.

## Prepare

Keep every review-created file in a unique, gitignored directory inside the repo. Use the
requested location or an existing `.context/` or `tmp/`; default to `.context/visual-review/`.
Confirm with `git check-ignore` and add a narrow ignore entry if needed.

Before launching tools, direct artifacts, fixtures, databases, logs, browser profiles, downloads,
caches, and temporary files there. Isolate app storage through documented overrides or test
injection. A separate checkout does not isolate home-directory data. Leave existing credentials
and databases untouched. If repo-local storage is impossible, report the blocker; do not fall
back to external directories.

Use the project's runtime, package manager, launch command, URL, and login instructions.
Reuse an app only if it serves the intended checkout with isolated test storage. Open a separate
browser session. Actions affecting live data or external services require explicit authorization.

### Tools and prerequisites

Use agent-browser by default. Check `agent-browser --version`, read its skill, and load
`agent-browser skills get core`. Use Playwright CLI for traces, custom Playwright code, or a
blocked check. Read its skill or installed help first; check `playwright-cli --version` when needed.
When switching, restore the page, viewport, login, and data; sessions and element references differ.

Install missing tools locally, for example:
`npm install --prefix <review-dir>/tools --cache <review-dir>/npm-cache agent-browser`.
For Playwright CLI, substitute `@playwright/cli`. Run the binary from `tools/node_modules/.bin`.
Follow installed help for missing browsers, keeping downloads and caches in the run directory.

### Test data

Use or create in-scope fixtures for relevant empty, single-item, dense, long-text, and extreme
chart-value cases. Fix the clock when dates matter; otherwise record the actual date and seed
for it. Label mocks and missing data. Browser response mocks prove rendering, not provider
integration. Keep fixture changes separate from code under verification.

## Drive and inspect

Exercise criteria through actual controls. Cover relevant loading, validation, error, and recovery
states. Check keyboard navigation, visible focus, and focus return using real keys such as Tab.
Programmatic `.focus()` may not activate `:focus-visible`. Direct DOM changes can prepare a state
but cannot prove user input works.

Use snapshots to check text, roles, control states, and interaction results. Capture screenshots
and open each image you cite to judge its appearance.

Inspect changed screens and states at supported desktop and narrow widths, starting around
375px for narrow. Explain fixed-size exceptions. Frame the changed elements: full-page captures
can miss horizontal overflow, so scroll through wide content at the tested width. Widening the
viewport does not verify the narrow layout.

Check alignment, spacing, hierarchy, readability, contrast, wrapping, clipping, overlap, labels,
reachable actions, feedback, and recovery. Compare with nearby UI and supplied designs. Explain
user impact; distinguish defects from preferences.

Use console, network, HTTP, and accessibility checks to support findings, not replace UI checks.

## Judge and recheck

After your own implementation, fix in-scope defects, repeat affected checks, inspect fresh
screenshots, and run project checks appropriate to the fixes. In review-only mode, report findings
without changing the implementation.

Give each in-scope criterion PASS, FAIL, or UNVERIFIED, with evidence labeled as browser
observation, executed test, or static inspection. Missing tools, access, data, or observations
mean UNVERIFIED; explain why. A rendering check cannot pass a whole provider criterion, and
runtime tests cannot prove compile-time guarantees. Report internal-only evidence separately.

Finish when every criterion has a disposition and each defect is fixed and rechecked or reported.
An incomplete review cannot receive an overall pass.

## Report and clean up

Save screenshots of final screens and failures, named by screen, state, and viewport.
Add video when motion, timing, or a sequence needs it. Show the action and result, and inspect
the recording before citing it. Extracted frames prove appearance, not timing.

Report briefly:

- Changed-behavior verdict, reviewed screens, data setup, viewport sizes, and limits.
- Each criterion's status, action, observed result, and evidence.
- Remaining defects by impact, with reproduction steps and expected versus actual results.
  Separate introduced defects, existing defects, and design suggestions.
- Fixes and rechecks, with linked or embedded images/videos and captions explaining the findings.

Keep private data out of captures and generated evidence out of source commits unless requested.
Publish externally only when requested. Stop recordings and close only sessions and processes
started for this review; retain evidence and leave pre-existing servers and sessions running.
