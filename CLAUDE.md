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
- `tests/integration/` - Integration test suite validating full script execution workflows
- `tests/unit/` - Unit tests (reserved for complex logic as codebase evolves)
- `docs/` - Documentation including testing strategy and guidelines
- `.github/workflows/ci.yml` - GitHub Actions CI/CD pipeline

**Function Architecture Pattern:**
Each function follows this structure:
```bash
#!/usr/bin/env zsh

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
- Comprehensive error handling with proper exit codes
- Interactive prompts for user confirmation (e.g., package installation)
- Dependency validation before execution
- Security-conscious scripting practices

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