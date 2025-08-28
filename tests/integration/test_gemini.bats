#!/usr/bin/env bats

# Integration tests for gemini script end-to-end functionality

setup() {
    # Create temporary directory for test environment
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    export ORIG_PATH="$PATH"
    export PATH="$TEST_DIR:$PATH"
    
    # Path to gemini script
    export GEMINI_SCRIPT="$BATS_TEST_DIRNAME/../../src/gemini"
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
    echo "v20.10.0"
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
if [[ "$1" == "list" && "$2" == "-g" && "$3" == "@google/gemini-cli" ]]; then
    exit 1  # Not installed
elif [[ "$1" == "install" && "$2" == "-g" && "$3" == "@google/gemini-cli" ]]; then
    echo "Installing @google/gemini-cli globally..."
    echo "Successfully installed @google/gemini-cli"
    exit 0
fi
exit 0
EOF
    chmod +x "$TEST_DIR/npm"
}

create_mock_npm_installed() {
    cat > "$TEST_DIR/npm" << 'EOF'
#!/bin/bash
if [[ "$1" == "list" && "$2" == "-g" && "$3" == "@google/gemini-cli" ]]; then
    exit 0  # Already installed
fi
exit 0
EOF
    chmod +x "$TEST_DIR/npm"
}

create_mock_gemini_command() {
    cat > "$TEST_DIR/gemini" << 'EOF'
#!/bin/bash
echo "gemini executed with args: $*"
exit 0
EOF
    chmod +x "$TEST_DIR/gemini"
}

@test "gemini script exists and is executable" {
    [ -f "$GEMINI_SCRIPT" ]
    [ -x "$GEMINI_SCRIPT" ]
}

@test "gemini script has proper shebang" {
    run head -1 "$GEMINI_SCRIPT"
    [[ "$output" == "#!/usr/bin/env zsh" ]]
}

@test "gemini script fails with missing Node.js" {
    # Skip this test if we're in a CI environment where Node.js is installed system-wide
    # This test is designed to work with nvm installations, not system installations
    if [[ -x "/usr/bin/node" ]]; then
        skip "Skipping Node.js missing test in CI environment with system Node.js"
    fi
    
    # Don't create node command - this simulates Node.js not being installed
    create_mock_npm_installed
    
    # Create a mock gemini command that should not be reached if the script properly fails
    cat > "$TEST_DIR/gemini" << 'EOF'
#!/bin/bash
echo "ERROR: This mock gemini should not be executed when Node.js is missing"
exit 1
EOF
    chmod +x "$TEST_DIR/gemini"
    
    # Run in isolated environment without existing gemini functions
    run env -i PATH="$TEST_DIR:/usr/bin:/bin" zsh -c "source '$GEMINI_SCRIPT'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Node.js is not installed"* ]]
}

@test "gemini script fails with old Node.js version" {
    create_mock_node_old
    create_mock_npm_installed
    create_mock_gemini_command
    
    run zsh "$GEMINI_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"version 18.20.0 is too old"* ]]
    [[ "$output" == *"Node.js version 20 or higher"* ]]
}

@test "gemini script runs successfully when package is installed" {
    create_mock_node_good
    create_mock_npm_installed
    create_mock_gemini_command
    
    run zsh "$GEMINI_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"gemini executed with args: --help"* ]]
}

@test "gemini script prompts for installation when package not installed" {
    create_mock_node_good
    create_mock_npm_not_installed
    create_mock_gemini_command
    
    run bash -c "echo 'n' | zsh '$GEMINI_SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"@google/gemini-cli npm package is not installed"* ]]
    [[ "$output" == *"Installation declined"* ]]
}

@test "gemini script installs package when user agrees" {
    create_mock_node_good
    create_mock_npm_not_installed
    create_mock_gemini_command
    
    run bash -c "echo 'y' | zsh '$GEMINI_SCRIPT' test-arg"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Successfully installed @google/gemini-cli"* ]]
    [[ "$output" == *"gemini executed with args: test-arg"* ]]
}

@test "gemini script passes arguments correctly" {
    create_mock_node_good
    create_mock_npm_installed
    create_mock_gemini_command
    
    run zsh "$GEMINI_SCRIPT" arg1 arg2 --flag value
    [ "$status" -eq 0 ]
    [[ "$output" == *"gemini executed with args: arg1 arg2 --flag value"* ]]
}

@test "gemini script passes model selection arguments" {
    create_mock_node_good
    create_mock_npm_installed
    create_mock_gemini_command
    
    run zsh "$GEMINI_SCRIPT" -m gemini-2.5-flash "Explain this code"
    [ "$status" -eq 0 ]
    [[ "$output" == *"gemini executed with args: -m gemini-2.5-flash Explain this code"* ]]
}

@test "gemini script contains required helper functions" {
    grep -q "_gemini_check_nodejs_version" "$GEMINI_SCRIPT"
    grep -q "_gemini_is_installed" "$GEMINI_SCRIPT"
    grep -q "_gemini_install_package" "$GEMINI_SCRIPT"
    grep -q "_gemini_prompt_install" "$GEMINI_SCRIPT"
}