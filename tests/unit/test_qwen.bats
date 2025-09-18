#!/usr/bin/env bats

# Unit tests for qwen script helper functions

load "../helpers.bash"

setup() {
    # Load the qwen script functions for testing
    load_proxy_functions "qwen"
    PACKAGE_NAME=$(get_package_name "qwen")
}

teardown() {
    cleanup_mocks
}

@test "check_nodejs_version validates exact version boundary (20.0.0)" {
    mock_nodejs_success "v20.0.0"
    run _qwen_check_nodejs_version
    [ "$status" -eq 0 ]
}

@test "check_nodejs_version fails with version below minimum (19.x)" {
    mock_nodejs_old_version "v19.20.0"
    run _qwen_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"version 19.20.0 is too old"* ]]
}

@test "check_nodejs_version fails when Node.js not found" {
    mock_nodejs_failure
    run _qwen_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"Node.js is not installed"* ]]
}

@test "check_nodejs_version handles malformed version strings" {
    mock_nodejs_no_version
    run _qwen_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"Could not determine Node.js version"* ]]
}

@test "is_installed detects package presence correctly" {
    mock_package_installed "qwen" "$PACKAGE_NAME"
    run _qwen_is_installed "$PACKAGE_NAME"
    [ "$status" -eq 0 ]
}

@test "is_installed detects package absence correctly" {
    mock_package_not_installed "qwen" "$PACKAGE_NAME"
    run _qwen_is_installed "$PACKAGE_NAME"
    [ "$status" -eq 1 ]
}

@test "install_package handles successful installation" {
    mock_package_install_success "qwen" "$PACKAGE_NAME"
    run _qwen_install_package "$PACKAGE_NAME"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Successfully installed $PACKAGE_NAME"* ]]
}

@test "install_package handles npm errors properly" {
    mock_package_install_failure "qwen" "$PACKAGE_NAME"
    run _qwen_install_package "$PACKAGE_NAME"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to install $PACKAGE_NAME"* ]]
}

@test "helper functions exist in script" {
    grep -q "_qwen_check_nodejs_version" "$BATS_TEST_DIRNAME/../../autoload/qwen"
    grep -q "_qwen_is_installed" "$BATS_TEST_DIRNAME/../../autoload/qwen"
    grep -q "_qwen_install_package" "$BATS_TEST_DIRNAME/../../autoload/qwen"
    grep -q "_qwen_prompt_install" "$BATS_TEST_DIRNAME/../../autoload/qwen"
}