#!/usr/bin/env bats

# Integration tests for codex script end-to-end functionality

bats_require_minimum_version 1.5.0

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

@test "codex script handles command execution failures with generic error message" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "codex" "$PACKAGE_NAME"
    create_mock_command_failure "codex" 42

    run zsh "$CODEX_SCRIPT" failing-command
    [ "$status" -eq 42 ]
    [[ "$output" == *"Codex command failed with exit code 42"* ]]
    [[ "$output" == *"Troubleshooting Steps"* ]]
}

@test "codex script handles command not found (exit 127) with diagnostics" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_with_package_structure "codex" "$PACKAGE_NAME"
    create_mock_command_not_found "codex"

    run -127 zsh "$CODEX_SCRIPT" test-arg
    [ "$status" -eq 127 ]
    [[ "$output" == *"Codex command failed with exit code 127"* ]]
    [[ "$output" == *"Command 'codex' not found in PATH"* ]]
    [[ "$output" == *"Diagnostic Information"* ]]
    [[ "$output" == *"npm uninstall -g $PACKAGE_NAME"* ]]
    [[ "$output" == *"npm install -g $PACKAGE_NAME"* ]]
}

@test "codex script handles permission denied (exit 126) with helpful guidance" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "codex" "$PACKAGE_NAME"
    create_mock_command_permission_denied "codex"

    run -126 zsh "$CODEX_SCRIPT" test-arg
    [ "$status" -eq 126 ]
    [[ "$output" == *"Codex command failed with exit code 126"* ]]
    [[ "$output" == *"Permission denied"* ]]
    [[ "$output" == *"Check executable permissions"* ]]
}

@test "codex script handles generic failure (exit 1) with troubleshooting steps" {
    create_mock_node_good "v20.17.0"
    create_mock_npm_installed "codex" "$PACKAGE_NAME"
    create_mock_command_failure "codex" 1

    run -1 zsh "$CODEX_SCRIPT" test-arg
    [ "$status" -eq 1 ]
    [[ "$output" == *"Codex command failed with exit code 1"* ]]
    [[ "$output" == *"Command executed but returned an error"* ]]
    [[ "$output" == *"Troubleshooting Steps"* ]]
}