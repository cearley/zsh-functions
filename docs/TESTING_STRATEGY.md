# Testing Strategy for AI Agents

This document outlines the testing philosophy and strategy for the zsh-functions repository, intended for AI agents working with this codebase. It includes the analysis that led to our current approach and guidelines for future development.

## Executive Summary

**Current Approach:** Integration-first testing with minimal unit tests

**Rationale:** Our functions are thin shell wrappers around external commands (npm, node, CLI tools), not complex algorithmic code. Integration tests provide superior coverage for this type of codebase.


---

## Analysis: Unit vs Integration Testing

### Our Codebase Characteristics

The zsh-functions repository contains autoloadable shell functions that:
- Validate dependencies (Node.js version, npm packages)
- Prompt users for installation consent
- Execute external commands (npm install, CLI tools)
- Handle and propagate errors

Each function (~100 LOC) follows this pattern:
```bash
check_dependencies() → prompt_user() → install_if_needed() → execute_command()
```

### What We Tested Before (Redundant Approach)

**Unit Tests (36 tests - REMOVED):**
- Isolated helper function testing using in-process bash function mocking
- Tested: version validation, package detection, npm install execution
- Coverage: Edge cases like boundary versions (v18.0.0), malformed strings
- Execution: Fast (~2-3 seconds)

**Integration Tests (20 tests - KEPT):**
- Full script execution via `zsh "$SCRIPT"` with PATH-based mocks
- Tested: Complete workflow from invocation to command execution
- Coverage: User interaction, stdin/stdout, argument passing, error propagation
- Execution: Slightly slower (~5-8 seconds)

### The Overlap Problem

**Critical Finding:** 95% of validation logic was tested by BOTH suites

Example: Node.js version checking
- Unit test: Mocked `node()` bash function, called `_claude_check_nodejs_version()` directly
- Integration test: Created mock `node` executable in PATH, ran full script via zsh

**Result:** Both tested the same logic path, just with different mocking mechanisms.

### Why Integration-Only Makes Sense

**1. Nature of the Code**
- These are **glue scripts**, not **algorithms**
- No complex parsing logic requiring mathematical proofs
- No expensive operations to justify isolation
- Real bugs manifest in shell execution context (PATH resolution, quoting, zsh behavior)

**2. Helper Function Simplicity**
Most helpers are trivial command wrappers:
```bash
_claude_is_installed() {
    npm list -g "$claude_pkg" >/dev/null 2>&1  # Just runs npm
}
```
This doesn't need isolated testing - integration tests fully exercise it.

**3. Real-World Validation**
Integration tests prove the scripts work as **actual autoloaded functions**, which is how users consume them.

**4. Maintenance Burden**
- Every change required updating parallel test structures
- 40% reduction in test code to maintain
- Single source of truth for expected behavior

---

## Current Testing Strategy

### Integration Tests (Primary Suite)

**Location:** `tests/integration/`

**Coverage per function:**
1. Full execution with all dependencies present
2. Missing package installation workflow (user accepts)
3. Installation declined workflow (user rejects)
4. Argument passing to underlying command
5. Command execution failure handling

**Mocking Approach:**
- PATH-based executable mocks in temporary directory
- Stdin piping for user interaction simulation (`echo 'y' | zsh "$SCRIPT"`)
- Exit code validation for error propagation

**Example Test:**
```bash
@test "claude script prompts and installs missing package when user agrees" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_not_installed "claude" "@anthropic-ai/claude-code"
    create_mock_command "claude"

    run bash -c "echo 'y' | zsh '$CLAUDE_SCRIPT' test-arg"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Successfully installed"* ]]
    [[ "$output" == *"claude executed with args: test-arg"* ]]
}
```

### Unit Tests (Reserved for Future Complexity)

**Location:** `tests/unit/` (currently empty but structure retained)

**When to Add Unit Tests:**

Unit tests should ONLY be added when functions develop:

1. **Complex Parsing Logic**
   ```bash
   # Example: Semantic version comparison beyond simple integer checks
   _compare_semver() {
       # Complex logic with multiple edge cases
       # prerelease handling, build metadata, wildcards, etc.
   }
   ```

2. **Algorithmic Code**
   ```bash
   # Example: Data transformation or calculations
   _calculate_optimal_chunk_size() {
       # Mathematical logic requiring verification
   }
   ```

