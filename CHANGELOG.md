# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [unreleased]
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
