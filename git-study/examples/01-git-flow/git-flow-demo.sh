#!/usr/bin/env bash
# Topic 1 — Git flow: the everyday lifecycle of a change.
# edit -> add -> commit -> branch -> merge -> read history.

set -euo pipefail
# shellcheck source=../_lib.sh
source "$(dirname "$0")/../_lib.sh"

setup_scratch_repo

step "Record a first commit"
echo "# my project" > README.md
git add README.md
git commit -qm "Initial commit"

step "Make and commit a change"
echo "usage instructions" >> README.md
git add README.md
git commit -qm "Document usage"

step "Branch, change, and merge back"
git switch -qc feature/greeting
echo "hello" > greeting.txt
git add greeting.txt
git commit -qm "Add greeting"
git switch -q main
git merge -q feature/greeting

step "Read the resulting history"
git log --oneline --graph --decorate

step "Where does 'push' fit?"
echo "In real life you'd finish with:"
echo "  git remote add origin <url>"
echo "  git push -u origin main"
echo "(skipped here — no network / remote in this demo)"

echo
echo "OK: git-flow lifecycle completed."
