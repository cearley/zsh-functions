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
# Shared helpers for proxy command testing
# ==============================================

# Load helper functions from a proxy command script
# Usage: load_proxy_functions "claude" or "gemini" or "codex"
load_proxy_functions() {
    local cmd_name="$1"
    local script_path

    # Determine correct path based on test directory structure
    if [[ "$BATS_TEST_DIRNAME" == */tests/unit ]]; then
        script_path="$BATS_TEST_DIRNAME/../../autoload/$cmd_name"
    elif [[ "$BATS_TEST_DIRNAME" == */tests/integration ]]; then
        script_path="$BATS_TEST_DIRNAME/../../autoload/$cmd_name"
    else
        # Fallback - assume we're in the project root
        script_path="$BATS_TEST_DIRNAME/autoload/$cmd_name"
    fi

    # Extract and define helper functions from the script
    eval "$(sed -n "/^_${cmd_name}_check_nodejs_version() {/,/^}/p" "$script_path")"
    eval "$(sed -n "/^_${cmd_name}_is_installed() {/,/^}/p" "$script_path")"
    eval "$(sed -n "/^_${cmd_name}_prompt_install() {/,/^}/p" "$script_path")"
    eval "$(sed -n "/^_${cmd_name}_install_package() {/,/^}/p" "$script_path")"
}

# Mock Node.js with good version (20+)
mock_nodejs_success() {
    local mock_version="${1:-v20.0.0}"
    eval "node() {
        if [[ \"\$1\" == \"--version\" ]]; then
            echo \"$mock_version\"
        fi
    }"
    npm() { echo "npm version"; }
    export -f node npm
}

# Mock Node.js not installed
mock_nodejs_failure() {
    # Override the command builtin to say node is not found
    command() {
        if [[ "$1" == "-v" && "$2" == "node" ]]; then
            return 1
        fi
        # For other commands, use the real command builtin
        builtin command "$@"
    }
    export -f command
}

# Mock old Node.js version
mock_nodejs_old_version() {
    local mock_version="${1:-v18.0.0}"
    eval "node() {
        if [[ \"\$1\" == \"--version\" ]]; then
            echo \"$mock_version\"
        fi
    }"
    npm() { echo "npm version"; }
    export -f node npm
}

# Mock Node.js installed but version cannot be determined
mock_nodejs_no_version() {
    node() {
        if [[ "$1" == "--version" ]]; then
            return 1
        fi
    }
    npm() { echo "npm version"; }
    export -f node npm
}

# Mock npm missing
mock_npm_missing() {
    node() { echo "v20.0.0"; }
    export -f node
}

# Mock package installed
# Usage: mock_package_installed "claude" "@anthropic-ai/claude-code"
mock_package_installed() {
    local cmd_name="$1"
    local mock_package="$2"
    eval "npm() {
        if [[ \"\$*\" == \"list -g $mock_package\" ]]; then
            echo \"$mock_package@1.0.0\"
            return 0
        fi
        return 0
    }"
    export -f npm
}

# Mock package not installed
# Usage: mock_package_not_installed "claude" "@anthropic-ai/claude-code"
mock_package_not_installed() {
    local cmd_name="$1"
    local mock_package="$2"
    eval "npm() {
        if [[ \"\$*\" == \"list -g $mock_package\" ]]; then
            return 1
        fi
        return 0
    }"
    export -f npm
}

# Mock package install success
# Usage: mock_package_install_success "claude" "@anthropic-ai/claude-code"
mock_package_install_success() {
    local cmd_name="$1"
    local mock_package="$2"
    eval "npm() {
        if [[ \"\$*\" == \"install -g $mock_package\" || \"\$*\" == \"install -g $mock_package@latest\" ]]; then
            return 0
        fi
        return 0
    }"
    export -f npm
}

# Mock package install failure
# Usage: mock_package_install_failure "claude" "@anthropic-ai/claude-code"
mock_package_install_failure() {
    local cmd_name="$1"
    local mock_package="$2"
    eval "npm() {
        if [[ \"\$*\" == \"install -g $mock_package\" || \"\$*\" == \"install -g $mock_package@latest\" ]]; then
            echo \"Error: Failed to install package\"
            return 1
        fi
        return 0
    }"
    export -f npm
}

# Clean up exports
cleanup_mocks() {
    unset -f node npm command 2>/dev/null || true
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

# Get package name for a command
get_package_name() {
    local cmd_name="$1"
    case "$cmd_name" in
        claude) echo "@anthropic-ai/claude-code" ;;
        gemini) echo "@google/gemini-cli" ;;
        codex) echo "@openai/codex" ;;
        qwen) echo "@qwen-code/qwen-code" ;;
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
        *) echo "18" ;;
    esac
}
