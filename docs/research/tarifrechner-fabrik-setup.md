# tarifrechner-fabrik — setup teardown, and what generalizes

Primary-source research against the main checkout at `/Users/timo/_repos/9elf26/tarifrechner-fabrik`
(read-only; nothing was modified, built, or committed). Every claim below cites a file in that repo.

Scope note: this document deliberately describes **structure and practice**, not product content.
Domain specifics, customer names, account IDs, hostnames and secret values encountered during the
read are omitted. Where a secrets-handling *pattern* matters it is described; no value is reproduced.

---

## 1. Structural map — what lives where, and why

Root inventory (`ls` of the repo root):

| Path | Role | Evidence |
|---|---|---|
| `CLAUDE.md` | 22 KB single-file codebase guide for agents. The richest artifact in the repo. | `CLAUDE.md` |
| `QUALITY.md` | Measured quality **baseline** + the guardrail catalogue + reproduction commands. | `QUALITY.md` |
| `README.md` | Short human entry point: what it is, quality badges, getting started, commands, deploy rules. | `README.md` |
| `.claude/` | Agent setup: `settings.json` (hooks), `memory/` (47 shared memories), `skills/` (3 project skills). | `.claude/` |
| `.github/` | `workflows/deploy.yml`, `workflows/setup.yml`, `badges/*.json`. **No** PR template, issue template or CODEOWNERS. | `ls -a .github` |
| `.gitlab-ci.yml` | Superseded but deliberately retained (see `no-premature-delete` memory). | `.gitlab-ci.yml` |
| `packages/` | Pure/shared libraries. One is the domain core with a "no I/O" purity rule. | `pnpm-workspace.yaml`, `CLAUDE.md` |
| `apps/` | Deployable applications (three), each with its own Dockerfile. | `CLAUDE.md`, `.github/workflows/deploy.yml` |
| `services/` | Non-Node sidecar services (Python Lambdas), each its own Dockerfile + build context. | `docker-compose.yml`, deploy matrix |
| `cdk/` | Infrastructure-as-code, **outside** the pnpm workspace (own `npm ci`). | `pnpm-workspace.yaml` comment, `deploy.yml` |
| `db/init.sql` | Single schema bootstrap file, mounted into the local Postgres container. | `docker-compose.yml` |
| `scripts/` | Repo tooling: `memory-sync.mjs`, `quality-report.mjs`, `hooks/*.mjs`. | `scripts/` |
| `spike/` | Throwaway evaluation of a candidate dependency, kept as an artifact. | `spike/baml/README.md` |
| `docker-compose.yml` | The whole stack locally: db + object storage + parsers + apps. | `docker-compose.yml` |
| `.env.example` | Commented template of every var needed to boot locally, with safe placeholders. | `.env.example` |

### The layering rationale

`CLAUDE.md` § "Monorepo Layout" states the split explicitly and the dependency-cruiser config enforces
it (`.dependency-cruiser.cjs`):

- `packages/*` — reusable, may not import from `apps/*` ("the dependency points the wrong way").
- One designated **pure domain package** (`packages/core`) with a machine-enforced ban on I/O,
  DB, cloud and vendor SDK imports.
- `apps/*` — the deployables; sibling apps may not import each other ("separate deployables").
- A **vendor seam**: the third-party SDK may only be imported from one directory; everything else
  uses neutral types.

### The role of `spike/`

`spike/baml/README.md` is a self-contained evaluation of a candidate library: what was actually
executed, the *core proof* (a generated type showing the property being tested for), a
"does it fit our architecture" table mapping the candidate's mechanisms onto the existing seam,
an honest cost/risk section, and a recommendation ending in an explicit open decision for the
maintainer. The spike lives **in the repo, in its own top-level directory, not in the build**
(`.dockerignore` excludes non-app dirs; `spike/baml/.gitignore` excludes the generated client).

The follow-through is the interesting part: the recommendation was "adopt" — and the
`rejected-approaches` memory records that it was adopted, then ripped out again, with the reason
preserved (`.claude/memory/rejected-approaches.md`, `.claude/memory/dependency-discipline.md`).
So `spike/` is one half of a two-part pattern: **a spike directory for the evaluation, a
rejected-approaches register for the verdict.** That pairing is fully tech-agnostic.

---

## 2. The quality / guardrail system

This is the most transferable asset. It is built in **layers of increasing cost and decreasing
strictness**, and each layer is documented with the failure mode it prevents.

