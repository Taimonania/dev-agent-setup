# Step 2 — Boundaries

Make Step 1 enforceable. A folder that merely looks like a boundary is decoration.

---

## 2.1 Wire the rules

A command that fails when a boundary is crossed. Four rules:

| # | Forbidden |
|---|---|
| 1 | Importing anything inside a module other than its public entry file |
| 2 | Importing one slice from another slice |
| 3 | Dependency cycles |
| 4 | Any mutating operation on the event log |

Use the mechanism from Step 0. Prefer real language privacy over a linter — a compiler error is
cheaper and faster.

Write the rules **structurally**, not per module: adding a second module later must not require a
config change. If it would, they were written as a list of known names instead of a shape.

Each rule's message names the failure mode it prevents. This is where the reasoning lives, since
nothing else in the project will carry it.

Exceptions go in an allowlist, never by loosening a rule — and the allowlist is a **ratchet**:
entries come out, they do not go in, and a test asserts each remaining one is still needed. An
exception that quietly became unnecessary is what lets the next real violation through.

**Done when:** the command exists and covers all four.

---

## 2.2 Prove they bite

**This is the completion criterion for setup.** A rule that cannot fail is worthless.

For each of the four, in turn:

1. Run the command. It must **pass**.
2. Add the violation on purpose.
3. Run again. It must **fail**, naming the rule.
4. Revert. Run again. It must **pass**.

### The silent pass

The common failure is not a loose rule. It is a rule that matches **nothing** and reports success —
usually because the analyser cannot resolve cross-module import paths, so it never sees what it was
meant to reject. Everything is green forever, whatever anyone writes.

Confirm the tool actually resolved the imports it rejected. A green check that can never go red
tells you nothing.

**Done when:** you have shown the user pass → fail → pass for **each** of the four rules.
