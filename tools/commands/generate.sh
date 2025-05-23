#!/bin/bash

# Generate command for Chasm

# Source common functions
if [ -f "/usr/libexec/chasm/commands/common.sh" ]; then
    source "/usr/libexec/chasm/commands/common.sh"
else
    source "$(dirname "$0")/common.sh"
fi

generate_inventory() {
    local inventory_file="$1"
    local deployment_type
    
    echo "Generating inventory file: $inventory_file"
    echo
    
    # Ask for deployment type
    while true; do
        deployment_type=$(prompt "Enter deployment type" "baremetal")
        if [[ "$deployment_type" =~ ^(baremetal|cloud)$ ]]; then
            break
        fi
        echo "Error: Deployment type must be either 'baremetal' or 'cloud'"
    done
    
    # Create inventory directory if it doesn't exist
    mkdir -p "$(dirname "$inventory_file")"
    
    # Start building inventory file
    {
        echo "# Generated inventory file for Chasm deployment"
        echo "# Deployment Type: $deployment_type"
        echo
        echo "[controller]"
        
        if [ "$deployment_type" = "baremetal" ]; then
            # Ask for controller details
            local controller_name
            local controller_ip
            
            controller_name=$(prompt "Enter controller hostname" "controller")
            controller_ip=$(prompt "Enter controller IP address")
            echo "$controller_name ansible_host=$controller_ip"
        else
            echo "# Controller will be dynamically populated for cloud deployment"
        fi
        
        echo
        echo "[workers]"
        
        if [ "$deployment_type" = "baremetal" ]; then
            # Ask for worker details
            local add_worker="yes"
            local worker_count=0
            
            while [ "$add_worker" = "yes" ]; do
                worker_count=$((worker_count + 1))
                local worker_name
                local worker_ip
                
                worker_name=$(prompt "Enter worker $worker_count hostname" "worker$worker_count")
                worker_ip=$(prompt "Enter worker $worker_count IP address")
                echo "$worker_name ansible_host=$worker_ip"
                
                if [ $worker_count -lt 2 ]; then
                    add_worker="yes"
                else
                    add_worker=$(prompt "Add another worker? (yes/no)" "no")
                fi
            done
        else
            echo "# Workers will be dynamically populated for cloud deployment"
        fi
        
        echo
        echo "[chasm_servers:children]"
        echo "controller"
        echo "workers"
        echo
        echo "# Deployment type groups"
        echo "[$deployment_type:children]"
        echo "controller"
        echo "workers"
        echo
        echo "[all:vars]"
        echo "ansible_user=ansible"
        echo "ansible_python_interpreter=/usr/bin/python3"
        echo "ansible_distribution_major_version=9"
        echo "deployment_type=$deployment_type"
        echo "install_user=$(prompt "Enter installation username" "ansible")"
        echo "install_uid=$(prompt "Enter installation user UID" "1000")"
        echo "install_gid=$(prompt "Enter installation user GID" "1000")"
        
    } > "$inventory_file"
    
    echo
    echo "Inventory file generated successfully at: $inventory_file"
    echo "Please review the file and make any necessary adjustments."
} 