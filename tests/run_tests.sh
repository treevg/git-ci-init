#!/usr/bin/env bash
set -e

# ==============================================================================
# Automated Test Suite for git-ci-init
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GIT_CI_INIT="$ROOT_DIR/git-ci-init"

GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[0;34m"
BOLD="\033[1m"
RESET="\033[0m"

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

if [ ! -x "$GIT_CI_INIT" ]; then
  echo -e "${RED}Error: git-ci-init executable not found at $GIT_CI_INIT${RESET}" >&2
  exit 1
fi

TEST_SANDBOX=$(mktemp -d /tmp/git-ci-init-tests-XXXXXX)
cleanup() {
  rm -rf "$TEST_SANDBOX"
}
trap cleanup EXIT

assert() {
  local condition="$1"
  local message="$2"
  if ! eval "$condition"; then
    echo -e "    ${RED}Assertion failed:${RESET} $message"
    return 1
  fi
  return 0
}

assert_file_exists() {
  local path="$1"
  assert "[ -e '$path' ]" "Expected file to exist: $path"
}

assert_file_not_exists() {
  local path="$1"
  assert "[ ! -e '$path' ]" "Expected file NOT to exist: $path"
}

assert_file_contains() {
  local path="$1"
  local expected="$2"
  assert "grep -F -q '$expected' '$path'" "Expected '$path' to contain '$expected'"
}

run_test() {
  local test_name="$1"
  TESTS_RUN=$((TESTS_RUN + 1))
  echo -e "${BLUE}Running:${RESET} $test_name..."

  if ( $test_name ); then
    echo -e "  ${GREEN}✓ PASSED${RESET}\n"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "  ${RED}✗ FAILED${RESET}\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# ==============================================================================
# Test Cases
# ==============================================================================

test_dry_run_leaves_directory_empty() {
  local repo="$TEST_SANDBOX/test_dry_run"
  mkdir -p "$repo" && cd "$repo"
  git init -b main >/dev/null 2>&1

  "$GIT_CI_INIT" -n >/dev/null

  assert_file_not_exists "$repo/.github/workflows/ci.yml"
  assert_file_not_exists "$repo/VERSION"
  assert_file_not_exists "$repo/CHANGELOG.md"
}

test_bootstrap_creates_all_files_without_version_file() {
  local repo="$TEST_SANDBOX/test_bootstrap"
  mkdir -p "$repo" && cd "$repo"
  git init -b main >/dev/null 2>&1
  git config user.email "test@test.com"
  git config user.name "Test User"
  echo "Initial" > init.txt && git add init.txt && git commit -m "Init" >/dev/null

  "$GIT_CI_INIT" --version "1.0.0" >/dev/null

  assert_file_exists "$repo/.github/workflows/ci.yml"
  assert_file_exists "$repo/.github/workflows/release.yml"
  assert_file_exists "$repo/.github/workflows/snapshot.yml"
  assert_file_exists "$repo/tools/release_version.py"
  assert_file_exists "$repo/CHANGELOG.md"
  assert_file_exists "$repo/tests/run_tests.sh"
  assert_file_not_exists "$repo/VERSION"

  assert_file_contains "$repo/CHANGELOG.md" "## [unreleased]"
  assert "[ '$(git tag -l v1.0.0)' = 'v1.0.0' ]" "Expected initial Git tag v1.0.0 to exist"
}

test_generated_test_suite_executes_successfully() {
  local repo="$TEST_SANDBOX/test_generated_tests"
  mkdir -p "$repo" && cd "$repo"
  git init -b main >/dev/null 2>&1

  "$GIT_CI_INIT" >/dev/null

  # Execute the generated test suite
  ./tests/run_tests.sh >/dev/null

  assert "[ $? -eq 0 ]" "Expected generated ./tests/run_tests.sh to pass"
}

test_generated_release_script_bumps_semver_from_tags() {
  local repo="$TEST_SANDBOX/test_generated_release"
  mkdir -p "$repo" && cd "$repo"
  git init -b main >/dev/null 2>&1
  git config user.email "test@test.com"
  git config user.name "Test User"
  echo "Init" > file.txt && git add file.txt && git commit -m "Init" >/dev/null

  "$GIT_CI_INIT" --version "0.1.0" >/dev/null

  python3 tools/release_version.py minor >/dev/null

  assert_file_contains "$repo/CHANGELOG.md" "## [0.2.0]"
  assert_file_contains "$repo/CHANGELOG.md" "## [unreleased]"
  assert_file_not_exists "$repo/VERSION"
}

test_skip_existing_files_without_force() {
  local repo="$TEST_SANDBOX/test_skip_existing"
  mkdir -p "$repo" && cd "$repo"
  git init -b main >/dev/null 2>&1

  echo "CUSTOM CHANGELOG" > CHANGELOG.md

  # Running without -f should preserve custom CHANGELOG.md
  "$GIT_CI_INIT" >/dev/null

  assert_file_contains "$repo/CHANGELOG.md" "CUSTOM CHANGELOG"
}

test_force_flag_overwrites_existing_files() {
  local repo="$TEST_SANDBOX/test_force_overwrite"
  mkdir -p "$repo" && cd "$repo"
  git init -b main >/dev/null 2>&1

  echo "CUSTOM CHANGELOG" > CHANGELOG.md

  # Running with -f should overwrite
  "$GIT_CI_INIT" -f >/dev/null

  assert_file_contains "$repo/CHANGELOG.md" "## [unreleased]"
}

test_generated_release_script_branch_snapshot_initial() {
  local repo="$TEST_SANDBOX/test_branch_snapshot_initial"
  mkdir -p "$repo" && cd "$repo"
  git init -b main >/dev/null 2>&1
  git config user.email "test@test.com"
  git config user.name "Test User"
  echo "Init" > file.txt && git add file.txt && git commit -m "Init" >/dev/null

  "$GIT_CI_INIT" --version "1.3.3" >/dev/null

  # Switch to a feature branch with a slash
  git checkout -b feature/my-branch-name >/dev/null 2>&1

  # Run snapshot release command
  export GITHUB_OUTPUT="$repo/github_output.txt"
  python3 tools/release_version.py snapshot >/dev/null

  # Version should increase patch from 1.3.3 to 1.3.4, slugify slashes to dashes, and append .1
  assert "grep -q 'version=1.3.4-feature-my-branch-name.1' '$GITHUB_OUTPUT'" "Expected version 1.3.4-feature-my-branch-name.1 in GITHUB_OUTPUT"
  
  # CHANGELOG.md should remain completely untouched for snapshots
  assert "! grep -q '1.3.4-feature-my-branch-name.1' '$repo/CHANGELOG.md'" "CHANGELOG.md should NOT contain snapshot header"
  assert_file_contains "$repo/CHANGELOG.md" "## [unreleased]"
  unset GITHUB_OUTPUT
}

test_generated_release_script_branch_snapshot_incrementing_suffix() {
  local repo="$TEST_SANDBOX/test_branch_snapshot_suffix"
  mkdir -p "$repo" && cd "$repo"
  git init -b main >/dev/null 2>&1
  git config user.email "test@test.com"
  git config user.name "Test User"
  echo "Init" > file.txt && git add file.txt && git commit -m "Init" >/dev/null

  "$GIT_CI_INIT" --version "1.0.0" >/dev/null

  # Switch to fix branch
  git checkout -b fix/branch-id >/dev/null 2>&1

  # Simulate existing snapshot tags (.1 and .2)
  git tag -a "v1.0.1-fix-branch-id.1" -m "Snapshot 1" >/dev/null 2>&1
  git tag -a "v1.0.1-fix-branch-id.2" -m "Snapshot 2" >/dev/null 2>&1

  # Run snapshot release command
  export GITHUB_OUTPUT="$repo/github_output.txt"
  python3 tools/release_version.py snapshot >/dev/null

  # Suffix should increment to .3
  assert "grep -q 'version=1.0.1-fix-branch-id.3' '$GITHUB_OUTPUT'" "Expected version 1.0.1-fix-branch-id.3 in GITHUB_OUTPUT"
  
  # CHANGELOG.md should remain untouched
  assert "! grep -q '1.0.1-fix-branch-id.3' '$repo/CHANGELOG.md'" "CHANGELOG.md should NOT contain snapshot header"
  assert_file_contains "$repo/CHANGELOG.md" "## [unreleased]"
  unset GITHUB_OUTPUT
}

test_generated_release_script_dry_run_leaves_changelog_untouched() {
  local repo="$TEST_SANDBOX/test_release_dry_run"
  mkdir -p "$repo" && cd "$repo"
  git init -b main >/dev/null 2>&1
  git config user.email "test@test.com"
  git config user.name "Test User"
  echo "Init" > file.txt && git add file.txt && git commit -m "Init" >/dev/null

  "$GIT_CI_INIT" --version "0.1.0" >/dev/null

  # Dry run should NOT update CHANGELOG.md
  python3 tools/release_version.py minor --dry-run >/dev/null
  assert "! grep -q '## \[0.2.0\]' '$repo/CHANGELOG.md'" "Dry run should NOT write to CHANGELOG.md"

  # Actual run should update CHANGELOG.md
  python3 tools/release_version.py minor >/dev/null
  assert_file_contains "$repo/CHANGELOG.md" "## [0.2.0]"
}

# ==============================================================================
# Suite Runner
# ==============================================================================

echo -e "${BOLD}=== Running git-ci-init Automated Test Suite ===${RESET}\n"

run_test test_dry_run_leaves_directory_empty
run_test test_bootstrap_creates_all_files_without_version_file
run_test test_generated_test_suite_executes_successfully
run_test test_generated_release_script_bumps_semver_from_tags
run_test test_skip_existing_files_without_force
run_test test_force_flag_overwrites_existing_files
run_test test_generated_release_script_branch_snapshot_initial
run_test test_generated_release_script_branch_snapshot_incrementing_suffix
run_test test_generated_release_script_dry_run_leaves_changelog_untouched

echo -e "${BOLD}=== Test Results ===${RESET}"
echo -e "Total:  $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${RESET}"
if [ "$TESTS_FAILED" -gt 0 ]; then
  echo -e "Failed: ${RED}$TESTS_FAILED${RESET}"
  exit 1
else
  echo -e "Failed: 0"
  echo -e "\n${GREEN}${BOLD}All tests passed successfully!${RESET}"
  exit 0
fi
