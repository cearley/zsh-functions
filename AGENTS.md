# AGENTS.md

This file provides guidance for AI agents (Claude, Qwen, etc.) when working with code in this repository.

## Overview

This is a collection of useful zsh shell functions that serve as transparent proxies for various AI command-line tools (Claude, Codex, Gemini, Qwen) and other utilities. The functions automatically handle dependency installation and provide a consistent interface to external tools.

The project is structured around zsh autoloadable functions that are loaded dynamically when first called, making them efficient to use without consuming memory unnecessarily.

## Development Commands

**Testing:**
- `bats tests/integration/` - Run integration test suite (primary suite)
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

## Project Structure

```
├── autoload/              # Zsh autoloadable function files (loaded when first called)
│   ├── codex              # Codex AI proxy
│   ├── gemini             # Gemini AI proxy
│   ├── qwen               # Qwen AI proxy
│   ├── openspec           # OpenSpec AI proxy
│   └── brew-list-formulas # Homebrew utility
├── examples/              # Example function templates
│   └── hello              # Demo function
├── lib/                   # Shared library files
│   └── _common_proxy_lib  # Common functionality for AI proxies
├── tests/                 # Test suite
│   ├── unit/              # Unit tests
│   ├── integration/       # Integration tests
│   └── helpers.bash       # Test utilities
├── docs/                  # Documentation files
├── .vscode/               # VS Code configuration
├── .github/               # GitHub configuration (workflows, etc.)
└── README.md             # Main project documentation
```

## Key Components

### AI Proxy Functions

The core of the project consists of AI command proxy functions:
- **codex**: Transparent proxy to `@openai/codex` npm package (Node.js ≥20)
- **gemini**: Transparent proxy to `@google/gemini-cli` npm package (Node.js ≥20)
- **qwen**: Transparent proxy to `@qwen-code/qwen-code` npm package (Node.js ≥20)
- **openspec**: Transparent proxy to `@fission-ai/openspec` npm package (Node.js ≥20)

Each function follows the same pattern:
1. Checks for required Node.js version
2. Verifies if the required npm package is installed
3. Prompts the user to install if missing
4. Passes all arguments to the actual command

### Common Library

The `lib/_common_proxy_lib` file contains shared functionality:
- `_common_check_nodejs_version`: Validates Node.js version
- `_common_is_installed`: Checks if package is installed
- `_common_prompt_install`: Handles user prompts for installation
- `_common_install_package`: Installs packages globally
- `_common_run_command`: Executes commands with error handling
- `_common_diagnose_command_not_found`: Performs diagnostics for command not found errors
- `_common_format_error_message`: Provides contextual error messages and troubleshooting steps

The common library provides enhanced error handling with contextual diagnostics for common exit codes:
- Exit 127: Command not found (includes full diagnostics and reinstall instructions)
- Exit 126: Permission denied (executable permissions guidance)
- Exit 1: Generic failure (general troubleshooting steps)
- Exit 2: Invalid arguments (syntax help)
- Exit 130: User interruption (Ctrl+C)
- Other codes: General troubleshooting guidance

### Utility Functions

- **brew-list-formulas**: Lists Homebrew formulas from specified taps

## Installation and Usage

### Installing the Functions

1. Clone the repository:
   ```bash
   git clone https://github.com/cearley/zsh-functions.git ~/.zsh-functions
   ```

2. Add to your `~/.zshrc`:
   ```bash
   # Add zsh-functions to fpath
   fpath=("$HOME/.zsh-functions/autoload" "${fpath[@]}")

   # Autoload all functions (default behavior)
   autoload -Uz *

   # OR, to selectively exclude functions (e.g., if you have native installations):
   # autoload -Uz gemini qwen openspec brew-list-formulas
   # (excluding codex in this example since user has it via Homebrew)
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### Using the Functions

After installation, the functions are available directly from the command line:
```bash
codex "Write a function to parse JSON"
gemini "Explain the architecture of this codebase"
qwen "Refactor this code for better performance"
openspec "Document this API endpoint"
brew-list-formulas
```

## Architecture

This is a zsh functions collection with a modular, autoloadable design. Each function in `autoload/` is self-contained and follows zsh autoloading conventions.

**Core Structure:**
- `autoload/` - Autoloadable zsh function files (codex, gemini, qwen, openspec, brew-list-formulas)
- `examples/` - Example function templates (hello)
- `lib/` - Shared library files
  - `_common_proxy_lib` - Common functionality for AI proxy functions
- `tests/` - Test suite including integration and unit tests
  - `integration/` - Integration tests validating full script execution workflows
  - `unit/` - Unit tests (reserved for complex logic as codebase evolves)
- `docs/` - Documentation including testing strategy and guidelines
- `.github/workflows/ci.yml` - GitHub Actions CI/CD pipeline

**AI Proxy Functions:**

The core AI proxy functions (codex, gemini, qwen, openspec) are transparent wrappers around npm packages:
- **codex**: `@openai/codex` (Node.js ≥20)
- **gemini**: `@google/gemini-cli` (Node.js ≥20)
- **qwen**: `@qwen-code/qwen-code` (Node.js ≥20)
- **openspec**: `@fission-ai/openspec` (Node.js ≥20)

Each proxy function:
1. Sources the common proxy library with multi-location fallback strategy
2. Checks for required Node.js version
3. Verifies if the npm package is installed
4. Prompts user for installation if missing
5. Passes all arguments to the actual command

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

1. **Autoloaded functions** (primary use case): When a function is autoloaded via `fpath`, `$0` contains just the function name (e.g., `qwen`), and `${0:A}` resolves to `$PWD/$0` (current working directory + function name), not the actual file path. The `functions_source` array from the `zsh/parameter` module provides the actual source file path, enabling reliable library loading regardless of the current working directory.

2. **Direct execution and symlinks** (fallback): When the script is executed directly (e.g., `./autoload/qwen`) or via symlink, `$functions_source` is not set. The `${0:A:h}` expansion resolves the absolute path (following symlinks via `:A`), allowing the library to be found relative to the script location.

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

## Development

### Requirements

- **Zsh shell**
- **Bats** (for testing): `brew install bats-core`
- **Node.js ≥20** (for codex, gemini, qwen, and openspec functions)

### Testing

Tests use the Bats testing framework:

```bash
# Run all tests
bats tests/unit/ tests/integration/

