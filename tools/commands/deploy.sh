#!/bin/bash

# Deploy command for Chasm

# Source common functions
source "$(dirname "$0")/common.sh"

run_deploy() {
    local inventory_file="$1"
    local deployment_type="$2"
    local verbose="$3"
    
    check_requirements "$inventory_file"
    echo "Deploying Chasm..."
    ansible-playbook $verbose site.yml -i "$inventory_file" -e "deployment_type=$deployment_type"
} 