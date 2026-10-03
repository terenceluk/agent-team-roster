# Example: Uplert

Uplert is a personal uptime monitor. A signed-in user registers HTTP
endpoints to be polled on a schedule and sees whether each one is up, how
often it has been up recently, and how quickly it responds.

It exists here as a worked example of the only file you write per project.
The five agent files and `CLAUDE.md` in the repository root were used
unedited to build it.

## Why this application

The roster it came from was built for Waypoint, a travel journal that stores
pins and visit dates. Waypoint runs with no outbound network access at all,
which was one of its explicit environment constraints.

Uplert inverts that. Polling remote endpoints is the entire point of the
application, so outbound HTTP is a requirement rather than a prohibition.
Picking an application whose network requirements are the opposite of the
original was deliberate: if any network assumption had survived the
generalization, this spec would have surfaced it.

## What is in this folder

| File | What it is |
|---|---|
| `SPEC.md` | The spec, copied to the target project root unchanged |
| `build-prompt.md` | The dispatch prompt, and the three setup checks before it |

Nothing else. The built application is not published here, because a reader
wants the input that produced it rather than generated code to read as a
reference implementation.

## Running it

```bash
mkdir ~/uplert && cd ~/uplert
cp -r /path/to/agent-team-roster/.claude .
cp /path/to/agent-team-roster/CLAUDE.md .
cp /path/to/agent-team-roster/examples/uplert/SPEC.md .
```

On Windows:

```powershell
mkdir C:\Claude\uplert
xcopy /E /I "agent-team-roster\.claude" "C:\Claude\uplert\.claude"
copy "agent-team-roster\CLAUDE.md" "C:\Claude\uplert\"
copy "agent-team-roster\examples\uplert\SPEC.md" "C:\Claude\uplert\"
```

Then work through `build-prompt.md`. The three setup checks there matter
more than they look, because two of the three fail quietly.

## What the run produced

Recorded here so you have something to compare against, not as a target to
hit. A different model version or a different interpretation of the same
spec will land somewhere else.

| | |
|---|---|
| Elapsed time | 1 hour 5 minutes |
| Tests at first report | 111, with two real failures |
| Tests at completion | 139, all passing |
| Split | 99 integration, 40 unit |
| Defects routed back and fixed | 9, across two full rounds |
| Items left open as accepted risks | 5, each with the reasoning written down |

None of the nine defects was written up as a known limitation instead of
being fixed, which is the specific failure the remediation loop in
`CLAUDE.md` exists to prevent.

`FRONTEND-ASSUMPTIONS.md` was never created. The sequential relay was used
rather than parallel dispatch, so the frontend read a finished `API.md` and
had no contract guesses to record. The file is only load-bearing on the
parallel path.

## Where the walkthrough is

The full build, including every dispatch, the defect table, and the agent
panel at each stage, is written up at
[blog.terenceluk.com](https://blog.terenceluk.com).
