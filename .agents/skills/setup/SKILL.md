---
name: setup
description: Set up a new project from this template — detect the stack, lay down the event-sourced vertical-slice structure, wire boundary enforcement that actually fails, establish the verification command, and write the agent instructions. User-invoked. Run once, before the first feature.
user-invocable: true
---

# Setup

Take a new project from empty to ready-to-build. Run this once, near the start, before any feature
work.

Nothing here is language-specific. Every step states *what must be true*; you decide how to make it
true in this stack.

Read `event-orientation` and `vertical-slices` before starting. This skill installs the structure
those two describe.

---

## The parts

Work them in order. Each is a separate file in this skill folder; read a part only when you reach
it.

| Order | Part | Installs |
|---|---|---|
| 1 | [architecture.md](./architecture.md) | Module and slice folders, the event log, the first real slice |
| 2 | [boundaries.md](./boundaries.md) | Enforcement that fails a command when a boundary is crossed |
| 3 | [verification.md](./verification.md) | The one command that runs everything, and CI |
| 4 | [agent-instructions.md](./agent-instructions.md) | `AGENTS.md`, `CLAUDE.md`, and the pointers agents follow |

Do not reorder. Boundaries need the shape to exist. Verification needs something to run. The agent
instructions describe what the first three produced.

---

## Step 0 — Detect the stack

Before opening any part, establish and state back to the user:

- **Language and package manager** — from the lockfile or manifest already in the repo.
- **Test runner** — whatever the repo already uses. Do not introduce a second one.
- **Privacy mechanism** — how this language hides a symbol across a boundary. Java/Kotlin packages,
  Go's lowercase identifiers and `internal/`, Rust's `pub(crate)`, .NET `internal`, Python `__all__`
  plus convention, JS/TS `exports` maps or an import linter.
- **Boundary enforcement tool** — the linter or analyser that can fail a build on a forbidden
  import. If the language has real privacy, that *is* the tool.
- **Existing conventions** — if the repo already has a source layout, confirm with the user before
  putting a different one next to it.

If the language has **no** enforcement mechanism at all, say so plainly and propose an import-lint
rule instead. Do not continue with folders alone and call it a boundary.

**Done when:** all five are known and the user has agreed the privacy mechanism.

---

## The invariant

> Modules are enforced boundaries. Slices are folders inside them. The event log is the only thing
> slices share.

A folder that merely *looks* like a boundary is decoration. **The completion criterion for this
skill is that a violation fails a command** — not that the folders exist. `boundaries.md` is where
that is proven, and it is not optional.

---

## Not covered here

- **Issue tracker, triage labels, doc layout** — that is `setup-matt-pocock-skills`. Run it too;
  six of the vendored skills assume it has run. The two skills do not overlap.
- **Documentation structure** — documentation lives outside this repo. Do not scaffold `docs/` here
  beyond the one README that `agent-instructions.md` asks for.
- **CI provider choice, deployment, infrastructure** — out of scope. `verification.md` defines the
  command CI should run; picking the provider is a project decision.

---

## Done when

- The shape exists and one real slice passes its own test with no mocks.
- Each boundary rule has been observed to pass, then fail on a deliberate violation, then pass again.
- One command runs typecheck, tests, and boundaries together.
- `AGENTS.md` exists and points at the source README.

Report each of these with the command output that proves it. Do not report setup as complete on the
strength of the folders existing.
