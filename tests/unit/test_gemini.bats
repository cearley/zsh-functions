#!/usr/bin/env bats

# Unit tests for gemini script helper functions

setup() {
    # Load the gemini script functions for testing
    load_gemini_functions() {
        # Extract and define helper functions from gemini script
        eval "$(sed -n '/^_gemini_check_nodejs_version() {/,/^}/p' "$BATS_TEST_DIRNAME/../../autoload/gemini")"
        eval "$(sed -n '/^_gemini_is_installed() {/,/^}/p' "$BATS_TEST_DIRNAME/../../autoload/gemini")"
        eval "$(sed -n '/^_gemini_prompt_install() {/,/^}/p' "$BATS_TEST_DIRNAME/../../autoload/gemini")"
        eval "$(sed -n '/^_gemini_install_package() {/,/^}/p' "$BATS_TEST_DIRNAME/../../autoload/gemini")"
    }
    
    # Mock functions for testing
    mock_nodejs_success() {
        node() { echo "v20.0.0"; }
        npm() { echo "npm is available"; }
        export -f node npm
    }
    
    mock_nodejs_failure() {
        # Create a fake command function that always returns false
        command() {
            if [[ "$1" == "-v" && "$2" == "node" ]]; then
                return 1
            fi
            # For other commands, use the real command
            builtin command "$@"
        }
        npm() { echo "npm is available"; }
        export -f command npm
    }
    
    mock_nodejs_old_version() {
        node() { echo "v18.0.0"; }
        npm() { echo "npm is available"; }
        export -f node npm
    }
    
    mock_gemini_installed() {
        npm() {
            if [[ "$*" == "list -g @google/gemini-cli" ]]; then
                echo "@google/gemini-cli@1.0.0"
                return 0
            fi
        }
        export -f npm
    }
    
    mock_gemini_not_installed() {
        npm() {
            if [[ "$*" == "list -g @google/gemini-cli" ]]; then
                return 1
            fi
        }
        export -f npm
    }
    
    mock_gemini_install_success() {
        npm() {
            if [[ "$*" == "install -g @google/gemini-cli" ]]; then
                return 0
            fi
        }
        export -f npm
    }
    
    mock_gemini_install_failure() {
        npm() {
            if [[ "$*" == "install -g @google/gemini-cli" ]]; then
                echo "Error: Failed to install package"
                return 1
            fi
        }
        export -f npm
    }
    
    # Load functions
    load_gemini_functions
}

teardown() {
    # Clean up any exports
    unset -f node npm 2>/dev/null || true
}

@test "check_nodejs_version succeeds with Node.js 20+" {
    mock_nodejs_success
    run _gemini_check_nodejs_version
    [ "$status" -eq 0 ]
}

@test "check_nodejs_version fails without Node.js" {
    mock_nodejs_failure
    run _gemini_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"Node.js is not installed"* ]]
}

@test "check_nodejs_version fails with old Node.js version" {
    mock_nodejs_old_version
    run _gemini_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"version 18.0.0 is too old"* ]]
    [[ "$output" == *"Node.js version 20 or higher"* ]]
}

@test "gemini_is_installed returns true when installed" {
    mock_gemini_installed
    run _gemini_is_installed "@google/gemini-cli"
    [ "$status" -eq 0 ]
}

@test "gemini_is_installed returns false when not installed" {
    mock_gemini_not_installed
    run _gemini_is_installed "@google/gemini-cli"
    [ "$status" -eq 1 ]
}

@test "gemini_install_package succeeds with successful npm install" {
    mock_gemini_install_success
    run _gemini_install_package "@google/gemini-cli"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing @google/gemini-cli globally"* ]]
    [[ "$output" == *"Successfully installed @google/gemini-cli"* ]]
}

@test "gemini_install_package fails with npm error" {
    mock_gemini_install_failure
    run _gemini_install_package "@google/gemini-cli"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to install @google/gemini-cli"* ]]
}