#!/bin/bash

# Verify command for Chasm

# Source common functions
source "$(dirname "$0")/common.sh"

verify_inventory() {
    local inventory_file="$1"
    local deployment_type="$2"
    local verbose="$3"
    
    check_requirements "$inventory_file"
    echo "Verifying inventory structure..."
    ansible-playbook $verbose playbooks/verify_inventory.yml -i "$inventory_file" -e "deployment_type=$deployment_type"
} 