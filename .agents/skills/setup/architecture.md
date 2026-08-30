# Part 1 — Architecture

Lay down the event-sourced vertical-slice shape. Read `event-orientation` and `vertical-slices`
first; this part installs what they describe.

Assumes Step 0 of [SKILL.md](./SKILL.md) is done.

---

## 1.1 Choose the root and the first module

- Pick the source root the repo already implies. Do not invent a new convention next to an existing
  one.
- A **module** is a folder of slices that share a business concept. Name it after the concept, never
  after a technique — `orders`, not `handlers`.
- Start with **one** module. Modules are cheap to add and expensive to un-merge.

**Done when:** the source root and the first module name are agreed with the user.

---

## 1.2 Create the shape

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

## 1.3 Build the event log

The log is the one thing every slice shares, so keep its contract tiny.

Two operations, and no others:

| Operation | Signature (conceptually) | Notes |
|---|---|---|
| `append` | `(eventType, payload) -> void` | Atomic. Must support the two-phase CCC check. |
| `query` | `(filter) -> events` | Filter by event type and by `scopes` fields. |

There is **no** `update` and **no** `delete`. Do not add one "just for cleanup" — corrections are
new events.

The store must let you match on a field **inside** the payload, because `scopes` membership is a
payload equality check (see `event-orientation`). Any store that can index into the payload works.
This is not a reason to reach for a specialised event-store product on day one.

Provide an **in-memory implementation** as well. Slice tests seed it directly, and its contract is
small enough that in-memory is faithful — unlike an in-memory substitute for a real database.

**Done when:** `append` and `query` exist, no mutating operation exists, and the in-memory
implementation passes the same contract test as the real one.

---

## 1.4 Write one real slice end to end

Not a stub. One genuine command slice, chosen with the user, that:

- queries the log for its context,
- builds a **context model** — transient, private, never persisted,
- validates its constraints against that model,
- appends at least one event that satisfies the `event-orientation` five categories,
- performs the two-phase CCC check before appending,
- has a test written as **given past events / when command / then events**, using no mocks.

This slice is the template every later slice is copied from, so it is worth getting exactly right.

If you need a mock to test it, the handler is mixing composition and logic. Extract the logic into a
pure function (IOSP) rather than reaching for the mock.

**Done when:** the slice passes its own test, using the in-memory log, with no mocks.

---

## Notes

- **Do not scaffold a slice per table.** Slices follow requests, not storage.
- **Resist the shared helper.** Duplicate shape freely; extract only pure functions, only on the
  third occurrence (see `vertical-slices`).
- **Events are published contracts** from the moment they are appended. Add new event types; never
  change what an existing one means.

Next: [boundaries.md](./boundaries.md).