# Run specific test types
bats tests/unit/        # Unit tests only
bats tests/integration/ # Integration tests only
```

The project follows an integration-first testing strategy, as the functions are thin shell wrappers around external commands rather than complex algorithms. Integration tests provide superior coverage for this type of codebase.

### Adding New Functions

1. Create function in `autoload/`
2. Follow zsh function conventions:
   ```bash
   #!/usr/bin/env zsh

   # Source common library if needed (for proxy functions)
   # source "${0:A:h}/../lib/_common_proxy_lib" 2>/dev/null || {
   #     echo "Error: Could not load common proxy library." >&2
   #     return 1
   # }

   # Function description
   function_name() {
       # Implementation
   }

   # Auto-execute if called directly
   function_name "$@"
   ```

3. Make executable: `chmod +x autoload/function_name`
4. Test: `bats tests/`

## Build and CI/CD

The project uses GitHub Actions for CI/CD:

- **Shellcheck**: Validates shell scripts with `shellcheck -s bash --severity=warning autoload/*`
- **Function validation**: Ensures all autoloadable functions exist and are executable
- **Integration tests**: Runs Bats integration tests

## Development Philosophy

The project follows these key principles:

1. **Autoloadable Functions**: Functions are loaded only when first used
2. **Transparent Proxies**: Functions automatically handle dependency installation
3. **Integration-First Testing**: Focus on end-to-end workflows rather than isolated unit tests
4. **Shared Libraries**: Common functionality is abstracted to reduce code duplication
5. **Security Awareness**: Includes security notices when installing external packages

## Key Features

1. **Automatic Dependency Management**: Functions check for and install required Node.js packages
2. **User Confirmation**: Prompts users before installing packages
3. **Proper Error Handling**: Comprehensive error handling with exit codes
4. **Security Warnings**: Notifies users about installing external packages
5. **Consistent Interface**: All AI proxy functions follow the same pattern
6. **Zsh Autoloading**: Efficient memory usage through zsh's autoloading feature

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

## Contributing

When contributing to this project:
- Follow the zsh function conventions outlined in the README
- Add integration tests for new functionality
- Use the common library for shared functionality when appropriate
- Maintain the security-conscious approach with user confirmations
- Ensure all CI checks pass before submitting pull requests

## Dependencies

**System Requirements:**
- Zsh shell (primary requirement)
- Bats testing framework for development (`brew install bats-core`)

**Function-specific dependencies:**
- `codex`: Node.js ≥20, npm (auto-managed by the function)
- `gemini`: Node.js ≥20, npm (auto-managed by the function)
- `qwen`: Node.js ≥20, npm (auto-managed by the function)
- `openspec`: Node.js ≥20, npm (auto-managed by the function)
- `brew-list-formulas`: jq, Homebrew

## Code Style Guidelines

- Follow zsh scripting best practices with proper error handling (`set -e`)
- Use `local` for variable scoping
- Implement comprehensive input validation
- Include user-friendly error messages to stderr
- Use descriptive variable names and consistent formatting
- Test functions with integration tests; add unit tests only for complex algorithmic logic
- See [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) for when to add unit tests

## Agent Memories
- Fixed common proxy library loading issue in zsh_functions project. Original problem: AI proxy functions (claude, codex, gemini, qwen) failed with 'Error: Could not load common proxy library' when deployed to ~/.local/share/zsh-functions/. Solution: Implemented a multi-location sourcing approach that tries multiple paths to locate the library: 1) calculated project root directory approach, 2) original relative path for compatibility, 3) cd/pwd absolute path for symlinked/copy scenarios. All integration tests pass confirming the fix.