# AGENTS.md

## Architecture

Event sourcing, arranged as vertical slices.

- Append and query only. No update, no delete. Corrections are new events.
- One slice per command or query. The event log is the only thing slices share.
- AQ-over-CRUD is absolute: no CRUD slice, no opt-out.

The `event-orientation` and `vertical-slices` skills carry the rules and the reasoning. Consult them
before adding a module, a slice, or an event type.

## Before the first feature

This project has not been set up yet. Run `/setup`, which installs the structure and replaces this
file with one describing the actual project.
