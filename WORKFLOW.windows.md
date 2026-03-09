---
tracker:
  kind: linear
  api_key: $LINEAR_API_KEY
  project_slug: mobile-app
  active_states: ["Todo", "In Progress"]
  terminal_states: ["Done", "Cancelled", "Canceled", "Duplicate", "Closed"]

polling:
  interval_ms: 30000

workspace:
  root: $SYMPHONY_WORKSPACES_ROOT

hooks:
  timeout_ms: 180000

  after_create: |
    pwsh -NoProfile -Command "
    $branch = 'codex/{{ issue.identifier | downcase | replace: '' '', ''-'' }}';
    git -C $env:SYMPHONY_SOURCE_REPO fetch --all --prune;
    git -C $env:SYMPHONY_SOURCE_REPO worktree add $PWD.Path -B $branch origin/main
    "

  before_run: |
    pwsh -NoProfile -Command "
    $branch = 'codex/{{ issue.identifier | downcase | replace: '' '', ''-'' }}';
    git fetch --all --prune;
    git checkout $branch
    "

  after_run: |
    pwsh -NoProfile -Command "
    if (Get-Command melos -ErrorAction SilentlyContinue) {
      melos run analyze;
      melos run test;
    }
    "

  before_remove: |
    pwsh -NoProfile -Command "
    git -C $env:SYMPHONY_SOURCE_REPO worktree remove $PWD.Path --force;
    git -C $env:SYMPHONY_SOURCE_REPO worktree prune
    "

agent:
  max_concurrent_agents: 3
  max_retry_backoff_ms: 300000

codex:
  command: codex app-server
  approval_policy: on-request
  thread_sandbox: workspace-write
  turn_timeout_ms: 3600000
  read_timeout_ms: 5000
  stall_timeout_ms: 300000
---

You are implementing Linear issue {{ issue.identifier }}: {{ issue.title }}.

Follow AGENTS.md and SRD priorities.

Windows execution notes:
- Prefer PowerShell-native commands.
- Keep scope tight and changes testable.
- If issue is too large, implement the smallest safe slice and propose decomposition.
- Run relevant checks for touched modules and summarize risks.

Issue metadata:
- URL: {{ issue.url }}
- State: {{ issue.state }}
- Labels: {{ issue.labels | join: ", " }}
- Priority: {{ issue.priority }}
- Attempt: {{ attempt }}

Issue description:
{{ issue.description }}
