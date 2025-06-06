#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

usage() {
    echo "Usage: chasm vm-cleanup [OPTIONS] <platform>"
    echo
    echo "Clean up VMs and associated resources on the specified platform"
    echo
    echo "Platforms:"
    echo "  kvm     Clean up local KVM/libvirt VMs"
    echo "  aws     Clean up AWS resources"
    echo "  azure   Clean up Azure resources"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --force    Skip confirmation prompts"
    echo "  -c, --config   Path to custom configuration file"
    exit 1
}

# Parse command line arguments
FORCE=false
CONFIG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -c|--config)
            CONFIG="$2"
            shift 2
            ;;
        *)
            PLATFORM="$1"
            shift
            ;;
    esac
done

# Validate platform
if [[ ! "$PLATFORM" =~ ^(kvm|aws|azure)$ ]]; then
    echo "Error: Invalid platform. Must be one of: kvm, aws, azure"
    usage
fi

# Set paths
ROCKY9_TOOLS_DIR="$CHASM_DATA_DIR/tools/rocky9"
COMMON_SCRIPT="$ROCKY9_TOOLS_DIR/common.sh"

# Source Rocky9 common functions if they exist
if [[ -f "$COMMON_SCRIPT" ]]; then
    source "$COMMON_SCRIPT"
fi

# Execute the appropriate cleanup script based on platform
case "$PLATFORM" in
    kvm)
        if [[ "$FORCE" == "true" ]]; then
            virsh destroy controller worker1 worker2 2>/dev/null || true
            virsh undefine controller worker1 worker2 --remove-all-storage 2>/dev/null || true
        else
            read -p "Are you sure you want to destroy all KVM VMs? [y/N] " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                virsh destroy controller worker1 worker2 2>/dev/null || true
                virsh undefine controller worker1 worker2 --remove-all-storage 2>/dev/null || true
            fi
        fi
        ;;
    aws)
        if [[ "$FORCE" == "true" ]]; then
            "$ROCKY9_TOOLS_DIR/cleanup_aws.sh" --force ${CONFIG:+--config "$CONFIG"}
        else
            "$ROCKY9_TOOLS_DIR/cleanup_aws.sh" ${CONFIG:+--config "$CONFIG"}
        fi
        ;;
    azure)
        if [[ "$FORCE" == "true" ]]; then
            "$ROCKY9_TOOLS_DIR/cleanup_azure.sh" --force ${CONFIG:+--config "$CONFIG"}
        else
            "$ROCKY9_TOOLS_DIR/cleanup_azure.sh" ${CONFIG:+--config "$CONFIG"}
        fi
        ;;
esac 