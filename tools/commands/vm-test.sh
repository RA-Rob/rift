#!/bin/bash

# VM Test command for Rift

show_usage() {
    cat << EOF
Usage: rift vm-test [OPTIONS]

Test VM connectivity and configuration.

OPTIONS:
    -h, --help     Show this help message
    -v, --verbose  Enable verbose output
    -i, --inventory  Inventory file to use for testing (default: inventory/inventory.ini)
    -t, --timeout    Connection timeout in seconds (default: 30)

EXAMPLES:
    rift vm-test
    rift vm-test --verbose
    rift vm-test -i custom_inventory.ini

EOF
}

# Parse command line arguments
INVENTORY="inventory/inventory.ini"
TIMEOUT=30
VERBOSE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown argument: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Set data directory
RIFT_DATA_DIR="${RIFT_DATA_DIR:-/usr/share/rift}"
ROCKY9_TOOLS_DIR="$RIFT_DATA_DIR/tools/rocky9"

# Check if Rocky9 tools are available
if [ ! -d "$ROCKY9_TOOLS_DIR" ]; then
    echo "Error: Rocky9 tools not found at $ROCKY9_TOOLS_DIR"
    echo "Please ensure Rift is properly installed with Rocky9 tools."
    exit 1
fi

# Check if inventory file exists
if [ ! -f "$INVENTORY" ]; then
    echo "Error: Inventory file not found: $INVENTORY"
    exit 1
fi

# Execute test script
"$ROCKY9_TOOLS_DIR/test_lab.sh" -i "$INVENTORY" -t "$TIMEOUT" ${VERBOSE:+-v} 