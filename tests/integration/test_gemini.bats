#!/usr/bin/env bats

# Integration tests for gemini script end-to-end functionality

bats_require_minimum_version 1.5.0

load "../helpers.bash"

setup() {
    setup_integration_test "gemini"
    PACKAGE_NAME=$(get_package_name "gemini")
}

teardown() {
    teardown_integration_test
}

@test "gemini script executes successfully with all dependencies present" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_installed "gemini" "$PACKAGE_NAME"
    create_mock_command "gemini"

    run zsh "$GEMINI_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"gemini executed with args: --help"* ]]
}

@test "gemini script prompts and installs missing package when user agrees" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_not_installed "gemini" "$PACKAGE_NAME"
    create_mock_command "gemini"

    run bash -c "echo 'y' | zsh '$GEMINI_SCRIPT' test-arg"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$PACKAGE_NAME npm package is not installed"* ]]
    [[ "$output" == *"Successfully installed $PACKAGE_NAME"* ]]
    [[ "$output" == *"gemini executed with args: test-arg"* ]]
}

@test "gemini script exits gracefully when user declines installation" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_not_installed "gemini" "$PACKAGE_NAME"
    create_mock_command "gemini"

    run bash -c "echo 'n' | zsh '$GEMINI_SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$PACKAGE_NAME npm package is not installed"* ]]
    [[ "$output" == *"Installation declined"* ]]
}

@test "gemini script passes arguments to underlying command correctly" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_installed "gemini" "$PACKAGE_NAME"
    create_mock_command "gemini"

    run zsh "$GEMINI_SCRIPT" arg1 arg2 --flag value
    [ "$status" -eq 0 ]
    [[ "$output" == *"gemini executed with args: arg1 arg2 --flag value"* ]]
}

@test "gemini script passes model selection arguments correctly" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_installed "gemini" "$PACKAGE_NAME"
    create_mock_command "gemini"

    run zsh "$GEMINI_SCRIPT" -m gemini-2.5-flash "Explain this code"
    [ "$status" -eq 0 ]
    [[ "$output" == *"gemini executed with args: -m gemini-2.5-flash Explain this code"* ]]
}

@test "gemini script handles command execution failures with generic error message" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_installed "gemini" "$PACKAGE_NAME"
    create_mock_command_failure "gemini" 42

    run zsh "$GEMINI_SCRIPT" failing-command
    [ "$status" -eq 42 ]
    [[ "$output" == *"Gemini command failed with exit code 42"* ]]
    [[ "$output" == *"Troubleshooting Steps"* ]]
}

@test "gemini script handles command not found (exit 127) with diagnostics" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_with_package_structure "gemini" "$PACKAGE_NAME"
    create_mock_command_not_found "gemini"

    run -127 zsh "$GEMINI_SCRIPT" test-arg
    [ "$status" -eq 127 ]
    [[ "$output" == *"Gemini command failed with exit code 127"* ]]
    [[ "$output" == *"Command 'gemini' not found in PATH"* ]]
    [[ "$output" == *"Diagnostic Information"* ]]
    [[ "$output" == *"npm uninstall -g $PACKAGE_NAME"* ]]
    [[ "$output" == *"npm install -g $PACKAGE_NAME"* ]]
}

@test "gemini script handles permission denied (exit 126) with helpful guidance" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_installed "gemini" "$PACKAGE_NAME"
    create_mock_command_permission_denied "gemini"

    run -126 zsh "$GEMINI_SCRIPT" test-arg
    [ "$status" -eq 126 ]
    [[ "$output" == *"Gemini command failed with exit code 126"* ]]
    [[ "$output" == *"Permission denied"* ]]
    [[ "$output" == *"Check executable permissions"* ]]
}

@test "gemini script handles generic failure (exit 1) with troubleshooting steps" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_installed "gemini" "$PACKAGE_NAME"
    create_mock_command_failure "gemini" 1

    run -1 zsh "$GEMINI_SCRIPT" test-arg
    [ "$status" -eq 1 ]
    [[ "$output" == *"Gemini command failed with exit code 1"* ]]
    [[ "$output" == *"Command executed but returned an error"* ]]
    [[ "$output" == *"Troubleshooting Steps"* ]]
}