#!/usr/bin/env bats

# Integration tests for codex script end-to-end functionality

load "../helpers.bash"

setup() {
    setup_integration_test "codex"
    PACKAGE_NAME=$(get_package_name "codex")
}

teardown() {
    teardown_integration_test
}

@test "codex script executes successfully with all dependencies present" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "codex" "$PACKAGE_NAME"
    create_mock_command "codex"

    run zsh "$CODEX_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"codex executed with args: --help"* ]]
}

@test "codex script prompts and installs missing package when user agrees" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_not_installed "codex" "$PACKAGE_NAME"
    create_mock_command "codex"

    run bash -c "echo 'y' | zsh '$CODEX_SCRIPT' test-arg"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$PACKAGE_NAME npm package is not installed"* ]]
    [[ "$output" == *"Successfully installed $PACKAGE_NAME"* ]]
    [[ "$output" == *"codex executed with args: test-arg"* ]]
}

@test "codex script exits gracefully when user declines installation" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_not_installed "codex" "$PACKAGE_NAME"
    create_mock_command "codex"

    run bash -c "echo 'n' | zsh '$CODEX_SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$PACKAGE_NAME npm package is not installed"* ]]
    [[ "$output" == *"Installation declined"* ]]
}

@test "codex script passes arguments to underlying command correctly" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "codex" "$PACKAGE_NAME"
    create_mock_command "codex"

    run zsh "$CODEX_SCRIPT" arg1 arg2 --flag value
    [ "$status" -eq 0 ]
    [[ "$output" == *"codex executed with args: arg1 arg2 --flag value"* ]]
}

@test "codex script handles command execution failures properly" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "codex" "$PACKAGE_NAME"
    create_mock_command_failure "codex" 42

    run zsh "$CODEX_SCRIPT" failing-command
    [ "$status" -eq 42 ]
    [[ "$output" == *"codex command failed"* ]]
    [[ "$output" == *"Codex command failed with exit code 42"* ]]
}