#!/bin/bash

# VM Cleanup command for Rift

show_usage() {
    cat << EOF
Usage: rift vm-cleanup [OPTIONS] <platform>

Clean up VMs and associated resources on the specified platform.

PLATFORMS:
    kvm       Clean up VMs on KVM host
    aws       Clean up VMs on AWS
    azure     Clean up VMs on Azure

OPTIONS:
    -h, --help     Show this help message
    -v, --verbose  Enable verbose output
    -f, --force    Force cleanup without confirmation
    -a, --all      Clean up all resources (including networks, storage)

EXAMPLES:
    rift vm-cleanup kvm
    rift vm-cleanup aws --force
    rift vm-cleanup azure --all

EOF
}

# Parse command line arguments
PLATFORM=""
FORCE=""
ALL=""
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
        -f|--force)
            FORCE="true"
            shift
            ;;
        -a|--all)
            ALL="true"
            shift
            ;;
        *)
            if [ -z "$PLATFORM" ]; then
                PLATFORM="$1"
            else
                echo "Error: Unknown argument: $1"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if platform is specified
if [ -z "$PLATFORM" ]; then
    echo "Error: Platform must be specified"
    show_usage
    exit 1
fi

# Set data directory
RIFT_DATA_DIR="${RIFT_DATA_DIR:-/usr/share/rift}"
ROCKY9_TOOLS_DIR="$RIFT_DATA_DIR/tools/rocky9"

# Check if Rocky9 tools are available
if [ ! -d "$ROCKY9_TOOLS_DIR" ]; then
    echo "Error: Rocky9 tools not found at $ROCKY9_TOOLS_DIR"
    echo "Please ensure Rift is properly installed with Rocky9 tools."
    exit 1
fi

# Execute platform-specific cleanup script
case "$PLATFORM" in
    kvm)
        "$ROCKY9_TOOLS_DIR/cleanup_vms.sh" ${FORCE:+--force} ${ALL:+--all} ${VERBOSE:+-v}
        ;;
    aws)
        "$ROCKY9_TOOLS_DIR/cleanup_aws.sh" ${FORCE:+--force} ${ALL:+--all} ${VERBOSE:+-v}
        ;;
    azure)
        "$ROCKY9_TOOLS_DIR/cleanup_azure.sh" ${FORCE:+--force} ${ALL:+--all} ${VERBOSE:+-v}
        ;;
    *)
        echo "Error: Unsupported platform: $PLATFORM"
        echo "Supported platforms: kvm, aws, azure"
        exit 1
        ;;
esac 