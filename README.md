# Zsh Functions Collection

[![CI](https://github.com/cearley/zsh_functions/actions/workflows/ci.yml/badge.svg)](https://github.com/cearley/zsh_functions/actions)
[![GitHub release](https://img.shields.io/github/v/release/cearley/zsh_functions)](https://github.com/cearley/zsh_functions/releases)

A collection of useful zsh shell functions.

## Available Functions

The repository includes transparent proxy functions for various AI command-line tools:

- **codex** - Transparent proxy to the `@openai/codex` npm package
- **gemini** - Transparent proxy to the `@google/gemini-cli` npm package
- **qwen** - Transparent proxy to the `@qwen-code/qwen-code` npm package
- **openspec** - Transparent proxy to the `@fission-ai/openspec` npm package

And utility functions:

- **brew-list-formulas** - Lists formulas from Homebrew taps


## Installation

The `autoload/` directory contains **zsh autoloadable functions** - special shell functions that are loaded automatically by zsh when first called, rather than being loaded into memory immediately.

### Using the Latest Release (Recommended)

For most users, downloading the latest release instead of cloning the development branch is recommended:

1. **Go to the [Releases page](https://github.com/cearley/zsh_functions/releases) and download the latest release archive (tar.gz or zip)**

2. **Extract the archive and move to a preferred location:**
   ```bash
   tar -xzf zsh_functions-*.tar.gz
   mv zsh_functions-* ~/.zsh-functions
   ```

3. **Add autoload functions to your `~/.zshrc`:**
   ```bash
   # Add zsh-functions to fpath and autoload all functions
   fpath=("$HOME/.zsh-functions/autoload" $fpath)
   autoload -Uz $HOME/.zsh-functions/autoload/*
   ```

4. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

### Using the Development Version

If you want to use the latest development version or contribute to the project:

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

# Run all tests
bats tests/unit/ tests/integration/

# Run specific test types
bats tests/unit/        # Unit tests only
bats tests/integration/ # Integration tests only
```

### VS Code Development
Available tasks (Cmd+Shift+P → "Tasks: Run Task"):
- **Run All Tests (Bats)** - Execute full test suite
- **Make Functions Executable** - Set proper permissions
- **Validate Shell Scripts** - Run shellcheck
- **Run Unit Tests (Bats)** - Execute unit test suite
- **Run Integration Tests (Bats)** - Execute integration test suite

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

## Requirements

- **Zsh shell**
- **Bats** (for testing): `brew install bats-core`
- **Node.js ≥20** (for codex, gemini, and qwen functions)

## Functions

The repository includes transparent proxy functions for various AI command-line tools and utilities. These functions automatically handle dependency installation and management, acting as seamless wrappers around the actual CLI tools.

### Example: gemini
As an example, the `gemini` function is a transparent proxy to the `@google/gemini-cli` npm package:

```bash
gemini "Explain the architecture of this codebase"
gemini -m gemini-2.5-flash "Generate tests for this function"
```

**How Transparent Proxies Work:**
These functions are called 'transparent proxies' because they automatically check for and install the required npm packages (like `@google/gemini-cli`, `@openai/codex`, `@qwen-code/qwen-code`, or `@fission-ai/openspec`) the first time you use them. This is especially helpful for developers who use multiple Node.js environments (for example, with nvm or asdf), where global npm packages might not always be available in every environment.

**Key Benefits:**
- **Automatic Setup**: No need to manually install or update CLI tools
- **Environment Consistency**: Works across different Node.js versions and environments
- **Seamless Experience**: Functions work identically to the original CLI tools

**Possible Considerations:**
- First use may be slower if packages need installation
- Packages may be installed multiple times across different environments
- Automatic installation might not suit all production environments

For most developers, this approach provides a convenient, environment-agnostic way to access AI CLI tools without worrying about setup or dependency management.

## Release Process

To create a new release of this project:

1. Go to the **Actions** tab in the GitHub repository
2. Select the **Create Release** workflow from the list
3. Click the **Run workflow** button
4. Choose the version type (major, minor, or patch) according to semantic versioning
5. Optionally provide a custom tag name if you don't want to use semantic versioning
6. Click **Run workflow** to trigger the release process

The workflow will:
- Automatically bump the version number
- Generate release notes based on commit messages since the last release
- Create a new Git tag
- Create a GitHub Release with the changelog entries

## License

MIT License - see LICENSE file for details.
