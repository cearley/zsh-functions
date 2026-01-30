# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `ZSH_FUNCTIONS_DIR` environment variable fallback for library loading in non-standard environments (e.g., Claude Code)

### Changed
- Updated all proxy functions (codex, gemini, qwen, openspec) with three-tier library resolution
- Improved documentation in README.md and CLAUDE.md

## [1.0.1] - 2025-12-17

### Changed
- Updated release workflow to use ncipollo/release-action
- Improved fpath syntax and autoload instructions in documentation

## [1.0.0] - 2025-12-17

### Added
- Initial release of zsh functions collection
- Codex AI proxy function
- Gemini AI proxy function
- Qwen AI proxy function
- OpenSpec AI proxy function
- Brew-list-formulas utility function
- Common proxy library for shared functionality
- Comprehensive integration tests
- Documentation and usage guides

### Changed
- Project structure with autoload/ and lib/ directories
- Implementation using zsh autoloadable functions
- Shared library approach for common functionality

### Fixed
- Shellcheck compliance
- Proper error handling with exit codes
- Security warnings for package installations

### Security
- Added security notices for npm package installations
- Improved input validation for user responses

[Unreleased]: https://github.com/cearley/zsh_functions/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/cearley/zsh_functions/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/cearley/zsh_functions/releases/tag/v1.0.0
