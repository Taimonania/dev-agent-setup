---
name: vertical-slices
description: Structure code by request, not by layer. Apply Jimmy Bogard's vertical slice architecture — minimise coupling between slices, maximise coupling within one; a slice per command or query; cross-cutting concerns as wrappers not layers; pure functions as the only shared code. Use when deciding where code goes, adding a feature, reviewing structure, or resisting the pull toward a shared service layer.
user-invocable: false
---

# Vertical Slices

Sources: Jimmy Bogard, https://www.jimmybogard.com/vertical-slice-architecture/ (coined the term,
2018) · Oskar Dudycz, https://event-driven.io/en/how_to_slice_the_codebase_effectively/ and
https://event-driven.io/en/vertical-slices-and-dependencies/ · Ralf Westphal,
https://ralfwestphal.substack.com/p/slice-me-nice and https://ralfwestphal.substack.com/p/ioda-architecture

Composes with the `event-orientation` skill: that skill describes what happens *inside* a command
slice. This one describes how slices are arranged and what they may share.

---

## The Core Rule

> "Minimize coupling between slices, and maximize coupling in a slice." — Bogard

> "You take a normal 'n-tier' or hexagonal/whatever architecture and remove the gates and barriers
> across those layers, and couple along the axis of change." — Bogard

Code is organised by **request**, not by technical role. There is no service layer, no repository
layer, no shared "domain" package that everything imports.

**Every slice is event-sourced.** Bogard allows each slice to choose its own persistence style,
including CRUD. This project does not: AQ-over-CRUD is absolute (see `event-orientation`). A slice
appends and queries; it never updates or deletes. There is no CRUD slice, and no opt-out.

---

## What a Slice Is

**One request. One command or one query. Never both.**

A slice is not a feature area, a module, or a bounded context. `PlaceOrder` is a slice; `Orders` is a
folder of slices.

| Level | Unit | Boundary enforced? |
|---|---|---|
| **Slice** | one command or one query | No. Discipline only. Duplication is allowed here. |
| **Module** | a folder of related slices | **Yes.** One public entry file. Everything else private. |
| **Context** | deployable / transactional boundary | Yes. Versioned contracts. |

The module is the enforceable boundary — enforce it with the language's privacy mechanism, or with
import lint rules where the language has none. A folder where everything is exported is not a
boundary.

A slice folder contains, together:

```
orders/place-order/
  contract.*        input shape, output shape
  handler.*         composition only — no logic (see IOSP)
  decide.*          pure: (context model, command) -> events | rejection
  events.*          the event types this slice appends
  handler.test.*    given events / when command / then events
```

A query slice additionally owns its read model and projection. A command slice owns none.

---

## The Shape Every Slice Has

> "It's even boring, I'd say: Commands query the event stream for a context, build a context model,
> check constraints, serve the request, and finally append some events… Queries query the event
> stream for a context, build a context model, and return it." — Westphal

| | Command slice | Query slice |
|---|---|---|
| Reads | events it needs for its consistency check | events or a read model |
| Builds | a **context model** — transient, private, never persisted | a **read model** — persisted or cached, rebuildable |
| Decides | validates constraints, produces events | nothing |
| Writes | appends events (two-phase CCC check) | nothing |
| Returns | nothing, or an identifier | data |

Do not conflate **context model** and **read model**. Context models exist for one consistency check
and are thrown away. Read models are queryable derivations of the log.

---

## What Slices May Share

Exactly two things, and nothing else.

| Shared | Allowed? | Why |
|---|---|---|
| **The event log** | Yes — by design | Westphal's "least common denominator: very simple and small differences in state". Each slice projects it into its own model. |
| **Pure domain functions** | Yes, on the third occurrence | No I/O, no state, no side effects. |
| A shared service / manager / helper class | No | It becomes the new god-layer. |
| A shared ORM context, repository, or data-access layer | No | The horizontal layer, reintroduced. |
| A shared "domain model" object graph | No | See `event-orientation` — kill the entity. |
| Direct calls into another slice | No | The coupling this style exists to remove. |

> "Everything outside the slice is external, whether it's the next folder or another system."
> — Dudycz

---

## How Slices Communicate

| Order | Mechanism | When |
|---|---|---|
| 1 | **Through the log.** Slice B queries the events slice A appended and builds its own model. | Default. Nearly always. |
| 2 | **Declared narrow dependency.** The slice declares the function type it needs, in its own vocabulary; a composition root wires the real implementation. | When a synchronous answer from another module is genuinely required. |
| 3 | Direct call into another slice. | Never. |

> "Declare narrow function types where they're used, in your own vocabulary, rather than importing a
> wide interface." — Dudycz

> "Hidden dependencies are still there, only harder to find." — Dudycz

**The event log is not a bus between slices.** Slices *pull* — they query for their own context.
Push-based reactions (a policy or process manager) are their own slice with an explicit trigger, never
ambient magic.

---

## Duplication and When to Extract

Bogard's whole approach rests on one assumption, stated in the original article:

> "There are some downsides to this approach, however, as it does assume that your team understands
> code smells and refactoring. If your team does not understand when a 'service' is doing too much to
> push logic to the domain, this pattern is likely not for you."

So make the judgement explicit rather than instinctive.

