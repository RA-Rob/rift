#!/bin/bash

# Deploy command for Chasm

# Source common functions
if [ -f "/usr/libexec/chasm/commands/common.sh" ]; then
    source "/usr/libexec/chasm/commands/common.sh"
else
    source "$(dirname "$0")/common.sh"
fi

run_deploy() {
    local inventory_file="$1"
    local deployment_type="$2"
    local verbose="$3"
    
    check_requirements "$inventory_file"
    echo "Deploying Chasm..."
    ansible-playbook $verbose site.yml -i "$inventory_file" -e "deployment_type=$deployment_type"
} 