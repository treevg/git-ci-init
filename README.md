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
│   └── workflows/
│       ├── ci.yml                 # Reusable CI caller invoking treevg/github-workflows@v1
│       ├── release.yml            # Reusable Release caller invoking treevg/github-workflows@v1
│       └── snapshot.yml           # Reusable Snapshot caller invoking treevg/github-workflows@v1
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

### Standalone (Dependency-less) Mode:
```bash
cd /path/to/my-project
git ci-init --standalone
```
Bootstraps self-contained workflows and embeds `release_version.py` locally with **zero external repository dependencies** (ideal for isolated or air-gapped repositories).

### Options

| Flag | Description |
| :--- | :--- |
| `-u`, `--update` | Update workflows and tools without overwriting `CHANGELOG.md` or custom actions in `.ci/actions/`. |
| `-s`, `--standalone` | Scaffold self-contained, dependency-less CI (embeds release scripts locally with zero external repo dependency). |
| `-n`, `--dry-run` | Preview files that would be created without writing them. |
| `-f`, `--force` | Overwrite existing files (CI workflows, version, changelog). |
| `--version <ver>` | Specify the initial version string (default: `0.1.0`). |
| `-h`, `--help` | Show help message. |

---

## The Bootstrapped Components

### 1. Matrix CI Caller Workflow (`.github/workflows/ci.yml`)
Thin caller workflow invoking `treevg/github-workflows/.github/workflows/ci.yml@v1` to execute cross-platform matrix testing (Ubuntu + macOS) and PR changelog validation.

### 2. SemVer Release Caller Workflow (`.github/workflows/release.yml`)
Thin caller workflow invoking `treevg/github-workflows/.github/workflows/release.yml@v1` for official SemVer releases on `main`, running test/prep/deploy hooks, atomic commit/tag, and GitHub Releases.

### 3. Branch Snapshot Caller Workflow (`.github/workflows/snapshot.yml`)
Thin caller workflow invoking `treevg/github-workflows/.github/workflows/snapshot.yml@v1` for branch pre-releases, running test/prep/staging deploy hooks, and GitHub Pre-Releases.

### 4. Modular Test Action Stub (`.ci/actions/run-tests/action.yml`)
A composite GitHub Action invoked by `ci.yml`, `release.yml`, and `snapshot.yml`. Houses the test execution commands (e.g., pytest, npm test, cargo test, ./tests/run_tests.sh) in a single shared file so tests are configured in one place across all workflows.

### 5. Modular Codebase Preparation Stub (`.ci/actions/prepare-release/action.yml`)
A composite GitHub Action invoked prior to committing releases and snapshots. Allows applying on-the-fly modifications to the codebase (e.g., bumping `package.json`, `Cargo.toml`, or source version constants). Any modified tracked files are automatically committed into the release.

### 6. Modular Deploy Action Stub (`.ci/actions/deploy/action.yml`)
A composite GitHub Action invoked directly at the end of `release.yml` (production) and `snapshot.yml` (staging). Houses deployment logic for package registries (npm/PyPI), Docker containers, cloud deployments, and notifications. Automatically skipped during dry runs.
