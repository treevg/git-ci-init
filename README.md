# git-ci-init

A CLI tool and starter template to instantly bootstrap a standardized, production-ready **CI/CD, automated testing, SemVer versioning, and release engineering** setup into any Git repository.

---

## What It Bootstraps

When you run `git ci-init` in any repository, it equips the project with:

```text
your-repo/
├── .github/
│   └── workflows/
│       ├── ci.yml                 # Cross-platform matrix CI (Ubuntu + macOS) on push & PR
│       └── release.yml            # Automated SemVer release pipeline (tag & GitHub release)
├── tests/
│   └── run_tests.sh               # Standalone test runner with /tmp sandboxing & assertion helpers
├── tools/
│   └── release_version.py         # SemVer bumper managing VERSION & the Keep a Changelog standard
├── VERSION                        # Semantic version tracking file (e.g., 0.1.0)
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

### In a new folder (automatically initializes Git):
```bash
mkdir /path/to/new-tool
git ci-init /path/to/new-tool
```

### Options

| Flag | Description |
| :--- | :--- |
| `-n`, `--dry-run` | Preview files that would be created without writing them. |
| `-f`, `--force` | Overwrite existing files (CI workflows, version, changelog, tests). |
| `--version <ver>` | Specify the initial version string (default: `0.1.0`). |
| `-h`, `--help` | Show help message. |

---

## The Bootstrapped Components

### 1. Matrix CI Workflow (`.github/workflows/ci.yml`)
Runs `./tests/run_tests.sh` across both **Ubuntu** and **macOS** on every commit pushed to `main` and every Pull Request.

### 2. SemVer Release Workflow (`.github/workflows/release.yml`)
A manual `workflow_dispatch` action:
- Prompts for version bump type (`patch`, `minor`, `major`).
- Runs `tools/release_version.py` to bump `VERSION` and move in-development changelog items under `## [X.Y.Z] -- YYYY-MM-DD`.
- Runs the test suite to ensure green builds.
- Commits, tags (`vX.Y.Z`), pushes to `main`, and creates a GitHub Release with auto-generated release notes.

### 3. Automated Test Runner (`tests/run_tests.sh`)
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
