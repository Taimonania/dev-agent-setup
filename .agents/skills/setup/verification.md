# Part 3 — Verification

One command that tells you whether the project is sound. Agents and CI both run it; neither should
have to guess which of five commands matters.

---

## 3.1 The umbrella command

**Discover the repo's existing convention before adding anything.** Several vendored skills look for
the project's automated checks rather than assuming a name — `implement` runs typechecking and the
test suite, `resolving-merge-conflicts` discovers the checks and runs them. If a command already
plays this role, extend it. Do not add a second one beside it.

If none exists, add one. Name it whatever this ecosystem calls it — `check`, `ci`, `validate`,
`verify`, a `Makefile` target, a task-runner entry. The name does not matter. Having exactly one
does.

It must run, in this order, failing fast:

| Order | Stage | Why first |
|---|---|---|
| 1 | Typecheck or compile | Cheapest, catches the most |
| 2 | Boundary rules (Part 2) | Structural, fast, no test setup needed |
| 3 | Tests | Slowest |
| 4 | Format check | Last, and only as a check — never a rewrite inside verification |

**Done when:** one documented command runs all four, and a failure in any stage fails the command.

---

## 3.2 Make it the same command everywhere

The command a developer runs locally, the command an agent runs before opening a pull request, and
the command CI runs must be **the same command**. Not equivalent — the same.

Three copies of "roughly the checks" drift apart, and the drift is always discovered at the worst
moment. If CI needs extra stages (coverage upload, deployment gates), CI calls the umbrella command
and then does the extra work, rather than reimplementing it.

**Done when:** the CI config invokes the umbrella command by name and adds nothing that duplicates
it.

---

## 3.3 Decide what gates and what only reports

Not everything worth measuring is worth blocking on. Split them deliberately, and write down which
is which:

| Level | Meaning | Examples |
|---|---|---|
| **Enforced** | Fails the command. Non-negotiable. | Typecheck, boundary rules, tests |
| **Reported** | Printed, tracked, never blocks | Coverage, complexity, bundle size |
| **Reminded** | A prompt at the moment of change | Anything unbounded or semantic |

The distinction matters most for the third. A finite, unambiguous rule gets a deterministic check.
An unbounded or semantic one — "did this leak something sensitive?" — cannot be enumerated, because
any list-based check only knows about past leaks. Those get a reminder at the moment of change, not
a rule that gives false confidence.

Start with a small enforced set. Promoting a reported metric to enforced later is easy; demoting an
enforced one after it has blocked people is political.

**Done when:** each check has a stated level, and the enforced set is small enough that a green run
is believed.

Next: [agent-instructions.md](./agent-instructions.md).
