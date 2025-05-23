#!/bin/bash

# Verify command for Chasm

# Source common functions
if [ -f "/usr/libexec/chasm/commands/common.sh" ]; then
    source "/usr/libexec/chasm/commands/common.sh"
else
    source "$(dirname "$0")/common.sh"
fi

verify_inventory() {
    local inventory_file="$1"
    local deployment_type="$2"
    local verbose="$3"
    
    check_requirements "$inventory_file"
    echo "Verifying inventory structure..."
    ansible-playbook $verbose playbooks/verify_inventory.yml -i "$inventory_file" -e "deployment_type=$deployment_type"
} 