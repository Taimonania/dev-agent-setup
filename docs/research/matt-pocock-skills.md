# Matt Pocock's Skills — What They Are, How They Compose, What Belongs in a Tech-Agnostic Template

Research date: 2026-08-30. All claims traced to primary sources: the installed skill files under
`/Users/timo/conductor/workspaces/dev-agent-setup/munich-v1/.agents/skills/`, the lock file
`skills-lock.json`, and the upstream repo `github.com/mattpocock/skills` (fetched via the GitHub
contents/tree API and `raw.githubusercontent.com`).

---

## 0. Scope check: you have the complete upstream set

`skills-lock.json` lists **37** skills, all with `"source": "mattpocock/skills"`. The upstream tree
(`GET repos/mattpocock/skills/git/trees/main?recursive=1`) contains exactly 37 `SKILL.md` files
across four buckets — `skills/engineering/` (18), `skills/productivity/` (7), `skills/misc/` (4),
`skills/in-progress/` (8). **Nothing upstream was left uninstalled.** The only other bucket,
`skills/deprecated/`, contains just a README stating: *"Skills I no longer use. This bucket is
currently empty: a retired skill is deleted, and the changeset that removes it names whatever
replaced it."* (`skills/deprecated/README.md`).

Supporting files came along too: `tdd/tests.md`, `tdd/mocking.md`, `codebase-design/DEEPENING.md`,
`codebase-design/DESIGN-IT-TWICE.md`, `domain-modeling/CONTEXT-FORMAT.md`,
`domain-modeling/ADR-FORMAT.md`, `triage/AGENT-BRIEF.md`, `triage/OUT-OF-SCOPE.md`,
`prototype/LOGIC.md`, `prototype/UI.md`, `wizard/template.sh`,
`diagnosing-bugs/scripts/hitl-loop.template.sh`,
`git-guardrails-claude-code/scripts/block-dangerous-git.sh`,
`setup-ts-deep-modules/dependency-cruiser.config.cjs`, the four `setup-matt-pocock-skills/*.md`
seed templates, the four `teach/*-FORMAT.md` files, `ask-matt/PHASE-BOUNDARIES.md`,
`improve-codebase-architecture/HTML-REPORT.md`, `writing-for-agents/SKILL-MECHANICS.md`, plus an
`agents/openai.yaml` per skill (Codex metadata).

