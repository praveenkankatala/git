# Git — A Production-Oriented Study Repository

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Git](https://img.shields.io/badge/tool-git-F05032?logo=git&logoColor=white)](https://git-scm.com/)

A structured, hands-on reference for learning **Git** the way you'd actually use it on a DevOps/platform team — from the mental model (flow + architecture) through the day-to-day commands, the ones people confuse, branching strategy, and the thing that trips everyone up: **merge conflicts**.

Every command below is copy-paste runnable against a scratch repo. The `examples/` folder turns each topic into a script you can run end to end, and the CI workflow lint-checks every script so nothing rots.

> Scope note: "complete" here means **complete across standard, vanilla Git** (the `git` CLI, any recent 2.30+ release). It does *not* cover host-specific features (GitHub PRs, GitLab MRs, Bitbucket pipelines) except where noted, because those depend on your platform, not on Git itself. Anything that needs *your* environment is flagged inline with **⚙️ Depends on your setup**.

---

## Repository structure

```text
git-study/
├── README.md                      # This study guide
├── LICENSE                        # MIT (edit the <Your Name> placeholder)
├── .gitignore                     # Sensible ignores for a Git-learning repo
├── config/
│   ├── .gitconfig.example         # A real-world global git config
│   └── .gitattributes.example     # Line-ending + diff rules
├── examples/
│   ├── 01-git-flow/               # A commit → branch → merge lifecycle, scripted
│   ├── 02-git-architecture/       # Working dir ↔ index ↔ repo, made visible
│   ├── 03-core-commands/          # The everyday command set, run for real
│   ├── 04-command-differences/    # pull vs fetch, reset vs revert, merge vs rebase
│   ├── 05-branching-strategy/     # A trunk-based / GitHub-flow style walkthrough
│   └── 06-merge-conflicts/        # Deliberately create and resolve a conflict
├── .github/
│   └── workflows/
│       └── ci.yml                 # Lints every shell script + validates config
└── docs/                          # Expanded per-topic notes (stubs to grow into)
    ├── 01-git-flow.md
    ├── 02-git-architecture.md
    ├── 03-git-commands.md
    ├── 04-command-differences.md
    ├── 05-git-strategy.md
    └── 06-merge-conflicts.md
```

---

## Contents

| # | Topic | What it answers |
|---|-------|-----------------|
| 1 | [Git flow](#1-git-flow) | How a change moves from your editor to a shared branch |
| 2 | [Git architecture](#2-git-architecture) | The three trees: working directory, index, repository (+ HEAD) |
| 3 | [Git commands & explanation](#3-git-commands--explanation) | Every everyday command, what it does, and how to run it |
| 4 | [Git command differences](#4-git-command-differences) | The pairs people mix up: pull/fetch, reset/revert, merge/rebase |
| 5 | [Git strategy](#5-git-strategy) | Branching models, tags, stash, cherry-pick, ignore, reflog |
| 6 | [Merge conflicts](#6-merge-conflicts) | Why they happen and how to resolve them calmly |
| — | [Practical labs](#practical-labs) | Numbered, self-contained exercises |
| — | [Topic coverage index](#topic-coverage-index) | Everything included, at a glance |

---

## 1. Git flow

"Git flow" here means the **everyday lifecycle** of a change — not the specific `git-flow` branching model (that lives in [§5](#5-git-strategy)). A change starts as an edit in your working directory, gets **staged**, becomes a **commit**, and eventually reaches a shared branch via **push**. Reading history and switching context happen along the way.

```bash
# One-time identity setup (writes to ~/.gitconfig)
git config --global user.name  "Praveen"
git config --global user.email "praveen@example.com"

# Start a project and record a first change
git init                       # initialize a local repository in this folder
echo "# my project" > README.md
git add README.md              # stage the change (working dir -> index)
git commit -m "Initial commit" # snapshot the index (index -> repository)

# See where you stand and what happened
git status                     # what's staged / modified / untracked
git log --oneline --graph      # compact, visual history

# Publish it (⚙️ Depends on your setup: create the remote repo first)
git remote add origin https://github.com/<your-username>/<repo>.git
git branch -M main
git push -u origin main
```

*Why it matters:* internalizing **edit → `add` → `commit` → `push`** is the single mental model that makes every other command make sense.

---

## 2. Git architecture

Git tracks your project across **three "trees"** plus a pointer called **HEAD**. The **working directory** is the files you edit. The **staging area (index)** is a holding pen for the *next* commit. The **repository** (the `.git` folder) is the permanent, content-addressed history of commits. **HEAD** is a reference to "where you are" — normally the tip of your current branch.

```bash
# Make a change and watch it move through the three trees
echo "line one" > notes.txt
git status                 # notes.txt is in the WORKING DIRECTORY (untracked)

git add notes.txt          # promote it to the STAGING AREA (index)
git status                 # now "Changes to be committed"

git commit -m "Add notes"  # write it into the REPOSITORY as a commit
git cat-file -p HEAD       # inspect the commit object HEAD points to

git diff                   # working dir vs index  (unstaged changes)
git diff --staged          # index vs last commit  (what a commit would save)
```

*Why it matters:* almost every "wait, where did my change go?" moment is really a question about *which of the three trees* the change is currently sitting in — and `reset` vs `checkout`/`restore` are just tools for moving changes between them.

**HEAD, in detail.** HEAD normally points at your current branch, which in turn points at a commit. If you check out a *commit* (or a tag) directly instead of a branch, HEAD points straight at that commit — a state called **detached HEAD**. Commits you make there aren't on any branch and can be lost, so create a branch first if you want to keep them.

```bash
git checkout <commit-sha>   # detached HEAD: HEAD -> commit, not a branch
git switch -c rescue        # attach a branch here so the work isn't orphaned
git switch main             # go back to normal (attached) HEAD
```

---

## 3. Git commands & explanation

The everyday command set. Each is annotated inline; all are safe to run against a scratch repo.

```bash
# --- Setup & inspection ------------------------------------------------------
git init                                  # create a new local repo
git config --global user.name "Praveen"   # identity used to author commits
git status                                # working tree / staging state
git log --oneline                         # compact history (one line per commit)
git show HEAD                             # the newest commit and its diff

# --- Staging & committing ----------------------------------------------------
git add <file>                            # stage a specific file
git add .                                 # stage everything under the cwd
git commit -m "message"                   # commit staged changes
git commit --amend -m "better message"    # rewrite the most recent commit
                                          #   (only before it's pushed/shared)

# --- Branching ---------------------------------------------------------------
git branch                                # list branches (* = current)
git branch feature-x                      # create a branch (doesn't switch)
git switch feature-x                      # switch to it (modern verb)
git switch -c feature-y                   # create AND switch in one step
git checkout -b feature-z                 # older equivalent of "switch -c"
git branch -d feature-x                   # delete a merged branch
git branch -D feature-x                   # force-delete an unmerged branch

# --- Remotes -----------------------------------------------------------------
git remote -v                             # show remote URLs (fetch + push)
git remote add origin <url>               # add a remote named "origin"
git remote set-url origin <new-url>       # point "origin" at a different URL
git clone <url>                           # copy a remote repo to local
git clone -b <branch> <url>               # clone only a specific branch

# --- Syncing -----------------------------------------------------------------
git fetch origin                          # download remote history (no merge)
git pull origin main                      # fetch + merge into current branch
git push origin main                      # upload local commits to the remote

# --- Comparing & undoing -----------------------------------------------------
git diff <file>                           # unstaged changes for a file
git restore <file>                        # discard unstaged changes to a file
git restore --staged <file>               # unstage (keep the edit)
git reset --soft  <sha>                   # move HEAD; keep index + working dir
git reset --mixed <sha>                   # move HEAD + reset index (default)
git reset --hard  <sha>                   # move HEAD + wipe index + working dir
git revert <sha>                          # new commit that undoes an old one

# --- Labels & recovery -------------------------------------------------------
git tag v1.0.0                            # lightweight tag on HEAD
git tag -a v1.0.0 -m "release 1.0.0"      # annotated tag (has author + message)
git cherry-pick <sha>                     # copy one commit onto current branch
git stash                                 # shelve uncommitted work
git reflog                                # HEAD's movement log — your undo net
```

*Why it matters:* this block is the 20% of Git you'll use 80% of the time; keep it within reach.

---

## 4. Git command differences

The pairs that cause the most confusion. Each is shown as "the difference, then how to see it."

### `git pull` vs `git fetch`

`fetch` **downloads** remote commits into your local copy of the remote branch (e.g. `origin/main`) but leaves *your* branch untouched. `pull` is `fetch` **plus** a merge (or rebase) into your current branch — it moves your working files. Use `fetch` when you want to look before you leap.

```bash
git fetch origin                 # updates origin/main; your files DON'T change
git log --oneline main..origin/main   # preview what you'd be pulling in
git pull origin main             # now actually integrate it (fetch + merge)
```

### `git reset` vs `git revert`

`reset` **moves the branch pointer backward** and rewrites local history — great before you've shared, dangerous after. `revert` **adds a new commit** that undoes an old one, leaving history intact — the safe choice on shared branches. The three `reset` modes differ only in how far the undo reaches:

```bash
git reset --soft  <sha>   # undo commits; changes stay STAGED
git reset --mixed <sha>   # undo commits; changes stay in WORKING DIR (default)
git reset --hard  <sha>   # undo commits AND discard the changes entirely

git revert <sha>          # safe: creates a new "undo" commit, keeps history
```

### `git merge` vs `git rebase`

Both integrate one branch into another. `merge` **preserves history** and records a **merge commit** where the lines of work join. `rebase` **rewrites history** by replaying your commits on top of the target — a linear, merge-commit-free result, but new commit SHAs (so never rebase commits you've already shared). If a merge goes wrong mid-way, `git merge --abort` backs it out.

```bash
git switch feature
git merge main            # keeps both histories; may add a merge commit

git switch feature
git rebase main           # replays feature's commits on top of main (linear)

git merge --abort         # bail out of an in-progress, conflicted merge
git rebase --abort        # bail out of an in-progress, conflicted rebase
```

*Why it matters:* choosing the right member of each pair is the difference between a clean, recoverable repo and a shared-history disaster.

---

## 5. Git strategy

The tools and conventions that turn Git from "save button" into a workflow: branching models, tags, stash, cherry-pick, `.gitignore`, and reflog.

### Branching models

A branching **strategy** decides where work happens and how it merges back. Two common ones: **GitHub Flow / trunk-based** — short-lived feature branches off `main`, merged via review, deploy from `main`; and **Git Flow** — long-lived `main` + `develop` with `feature/*`, `release/*`, and `hotfix/*` branches for scheduled releases. Small teams shipping continuously usually prefer trunk-based; teams with versioned releases lean toward Git Flow.

```bash
# Trunk-based / GitHub-Flow shape
git switch main && git pull                 # start from up-to-date trunk
git switch -c feature/login                 # short-lived branch
# ...commit small changes...
git push -u origin feature/login            # open a PR/MR (⚙️ platform-specific)
# after review + merge, delete the branch:
git branch -d feature/login
```

### Tags — labeling a moment in history

A **tag** is a fixed pointer to a specific commit — unlike a branch, it never moves. **Lightweight** tags are just a name on a commit; **annotated** tags additionally store the tagger's name, email, date, and a message, and are stored as full objects — recommended for releases.

```bash
git tag v1.1.1                       # lightweight: just a name -> commit
git tag -a v1.1.0 -m "Release 1.1.0" # annotated: full metadata (preferred)
git show v1.1.0                      # inspect an annotated tag
git tag                              # list all tags
git tag -l "*beta*"                  # list tags whose name contains "beta"
git checkout v1.1.0                  # view the repo at that tag (detached HEAD)
git push origin v1.1.0               # tags aren't pushed by default — push explicitly
```

### Stash — shelve work without committing

`git stash` stores your uncommitted changes safely in a hidden place so you can switch branches with a clean tree, then restore them later. Think "store something temporarily" — Git saves your data without making a commit.

```bash
git stash                       # shelve tracked, modified changes
git stash save "wip: login ui"  # (older syntax) shelve with a label
git stash list                  # list shelved entries (stash@{0}, {1}, ...)
git stash apply                 # reapply the latest stash, KEEP it in the list
git stash pop                   # reapply the latest stash AND drop it
git stash branch fix-later      # turn a stash into a fresh branch
```

### Cherry-pick — copy a single commit

`git cherry-pick` applies **one specific commit** from another branch onto your current one — useful when you want a single fix without merging the whole branch (classically, porting a bugfix into every release branch). It's powerful like rebase, but can create **duplicate commits**, so it's a tool, not a default.

```bash
git switch release/1.2
git cherry-pick <bugfix-sha>    # place just that fix onto the release branch
```

### `.gitignore` — keep noise (and secrets) out

List patterns in a `.gitignore` file and Git won't track matching files. This is also how you **keep secrets out of history** — never commit `.env`, keys, or tokens; commit an example instead.

```bash
cat > .gitignore <<'EOF'
*.log
*.tmp
.env               # real secrets — NEVER commit
.env.example       # ...but DO commit a redacted template (note: not ignored)
node_modules/
target/
EOF
git rm --cached .env    # if a secret slipped in, stop tracking it
```

> Secure pattern: commit `.env.example` with **placeholder** values and document the real names; load real values from your secret manager / CI variables at runtime — never from the repo.

### Reflog — your safety net

"Reflog" is short for **reference log**: a local record of everywhere HEAD (and branches) have pointed. It's how you recover commits after a bad `reset`, `rebase`, or branch delete. It's **local only** (not shared) and entries expire after ~90 days by default.

```bash
git reflog                       # every position HEAD has held, most recent first
git reflog show main             # the movement log for a specific branch
git reset --hard HEAD@{2}        # jump back to where HEAD was 2 moves ago
```

*Why it matters:* strategy is what keeps a repo navigable for a *team* over months — and reflog is what lets you undo the scary stuff.

---

## 6. Merge conflicts

A conflict happens when two branches change **the same lines** of the same file (or one edits a file the other deletes) and Git can't decide which wins. It pauses the merge/rebase and marks the file with conflict markers for you to resolve by hand.

```bash
# Reproduce a conflict on purpose
git switch -c branch-a
printf 'hello from A\n' > greeting.txt && git commit -am "A edits greeting"

git switch main
printf 'hello from main\n' > greeting.txt && git commit -am "main edits greeting"

git merge branch-a               # CONFLICT: both changed greeting.txt
```

Git writes markers into the file. `<<<<<<<` opens *your* side (HEAD), `=======` separates, `>>>>>>>` closes *their* side:

```text
<<<<<<< HEAD
hello from main
=======
hello from A
>>>>>>> branch-a
```

Resolve by editing the file to the intended final content (delete the markers), then stage and finish:

```bash
# ...edit greeting.txt so it contains only the lines you want...
git add greeting.txt             # marks the conflict as resolved
git commit                       # completes the merge (default message is fine)

# Prefer a whole side instead of hand-editing:
git checkout --ours   greeting.txt   # keep HEAD's version
git checkout --theirs greeting.txt   # keep the incoming branch's version

git merge --abort                # or: give up and return to pre-merge state
```

*Why it matters:* conflicts are normal, not failure — knowing the marker anatomy and `--ours`/`--theirs`/`--abort` turns a panic moment into a 30-second fix.

---

## Practical labs

Self-contained exercises. Each starts from an empty scratch directory, so nothing here can touch your real projects.

1. **First repo, first commit.** `mkdir lab1 && cd lab1 && git init`. Create a file, `git add` it, `git commit`, then run `git log --oneline`. Confirm you can explain what `add` did versus what `commit` did.
2. **The three trees.** Edit a tracked file. Run `git diff` (working vs index), `git add`, then `git diff --staged` (index vs commit). Predict each output *before* running it.
3. **Branch and merge cleanly.** Create `feature/x`, make two commits, switch to `main`, and `git merge feature/x` (fast-forward, no conflict). Then `git branch -d feature/x`.
4. **fetch vs pull.** Clone any public repo. Run `git fetch`, inspect `git log main..origin/main`, *then* `git pull`. Describe what changed after each.
5. **Undo three ways.** On a throwaway branch, make a commit, then try `git reset --soft HEAD~1`, `git reset --mixed HEAD~1`, and `git reset --hard HEAD~1` (recreating the commit between each). Note where the changes end up.
6. **Safe undo on shared history.** Make a commit, then `git revert HEAD`. Confirm the original commit still exists in `git log` and a new "undo" commit sits on top.
7. **Rebase vs merge.** Branch off `main`, commit on both, then integrate once with `merge` and once with `rebase` (in separate clones). Compare `git log --graph --oneline`.
8. **Tag a release.** Create an annotated tag `v1.0.0`, run `git show v1.0.0`, then `git checkout v1.0.0` and notice the detached-HEAD warning. Return with `git switch main`.
9. **Stash a context switch.** With uncommitted edits, `git stash`, switch branches, come back, and `git stash pop`. Then repeat with `git stash apply` and observe the difference in `git stash list`.
10. **Cherry-pick a fix.** Make a bugfix commit on `main`, create `release/1.0`, and `git cherry-pick` just that commit onto the release branch.
11. **Ignore and protect secrets.** Add a fake `.env`, create a `.gitignore` that excludes it, and confirm `git status` no longer shows it. Commit a `.env.example` instead.
12. **Force a conflict and resolve it.** Follow [§6](#6-merge-conflicts) to create a conflict, resolve it by hand, then do it again using `--ours` / `--theirs`.
13. **Recover with reflog.** `git reset --hard HEAD~2`, then use `git reflog` to find the lost commit and `git reset --hard HEAD@{1}` to restore it.

Every lab has a scripted counterpart under [`examples/`](./examples) — read the script, predict the output, then run it.

---

## Topic coverage index

Everything included, so coverage is scannable at a glance:

- **Git flow** — identity setup, `init`, `add`, `commit`, `status`, `log`, `push` lifecycle
- **Git architecture** — working directory, staging area (index), repository, HEAD, detached HEAD, `cat-file`, `diff` / `diff --staged`
- **Core commands** — `init`, `config`, `status`, `log`, `show`, `add`, `commit`, `commit --amend`, `branch`, `switch`, `checkout -b`, `branch -d/-D`, `remote -v/add/set-url`, `clone`, `clone -b`, `fetch`, `pull`, `push`, `diff`, `restore`, `restore --staged`, `reset --soft/--mixed/--hard`, `revert`, `tag`, `cherry-pick`, `stash`, `reflog`
- **Command differences** — pull vs fetch, reset vs revert, reset modes, merge vs rebase, `merge --abort` / `rebase --abort`
- **Strategy** — trunk-based vs Git Flow branching, lightweight vs annotated **tags**, tag listing/checkout/push, **stash** (list/apply/pop/save/branch), **cherry-pick**, **.gitignore** + secret hygiene, **reflog** (show/expire, `HEAD@{n}`)
- **Merge conflicts** — cause, marker anatomy (`<<<<<<<`/`=======`/`>>>>>>>`), manual resolve, `--ours` / `--theirs`, `merge --abort`

See [`docs/`](./docs) for room to expand any of these into deeper standalone notes.

---

## License

MIT — see [LICENSE](./LICENSE). Edit the `<Your Name>` placeholder before publishing.
