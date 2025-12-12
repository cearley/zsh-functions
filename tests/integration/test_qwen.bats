#!/usr/bin/env bats

# Integration tests for qwen script end-to-end functionality

bats_require_minimum_version 1.5.0

load "../helpers.bash"

setup() {
    setup_integration_test "qwen"
    PACKAGE_NAME=$(get_package_name "qwen")
}

teardown() {
    teardown_integration_test
}

@test "qwen script executes successfully with all dependencies present" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "qwen" "$PACKAGE_NAME"
    create_mock_command "qwen"

    run zsh "$QWEN_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"qwen executed with args: --help"* ]]
}

@test "qwen script prompts and installs missing package when user agrees" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_not_installed "qwen" "$PACKAGE_NAME"
    create_mock_command "qwen"

    run bash -c "echo 'y' | zsh '$QWEN_SCRIPT' test-arg"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$PACKAGE_NAME npm package is not installed"* ]]
    [[ "$output" == *"Successfully installed $PACKAGE_NAME"* ]]
    [[ "$output" == *"qwen executed with args: test-arg"* ]]
}

@test "qwen script exits gracefully when user declines installation" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_not_installed "qwen" "$PACKAGE_NAME"
    create_mock_command "qwen"

    run bash -c "echo 'n' | zsh '$QWEN_SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$PACKAGE_NAME npm package is not installed"* ]]
    [[ "$output" == *"Installation declined"* ]]
}

@test "qwen script passes arguments to underlying command correctly" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "qwen" "$PACKAGE_NAME"
    create_mock_command "qwen"

    run zsh "$QWEN_SCRIPT" arg1 arg2 --flag value
    [ "$status" -eq 0 ]
    [[ "$output" == *"qwen executed with args: arg1 arg2 --flag value"* ]]
}

@test "qwen script handles command execution failures with generic error message" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "qwen" "$PACKAGE_NAME"
    create_mock_command_failure "qwen" 42

    run zsh "$QWEN_SCRIPT" failing-command
    [ "$status" -eq 42 ]
    [[ "$output" == *"Qwen command failed with exit code 42"* ]]
    [[ "$output" == *"Troubleshooting Steps"* ]]
}

@test "qwen script handles command not found (exit 127) with diagnostics" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_with_package_structure "qwen" "$PACKAGE_NAME"
    create_mock_command_not_found "qwen"

    run -127 zsh "$QWEN_SCRIPT" test-arg
    [ "$status" -eq 127 ]
    [[ "$output" == *"Qwen command failed with exit code 127"* ]]
    [[ "$output" == *"Command 'qwen' not found in PATH"* ]]
    [[ "$output" == *"Diagnostic Information"* ]]
    [[ "$output" == *"npm uninstall -g $PACKAGE_NAME"* ]]
    [[ "$output" == *"npm install -g $PACKAGE_NAME"* ]]
}

@test "qwen script handles permission denied (exit 126) with helpful guidance" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "qwen" "$PACKAGE_NAME"
    create_mock_command_permission_denied "qwen"

    run -126 zsh "$QWEN_SCRIPT" test-arg
    [ "$status" -eq 126 ]
    [[ "$output" == *"Qwen command failed with exit code 126"* ]]
    [[ "$output" == *"Permission denied"* ]]
    [[ "$output" == *"Check executable permissions"* ]]
}

@test "qwen script handles generic failure (exit 1) with troubleshooting steps" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "qwen" "$PACKAGE_NAME"
    create_mock_command_failure "qwen" 1

    run -1 zsh "$QWEN_SCRIPT" test-arg
    [ "$status" -eq 1 ]
    [[ "$output" == *"Qwen command failed with exit code 1"* ]]
    [[ "$output" == *"Command executed but returned an error"* ]]
    [[ "$output" == *"Troubleshooting Steps"* ]]
}