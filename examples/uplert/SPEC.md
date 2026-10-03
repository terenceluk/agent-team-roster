# SPEC.md

## What this application is

Uplert is a personal uptime monitor. A signed-in user registers HTTP
endpoints to be polled on a schedule, and sees whether each one is up,
how often it has been up recently, and how quickly it responds.

## Users and roles

- **Registered user**: creates and deletes their own checks, views their
  own results. Cannot see any other user's checks or results.
- **Administrator**: additionally lists every registered user and how many
  checks each one has. Cannot view another user's check results.

## Core behaviors

1. Register an account and sign in.
2. Add a check: a URL, a display name, and a polling interval.
3. A background worker polls every due check and records the status code,
   the response time in milliseconds, and a timestamp.
4. View a dashboard of the signed-in user's checks with current state,
   uptime percentage over the last 24 hours, and recent response times.
5. Delete a check, which also removes its history.
6. An administrator lists every registered user and their check count.

## Data

- **User**: email, password credential, role, created timestamp. Owned by
  itself.
- **Check**: owner, URL, display name, interval in seconds, enabled flag.
  Owned by the user who created it, visible to nobody else.
- **Result**: check, status code, response time, timestamp. Inherits the
  owner of its check.

## Stack constraints

- **Runtime / language:** Node or Python, either is fine
- **Data store:** SQLite, created on first run
- **Deployment target:** runs locally with one command
- **Must run without:** Docker, WSL, any paid or signup-gated service
- **Requires:** outbound HTTP access, because polling remote endpoints is
  the application

## Non-goals

Alerting is the obvious next thing to build and is deliberately out of scope
here, so no email or webhook notifications in this version. Also no status
page shared with anyone outside the account, and no scheduled report exports.

## Known limitations of the environment

Served over plain HTTP on localhost. Browsers treat localhost as a secure
context, so Secure cookies and anything else gated on a secure origin still
behave normally. What cannot be exercised here is anything depending on a
real TLS connection, including certificate validation and HSTS, so treat
those as out of scope rather than as findings.
