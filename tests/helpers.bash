#!/usr/bin/env bash

# Test helper functions for Bats tests

# Create a mock command that always succeeds
create_mock_success() {
    local command_name="$1"
    local output="$2"

    cat > "$TEST_DIR/$command_name" << EOF
#!/bin/bash
echo "$output"
exit 0
EOF
    chmod +x "$TEST_DIR/$command_name"
}

# Create a mock command that always fails
create_mock_failure() {
    local command_name="$1"
    local output="$2"
    local exit_code="${3:-1}"

    cat > "$TEST_DIR/$command_name" << EOF
#!/bin/bash
echo "$output" >&2
exit $exit_code
EOF
    chmod +x "$TEST_DIR/$command_name"
}

# Check if a string contains another string
contains() {
    local haystack="$1"
    local needle="$2"
    [[ "$haystack" == *"$needle"* ]]
}

# ==============================================
# Integration test helpers
# ==============================================

# Setup integration test environment
setup_integration_test() {
    local cmd_name="$1"

    # Create temporary directory for test environment
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    export ORIG_PATH="$PATH"
    export PATH="$TEST_DIR:$PATH"

    # Set script path based on command name
    case "$cmd_name" in
        claude)
            export CLAUDE_SCRIPT="$BATS_TEST_DIRNAME/../../autoload/claude"
            ;;
        gemini)
            export GEMINI_SCRIPT="$BATS_TEST_DIRNAME/../../autoload/gemini"
            ;;
        codex)
            export CODEX_SCRIPT="$BATS_TEST_DIRNAME/../../autoload/codex"
            ;;
        qwen)
            export QWEN_SCRIPT="$BATS_TEST_DIRNAME/../../autoload/qwen"
            ;;
        openspec)
            export OPENSPEC_SCRIPT="$BATS_TEST_DIRNAME/../../autoload/openspec"
            ;;
    esac
}

# Teardown integration test environment
teardown_integration_test() {
    # Restore PATH and cleanup
    export PATH="$ORIG_PATH"
    rm -rf "$TEST_DIR"
}

# Create mock Node.js command for integration tests
create_mock_node_good() {
    local version="${1:-v20.17.0}"
    cat > "$TEST_DIR/node" << EOF
#!/bin/bash
if [[ "\$1" == "--version" ]]; then
    echo "$version"
fi
exit 0
EOF
    chmod +x "$TEST_DIR/node"
}

# Create mock old Node.js command for integration tests
create_mock_node_old() {
    local version="${1:-v18.20.0}"
    cat > "$TEST_DIR/node" << EOF
#!/bin/bash
if [[ "\$1" == "--version" ]]; then
    echo "$version"
fi
exit 0
EOF
    chmod +x "$TEST_DIR/node"
}

# Create mock npm with package not installed
# Usage: create_mock_npm_not_installed "claude" "@anthropic-ai/claude-code"
create_mock_npm_not_installed() {
    local cmd_name="$1"
    local package_name="$2"
    cat > "$TEST_DIR/npm" << EOF
#!/bin/bash
if [[ "\$1" == "list" && "\$2" == "-g" && "\$3" == "$package_name" ]]; then
    exit 1  # Not installed
elif [[ "\$1" == "install" && "\$2" == "-g" && ("\$3" == "$package_name" || "\$3" == "$package_name@latest") ]]; then
    echo "Installing $package_name globally..."
    echo "Successfully installed $package_name"
    exit 0
fi
exit 0
EOF
    chmod +x "$TEST_DIR/npm"
}

# Create mock npm with package installed
# Usage: create_mock_npm_installed "claude" "@anthropic-ai/claude-code"
create_mock_npm_installed() {
    local cmd_name="$1"
    local package_name="$2"
    cat > "$TEST_DIR/npm" << EOF
#!/bin/bash
if [[ "\$1" == "list" && "\$2" == "-g" && "\$3" == "$package_name" ]]; then
    exit 0  # Already installed
fi
exit 0
EOF
    chmod +x "$TEST_DIR/npm"
}

