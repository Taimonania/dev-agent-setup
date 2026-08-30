---
name: setup-slice-architecture
description: Lay down the event-sourced vertical-slice structure in a new project — module and slice folders, the event log, boundary enforcement in this repo's own toolchain, and a worked example slice that proves the rules bite. User-invoked. Run once, near the start of a project, before the first feature.
user-invocable: true
---

# Setup Slice Architecture

Establish the default architecture: **event sourcing** (`event-orientation`) arranged as **vertical
slices** (`vertical-slices`). Read both skills before starting; this skill installs the structure
they describe, in whatever language the project uses.

Nothing here is language-specific. Every step says *what must be true*, and you decide how to make
it true in this stack.

---

## The invariant this installs

> Modules are enforced boundaries. Slices are folders inside them. The event log is the only thing
> slices share.

A folder that merely *looks* like a boundary is decoration. The completion criterion for this skill
is that a violation **fails a command** — not that the folders exist.

---

## Step 1 — Detect the stack

Establish, and state back to the user:

- **Language and package manager** — from the lockfile or manifest present in the repo.
- **Test runner** — whatever the repo already uses. Do not introduce a second one.
- **Privacy mechanism** — how this language hides a symbol across a boundary. Examples: Java/Kotlin
  packages, Go's lowercase identifiers and `internal/`, Rust's `pub(crate)`, .NET `internal`,
  Python `__all__` plus convention, JS/TS `exports` maps or an import linter.
- **Boundary enforcement tool** — the linter or analyser that can fail a build on a forbidden
  import. If the language has real privacy, that *is* the tool.

**Done when:** all four are known, and you have told the user which privacy mechanism you will use.

If the language has **no** enforcement mechanism at all, say so plainly and propose an import-lint
rule instead. Do not silently continue with folders alone.

---

## Step 2 — Choose the root and the first module

- Pick the source root the repo already implies. Do not invent a new convention next to an existing
  one; confirm with the user if one already exists.
- A **module** is a folder of slices that share a business concept. Name it after the concept, never
  after a technique (`orders`, not `handlers`).
- Start with **one** module. Modules are cheap to add and expensive to un-merge.

**Done when:** the source root and the first module name are agreed with the user.

---

## Step 3 — Create the shape

```
<root>/
  <module>/
    <public entry>          the module's only public surface
    <slice>/                one command or one query
      contract.*            input shape, output shape
      handler.*             composition only, no logic
      decide.*              pure: (context model, command) -> events | rejection
      events.*              the event types this slice appends
      handler.test.*        given events / when command / then events
  event-log/                append and query, nothing else
```

Rules that must hold, whatever the file extensions are:

- A slice is **one request** — one command or one query, never both.
- A slice folder is **self-contained**: deleting it deletes the feature and its tests.
- A query slice owns its read model and projection. A command slice owns neither.
- Only the module's entry file is importable from outside the module.

**Done when:** the module exposes exactly one public surface, and slice internals are unreachable
from outside it.

---

## Step 4 — Build the event log

The log is the one thing every slice shares, so keep its contract tiny.

Two operations, and no others:

| Operation | Signature (conceptually) | Notes |
|---|---|---|
| `append` | `(eventType, payload) -> void` | Atomic. Must support the two-phase CCC check. |
| `query` | `(filter) -> events` | Filter by event type and by `scopes` fields. |

There is **no** `update` and **no** `delete`. Do not add one "just for cleanup" — corrections are
new events.

The store must let you match on a field **inside** the payload, because `scopes` membership is a
payload equality check (see `event-orientation`). Any store that can index into the payload works;
this is not a reason to reach for a specialised event-store product on day one.

Provide an **in-memory implementation** as well. Slice tests seed it directly, and its contract is
small enough that in-memory is faithful — unlike an in-memory substitute for a real database.

**Done when:** `append` and `query` exist, no mutating operation exists, and an in-memory
implementation passes the same contract test as the real one.

---

## Step 5 — Wire boundary enforcement

Add a command that fails when a boundary is crossed. It must forbid:

1. Importing anything inside a module other than its public entry file.
2. Importing one slice from another slice.
3. Dependency cycles.
4. Any mutating operation on the event log.

Fold it into whatever command already runs typecheck, lint, or tests — **discover** that command,
do not assume one is named `check`. If the repo has no umbrella command, add the boundary command
on its own and tell the user to put it in CI.

**Done when:** the boundary command runs as part of the repo's existing verification command.

---

## Step 6 — Prove the rules bite

**This is the completion criterion for the whole skill.** A rule that cannot fail is worthless.

For each of the four forbidden things in Step 5:

1. Run the boundary command. It must **pass**.
2. Add the violation on purpose — a deep import into a module, a slice-to-slice import, a cycle, a
   delete against the log.
3. Run again. It must **fail**, and the message must name the rule.
4. Revert. Run again. It must **pass**.

If any violation does not fail, the rule is not wired up. Fix it before continuing. Do not report
this skill as complete on the strength of the folders existing.

A common cause of a silent pass: the analyser cannot resolve cross-module paths, so every rule
matches nothing and reports success. Check that the tool actually resolved the imports it was
supposed to reject.

**Done when:** you have observed pass → fail → pass for **each** of the four rules.

---

## Step 7 — Write one real slice end to end

Not a stub. One genuine command slice, chosen with the user, that:

- queries the log for its context,
- builds a **context model** — transient, private, never persisted,
- validates its constraints against that model,
- appends at least one event that satisfies the `event-orientation` five categories,
- performs the two-phase CCC check before appending,
- has a test written as **given past events / when command / then events**, using no mocks.

This slice is the template every later slice is copied from, so it is worth getting exactly right.
If you need a mock to test it, the handler is mixing composition and logic — extract the logic into
a pure function (IOSP) rather than reaching for the mock.

**Done when:** the slice passes its own test, and the test uses the in-memory log with no mocks.

---

## Step 8 — Document and point at it

Write a short README **next to the modules**, covering:

- the module / slice / event-log layout,
- "import only a module's public entry file",
- the two log operations and the absence of any third,
- how to run the boundary command,
- the copy-me slice from Step 7.

Then add **one line** to the repo's agent-instructions file (`AGENTS.md`, or `CLAUDE.md` if that is
what the repo uses) pointing at it. One line is enough:

```
Code is event-sourced vertical slices: see <root>/README.md before adding a module, slice, or event.
```

This pointer is what makes an agent discover the rule instead of tripping over it. The rule itself
stays in the README, not in the agent file.

**Done when:** the README exists and the agent-instructions file links to it.

---

## Notes

- **Do not scaffold a slice per table.** Slices follow requests, not storage.
- **Resist the shared helper.** Duplicate shape freely; extract only pure functions, only on the
  third occurrence (see `vertical-slices`).
- **Events are published contracts** from the moment they are appended. Add new event types; never
  change what an existing one means.
- If the project later needs a second module, no config change should be required. If it is, the
  Step 5 rules were written per-module instead of structurally — fix that now rather than later.
