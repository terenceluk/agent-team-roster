# SPEC.md

Copy this file into the target project as `SPEC.md` and fill it in. Every
agent in the roster reads it as the source of truth. This is the only file
you rewrite per application; the five agent definitions never change.

Delete any section that genuinely does not apply, rather than leaving it
empty. An empty section reads as "not decided yet" and agents will ask.

---

## What this application is

One paragraph, plain language. What it does and who it is for.

## Users and roles

- Who uses it
- What roles exist, if any, and what each one can do that the others cannot
- If there is exactly one kind of user and no privileged role, say so
  explicitly so the tester and security reviewer skip role boundaries
  rather than inventing them

## Core behaviors

Numbered list. One line per user-visible action. This is what the tester
builds its happy-path coverage from, so be specific about the actions and
vague about the implementation.

1.
2.
3.

## Data

What the application stores, and the shape of each thing it stores.

For each: what fields it has, who owns it, and who is allowed to see it.
Ownership is what the security reviewer audits against, so state it even
when it feels obvious.

## Stack constraints

The constraints the backend and frontend agents must satisfy. Leave a line
out entirely if you genuinely do not care, and the agent will choose.

- **Runtime / language:**
- **Data store:**
- **Deployment target:**
- **Must run without:** (e.g. Docker, internet access, paid API keys,
  anything requiring signup)
- **Must run on:** (e.g. Windows 11 natively, Linux container, Azure App
  Service)
- **Allowed dependencies:** (e.g. "standard library plus one web framework",
  or "anything on npm", or leave out for no constraint)

## Non-goals

What this explicitly does not do. This is the cheapest section to write and
it prevents the most scope drift.

## Known limitations of the environment

Anything about how this will actually run that the security reviewer should
treat as a known constraint rather than a finding.

Be precise if you are running locally over plain HTTP. Browsers treat
localhost as a secure context, so Secure cookies and anything else gated on
a secure origin still behave normally. What genuinely cannot be exercised
is anything depending on a real TLS connection, such as certificate
validation and HSTS. Say which of the two you mean, because "no HTTPS
locally" on its own invites the reviewer to file findings that are not
real.
