# Step 1 — Architecture

Install the shape. `vertical-slices` and `event-orientation` explain it; this is the procedure.

---

## 1.1 Root and first module

Pick the source root the repo already implies. Name the first module after a business concept, never
a technique — `orders`, not `handlers`. Start with **one**; modules are cheap to add and expensive
to un-merge.

**Done when:** root and module name are agreed with the user.

---

## 1.2 The shape

```
<root>/
  <module>/
    <public entry>      the module's only public surface
    <slice>/            one command or one query
      events.*          the event types this slice appends
      handler.*         entry point, plus its input and output shapes
      handler.test.*    given events / when command / then events
  event-log/            append and query, nothing else
```

- One request per slice. Deleting the folder deletes the feature and its tests.
- Only the module's entry file is reachable from outside.
- Event types get their own file — they are the only thing crossing the slice boundary.
- File count follows size. Three files or one is a judgement about length.

**Done when:** the module has exactly one public surface and slice internals are unreachable from
outside it.

---

## 1.3 The event log

Two operations. No third.

| Operation | Notes |
|---|---|
| `append(eventType, payload)` | Atomic. Must support the two-phase CCC check. |
| `query(filter)` | Filters by event type and by `scopes` fields. |

The store must match on a field **inside** the payload. Any store that indexes into the payload
works — this is not a reason to adopt a specialised event-store product on day one.

Build an **in-memory implementation** too. Slice tests seed it directly, and the contract is small
enough that in-memory is faithful.

**Done when:** no mutating operation exists, and both implementations pass the same contract test.

---

## 1.4 One real slice

Not a stub. One genuine command slice, chosen with the user, that queries the log for its context,
validates against it, appends at least one event, performs the two-phase CCC check, and is tested as
given events / when command / then events.

This is the artifact every later slice is copied from, and the only proof the whole stack works.

If you need a mock to test it, the handler is mixing composition and logic — extract the logic
(IOSP) rather than reaching for the mock.

**Done when:** it passes, using the in-memory log, with no mocks.

Next: [boundaries.md](./boundaries.md).
