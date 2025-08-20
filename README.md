# Zsh Functions Collection

A collection of useful zsh shell functions with comprehensive testing.

## Functions

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

### `hello`
Simple greeting function demonstrating zsh function structure.

**Usage:**
```bash
hello
# Output: Hello world.
```

## Installation

1. **Copy functions to your zsh directory:**
   ```bash
   mkdir -p ~/.zfunc
   cp src/* ~/.zfunc/
   chmod +x ~/.zfunc/*
   ```

2. **Add to your `~/.zshrc`:**
   ```bash
   # Add function directory to fpath
   fpath=(~/.zfunc $fpath)
   
   # Auto-load all functions
   autoload -Uz ~/.zfunc/*
   ```

3. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

## Development

### Quick Sync
Use the included sync script:
```bash
./sync.zsh
```

### Testing
Tests use [Bats testing framework](https://github.com/bats-core/bats-core):

```bash
# Install Bats
brew install bats-core

# Run all tests (15 tests total)
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
