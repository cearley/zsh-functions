#!/usr/bin/env bats

# Integration tests for claude script end-to-end functionality

setup() {
    # Create temporary directory for test environment
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    export ORIG_PATH="$PATH"
    export PATH="$TEST_DIR:$PATH"
    
    # Path to claude script
    export CLAUDE_SCRIPT="$BATS_TEST_DIRNAME/../../src/claude"
}

teardown() {
    # Restore PATH and cleanup
    export PATH="$ORIG_PATH"
    rm -rf "$TEST_DIR"
}

create_mock_node_good() {
    cat > "$TEST_DIR/node" << 'EOF'
#!/bin/bash
if [[ "$1" == "--version" ]]; then
    echo "v18.17.0"
fi
exit 0
EOF
    chmod +x "$TEST_DIR/node"
}

create_mock_node_old() {
    cat > "$TEST_DIR/node" << 'EOF'
#!/bin/bash
if [[ "$1" == "--version" ]]; then
    echo "v16.20.0"
fi
exit 0
EOF
    chmod +x "$TEST_DIR/node"
}

create_mock_npm_not_installed() {
    cat > "$TEST_DIR/npm" << 'EOF'
#!/bin/bash
if [[ "$1" == "list" && "$2" == "-g" && "$3" == "@anthropic-ai/claude-code" ]]; then
    exit 1  # Not installed
elif [[ "$1" == "install" && "$2" == "-g" && "$3" == "@anthropic-ai/claude-code" ]]; then
    echo "Installing @anthropic-ai/claude-code globally..."
    echo "Successfully installed @anthropic-ai/claude-code"
    exit 0
fi
exit 0
EOF
    chmod +x "$TEST_DIR/npm"
}

create_mock_npm_installed() {
    cat > "$TEST_DIR/npm" << 'EOF'
#!/bin/bash
if [[ "$1" == "list" && "$2" == "-g" && "$3" == "@anthropic-ai/claude-code" ]]; then
    exit 0  # Already installed
fi
exit 0
EOF
    chmod +x "$TEST_DIR/npm"
}

create_mock_claude_command() {
    cat > "$TEST_DIR/claude" << 'EOF'
#!/bin/bash
echo "claude executed with args: $*"
exit 0
EOF
    chmod +x "$TEST_DIR/claude"
}

@test "claude script exists and is executable" {
    [ -f "$CLAUDE_SCRIPT" ]
    [ -x "$CLAUDE_SCRIPT" ]
}

@test "claude script has proper shebang" {
    run head -1 "$CLAUDE_SCRIPT"
    [[ "$output" == "#!/usr/bin/env zsh" ]]
}

@test "claude script fails with missing Node.js" {
    # Don't create node command - this simulates Node.js not being installed
    create_mock_npm_installed
    
    # Create a mock claude command that should not be reached if the script properly fails
    cat > "$TEST_DIR/claude" << 'EOF'
#!/bin/bash
echo "ERROR: This mock claude should not be executed when Node.js is missing"
exit 1
EOF
    chmod +x "$TEST_DIR/claude"
    
    # Run in isolated environment without existing claude functions
    run env -i PATH="$TEST_DIR:/usr/bin:/bin" zsh -c "source '$CLAUDE_SCRIPT'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Node.js is not installed"* ]]
}

@test "claude script fails with old Node.js version" {
    create_mock_node_old
    create_mock_npm_installed
    create_mock_claude_command
    
    run zsh "$CLAUDE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"version 16.20.0 is too old"* ]]
}

@test "claude script runs successfully when package is installed" {
    create_mock_node_good
    create_mock_npm_installed
    create_mock_claude_command
    
    run zsh "$CLAUDE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude executed with args: --help"* ]]
}

@test "claude script prompts for installation when package not installed" {
    create_mock_node_good
    create_mock_npm_not_installed
    create_mock_claude_command
    
    run bash -c "echo 'n' | zsh '$CLAUDE_SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"@anthropic-ai/claude-code npm package is not installed"* ]]
    [[ "$output" == *"Installation declined"* ]]
}

@test "claude script installs package when user agrees" {
    create_mock_node_good
    create_mock_npm_not_installed
    create_mock_claude_command
    
    run bash -c "echo 'y' | zsh '$CLAUDE_SCRIPT' test-arg"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Successfully installed @anthropic-ai/claude-code"* ]]
    [[ "$output" == *"claude executed with args: test-arg"* ]]
}

@test "claude script passes arguments correctly" {
    create_mock_node_good
    create_mock_npm_installed
    create_mock_claude_command
    
    run zsh "$CLAUDE_SCRIPT" arg1 arg2 --flag value
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude executed with args: arg1 arg2 --flag value"* ]]
}

@test "claude script contains required helper functions" {
    grep -q "_claude_check_nodejs_version" "$CLAUDE_SCRIPT"
    grep -q "_claude_is_installed" "$CLAUDE_SCRIPT"
    grep -q "_claude_install_package" "$CLAUDE_SCRIPT"
    grep -q "_claude_prompt_install" "$CLAUDE_SCRIPT"
}
