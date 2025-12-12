# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Testing:**
- `bats tests/integration/` - Run integration test suite (20 tests - primary suite)
- `bats tests/unit/` - Run unit tests (reserved for complex logic when added)
- `act` - Test GitHub Actions CI workflow locally (requires Docker)

**Testing Philosophy:**
- Integration-first approach: Functions are thin shell wrappers, integration tests provide optimal coverage
- See [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) for detailed testing philosophy and guidelines

**Development workflow:**
- `shellcheck autoload/*` - Validate shell scripts
- `chmod +x autoload/*` - Make functions executable
- Test with `bats tests/integration/`

**VS Code tasks available:**
- "Run All Tests (Bats)" - Execute full test suite
- "Validate Shell Scripts" - Run shellcheck on all functions

## Architecture

This is a zsh functions collection with a modular, autoloadable design. Each function in `autoload/` is self-contained and follows zsh autoloading conventions.

**Core Structure:**
- `autoload/` - Autoloadable zsh function files (claude, codex, gemini, qwen, brew-list-formulas, hello)
- `lib/` - Shared library files
  - `_common_proxy_lib` - Common functionality for AI proxy functions
- `tests/integration/` - Integration test suite validating full script execution workflows (20 tests)
- `tests/unit/` - Unit tests (reserved for complex logic as codebase evolves)
- `docs/` - Documentation including testing strategy and guidelines
- `.github/workflows/ci.yml` - GitHub Actions CI/CD pipeline

**AI Proxy Functions:**

The core AI proxy functions (claude, codex, gemini, qwen) are transparent wrappers around npm packages:
- **claude**: `@anthropic-ai/claude-code` (Node.js ≥18)
- **codex**: `@openai/codex` (Node.js ≥20)
- **gemini**: `@google/gemini-cli` (Node.js ≥20)
- **qwen**: `@qwen-code/qwen-code` (Node.js ≥20)

Each proxy function:
1. Sources the common proxy library with multi-location fallback strategy
2. Checks for required Node.js version
3. Verifies if the npm package is installed
4. Prompts user for installation if missing
5. Passes all arguments to the actual command

**Common Proxy Library (`lib/_common_proxy_lib`):**

Provides shared functionality to reduce code duplication:
- `_common_check_nodejs_version`: Validates Node.js version requirements
- `_common_is_installed`: Checks if npm package is installed globally
- `_common_prompt_install`: Handles user prompts for package installation
- `_common_install_package`: Installs npm packages globally with error handling
- `_common_run_command`: Executes commands with intelligent error diagnostics and troubleshooting guidance

**Enhanced Error Handling:**

The library provides intelligent error diagnostics through:
- `_common_diagnose_command_not_found`: Performs comprehensive diagnostics for exit code 127
  - Checks package directory existence
  - Validates package.json presence
  - Verifies binary file location
  - Inspects npm global bin symlinks
- `_common_format_error_message`: Provides contextual error messages and troubleshooting steps for common exit codes:
  - Exit 127: Command not found (includes full diagnostics and reinstall instructions)
  - Exit 126: Permission denied (executable permissions guidance)
  - Exit 1: Generic failure (general troubleshooting steps)
  - Exit 2: Invalid arguments (syntax help)
  - Exit 130: User interruption (Ctrl+C)
  - Other codes: General troubleshooting guidance

Error messages include:
- Clear cause identification
- Actionable troubleshooting steps with specific commands
- Package-specific diagnostic information
- Structured output with visual indicators (✓/✗)

**Library Loading Strategy:**

The proxy functions use a two-tier sourcing approach to handle both autoloaded and directly-executed scenarios:

```bash
# Load zsh/parameter module for functions_source array
zmodload zsh/parameter 2>/dev/null

# Primary: Use functions_source to get actual file path (works with autoload)
if [[ -v functions_source[$0] ]]; then
    source "${functions_source[$0]:h}/../lib/_common_proxy_lib" 2>/dev/null && sourced=1
fi

# Fallback: Relative path for direct execution and symlinks
if [[ ! -v sourced ]]; then
    source "${0:A:h}/../lib/_common_proxy_lib" 2>/dev/null && sourced=1
fi

# Error if both attempts fail
if [[ ! -v sourced ]]; then
    echo "Error: Could not load common proxy library." >&2
    return 1
fi
```

**How it works:**

