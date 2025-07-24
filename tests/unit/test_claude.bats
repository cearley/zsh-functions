#!/usr/bin/env bats

# Unit tests for claude script helper functions

setup() {
    # Load the claude script functions for testing
    load_claude_functions() {
        # Extract and define helper functions from claude script
        eval "$(sed -n '/^_check_nodejs_version() {/,/^}/p' "$BATS_TEST_DIRNAME/../../src/claude")"
        eval "$(sed -n '/^_claude_is_installed() {/,/^}/p' "$BATS_TEST_DIRNAME/../../src/claude")"
        eval "$(sed -n '/^_claude_prompt_install() {/,/^}/p' "$BATS_TEST_DIRNAME/../../src/claude")"
        eval "$(sed -n '/^_claude_install_package() {/,/^}/p' "$BATS_TEST_DIRNAME/../../src/claude")"
    }
    
    # Mock functions for testing
    mock_nodejs_success() {
        node() { echo "v18.0.0"; }
        export -f node
    }
    
    mock_nodejs_failure() {
        node() { return 1; }
        export -f node
    }
    
    mock_claude_installed() {
        npm() {
            if [[ "$*" == "list -g @anthropic-ai/claude-code" ]]; then
                echo "@anthropic-ai/claude-code@1.0.0"
                return 0
            fi
        }
        export -f npm
    }
    
    mock_claude_not_installed() {
        npm() {
            if [[ "$*" == "list -g @anthropic-ai/claude-code" ]]; then
                return 1
            fi
        }
        export -f npm
    }
    
    mock_claude_install_success() {
        npm() {
            if [[ "$*" == "install -g @anthropic-ai/claude-code" ]]; then
                return 0
            fi
        }
        export -f npm
    }
    
    mock_claude_install_failure() {
        npm() {
            if [[ "$*" == "install -g @anthropic-ai/claude-code" ]]; then
                echo "Error: Failed to install package"
                return 1
            fi
        }
        export -f npm
    }
    
    # Load functions
    load_claude_functions
}

teardown() {
    # Clean up any exports
    unset -f node npm 2>/dev/null || true
}

@test "check_nodejs_version succeeds with Node.js installed" {
    mock_nodejs_success
    run _check_nodejs_version
    [ "$status" -eq 0 ]
}

@test "check_nodejs_version fails without Node.js" {
    mock_nodejs_failure
    run _check_nodejs_version
    [ "$status" -eq 1 ]
}

@test "claude_is_installed returns true when installed" {
    mock_claude_installed
    run _claude_is_installed
    [ "$status" -eq 0 ]
}

@test "claude_is_installed returns false when not installed" {
    mock_claude_not_installed
    run _claude_is_installed
    [ "$status" -eq 1 ]
}

@test "claude_install_package succeeds with successful npm install" {
    mock_claude_install_success
    run _claude_install_package
    [ "$status" -eq 0 ]
}

@test "claude_install_package fails with npm error" {
    mock_claude_install_failure
    run _claude_install_package
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to install @anthropic-ai/claude-code"* ]]
}
