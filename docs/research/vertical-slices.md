# Vertical Slice Architecture — Primary-Source Research

Research date: 2026-08-30. Purpose: decide what a tech-agnostic `vertical-slices` agent skill should
contain, and how it composes with the existing `event-orientation` skill (Ralf Westphal).

**Citation confidence note.** Quotes marked **[verbatim]** were extracted from the raw page source and
are exact. Quotes marked **[fetched]** came through a page-summarising fetch tool; the wording is very
likely exact but I could not re-verify every character. Anything I could not verify at all is called
out explicitly as *unverified*.

---

## 1. What vertical slice architecture actually claims — in Bogard's own words

Primary source: Jimmy Bogard, **"Vertical Slice Architecture"**, 19 Apr 2018 —
<https://www.jimmybogard.com/vertical-slice-architecture/>

The whole article is ~600 words. The load-bearing passages, **[verbatim]** from the page:

> "Many years back, we started on a new, long term project, and to start off with, we built the
> architecture around an onion architecture. Within a couple of months, the cracks started to show
> around this style and we moved away from that architecture and towards CQRS (before it had that
> name). Along with moving to CQRS, we started building our architectures around vertical slices
> instead of layers (whether flat or concentric, it's still layers)."

> "A traditional layered/onion/clean architecture is monolithic in its approach… The problem is this
> approach/architecture is really only appropriate in a minority of the typical requests in a system.
> Additionally, I tend to see these architectures mock-heavy, with rigid rules around dependency
> management. In practice, I've found these rules rarely useful, and you start to get many
> abstractions around concepts that really shouldn't be abstracted (Controller MUST talk to a Service
> that MUST use a Repository)."

> "Instead, I want to take a tailored approach to my system, where I treat **each request as a
> distinct use case** in how to approach its code."

> "So what is a 'Vertical Slice Architecture'? In this style, my architecture is built around
> **distinct requests, encapsulating and grouping all concerns from front-end to back**. You take a
> normal 'n-tier' or hexagonal/whatever architecture and **remove the gates and barriers across those
> layers, and couple along the axis of change**."

> "When adding or changing a feature in an application, I'm typically touching many different 'layers'
> in an application. I'm changing the user interface, adding fields to models, modifying validation,
> and so on. Instead of coupling across a layer, we couple vertically along a slice. **Minimize
> coupling between slices, and maximize coupling in a slice.**"

> "With this approach, most abstractions melt away, and we don't need any kind of 'shared' layer
> abstractions like repositories, services, controllers. Sometimes these are still required by our
> tools (like controllers or ORM units-of-work) but we keep our cross-slice logic sharing to a
> minimum."

> "The old Domain Logic patterns from the Patterns of Enterprise Architecture book no longer need to be
> an application-wide choice. Instead, we can **start simple (Transaction Script) and simply refactor
> to the patterns that emerges from code smells** we see in the business logic. New features only add
> code, you're not changing shared code and worrying about side effects. Very liberating!"

### What is a slice a slice *of*?

Bogard is unambiguous, and it is narrower than most people assume: **a slice is a slice of one
request** — one use case, one command or one query. Not "a feature area", not "a module", not "a
bounded context". `AddProduct` is a slice; `ShoppingCart` is a *folder of* slices.

Three sizes are routinely conflated, and the skill should keep them distinct:

| Level | Unit | Boundary strength |
|---|---|---|
| Slice | one request (one command **or** one query) | no enforcement; free to duplicate |
| Module / feature area | a folder of related slices | explicit public surface; the real boundary |
| Bounded context / service | deployable or transactional boundary | contracts, versioning |

Bogard writes about level 1. Oskar Dudycz explicitly places the *enforced* boundary at level 2
(see §3).

### The stated genealogy (Bogard's own evolution)

