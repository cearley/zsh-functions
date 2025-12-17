# Project Summary

## Overall Goal
To maintain and improve a collection of zsh shell functions that serve as transparent proxies for various AI command-line tools (Claude, Codex, Gemini, Qwen) and other utilities, with comprehensive testing and proper code organization.

## Key Knowledge
- **Technology Stack**: Zsh shell functions, Node.js (≥18 for Claude, ≥20 for others), npm, Bats testing framework
- **Architecture**: Functions are structured as zsh autoloadable functions with a shared library `_common_proxy_lib` in a separate `lib/` directory
- **Directory Structure**: `autoload/` contains autoloadable functions, `lib/` contains shared libraries, `tests/` contains integration and unit tests
- **Installation**: Uses `fpath=("$HOME/.zsh-functions/autoload" $fpath)` and `autoload -Uz $HOME/.zsh-functions/autoload/*` in `.zshrc`
- **CI/CD**: GitHub Actions workflow with shellcheck (using `--severity=warning` to ignore SC1091 info messages), dependency installation, and integration tests
- **Testing Strategy**: Integration-first approach with Bats framework, following the principle that these are "glue scripts" not complex algorithms
- **Code Conventions**: Functions use zsh-specific syntax like `${0:A:h}` for path resolution and include security notices when prompting for package installation

## Recent Actions
- [DONE] Moved `_common_proxy_lib` from `autoload/` to separate `lib/` directory to properly separate autoloadable functions from library files
- [DONE] Fixed SC2145 shellcheck error in `brew-list-formulas` by separating string and array arguments in echo statement
- [DONE] Added shellcheck source directives (`# shellcheck source=../lib/_common_proxy_lib`) to all functions that source the common library
- [DONE] Updated CI workflow to use `shellcheck -s bash --severity=warning autoload/*` to prevent informational messages from breaking the build
- [DONE] Added security warnings to the common library's installation prompts
- [DONE] Improved input validation with robust response handling for installation prompts
- [DONE] Consistent syntax usage across all functions (using `[[` instead of `[`)
- [DONE] Created shared library functionality to reduce code duplication in AI proxy functions
- [DONE] Updated README documentation to reflect new directory structure and clarify autoloadable function purpose

## Current Plan
- [DONE] Maintain proper separation of autoloadable functions and library files
- [DONE] Ensure all integration tests pass (41 tests currently passing)
- [DONE] Fix all shellcheck issues that were causing CI failures
- [TODO] Continue maintaining the integration-first testing approach as the primary testing strategy
- [TODO] Add new functions following the established patterns and conventions
- [TODO] Keep CI/CD pipeline passing with all tests and shellcheck validation

---

## Summary Metadata
**Update time**: 2025-10-04T02:26:50.766Z 