1. **Autoloaded functions** (primary use case): When a function is autoloaded via `fpath`, `$0` contains just the function name (e.g., `claude`), and `${0:A}` resolves to `$PWD/$0` (current working directory + function name), not the actual file path. The `functions_source` array from the `zsh/parameter` module provides the actual source file path, enabling reliable library loading regardless of the current working directory.

2. **Direct execution and symlinks** (fallback): When the script is executed directly (e.g., `./autoload/claude`) or via symlink, `$functions_source` is not set. The `${0:A:h}` expansion resolves the absolute path (following symlinks via `:A`), allowing the library to be found relative to the script location.

**Function Architecture Pattern:**
Each function follows this structure:
```bash
#!/usr/bin/env zsh

# Source common library if needed (for proxy functions)
# [Multi-location sourcing as shown above]

# Helper functions with _ prefix
_private_helper() { ... }

# Main function
function_name() {
    # Implementation with proper error handling
    # Uses local variables and proper quoting
}

# Auto-execute when called directly
function_name "$@"
```

**Key Design Principles:**
- Functions are autoloadable and self-contained
- Transparent proxy pattern with automatic dependency management
- Shared libraries for common functionality (reduces duplication)
- Comprehensive error handling with proper exit codes
- Interactive prompts for user confirmation (e.g., package installation)
- Dependency validation before execution
- Security-conscious scripting practices with user warnings
- Multi-location library loading for deployment flexibility

**Development Environment:**
- Supports both manual testing and automated Bats testing
- VS Code integration with predefined tasks
- Functions used directly from cloned repository via zsh's `fpath`
- GitHub Actions CI/CD for automated testing and validation

## Dependencies

**System Requirements:**
- Zsh shell (primary requirement)
- Bats testing framework for development (`brew install bats-core`)

**Function-specific dependencies:**
- `claude`: Node.js ≥18, npm (auto-managed by the function)
- `codex`: Node.js ≥20, npm (auto-managed by the function)
- `gemini`: Node.js ≥20, npm (auto-managed by the function)
- `qwen`: Node.js ≥20, npm (auto-managed by the function)
- `brew-list-formulas`: jq, Homebrew

## Installation Process

Functions are used directly from the cloned repository:
1. Clone: `git clone https://github.com/cearley/zsh-functions.git ~/.zsh-functions`
2. Add to `~/.zshrc`: `fpath=("$HOME/.zsh-functions/autoload" $fpath)`
3. Add to `~/.zshrc`: `autoload -Uz $HOME/.zsh-functions/autoload/*`
4. Functions become available as shell commands

## Code Style Guidelines

- Follow zsh scripting best practices with proper error handling (`set -e`)
- Use `local` for variable scoping
- Implement comprehensive input validation
- Include user-friendly error messages to stderr
- Use descriptive variable names and consistent formatting
- Test functions with integration tests; add unit tests only for complex algorithmic logic
- See [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) for when to add unit tests

## Continuous Integration

The repository includes a GitHub Actions CI workflow (`.github/workflows/ci.yml`) that automatically:

**CI Pipeline Steps:**
1. **Environment Setup**: Uses Ubuntu 22.04 container with zsh, jq, shellcheck, git, curl
2. **Node.js Installation**: Installs Node.js 20.x for function dependencies
3. **Bats Installation**: Installs Bats testing framework from source
4. **Static Analysis**: Runs shellcheck on all source functions
5. **Functions Testing**: Validates that function files exist and are executable
6. **Test Execution**: Runs the complete Bats test suite

**Local CI Testing with act:**
You can test the GitHub Actions workflow locally using [act](https://nektosact.com/):

```bash
# Install act (macOS with Homebrew)
brew install act

# Run the CI workflow locally
act

# Run specific job
act -j test

# Use medium runner for more resources
act -P ubuntu-latest=catthehacker/ubuntu:act-22.04
```

**act Benefits:**
- **Fast Feedback**: Test workflow changes without pushing to GitHub
- **Local Development**: Catch CI issues before committing
- **Resource Efficient**: Uses Docker containers to simulate GitHub's environment

**act Requirements:**
- Docker installed and running
- Sufficient disk space for Ubuntu container images
- Network access for downloading dependencies

**Important Notes:**
- Some integration tests are conditionally skipped in CI environments where Node.js is installed system-wide
- The CI uses Ubuntu 22.04 container for consistent, clean testing environment
- All integration tests should pass for successful CI completion
- See [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) for our integration-first testing philosophy