#!/usr/bin/env bash
# Topic 6 — Merge conflicts: create one on purpose, then resolve it three ways
# (manual edit, --ours, and --abort).

set -euo pipefail
# shellcheck source=../_lib.sh
source "$(dirname "$0")/../_lib.sh"

setup_scratch_repo

step "Set up two branches that edit the SAME line"
echo "original" > greeting.txt
git add greeting.txt && git commit -qm "base greeting"

git switch -qc branch-a
echo "hello from A" > greeting.txt
git commit -qam "A edits greeting"

git switch -q main
echo "hello from main" > greeting.txt
git commit -qam "main edits greeting"

step "Merge -> conflict (expected)"
if git merge --no-edit branch-a; then
	echo "no conflict (unexpected)"; exit 1
fi
echo "-- conflict markers in the file: --"
cat greeting.txt

step "Resolve 1: manual edit to the intended final content"
cat > greeting.txt <<'EOF'
hello from main and A
EOF
git add greeting.txt
git commit -qm "Resolve greeting conflict (manual)"
echo "-- resolved: --"
cat greeting.txt

step "Resolve 2: prefer one whole side with --ours / --theirs"
git switch -qc branch-b main
echo "B version" > greeting.txt
git commit -qam "B edits greeting"
git switch -q main
echo "main-2 version" > greeting.txt
git commit -qam "main edits greeting again"
git merge --no-edit branch-b || true
git checkout --ours greeting.txt    # keep main's version
git add greeting.txt
git commit -qm "Resolve by keeping ours"
cat greeting.txt

step "Resolve 3: --abort to bail out entirely"
git switch -qc branch-c main
echo "C version" > greeting.txt
git commit -qam "C edits greeting"
git switch -q main
echo "main-3 version" > greeting.txt
git commit -qam "main edits greeting yet again"
git merge --no-edit branch-c || true
git merge --abort
echo "-- after --abort, tree is back to pre-merge state: --"
git status --short
cat greeting.txt

echo
echo "OK: merge-conflict demo completed."
