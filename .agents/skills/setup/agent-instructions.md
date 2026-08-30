# Part 4 — Agent instructions

Tell agents what they need to know, once, in the place they actually read.

Run this last: it describes what Parts 1–3 produced.

---

## 4.1 Write the source README

Write a short README **next to the modules**, not in a docs folder. It covers:

- the module / slice / event-log layout,
- "import only a module's public entry file",
- the two log operations and the absence of any third,
- how to run the boundary command and the umbrella command,
- the copy-me slice from Part 1.

Keep it to a copy-me snippet plus a paragraph per rule. This file is read at the moment someone adds
a module, so it must be skimmable.

**Done when:** the README exists next to the source root.

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
| A pointer to the source README | The layout the README already describes |
| Rules that change what an agent does | Rules that restate the linter |

---

## 4.3 Add the pointer

One line in `AGENTS.md`, pointing at the README from 4.1:

```
Code is event-sourced vertical slices: see <root>/README.md before adding a module, slice, or event.
```

This pointer is what makes an agent **discover** the rule instead of tripping over it. The rule
itself stays in the README.

The same principle applies to every later doc: content in the doc, one pointer in `AGENTS.md`.
Copying the content into both guarantees they disagree within a month, and nobody will know which
one is current.

**Done when:** `AGENTS.md` exists, `CLAUDE.md` imports it, and the pointer resolves to a file that
exists.

---

## 4.4 Check it back

Read `AGENTS.md` as if you had never seen the project.

- Is every pointer a real path?
- Is there anything here an agent would not act on differently for having read it? Cut it.
- Is there a rule you learned during setup that is not written down anywhere?

**Done when:** every pointer resolves and nothing in the file is decorative.
