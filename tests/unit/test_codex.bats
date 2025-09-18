#!/usr/bin/env bats

# Unit tests for codex script helper functions

setup() {
    # Load the codex script functions for testing
    load_codex_functions() {
        # Extract and define helper functions from codex script
        eval "$(sed -n '/^_codex_check_nodejs_version() {/,/^}/p' "$BATS_TEST_DIRNAME/../../autoload/codex")"
        eval "$(sed -n '/^_codex_is_installed() {/,/^}/p' "$BATS_TEST_DIRNAME/../../autoload/codex")"
        eval "$(sed -n '/^_codex_prompt_install() {/,/^}/p' "$BATS_TEST_DIRNAME/../../autoload/codex")"
        eval "$(sed -n '/^_codex_install_package() {/,/^}/p' "$BATS_TEST_DIRNAME/../../autoload/codex")"
    }

    # Mock functions for testing
    mock_nodejs_success() {
        node() { echo "v20.0.0"; }
        npm() { echo "npm version"; }
        command() {
            case "$2" in
                node) return 0 ;;
                npm) return 0 ;;
                *) return 1 ;;
            esac
        }
        export -f node npm command
    }

    mock_nodejs_failure() {
        command() {
            case "$2" in
                node) return 1 ;;
                npm) return 1 ;;
                *) return 1 ;;
            esac
        }
        export -f command
    }

    mock_nodejs_old_version() {
        node() { echo "v18.0.0"; }
        npm() { echo "npm version"; }
        command() {
            case "$2" in
                node) return 0 ;;
                npm) return 0 ;;
                *) return 1 ;;
            esac
        }
        export -f node npm command
    }

    mock_nodejs_no_version() {
        node() { return 1; }
        npm() { echo "npm version"; }
        command() {
            case "$2" in
                node) return 0 ;;
                npm) return 0 ;;
                *) return 1 ;;
            esac
        }
        export -f node npm command
    }

    mock_codex_installed() {
        npm() {
            if [[ "$*" == "list -g @openai/codex" ]]; then
                echo "@openai/codex@1.0.0"
                return 0
            fi
        }
        export -f npm
    }

    mock_codex_not_installed() {
        npm() {
            if [[ "$*" == "list -g @openai/codex" ]]; then
                return 1
            fi
        }
        export -f npm
    }

    mock_codex_install_success() {
        npm() {
            if [[ "$*" == "install -g @openai/codex" ]]; then
                return 0
            fi
        }
        export -f npm
    }

    mock_codex_install_failure() {
        npm() {
            if [[ "$*" == "install -g @openai/codex" ]]; then
                echo "Error: Failed to install package"
                return 1
            fi
        }
        export -f npm
    }

    # Load functions
    load_codex_functions
}

teardown() {
    # Clean up any exports
    unset -f node npm command 2>/dev/null || true
}

@test "check_nodejs_version succeeds with Node.js 20+" {
    mock_nodejs_success
    run _codex_check_nodejs_version
    [ "$status" -eq 0 ]
}

@test "check_nodejs_version fails without Node.js" {
    mock_nodejs_failure
    run _codex_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"Node.js is not installed"* ]]
}

@test "check_nodejs_version fails with old Node.js version" {
    mock_nodejs_old_version
    run _codex_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"version 18.0.0 is too old"* ]]
}

@test "check_nodejs_version fails when node version cannot be determined" {
    mock_nodejs_no_version
    run _codex_check_nodejs_version
    [ "$status" -eq 1 ]
    [[ "$output" == *"Could not determine Node.js version"* ]]
}

@test "codex_is_installed returns true when installed" {
    mock_codex_installed
    run _codex_is_installed "@openai/codex"
    [ "$status" -eq 0 ]
}

@test "codex_is_installed returns false when not installed" {
    mock_codex_not_installed
    run _codex_is_installed "@openai/codex"
    [ "$status" -eq 1 ]
}

@test "codex_install_package succeeds with successful npm install" {
    mock_codex_install_success
    run _codex_install_package "@openai/codex"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Successfully installed @openai/codex"* ]]
}

@test "codex_install_package fails with npm error" {
    mock_codex_install_failure
    run _codex_install_package "@openai/codex"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to install @openai/codex"* ]]
}