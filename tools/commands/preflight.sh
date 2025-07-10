#!/bin/bash

# Preflight command for Rift

# Source common functions
if [ -f "/usr/libexec/rift/commands/common.sh" ]; then
    source "/usr/libexec/rift/commands/common.sh"
else
    source "$(dirname "$0")/common.sh"
fi

run_preflight() {
    local inventory_file="$1"
    local deployment_type="$2"
    local verbose="$3"
    local ssh_key="$4"
    
    check_requirements "$inventory_file"
    set_ssh_key "$ssh_key"
    
    echo "Running preflight checks..."
    ansible-playbook playbooks/preflight.yml -i "$inventory_file" -e "deployment_type=$deployment_type" $verbose
} 