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

## Work-specific tools

Java, Maven, JDK8/17, localstack — not installed by default:

```bash
brew bundle install --file=~/repos/alex-dotfiles/Brewfile.work
```

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
