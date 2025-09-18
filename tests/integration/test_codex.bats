#!/usr/bin/env bats

# Integration tests for codex script end-to-end functionality

setup() {
    # Create temporary directory for test environment
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    export ORIG_PATH="$PATH"
    export PATH="$TEST_DIR:$PATH"

    # Path to codex script
    export CODEX_SCRIPT="$BATS_TEST_DIRNAME/../../autoload/codex"
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
    echo "v20.17.0"
fi
exit 0
EOF
    chmod +x "$TEST_DIR/node"
}

create_mock_node_old() {
    cat > "$TEST_DIR/node" << 'EOF'
#!/bin/bash
if [[ "$1" == "--version" ]]; then
    echo "v18.20.0"
fi
exit 0
EOF
    chmod +x "$TEST_DIR/node"
}

create_mock_npm_not_installed() {
    cat > "$TEST_DIR/npm" << 'EOF'
#!/bin/bash
if [[ "$1" == "list" && "$2" == "-g" && "$3" == "@openai/codex" ]]; then
    exit 1  # Not installed
elif [[ "$1" == "install" && "$2" == "-g" && "$3" == "@openai/codex" ]]; then
    echo "Installing @openai/codex globally..."
    echo "Successfully installed @openai/codex"
    exit 0
fi
exit 0
EOF
    chmod +x "$TEST_DIR/npm"
}

create_mock_npm_installed() {
    cat > "$TEST_DIR/npm" << 'EOF'
#!/bin/bash
if [[ "$1" == "list" && "$2" == "-g" && "$3" == "@openai/codex" ]]; then
    exit 0  # Already installed
fi
exit 0
EOF
    chmod +x "$TEST_DIR/npm"
}

create_mock_codex_command() {
    cat > "$TEST_DIR/codex" << 'EOF'
#!/bin/bash
echo "codex executed with args: $*"
exit 0
EOF
    chmod +x "$TEST_DIR/codex"
}

@test "codex script exists and is executable" {
    [ -f "$CODEX_SCRIPT" ]
    [ -x "$CODEX_SCRIPT" ]
}

@test "codex script has proper shebang" {
    run head -1 "$CODEX_SCRIPT"
    [[ "$output" == "#!/usr/bin/env zsh" ]]
}

@test "codex script fails with missing Node.js" {
    # Skip this test if we're in a CI environment where Node.js is installed system-wide
    # This test is designed to work with nvm installations, not system installations
    if [[ -x "/usr/bin/node" ]]; then
        skip "Skipping Node.js missing test in CI environment with system Node.js"
    fi

    # Don't create node command - this simulates Node.js not being installed
    create_mock_npm_installed

    # Create a mock codex command that should not be reached if the script properly fails
    cat > "$TEST_DIR/codex" << 'EOF'
#!/bin/bash
echo "ERROR: This mock codex should not be executed when Node.js is missing"
exit 1
EOF
    chmod +x "$TEST_DIR/codex"

    # Run in isolated environment without existing codex functions
    run env -i PATH="$TEST_DIR:/usr/bin:/bin" zsh -c "source '$CODEX_SCRIPT'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Node.js is not installed"* ]]
}

@test "codex script fails with missing npm" {
    create_mock_node_good
    # Don't create npm command - this simulates npm not being installed

    run env -i PATH="$TEST_DIR:/usr/bin:/bin" zsh -c "source '$CODEX_SCRIPT'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"npm is not available"* ]]
}

@test "codex script fails with old Node.js version" {
    create_mock_node_old
    create_mock_npm_installed
    create_mock_codex_command

    run zsh "$CODEX_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"version 18.20.0 is too old"* ]]
}

@test "codex script runs successfully when package is installed" {
    create_mock_node_good
    create_mock_npm_installed
    create_mock_codex_command

    run zsh "$CODEX_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"codex executed with args: --help"* ]]
}

@test "codex script prompts for installation when package not installed" {
    create_mock_node_good
    create_mock_npm_not_installed
    create_mock_codex_command

    run bash -c "echo 'n' | zsh '$CODEX_SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"@openai/codex npm package is not installed"* ]]
    [[ "$output" == *"Installation declined"* ]]
}

@test "codex script installs package when user agrees" {
    create_mock_node_good
    create_mock_npm_not_installed
    create_mock_codex_command

    run bash -c "echo 'y' | zsh '$CODEX_SCRIPT' test-arg"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Successfully installed @openai/codex"* ]]
    [[ "$output" == *"codex executed with args: test-arg"* ]]
}

@test "codex script passes arguments correctly" {
    create_mock_node_good
    create_mock_npm_installed
    create_mock_codex_command

    run zsh "$CODEX_SCRIPT" arg1 arg2 --flag value
    [ "$status" -eq 0 ]
    [[ "$output" == *"codex executed with args: arg1 arg2 --flag value"* ]]
}

@test "codex script contains required helper functions" {
    grep -q "_codex_check_nodejs_version" "$CODEX_SCRIPT"
    grep -q "_codex_is_installed" "$CODEX_SCRIPT"
    grep -q "_codex_install_package" "$CODEX_SCRIPT"
    grep -q "_codex_prompt_install" "$CODEX_SCRIPT"
}

@test "codex script enforces Node.js 20+ requirement" {
    create_mock_node_good
    create_mock_npm_installed
    create_mock_codex_command

    # The mock creates Node.js v20.17.0, which should pass
    run zsh "$CODEX_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"codex executed with args: --version"* ]]
}

@test "codex script handles command execution failure" {
    create_mock_node_good
    create_mock_npm_installed

    # Create a codex command that fails
    cat > "$TEST_DIR/codex" << 'EOF'
#!/bin/bash
echo "codex command failed"
exit 42
EOF
    chmod +x "$TEST_DIR/codex"

    run zsh "$CODEX_SCRIPT" failing-command
    [ "$status" -eq 42 ]
    [[ "$output" == *"codex command failed"* ]]
    [[ "$output" == *"Codex command failed with exit code 42"* ]]
}