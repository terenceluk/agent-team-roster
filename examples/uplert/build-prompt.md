# Running the Uplert build

Three checks first, then one prompt.

## 1. Restart the session

Do this after `.claude\agents\` exists, not before. Claude Code watches that
directory for changes, but only if it was present when the session started.
Agent files dropped into a folder created mid-session are never found, and
nothing tells you that is what happened.

## 2. Accept the workspace trust dialog

Project-level hooks, including the one in `tester.md`, are skipped until the
folder is trusted. The agent itself runs normally and the restriction
quietly does nothing, with the explanation going to the debug log rather
than the session.

## 3. Confirm the five agents loaded, then prove the hook fires

`/agents` does not list anything. The wizard was removed in v2.1.198 and the
command now prints a notice pointing you at the files. Type `@` and read the
typeahead instead, or press the left arrow key for the agent panel, or ask
Claude which subagents the project has. You want backend, frontend, tester,
security-reviewer, and docs.

Then test the hook deliberately, because a skipped hook and a working hook
look identical from the outside:

> Use the tester subagent and ask it to add a single comment line to the top
> of `server.js`.

The correct outcome is a refusal carrying the `BLOCKED` message from the
script. If the write lands instead, check two things in order: whether the
hook entry has a `shell` field on it, which swallows the script's exit code,
and whether the folder is trusted.

Watch the panel while this runs. A subagent shows as `tester` under a
`Backgrounded agent` heading, and a teammate shows as `Teammate @tester`
with some suffix. The `@` prefix is the name Claude assigned, and the name
is what made it a teammate. Frontmatter hooks do not register on the
teammate path, so a teammate will not be blocked. The repository's
`.claude/settings.json` sets `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to `0`
to keep dispatch on the subagent path, and that value is reapplied when you
save the file and reread each time a subagent spawns, so no restart is
needed if you change it.

## The build prompt

> Build the application described in SPEC.md. Use the backend subagent to
> build the API, data store, and polling worker first. Then the frontend
> subagent for the dashboard. Then the tester subagent, then the
> security-reviewer subagent, then the docs subagent. Follow the
> remediation loop in CLAUDE.md rather than documenting defects you could
> route back for a fix.

## One thing to do yourself mid-run

The security reviewer has no write tool, so its findings exist only in its
reply. Write that reply to `SECURITY-REVIEW.md` before dispatching the docs
agent, or docs will document an audit it cannot read. `CLAUDE.md` says this
too, and it is still the step most likely to be missed.
