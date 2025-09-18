#!/usr/bin/env bats

# Integration tests for claude script end-to-end functionality

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

@test "claude script handles command execution failures properly" {
    create_mock_node_good "v18.17.0"
    create_mock_npm_installed "claude" "$PACKAGE_NAME"
    create_mock_command_failure "claude" 42

    run zsh "$CLAUDE_SCRIPT" failing-command
    [ "$status" -eq 42 ]
    [[ "$output" == *"claude command failed"* ]]
    [[ "$output" == *"Claude command failed with exit code 42"* ]]
}
