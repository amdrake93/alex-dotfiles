# Claude onboarding — alex-dotfiles

Alex's personal macOS dotfiles. Everything here is configured to run on a fresh Mac.

## Fresh machine setup

```bash
cd ~/repos/alex-dotfiles
./install.sh                # personal tools, symlinks, starship, antidote
./scripts/setup-work.sh     # only if using Java/Maven (jenv, JDKs, per-repo .java-version)
```

Both are idempotent.

## Verify the install

```bash
,h                   # comma-prefix git help — if this works, zsh/aliases loaded
starship --version   # prompt engine
java -version        # inside a cloud-campaign-* repo, should match .java-version
```

## Layout

| Path | Purpose |
|------|---------|
| `home/` | Mirrors `$HOME`; install.sh symlinks these into place |
| `bin/` | Personal scripts symlinked individually to `~/bin/` (claudew, aws-keys-rotate.sh) |
| `scripts/` | Install helpers (`install-starship.sh`, `setup-work.sh`). Not symlinked. |
| `Brewfile` | Cross-machine tools (CLI, editor, modern Unix, fonts) — installed by install.sh |
| `Brewfile.work` | Java toolchain (JDK 8/17, maven, jenv, localstack) — installed by setup-work.sh |

## Shell architecture

- `.zshenv` sets `ZDOTDIR=$HOME/.config/zsh` (all other zsh config lives there)
- `.zshrc` sources `exports.zsh`, `aliasrc`, and every `zshrc.d/*.zsh` in order
- `zshrc.d/` modules are numbered for explicit ordering (00_prompt, 03_antidote, 05_git, 09_bindkeys, etc.)
- `antidote` manages zsh plugins (brew-installed)

## Design decisions (non-obvious)

- **Night Owl theme + palette-matched starship colors.** Chosen for red/green colorblind friendliness — essential for diff readability.
- **Per-language prompt accents follow logo colors.** java=red (coral), python=yellow, node=green, go=cyan, terraform=mint.
- **jenv with `.java-version` files, user-only.** Global `core.excludesfile` (`~/.config/git/ignore`) keeps `.java-version` out of upstream repos. `setup-work.sh` auto-detects the right version per Cloud Campaign repo from pom.xml / Dockerfile / bitbucket-pipelines.yml.
- **Java 8 is the jenv global default.** Most Cloud Campaign repos are Java 8; the two Java 17 ones (worker-service, social-media-service) are set per-repo.
- **No tmux.** Removed because it interfered with macOS system clipboard.
- **Comma-prefix git system.** `,co`/`,sc`/`,cm`/`,u`/etc. live in `zshrc.d/05_git.zsh`; run `,h` for the full reference.

## What's NOT in this repo

Cloud Campaign (Alex's employer) work context lives in `~/repos/CLAUDE.md` on machines where work repos are cloned. That file documents team conventions, build commands, testing rules, etc. — intentionally kept out of the dotfiles repo because it's work-specific and changes with the job.

If `~/repos/CLAUDE.md` doesn't exist on a fresh machine, that's expected — it means work repos haven't been cloned yet.
