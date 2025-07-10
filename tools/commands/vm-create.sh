#!/bin/bash

# VM Create command for Rift

show_usage() {
    cat << EOF
Usage: rift vm-create [OPTIONS] <platform>

Create VMs on the specified platform.

PLATFORMS:
    kvm       Create VMs on KVM host
    aws       Create VMs on AWS
    azure     Create VMs on Azure

OPTIONS:
    -h, --help     Show this help message
    -v, --verbose  Enable verbose output
    -n, --count    Number of VMs to create (default: 1)
    -s, --size     VM size/type (default: standard)
    -r, --region   Region for cloud platforms (default: us-east-1)

EXAMPLES:
    rift vm-create kvm
    rift vm-create aws -n 3 -s t3.medium
    rift vm-create azure -r eastus

EOF
}

# Parse command line arguments
PLATFORM=""
VM_COUNT=1
VM_SIZE="standard"
REGION="us-east-1"
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
        -n|--count)
            VM_COUNT="$2"
            shift 2
            ;;
        -s|--size)
            VM_SIZE="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
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

# Execute platform-specific script
case "$PLATFORM" in
    kvm)
        "$ROCKY9_TOOLS_DIR/create_vms.sh" -n "$VM_COUNT" -s "$VM_SIZE" ${VERBOSE:+-v}
        ;;
    aws)
        "$ROCKY9_TOOLS_DIR/create_vms_aws.sh" -n "$VM_COUNT" -s "$VM_SIZE" -r "$REGION" ${VERBOSE:+-v}
        ;;
    azure)
        "$ROCKY9_TOOLS_DIR/create_vms_azure.sh" -n "$VM_COUNT" -s "$VM_SIZE" -r "$REGION" ${VERBOSE:+-v}
        ;;
    *)
        echo "Error: Unsupported platform: $PLATFORM"
        echo "Supported platforms: kvm, aws, azure"
        exit 1
        ;;
esac 