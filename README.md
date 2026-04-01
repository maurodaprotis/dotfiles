# dotfiles

Personal development environment configuration. Symlinked for instant updates — just `git pull`.

## Quick Start

```bash
git clone git@github.com:maurodaprotis/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer is idempotent — safe to re-run anytime. Existing files are backed up with a timestamp before being replaced.

## What's Inside

| Directory      | What it configures                                                        |
| -------------- | ------------------------------------------------------------------------- |
| `zsh/`         | Oh My Zsh config, aliases, NVM, pyenv, pnpm, Bun, uv                     |
| `git/`         | `.gitconfig` (aliases, LFS, ff-only pulls) and global `.gitignore`        |
| `gh/`          | GitHub CLI config                                                         |
| `claude/`      | Claude Code `settings.json`                                               |
| `ssh/`         | SSH config (OrbStack, keychain, hosts)                                    |
| `fonts/`       | Operator Mono font family (auto-installed to system fonts)                |
| `macos/`       | macOS defaults (Dock, keyboard, Finder, screenshots)                      |
| `ai/`          | AI skills and agents for Claude, Cursor, Gemini, Codex, Copilot and more  |
| `templates/`   | Files with secrets (`.npmrc`, `mcp.json`) — copied, not symlinked         |

### Custom Prompt

`prompt.zsh` provides a situation-aware shell prompt with Nerd Font icons. Segments only appear when relevant:

- Runtime version (Node/Python) — only in projects that use them
- Git branch + diff stats — only in git repos
- Python virtualenv, AWS profile, GCP project, Kubernetes context — only when active
- Command duration — only when > 2 seconds
- Exit code — only on failure

## AI Skills & Agents

The `ai/` directory contains reusable skills and agent personas that get symlinked into each AI tool's config directory.

### Setup

Globally (done by `install.sh`):

```bash
./ai/setup.sh --all ~
```

Per-project:

```bash
./ai/setup.sh --all /path/to/project
# or pick specific tools:
./ai/setup.sh --claude --cursor /path/to/project
```

Supported tools: `--claude`, `--cursor`, `--gemini`, `--codex`, `--opencode`, `--copilot`, `--all`.

### Available Skills

| Skill                            | Description                                              |
| -------------------------------- | -------------------------------------------------------- |
| `code-review`                    | Structured code review                                   |
| `commit-message`                 | Generate commit messages                                 |
| `refactor`                       | Code refactoring guidance                                |
| `tdd`                            | Test-driven development (red-green-refactor)             |
| `react-doctor`                   | Catch React issues early                                 |
| `write-a-prd`                    | Create PRDs and submit as GitHub issues                  |
| `prd-to-issues`                  | Break PRDs into GitHub issues (vertical slices)          |
| `write-a-prd-linear`            | Create PRDs and submit as Linear issues                  |
| `prd-to-issues-linear`          | Break PRDs into Linear issues (vertical slices)          |
| `improve-codebase-architecture` | Find architectural improvement opportunities             |
| `grill-me`                       | Stress-test a plan or design through interview           |

### Agents

| Agent      | Description                  |
| ---------- | ---------------------------- |
| `planner`  | Planning-focused persona     |
| `reviewer` | Code review-focused persona  |

## Templates

Files in `templates/` contain placeholders for secrets. They're **copied** (not symlinked) on first install, so you fill in tokens once and they won't be overwritten:

- `npmrc.template` → `~/.npmrc`
- `mcp.json.template` → `~/.cursor/mcp.json`
