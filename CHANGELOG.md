# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-01-01

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

### Removed
- Claude AI proxy function (now available through native installation)

### Changed
- Project structure with autoload/ and lib/ directories
- Implementation using zsh autoloadable functions
- Shared library approach for common functionality

### Fixed
- Shellcheck compliance
- Proper error handling with exit codes
- Security warnings for package installations

### Deprecated
- None

### Removed
- None

### Security
- Added security notices for npm package installations
- Improved input validation for user responses