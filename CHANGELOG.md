# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [unreleased]

### Changed
- Relocated project-specific composite actions from `.github/actions/*` to `.ci/actions/*` to cleanly decouple repository customization from GitHub Actions workflow orchestration.
- Relocated CI release script `tools/release_version.py` into `.github/scripts/release_version.py` to keep the project root clean and isolate GitHub Actions automation inside `.github/`.

## [3.0.0] -- 2026-11-26

### Added
- Modular composite GitHub Actions (`.github/actions/run-tests/action.yml`, `.github/actions/prepare-release/action.yml`, and `.github/actions/deploy/action.yml`) to cleanly separate test execution, codebase preparation, and deployment steps from workflow definitions.
- Dedicated workflows splitting release engineering: `release.yml` (official SemVer releases on main with `patch|minor|major` dropdown) and `snapshot.yml` (branch pre-releases on any branch).
- Atomic post-release deployment execution in `release.yml` and `snapshot.yml` running *before* git commits and tags are pushed, preventing unreleased artifacts or failed deployments from corrupting git history and changelogs.
- `-u` / `--update` flag to `git ci-init` to safely upgrade CI/CD workflows and release tooling in existing repositories without overwriting `CHANGELOG.md` or custom actions in `.github/actions/`.
- `run_tests` and `dry_run` input checkboxes to `snapshot.yml` and `dry_run` to `release.yml` for previewing release plans safely.
- Pull Request changelog linter in `ci.yml` ensuring `CHANGELOG.md` is updated on PRs (supports `[skip changelog]` in title).
- Branch snapshot pre-release versioning: bumps patch level and appends `-<branch>.<sequence>` suffix (e.g., `1.3.4-feature-my-branch-name.1`), publishing as a GitHub Pre-Release while keeping `CHANGELOG.md` untouched.

## [1.1.0] -- 2026-11-26

### Changed
- Switched to Git tag-based versioning, eliminating redundant VERSION files.
- Updated SemVer bump tooling and GitHub Actions workflows to read from git tags.

## [1.0.0] -- 2026-11-26

### Added
- Initial release of `git-ci-init`.
- CLI generator bootstrapping standardized CI, release workflows, versioning, testing, and changelog into any Git repository.
- Cross-platform GitHub Actions CI matrix workflow (Ubuntu + macOS).
- GitHub Actions automated SemVer release pipeline (`patch`, `minor`, `major`).
- SemVer version bumper and Keep a Changelog synchronizer (`tools/release_version.py`).
- Automated test runner with assertion library (`tests/run_tests.sh`).
- PATH installation script (`install.sh`).