3. **Stateful Logic**
   ```bash
   # Example: Multi-step state machines
   _track_installation_state() {
       # Complex state transitions
   }
   ```

4. **Expensive External Operations**
   ```bash
   # Example: If we started calling slow APIs
   _fetch_remote_manifest() {
       # Would want to mock for speed in unit tests
   }
   ```

**Current Functions DO NOT Meet These Criteria**

---

## Guidelines for Future Development

### Adding New Functions

**Step 1: Assess Complexity**

Ask yourself:
- Is this primarily calling external commands?
  → **Integration tests only**
- Does this contain complex parsing/validation logic?
  → **Consider unit tests for the complex parts**
- Does this perform calculations or transformations?
  → **Unit tests for the algorithm, integration for the workflow**

**Step 2: Write Integration Tests First**

Always start with integration tests that validate the complete user experience:
```bash
@test "function_name executes successfully with valid input" { ... }
@test "function_name handles missing dependencies gracefully" { ... }
@test "function_name propagates errors correctly" { ... }
```

**Step 3: Add Unit Tests Only If Justified**

If you find yourself writing complex logic within a helper function, extract it and add unit tests:

```bash
# BAD: Complex logic in helper without unit tests
_helper() {
    # 50 lines of complex parsing logic
}

# GOOD: Extracted logic with unit tests
_parse_complex_format() {
    # 50 lines of parsing logic
    # Has unit tests in tests/unit/
}

_helper() {
    local parsed=$(_parse_complex_format "$input")
    # Use parsed data
}
```

### Example: When Unit Tests Would Be Valuable

**Hypothetical Scenario:** Adding a function that downloads and validates checksums

```bash
#!/usr/bin/env zsh

# Complex logic that SHOULD have unit tests
_validate_checksum() {
    local file="$1"
    local expected_hash="$2"
    local algorithm="${3:-sha256}"

    # Complex: Multiple hash algorithms, error handling, format parsing
    case "$algorithm" in
        sha256) local actual=$(shasum -a 256 "$file" | cut -d' ' -f1) ;;
        sha512) local actual=$(shasum -a 512 "$file" | cut -d' ' -f1) ;;
        md5) local actual=$(md5 -q "$file") ;;
        *) return 1 ;;
    esac

    [[ "$actual" == "$expected_hash" ]]
}

# Simple workflow that should use integration tests
download_with_verification() {
    _check_dependencies || return 1
    _download_file "$url" "$output" || return 1
    _validate_checksum "$output" "$hash" || return 1  # Tested via unit test
}
```

**Testing Approach:**
- **Unit tests:** Test `_validate_checksum()` with various algorithms, formats, edge cases
- **Integration tests:** Test full `download_with_verification()` workflow with mocked downloads

---

## Testing Commands

```bash
# Run integration tests (primary suite)
bats tests/integration/

# Run unit tests (when they exist for complex logic)
bats tests/unit/

# Run full test suite
bats tests/unit/ tests/integration/

# Test GitHub Actions CI locally
act

# Validate shell scripts
shellcheck autoload/*
```

---

## CI/CD Integration

The GitHub Actions CI workflow (`.github/workflows/ci.yml`) runs:
1. shellcheck on all functions
2. Integration test suite via Bats
3. (Future) Unit tests when complex logic is added

**Expected:** All integration tests must pass for CI to succeed.

---

## Benefits of This Approach

**Simplicity**
- Fewer tests to maintain (40% reduction)
- Single source of truth for behavior
- Clear mental model: "Test the full workflow"

**Realism**
- Tests mirror actual user experience
- Catches shell-specific bugs (PATH, quoting, zsh quirks)
- Validates autoloading behavior

**Scalability**
- Strategy adapts as complexity grows
- Clear guidelines for when to add unit tests
- Prevents premature abstraction

**Maintenance**
- Tests align with code structure
- No parallel test hierarchies to keep in sync
- Easier to refactor with fewer test dependencies

---

## Key Takeaway

**Test at the appropriate level of abstraction for the code's nature.**

- Thin shell wrappers → Integration tests
- Complex algorithms → Unit tests
- Hybrid functions → Both, targeting the right layers

Our current codebase is 100% thin wrappers, so integration tests provide optimal coverage with minimal maintenance burden.

---

## Document History

- **2025-10-03:** Initial strategy documentation
  - Analyzed unit vs integration test coverage
  - Removed redundant unit tests (36 tests)
  - Established integration-first approach
  - Defined criteria for future unit test addition
