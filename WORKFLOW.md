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
  timeout_ms: 120000

  after_create: |
    set -e
    BRANCH="codex/{{ issue.identifier | downcase | replace: ' ', '-' }}"
    git -C "$SYMPHONY_SOURCE_REPO" fetch --all --prune
    git -C "$SYMPHONY_SOURCE_REPO" worktree add "$PWD" -B "$BRANCH" origin/main

  before_run: |
    set -e
    git fetch --all --prune
    git checkout "codex/{{ issue.identifier | downcase | replace: ' ', '-' }}"

  after_run: |
    set +e
    if command -v melos >/dev/null 2>&1; then
      melos run analyze || true
      melos run test || true
    fi

  before_remove: |
    set +e
    git -C "$SYMPHONY_SOURCE_REPO" worktree remove "$PWD" --force || true
    git -C "$SYMPHONY_SOURCE_REPO" worktree prune || true

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

Execution rules:
- Keep changes tightly aligned to issue scope.
- Prefer minimal, testable increments.
- If issue is too large, implement the smallest safe slice and propose decomposition.
- Run relevant checks for touched modules.
- End with: summary of changes, risks, and follow-up actions.

Issue metadata:
- URL: {{ issue.url }}
- State: {{ issue.state }}
- Labels: {{ issue.labels | join: ", " }}
- Priority: {{ issue.priority }}
- Attempt: {{ attempt }}

Issue description:
{{ issue.description }}