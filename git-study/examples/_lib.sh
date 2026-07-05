#!/usr/bin/env bash
# Shared helpers for the example scripts.
# Each example sources this, then works inside a throwaway temp repo so it can
# NEVER touch your real projects.

set -euo pipefail

# Create an isolated scratch repo and cd into it. Cleaned up on exit.
# SCRATCH_DIR is intentionally global so the EXIT trap can see it even under
# `set -u` (a `local` would be out of scope when the trap fires).
SCRATCH_DIR=""
setup_scratch_repo() {
	SCRATCH_DIR="$(mktemp -d)"
	trap 'rm -rf "${SCRATCH_DIR:-}"' EXIT
	cd "$SCRATCH_DIR"
	git init -q -b main
	# Local identity so commits work even on a machine with no global config
	git config user.name  "Example Learner"
	git config user.email "learner@example.com"
}

# Pretty section header.
step() {
	printf '\n=== %s ===\n' "$*"
}
