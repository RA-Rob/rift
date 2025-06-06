#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

usage() {
    echo "Usage: chasm vm-test [OPTIONS]"
    echo
    echo "Test VM connectivity and configuration"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Show detailed test output"
    exit 1
}

# Parse command line arguments
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
done

# Set paths
ROCKY9_TOOLS_DIR="$CHASM_DATA_DIR/tools/rocky9"
COMMON_SCRIPT="$ROCKY9_TOOLS_DIR/common.sh"

# Source Rocky9 common functions if they exist
if [[ -f "$COMMON_SCRIPT" ]]; then
    source "$COMMON_SCRIPT"
fi

# Execute the test script
if [[ "$VERBOSE" == "true" ]]; then
    "$ROCKY9_TOOLS_DIR/test_lab.sh" --verbose
else
    "$ROCKY9_TOOLS_DIR/test_lab.sh"
fi 