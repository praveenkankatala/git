#!/usr/bin/env bash
# Topic 2 — Git architecture: working directory, staging area (index),
# repository, and HEAD — made visible.

set -euo pipefail
# shellcheck source=../_lib.sh
source "$(dirname "$0")/../_lib.sh"

setup_scratch_repo

step "Working directory: an untracked file"
echo "line one" > notes.txt
git status --short          # "?? notes.txt" = untracked, in working dir only

step "Staging area (index): promote it"
git add notes.txt
git status --short          # "A  notes.txt" = staged, ready to commit

step "Repository: write the commit"
git commit -qm "Add notes"
git log --oneline

step "HEAD points at the newest commit"
git rev-parse HEAD
git cat-file -t HEAD        # "commit"

step "diff shows which tree a change sits in"
echo "line two" >> notes.txt
echo "-- git diff (working dir vs index): --"
git --no-pager diff
git add notes.txt
echo "-- git diff --staged (index vs last commit): --"
git --no-pager diff --staged

step "Detached HEAD demo"
first="$(git rev-parse HEAD)"
git commit -qam "Stage line two" 2>/dev/null || git commit -qm "Stage line two"
git checkout -q "$first"
git --no-pager status | head -n 2   # notes about detached HEAD
git switch -q main

echo
echo "OK: architecture / three-trees demo completed."