The idea predates the name. Bogard's 2015 talk "SOLID Architecture in Slices not Layers"
(<https://vimeo.com/131633177>) already carried the whole argument; the community-maintained history
page quotes his slides:

> "SRP – One class per feature/concept · OCP – Extend through cross-cutting concerns · LSP – Just
> don't do inheritance · ISP – Separating queries from commands · DIP – Save for true external
> dependencies."
> — <https://github.com/Hona/VerticalSliceArchitecture.Documentation/blob/main/learn/cookbook/history.md>

That OCP line matters: **cross-cutting concerns were, from the very beginning, the designated
extension mechanism** — not a layer, but a pipeline. See §5.

Timeline of Bogard's own material:

| Date | Item | URL |
|---|---|---|
| 2015 | "SOLID Architecture in Slices not Layers" (NDC) — the idea, pre-name | <https://vimeo.com/131633177> |
| Apr 2018 | "Vertical Slice Architecture" — term coined | <https://www.jimmybogard.com/vertical-slice-architecture/> |
| 2018 | NDC Sydney talk | <https://www.youtube.com/watch?v=SUiWfhAhgQw> |
| 2019 | "Composite UIs for Microservices: Vertical Slice APIs" — slices extended past the service boundary | <https://www.jimmybogard.com/composite-uis-for-microservices-vertical-slice-apis/> |
| Nov 2020 | Reference repo updated to .NET 5 | <https://www.jimmybogard.com/vertical-slice-example-updated-to-net-5/> |
| Feb 2024 | Two-day training; framing shifts to **refactoring existing systems** into VSA | <https://www.jimmybogard.com/upcoming-training-on-vertical-slice-architecture/> |
| Jul 2026 | Webinar: VSA + DDD + AI-assisted development | <https://www.jimmybogard.com/vertical-slice-architecture-webinar/> |

Reference implementation he actually points at: **`jbogard/ContosoUniversityDotNetCore-Pages`** —
"Contoso University, the way I would write it." Its own README lists "Vertical slice architecture"
alongside CQRS/MediatR/AutoMapper/FluentValidation
(<https://github.com/jbogard/ContosoUniversityDotNetCore-Pages>).

### Has he walked anything back?

**I found no retraction.** I searched jimmybogard.com's architecture tag and did targeted searches;
there is no "I was wrong about vertical slices" post. What I can substantiate is a *shift of emphasis*,
not a reversal:

- **2018:** framed as the greenfield default, replacing onion architecture wholesale.
- **2024:** the training is explicitly about *"refactoring a system using Vertical Slice
  Architecture"* because *"most of my systems I deal with are not greenfield"* **[verbatim]**. VSA is
  presented as a refactoring target reached from an existing system, not a big-bang starting posture.
- **2026 webinar blurb:** he pairs VSA back up with DDD — *"Vertical Slice Architecture, DDD, and how
  they fit in with AI-assisted development"* — and argues VSA *"can shorten those cycles by reducing
  side-effects and coupling in your systems"* **[fetched]**. The 2018 post's dismissiveness toward the
  domain layer has softened into "start with Transaction Script, refactor toward DDD when smells
  appear", which is arguably what the 2018 post already said.

The one thing worth flagging as a *de facto* correction by the community rather than by Bogard: VSA
has been so thoroughly conflated with his MediatR library that Oskar Dudycz devoted an essay to the
"semantic diffusion" (see §7).

---

## 2. The honest tradeoffs — what it costs

### Bogard's own caveat (the only one in the founding article), **[verbatim]**

> "There are some downsides to this approach, however, as it does assume that your team understands
> code smells and refactoring. **If your team does not understand when a 'service' is doing too much to
> push logic to the domain, this pattern is likely not for you.**"

> "If your team does understand refactoring, and can recognize when to push complex logic into the
> domain, into what DDD services should have been, and is familiar other Fowler/Kerievsky refactoring
> techniques, you'll find this style of architecture able to scale far past the traditional
> layered/concentric architectures."

This is the single most important honest statement in the whole literature: **VSA moves the cost from
up-front structure to continuous refactoring judgement.** A layered architecture tells a weak team
where to put things and is wrong slowly. VSA tells them nothing and is wrong fast. For an
*agent-driven* codebase this cuts both ways — agents are excellent at "add a new folder next to the
existing ones" and poor at "notice that six slices now share a smell and extract the right
abstraction". That extraction step should be an explicit, scheduled ritual in the skill, not an
assumed instinct.

### Simon Brown's structural criticism

Primary source: Simon Brown, **"Modular monolith and 'package by component'"** —
<https://simonbrown.je/modular-monolith/> (and the "Missing Chapter" of *Clean Architecture*).

Brown's two charges against package-by-feature, **[fetched]**:

> "Both, in my opinion, are suboptimal, with teams just switching from one extreme to the other."

and, on enforcement, that if all types are `public` then package-by-layer, package-by-feature and
package-by-component are functionally *"exactly the same"* — the packaging is decoration, not
encapsulation.

His fix is "package by component": a coarser unit than a slice, with a real, narrow public interface
and everything else language-private. **This is the correction Timo's template needs most**, because
in most modern languages (TypeScript, Python, Go outside of internal/) there is no compiler-enforced
package privacy, so the boundary is enforced only by lint rules, import graphs, or discipline. A slice
folder with everything exported is not a boundary.

### Reported failure modes (community consensus; not primary, flagged as such)

I could not find a single first-party post-mortem from an originator listing failure modes. The
following are recurring practitioner reports across secondary sources — treat as hypotheses to guard
against, not cited facts:

| Failure mode | Symptom | Guard |
|---|---|---|
| Duplication ossifies | The same business rule diverges across 5 slices; a rule change misses 2 of them | Duplicate *shape*, never duplicate *policy*. Rules go in pure functions. |
| Inconsistency / least-surprise violation | Every slice solves the same problem differently; onboarding cost rises | One canonical slice template. New slices are copies of it. |
| Anaemic slices | Slice = thin passthrough; logic drifts back into a shared "service" that becomes the new god-layer | Watch for any shared module gaining a second unrelated caller. |
| God slices | A slice grows to 800 lines and 6 responsibilities | A slice handles exactly one request. If it handles two, it is two slices. |
| Hidden coupling via shared storage | Slices "independent" in code, welded together by one schema | With event sourcing this risk shifts to the event *schema* — see §3. |
| Refactoring debt | Duplicated logic makes later extraction expensive | Scheduled "rule of three" sweep. |

**The rule of three** is the practical answer to "when do I extract": duplicate freely at two call
sites; at the third, extract — but extract a *pure function*, not a layer, and let each slice keep
calling it in its own vocabulary.

### What vertical slices actually give up

| Property | Layered / n-tier | Clean Architecture | Hexagonal (Ports & Adapters) | Vertical slices |
|---|---|---|---|---|
| Primary axis of organisation | technical role | distance from the domain | inside vs. outside | the request |
| Enforced invariant | "call only downward" | the Dependency Rule ("source code dependencies can only point inwards") | domain never imports an adapter | **none** — discipline only |
| Where the domain model lives | a layer | the innermost circle (Entities) | the centre | wherever the slice needs it; often nowhere at first |
| Cost of adding a feature | touch N layers | touch N circles + define ports | touch domain + adapters | add one folder |
| Cost of changing a shared rule | change one place | change one place | change one place | **change every slice that duplicated it** |
| Substituting infrastructure | leaky | first-class | first-class ("any device that adheres to the protocols of a port can be plugged into it") | per-slice; no global swap story |
| Testability without infra | mock-heavy | strong by construction | strong by construction ("developed and tested in isolation from its eventual run-time devices and databases") | strong *if* the decision logic is pure; otherwise integration tests |
| Failure mode | rigidity, ceremony, "seven layers for a CRUD op" | over-abstraction, indirection | port explosion / port starvation | duplication, drift, inconsistency |

Sources for the alternatives, in their authors' own words:

- **Clean Architecture** — Robert C. Martin, 13 Aug 2012,
  <https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html>. The Dependency
  Rule: *"Source code dependencies can only point inwards. Nothing in an inner circle can know
  anything at all about something in an outer circle."* **[fetched]** He also explicitly disclaims
  the layer count: *"There's no rule that says you must always have just these four."* **[fetched]**
  — so "Clean Architecture mandates four projects" is folklore, not Martin.
- **Screaming Architecture** — Robert C. Martin, 30 Sep 2011,
  <https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html>. *"When you look at
  the top level directory structure… do they scream: Health Care System, or Accounting System… Or do
  they scream: Rails, or Spring/Hibernate, or ASP?"* **[fetched]** — note this is **the
  package-by-feature argument, made by the author of Clean Architecture, seven years before the term
  "vertical slice" existed.** VSA and Clean Architecture agree completely on the top-level directory
  question; they disagree only about what is *inside*.
- **Hexagonal / Ports and Adapters** — Alistair Cockburn,
  <https://alistair.cockburn.us/hexagonal-architecture/>. Intent: *"Allow an application to equally be
  driven by users, programs, automated test or batch scripts, and to be developed and tested in
  isolation from its eventual run-time devices and databases."* **[fetched]** Cockburn is notably
  relaxed about rigour: *"It doesn't appear that there is any particular damage in choosing the wrong
  number of ports"*, and warns against both hundreds of ports (one per use case) and only two
  **[fetched]**. Vertical slices are, in Cockburn's terms, the "hundreds of ports" extreme — which he
  cautions against. Worth knowing.
- **Oskar Dudycz on onion/clean**, <https://event-driven.io/en/onion_clean_code/>: describes a project
  needing *"seven layers to perform a simple CRUD operation"*, and the risk-aversion that shared
  horizontal mechanisms breed — *"a change in one layer can potentially affect most functionalities"*
  **[fetched]**.

**Be fair to the alternatives.** Layers, Clean and Hexagonal all buy one thing VSA does not: a
*mechanically checkable* invariant. You can fail a build on a dependency-rule violation. You cannot
fail a build on "this slice duplicated a business rule". If Timo's template wants any enforcement at
all, it has to come from module boundaries (Brown) or lint/import rules — not from the slice concept.

---

## 3. The event-sourcing intersection — the key question

### Does a slice own its events?

**No — a slice owns its *decisions*; the log owns the events.** This is the consensus across all three
practitioners, and it is the single most important correction to the naive reading.

Oskar Dudycz, "How to slice the codebase effectively?" —
<https://event-driven.io/en/how_to_slice_the_codebase_effectively/> — places the event *definition*
next to the command that produces it (`Carts/AddingProduct/` contains both `AddProduct` and
`ProductAdded`) **[fetched]**. So authorship is local. But the event, once appended, is a global fact,
readable by any slice.

The distinction the skill must make sharply:

| Thing | Owned by | Changeable by one slice? |
|---|---|---|
| The command / request shape | the slice | yes |
| The decision logic (validate, decide) | the slice | yes |
| The context model / projection it builds to decide | the slice | yes |
| The **event type and its payload schema** | the slice that appends it, but it is a **published contract** | no — it is append-only history; you can only add new event types |
| The event log itself | the system | never |
| A read model serving one query | the query slice | yes — rebuildable, disposable |

This is where VSA folklore ("slices share nothing") is simply wrong under event sourcing. Slices share
exactly one thing, deliberately: **the event log**. That is the entire point.

### Ralf Westphal already answered this — and it lines up with the existing skill

This is the most valuable find of the research: **Westphal has published directly on slices**, so the
two skills can be built on one author's coherent position rather than stitched together.

- **"Slice me nice"** (11 Sep 2025) — *"Mapping Agile increments to event sourced slices"* —
  <https://ralfwestphal.substack.com/p/slice-me-nice>
- **"Incremental Event Sourcing — Under the hood"** (29 Jul 2025) — *"How can small Agile increments
  be mapped onto code?"* — <https://ralfwestphal.substack.com/p/incremental-event-sourcing-under>
- **"Incremental Event Sourcing"** (26 Jul 2025) — <https://ralfwestphal.substack.com/p/incremental-event-sourcing>
- **"IODA Architecture"** — <https://ralfwestphal.substack.com/p/ioda-architecture>

Westphal's positions, **[fetched]**:

> "Slices are the work horses. That's where interesting things are happening."

> "Slices service the user interface. Slices append to and query the ever growing event stream."

The event stream is *"the single source of truth regarding the application state now and at every
moment in the past."*

On what a slice **is**: *"the manifestations of Agile requirement analysis increments in code"* — i.e.
**one increment of requirement → one slice**. Each slice is a command **or** a query, per CQS:
*"Commands change state, but don't return a result, and queries return a result, but don't change
state."*

On **sharing state**, this is the crux and it maps exactly onto the existing `event-orientation` skill:

> "Context is king… It cannot possibly affect any other slice, because no shared code was touched."

Slices share only *"the least common denominator: very simple and small differences in state. A fine
granulate from which they can extract all the information they need."* — i.e. **individual events, not
aggregates, not a shared domain model.** The "fine granulate" phrasing is precisely why
`event-orientation`'s AQ-over-CRUD and event-to-event scoping make slices work: because the shared
substrate is maximally fine-grained, two slices can project it into wildly different context models
without ever colliding.

On the **shape every slice has** — this is effectively the slice template, **[fetched]**:

> "It's even boring, I'd say: Commands query the event stream for a context, build a context model,
> check constraints, serve the request, and finally append some events… Queries query the event stream
> for a context, build a context model, and return it."

Compare with `event-orientation`'s CCC pipeline —
`build query → replay context → project model → validate → generate events → record`. **They are the
same pipeline.** The existing skill describes the inside of a command slice without naming it a slice.
The two skills fit together with zero contradiction.

On **inter-slice code sharing**: slices *"don't directly call each other"*, but *"may share pure
domain functions separated into dedicated modules"* — *"All domain functions are pure functions."*
**[fetched]** This is a much crisper "when to extract" rule than Bogard's "refactor on smells":
**extract only pure functions; never extract stateful services, never extract I/O.**

On **testing**: slices are tested with an in-memory event store seeded with only the events that slice
needs **[fetched]**.

**IODA / IOSP** (<https://ralfwestphal.substack.com/p/ioda-architecture>) is Westphal's answer to "how
do I structure the *inside* of a slice", and it is orthogonal to and compatible with VSA:

- **I**ntegration modules compose workflows from operations; **O**peration modules do the work;
  **D**ata modules carry data; **A**PIs cause side effects **[fetched]**.
- **IOSP** — the Integration Operation Segregation Principle: a function either *"only contains
  logic"* (operation) or *"does not contain any logic, but only calls to other functions"*
  (integration). Never both **[fetched]**.
- The problem it removes is the *functional dependency*: *"a function contains logic **and also** calls
  another function (from the same application's codebase) for some service"* — which breaks single
  level of abstraction and testability **[fetched]**.

For Timo's template this is a genuinely valuable, tech-agnostic, one-paragraph rule for slice
internals: **the slice's entry point is pure composition; every decision is a pure function it calls.**
That makes the decision logic trivially unit-testable and the slice itself thin enough to be an
integration test.

I did **not** find Westphal explicitly using the phrase "vertical slice architecture" as a citation of
Bogard, though the search index attributes to him the framing *"According to the Vertical Slice
Architecture (VSA) an application is made up of a multitude of such slices"* and the position that
*"Event Sourcing and VSA are great, but without the IODA mindset (or at least the IOSP principle)
you're still prone to write code harder to maintain than necessary"* — I could not verify this second
quote's exact source article, so treat it as **unverified attribution**, though it is consistent with
everything else he writes.

### How do slices communicate?

Three mechanisms, in order of preference. This is the answer to the core question.

| Mechanism | When | Notes |
|---|---|---|
| **1. Through the log** (slice B queries events slice A appended) | default; nearly always | No call, no dependency, no coupling in code. B replays the events it needs and builds *its own* context model. This is Westphal's "least common denominator". |
| **2. Explicit declared dependency (narrow function type)** | when a slice genuinely needs a synchronous answer another module owns | Dudycz: *"Declare narrow function types where they're used, in your own vocabulary, rather than importing a wide interface"* **[fetched]**. Wired at a composition root. |
| **3. Direct call into another slice** | never | Creates the coupling the whole style exists to avoid. |

Note the important negative result: **the event store is NOT a bus between slices, and slices are not
event handlers reacting to each other.** In Westphal's model, a command slice *pulls* — it queries the
event stream for its own context and builds its own model. Push-based inter-slice reaction is a
*separate* thing (a process manager / policy), and it should itself be modelled as a slice with an
explicit trigger, not as ambient magic. Blurring these two is how event-sourced systems become
untraceable.

Dudycz on ownership, **"Vertical slices, their ownership and external dependencies"** —
<https://event-driven.io/en/vertical-slices-and-dependencies/> **[fetched]**:

> "Everything outside the slice is external, whether it's the next folder or another system."

> "Hidden dependencies are still there, only harder to find. What I'm optimising for is cohesion, and
> explicit dependencies serve that."

And crucially, against the purist reading: **slices do not need to be autonomous.** Slices group into
modules; modules may share a bounded context. Autonomy is not the goal — *cohesion* and *explicit
dependency* are.

### Where do read models and projections live?

Dudycz's structure puts a query's read model **inside the query slice**:
`Carts/GettingCartById/` contains `GetCartById` (query + handler) and `CartDetails` (read model +
projection) **[fetched]**, per
<https://event-driven.io/en/how_to_slice_the_codebase_effectively/>. He states Event Sourcing
*amplifies* the benefit of slicing because *"we do not need a unified data model"* — no shared
DbContext-style construct.

The rule that falls out:

- A read model with **one consumer** lives inside that consumer's query slice. It is disposable and
  rebuildable from the log; it is not shared state, it is a cache with a derivation.
- A read model with **many consumers** is promoted to the module level and gets an explicit name and
  owner. Promotion is a deliberate act, not a drift.
- **Never** promote a read model to a "shared data layer". That reintroduces the horizontal layer VSA
  exists to delete, with worse consistency properties.
- The **context model** a command slice builds to make its decision (CCC in `event-orientation`) is
  *not* a read model. It is transient, private, and never persisted. Keep these two words distinct in
  the skill — conflating them is the most common error.

### Greg Young on boundaries

Primary sources: **"CQRS is not an Architecture"**, 9 Sep 2012 —
<https://gregfyoung.wordpress.com/2012/09/09/cqrs-is-not-an-architecture/>; and the **CQRS Documents**
PDF — <https://cqrs.wordpress.com/wp-content/uploads/2010/11/cqrs_documents.pdf>.

Young's argument, **[fetched]**:

> "CQRS is not an architecture. CQRS can be called an architectural pattern."

> "CQRS and Event Sourcing describe something inside a single system or component" — as opposed to
> architectural styles like SOA or EDA which "describe a system of systems."

> "The largest failure I see from people using event sourcing is that they try to use it everywhere."

And the resulting posture: your system may legitimately be *"SOA+EDA with ActiveRecord+CRUD in some
places and Event Sourcing in others."*

**This is the most important warning in the whole research for a template repository.** A template that
makes event sourcing + vertical slices the *global default* is doing exactly what Young names as the
number-one failure. The skill must contain an explicit "when not to" section and an escape hatch: some
slices are plain CRUD, some modules are not event-sourced, and that is correct, not a compromise. VSA
actually makes this *easier* than any layered style, because per-slice heterogeneity is the whole
point — Bogard: *"each of our vertical slices can decide for itself how to best fulfill the request"*
**[verbatim]**.

Dudycz reinforces the direction of travel: *"when you properly apply CQRS, you naturally drift towards
Vertical Slices"* **[fetched]** —
<https://www.architecture-weekly.com/p/my-thoughts-on-vertical-slices-cqrs>. CQRS gives you the
command/query split; VSA gives you the organisational principle. Event sourcing is orthogonal to both
— Young's and Dudycz's shared point.

---

## 4. Cross-cutting concerns

The mechanism was in Bogard's design from 2015: **OCP — "Extend through cross-cutting concerns"**
(<https://vimeo.com/131633177>, via the history page). Not a layer above slices — a **pipeline around
each slice invocation**. In .NET this is MediatR's `IPipelineBehavior`; in every other ecosystem it is
middleware, decorators, higher-order functions, interceptors, or a hand-rolled `compose()`.

The tech-agnostic form: **wrap, don't layer.** Each concern is a function that takes a handler and
returns a handler.

| Concern | Where | Why |
|---|---|---|
| **Authentication** | Outside the slice entirely — edge/transport | Identity is established once; it is not a per-slice concern. |
| **Authorisation** | Split. Coarse (role/scope) in the pipeline; fine (*"can this user act on this thing?"*) **inside the slice**, because it needs the slice's own context model | Fine-grained authz is a business rule and depends on replayed events. Do not hoist it into a shared policy layer. |
| **Request/shape validation** | Pipeline, before the handler | Bogard: *"have I filled out the form correctly"* — *"does not require any sort of domain-specific knowledge"*; returns 400 immediately **[fetched]**, <https://www.jimmybogard.com/domain-command-patterns-validation/> |
| **Domain/state validation** | **Inside the slice**, after building the context model | Bogard: *"can I affect the change to my system based on the current state of my system"* **[fetched]**. This *is* CCC from `event-orientation`. Never move it to a pipeline — the pipeline cannot see the slice's context. |
| **Logging / tracing / metrics** | Pipeline, generic over all slices | Truly uniform; the one concern with no per-slice variation. |
| **Transactions / atomic append** | Pipeline opens the unit of work; the slice decides what to append; commit uses the CCC two-phase check | Keep the *mechanism* generic, the *consistency rule* in the slice. |
| **Idempotency** | Pipeline (dedupe key) + slice (event-level check) | Under event sourcing, duplicate suppression is often just a context query. |
| **Error → transport mapping** | Edge | Slices return domain outcomes, not HTTP status codes. |

The rule the skill needs: **a concern belongs in the pipeline only if it is identical for every slice
and needs nothing from the slice's context model.** The moment it needs the context, it is business
logic and belongs in the slice.

The composition trap: pipelines are a horizontal layer wearing a disguise. Every behaviour added to
the global pipeline is coupling reintroduced across all slices. Keep the pipeline short, keep it
generic, and prefer per-slice opt-in over global application.

Bogard's DIP line — *"DIP – Save for true external dependencies"* — is the other half: do not
dependency-invert your own code. Invert only at genuine system edges (clock, network, store,
randomness). Everything internal is a direct call to a pure function.

---

## 5. Testing implications

### What changes

Layered testing tests *layers*: a unit test per service, per repository, per controller, with mocks
between. Slice testing tests *requests*: one test suite per slice, exercising it end to end, with real
infrastructure where it is cheap.

Bogard's supporting position — **"Avoid In-Memory Databases for Tests"**,
<https://www.jimmybogard.com/avoid-in-memory-databases-for-tests/> **[fetched]**: fake persistence
produces *"false positives"*, the APIs diverge, transaction semantics differ, and — the killer
argument — *"if we were writing the tests twice, what was the value of having two tests?"* His teams
*"rely on integration/subcutaneous tests as your final 'green' test for feature complete"*
(Respawn docs, <https://www.jimmybogard.com/respawn-1-0-0-released/>).

Note the mock-heaviness charge from the 2018 article is not incidental — it is the layered
architecture's *testing* strategy that Bogard is rejecting, as much as its structure.

### The event-sourced slice test — the best shape available

Because of event sourcing, the slice test does not need mocks *or* a real database. Dudycz,
<https://event-driven.io/en/testing_event_sourcing/> **[fetched]**:

> "**Given** the sequence of past events… **When** the business logic is run for the command and the
> current state built from events… **Then** the following set of events is returned (when succeeded),
> or an exception is thrown (when failed)."

> "It's a pure function that's not causing any side effects. Thus, straightforward code to test."

Westphal concurs: slices are tested with an in-memory event store seeded with only the events that
slice needs **[fetched]**.

**Events in → events out.** No mocks, no fixtures, no database, no builders. This is the strongest
single argument for combining VSA with event sourcing, and the skill should lead with it.

### The test pyramid, restated per slice

| Level | Scope | Uses | Count |
|---|---|---|---|
| Decision tests | the pure decide function: `(context model, command) → events \| rejection` | nothing | many, fast |
| Slice tests | given past events, when command, then events | in-memory event log | one suite per slice |
| Projection tests | given events, then read model | in-memory | one per read model |
| Contract tests | serialised event shape is stable and forward-compatible | golden files | one per event type |
| Edge tests | HTTP/CLI/queue → slice → response | real transport, real store | a thin sample |

Two rules that fall out and matter for a template:

1. **No mocks between your own code.** If you need a mock to test a slice, the slice has a functional
   dependency (Westphal's IOSP violation). Extract the logic into a pure function instead.
2. **A slice's test file lives in the slice folder.** The test suite has the same shape as the source
   tree. Deleting a feature deletes its tests. This is the vertical-slice property that matters most
   for an agent-driven repo: an agent given one folder has the code, the events, the read model, and
   the tests in one place.
3. Contract tests on event shapes are the *only* horizontal test suite you need, and you need it
   because events are the one thing slices genuinely share.

---

## 6. Tech-agnostic distillation — stripping the .NET

Bogard's material is heavily .NET-flavoured and MediatR is his own library, so the filter matters.

Notable verifiable fact: **the 2018 founding article does not mention MediatR at all.** (Confirmed by
grepping the raw page: the only three occurrences are in the site's "recent posts" sidebar, which
lists unrelated release-note posts.) The MediatR/VSA identification is community accretion, not the
original claim. Dudycz names this directly: VSA does not require *"specific folder structures or tools
like MediatR"*, and *"semantic diffusion happens because successful patterns attract attention"*
**[fetched]**, <https://www.architecture-weekly.com/p/my-thoughts-on-vertical-slices-cqrs>.

I did **not** find Bogard himself saying "you don't need MediatR for VSA" — treat that as *unverified*.
What is verified is that his founding statement of the pattern did not invoke it.

| Bogard/.NET-specific artefact | Actually a tool detail | Language-neutral principle |
|---|---|---|
| MediatR `IRequest`/`IRequestHandler` | yes | A slice is a named request and one function that handles it. A dispatcher is optional; a direct import is fine. |
| MediatR `IPipelineBehavior` | yes | Cross-cutting concerns are handler decorators / middleware, applied per invocation. |
| AutoMapper | yes | Nothing. Map explicitly; a slice's DTO is its own. |
| FluentValidation | yes | Separate shape validation (pipeline) from state validation (in slice). |
| Razor Pages / Minimal APIs / controllers | yes | The transport is an adapter that calls one slice. |
| EF Core `DbContext` / unit of work | yes | The append operation is transactional; the model is not shared. |
| `Respawn` | yes | Tests need a known starting state; with an event log that means an empty or seeded log. |
| C# `internal` keyword | partially | Slices need a *language-appropriate* privacy mechanism. Where none exists, enforce with import lint rules. |
| Assembly / project boundaries | yes | Module boundaries are folders + an explicit public index/facade. |

**The eight language-neutral principles:**

1. Organise by request, not by technical role. Top-level folders name the business, not the framework
   (Martin's Screaming Architecture — and note this is the one point where Clean Architecture and VSA
   agree completely).
2. Minimise coupling between slices; maximise coupling inside a slice.
3. A slice contains everything for one request: input contract, decision logic, its events or writes,
   its read model, its tests.
4. Slices do not call slices. They share substrate (the event log), not code paths.
5. Extract only pure functions, and only on the third occurrence.
6. Cross-cutting concerns wrap slices; they never sit above them as a layer.
7. Each slice chooses its own internal complexity; start with a transaction script and refactor when
   the smell arrives.
8. The module — a folder of slices with an explicit public surface — is the enforceable boundary. The
   slice is not.

---

## 7. Points of genuine tension with `event-orientation`

Almost everything composes. Four places need explicit handling, because they are real, not cosmetic:

| # | Tension | Resolution to state in the skill |
|---|---|---|
| 1 | **"Slices share nothing" vs. "events are a global append-only log."** The naive VSA reading demands isolation; event sourcing demands a single shared log. | Slices share the log deliberately and share *nothing else*. Westphal's "least common denominator" — shared *facts*, never shared *code paths* or *models*. Not a contradiction, but it must be said out loud or agents will duplicate the event store per module. |
| 2 | **"Each slice decides how to fulfil the request" (Bogard) vs. "AQ over CRUD, always" (Westphal).** Bogard's per-slice freedom explicitly permits CRUD/ActiveRecord in a slice. Westphal's position is that there is no U or D. | Genuine philosophical conflict. Young sides with Bogard: *"the largest failure… is that they try to use it everywhere."* Recommend: **event sourcing is the template default; a slice may opt out, and opting out is a documented decision, not a silent one.** |
| 3 | **Slice-local event definitions vs. events as global contracts.** Co-locating `ProductAdded` inside `AddingProduct/` invites treating it as private and freely editable. It is not — it is immutable history. | Co-locate the *definition*, but treat every event type as a published, append-only contract. Changing an event's meaning is forbidden; only new event types are allowed. Contract-test event shapes. |
| 4 | **"Context model" vs. "read model."** Both are projections from the log; they have opposite lifecycles. | CCC context model: transient, private to one command, never persisted, exists for one consistency check. Read model: persisted or cached, serves queries, rebuildable, may be promoted to module scope. Keep the words distinct. |

Non-tensions worth noting explicitly, because they are load-bearing:

- Westphal's command pipeline (*query stream → build context → check constraints → append*) **is** the
  `event-orientation` CCC pipeline, and it **is** the inside of a Bogard command slice. One shape,
  three authors.
- CQS (command slice vs. query slice) is shared by all three: Bogard's ISP line, Westphal's explicit
  CQS statement, Young's foundational split.
- `event-orientation`'s "only model for what is known now" and VSA's "start with a transaction script,
  refactor on smells" and Dudycz's *"our initial design will be wrong… target Removability over
  maintainability"* are the same anti-BDUF stance from three directions.

---

## 8. Draft `SKILL.md`

Format and density modelled on the existing `event-orientation` skill.

````markdown
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

## When Not To Slice This Way

> "The largest failure I see from people using event sourcing is that they try to use it everywhere."
> — Greg Young

> "CQRS is not an architecture. CQRS can be called an architectural pattern." — Greg Young

A system may legitimately be event-sourced in some places and plain CRUD in others. Per-slice
heterogeneity is a feature of this style, not a compromise:

> "Each of our vertical slices can decide for itself how to best fulfill the request." — Bogard

| Signal | Response |
|---|---|
| A slice is pure reference-data CRUD with no business rules | Plain storage. Skip event sourcing for it. Record the decision. |
| A whole module is generic infrastructure (auth provider, file store) | Not a domain module. Do not slice it. |
| The team cannot recognise when to extract | Bogard's own warning: "this pattern is likely not for you." Compensate with the rule-of-three ritual below. |
| The system is a genuine CRUD admin panel | Layers are fine. Do not force this. |

Opting out is a **documented** decision, not a silent one.

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
````

---

## 9. Source index

**Vertical slices — originator**
- Jimmy Bogard, "Vertical Slice Architecture", 2018 — <https://www.jimmybogard.com/vertical-slice-architecture/>
- Jimmy Bogard, "SOLID Architecture in Slices not Layers", 2015 — <https://vimeo.com/131633177>
- NDC Sydney 2018 talk — <https://www.youtube.com/watch?v=SUiWfhAhgQw>
- Reference repo — <https://github.com/jbogard/ContosoUniversityDotNetCore-Pages>
- Architecture tag index — <https://www.jimmybogard.com/tag/architecture/>
- Training (2024) — <https://www.jimmybogard.com/upcoming-training-on-vertical-slice-architecture/>
- Webinar (2026) — <https://www.jimmybogard.com/vertical-slice-architecture-webinar/>
- Validation taxonomy — <https://www.jimmybogard.com/domain-command-patterns-validation/>
- Testing posture — <https://www.jimmybogard.com/avoid-in-memory-databases-for-tests/>, <https://www.jimmybogard.com/respawn-1-0-0-released/>
- Community history page (secondary, quotes his slides) — <https://github.com/Hona/VerticalSliceArchitecture.Documentation/blob/main/learn/cookbook/history.md>

**Alternatives, in their authors' own words**
- Robert C. Martin, "The Clean Architecture" — <https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html>
- Robert C. Martin, "Screaming Architecture" — <https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html>
- Alistair Cockburn, "Hexagonal Architecture" — <https://alistair.cockburn.us/hexagonal-architecture/>
- Simon Brown, "Modular monolith and package by component" — <https://simonbrown.je/modular-monolith/>; slides <https://static.simonbrown.je/modular-monoliths.pdf>

**Event sourcing / CQRS intersection**
- Oskar Dudycz, "How to slice the codebase effectively?" — <https://event-driven.io/en/how_to_slice_the_codebase_effectively/>
- Oskar Dudycz, "Vertical Slices in practice" — <https://event-driven.io/en/vertical_slices_in_practice/>
- Oskar Dudycz, "Vertical slices, their ownership and external dependencies" — <https://event-driven.io/en/vertical-slices-and-dependencies/>
- Oskar Dudycz, "CQRS facts and myths explained" — <https://event-driven.io/en/cqrs_facts_and_myths_explained/>
- Oskar Dudycz, "What onion has to do with Clean Code?" — <https://event-driven.io/en/onion_clean_code/>
- Oskar Dudycz, "Testing Event Sourcing" — <https://event-driven.io/en/testing_event_sourcing/>
- Oskar Dudycz, "My thoughts on Vertical Slices, CQRS, Semantic Diffusion" — <https://www.architecture-weekly.com/p/my-thoughts-on-vertical-slices-cqrs>
- Emmett (his event-sourcing library; thin slices, no aggregates) — <https://event-driven-io.github.io/emmett/getting-started.html>
- Reference repos — <https://github.com/oskardudycz/EventSourcing.NetCore>, <https://github.com/event-driven-io>
- Greg Young, "CQRS is not an Architecture" — <https://gregfyoung.wordpress.com/2012/09/09/cqrs-is-not-an-architecture/>
- Greg Young, CQRS Documents (PDF) — <https://cqrs.wordpress.com/wp-content/uploads/2010/11/cqrs_documents.pdf>

**Ralf Westphal on slicing (he *does* have material — see §3)**
- "Slice me nice" — <https://ralfwestphal.substack.com/p/slice-me-nice>
- "Incremental Event Sourcing — Under the hood" — <https://ralfwestphal.substack.com/p/incremental-event-sourcing-under>
- "Incremental Event Sourcing" — <https://ralfwestphal.substack.com/p/incremental-event-sourcing>
- "IODA Architecture" / IOSP — <https://ralfwestphal.substack.com/p/ioda-architecture>
- "Command Context Consistency" — <https://ralfwestphal.substack.com/p/command-context-consistency>
- "Killing the Entity!" — <https://ralfwestphal.substack.com/p/killing-the-entity>
- Archive — <https://ralfwestphal.substack.com/archive>

**Not verified / could not confirm**
- Any Bogard retraction or "I changed my mind" post on VSA — searched, not found.
- Any Bogard statement that MediatR is not required for VSA — not found in his own writing. (Verified
  fact instead: the 2018 founding article does not mention MediatR.)
- The exact source article for the attributed Westphal quote "Event Sourcing and VSA are great, but
  without the IODA mindset… you're still prone to write code harder to maintain than necessary."
- The javapractices.com "Package by feature, not layer" page (the oldest widely-cited statement of
  package-by-feature) is **offline** — the domain now returns HTTP 404 and its TLS certificate has
  expired. The older tradition therefore rests on Martin's "Screaming Architecture" (2011) and Brown's
  package-by-component writing (2013–) as its surviving primary sources.
- No first-party post-mortem from any originator listing VSA failure modes exists that I could find;
  §2's failure table is synthesised from recurring practitioner reports and is labelled as such.
