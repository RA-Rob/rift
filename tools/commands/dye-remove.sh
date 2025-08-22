#!/bin/bash

# Dye file management - Remove dye files from system
# This script handles removing .dye files from target directories

# Configuration variables - modify these paths as needed
DYE_TARGET_DIR1="/opt/exports/abyss-default/signatures-local/deep-core-main"
DYE_TARGET_DIR2="/opt/exports/abyss-default/signatures/deep-core-main/current/signatures/local"
RIFT_USER="${RIFT_USER:-ec2-user}"

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to validate directories exist
validate_directories() {
    local errors=0
    
    if [ ! -d "$DYE_TARGET_DIR1" ]; then
        log_message "ERROR: Target directory 1 does not exist: $DYE_TARGET_DIR1"
        errors=$((errors + 1))
    fi
    
    if [ ! -d "$DYE_TARGET_DIR2" ]; then
        log_message "ERROR: Target directory 2 does not exist: $DYE_TARGET_DIR2"
        errors=$((errors + 1))
    fi
    
    return $errors
}

# Function to remove dye files from a directory
remove_dye_files_from_dir() {
    local target_dir="$1"
    local removed=0
    local errors=0
    
    log_message "Removing dye files from: $target_dir"
    
    # Find and remove all .dye files in target directory using sudo
    while IFS= read -r -d '' dye_file; do
        if [ -f "$dye_file" ]; then
            local filename=$(basename "$dye_file")
            if sudo rm "$dye_file" 2>/dev/null; then
                log_message "Removed: $filename from $target_dir"
                removed=$((removed + 1))
            else
                log_message "ERROR: Failed to remove $filename from $target_dir"
                errors=$((errors + 1))
            fi
        fi
    done < <(sudo find "$target_dir" -name "*.dye" -type f -print0 2>/dev/null)
    
    log_message "Removed $removed files from $target_dir (Errors: $errors)"
    return $errors
}

# Function to remove specific dye file by name
remove_specific_dye_file() {
    local filename="$1"
    local removed=0
    local errors=0
    
    log_message "Removing specific dye file: $filename"
    
    # Remove from both target directories using sudo
    for target_dir in "$DYE_TARGET_DIR1" "$DYE_TARGET_DIR2"; do
        local target_file="$target_dir/$filename"
        if sudo test -f "$target_file" 2>/dev/null; then
            if sudo rm "$target_file" 2>/dev/null; then
                log_message "Removed: $filename from $target_dir"
                removed=$((removed + 1))
            else
                log_message "ERROR: Failed to remove $filename from $target_dir"
                errors=$((errors + 1))
            fi
        else
            log_message "File not found: $filename in $target_dir"
        fi
    done
    
    log_message "Removed $filename from $removed locations (Errors: $errors)"
    return $errors
}

# Function to list all dye files
list_dye_files() {
    local total=0
    
    log_message "Listing all dye files:"
    
    for target_dir in "$DYE_TARGET_DIR1" "$DYE_TARGET_DIR2"; do
        log_message "Directory: $target_dir"
        local count=0
        while IFS= read -r -d '' dye_file; do
            local filename=$(basename "$dye_file")
            local filesize=$(sudo stat -f%z "$dye_file" 2>/dev/null || echo "unknown")
            local filedate=$(sudo stat -f%Sm -t '%Y-%m-%d %H:%M:%S' "$dye_file" 2>/dev/null || echo "unknown")
            echo "  $filename (${filesize} bytes, $filedate)"
            count=$((count + 1))
            total=$((total + 1))
        done < <(sudo find "$target_dir" -name "*.dye" -type f -print0 2>/dev/null)
        log_message "Found $count dye files in $target_dir"
    done
    
    log_message "Total dye files found: $total"
}

# Function to remove all dye files
remove_all_dye_files() {
    local total_removed=0
    local total_errors=0
    
    log_message "Starting removal of all dye files..."
    
    for target_dir in "$DYE_TARGET_DIR1" "$DYE_TARGET_DIR2"; do
        remove_dye_files_from_dir "$target_dir"
        local exit_code=$?
        if [ $exit_code -gt 0 ]; then
            total_errors=$((total_errors + exit_code))
        fi
    done
    
    log_message "Dye file removal completed. Total errors: $total_errors"
    return $total_errors
}

# Function to show usage
show_usage() {
    echo "Usage: rift dye-remove [options] [filename]"
    echo
    echo "Remove .dye files from target directories"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -l, --list     List all dye files in target directories"
    echo "  -a, --all      Remove all dye files from target directories"
    echo "  -v, --verbose  Enable verbose output"
    echo
    echo "Arguments:"
    echo "  filename       Specific .dye file to remove (without path)"
    echo
    echo "Configuration:"
    echo "  Target directory 1: $DYE_TARGET_DIR1"
    echo "  Target directory 2: $DYE_TARGET_DIR2"
    echo "  Rift user: $RIFT_USER"
    echo
    echo "Examples:"
    echo "  rift dye-remove --list                    # List all dye files"
    echo "  rift dye-remove --all                     # Remove all dye files"
    echo "  rift dye-remove malware.dye               # Remove specific file"
}

# Main function to handle dye-remove command
handle_dye_remove_command() {
    local verbose=false
    local list_files=false
    local remove_all=false
    local specific_file=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                return 0
                ;;
            -l|--list)
                list_files=true
                shift
                ;;
            -a|--all)
                remove_all=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -*)
                echo "Error: Unknown option: $1"
                show_usage
                return 1
                ;;
            *)
                if [ -z "$specific_file" ]; then
                    specific_file="$1"
                    # Ensure it has .dye extension
                    if [[ "$specific_file" != *.dye ]]; then
                        specific_file="${specific_file}.dye"
                    fi
                else
                    echo "Error: Multiple filenames specified"
                    show_usage
                    return 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if sudo is available (required for file operations)
    if ! command -v sudo &> /dev/null; then
        log_message "ERROR: sudo command not found. This script requires sudo access."
        return 1
    fi
    
    # Test sudo access
    if ! sudo -n true 2>/dev/null; then
        log_message "WARNING: Passwordless sudo may not be configured for user $RIFT_USER. Operations may prompt for password."
    fi
    
    # Validate directories
    if ! validate_directories; then
        log_message "ERROR: Directory validation failed"
        return 1
    fi
    
    # Execute requested action
    if [ "$list_files" = true ]; then
        list_dye_files
        return 0
    elif [ "$remove_all" = true ]; then
        if [ -n "$specific_file" ]; then
            echo "Error: Cannot specify both --all and a specific filename"
            show_usage
            return 1
        fi
        echo "WARNING: This will remove ALL dye files from target directories."
        read -p "Are you sure? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            remove_all_dye_files
        else
            log_message "Operation cancelled by user"
            return 0
        fi
    elif [ -n "$specific_file" ]; then
        remove_specific_dye_file "$specific_file"
    else
        echo "Error: No action specified"
        show_usage
        return 1
    fi
}
