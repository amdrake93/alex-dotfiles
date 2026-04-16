# =============================================================================
# Git comma-prefix system
#
# Comma is right-hand (index/middle), leaving left hand free for the rest
# of the acronym — natural hand alternation, avoids pinky stretches.
#
# Run ',h' for a quick reference of all available commands.
# =============================================================================

# --- Meta-alias: ',' = 'git' ------------------------------------------------
# Use: ', log --since 2.weeks' => 'git log --since 2.weeks'
alias ,=git

# --- Direct aliases (no space, wrap gitconfig aliases) -----------------------
alias ,s='git s'
alias ,d='git d'
alias ,ds='git ds'
alias ,l='git l'
alias ,ll='git ll'
alias ,b='git b'
alias ,pf='git pf'

# --- Smart shell functions ---------------------------------------------------

# ,co <branch> — smart checkout: local first, fetch if remote-only
,co() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "Usage: ,co <branch>" >&2
    return 1
  fi

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git checkout "$branch"
  elif git ls-remote --exit-code --heads origin "$branch" &>/dev/null; then
    git fetch origin "$branch"
    git checkout "$branch"
  else
    echo "Branch '$branch' not found locally or on origin" >&2
    return 1
  fi
}

# ,sc <name> [base] — new branch via 'git switch -c'
# Default base = origin/HEAD (auto main vs master). Fetches base first.
,sc() {
  local name="$1"
  local base="${2:-$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')}"
  base="${base:-main}"

  if [[ -z "$name" ]]; then
    echo "Usage: ,sc <branch-name> [base]" >&2
    echo "  base defaults to origin/$base (auto-detected)" >&2
    return 1
  fi

  if [[ "$base" == origin/* ]]; then
    git fetch origin "${base#origin/}" || return 1
  else
    git fetch origin "$base" || return 1
    base="origin/$base"
  fi

  git switch -c "$name" "$base"
}

# ,cm <msg> — git add . && git commit -m "msg"
,cm() {
  if [[ -z "$1" ]]; then
    echo "Usage: ,cm <message>" >&2
    return 1
  fi
  git add . && git commit -m "$*"
}

# ,ci — git commit (opens editor for selective-stage workflow)
,ci() {
  git commit "$@"
}

# ,u — smart push: auto -u on first push, never force
,u() {
  local branch
  branch=$(git symbolic-ref --short HEAD)
  if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' &>/dev/null; then
    git push origin "$branch"
  else
    echo "Setting upstream: origin/$branch"
    git push -u origin "$branch"
  fi
}

# ,uf — push --force-with-lease (safer force push)
,uf() {
  git push --force-with-lease
}

# ,cp <remote-branch> <commit-hash> [more-hashes...]
# Cherry-pick onto a new branch: fetch + create 'cherry-pick-<remote>' off
# origin/<remote>, then cherry-pick the commit(s).
,cp() {
  local remote="$1"
  shift
  local commits=("$@")

  if [[ -z "$remote" || ${#commits[@]} -eq 0 ]]; then
    echo "Usage: ,cp <remote-branch> <commit-hash> [more-hashes...]" >&2
    echo "Creates branch 'cherry-pick-<remote-branch>' off 'origin/<remote-branch>'" >&2
    echo "and cherry-picks the commit(s)." >&2
    return 1
  fi

  git fetch --all --prune || return 1

  if ! git ls-remote --exit-code --heads origin "$remote" &>/dev/null; then
    echo "Remote branch 'origin/$remote' not found" >&2
    return 1
  fi

  local branch="cherry-pick-${remote}"

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Branch '$branch' already exists locally — checkout/delete it first" >&2
    return 1
  fi

  git checkout -b "$branch" "origin/$remote" || return 1
  git cherry-pick "${commits[@]}"
}

# ,sync — fetch --all --prune + rebase onto upstream
,sync() {
  git fetch --all --prune
  local upstream
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || upstream="origin/main"
  echo "Rebasing onto $upstream"
  git rebase "$upstream"
}

# ,st / ,stp — stash / stash pop
,st() { git stash "$@"; }
,stp() { git stash pop "$@"; }

# --- Help --------------------------------------------------------------------

,h() {
  cat <<'EOF'
Git aliases (in ~/.gitconfig — work via 'git X' AND ',X'):
  git s         status --short --branch
  git d         diff
  git ds        diff --staged
  git l         log --oneline --decorate -20
  git ll        log --oneline --decorate --graph --all
  git b         branch (list)
  git pf        push --force-with-lease
  git unstage   reset HEAD --
  git undo      reset --soft HEAD~1

Shell aliases (interactive zsh, comma prefix):
  ,             meta-alias: ', <anything>' = 'git <anything>'
  ,s ,d ,ds     wrap 'git s/d/ds'
  ,l ,ll ,b ,pf wrap 'git l/ll/b/pf'

Smart shell functions (multi-step / conditional):
  ,co <branch>             smart checkout: local first, fetches if remote-only
  ,sc <name> [base]        new branch via 'git switch -c'; base defaults to
                           origin/HEAD (auto main vs master); fetches base
  ,cm <msg>                git add . && git commit -m "msg"
  ,ci                      git commit (no flags, opens editor)
  ,u                       smart push: auto '-u' on first push, never force
  ,uf                      git push --force-with-lease
  ,cp <remote> <hash...>   fetch + create branch 'cherry-pick-<remote>' off
                           origin/<remote>, then cherry-pick the commit(s)
  ,sync                    git fetch --all --prune + rebase onto upstream
  ,st  ,stp                stash / stash pop
  ,h                       this help

Examples:
  ,sc PD-5022-canva-scaffolding                  # new branch off origin/main
  ,sc PD-5022-foo PD-4999-other                  # new branch off another feature
  ,cm "wip checkpoint"                           # quick add+commit
  ,co main                                       # checkout (fetches if remote-only)
  ,co PD-5022-foo                                # works for any branch
  ,cp main abc1234                               # cherry-pick onto cherry-pick-main
  ,cp main abc1234 def5678                       # cherry-pick multiple commits

Tip: 'which ,sc' (or any function name) shows the actual implementation.
EOF
}
alias ,help=',h'