# Create mock command for integration tests
# Usage: create_mock_command "claude"
create_mock_command() {
    local cmd_name="$1"
    cat > "$TEST_DIR/$cmd_name" << EOF
#!/bin/bash
echo "$cmd_name executed with args: \$*"
exit 0
EOF
    chmod +x "$TEST_DIR/$cmd_name"
}

# Create mock command that fails for integration tests
# Usage: create_mock_command_failure "claude" 42
create_mock_command_failure() {
    local cmd_name="$1"
    local exit_code="${2:-1}"
    cat > "$TEST_DIR/$cmd_name" << EOF
#!/bin/bash
echo "$cmd_name command failed"
exit $exit_code
EOF
    chmod +x "$TEST_DIR/$cmd_name"
}

# Create mock command that returns exit code 127 (command not found)
# Usage: create_mock_command_not_found "claude"
create_mock_command_not_found() {
    local cmd_name="$1"
    cat > "$TEST_DIR/$cmd_name" << 'EOF'
#!/bin/bash
exit 127
EOF
    chmod +x "$TEST_DIR/$cmd_name"
}

# Create mock command that returns exit code 126 (permission denied)
# Usage: create_mock_command_permission_denied "claude"
create_mock_command_permission_denied() {
    local cmd_name="$1"
    cat > "$TEST_DIR/$cmd_name" << 'EOF'
#!/bin/bash
exit 126
EOF
    chmod +x "$TEST_DIR/$cmd_name"
}

# Create mock npm with package installed and package.json structure for diagnostics
# Usage: create_mock_npm_with_package_structure "claude" "@anthropic-ai/claude-code"
create_mock_npm_with_package_structure() {
    local cmd_name="$1"
    local package_name="$2"

    # Create mock npm root directory structure
    local mock_npm_root="$TEST_DIR/node_modules"
    local pkg_dir="$mock_npm_root/$package_name"
    mkdir -p "$pkg_dir/bin"

    # Create package.json
    cat > "$pkg_dir/package.json" << EOF
{
  "name": "$package_name",
  "version": "1.0.0",
  "bin": {
    "$cmd_name": "bin/$cmd_name.js"
  }
}
EOF

    # Create binary file
    cat > "$pkg_dir/bin/$cmd_name.js" << EOF
#!/usr/bin/env node
console.log('Mock $cmd_name binary');
EOF
    chmod +x "$pkg_dir/bin/$cmd_name.js"

    # Create mock npm that returns the correct root path
    cat > "$TEST_DIR/npm" << EOF
#!/bin/bash
if [[ "\$1" == "root" && "\$2" == "-g" ]]; then
    echo "$mock_npm_root"
elif [[ "\$1" == "prefix" && "\$2" == "-g" ]]; then
    echo "$TEST_DIR"
elif [[ "\$1" == "list" && "\$2" == "-g" && "\$3" == "$package_name" ]]; then
    exit 0  # Package is installed
fi
exit 0
EOF
    chmod +x "$TEST_DIR/npm"
}

# Get package name for a command
get_package_name() {
    local cmd_name="$1"
    case "$cmd_name" in
        claude) echo "@anthropic-ai/claude-code" ;;
        gemini) echo "@google/gemini-cli" ;;
        codex) echo "@openai/codex" ;;
        qwen) echo "@qwen-code/qwen-code" ;;
        openspec) echo "@fission-ai/openspec" ;;
        *) echo "unknown-package" ;;
    esac
}

# Get minimum Node.js version for a command
get_min_node_version() {
    local cmd_name="$1"
    case "$cmd_name" in
        claude) echo "18" ;;
        gemini) echo "20" ;;
        codex) echo "20" ;;
        qwen) echo "20" ;;
        openspec) echo "20" ;;
        *) echo "18" ;;
    esac
}
