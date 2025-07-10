#!/bin/bash

# Deploy command for Rift

# Source common functions
if [ -f "/usr/libexec/rift/commands/common.sh" ]; then
    source "/usr/libexec/rift/commands/common.sh"
else
    source "$(dirname "$0")/common.sh"
fi

run_deploy() {
    local inventory_file="$1"
    local deployment_type="$2"
    local verbose="$3"
    
    check_requirements "$inventory_file"
    
    echo "Deploying Rift..."
    ansible-playbook site.yml -i "$inventory_file" -e "deployment_type=$deployment_type" $verbose
} 