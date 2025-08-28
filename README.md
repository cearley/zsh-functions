# Zsh Functions Collection

[![CI](https://github.com/craig/zsh_functions/actions/workflows/ci.yml/badge.svg)](https://github.com/craig/zsh_functions/actions/workflows/ci.yml)
![Shell](https://img.shields.io/badge/shell-zsh-blue.svg)
![macOS](https://img.shields.io/badge/macOS-supported-blue.svg)
![Node.js](https://img.shields.io/badge/node.js-18%2B-green.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)
![GitHub last commit](https://img.shields.io/github/last-commit/craig/zsh_functions)

A collection of useful zsh shell functions with comprehensive testing.

## Functions

See [Note on claude and gemini functions](#note-on-claude-and-gemini-functions)

### `claude`
Transparent proxy to the `@anthropic-ai/claude-code` npm package. Automatically handles installation and setup.

**Features:**
- Checks for Node.js (≥18) and npm
- Prompts to install package if missing
- Passes all arguments to the actual claude command

**Usage:**
```bash
claude "Write a hello world function"
```

### `gemini`
Transparent proxy to the `@google/gemini-cli` npm package. Automatically handles installation and setup.

**Features:**
- Checks for Node.js (≥20) and npm
- Prompts to install package if missing
- Passes all arguments to the actual gemini command

**Usage:**
```bash
gemini "Explain the architecture of this codebase"
gemini -m gemini-2.5-flash "Generate tests for this function"
```

### Note on claude and gemini functions
These functions are called 'transparent proxies' because they automatically check for and install the required npm packages (like `@anthropic-ai/claude-code` or `@google/gemini-cli`) the first time you use them. This is especially helpful for developers who use multiple Node.js environments (for example, with nvm or asdf), where global npm packages might not always be available in every environment.

**Advantages:**
- You don't have to manually install or update the CLI tools—they are installed for you if missing.
- You always get a working command, even if you switch Node.js versions or environments.
- The proxy functions work just like the real CLI tools, so you can use them the same way.

**Possible disadvantages:**
- The first run may be slower if the package needs to be installed.
- If you use many different Node.js environments, the package may be installed multiple times (once per environment).
- Automatic installation may not be desirable in some locked-down or production environments.

For most developers, this approach makes it much more convenient to use these tools without worrying about setup or environment issues.

### `brew-list-formulas`
Lists formulas from Homebrew taps.

**Usage:**
```bash
# List all taps
brew-list-formulas

# List formulas from specific tap
brew-list-formulas homebrew/core

# List from multiple taps
brew-list-formulas tap1/name tap2/name
```

## Installation

1. **Copy functions to your zsh directory:**
   Use the included sync script:
   ```bash
   ZFUNC_SYNC_DIR={your_custom_directory} ./sync.zsh
   # - or -
   ./sync.zsh # ZFUNC_SYNC_DIR defaults to ~/.zsh_functions
   ```

2. **Add to your `~/.zshrc`:**
   ```bash
   # Add custom functions directory to fpath
   fpath=( "$HOME/.zsh_functions" "${fpath[@]}" )
   autoload -Uz $HOME/.zsh_functions/*
   ```

3. **Reload your shell:**
   ```bash 
   source ~/.zshrc
   ```

### Development and Testing
Tests use [Bats testing framework](https://github.com/bats-core/bats-core):

```bash
# Install Bats
brew install bats-core

# Run all tests (32 tests total)
bats tests/unit/ tests/integration/

# Run specific test types
bats tests/unit/        # Unit tests only
bats tests/integration/ # Integration tests only
```

### VS Code Development
Available tasks (Cmd+Shift+P → "Tasks: Run Task"):
- **Run All Tests (Bats)** - Execute full test suite
- **Sync to ~/.zfunc** - Copy functions to zsh directory
- **Make Functions Executable** - Set proper permissions
- **Validate Shell Scripts** - Run shellcheck

### Adding New Functions

1. Create function in `src/directory`
2. Follow zsh function conventions:
   ```bash
   #!/usr/bin/env zsh
   
   # Function description
   function_name() {
       # Implementation
   }
   
   # Auto-execute if called directly
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
       function_name "$@"
   fi
   ```

3. Make executable: `chmod +x src/function_name`
4. Test: `bats tests/`
5. Sync: `./sync.zsh`

## Project Structure

```
├── src/                    # Function source files
│   ├── claude             # Claude AI proxy
│   ├── gemini             # Gemini AI proxy
│   ├── brew-list-formulas # Homebrew utility
│   └── hello              # Demo function
├── tests/                 # Test suite
│   ├── unit/              # Unit tests
│   ├── integration/       # Integration tests
│   └── helpers.bash       # Test utilities
├── .vscode/               # VS Code configuration
├── sync.zsh              # Development sync script
└── README.md             # This file
```

## Requirements

- **Zsh shell**
- **Bats** (for testing): `brew install bats-core`
- **Node.js ≥18** (for claude function)
- **Node.js ≥20** (for gemini function)

## License

MIT License - see LICENSE file for details.
