# CLAUDE.md

This file holds the rules that govern how the five-agent roster works
together, separate from what the application does. It sits at the project
root alongside `SPEC.md`.

Rule of thumb for what goes where:

- **What the application is** goes in `SPEC.md`
- **How the team works** goes here
- **What each role does** is already in `.claude/agents/`, and does not
  change per project

---

## The roster

Five agents in `.claude/agents/`, split by codebase layer:

| Agent | Owns | Write access |
|---|---|---|
| `backend` | Server-side code, data store, `API.md` | Full |
| `frontend` | Client-side code only | Full, but never server-side files |
| `tester` | `tests/` only | Enforced by hook |
| `security-reviewer` | Nothing | None, by tool grant |
| `docs` | `README.md`, `CHANGELOG.md`, `docs/` | By instruction |

## File ownership

Assign ownership explicitly before dispatching anything, so two agents
never edit the same file. When a file needs to change and its owner is not
the agent that needs the change, route the change through the owner rather
than letting the other agent reach across the line.

The shared package manifest is the usual collision point. Decide up front
who owns it, and have everyone else request changes to it.

## Contract artifacts

These files are the pipeline's connective tissue. Their paths are fixed
because agents read them by name.

| File | Written by | Read by |
|---|---|---|
| `SPEC.md` | You | Everyone |
| `API.md` | `backend` | `frontend`, `tester`, `docs` |
| `SECURITY-REVIEW.md` | **The lead session** | `docs` |
| `FRONTEND-ASSUMPTIONS.md` | `frontend` | The lead, `tester`, `docs` |

`SECURITY-REVIEW.md` is the one that needs your attention. The
security-reviewer has no write tool by design, so its findings exist only
in its reply. **The lead session must write that reply to
`SECURITY-REVIEW.md` before dispatching the docs agent**, or the docs agent
will document an audit it cannot read.

## The remediation loop

The default pipeline is a straight line: build, test, audit, document.
A straight line has no way to act on what the tester and the auditor find,
which means real defects get written up as known limitations instead of
fixed. Do not run it that way.

When the tester reports a failure or the security reviewer reports a
finding worth acting on:

1. Confirm it independently before acting. An agent's report is a claim,
   not a verdict. Read the file yourself.
2. Route it back to the agent that owns the affected layer as new work.
3. Stage the tester's re-verification behind that fix.
4. Hold the docs agent until both land.
5. Confirm the fix was applied to every path sharing the defect, not just
   the one the test happened to exercise. A half-applied fix to a shared
   validator is worse than no fix.

Not everything has to be fixed. A debatable judgment call can stay open and
documented, on the owning agent's reasoning. What must not happen is a
defect getting quietly downgraded to a limitation because the pipeline had
nowhere to send it.

## Verifying agent reports

Treat every agent's self-report as a claim requiring confirmation:

- Re-run the test suite yourself before believing a pass count
- Grep for what an agent says it removed, before believing it removed it
- Spot-check the highest-severity security findings against the actual file
- Check any number that appears in two places against both

The security reviewer in particular cannot run the application, so
everything it produces is a code review rather than a proven exploit.
Findings from it need a human in the loop before they are treated as fact.

## Writing task instructions

Read an agent's definition file before writing a task for it. The most
common orchestration failure is a task instruction that contradicts the
agent's own constraints, or that asks an agent for something its tool grant
makes impossible, such as asking the read-only reviewer to create a file.

When you do have to correct a task mid-run, issue the correction as an
unambiguous directive with concrete acceptance criteria, not as a
discussion. Reversals framed conversationally get read as commentary and
ignored. Then update every task that carries the stale instruction, not
just the one you were looking at.

## Project-specific rules

<!-- Add anything here that applies to this project and is not in SPEC.md.
     Coding conventions, branch rules, deployment gotchas. -->
