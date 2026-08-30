# Part 2 — Boundaries

Make the structure from [architecture.md](./architecture.md) enforceable. A folder that merely
*looks* like a boundary is decoration.

---

## 2.1 Wire enforcement

Add a command that fails when a boundary is crossed. It must forbid all four:

| # | Forbidden | Why |
|---|---|---|
| 1 | Importing anything inside a module other than its public entry file | Otherwise the module's internals become everyone's dependency |
| 2 | Importing one slice from another slice | This is the coupling the style exists to remove |
| 3 | Dependency cycles | A cycle means the boundary was never real |
| 4 | Any mutating operation on the event log | AQ-over-CRUD is absolute |

Use the mechanism found in Step 0. Where the language has real privacy, prefer it — a compiler
error is cheaper and faster than a linter. Where it does not, an import-lint rule is the fallback.

Write the rules **structurally**, not per module. Adding a second module later must not require a
config change. If it does, the rules were written as a list of known names instead of a shape.

Give each rule a message that names what was violated and why it matters — not just "forbidden
import". The person who trips it is usually not the person who wrote the rule.

**Done when:** the command exists and covers all four.

---

## 2.2 Prove the rules bite

**This is the completion criterion for the whole setup skill.** A rule that cannot fail is
worthless.

For each of the four rules, in turn:

1. Run the boundary command. It must **pass**.
2. Add the violation on purpose — a deep import into a module, a slice-to-slice import, a cycle, a
   delete against the log.
3. Run again. It must **fail**, and the message must name the rule.
4. Revert. Run again. It must **pass**.

If any violation does not fail, the rule is not wired up. Fix it before continuing.

### The silent pass

The most common failure is not a rule that is too loose. It is a rule that matches **nothing** and
therefore reports success.

Usual cause: the analyser cannot resolve cross-module import paths, so it never sees the imports it
was supposed to reject. Everything is green, forever, no matter what anyone writes.

This is why step 2 above is not optional. A green check that can never go red tells you nothing.
Confirm the tool actually resolved the imports it rejected.

### Exceptions

If a rule needs an exception, add it to an explicit allowlist rather than loosening the rule.

Then make the allowlist a **ratchet**: entries may be removed but never added without a deliberate
decision, and a test asserts that every entry is still necessary. An exception that has quietly
become unnecessary is the one that lets the next real violation through.

**Done when:** you have observed pass → fail → pass for **each** of the four rules, and have shown
the user the failing output.

Next: [verification.md](./verification.md).
