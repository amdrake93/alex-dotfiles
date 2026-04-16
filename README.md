# Alex's Dotfiles

Personal dotfiles for macOS. Clone + run `install.sh` to bootstrap a fresh machine.

## Quick start

```bash
git clone <repo-url> ~/repos/alex-dotfiles
cd ~/repos/alex-dotfiles
./install.sh
```

## What's inside

- **Shell:** zsh with antidote plugin manager, starship prompt, zoxide, modern Unix tools (eza, bat, ripgrep, fd, delta, lazygit)
- **Git:** comma-prefix alias system (run `,h` for reference), delta-powered diffs, sensible defaults
- **Editor:** minimal nvim (~30 lines, no plugins) — IntelliJ is the primary IDE
- **Prompt:** starship with git status, language versions (Java/Python/Node/Go), terraform workspace, 12h clock
- **Fonts:** FiraCode Nerd Font

## Work-specific setup

Java toolchain, localstack, and per-project Java version management — run after `install.sh`:

```bash
./scripts/setup-work.sh
```

This installs `Brewfile.work` (JDK 8/17, maven, jenv, localstack), enables jenv's export plugin (auto-exports `JAVA_HOME`), registers installed JDKs, sets `jenv global 1.8`, and auto-generates `.java-version` files for every `~/repos/cloud-campaign-*` clone (detected from `pom.xml`, `Dockerfile`, or `bitbucket-pipelines.yml`). Idempotent — re-run anytime.

`.java-version` files are user-only (gitignored globally via `core.excludesfile`) so they never get committed to upstream work repos.

## Comma-prefix git system

Run `,h` in your terminal for the full reference. Quick overview:

| Command | What it does |
|---|---|
| `,co <branch>` | Smart checkout (fetches if remote-only) |
| `,sc <name> [base]` | New branch from origin/main (or specify base) |
| `,cm <msg>` | Quick add + commit |
| `,u` | Smart push (auto -u on first push) |
| `,cp <remote> <hash>` | Cherry-pick onto new branch |
| `,sync` | Fetch + rebase onto upstream |
| `,h` | Full help |

## Structure

```
home/          mirrors $HOME — symlinked by install.sh
bin/           scripts -> ~/bin/ (individual symlinks)
scripts/       install helpers (not symlinked)
Brewfile       cross-machine standard packages
Brewfile.work  job-specific packages
install.sh     bootstrap script (idempotent)
```

## Design notes

A few non-obvious choices worth keeping in mind:

- **Night Owl theme (Ghostty) and Night Owl-aligned starship colors.** Chosen for red/green colorblind friendliness — most themes make diff coloring hard to distinguish.
- **Per-language prompt accents match each ecosystem's branding.** Java=red (coral), Python=yellow, Node=green, Go=cyan.
- **jenv for Java version switching.** Lighter than asdf/sdkman for a single-language use case. Shims `java`/`javac`/`mvn`; exports `JAVA_HOME` per-repo via `.java-version`.
- **`.java-version` is user-local, never committed.** Global git `excludesfile` (`~/.config/git/ignore`) keeps it out of upstream repos.
- **No tmux.** Removed — interfered with system clipboard.