### 2.1 `.dependency-cruiser.cjs` — architecture boundaries (the gate)

Seven rules, each with a `comment` explaining the *why* (this is what makes them portable):

| Rule | Enforces | Failure mode prevented | Severity |
|---|---|---|---|
| `no-circular` | No runtime import cycles; **type-only cycles explicitly allowed** (`viaOnly: { dependencyTypesNot: ["type-only"] }`) | Unreasonable module graph, broken tree-shaking — without the type-only exemption the rule would be unusable | error |
| `core-is-pure` | The domain package imports no DB/cloud/LLM/UI packages and no I/O node built-ins (`node:fs|net|dns|tls|http|https|child_process|dgram`) | Domain logic becoming untestable and un-reusable because it grew an I/O dependency | error |
| `packages-no-apps` | `packages/**` must not import `apps/**` | Inverted dependency direction; a "shared" library that can't be extracted | error |
| `artifact-not-factory` / `factory-not-artifact` | Two deployables cannot cross-import | Accidental coupling between things that ship separately | error |
| `vendor-llm-only-behind-seam` | A named vendor SDK may only be imported from one directory | Vendor lock-in leaking through the whole codebase | error |
| `no-orphans` | Flags modules imported by nothing, with a well-tuned `pathNot` exemption list (`.d.ts`, tests, `index`/config entrypoints, framework convention dirs, IaC) | Dead code accumulating | **warn** |

Options worth copying verbatim in spirit: `tsPreCompilationDeps: true` (so type-only edges are
visible at all), `exclude` of build output dirs, and a dedicated `tsConfig` file.

### 2.2 `tsconfig.arch.json` — resolution-only config

Its own first line states the purpose: *"Resolution-only config for dependency-cruiser: maps
workspace aliases to source so cross-package edges resolve to files (not node_modules symlinks).
Not used for compilation."*

Failure mode prevented: in a workspace monorepo, cross-package imports resolve through
`node_modules` symlinks, so the architecture tool sees "an npm package" instead of "our other
package" and every cross-package rule silently passes. This is a **non-obvious prerequisite** for
any package-graph linting in a monorepo, and it generalizes to any language with a package-alias
mechanism.

### 2.3 `apps/factory/test/architecture.test.ts` — source-text rules with a ratchet

Runs inside the normal test suite. It covers what module resolution cannot see reliably, and it
introduces the **ratchet allowlist** pattern:

```ts
const KNOWN_SEAM_EXCEPTIONS = new Set([ /* 4 grandfathered files */ ]);
```

Two tests, and the second one is the clever half:

1. No *new* file outside the seam may import the vendor SDK.
2. *"the allowlist has no stale entries (a fixed file must be removed from the ratchet)"* — it
   asserts every allowlisted file **still violates** the rule, so the allowlist cannot rot.

Failure mode prevented: the usual "add an exception, forget it, exceptions grow forever." Here
exceptions can only shrink. This is completely language-agnostic and is, in my reading, the single
most reusable idea in the repo.

Also in the same file: a purity test for the domain package expressed as source-text regex, and a
test that the customer-delivered app carries no LLM SDK at all — i.e. *"what must NOT be in the
shipped artifact"* as an executable assertion.

### 2.4 `eslint.quality.mjs` — complexity as a report, not a gate

