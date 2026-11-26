# git-ci-init

A CLI tool and starter template to instantly bootstrap a standardized, production-ready **CI/CD, automated testing, SemVer versioning, and release engineering** setup into any Git repository.

---

## What It Bootstraps

When you run `git ci-init` in any repository, it equips the project with:

```text
your-repo/
├── .github/
│   └── workflows/
│       ├── ci.yml                 # Cross-platform matrix CI (Ubuntu + macOS) on push/PR with changelog linter
│       ├── release.yml            # Manual SemVer release workflow for main branch
│       ├── snapshot.yml           # Branch pre-release workflow for any branch
│       └── deploy.yml             # Post-release deployment pipeline (staging snapshots & prod releases)
├── tests/
│   └── run_tests.sh               # Standalone test runner with /tmp sandboxing & assertion helpers
├── tools/
│   └── release_version.py         # SemVer bumper managing Git tags & Keep a Changelog standard
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
| `-u`, `--update` | Update workflows and tools without overwriting `CHANGELOG.md` or custom tests. |
| `-n`, `--dry-run` | Preview files that would be created without writing them. |
| `-f`, `--force` | Overwrite existing files (CI workflows, version, changelog, tests). |
| `--version <ver>` | Specify the initial version string (default: `0.1.0`). |
| `-h`, `--help` | Show help message. |

---

## The Bootstrapped Components

### 1. Matrix CI Workflow (`.github/workflows/ci.yml`)
Runs `./tests/run_tests.sh` across both **Ubuntu** and **macOS** on every commit pushed to `main` and every Pull Request.

### 2. SemVer Release Workflow (`.github/workflows/release.yml`)
- Manual `workflow_dispatch` action restricted to `main`.
- Prompts for version bump type (`patch`, `minor`, `major`) and includes a `dry_run` preview mode.
- Bumps version from Git tags, promotes `CHANGELOG.md` items under `## [X.Y.Z] -- YYYY-MM-DD`, tags, and publishes a GitHub Release.

### 3. Branch Snapshot Workflow (`.github/workflows/snapshot.yml`)
- Manual `workflow_dispatch` action for any branch.
- Bumps patch level with branch slug and auto-incrementing suffix (e.g. `1.3.4-feature-name.1`).
- Leaves `CHANGELOG.md` untouched, tags the branch commit, and publishes a GitHub Pre-Release.
- Includes optional checkboxes for `run_tests` and `dry_run`.

### 4. Post-Release Deployment Workflow (`.github/workflows/deploy.yml`)
- Automatically triggered on GitHub `release: [published]` (or manual dispatch).
- Distinguishes between **snapshot pre-releases** (deploys to staging/test channels) and **official releases** (deploys to production).
- Includes starter templates and examples for package registries (npm/PyPI), Docker images, and webhook notifications.

### 5. Automated Test Runner (`tests/run_tests.sh`)
A zero-dependency test runner equipped with:
- Isolated `/tmp` sandboxing with automatic cleanup via `trap`.
- Assertion helpers (`assert`, `assert_file_exists`, `assert_file_not_exists`, `assert_file_contains`).
- Test execution in isolated subshells with colored pass/fail reporting.

---

## Running Tests

An automated test suite tests `git-ci-init` itself by creating temporary repositories, bootstrapping files, and verifying test and release execution:

```bash
./tests/run_tests.sh
```
