# git-ci-init

A CLI tool and starter template to instantly bootstrap a standardized, production-ready **CI/CD, automated testing, SemVer versioning, and release engineering** setup into any Git repository.

---

## What It Bootstraps

When you run `git ci-init` in any repository, it equips the project with:

```text
your-repo/
├── .ci/
│   └── actions/
│       ├── run-tests/
│       │   └── action.yml         # Test suite execution composite action (stub to plug in custom tests)
│       ├── prepare-release/
│       │   └── action.yml         # On-the-fly codebase preparation (e.g. bumping package.json / Cargo.toml)
│       └── deploy/
│           └── action.yml         # Deployment execution composite action (staging snapshots & prod releases)
├── .github/
│   ├── scripts/
│   │   └── release_version.py     # SemVer bumper managing Git tags & Keep a Changelog standard
│   └── workflows/
│       ├── ci.yml                 # Cross-platform matrix CI (Ubuntu + macOS) on push/PR with changelog linter
│       ├── release.yml            # Manual SemVer release & production deploy workflow (main branch only)
│       └── snapshot.yml           # Branch pre-release & staging deploy workflow (any branch)
└── CHANGELOG.md                   # Keep a Changelog template with the ## [unreleased] placeholder
```

---

## Installation

Clone or navigate to this repository and run the install script:

```bash
cd /Users/treevg/Documents/Tools/git-ci-init
./install.sh
```

This symlinks `git-ci-init` into `~/.local/bin/git-ci-init`. Because Git automatically resolves commands matching `git-<subcommand>`, you can invoke it in any repository as:

```bash
git ci-init
```

To uninstall:
```bash
./install.sh --uninstall
```

---

## Usage

### In an existing repository:
```bash
cd /path/to/my-project
git ci-init
```

### Upgrade workflows in an existing repository (safe update):
```bash
cd /path/to/my-project
git ci-init --update
```

### In a new folder (automatically initializes Git):
```bash
mkdir /path/to/new-tool
git ci-init /path/to/new-tool
```

### Options

| Flag | Description |
| :--- | :--- |
| `-u`, `--update` | Update workflows and tools without overwriting `CHANGELOG.md` or custom actions in `.ci/actions/`. |
| `-n`, `--dry-run` | Preview files that would be created without writing them. |
| `-f`, `--force` | Overwrite existing files (CI workflows, version, changelog). |
| `--version <ver>` | Specify the initial version string (default: `0.1.0`). |
| `-h`, `--help` | Show help message. |

---

## The Bootstrapped Components

### 1. Matrix CI Workflow (`.github/workflows/ci.yml`)
Runs cross-platform testing across both **Ubuntu** and **macOS** on every commit pushed to `main` and every Pull Request, invoking the modular composite action `./.ci/actions/run-tests`.

### 2. SemVer Release Workflow (`.github/workflows/release.yml`)
- Manual `workflow_dispatch` action restricted to `main`.
- Prompts for version bump type (`patch`, `minor`, `major`) and includes a `dry_run` preview mode.
- Bumps version from Git tags, promotes `CHANGELOG.md` items under `## [X.Y.Z] -- YYYY-MM-DD`, tags, publishes a GitHub Release, and automatically triggers `./.ci/actions/deploy` (target: `production`).

### 3. Branch Snapshot Workflow (`.github/workflows/snapshot.yml`)
- Manual `workflow_dispatch` action for any branch.
- Bumps patch level with branch slug and auto-incrementing suffix (e.g. `1.3.4-feature-name.1`).
- Leaves `CHANGELOG.md` untouched, tags the branch commit, publishes a GitHub Pre-Release, and automatically triggers `./.ci/actions/deploy` (target: `staging`).
- Includes optional checkboxes for `run_tests` and `dry_run`.

### 4. Modular Test Action Stub (`.ci/actions/run-tests/action.yml`)
A composite GitHub Action invoked by `ci.yml`, `release.yml`, and `snapshot.yml`. Houses the test execution commands (e.g., pytest, npm test, cargo test, ./tests/run_tests.sh) in a single shared file so tests are configured in one place across all workflows.

### 5. Modular Codebase Preparation Stub (`.ci/actions/prepare-release/action.yml`)
A composite GitHub Action invoked prior to committing releases and snapshots. Allows applying on-the-fly modifications to the codebase (e.g., bumping `package.json`, `Cargo.toml`, or source version constants). Any modified tracked files are automatically committed into the release.

### 6. Modular Deploy Action Stub (`.ci/actions/deploy/action.yml`)
A composite GitHub Action invoked directly at the end of `release.yml` (production) and `snapshot.yml` (staging). Houses deployment logic for package registries (npm/PyPI), Docker containers, cloud deployments, and notifications. Automatically skipped during dry runs.