12 lines. A standalone config (invoked with `--no-config-lookup`, so it is independent of the
project's normal lint config) with three SonarJS rules at `warn`:
cognitive complexity > 15, identical functions, duplicate strings (threshold 8)
(`eslint.quality.mjs`, `package.json` → `quality:complexity`).

The separation is deliberate: **the normal lint config is for correctness; the quality config is a
separate measurement instrument.** It can be run repo-wide over a mixed codebase without failing
anyone's build.

### 2.5 `QUALITY.md` — the baseline document

Structure worth stealing wholesale:

- A **measurement date** and the claim "every number below is reproducible via the commands at the
  bottom" — then the commands.
- An explicit statement of **scope** (whole monorepo, not one app).
- An explicit statement of **enforcement level per metric**: architecture is *enforced*, type
  coverage / test coverage / complexity are *reported*. "Gating can be enabled per metric later."
- Per-metric tables with numbers **and interpretation** — e.g. it explains that low statement
  coverage with high branch coverage means "untested files, not shallow tests."
- Honest gaps, each with a tracked ticket ID, listed in a `Follow-ups` section.

Its stated purpose: *"This file is the reference point against which drift becomes visible."*

### 2.6 Hooks — three `.claude/settings.json` gates

| Hook | Event | What it does | Failure mode prevented |
|---|---|---|---|
| `push-gate.mjs` | `PreToolUse` on `Bash` | Runs the fast architecture check before any `git push` leaves the machine | Architecture violations reaching CI/the branch |
| `prompt-neutrality-reminder.mjs` | `PostToolUse` on `Edit\|Write` | On editing a prompt file, prints a semantic self-check instruction and exits 2 | A domain-specific leak into a generic prompt |
| `root-cause-gate.mjs` | `Stop` | If product source changed and no test file was touched, blocks the stop once and asks two questions | Fixes shipped without a proving test / symptom-doctoring |

Craft details worth carrying:

- **Cheap prefilter before the expensive interpreter.** The `PreToolUse` hook is wrapped in
  `sh -c 'in=$(cat); case "$in" in *git*push*) … node …;; esac'`. Commit `6a060f9` states the
  reason: *"Every Bash tool call was paying node startup for the PreToolUse hook."*
- **Precise matching inside the script too:** the push gate splits the command on `&&`, `||`, `;`,
  `|`, newline and only fires on segments that actually *start with* `git` — so `echo "git push"`
  does not trigger it (`scripts/hooks/push-gate.mjs`).
- **The stop gate nags exactly once** — guarded by `if (input.stop_hook_active) process.exit(0)`,
  and a justified "no test needed because …" is an accepted answer (`scripts/hooks/root-cause-gate.mjs`).
- **Hooks degrade safely.** Every script wraps stdin parsing in try/catch and exits 0 on anything
  unexpected.
- **Deterministic vs. semantic split.** Commits `1f6f88b` and `16b1301` are the reasoning:
  a domain-noun denylist was built, then reverted, because *"Any list-based check only knows past
  leaks — future … are unknown by definition, so it gives false confidence."* The conclusion:
  finite, unambiguous things get a deterministic check; unbounded/semantic things get a
  *reminder at the moment of change* that makes the agent do the judging. This is a genuinely
  generalizable principle for designing agent guardrails.

### 2.7 CI gates

`.github/workflows/deploy.yml`:

- The `test` job is a **per-package matrix**, one job per workspace package, `fail-fast: false`.
  The header comment gives the reason: isolated memory, no OOM on a shared runner.
- The `quality` job is `continue-on-error: true` and writes its output to
  `$GITHUB_STEP_SUMMARY` as Markdown tables. Its comment: *"Drift is surfaced, not enforced."*
- Tests and image builds run **concurrently**; only `deploy` gates on both. The comment spells out
  the safety argument for why this is not a weakening.
- `concurrency: group: deploy-${{ github.ref }}` so two deploys can never race.
- A `changes` job (`dorny/paths-filter`) drives build-vs-retag per image.
- Every non-obvious decision carries an inline comment explaining the incident behind it
  (`provenance: false` because "Lambda requires a plain Docker v2 manifest"; the hotswap fallback;
  the `:latest` promotion happening only *after* a successful deploy).

`scripts/quality-report.mjs` regenerates `.github/badges/quality.json` in the **shields.io endpoint
schema** rather than rewriting the README. `rejected-approaches` records the discarded alternative:
*"Self-editing README badge script — live value instead of automation churning a human-maintained file."*

---

## 3. The agent setup

### 3.1 How `CLAUDE.md` is organized

Section order (from `CLAUDE.md`), which is itself the pattern:

1. **What This Is** — 3 sentences, plus an explicit statement of what is *outside* the repo.
2. **Team knowledge system** — where memories/skills/hooks live, and the instruction
   *"Start Claude sessions in this directory — hooks and memory sync only fire here."*
3. **Monorepo Layout** — an ASCII tree where every entry has a one-line purpose, then a second
   tree for the one subsystem deep enough to need it.
4. **Architecture chapters** — the core model, with tables for anything enumerable
   (event types, value types, priority ordering).
5. **API Endpoints** — highlights only, with the explicit note *"the full route list is the
   `api/` tree itself"* (i.e. it refuses to duplicate what the filesystem already says).
6. **Infrastructure & CI/CD** — a stack table plus the deploy trigger→stage mapping.
7. **Environment Variables** — one table per app: variable | description.
8. **Running Locally** — three commands.
9. **Operations / Gotchas** — ~10 bullets, each a real incident distilled into a rule.
10. **Coding Conventions** — language, naming, comments, git, branching.

Style traits: heavy use of tables; bold lead-ins; the *reason* attached to every rule ("this
silently broke operator login once"); and pointers out to memories/skills rather than inlining them.

### 3.2 `.claude/` contents

```
.claude/settings.json          — hooks only (4 hook events)
.claude/memory/                — 47 memory files + README.md
.claude/skills/                — event-orientation, plan-feature, review-requirements
```

**The memory system** (`.claude/memory/README.md`, `scripts/memory-sync.mjs`) is the standout piece
of infrastructure. `.claude/memory/` in the repo is canonical; `scripts/memory-sync.mjs` is wired to
`SessionStart` and `SessionEnd`:

- `start`: copies repo memories into `~/.claude/projects/<slug>/memory/` and maintains a
  fenced **repo-managed block** in the local `MEMORY.md` index (`<!-- repo-managed:start … -->`),
  so local personal memories outside the block are never touched.
- `end`: detects drift by content hash against a `.repo-sync-state.json`, then pushes changed/added
  files onto a `memory/<user>` branch via a **temporary git worktree**, force-with-lease, and opens
  or updates **one standing PR per developer** with `gh`.
- Skips any file with `private: true` in its frontmatter.
- Fails soft everywhere — offline, no `gh`, no git identity, all exit 0 with a message; proposals
  are retried next session.

The stated rules (`.claude/memory/README.md`): the repo wins; personal memories stay personal;
memory PRs are review material not releases; **no secrets, ever** ("a memory may name where a secret
lives, never its value"); and a fixed file format — frontmatter (`name`, `description`,
`metadata.type` ∈ `feedback` | `project` | `reference`), then the fact + **Why** + **How to apply**,
cross-linked with `[[name]]`.

`.claude/memory/memory-discipline.md` adds the editorial filter — what is memory-worthy
(methodical corrections *with the incident*, rejected approaches *with the reason*, non-derivable
architecture decisions and gotchas) and what is not (session state, anything the repo already
records, secrets, purely personal preferences).

**The skills** are three distinct shapes:

- `event-orientation` — `user-invocable: false`. A pure **reference/vocabulary** skill: an external
  methodology written up as principles + a design checklist, with the source cited.
- `plan-feature` — a **process** skill: 6 numbered steps (feasibility-first against real code →
  design → placement/constraints → work-package slicing → flag uncertainties with fallbacks →
  adversarial self-review), a defined output structure, and a required end state
  (`**PLAN READY FOR REVIEW**`).
- `review-requirements` — a **role** skill ("You are a QA Analyst") with checklists, an output
  template, and a binary verdict (`APPROVED` / `CHANGES REQUESTED`).

All three end by demanding a specific artifact/phrase, which makes them composable.

### 3.3 Conductor

**There is no Conductor configuration in this repo.** `.conductor/` exists at the root but is
empty and untracked (`git ls-files .conductor` → nothing). The workspace copy at
`/Users/timo/conductor/workspaces/tarifrechner-fabrik/da-nang` has no `.conductor/` and no
`settings.toml`; the only extra file there is an empty `.context/todos.md`. So Conductor is used
as a workspace runner here, not configured per-repo — there is **no evidence-backed Conductor
pattern to extract** from this project.

### 3.4 Permissions

`.claude/settings.json` contains **only** `hooks`. No `permissions` block, no allow/deny lists.
Guardrails here are behavioural (hooks + memories), not permission-based.

---

## 4. Conventions

| Area | Practice | Source |
|---|---|---|
| Commits | `type(scope): imperative summary`, lowercase, German umlauts allowed in feature summaries. Types seen: `feat`, `fix`, `chore`, `docs`, `refactor`/`refine`, `revert`, `memory:`, `operations:`. | `git log --oneline -60` |
| Commit authorship | Real developer identity; **no `Co-Authored-By` lines**, no fabricated `-c user.name`. Reason given: a fabricated identity once had to be filter-branch'd out. | `.claude/memory/commit-conventions.md`, `CLAUDE.md` |
| Commit bodies | Non-trivial commits carry a body explaining the *reasoning*, incl. reverts (`16b1301`, `1f6f88b`, `6a060f9`). | `git log` |
| Branching | Trunk-based. Branch fresh off **freshly-fetched** `origin/main` (never local main). One work package = one branch = one PR. Agent pushes and opens the PR; **only the maintainer merges.** | `.claude/memory/trunk-based-workflow.md` |
| Merge gate | "Certified green" = full suite across *all* packages + monorepo typecheck + architecture check — not just the touched package. | same |
| Post-merge | A merged PR is immutable; a late fix gets its own branch off fresh main. | same |
| PR granularity | Situational, explicitly the maintainer's call; two named modes (one-fix-one-PR vs. fat branch with clean commits). Ask when unclear. | same |
| Deploys | Push→CI only. Never mutate infrastructure from a local machine (read-only diagnosis is fine). Ref→stage mapping: `main`→dev, `staging-*` tag→staging, `v*` tag→prod. | `CLAUDE.md`, `.claude/memory/deploy-via-ci.md`, `cdk/SETUP.md` |
| Docs placement | Plan/coordination docs live **outside the repo** — because every push to `main` deploys. | `.claude/skills/plan-feature/SKILL.md`, `trunk-based-workflow.md` |
| Env vars | Documented as tables in `CLAUDE.md`, one per app. Read through the framework's config accessor, never `process.env` directly. A framework-specific prefix requirement is called out as a gotcha *with the incident it caused*. | `CLAUDE.md` § Environment Variables / Gotchas |
| `.env` handling | `.gitignore` has `.env`, `.env.*`, `!.env.example`. `.env.example` is a commented template with placeholder values and inline explanation of which are optional locally. | `.gitignore`, `.env.example` |
| Secrets | Never in the event store, never in memories, never committed. Named location (`~/.secrets` / a manager). CI: temporary admin credentials used once for bootstrap, then **deleted** in favour of OIDC — step 4 of the setup doc is literally "delete those secrets again". | `.claude/memory/secrets-never-in-events.md`, `team-resources.md`, `cdk/SETUP.md` |
| Testing | Vitest, `pnpm -r test`. Bug workflow is test-first: red test that fails *for the right reason*, then the fix. Reproduce at the smallest pure layer. If the rig genuinely can't cover it, **say so in the PR** rather than skipping silently. | `.claude/memory/test-first-for-bugs.md` |
| Type strictness | `strict` + `noUncheckedIndexedAccess` + `verbatimModuleSyntax` in every package tsconfig; measured with `type-coverage --strict`. | `packages/core/tsconfig.json`, `package.json` |
| Comments | Non-obvious **why** only, one line, default to none. Rename instead of commenting. No `FooV2`-style version-suffix names — encode the *reason* in the name. | `.claude/memory/terse-comments-naming.md` |
| Language | All identifiers, schemas, comments and prompts in English; the local language only in UI label catalogues. | `.claude/memory/english-only-code.md`, `CLAUDE.md` |
| Deletion | Do not delete files unprompted — propose and wait. (Concrete case: the superseded `.gitlab-ci.yml` was kept deliberately.) | `.claude/memory/no-premature-delete.md`, `.gitlab-ci.yml` |
| Local dev | Must stay fully runnable offline; never gate local dev behind cloud services. Pattern: a transport/mode switch per external dependency (`MAIL_TRANSPORT=console`, `*_MODE=local`, MinIO for S3). | `.claude/memory/fully-local-offline.md`, `docker-compose.yml` |
| Dependencies | No native modules in the bundle path; no AGPL; no platform-company lock-in for core seams; risky swaps roll out **additively** (new path beside old, switchable); verify third-party pins exist before committing them. | `.claude/memory/dependency-discipline.md` |

Notably **absent**: PR templates, issue templates, CODEOWNERS, a CONTRIBUTING.md, a lint-staged /
husky pre-commit setup, and a conventional-commits enforcer. Commit-time enforcement here happens
via Claude Code hooks, not via git hooks.

---

## 5. Separation table — what carries over

**(a) fully tech-agnostic — drop straight into a template**

| Practice | Source |
|---|---|
| `CLAUDE.md` section skeleton (What This Is → knowledge system → layout tree → architecture → local dev → gotchas → conventions), tables over prose, reason attached to every rule | `CLAUDE.md` |
| `QUALITY.md` shape: measurement date, reproducible commands, scope, **enforcement level per metric**, interpretation of the numbers, tracked follow-ups | `QUALITY.md` |
| The **ratchet allowlist** for architecture exceptions + the "no stale entries" counter-test | `apps/factory/test/architecture.test.ts` |
| Layered enforcement: *enforced* boundary rules vs. *reported* metrics, with "gating can be enabled per metric later" written down | `QUALITY.md`, `deploy.yml` quality job |
| Shared repo-managed agent memory: canonical dir in git, sync on session start, backflow as **memory-only** PRs, `private: true` opt-out, "the repo wins", "no secrets ever" | `.claude/memory/README.md`, `scripts/memory-sync.mjs` |
| Memory file format: frontmatter (`name`, `description`, `metadata.type`) + fact + **Why** + **How to apply** + `[[cross-links]]` | any `.claude/memory/*.md` |
| Memory editorial filter (what is / isn't memory-worthy) | `.claude/memory/memory-discipline.md` |
| A `rejected-approaches` register — the decision **plus the reason**, so it can be re-opened only when the reason lapses | `.claude/memory/rejected-approaches.md` |
| A `spike/<name>/README.md` convention: what was executed, the core proof, fit-to-architecture table, honest costs, recommendation ending in an explicit open decision | `spike/baml/README.md` |
| The three hook archetypes: pre-push cheap gate, edit-time semantic reminder, stop-time "root cause + proving test" gate | `.claude/settings.json`, `scripts/hooks/` |
| Hook craft: cheap shell prefilter before spawning an interpreter; precise command-segment matching; `stop_hook_active` single-nag guard; fail-soft (exit 0) on any parse error | `scripts/hooks/*.mjs`, commit `6a060f9` |
| The deterministic-vs-semantic guardrail split (finite → deterministic check; unbounded → moment-of-change self-check reminder) | commits `1f6f88b`, `16b1301` |
| Trunk-based rules: branch off freshly-fetched trunk, agent opens the PR, only the maintainer merges, "certified green" full-suite gate, merged PR is immutable | `.claude/memory/trunk-based-workflow.md` |
| Commit conventions: real identity, no `Co-Authored-By`, reasoning in the body, `type(scope):` subjects | `.claude/memory/commit-conventions.md`, `git log` |
| Test-first-for-bugs, with "fails for the right reason" and "say so in the PR if untestable" | `.claude/memory/test-first-for-bugs.md` |
| `no-premature-delete` and `root-cause-not-band-aids` as standing agent rules | those memory files |
| `verify-claims-against-artifacts` ("status is a claim, the artifact is the truth") | that memory file |
| `plan-feature` skill shape: feasibility-first, slice by dependency **and** testability, flag uncertain assumptions **with a documented fallback**, adversarial self-review, fixed hand-off phrase | `.claude/skills/plan-feature/SKILL.md` |
| `review-requirements` skill shape: role + checklist + output template + binary verdict | `.claude/skills/review-requirements/SKILL.md` |
| `.env` / `.env.example` discipline (ignore `.env*`, negate the example; example is commented, placeholders only) | `.gitignore`, `.env.example` |
| "Local dev must run fully offline; every external dependency gets a local mode switch" | `.claude/memory/fully-local-offline.md` |
| Dependency-discipline rules (licence check before adoption, no platform lock-in for core seams, additive rollout for risky swaps, verify pins exist) | `.claude/memory/dependency-discipline.md` |
| Terse-comments + meaningful-names rule | `.claude/memory/terse-comments-naming.md` |
| CI: concurrency group per ref, non-blocking quality job writing to the run summary, per-unit test matrix with `fail-fast: false`, inline comments recording the incident behind each odd flag | `.github/workflows/deploy.yml` |
| Badge-as-endpoint-JSON instead of a README-rewriting bot | `scripts/quality-report.mjs`, `rejected-approaches` |
| A one-time `SETUP.md` separated from ongoing automation, ending in "delete the bootstrap credentials" | `cdk/SETUP.md` |

**(b) generalizable in principle, currently TypeScript/pnpm/AWS-specific**

| Concrete thing | Agnostic version for the template |
|---|---|
| `.dependency-cruiser.cjs` | "An **architecture-boundary linter** wired into a `quality`/`arch` task." Ship the *rule set* as language-neutral prose + a stub config: no runtime cycles (allow type-only), a pure-domain rule, libs-must-not-import-apps, deployables-must-not-cross-import, vendor SDK behind a named seam, orphans as warn. Equivalents: import-linter (Python), ArchUnit (Java/Go), `go-arch-lint`, Rust `cargo-deny`+module rules. |
| `tsconfig.arch.json` | "Give the architecture tool a resolution config that maps workspace aliases to **source**, otherwise cross-package edges resolve to installed artifacts and every rule silently passes." Applies to any language with a workspace/alias mechanism. |
| `apps/*/test/architecture.test.ts` (source-text regex tests) | "Rules the import graph can't see get expressed as an **executable test over source text**, run in the normal suite, with a shrink-only ratchet." Portable to any test framework. |
| `eslint.quality.mjs` + SonarJS | "A **separate quality-lint config**, independent of the correctness linter, reporting complexity/duplication. Report-only." Equivalents: ruff/radon, golangci-lint, clippy, PMD. |
| `type-coverage --strict` | "A **strictness metric** for the language's type system (or a `# type: ignore` / `any` census), reported per package with a floor recorded in QUALITY.md." |
| `pnpm-workspace.yaml` + per-package `typecheck`/`test` scripts | "A workspace manifest and a **uniform per-unit task vocabulary** (`test`, `typecheck`, `build`) so CI can matrix over units without knowing what they are." |
| `pnpm arch` / `pnpm quality` script names | Keep the **names** (`arch`, `quality`, `quality:report`) as the template's task contract; the runner behind them is per-stack. |
| `docker-compose.yml` + `db/init.sql` + MinIO/RIE substitutes | "One command brings up the entire stack locally; every cloud dependency has a local substitute container and a `*_MODE=local` switch." Fully agnostic *idea*, container-specific *implementation*. |
| `.github/workflows/deploy.yml` | Keep the **topology**: resolve-ref→stage · changed-paths filter · parallel test matrix · non-blocking quality · build ‖ test with deploy gating on both · concurrency group · promote-only-after-successful-deploy. Drop the ECR/CDK/hotswap specifics. |
| `cdk/` outside the workspace with its own install | "Infrastructure code lives in its own top-level dir with its own dependency manifest, deployed only by CI." |
| OIDC / keyless CI auth | "CI authenticates to the cloud without long-lived stored credentials; bootstrap credentials are temporary and deleted after setup." |
| `scripts/memory-sync.mjs` (Node + `gh`) | The mechanism is agnostic; the implementation is Node + GitHub CLI. For a template: ship it as-is behind a "requires Node + gh" note, or document the protocol so it can be reimplemented. |
| Per-package matrix "because of memory/OOM" | Generalize to "**isolate CI units** so one heavy unit can't starve the others; record the reason inline." |

**(c) project-specific — do not carry over**

- The domain model, event catalogue, pipeline stages, rate/structure types, section roles, and every
  memory of `metadata.type: project` that encodes domain knowledge
  (`structure-modeling-lessons`, `uiconfig-generation-pipeline`, `offer-texts-are-data`,
  `correctness-from-data`, `self-verification`, `artifact-delivery-model`, `postgres-versions`, …).
- All LLM-pipeline-specific practice (`coax-llm-seam`, `llm-roles-and-usage`,
  `prompt-caching-discipline`, `prompts-domain-neutral`, `dont-over-constrain-llm`,
  `bound-llm-output-before-events`, `llm-name-stability`, `preview-confirm-pattern`) — real and
  well-earned, but only relevant to an LLM-pipeline project. The *seam* idea generalizes; the
  contents don't.
- `event-orientation` skill — excellent, but it presumes event sourcing.
- Framework gotchas (`nuxt-runtime-config`, serverAssets resolution, Aurora upgrade procedure,
  SES regionality, CloudFront timeout, DNS negative cache) — the *practice* of keeping a
  "Gotchas" section is (a); these entries are not.
- `.gitlab-ci.yml`, `cdk/SETUP.md` contents, `docker-compose.yml` service list, the specific
  package/app names, badge JSON values, `spike/baml` contents.
- `team-resources` memory (names internal systems) and anything referencing account IDs, hostnames
  or internal ticket prefixes.

---

## 6. Concrete extraction recommendations

What the new-project template should contain, each justified by the evidence above.

### 6.1 Root documents

| File | Content |
|---|---|
| `CLAUDE.md` | Skeleton with the 10 sections from §3.1, each a heading + a one-line instruction of what to write there + a `<!-- -->` example. Include the standing rules that are stack-independent: real-identity commits / no `Co-Authored-By`, no unprompted deletes, root-cause-not-symptom, test-first-for-bugs, terse comments, English identifiers, "start sessions in the repo root so hooks fire". |
| `QUALITY.md` | Template with: measured-on date placeholder, scope statement, an **enforcement-level table** (metric \| how measured \| enforced or reported), empty per-metric sections, a `## Commands` block, and a `## Follow-ups` section. |
| `README.md` | Short: what it is · quality block (badge endpoint JSON, not a rewritten README) · getting started (≤3 commands) · commands table · how deploys are triggered. |
| `.env.example` | Header comment "copy to `.env`, then `<one command>` runs the whole stack locally", placeholders only, optional vars commented out with an explanation. |
| `.gitignore` | Must contain `.env`, `.env.*`, `!.env.example` plus the "generated-except-hand-written" negation pattern shown in this repo's `.gitignore` (a comment explaining why a `.d.ts` is negated). |
| `CONTRIBUTING.md` (new — absent there, worth adding) | The trunk-based rules from §4 as prose, since they currently live only in a memory file. |

### 6.2 Quality skeleton

- `docs/architecture-rules.md` — the six boundary rules written stack-neutrally (§5b row 1), so the
  concrete linter config is a translation exercise.
- A stubbed architecture-linter config for the default stack, with **the `comment`/reason field
  filled in on every rule** — that is what makes the rules survive.
- `test/architecture.<ext>` skeleton demonstrating the **ratchet allowlist + no-stale-entries
  counter-test**, with a comment explaining "removing an entry is welcome, adding one is not."
- A separate quality-lint config (complexity/duplication) kept apart from the correctness linter.
- Task vocabulary in the root manifest: `arch`, `arch:graph`, `quality`, `quality:types`,
  `quality:coverage`, `quality:complexity`, `quality:report`, `typecheck`, `test`.
- `scripts/quality-report.<ext>` writing `.github/badges/quality.json` in shields endpoint schema.

### 6.3 Agent setup

```
.claude/settings.json          # hooks only; no permissions block
.claude/hooks/push-gate.*      # cheap prefilter → fast architecture check before push
.claude/hooks/root-cause-gate.*# Stop gate: source changed, no test touched → ask twice, once
.claude/memory/README.md       # the rules + file format, verbatim-adaptable from the source
.claude/memory/*.md            # seed with the ~12 tech-agnostic memories listed in §5a
scripts/memory-sync.*          # the sync + backflow mechanism
.claude/skills/plan-feature/   # the 6-step process skill, de-domained
.claude/skills/review-requirements/  # the QA-role skill (already generic — near-verbatim)
```

Seed memories worth shipping (all `metadata.type: feedback`, all already domain-neutral in the
source): `commit-conventions`, `trunk-based-workflow`, `memory-discipline`, `test-first-for-bugs`,
`root-cause-not-band-aids`, `no-premature-delete`, `plan-discipline`, `verify-claims-against-artifacts`,
`steering-signals`, `dependency-discipline`, `terse-comments-naming`, `fully-local-offline`,
plus an empty `rejected-approaches` register. Each needs a light pass to strip the project-specific
incidents from the **Why** paragraphs — though keeping *a* concrete incident is what gives these
files their force, so the template should instruct users to add theirs rather than delete the field.

`.claude/skills/review-requirements/SKILL.md` is copy-ready as written — it contains no project
specifics.

### 6.4 CI skeleton

A single workflow with the jobs `resolve` (ref→stage) · `changes` (paths filter) · `test` (matrix
over units, `fail-fast: false`) · `quality` (`continue-on-error: true`, writes to the step summary)
· `deploy` (gates on test **and** build), plus `concurrency: group: <name>-${{ github.ref }}`.
Keep the source's habit of an inline comment on every non-obvious flag stating the incident.

### 6.5 Conventions to state explicitly in the template

- Enforcement is layered and the layer is written down: **enforced** (boundaries), **reported**
  (metrics), **reminded** (semantic hooks). Promotion between layers is a deliberate decision.
- Finite/unambiguous → deterministic check. Unbounded/semantic → moment-of-change self-check.
  Never a denylist for an open vocabulary.
- Exceptions are ratchets: shrink-only, with a test that fails when an entry goes stale.
- Local dev runs offline; every cloud dependency gets a local substitute and a mode switch.
- Plans/coordination docs live where they don't trigger a pipeline.
- Bootstrap credentials are temporary and deleted; ongoing CI auth is keyless.

### 6.6 What the template should *not* claim to provide

There is no Conductor configuration to copy (§3.3), no permissions policy (§3.4), and no git-level
pre-commit hooks — commit-time enforcement in this project is entirely Claude Code hooks. If the
template wants git hooks, that is a new decision, not an extraction.
