#!/usr/bin/env bash

# Test helper functions for Bats tests

# Create a mock command that always succeeds
create_mock_success() {
    local command_name="$1"
    local output="$2"
    
    cat > "$TEST_DIR/$command_name" << EOF
#!/bin/bash
echo "$output"
exit 0
EOF
    chmod +x "$TEST_DIR/$command_name"
}

# Create a mock command that always fails
create_mock_failure() {
    local command_name="$1"
    local output="$2"
    local exit_code="${3:-1}"
    
    cat > "$TEST_DIR/$command_name" << EOF
#!/bin/bash
echo "$output" >&2
exit $exit_code
EOF
    chmod +x "$TEST_DIR/$command_name"
}

# Check if a string contains another string
contains() {
    local haystack="$1"
    local needle="$2"
    [[ "$haystack" == *"$needle"* ]]
}
