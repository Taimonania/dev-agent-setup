---
name: setup
disable-model-invocation: true
description: Install the event-sourced vertical-slice structure in a new project — modules and slices, the event log, boundary enforcement that actually fails, and the verification command. Run once, after the stack has been decided and before the first feature.
---

# Setup

Turn an empty repo into one ready for its first feature.

**Run `/setup-matt-pocock-skills` and `/grill-with-docs` first.** The tech decisions — language,
runtime, storage — are made during the grilling and recorded there. This skill installs a structure
in a stack that has already been chosen; it does not choose one. If those decisions do not exist
yet, stop and go do that instead.

**Read `vertical-slices` and `event-orientation` too.** They own the architecture and the reasons
for it. This skill installs what they describe and does not restate it — when you need to know *why*
a step is what it is, go there.

Nothing here names a language. Each step states what must be true; you decide how to make it true.

---

## Step 0 — Establish the stack

Read the decisions recorded by `/grill-with-docs` — the ADRs and glossary — and confirm with the
user:

- **Language, package manager, test runner.** In a greenfield repo these are decisions, not
  detectable facts; there is no lockfile yet. If the repo is not empty, read what is there and do
  not add a second test runner beside an existing one.
- **Privacy mechanism** — how this language hides a symbol across a boundary (Go `internal/`, Rust
  `pub(crate)`, Java packages, .NET `internal`, an import linter where there is none).
- **Existing layout** — if a source convention already exists, agree with the user before putting a
  different one beside it.

If no stack decision has been recorded, **stop**. Run `/grill-with-docs` and come back. Guessing a
language here silently makes the most consequential decision in the project.

If the chosen language has no enforcement mechanism at all, say so and propose an import linter. Do
not continue with folders alone and call it a boundary.

---

## Step 1 — [architecture.md](./architecture.md)

Modules, slices, the event log, and one real slice.

## Step 2 — [boundaries.md](./boundaries.md)

Enforcement, and proof that it fails when it should.

## Step 3 — Verification

One command runs typecheck, then boundary rules, then tests — in that order, failing fast.

Discover the repo's existing command before adding one; several vendored skills look for the
project's checks rather than a fixed name. If one exists, extend it. If not, add one and name it
whatever this ecosystem calls it.

CI must invoke that same command by name, not a reimplementation of it.

## Step 4 — Agent instructions

**Replace the template's `AGENTS.md` entirely.** The inherited one describes the template and says
the project has not been set up yet; both are now false. `CLAUDE.md` stays as the single line
`@AGENTS.md`.

**Write no document describing the structure.** The code is the source of truth: the layout is the
folders, the import rule is the boundary config, the log's operations are its interface, and the
copy-me example is the real slice from Step 1. A prose copy of an enforced rule can disagree with
it, and then nobody can tell which is current.

`AGENTS.md` gets a few lines pointing at the example slice, the boundary config, and the
verification command — artifacts, so a stale pointer breaks loudly. Judgements that no rule catches
stay in `vertical-slices` and `event-orientation`; do not restate them per project.

---

## Not covered here

Issue tracker, triage labels, and doc layout are `setup-matt-pocock-skills` — run it too. CI
provider, deployment, and infrastructure are project decisions.

---

## Done when

Report each with the command output that proves it:

- One real slice passes its own test, using the in-memory log, with no mocks.
- Each boundary rule was observed to pass, fail on a deliberate violation, then pass again.
- One command runs typecheck, boundaries, and tests together.
- `AGENTS.md` is short and every pointer in it resolves.

Folders existing is not evidence. Do not report setup complete without the output.
