# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [unreleased]
- Split release engineering into dedicated workflows: `release.yml` (official SemVer releases on main with `patch|minor|major` dropdown) and `snapshot.yml` (branch pre-releases on any branch).
- Added `run_tests` and `dry_run` input checkboxes to `snapshot.yml` and `dry_run` to `release.yml` for previewing release plans safely.
- Added Pull Request changelog linter in `ci.yml` ensuring `CHANGELOG.md` is updated on PRs (supports `[skip changelog]` in title).
- Added branch snapshot pre-release versioning: bumps patch level and appends `-<branch>.<sequence>` suffix (e.g., `1.3.4-feature-my-branch-name.1`), publishing as a GitHub Pre-Release while keeping `CHANGELOG.md` untouched.

## [1.1.0] -- 2026-11-26
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
