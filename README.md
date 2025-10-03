# Zsh Functions Collection

[![CI](https://github.com/cearley/zsh_functions/actions/workflows/ci.yml/badge.svg)](https://github.com/cearley/zsh_functions/actions)
![Shell](https://img.shields.io/badge/shell-zsh-blue.svg)
![Node.js](https://img.shields.io/badge/node.js-18%2B-green.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)
[![GitHub last commit](https://img.shields.io/github/last-commit/cearley/zsh_functions)](https://github.com/cearley/zsh_functions/commits)

A collection of useful zsh shell functions with comprehensive testing.

## Available Functions

- **[claude](#claude)** - Transparent proxy to the `@anthropic-ai/claude-code` npm package
- **[codex](#codex)** - Transparent proxy to the `@openai/codex` npm package
- **[gemini](#gemini)** - Transparent proxy to the `@google/gemini-cli` npm package
- **[qwen](#qwen)** - Transparent proxy to the `@qwen-code/qwen-code` npm package
- **[brew-list-formulas](#brew-list-formulas)** - Lists formulas from Homebrew taps


## Installation

The `autoload/` directory contains **zsh autoloadable functions** - special shell functions that are loaded automatically by zsh when first called, rather than being loaded into memory immediately.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/cearley/zsh-functions.git ~/.zsh-functions
   ```

2. **Add autoload functions to your `~/.zshrc`:**
   ```bash
   # Add zsh-functions to fpath and autoload all functions
   fpath=("$HOME/.zsh-functions/autoload" $fpath)
   autoload -Uz $HOME/.zsh-functions/autoload/*
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

# Run all tests (57 tests total)
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

## Project Structure

```
├── autoload/              # Zsh autoloadable function files (loaded when first called)
│   ├── claude             # Claude AI proxy
│   ├── codex              # Codex AI proxy
│   ├── gemini             # Gemini AI proxy
│   ├── qwen               # Qwen AI proxy
│   ├── brew-list-formulas # Homebrew utility
│   └── hello              # Demo function
├── lib/                   # Shared library files
│   └── _common_proxy_lib  # Common functionality for AI proxies
├── tests/                 # Test suite
│   ├── unit/              # Unit tests
│   ├── integration/       # Integration tests
│   └── helpers.bash       # Test utilities
├── .vscode/               # VS Code configuration
└── README.md             # This file
```

## Requirements

- **Zsh shell**
- **Bats** (for testing): `brew install bats-core`
- **Node.js ≥18** (for claude function)
- **Node.js ≥20** (for codex, gemini, and qwen functions)

## Functions

### claude
Transparent proxy to the `@anthropic-ai/claude-code` npm package. Automatically handles installation and setup.

**Features:**
- Checks for Node.js (≥18) and npm
- Prompts to install package if missing
- Passes all arguments to the actual claude command

**Usage:**
```bash
claude "Write a hello world function"
```

### codex
Transparent proxy to the `@openai/codex` npm package. Automatically handles installation and setup.

**Features:**
- Checks for Node.js (≥20) and npm
- Prompts to install package if missing
- Passes all arguments to the actual codex command

**Usage:**
```bash
codex "Write a function to parse JSON"
codex --model code-davinci-002 "Generate unit tests"
```

### gemini
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

### qwen
Transparent proxy to the `@qwen-code/qwen-code` npm package. Automatically handles installation and setup.

**Features:**
- Checks for Node.js (≥20) and npm
- Prompts to install package if missing
- Passes all arguments to the actual qwen command

**Usage:**
```bash
qwen "Refactor this code for better performance"
qwen --help
```

### brew-list-formulas
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

### Note on AI proxy functions (claude, codex, gemini, qwen)
These functions are called 'transparent proxies' because they automatically check for and install the required npm packages (like `@anthropic-ai/claude-code`, `@openai/codex`, `@google/gemini-cli`, or `@qwen-code/qwen-code`) the first time you use them. This is especially helpful for developers who use multiple Node.js environments (for example, with nvm or asdf), where global npm packages might not always be available in every environment.

**Advantages:**
- You don't have to manually install or update the CLI tools—they are installed for you if missing.
- You always get a working command, even if you switch Node.js versions or environments.
- The proxy functions work just like the real CLI tools, so you can use them the same way.

**Possible disadvantages:**
- The first run may be slower if the package needs to be installed.
- If you use many different Node.js environments, the package may be installed multiple times (once per environment).
- Automatic installation may not be desirable in some locked-down or production environments.

For most developers, this approach makes it much more convenient to use these tools without worrying about setup or environment issues.

## License

MIT License - see LICENSE file for details.
