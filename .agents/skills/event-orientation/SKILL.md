---
name: event-orientation
description: Use when deciding what to record as an event, scoping or naming an event type, working out what a command must check before it appends, or when an update, delete, entity, or aggregate is about to appear.
user-invocable: false
---

# Event-Orientation (Ralf Westphal)

Source: Ralf Westphal's article series, e.g. https://ralfwestphal.substack.com/p/the-last-object

Apply these principles when designing event stores, deciding what to record, structuring event
relationships, or planning consistency strategies. Apply them literally: the event log is AQ-only,
and every event carries its own `<eventName>Id` plus a `scopes` property.

Composes with the `vertical-slices` skill: this skill describes what happens *inside* a command
slice; that one describes how slices are arranged and what they may share.

---

## AQ over CRUD

Replace Create/Update/Delete with **Append + Query** only.

- **Append**: `append(<eventType>, <payload>)` — records what happened, labeled with why
- **Query**: `query(<filter>)` — retrieves events to build purpose-specific context models

CRUD forces maintaining a single current state. An AQ event store is limitless append-only memory — every state change is recorded forever as a labeled fact. Multiple context models can be built from the same stream, each for a specific purpose.

> "In reality, there is no U(pdate) or D(elete)… There is only ever new, new, new, new…"

---

## When to Record an Event

Five categories — apply all five before deciding:

| Category | When to record | Examples |
|---|---|---|
| **External Facts** | Real-world events that change application state | Task created, money withdrawn, user enrolled |
| **Environment Impact** | Non-idempotent side effects caused by the system | Email sent, notification triggered, schema updated |
| **Lifecycle Changes** | Internally-determined state transitions | Game ended (by rules), contract expired |
| **Stable Interpretations** | Decisions whose rules might change in the future | Grade assigned, discount granted — record if re-derivation might give different results later |
| **Documented Failures** | Failures worth tracking for auditing or patterns | Failed login, exhausted retries on external service |

**Less is more:** If something is cheap to re-derive and the rules definitely won't change — don't create an event. When uncertain, favor recording over omission (loss of a fact is worse than modest storage waste).

---

## Scoping Events — Event-to-Event References

### The Problem with Invented IDs

Traditional reflex:
```json
{ "eventtype": "GameStarted", "payload": { "gameId": "123", "playername": "Mary" } }
{ "eventtype": "ThrowMade",   "payload": { "gameId": "123", "pinsKnockedDown": 7 } }
```

`gameId` is an invented entity. Nothing was created in the real world — only an event happened. **This is Entity-oriented thinking and must be eliminated.**

### Event IDs and Backlinks

Every event gets its own ID inside its payload. Naming pattern: `<eventName>Id`.

```json
{
  "eventtype": "GameStarted",
  "payload": {
    "gameStartedId": "7b1dba45-6ba8-4def-b25d-bfd94223a850",
    "playername": "Mary"
  }
}
```

Later events reference predecessor events using that same property name:

```json
{
  "eventtype": "ThrowMade",
  "payload": {
    "throwMadeId": "8a2dba45-...",
    "pinsKnockedDown": 7,
    "gameStartedId": "7b1dba45-..."
  }
}
```

> "Every event gets its own id. That's the rule. That way I don't have to look ahead and think about whether in the future maybe some other event would like to link back to it."

### Scopes

A scope is a container for related events. Every event can be:
- A **scope root** (any event can become one retroactively — no upfront planning needed)
- A **member of multiple scopes simultaneously**

Scopes nest: messages → chat → grading → enrollment → student registration + course publication.

### Encoding Scope Membership

Use a dedicated `scopes` property in the payload:

```json
{
  "eventtype": "GradeAssigned",
  "payload": {
    "gradeAssignedId": "...",
    "grade": "A",
    "scopes": {
      "studentEnrolledInCourseId": "...",
      "studentRegisteredId": "...",
      "coursePublishedId": "..."
    }
  }
}
```

**Querying all events in a scope** (e.g., all events for a given course):
- The `CoursePublished` event itself
- All events where `payload.scopes.coursePublishedId = "<that ID>"`

A simple equality match on a payload field — no graph traversal, no special event store support
needed. Any store that can index a field inside the payload will do.

---

## Killing the Entity: Story Recording

Events reference predecessor events, not abstract entities.

**Traditional DDD:** Design Student, Course, Enrollment entities upfront. Map relationships. Struggle when requirements change.

**Story Recording:** Only model for what is known now. Events tell stories:

```
TeacherSignedOn → CoursePublished → Enrolled → Graded → Comment
```

Each arrow = explicit event ID reference. No external entity namespace. The event stream is "a universe in itself."

For enrollment:
- `GetCourseCatalog()` queries `CoursePublished` + `TeacherSignedOn` events
- `Enroll(studentRegisteredId, coursePublishedId)` creates `Enrolled` event referencing those two predecessor events
- No Student or Course entity designed upfront

The event IDs in the payload ARE the identities. There is no entity outside the event store.

> "Only model and build for the moment based on what I know. What I know is the past and immediate requirements. Nothing more."

---

## Command Context Consistency (CCC)

How to ensure consistency without aggregates or entity streams.

**Context** = all events relevant for a command's consistency check. Command-specific, not entity-specific.

**Command execution pipeline:**
```
build query → replay context → project model → validate → generate events → record
```

**Two-phase recording:**
1. Replay context, validate constraints, generate success events
2. Before recording: re-run the same query. If no new context events appeared → append atomically. Otherwise retry or fail.

> "This is generalized optimistic locking for Event Stores."

No IDs, streams, or aggregates needed as framework concepts. Identity is a payload property — orthogonal to Event Sourcing.

**Example — enroll student (max 3 courses per student, max 10 students per course):**
- Context: `studentRegisteredInCourse` + `studentUnregisteredFromCourse` events matching either the student ID or course ID
- Context model: `{ nCourses: 2, nStudents: 10 }`
- Validate, generate `Enrolled` event if both constraints pass
- Re-run same query before appending — if unchanged, commit

---

## Design Checklist for New Events

1. **Does it qualify?** Apply the 5 categories. If none apply → don't create it.
2. **Is it a scope root?** Will other events reference back to it? If yes → add `<eventName>Id` UUID to payload.
3. **Which predecessors?** Add their IDs to a `scopes` property.
4. **What payload?** Everything needed to understand this event without reading the DB. Avoid internal implementation details that will change.
5. **Stable interpretation?** If the business rule interpreting this fact might change later, record it now.
