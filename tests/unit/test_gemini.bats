#!/usr/bin/env bats

# Unit tests for gemini script helper functions

load "../helpers.bash"

setup() {
    # Load the gemini script functions for testing
    load_proxy_functions "gemini"
    PACKAGE_NAME=$(get_package_name "gemini")
}

teardown() {
    cleanup_mocks
}

@test "check_nodejs_version validates exact version boundary (20.0.0)" {
    mock_nodejs_success "v20.0.0"
    run _gemini_check_nodejs_version
    [ "$status" -eq 0 ]
}

@test "check_nodejs_version fails with version below minimum (19.x)" {
    mock_nodejs_old_version "v19.20.0"
    run _gemini_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"version 19.20.0 is too old"* ]]
}

@test "check_nodejs_version fails when Node.js not found" {
    mock_nodejs_failure
    run _gemini_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"Node.js is not installed"* ]]
}

@test "check_nodejs_version handles malformed version strings" {
    mock_nodejs_no_version
    run _gemini_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"Could not determine Node.js version"* ]]
}

@test "is_installed detects package presence correctly" {
    mock_package_installed "gemini" "$PACKAGE_NAME"
    run _gemini_is_installed "$PACKAGE_NAME"
    [ "$status" -eq 0 ]
}

@test "is_installed detects package absence correctly" {
    mock_package_not_installed "gemini" "$PACKAGE_NAME"
    run _gemini_is_installed "$PACKAGE_NAME"
    [ "$status" -eq 1 ]
}

@test "install_package handles successful installation" {
    mock_package_install_success "gemini" "$PACKAGE_NAME"
    run _gemini_install_package "$PACKAGE_NAME"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Successfully installed $PACKAGE_NAME"* ]]
}

@test "install_package handles npm errors properly" {
    mock_package_install_failure "gemini" "$PACKAGE_NAME"
    run _gemini_install_package "$PACKAGE_NAME"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to install $PACKAGE_NAME"* ]]
}

@test "helper functions exist in script" {
    grep -q "_gemini_check_nodejs_version" "$BATS_TEST_DIRNAME/../../autoload/gemini"
    grep -q "_gemini_is_installed" "$BATS_TEST_DIRNAME/../../autoload/gemini"
    grep -q "_gemini_install_package" "$BATS_TEST_DIRNAME/../../autoload/gemini"
    grep -q "_gemini_prompt_install" "$BATS_TEST_DIRNAME/../../autoload/gemini"
}