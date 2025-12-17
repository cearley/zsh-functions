# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Improved fpath syntax in README and documentation to use proper array handling with "${fpath[@]}"
- Clarified function exclusion approach to use individual autoload commands
- Updated installation instructions to reflect correct zsh autoloading syntax

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