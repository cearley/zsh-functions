#!/usr/bin/env bats

# Integration tests for gemini script end-to-end functionality

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

@test "gemini script handles command execution failures properly" {
    create_mock_node_good "v20.10.0"
    create_mock_npm_installed "gemini" "$PACKAGE_NAME"
    create_mock_command_failure "gemini" 42

    run zsh "$GEMINI_SCRIPT" failing-command
    [ "$status" -eq 42 ]
    [[ "$output" == *"gemini command failed"* ]]
    [[ "$output" == *"Gemini command failed with exit code 42"* ]]
}