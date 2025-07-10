#!/bin/bash

# Verify command for Rift

# Source common functions
if [ -f "/usr/libexec/rift/commands/common.sh" ]; then
    source "/usr/libexec/rift/commands/common.sh"
else
    source "$(dirname "$0")/common.sh"
fi

verify_inventory() {
    local inventory_file="$1"
    local deployment_type="$2"
    local verbose="$3"
    
    check_requirements "$inventory_file"
    
    echo "Verifying inventory..."
    ansible-inventory -i "$inventory_file" --list $verbose
} 