**Not installed** (they live outside `skills/`, so the CLI wouldn't take them) but worth reading as
design documents: `.agents/invocation.md`, `.agents/writing-docs.md`, `.agents/install-block.md`,
`.agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md`,
`.agents/adr/0002-ship-as-a-claude-code-plugin.md`.

### The author's stated philosophy

From the upstream `README.md`:

> "Developing real applications is hard. Approaches like GSD, BMAD, and Spec-Kit try to help by
> owning the process. But while doing so, they take away your control and make bugs in the process
> hard to resolve. These skills are designed to be small, easy to adapt, and composable. They work
> with any model."

The README frames the whole set as fixes for four failure modes: (#1) misalignment → grilling;
(#2) verbosity → shared domain language / `CONTEXT.md`; (#3) code doesn't work → feedback loops,
TDD, diagnosis; (#4) ball of mud → deep-module design. That four-part framing is the most useful
lens for deciding what a new-project template needs.

### The one organising axis the author actually uses

`.agents/invocation.md` (upstream, not installed) is explicit:

> "Every `SKILL.md` in this repo is a skill. The one axis that splits them is **invocation**, who can
> reach it: **User-invoked** … set `disable-model-invocation: true` … **Model-invoked**: reachable by
> model or user."
>
> "A user-invoked skill may invoke model-invoked skills, but it can never reach another user-invoked
> skill."

So: **user-invoked skills orchestrate; model-invoked skills hold reusable discipline.** Buckets
(`engineering/`, `productivity/`, `misc/`, `in-progress/`) are maturity/topic shelving, not
architecture.

---

## 1. Inventory

Legend for **Stack**: **Agnostic** = no language/tool assumption in the file; **Leaky** = mostly
agnostic but contains a TS/JS example or aside; **TS/Node** = will not work outside a JS/TS repo.
**Inv.** = U (user-invoked, `disable-model-invocation: true`) / M (model-invoked).

### `skills/engineering/` — 18 skills

| Skill | Inv. | Purpose (one line) | Trigger (from frontmatter `description`) | Stack |
|---|---|---|---|---|
| `ask-matt` | U | Router over every skill; the map of the flows | "Ask which skill or flow fits your situation. A router over the skills in this repo." | Agnostic |
| `setup-matt-pocock-skills` | U | Run-once repo config: issue tracker, triage labels, domain-doc layout | "Configure this repo for the engineering skills… Run once before first use of the other engineering skills." | Leaky (sniffs `pnpm-workspace.yaml` / `package.json` as monorepo signals, `SKILL.md` step 1) |
| `grill-with-docs` | U | Grilling interview that also writes `CONTEXT.md` + ADRs | "A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go." | Agnostic |
| `to-spec` | U | Synthesise the conversation into a spec, publish to tracker | "Turn the current conversation into a spec and publish it to the project issue tracker: no interview, just synthesis…" | Agnostic |
| `to-tickets` | U | Split a spec into tracer-bullet tickets with blocking edges | "Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges…" | Agnostic |
| `implement` | U | Build from spec/tickets, driving `/tdd`, closing with `/code-review` | "Implement a piece of work based on a spec or set of tickets." | Agnostic (15 lines total) |
| `triage` | U | State machine over incoming issues/external PRs → agent briefs | "Move issues and external PRs through a state machine of triage roles, categorise, verify, grill if needed, and write agent-ready briefs." | Agnostic |
| `wayfinder` | U | Chart a too-big-for-one-session effort as a map of decision tickets | "Plan a huge chunk of work (more than one agent session can hold) as a shared map of decision tickets on your issue tracker…" | Agnostic |
| `improve-codebase-architecture` | U | Survey codebase for deepening opportunities → HTML report → grill | "Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick." | Agnostic |
| `grilling` | M | The interview primitive: rounds, frontier, design tree | "Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases." | Agnostic |
| `domain-modeling` | M | Actively build/sharpen the glossary + ADRs | "Build and sharpen a project's domain model. Use when discussing codebase terminology, writing or editing a CONTEXT.md, or recording or editing an ADR." | Agnostic |
| `codebase-design` | M | Deep-module vocabulary (module/interface/depth/seam/adapter/leverage/locality) | "Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes…" | Leaky (two ```typescript examples, `SKILL.md` L73/L85; warns against reading "interface" as the TS keyword, L108) |
| `tdd` | M | Red-green-refactor discipline + what makes a good test | "Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions \"red-green-refactor\", or wants integration tests." | Leaky (`SKILL.md` itself is agnostic; `tests.md` and `mocking.md` are all ```typescript, and `tests.md` L32 uses `jest.mock`) |
| `code-review` | M | Two-axis review (Standards + Spec) in parallel sub-agents, Fowler smell baseline | "Review the changes since a fixed point… along two axes: Standards… and Spec… Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"." | Agnostic |
| `diagnosing-bugs` | M | Feedback-loop-first diagnosis discipline for hard bugs | "Diagnosis loop for hard bugs and performance regressions. Use when the user says \"diagnose\"/\"debug this\", or reports something broken/throwing/failing/slow." | Agnostic (names Playwright/Puppeteer/`git bisect` as *options* among 10, L: "Ways to construct one") |
| `research` | M | Background agent investigates primary sources, leaves a cited MD file | "Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo…" | Agnostic (12 lines) |
| `resolving-merge-conflicts` | M | Resolve merge/rebase hunks by intent; never `--abort` | "Use when you need to resolve an in-progress git merge/rebase conflict." | Agnostic (git-specific by nature; step 4 says "Discover the project's automated checks") |
| `prototype` | M | Throwaway code answering one design question (logic vs UI branch) | "Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like." | Leaky→TS (SKILL.md L22 lists `pnpm`/`python`/`bun`; `LOGIC.md` L66 names React; `UI.md` L87 assumes Next router / React Router) |
| `wizard` | M | Generate an interactive bash wizard for human-only steps | "Generate an interactive bash wizard that walks a human through steps only they can perform. Use when provisioning infrastructure, setting up credentials or CI secrets…" | Agnostic (bash + `gh` CLI + `.env`) |

### `skills/productivity/` — 7 skills

| Skill | Inv. | Purpose | Trigger | Stack |
|---|---|---|---|---|
| `grill-me` | U | Stateless grilling (no repo, no docs) | "A relentless interview to sharpen a plan or design." | Agnostic (body is one line: `Call the Skill tool with "grilling".`) |
| `handoff` | U | Write a portable handoff MD to the OS temp dir | "Compact the current conversation into a handoff document for another agent to pick up." | Agnostic |
| `wait-what` | U | Re-pitch a message that didn't land, in Simplified Technical English | "Stop. That last message did not land: re-pitch it." | Agnostic (7 lines; depends on `CONTEXT.md`) |
| `to-questionnaire` | U | Turn a decision you can't answer into a questionnaire for someone who can | "Turn a decision you can't fully answer into a questionnaire for someone else to fill in." | Agnostic |
| `teach` | U | Multi-session teaching workspace (MISSION.md, lessons/, learning-records/) | "Teach the user a new skill or concept, within this workspace." | Agnostic (HTML lessons) |
| `grilling` | M | *(listed above — lives in productivity/ upstream)* | — | Agnostic |
| `writing-for-agents` | M | How to write docs agents consume: skills, AGENTS.md, CLAUDE.md | "Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md." | Agnostic |

*(Note: `grilling` is upstream in `productivity/`, per `skills-lock.json` `skillPath: skills/productivity/grilling/SKILL.md`, even though every engineering flow uses it.)*

### `skills/misc/` — 4 skills

Upstream `skills/misc/README.md`: *"Tools I keep around but rarely use, not promoted in the plugin."*

| Skill | Inv. | Purpose | Trigger | Stack |
|---|---|---|---|---|
| `git-guardrails-claude-code` | M | Claude Code PreToolUse hook blocking `git push`, `reset --hard`, `clean -f`, `branch -D`, `checkout .` | "Set up Claude Code hooks to block dangerous git commands… before they execute." | Agnostic, but **Claude-Code-specific** (writes `.claude/settings.json`, ships `scripts/block-dangerous-git.sh`) |
| `setup-pre-commit` | M | Husky + lint-staged + Prettier + typecheck + test pre-commit hook | "Set up Husky pre-commit hooks with lint-staged (Prettier)… Use when user wants to add pre-commit hooks, set up Husky…" | **TS/Node** — hard dependency |
| `migrate-to-shoehorn` | M | Replace `as` assertions in tests with `@total-typescript/shoehorn` | "Migrate test files from `as` type assertions to @total-typescript/shoehorn…" | **TS only** — single-library |
| `scaffold-exercises` | M | Scaffold course exercise dirs that pass `pnpm ai-hero-cli internal lint` | "Create exercise directory structures with sections, problems, solutions, and explainers that pass linting…" | **Author's private repo only** |

### `skills/in-progress/` — 8 skills

Upstream `skills/in-progress/README.md`: *"Beta. These skills are public on purpose: try them and
tell me what breaks. They're excluded from the plugin and the top-level README until they graduate
to a stable bucket, they get no docs pages, and they can change or disappear without warning."*

| Skill | Inv. | Purpose | Trigger | Stack |
|---|---|---|---|---|
| `implement-spec` | U | Implement a whole spec on one branch via parallel implementer subagents in worktrees → one PR | "Implement a specification in code." | Agnostic (assumes git worktrees + a PR host) |
| `claude-handoff` | U | Launch a fresh background agent seeded with a handoff summary via `claude --bg` | "Hand the current conversation off to a fresh background agent that picks up the work immediately." | **Claude Code CLI-specific** (`claude --bg --name`) |
| `retro` | U | Post-session retrospective on the *agent's environment* (steering files, checks, tooling) | "Conduct a retrospective on a coding session." | Agnostic — but upstream README calls it **"STUB: design notes only, not functional yet"** |
| `loop-me` | U | Grill the user into workflow specs in `workflows/*.md` | "Grill me about specs for the workflows I want to build, within this workspace." | Agnostic (life-automation, not code) |
| `setup-ts-deep-modules` | U | Wire dependency-cruiser to enforce entry-point-only imports per package | "Wire dependency-cruiser into a TypeScript repo so each package is a deep module…" | **TS/Node** — hard dependency |
| `writing-fragments` | U | Explore: mine raw writing fragments into one MD file | "Writing, explore: mine raw fragments, no structure yet." | Agnostic (prose) |
| `writing-shape` | U | Exploit: shape raw material into an article paragraph by paragraph | "Writing, exploit: shape raw material into an article, paragraph by paragraph." | Agnostic (prose) |
| `writing-beats` | U | Exploit: assemble raw material as a journey of grounded "beats" | "Writing, exploit; assemble raw material into a journey of beats…" | Agnostic (prose) |

---

## 2. Composition map

### The entry point / meta skills

- **`ask-matt`** is the router. It is the single best document in the set for understanding intent
  (`ask-matt/SKILL.md`). It is *not* operative — `.agents/invocation.md` notes router prose "isn't
  invoking anything, so it keeps `/skill`-style names as plain labels."
- **`setup-matt-pocock-skills`** is the stated precondition: *"run before your first engineering flow
  to configure the issue tracker, triage labels, and doc layout the other skills assume"*
  (`ask-matt/SKILL.md`, "Precondition").
- **`writing-for-agents`** is the meta-skill for authoring more skills / `AGENTS.md` / `CLAUDE.md`.

### The main flow (verbatim structure from `ask-matt/SKILL.md`, "The main flow: idea → ship")

```
                                     ┌─ (question needs runnable answer) ─┐
                                     │  /handoff → /prototype → /handoff  │
                                     └────────────────┬───────────────────┘
/grill-with-docs ──────────────────────────────────────┴──► multi-session?
        │ (= /grilling + /domain-modeling)                     │
        │                                            yes ──► /to-spec ──► /to-tickets ──┐
        │                                             no ─────────────────────────────┐ │
        └──────────────────────────────────────────────────────────────────────────┐  │ │
                                                                                   ▼  ▼ ▼
                                                            /implement  ──drives──► /tdd ──► /code-review ──► commit
```

Context-hygiene rule, quoted: *"Keep steps 1–3 in one unbroken context window (don't compact or
clear until after `/to-tickets`)… Each `/implement` then starts fresh, working from the ticket."*

### Explicit invocation edges (grepped for `Call the Skill tool`)

| Caller | Callee(s) | Source |
|---|---|---|
| `grill-me` | `grilling` | `grill-me/SKILL.md` (entire body) |
| `grill-with-docs` | `grilling`, `domain-modeling` | `grill-with-docs/SKILL.md` (entire body) |
| `triage` | `grilling`, `domain-modeling` | `triage/SKILL.md` step 4 |
| `wayfinder` | `grilling`, `domain-modeling`, `research`, `prototype` | `wayfinder/SKILL.md` — "Ticket Types", "Chart the map" 1 & 5, "Work through the map" 3 |
| `improve-codebase-architecture` | `codebase-design`, `grilling`, `domain-modeling` | `improve-codebase-architecture/SKILL.md` intro + later steps |
| `tdd` | `codebase-design` | `tdd/SKILL.md`, "Seams: where tests go" |
| `setup-ts-deep-modules` | `codebase-design` | `setup-ts-deep-modules/SKILL.md` |
| `retro` | `writing-for-agents` | `retro/SKILL.md` step 1 |
| `implement` | `tdd`, `code-review` (prose `/tdd`, `/code-review`) | `implement/SKILL.md` |
| `implement-spec` | `code-review` | `implement-spec/SKILL.md` step 7 |
| `handoff` / `claude-handoff` | emit a "suggested skills" section naming skills for the next agent | both `SKILL.md`s |

### On-ramps and standalone (from `ask-matt/SKILL.md`)

- **Bugs/requests piling up** → `triage` → produces agent-ready issues → `implement`.
- **Something's broken** → `diagnosing-bugs`; its post-mortem "hands off to
  `/improve-codebase-architecture` when the real finding is that there's no good seam."
- **Huge foggy effort** → `wayfinder`; *"when the map clears, it hands off, it doesn't build: merge
  onto the main flow at `/to-spec`."*
- **Upkeep** → `improve-codebase-architecture` (run "every few days", per upstream README).
- **Vocabulary layer underneath everything**: `domain-modeling` (domain words) and `codebase-design`
  (structure words). Both model-invoked references, not sessions.

### The shared config surface all the tracker-aware skills read

`setup-matt-pocock-skills` writes `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, and
(conditionally) `docs/agents/triage-labels.md`, plus an `## Agent skills` block into `CLAUDE.md` or
`AGENTS.md`. Four skills hard-check for it and tell the user to run it if missing: `code-review`
(L13), `to-tickets` (L11), `to-spec`, `wayfinder` (L25), `triage`. Domain artifacts are `CONTEXT.md`
(glossary only — *"totally devoid of implementation details… It is a glossary and nothing else"*,
`domain-modeling/SKILL.md`), optional `CONTEXT-MAP.md` for monorepos, and `docs/adr/NNNN-slug.md`.

### The phase-boundary meta-doc

`ask-matt/PHASE-BOUNDARIES.md` is a standalone, tech-agnostic decision tree for context management:
Continue → `/clear` → `/handoff` → Subagent → `/compact`, in that order, with the rationale that
*"Every move except Continue turns a primary source into a secondary source."* This is arguably the
single most portable artifact in the whole set and is worth lifting into a template's docs even if
you take no skills at all.

---

## 3. Maturity signals

1. **`skills/in-progress/` is explicitly beta and explicitly unsupported.** Upstream README for the
   bucket: *"they get no docs pages, and they can change or disappear without warning"*, and *"The
   plugin won't give you these"* — i.e. the author's own recommended install path (the Claude Code
   plugin) excludes all 8. You installed them anyway because `skills.sh` offers the full tree.
2. **`retro` is a declared stub.** `skills/in-progress/README.md`: *"STUB: design notes only, not
   functional yet."* The local file reads plausibly but has never been promoted.
3. **`skills/misc/` is "rarely used, not promoted in the plugin"** (`skills/misc/README.md`). Three of
   its four are single-purpose or personal.
4. **`scaffold-exercises` is not a general skill at all** — it hard-codes `pnpm ai-hero-cli internal
   lint`, the author's own course CLI (`scaffold-exercises/SKILL.md` L8, L49, L54). Useless outside
   `mattpocock/ai-hero`.
5. **Thin skills.** `implement` is 15 lines of prose; `research` 12; `wait-what` 7; `grill-me` and
   `grill-with-docs` are one line each. Thin is deliberate in some cases (`grill-me` is pure
   delegation) but `implement` is genuinely underspecified for the load-bearing role it plays in the
   main flow.
6. **Two competing implement skills.** `implement` (stable, sequential, same context) vs
   `implement-spec` (in-progress, subagents + worktrees + PR). They are not composed; they are
   alternatives, and `ask-matt` never mentions `implement-spec`.
7. **Two competing handoffs.** `handoff` (stable, writes a file to OS temp) vs `claude-handoff`
   (in-progress, `claude --bg`). Same split.
8. **Versioning is by content hash, not semver.** `skills-lock.json` carries a `computedHash` per
   skill and no version. Upstream can change any skill under you; `npx skills update` is the only
   drift control (upstream README, "For tinkerers").

---

## 4. Stack assumptions — the explicit list

### Hard dependencies (will not work in a non-JS/TS repo)

| Skill | Evidence |
|---|---|
| `setup-pre-commit` | `SKILL.md` L19 detects `package-lock.json`/`pnpm-lock.yaml`/`yarn.lock`/`bun.lockb`; L26 installs `husky lint-staged prettier`; L32 `npx husky init`; L35 writes `prepare: "husky"` into `package.json`; L42 `npx lint-staged`; L53 `"*": "prettier --ignore-unknown --write"`. Husky, lint-staged, Prettier, npm/pnpm/yarn/bun — all mandatory. |
| `setup-ts-deep-modules` | Title says "TypeScript repo". L41 package-manager detection; L49 installs `dependency-cruiser` as devDependency; L90 of `dependency-cruiser.config.cjs` sets `tsConfig: { fileName: "tsconfig.json" }`. |
| `migrate-to-shoehorn` | Entire skill is about `@total-typescript/shoehorn`; L23/L113 `npm i @total-typescript/shoehorn`. TypeScript-only by construction. |
| `scaffold-exercises` | L8/L49/L54 `pnpm ai-hero-cli internal lint`; L62 references `pnpm run exercise`. pnpm + a private CLI. |

### Soft leaks (agnostic logic, JS/TS-flavoured examples or defaults)

| Skill | Leak |
|---|---|
| `tdd` | `SKILL.md` is stack-neutral, but its two reference files are not: `tests.md` L7/29/47/65 are all ```typescript blocks and L32 uses `jest.mock(paymentService)`; `mocking.md` L24/L41 likewise TypeScript. A Python or Go user reads Jest idioms. |
| `prototype` | `SKILL.md` L22 hedges (`pnpm <name>`, `python <path>`, `bun <path>`) — good. But `LOGIC.md` L66 says *"a React app or a dev server defeats 'shareable'"*, and `UI.md` L87 assumes *"the framework's router, e.g. `router.replace` on Next, `navigate` on React Router"*. `UI.md` is effectively a React/Next skill. |
| `codebase-design` | L73 and L85 are ```typescript examples; L108 warns against reading "Interface" as the TypeScript `interface` keyword. Concepts are language-neutral (Ousterhout / Feathers); the illustrations are not. |
| `setup-matt-pocock-skills` | L30 uses `pnpm-workspace.yaml` and `package.json` `workspaces` as its *only* monorepo signals. A Cargo/Go/Nx/Bazel monorepo is silently classified single-context. |

### Harness / tooling assumptions (not language, but not neutral either)

| Skill | Assumption |
|---|---|
| `git-guardrails-claude-code` | Claude Code `PreToolUse` hooks and `.claude/settings.json`. Name says it. Not portable to Codex/Cursor. |
| `claude-handoff` | `claude --bg --name` CLI and `claude agents`. Claude Code only. |
| `implement-spec` | git worktrees, branches, a PR host, background subagents. |
| `wizard` | bash, `gh secret`/`gh variable`, `.env`. GitHub-flavoured, though the template is otherwise generic. |
| `triage`, `to-spec`, `to-tickets`, `code-review`, `wayfinder` | An issue tracker. `setup-matt-pocock-skills` supports GitHub (`gh`), GitLab (`glab`), local markdown under `.scratch/`, or freeform "other". The local-markdown option is what makes these genuinely infrastructure-agnostic. |
| `resolving-merge-conflicts`, `code-review`, `improve-codebase-architecture` | git. |
| Every skill | `agents/openai.yaml` sidecars carry Codex metadata; frontmatter `disable-model-invocation` is Claude Code's. The set is dual-harness by design (`.agents/invocation.md`). |

**Nothing in the set assumes React or Vitest specifically** — the React exposure is `prototype/UI.md`
and `prototype/LOGIC.md`; the test-runner exposure is Jest (not Vitest) in `tdd/tests.md`.

---

## 5. Recommendation for a tech-agnostic new-project template

### Tier 1 — Core. Take these, essentially as-is (11 skills)

These carry zero stack assumptions and cover the four failure modes the author's README names.

| Skill | Why it belongs |
|---|---|
| `grilling` | The primitive behind five other skills. Pure interview discipline: design tree, frontier, rounds, "facts are the agent's job, decisions are yours." Nothing tech-specific. Fixes README failure #1. |
| `grill-me` | One-line wrapper; free. Stateless entry for non-repo thinking. |
| `grill-with-docs` | One-line wrapper; the stateful entry point for a repo. This is the "start here" of the whole system. |
| `domain-modeling` (+ `CONTEXT-FORMAT.md`, `ADR-FORMAT.md`) | The `CONTEXT.md` glossary + ADR discipline is the highest-leverage thing in the set for a *new* project — you're defining the vocabulary from scratch, which is exactly when it's cheapest. Fixes failure #2. Language-neutral. |
| `codebase-design` (+ `DEEPENING.md`, `DESIGN-IT-TWICE.md`) | Ousterhout/Feathers vocabulary. Applies to any language. Fixes failure #4. Genericise: replace the two `typescript` fences with pseudocode or drop the fence language tag. |
| `code-review` | Two-axis Standards+Spec review with the Fowler smell baseline pasted inline. Entirely language-neutral; the smell list works in any language. Only external need is a spec source. |
| `diagnosing-bugs` | "Build a tight feedback loop before you theorise" is the most transferable engineering discipline here, and its ten loop-construction options span HTTP, CLI, browser, trace-replay, fuzz, bisect, differential. Fixes failure #3. |
| `research` | 12 lines, zero assumptions, high value in a greenfield repo where every dependency choice is unmade. |
| `resolving-merge-conflicts` | git-only, which every project has. Five steps, agnostic. |
| `writing-for-agents` (+ `SKILL-MECHANICS.md`) | The meta-skill. If the template's purpose is to be a *starting point for agent-driven projects*, this is the skill that lets the project grow its own skills correctly. Context pointers, the two loads, information hierarchy, progressive disclosure. |
| `handoff` | Portable markdown handoff. Harness-neutral (unlike `claude-handoff`). |

Also lift **`ask-matt/PHASE-BOUNDARIES.md`** into the template's docs regardless of whether you ship
`ask-matt` itself — it is a self-contained, tool-agnostic context-management doctrine.

### Tier 2 — Core with genericisation required (3 skills)

| Skill | Change needed |
|---|---|
| `tdd` | Keep `SKILL.md` verbatim (it is genuinely agnostic: seams, vertical slices, red-before-green, three named anti-patterns). **Rewrite `tests.md` and `mocking.md`** to drop TypeScript/Jest — either pseudocode, or a per-language examples directory the project fills in. As shipped, they teach Jest idioms to a Python project. |
| `setup-matt-pocock-skills` | This is the keystone: without it, five skills print "tell the user to run `/setup-matt-pocock-skills`". But its monorepo detection is pnpm/npm-only (L30). Genericise the signals (add `Cargo.toml` workspaces, `go.work`, `pyproject.toml` + uv workspaces, `nx.json`, `MODULE.bazel`) or reduce it to "ask the user". Also consider renaming it — `setup-matt-pocock-skills` is a poor name in someone else's template. Default the issue tracker to **local markdown** for a fresh project with no remote. |
| `prototype` | `SKILL.md` and `LOGIC.md`'s core idea (throwaway code answers one question; keep it as a primary source on a `prototype/<name>` branch) are excellent and agnostic. `UI.md` is React/Next-specific and `LOGIC.md` L66 assumes web. Either ship `SKILL.md` + a genericised `LOGIC.md` only, or gate `UI.md` behind "if this is a web project". |

### Tier 3 — Optional add-ons (opt in per project)

| Skill | When |
|---|---|
| `ask-matt` | Ship it **rewritten** to describe *your* flow, not Matt's. As-is it advertises skills you may have excluded and uses `/name` syntax. It is the discoverability layer, so it's valuable — but it must match reality or it misroutes. |
| `to-spec`, `to-tickets`, `implement` | The multi-session build chain. Agnostic, but only earn their keep once the project has an issue tracker and work big enough to split. `implement` is 15 lines — you will want to thicken it. |
| `triage` (+ `AGENT-BRIEF.md`, `OUT-OF-SCOPE.md`) | Only once the project has *incoming* issues from other people. Explicitly *not* for tickets you created: *"Tickets that `/to-tickets` produced are already agent-ready, so don't triage them"* (`ask-matt/SKILL.md`). Day-one dead weight for a greenfield template. |
| `wayfinder` | Powerful but heavy — `ask-matt` calls it *"the most cognitively demanding flow here"* and warns *"save it for exactly that, never a well-scoped feature."* Ironically it's aimed at greenfield ("a greenfield project or a huge feature build"), so it's a real candidate — just not a default. |
| `improve-codebase-architecture` | Maintenance. Nothing to survey on day one. Add when the repo has history (it reads `git log` for hot spots). |
| `wizard` | Genuinely useful for an infra-agnostic template: it's the escape hatch for the human-only steps (provisioning, secrets, CI). bash + `gh`. Include if the template targets GitHub; genericise `set_secret` otherwise. |
| `to-questionnaire`, `wait-what`, `teach` | Individually fine, zero stack assumptions, but off the engineering path. `wait-what` is 7 lines and free. |
| `git-guardrails-claude-code` | Include only if the template commits to Claude Code. Real safety value; zero portability. |

### Tier 4 — Exclude

| Skill | Reason |
|---|---|
| `scaffold-exercises` | Hard-coded to `pnpm ai-hero-cli internal lint`, a private course CLI. Zero value outside `mattpocock/ai-hero`. |
| `migrate-to-shoehorn` | Single TypeScript library migration. |
| `setup-pre-commit` | Husky + lint-staged + Prettier + `package.json`. Directly contradicts "tech-agnostic". If the template wants pre-commit hooks, write a stack-neutral one (or use `pre-commit` the Python tool, or plain `.git/hooks`). |
| `setup-ts-deep-modules` | TypeScript + dependency-cruiser. Its *idea* (enforce entry-point-only imports so packages are deep modules) is worth stealing at the doc level, paired with `codebase-design`; the implementation is not portable. |
| `scaffold-exercises`, `writing-fragments`, `writing-shape`, `writing-beats` | The three writing skills are agnostic and decent, but they are prose-authoring tools, not project infrastructure. Ship them in a personal skill set, not a project template. |
| `loop-me` | Life-workflow design, in-progress, unrelated to a code project. |
| `retro` | Declared stub upstream. The *idea* (retro on the agent's environment, not the code) is the single most template-relevant idea in `in-progress/` — consider writing your own version rather than shipping this one. |
| `claude-handoff` | Superseded for a portable template by `handoff`; Claude-CLI-locked; in-progress. |
| `implement-spec` | In-progress, and overlaps `implement` with no stated relationship. Pick one. Its worktree/task-graph/parallel-subagent model is the more interesting design — but it is beta and `ask-matt` doesn't know it exists. |

### Suggested default core for `Taimonania/dev-agent-setup`

**14 skills**: `grilling`, `grill-me`, `grill-with-docs`, `domain-modeling`, `codebase-design`,
`tdd` (genericised refs), `code-review`, `diagnosing-bugs`, `research`,
`resolving-merge-conflicts`, `writing-for-agents`, `handoff`, `prototype` (logic branch only),
plus a renamed/genericised `setup-*` keystone. Ship `ask-matt` rewritten as your own router, and
`PHASE-BOUNDARIES.md` as a doc. Everything else opt-in.

---

## 6. Gaps — what a new-project starting point needs that these skills do NOT cover

1. **Project bootstrap itself.** Nothing here scaffolds a repo: no "choose a stack", no directory
   layout, no `.gitignore`, no license, no README generation. The set assumes a repo already exists
   with code in it. `setup-matt-pocock-skills` configures *agent conventions*, not the project.
2. **Stack selection / ADR-0000.** `domain-modeling` records ADRs but nothing prompts the
   foundational decisions (language, runtime, package manager, test runner, CI) that a template must
   surface on day one. `grill-with-docs` could be aimed at this, but no skill does it.
3. **CI/CD.** No skill sets up a pipeline. `wizard` handles *secrets* for CI and `code-review`
   assumes checks exist, but nothing creates `.github/workflows/`, a Makefile/Justfile, or a task
   runner. `resolving-merge-conflicts` L4 just says *"Discover the project's automated checks"* —
   assuming they exist.
4. **A stack-neutral quality gate.** The only formatting/linting/hook skill is `setup-pre-commit`,
   which is Husky-specific. There is no "define the repo's `check` command" skill, yet
   `setup-ts-deep-modules` L62 explicitly assumes *"the repo's umbrella check command, the one that
   already runs typecheck (e.g. a `check`/`ci`/`validate` script)"*. That umbrella command is the
   contract several skills lean on, and nothing establishes it.
5. **`CODING_STANDARDS.md`.** `code-review` step 3 looks for `CODING_STANDARDS.md` /
   `CONTRIBUTING.md`, and `retro` treats `CODING_STANDARDS.md` as a first-class file — but no skill
   creates or maintains one. A template should ship the file and the discipline.
6. **Dependency, security, and licensing hygiene.** Nothing about supply chain, SBOM, secret
   scanning, vulnerability review, or dependency upgrades. `diagnosing-bugs` has a good "Redact"
   section, and `handoff` says redact secrets, but that's the extent of security thinking.
7. **Observability / running the app.** No skill starts a dev server, reads logs, or verifies a
   change in the real app. `diagnosing-bugs` lists dev servers and headless browsers as loop
   ingredients but assumes you know how to launch them. `retro` names "teeing dev server logs" as a
   *candidate improvement*, i.e. an acknowledged gap.
8. **Deployment, environments, migrations.** `wizard` covers one-off human-driven cutovers; nothing
   covers repeatable deploys or environment promotion. Explicitly infrastructure-agnostic here means
   infrastructure-absent.
9. **Multi-agent / harness portability.** The set is dual-harness (Claude + Codex `openai.yaml`) but
   two skills are Claude-CLI-locked and there is no skill for keeping a repo's agent config portable
   across harnesses — a likely core concern for `dev-agent-setup`.
10. **Skill lifecycle management.** `writing-for-agents` teaches how to *write* a skill; nothing
    covers installing, pinning, updating, or auditing third-party skills — exactly the problem
    `skills-lock.json` exists to solve. That gap is arguably this repo's reason to exist.
11. **Onboarding a human.** `teach` teaches concepts; nothing writes the project's own
    getting-started path. `wizard` step 4 gestures at it ("link it from the README") but there's no
    README discipline.
12. **Non-code work.** No skills for data/ML pipelines, infrastructure-as-code, mobile, or embedded.
    The implicit target is a web/service codebase with an issue tracker and a test suite.

---

## Sources

- Installed skills: `/Users/timo/conductor/workspaces/dev-agent-setup/munich-v1/.agents/skills/**/*.md` (all 37 `SKILL.md` plus supporting files), read directly.
- `/Users/timo/conductor/workspaces/dev-agent-setup/munich-v1/skills-lock.json` — 37 entries, all `mattpocock/skills`, with upstream `skillPath` and `computedHash`.
- <https://raw.githubusercontent.com/mattpocock/skills/main/README.md> — philosophy, install paths, the four failure modes, the full user-/model-invoked reference lists.
- `GET https://api.github.com/repos/mattpocock/skills/git/trees/main?recursive=1` — full upstream file tree (used to confirm nothing was left uninstalled).
- Upstream `skills/engineering/README.md`, `skills/productivity/README.md`, `skills/misc/README.md`, `skills/in-progress/README.md`, `skills/deprecated/README.md` — bucket definitions and maturity statements.
- Upstream `.agents/invocation.md` — the user-invoked / model-invoked axis and the Skill-tool dependency convention.
- Upstream `.agents/writing-docs.md` — the author's docs-page doctrine (useful as a model for a template's own doc conventions).