| Situation | Do |
|---|---|
| Two slices have similar shape | Nothing. Duplicate. Shape duplication is free. |
| Two slices contain the same business rule | Still nothing — but note it. |
| **Three** slices contain the same business rule | Extract a **pure function**. Nothing else. |
| A rule needs I/O to evaluate | Do not extract. Each slice queries the log itself. |
| A read model has a second consumer | Promote it to module scope, deliberately and by name. |
| A shared module gains a second unrelated caller | Stop. It is becoming a layer. Split it. |

**Duplicate shape freely. Never duplicate policy silently.**

Extract *pure functions*, never stateful services, never I/O.

---

## Inside a Slice: composition and logic never mix

Westphal's Integration Operation Segregation Principle (IOSP). A function either:

- **contains logic and calls nothing of yours** (an operation — pure, trivially testable), or
- **contains no logic and only calls other functions** (integration — composition).

Never both. A function that computes *and* calls your other function is a **functional dependency**:
it breaks single level of abstraction and forces mocks in tests.

Practically: the slice's entry point is pure composition. Every decision is a pure function it calls.
If you need a mock to test a slice, you have an IOSP violation — extract the logic instead.

Invert dependencies only at true system edges (clock, network, store, randomness). Never
dependency-invert your own code.

---

## Cross-Cutting Concerns

**Wrap, don't layer.** Each concern is a function that takes a handler and returns a handler —
middleware, decorator, higher-order function, interceptor. Never a layer above slices.

| Concern | Where | Rule |
|---|---|---|
| Authentication | Edge / transport | Identity established once, outside all slices. |
| Authorisation — coarse (role, scope, tenant) | Wrapper | Needs no slice context. |
| Authorisation — fine ("may this user act on this thing?") | **In the slice** | It is a business rule and needs the context model. |
| Shape validation ("is the form filled in correctly") | Wrapper | Bogard: "does not require any sort of domain-specific knowledge". Reject before the handler. |
| State validation ("can I make this change given current state") | **In the slice** | This is CCC — see `event-orientation`. A wrapper cannot see the context. |
| Logging, tracing, metrics | Wrapper | The only truly uniform concern. |
| Transactions / atomic append | Wrapper opens it; slice decides what to append | Mechanism generic, consistency rule local. |
| Idempotency | Wrapper (dedupe key) + slice (context query) | Often just a context check under event sourcing. |
| Error → transport mapping | Edge | Slices return domain outcomes, not status codes. |

**Test:** a concern belongs in a wrapper only if it is identical for every slice *and* needs nothing
from the slice's context model. The moment it needs the context, it is business logic.

Keep the wrapper stack short. Every global behaviour is coupling reintroduced across all slices.
Prefer per-slice opt-in over global application.

---

## Testing a Slice

Events in, events out. No mocks.

> "**Given** the sequence of past events… **When** the business logic is run for the command and the
> current state built from events… **Then** the following set of events is returned (when succeeded),
> or an exception is thrown (when failed)." — Dudycz

| Level | Scope | Uses |
|---|---|---|
| Decision test | `(context model, command) -> events \| rejection` | nothing |
| Slice test | given past events, when command, then events | in-memory event log seeded with only what this slice needs |
| Projection test | given events, then read model | in-memory |
| Event contract test | serialised event shape is stable and forward-compatible | golden files |
| Edge test | transport → slice → response | real transport, real store, a thin sample only |

Rules:

- **Tests live in the slice folder.** Deleting a feature deletes its tests.
- **No mocks between your own code.** Needing one means an IOSP violation.
- **Avoid fake persistence at the edge.** Bogard: in-memory database substitutes produce false
  positives — APIs and transaction semantics diverge. In-memory *event logs* are fine, because the
  log's contract is trivially small.
- Event contract tests are the only horizontal suite you need — because events are the only thing
  slices genuinely share.

---

## Known Failure Modes

| Failure | Symptom | Guard |
|---|---|---|
| Duplication ossifies | The same rule diverged across slices; a change misses some | Rule of three. Extract pure functions. |
| Inconsistency | Every slice solves the same problem differently | One canonical slice template; new slices copy it. |
| The new god-layer | A "shared" module accumulates unrelated callers | Any shared module with a second unrelated caller gets split. |
| God slice | One slice handles several requests, hundreds of lines | One request per slice. Two requests means two slices. |
| Fake boundaries | Everything exported; folders are decoration | Module-level privacy or import lint rules. |
| Event schema drift | A slice "owns" its event and edits it freely | Events are append-only published contracts. Add new types; never change meaning. |
| Ambient reaction | Slices react to each other's events implicitly; flow untraceable | Reactions are explicit slices with named triggers. |

---

## Checklist for a New Slice

1. **One request?** If it handles two, it is two slices.
2. **Command or query?** Never both. Commands change state and return nothing meaningful; queries
   return data and change nothing.
3. **Which module?** Put it next to the slices it shares a business concept with — not next to the
   ones it shares a technique with.
4. **What context does it need?** For a command: which events must be replayed for the consistency
   check (see `event-orientation` — CCC). For a query: which events or read model.
5. **What does it append?** Apply the `event-orientation` five categories. Co-locate the event
   definition; treat the event type as a published contract.
6. **Any dependency outside itself?** Declare it as a narrow function type in the slice's own
   vocabulary. Wire it at the composition root.
7. **Is the handler pure composition?** All logic in pure functions it calls (IOSP).
8. **Does it duplicate a rule already in two other slices?** If yes, extract a pure function now.
9. **Test written as given-events / when-command / then-events, in the slice folder?**
10. **Would deleting this folder cleanly delete the feature?** If not, the boundary is wrong.
