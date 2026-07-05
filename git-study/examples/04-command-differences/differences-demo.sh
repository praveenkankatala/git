#!/usr/bin/env bash
# Topic 4 — Command differences: reset vs revert, reset modes,
# merge vs rebase, and fetch vs pull (against a local remote).

set -euo pipefail
# shellcheck source=../_lib.sh
source "$(dirname "$0")/../_lib.sh"

setup_scratch_repo

step "Seed some history"
for n in 1 2 3; do
	echo "line $n" >> file.txt
	git add file.txt
	git commit -qm "commit $n"
done
git log --oneline

step "reset --soft: undo commit, keep changes STAGED"
git reset --soft HEAD~1
git status --short          # staged change from the undone commit
git commit -qm "commit 3 (recommitted)"

step "revert: safe undo that ADDS a commit"
git revert --no-edit HEAD
git log --oneline           # original commit still present + a revert commit

step "merge vs rebase (two branches diverge)"
git switch -qc feature
echo "feature work" >> feat.txt
git add feat.txt && git commit -qm "feature commit"
git switch -q main
echo "main work" >> main.txt
git add main.txt && git commit -qm "main commit"

# Merge keeps both histories (records a merge commit here):
git merge --no-edit feature
echo "-- after merge: --"
git log --oneline --graph | head -n 6

step "fetch vs pull against a local remote"
remote="$(mktemp -d)"
git init -q --bare -b main "$remote"     # -b main so the remote HEAD isn't 'master'
git remote add origin "$remote"
git push -q -u origin main

# Simulate someone else pushing a new commit to the remote:
other="$(mktemp -d)"
git clone -q "$remote" "$other/x"
( cd "$other/x" \
  && git config user.email a@b.c && git config user.name teammate \
  && echo "remote change" >> file.txt \
  && git commit -qam "teammate commit" \
  && git push -q origin main )

echo "-- fetch downloads but does NOT move our branch: --"
git fetch -q origin
git log --oneline main..origin/main    # preview incoming commit(s)

echo "-- pull integrates it: --"
git pull -q --no-edit origin main
git log --oneline | head -n 3

rm -rf "$remote" "$other"
echo
echo "OK: command-differences demo completed."
