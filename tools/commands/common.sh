#!/bin/bash

# Common functions for Rift commands

# Function to prompt for input with default value
prompt() {
    local message="$1"
    local default="$2"
    local input
    
    if [ -n "$default" ]; then
        read -p "$message [$default]: " input
        echo "${input:-$default}"
    else
        read -p "$message: " input
        echo "$input"
    fi
}

# Function to check if required files exist
check_requirements() {
    local inventory_file="$1"
    
    if [ ! -f "$inventory_file" ]; then
        echo "Error: Inventory file not found: $inventory_file"
        exit 1
    fi
    if [ ! -f "ansible.cfg" ]; then
        echo "Error: ansible.cfg not found"
        exit 1
    fi
}

# Function to set SSH key
set_ssh_key() {
    local ssh_key="$1"
    
    if [ -n "$ssh_key" ]; then
        if [ ! -f "$ssh_key" ]; then
            echo "Error: SSH key file not found: $ssh_key"
            exit 1
        fi
        export RIFT_SSH_PUBLIC_KEY="$(cat "$ssh_key")"
    else
        echo "Error: SSH key file is required for preflight"
        exit 1
    fi
} 