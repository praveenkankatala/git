#!/usr/bin/env bash
# Topic 5 — Strategy: short-lived feature branches, tags, stash, cherry-pick,
# .gitignore (with secret hygiene), and reflog recovery.

set -euo pipefail
# shellcheck source=../_lib.sh
source "$(dirname "$0")/../_lib.sh"

setup_scratch_repo

step "Trunk-based: short-lived feature branch off main"
echo "base" > app.txt
git add app.txt && git commit -qm "base"
git switch -qc feature/login
echo "login" >> app.txt
git add app.txt && git commit -qm "add login"
git switch -q main
git merge -q --no-edit feature/login
git branch -d feature/login

step ".gitignore keeps secrets and noise out"
cat > .gitignore <<'EOF'
*.log
.env
!.env.example
EOF
echo "SECRET=do-not-commit" > .env          # real secret — ignored
echo "SECRET=<put-value-here>" > .env.example  # safe template — committed
echo "noisy" > debug.log                     # ignored
git add .gitignore .env.example
git commit -qm "Add gitignore and env template"
echo "-- status shows .env and debug.log are ignored: --"
git status --short --ignored | grep -E '\.env|debug\.log' || true

step "Tags: lightweight vs annotated"
git tag v1.0.0-light
git tag -a v1.0.0 -m "Release 1.0.0"
git tag
git --no-pager show v1.0.0 --stat | head -n 4

step "Stash: shelve work, switch, restore"
echo "wip" >> app.txt
git stash push -m "wip: half-done"
git stash list
git stash pop
git checkout -- app.txt 2>/dev/null || git restore app.txt

step "Cherry-pick a single commit onto a release branch"
echo "bugfix" >> app.txt
git add app.txt && git commit -qm "critical bugfix"
fix="$(git rev-parse HEAD)"
git switch -qc release/1.0 HEAD~1
git cherry-pick "$fix"
git log --oneline | head -n 2
git switch -q main

step "Reflog: recover after a bad hard reset"
before="$(git rev-parse HEAD)"
git reset --hard HEAD~2
echo "-- oops, went back 2 commits. reflog remembers: --"
git --no-pager reflog | head -n 4
git reset --hard "$before"
echo "-- restored to: $(git rev-parse --short HEAD)"

echo
echo "OK: strategy demo completed."
