# restrict-to-tests.ps1
#
# PreToolUse hook for the tester agent. Blocks any Write/Edit whose target
# falls outside the project's own tests/ directory, turning the tester's
# prompt-level restriction into an enforced one.
#
# Wired up via the `hooks:` block in .claude/agents/tester.md so it applies
# to that agent only. Do NOT move this into settings.json unmodified: there
# it would apply to every agent in the project and block the backend and
# frontend agents from writing anything.
#
# Exit codes matter here:
#   0 - allow the tool call
#   2 - BLOCK the tool call and return stderr to the agent
#   1 - non-blocking error, so the write proceeds anyway. Never use 1 to deny.
#
# Written for Windows PowerShell 5.1, which is on every Windows machine, so
# it avoids .NET Core only helpers such as Path.GetRelativePath.

$input_json = [Console]::In.ReadToEnd()

if ([string]::IsNullOrWhiteSpace($input_json)) {
    # Nothing to inspect. Fail open rather than blocking the agent on a
    # malformed payload, and the prompt-level instruction still stands.
    exit 0
}

try {
    $payload = $input_json | ConvertFrom-Json
} catch {
    exit 0
}

# Write/Edit/MultiEdit use file_path, NotebookEdit uses notebook_path.
$target = $payload.tool_input.file_path
if (-not $target) { $target = $payload.tool_input.notebook_path }
if (-not $target) { exit 0 }

# Anchor everything to the project root the hook was invoked from. Matching
# "tests/" anywhere in the absolute path is not enough, because a project
# living under C:\tests\ or C:\Users\test\ would then allow every write.
$root = $payload.cwd
if (-not $root) { $root = (Get-Location).Path }

if (-not [System.IO.Path]::IsPathRooted($target)) {
    $target = Join-Path $root $target
}

try {
    $fullTarget = [System.IO.Path]::GetFullPath($target)
    $fullRoot   = [System.IO.Path]::GetFullPath($root)
} catch {
    $fullTarget = $target
    $fullRoot   = $root
}

$normTarget = $fullTarget -replace '\\', '/'
$normRoot   = ($fullRoot -replace '\\', '/').TrimEnd('/')

# Inside the project, and inside tests/ or test/ at its root, is the only
# combination that is allowed. Anything outside the project is denied too.
if ($normTarget.StartsWith($normRoot + '/', [System.StringComparison]::OrdinalIgnoreCase)) {
    $relative = $normTarget.Substring($normRoot.Length + 1)
    if ($relative -match '^tests?/') { exit 0 }
}

[Console]::Error.WriteLine(
    "BLOCKED: the tester agent may only write under tests/ in this project. " +
    "Attempted write to: $target`n" +
    "If this is a real defect in application source, report it and stop. " +
    "Fixing it is not your job."
)
exit 2
