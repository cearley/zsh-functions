# Library Files

This directory contains shared library files for the zsh functions in the autoload directory. These are not meant to be autoloaded directly but are sourced by the autoloadable functions as needed.

## Available Libraries

- `_common_proxy_lib`: Shared functionality for AI command proxy functions (claude, codex, gemini, qwen)
  - Node.js version checking
  - Package installation validation
  - User prompting for installations
  - Command execution with error handling