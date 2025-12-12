#!/usr/bin/env bats

# Integration tests for claude script end-to-end functionality

bats_require_minimum_version 1.5.0

load "../helpers.bash"

setup() {
    setup_integration_test "claude"
    PACKAGE_NAME=$(get_package_name "claude")
}

teardown() {
    teardown_integration_test
}

@test "claude script executes successfully with all dependencies present" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_installed "claude" "$PACKAGE_NAME"
    create_mock_command "claude"

    run zsh "$CLAUDE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude executed with args: --help"* ]]
}

@test "claude script prompts and installs missing package when user agrees" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_not_installed "claude" "$PACKAGE_NAME"
    create_mock_command "claude"

    run bash -c "echo 'y' | zsh '$CLAUDE_SCRIPT' test-arg"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$PACKAGE_NAME npm package is not installed"* ]]
    [[ "$output" == *"Successfully installed $PACKAGE_NAME"* ]]
    [[ "$output" == *"claude executed with args: test-arg"* ]]
}

@test "claude script exits gracefully when user declines installation" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_not_installed "claude" "$PACKAGE_NAME"
    create_mock_command "claude"

    run bash -c "echo 'n' | zsh '$CLAUDE_SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$PACKAGE_NAME npm package is not installed"* ]]
    [[ "$output" == *"Installation declined"* ]]
}

@test "claude script passes arguments to underlying command correctly" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_installed "claude" "$PACKAGE_NAME"
    create_mock_command "claude"

    run zsh "$CLAUDE_SCRIPT" arg1 arg2 --flag value
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude executed with args: arg1 arg2 --flag value"* ]]
}

@test "claude script handles command execution failures with generic error message" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_installed "claude" "$PACKAGE_NAME"
    create_mock_command_failure "claude" 42

    run zsh "$CLAUDE_SCRIPT" failing-command
    [ "$status" -eq 42 ]
    [[ "$output" == *"Claude command failed with exit code 42"* ]]
    [[ "$output" == *"Troubleshooting Steps"* ]]
}

@test "claude script handles command not found (exit 127) with diagnostics" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_with_package_structure "claude" "$PACKAGE_NAME"
    create_mock_command_not_found "claude"

    run -127 zsh "$CLAUDE_SCRIPT" test-arg
    [ "$status" -eq 127 ]
    [[ "$output" == *"Claude command failed with exit code 127"* ]]
    [[ "$output" == *"Command 'claude' not found in PATH"* ]]
    [[ "$output" == *"Diagnostic Information"* ]]
    [[ "$output" == *"npm uninstall -g $PACKAGE_NAME"* ]]
    [[ "$output" == *"npm install -g $PACKAGE_NAME"* ]]
}

@test "claude script handles permission denied (exit 126) with helpful guidance" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_installed "claude" "$PACKAGE_NAME"
    create_mock_command_permission_denied "claude"

    run -126 zsh "$CLAUDE_SCRIPT" test-arg
    [ "$status" -eq 126 ]
    [[ "$output" == *"Claude command failed with exit code 126"* ]]
    [[ "$output" == *"Permission denied"* ]]
    [[ "$output" == *"Check executable permissions"* ]]
}

@test "claude script handles generic failure (exit 1) with troubleshooting steps" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_installed "claude" "$PACKAGE_NAME"
    create_mock_command_failure "claude" 1

    run -1 zsh "$CLAUDE_SCRIPT" test-arg
    [ "$status" -eq 1 ]
    [[ "$output" == *"Claude command failed with exit code 1"* ]]
    [[ "$output" == *"Command executed but returned an error"* ]]
    [[ "$output" == *"Troubleshooting Steps"* ]]
}
