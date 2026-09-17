---
name: visual-review
description: Review the running UI against acceptance criteria and broader visual and interaction quality, with screenshots and optional videos as evidence. Use automatically after implementing user-facing UI changes, and when asked for a visual review, UI acceptance check, or interaction review. Backend-only changes do not trigger it.
---

# Visual Review

Drive the affected user flows, inspect their rendered appearance, and report what actually works.
Review both the requested behavior and usability beyond the explicit acceptance criteria.

## 1. Establish the review

Read the current task and its linked spec or issue. Preserve explicit acceptance criteria in a
checklist and map each to an observable screen, state, or interaction. Use the relevant diff,
including uncommitted work, to locate the affected surface; the diff is a scope aid, not proof.
For a standalone review without a diff, use the requested pages and flows.

When criteria are missing, derive a short checklist from the requested behavior and label it as
inferred. Resolve routine details from the project; ask only if an ambiguity materially changes
what success means. Keep broader usability observations separate from requirement failures.

Establish whether this is verification of your own implementation or a review-only request:

- After implementing: fix observed defects within the original task, then repeat affected checks.
- Review-only: report findings and reproduction steps; leave implementation changes to a fix task.

## 2. Prepare the app and browser

Discover the project's launch command, URL, test data, and authentication setup from its
instructions and configuration. Reuse a suitable running instance or start the documented local
review/dev environment. Verify it serves the intended checkout. Record the URL and data setup.

Prefer isolated test data and existing fixtures. For data-dependent layouts, exercise relevant
empty, single-item, dense, and long-text cases, including extreme values for charts. Use exact
fixtures for numeric assertions and a pinned clock when time affects the result, if supported.
Create missing local fixtures when within the implementation task; otherwise report the fixture
gap and which checks it blocks. Synthetic or mocked data must be identified in the report.

Use a separate browser session for this review. Keep production writes and consequential external
actions within the user's explicit authorization; a review is not permission to send messages,
purchase, or modify live customer data. Use test equivalents where available.

### Browser tools

**Default: agent-browser.** Read its available skill and load the installed workflow with
`agent-browser skills get core`. Use its snapshot/element-reference interaction loop, screenshots,
and video recording. Refresh references after navigation or significant page changes. Consult
installed help for the exact commands rather than relying on a copied command catalog.

**Debugging fallback: Playwright CLI.** Use it when a concrete investigation benefits from
Playwright traces, custom Playwright code, or a capability unavailable or unreliable through the
default driver. Read the available `playwright-cli` skill and relevant references, or its installed
`--help` if the skill is absent. State what the switch will resolve. Re-establish the same URL,
viewport, data, and authentication; sessions and element references are not interchangeable.

If agent-browser is unavailable, use an available Playwright CLI and disclose the fallback.
If neither is available, report the missing dependency and the resulting unverified checks.
Tool unavailability never turns a check into a pass.

## 3. Exercise and inspect

Drive each criterion through the actual UI: click, type, submit, navigate, and observe the result.
Include relevant validation, loading, error, empty, and recovery states. Test keyboard navigation,
visible focus, and focus return for changed interactive controls such as dialogs and menus.
Use HTTP, console, and network inspection to support diagnosis; API responses cannot establish
that a user interaction works. Mocks and direct state manipulation can prepare scenarios, but the
interaction under review must still be exercised through the UI.

For every UI criterion, use both verification channels:

- **Structure and behavior:** browser snapshots establish text, roles, control states, and results
  of interactions.
- **Rendered appearance:** capture and open screenshots with the image-viewing tool. Judge the
  pixels yourself; creating an image file or reading the accessibility tree is not visual review.

Inspect each materially different affected screen/state at a desktop and narrow viewport by
default, using supported product dimensions (about 375px is a useful narrow starting point).
For a documented fixed-size or desktop-only surface, choose relevant supported sizes and explain
the coverage. Check breakpoints suggested by an observed problem rather than an exhaustive grid.

Screenshots must frame the changed surface. Full-page capture may include vertical scrolling
while still missing horizontal overflow. Inspect horizontally scrolling content in segments at
the target viewport; a wider overview can supplement those captures but cannot prove the narrow
layout works. Wait for the intended state to render before capturing, and label transient states.

For each inspected state, record the material results of this visual and usability checklist:

- Alignment, spacing, hierarchy, and consistency with neighboring UI or supplied designs.
- Readability, contrast concerns, long-text wrapping, truncation, clipping, and overflow.
- Collisions, chart headroom, crowded controls, and behavior as data density changes.
- Discoverability, clear labels, feedback after actions, and useful error/recovery paths.
- Keyboard usability, visible focus, and whether responsive layouts keep actions reachable.

When useful, supplement inspection with available accessibility checks. Describe their actual
coverage; a visual review or automated scan is not a complete accessibility audit.

An objective defect has observable impact, such as an unreachable button or text obscuring a
field. A design preference, such as a different spacing rhythm, is a suggestion. Explain the
user impact and supporting evidence for each finding rather than presenting taste as a failure.

## 4. Resolve and recheck

Mark each criterion **PASS**, **FAIL**, or **UNVERIFIED**, with observed evidence. Missing access,
fixtures, tools, or an unobserved state means UNVERIFIED. Unit tests and source inspection can
support a finding but cannot replace observing a visual criterion in the running app.

In implementation mode, fix in-scope defects, rerun the affected flow and nearby interactions,
and capture fresh evidence of the final state. Run project checks appropriate to any code fixes.
Keep broader redesign suggestions in the report. If progress requires unavailable access or a
scope decision, report the specific blocker instead of repeating the same unsuccessful check.

Finish when every criterion has an evidence-backed status and every finding is either resolved
and rechecked, or explicitly reported with its impact. An incomplete review is not an overall pass.

## 5. Deliver evidence and clean up

Save artifacts in the project's existing review-artifact location, or a new run directory under
`.context/visual-review/` when no convention exists. Keep generated evidence out of source commits
unless requested, and avoid overwriting earlier runs. Use names that identify the screen, state,
and viewport. Capture test data without exposing credentials or private user content.

Provide screenshots of the final affected screens and decisive failure states. Include a short
video when sequence, timing, motion, drag-and-drop, or an intermittent problem is clearer in
motion. Begin recording before the interaction, show its result, and stop recording. Review the
playback or extracted frames/contact sheet before citing it; frames alone cannot verify timing.

Write a concise report with:

- **Verdict and scope:** what was reviewed, environment/data assumptions, viewport coverage, and
  unresolved limitations.
- **Acceptance results:** one entry per criterion with PASS / FAIL / UNVERIFIED, the action taken,
  the observed result, and a link to decisive evidence.
- **Additional findings:** remaining defects ordered by user impact, each with route, steps,
  expected versus observed behavior, and evidence. List design suggestions separately.
- **Changes and evidence:** fixes made and rechecked, linked screenshots with captions explaining
  what they show and your visual judgment, and videos when useful.

Embed images when the host supports it. A bare artifact path is insufficient: include the
observation in the report so a reader can understand the result without opening the file.
Publish or attach evidence externally only when that is part of the user's request.

On success or failure, stop recordings and close only browser sessions and app processes started
for this review. Preserve pre-existing sessions/servers and retained evidence.
