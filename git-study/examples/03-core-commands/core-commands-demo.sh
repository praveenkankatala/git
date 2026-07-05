#!/usr/bin/env bash
# Topic 3 — Core commands run for real: status, log, branch, tag, restore,
# amend, and a local "remote" so clone/fetch work with no network.

set -euo pipefail
# shellcheck source=../_lib.sh
source "$(dirname "$0")/../_lib.sh"

setup_scratch_repo

step "Commit, inspect, amend"
echo "v1" > app.txt
git add app.txt
git commit -qm "Add app (typo in mesage)"
git commit -q --amend -m "Add app"     # rewrite the last (unshared) commit
git log --oneline

step "Branch verbs"
git branch feature-x
git switch -qc feature-y
git switch -q main
git branch                              # list; * marks current
git branch -d feature-x

step "Stage / unstage / discard with restore"
echo "v2" > app.txt
git add app.txt
git restore --staged app.txt           # unstage, keep the edit
git restore app.txt                     # discard the edit entirely
git status --short                      # clean

step "A local bare repo acts as our 'remote'"
remote="$(mktemp -d)"
git init -q --bare -b main "$remote"     # -b main so the remote HEAD isn't 'master'
git remote add origin "$remote"
git push -q -u origin main
git remote -v

step "Clone that remote elsewhere, then fetch"
clone_dir="$(mktemp -d)"
git clone -q "$remote" "$clone_dir/copy"
( cd "$clone_dir/copy" && git log --oneline && git fetch -q origin )

step "Tag a release"
git tag -a v1.0.0 -m "Release 1.0.0"
git --no-pager show v1.0.0 --stat | head -n 5
git tag

rm -rf "$remote" "$clone_dir"
echo
echo "OK: core-commands demo completed."
