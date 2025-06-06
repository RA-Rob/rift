#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

usage() {
    echo "Usage: chasm vm-create [OPTIONS] <platform>"
    echo
    echo "Create VMs on the specified platform"
    echo
    echo "Platforms:"
    echo "  kvm     Create VMs using local KVM/libvirt"
    echo "  aws     Create VMs on AWS"
    echo "  azure   Create VMs on Azure"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --force    Force recreation of VMs if they exist"
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

# Execute the appropriate creation script based on platform
case "$PLATFORM" in
    kvm)
        if [[ "$FORCE" == "true" ]]; then
            "$ROCKY9_TOOLS_DIR/create_vms_cloudinit.sh" --force ${CONFIG:+--config "$CONFIG"}
        else
            "$ROCKY9_TOOLS_DIR/create_vms_cloudinit.sh" ${CONFIG:+--config "$CONFIG"}
        fi
        ;;
    aws)
        if [[ "$FORCE" == "true" ]]; then
            "$ROCKY9_TOOLS_DIR/create_vms_aws.sh" --force ${CONFIG:+--config "$CONFIG"}
        else
            "$ROCKY9_TOOLS_DIR/create_vms_aws.sh" ${CONFIG:+--config "$CONFIG"}
        fi
        ;;
    azure)
        if [[ "$FORCE" == "true" ]]; then
            "$ROCKY9_TOOLS_DIR/create_vms_azure.sh" --force ${CONFIG:+--config "$CONFIG"}
        else
            "$ROCKY9_TOOLS_DIR/create_vms_azure.sh" ${CONFIG:+--config "$CONFIG"}
        fi
        ;;
esac 