# Part 4 — Agent instructions

Tell agents what they need to know, once, in the place they actually read.

Run this last: it describes what Parts 1–3 produced.

---

## 4.1 Do not write a layout README

**The code is the source of truth.** Write no document describing the structure Parts 1–3 produced.

Everything such a document would say already exists somewhere executable, where it cannot drift:

| Would-be doc content | Already lives in |
|---|---|
| The module / slice / event-log layout | The folders themselves |
| "Import only a module's public entry file" | Boundary rule 1. The config **is** code. |
| The two log operations, and the absence of a third | The log's interface. You cannot call an operation that does not exist. |
| How to run the checks | The manifest or task runner |
| A copy-me slice | The real slice from Part 1.4 — tested, therefore correct, therefore better |

A prose copy of an enforced rule is strictly worse than the rule: it can disagree with it, and when
it does, a reader has no way to tell which one is current.

### Put the *why* in the rule, not in a document

The one thing code carries badly is the reason a rule exists. So put it there rather than writing a
document to hold it:

- Each boundary rule carries a message naming the failure mode it prevents (Part 2.1).
- Each event type's definition says what real-world fact it records.
- The example slice is the worked answer to "how do I write one of these".

### What genuinely is not enforceable

Some things resist enforcement — name modules after concepts not techniques; duplicate shape freely
but extract a pure function on the third occurrence. These are judgements, not rules.

They live in the `vertical-slices` and `event-orientation` skills, which are already in the repo and
already versioned. **Do not restate them per project.** A local copy is one more thing to disagree
with the original.

**Done when:** no structural README was written, and every rule from Parts 1–3 is either enforced or
carried by a skill.

---

## 4.2 Write `AGENTS.md`

`AGENTS.md` holds the content. `CLAUDE.md` is a single line:

```
@AGENTS.md
```

That import is Claude Code's documented interop, and it means one file to maintain instead of two
that drift.

**Keep `AGENTS.md` short.** It holds pointers, plus the few rules that actually change behaviour.
It is not an architecture overview and not a directory listing — Anthropic's own `/doctor` trim
strips exactly that kind of content out. Long instruction files are skimmed, and the one rule that
mattered is the one that gets skimmed past.

What earns a place:

| Include | Leave out |
|---|---|
| The default architecture, in two lines | An explanation of event sourcing |
| The umbrella command's name | The list of what it runs |
| A pointer to the example slice | The layout the folders already show |
| Rules that change what an agent does | Rules that restate the linter |

---

## 4.3 Point at code, not at prose

`AGENTS.md` needs to say where to look. Point at the artifacts themselves — each one is executable,
so a stale pointer is a broken path rather than a quiet lie.

Two or three lines is the whole of it:

```
Code is event-sourced vertical slices. Copy <path to the example slice> when adding one.
Boundary rules and the reasons for them: <path to the boundary config>.
Run <umbrella command> before opening a pull request.
```

This is what makes an agent **discover** the rules instead of tripping over them. The rules stay
where they are enforced.

**Never copy a rule into `AGENTS.md` that is already enforced.** The copy will drift, and a reader
who spots the disagreement has no way to tell which one is current. Point at the enforcement; let
the failure message do the teaching.

**Done when:** `AGENTS.md` exists, `CLAUDE.md` imports it, and every pointer resolves to a file that
exists.

---

## 4.4 Check it back

Read `AGENTS.md` as if you had never seen the project.

- Is every pointer a real path?
- Is there anything here an agent would not act on differently for having read it? Cut it.
- Is anything here already enforced by a rule? Cut it and point at the rule.
- Is there a judgement you made during setup that no rule and no skill captures? That is the only
  thing worth adding.

**Done when:** every pointer resolves and nothing in the file is decorative.
