# agent-team-roster

A reusable five-agent Claude Code roster for building an application of any
kind, split by codebase layer rather than by business function. Drop it into
an empty project, write one `SPEC.md`, and run it.

This is the generalized version of the Waypoint roster from the
[subagent relay vs. agent teams](https://blog.terenceluk.com/2026/07/subagent-relay.html)
post. That version deliberately baked one specific application into the
agent files so three rounds would get a byte-identical brief. This one does
the opposite, which is what makes it reusable.

## The idea

Three kinds of fact, three different homes:

| Kind of fact | Example | Lives in |
|---|---|---|
| **Role** | "The tester may only write under `tests/`" | `.claude/agents/*.md` |
| **Application** | "A pin has a latitude, longitude, and visit date" | `SPEC.md` |
| **Process** | "Route test failures back to the owning layer" | `CLAUDE.md` |

The five agent files never change between projects. `SPEC.md` is the only
file you write per application.

## Contents

```
agent-team-roster/
├── README.md                       this file
├── LICENSE                         MIT
├── SPEC.template.md                copy to the target project as SPEC.md
├── CLAUDE.md                       copy to the target project root
├── .claude/
│   ├── agents/
│   │   ├── backend.md              server-side code, publishes API.md
│   │   ├── frontend.md             client-side code, reads API.md
│   │   ├── tester.md               tests/ only, hook-enforced
│   │   ├── security-reviewer.md    read-only by tool grant
│   │   └── docs.md                 markdown only
│   ├── hooks/
│   │   └── restrict-to-tests.ps1   blocks tester writes outside tests/
│   └── settings.json               agent teams off, so hooks register
└── examples/
    └── uplert/                     a worked SPEC.md and what it produced
        ├── README.md
        ├── SPEC.md
        └── build-prompt.md
```

## Setup

Clone the repository, then copy three things into the project you want
built:

```bash
git clone https://github.com/terenceluk/agent-team-roster.git
cp -r agent-team-roster/.claude /path/to/your-project/
cp agent-team-roster/CLAUDE.md /path/to/your-project/
cp agent-team-roster/SPEC.template.md /path/to/your-project/SPEC.md
```

On Windows:

```powershell
git clone https://github.com/terenceluk/agent-team-roster.git
xcopy /E /I "agent-team-roster\.claude" "C:\your-project\.claude"
copy "agent-team-roster\CLAUDE.md" "C:\your-project\"
copy "agent-team-roster\SPEC.template.md" "C:\your-project\SPEC.md"
```

Fill in `SPEC.md`. That is the whole per-project setup.

`.claude/settings.json` carries one value, which turns agent teams off. It
is there because frontmatter hooks do not register for teammates, so the
tester's restriction is only enforced on the subagent dispatch path. See
Known gaps below for the detail, and the agent team section below if you
want to turn it back on deliberately.

See [`examples/uplert/`](examples/uplert/) for a filled-in `SPEC.md` and
what the build it produced actually looked like.

Two things to know before the first run:

- **Restart the session after creating `.claude/agents/` for the first
  time.** Claude Code watches that directory for changes, but only if it
  existed when the session started.
- **Accept the workspace trust dialog for the project folder.** The
  tester's `PreToolUse` hook is project-level, and until you trust the
  folder, hooks are silently skipped. The agent runs fine and the
  restriction quietly does nothing.
- **`/agents` no longer lists anything.** The wizard was removed in
  v2.1.198 and the command now prints a notice pointing you at the files.
  To confirm the five definitions loaded, type `@` and read the typeahead,
  press the left arrow key for the agent panel, or ask Claude directly.

## Running it

Three ways, in increasing order of cost and capability.

### Sequential relay

Simplest, and correct when the layers genuinely depend on each other.

> Build the application described in SPEC.md. Use the backend subagent to
> build the API and data store first. Then the frontend subagent for the
> interface. Then the tester subagent, then the security-reviewer subagent,
> then the docs subagent. Follow the remediation loop in CLAUDE.md rather
> than documenting defects you could route back for a fix.

### Parallel dispatch

Backend and frontend in the same turn. Faster to build, but they cannot
talk to each other, so the frontend works from `API.md` or from disclosed
guesses. Worth it when most of the frontend work does not depend on the
API, and a false economy when it does.

> Build the application described in SPEC.md. Dispatch the backend and
> frontend subagents together in the same turn. Backend publishes API.md
> early, before polishing. Frontend builds everything that does not depend
> on the server and records any contract guess in FRONTEND-ASSUMPTIONS.md.
> Once both report done, run the tester, then the security-reviewer, then
> docs, following the remediation loop in CLAUDE.md.

### Agent team

Teammates message each other directly and self-claim from a shared task
list. Experimental, and the most expensive of the three.

Enable it first, by changing the value this repository ships in
`.claude/settings.json` from `"0"` to `"1"`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or per session, in PowerShell:

```powershell
$env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"
```

No restart is needed either way. Claude Code reapplies settings-file `env`
values to the running session when you save, and rereads the variable each
time it spawns a subagent. Know what you are giving up before you flip it:
on this path the tester's hook never registers, so its restriction drops
back to a prompt-level instruction.

Then:

> Spawn a team of five to build the application described in SPEC.md, named
> backend, frontend, tester, security-reviewer, and docs, each using the
> agent type of the same name. Read each agent's definition file before
> writing its task, so no task contradicts its own agent's constraints.
> Express ordering as task dependencies rather than by holding teammates
> back: backend and frontend start immediately and run in parallel, tester
> and security-reviewer both depend on backend and frontend completing, and
> docs depends on tester and security-reviewer. Have frontend message
> backend directly to confirm any route, field name, or authentication
> detail rather than guessing. Follow the remediation loop in CLAUDE.md.

Shut the team down when it finishes. Idle teammates keep consuming tokens
until they exit.

> Ask the backend, frontend, tester, security-reviewer, and docs teammates
> to shut down.

## What each restriction actually is

Worth knowing which boundaries the runtime enforces and which are requests
to a cooperative agent, because they fail differently:

| Agent | Restriction | Kind |
|---|---|---|
| `security-reviewer` | Cannot write anything | **Enforced.** No write tool, no shell. Nothing to circumvent. |
| `tester` | Cannot write outside `tests/` | **Enforced as a subagent,** via the `PreToolUse` hook. **An instruction as a teammate,** because frontmatter hooks do not register on that path. |
| `frontend` | Cannot touch server-side files | **An instruction.** Prompt-level only. |
| `docs` | Markdown only | **An instruction.** Prompt-level only. |

The `tools:` allowlist is the mechanism behind the enforced ones, and it is
an allowlist rather than a denylist on purpose: an allowlist excludes
everything you did not think of, a denylist excludes only what you did. Note that `Bash` and
`PowerShell` are separate tools, so denying one leaves the other open. A
shell is as capable of overwriting a file as `Write` is.

## Known gaps

- **Test the hook before trusting it.** The frontmatter `hooks:` block in
  `tester.md` matches the documented shape, and it only fires once you have
  accepted the workspace trust dialog for the project folder. Until then
  the agent runs normally while its hooks are skipped, and the explanation
  goes to the debug log. Verify by asking the tester to write a file
  outside `tests/` and confirming it is refused. A silently skipped hook
  looks exactly like a working one.
- **Frontmatter hooks do not apply to agent teams teammates.** Verified by
  running the same probe on both paths. Dispatched as a subagent, the hook
  registers and denies. Spawned as a teammate, no registration line appears
  at all and the write lands unopposed. The tester's boundary is therefore
  a guardrail as a subagent and an instruction as a teammate. To enforce it
  in a team, move the hook to `.claude/settings.json` and have the script read
  `agent_type` from the payload, exiting 0 for every agent but the tester.
- **Do not set `shell: powershell` on the hook entry.** It wraps the
  command in a PowerShell host, which does not pass a native command's exit
  code through as its own, so the script exits 2, the wrapper exits 1, and
  Claude Code treats that as a non-blocking error and writes the file. The
  hook fires, prints its block message, and stops nothing. The entry here
  omits `shell` and keeps `; exit $LASTEXITCODE` on the command as
  insurance for machines with no Git Bash, where the default falls back to
  PowerShell. Grep the debug log for `Hook denied tool use` to confirm.
- **Only the tester's boundary is enforced.** The frontend and docs
  restrictions are still prompt-level. The same hook pattern extends to
  them if you want those enforced too.
- **The security reviewer cannot run anything.** It reads code and reasons
  about it, which produces a code review rather than a penetration test.
  Every finding needs a human to confirm.
- **No CI integration.** The remediation loop lives in `CLAUDE.md` as an
  instruction to the lead session, not in a pipeline that enforces it.
