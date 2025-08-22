#!/bin/bash

# Dye file management - Add dye files to system
# This script handles adding .dye files from source to target directories

# Configuration variables - modify these paths as needed
DYE_SOURCE_DIR="/var/abyss/dye"
DYE_TARGET_DIR1="/opt/exports/abyss-default/signatures-local/deep-core-main"
DYE_TARGET_DIR2="/opt/exports/abyss-default/signatures/deep-core-main/current/signatures/local"
DYE_OWNER_UID=500
DYE_OWNER_GID=500
DYE_PERMISSIONS=644
RIFT_USER="${RIFT_USER:-ec2-user}"

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to validate directories exist
validate_directories() {
    local errors=0
    
    if [ ! -d "$DYE_SOURCE_DIR" ]; then
        log_message "ERROR: Source directory does not exist: $DYE_SOURCE_DIR"
        errors=$((errors + 1))
    fi
    
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

# Function to copy dye file to target directory
copy_dye_file() {
    local source_file="$1"
    local target_dir="$2"
    local filename=$(basename "$source_file")
    local target_file="$target_dir/$filename"
    
    # Copy the file using sudo
    if sudo cp "$source_file" "$target_file" 2>/dev/null; then
        log_message "Copied: $filename to $target_dir"
        
        # Set ownership using sudo
        if sudo chown "$DYE_OWNER_UID:$DYE_OWNER_GID" "$target_file" 2>/dev/null; then
            log_message "Set ownership: $DYE_OWNER_UID:$DYE_OWNER_GID for $target_file"
        else
            log_message "WARNING: Failed to set ownership for $target_file"
        fi
        
        # Set permissions using sudo
        if sudo chmod "$DYE_PERMISSIONS" "$target_file" 2>/dev/null; then
            log_message "Set permissions: $DYE_PERMISSIONS for $target_file"
        else
            log_message "WARNING: Failed to set permissions for $target_file"
        fi
        
        return 0
    else
        log_message "ERROR: Failed to copy $filename to $target_dir"
        return 1
    fi
}

# Function to process all dye files
process_dye_files() {
    local processed=0
    local errors=0
    
    log_message "Starting dye file processing..."
    
    # Find all .dye files in source directory
    while IFS= read -r -d '' dye_file; do
        if [ -f "$dye_file" ]; then
            local filename=$(basename "$dye_file")
            log_message "Processing: $filename"
            
            # Copy to both target directories
            if copy_dye_file "$dye_file" "$DYE_TARGET_DIR1"; then
                if copy_dye_file "$dye_file" "$DYE_TARGET_DIR2"; then
                    # Remove source file after successful copy to both targets
                    if sudo rm "$dye_file" 2>/dev/null; then
                        log_message "Removed source file: $filename"
                        processed=$((processed + 1))
                    else
                        log_message "WARNING: Failed to remove source file: $filename"
                    fi
                else
                    errors=$((errors + 1))
                fi
            else
                errors=$((errors + 1))
            fi
        fi
    done < <(find "$DYE_SOURCE_DIR" -name "*.dye" -type f -print0 2>/dev/null)
    
    log_message "Processing complete. Files processed: $processed, Errors: $errors"
    return $errors
}

# Function to show usage
show_usage() {
    echo "Usage: rift dye-add [options]"
    echo
    echo "Add .dye files from $DYE_SOURCE_DIR to target directories"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo
    echo "Configuration:"
    echo "  Source directory: $DYE_SOURCE_DIR"
    echo "  Target directory 1: $DYE_TARGET_DIR1"
    echo "  Target directory 2: $DYE_TARGET_DIR2"
    echo "  File ownership: $DYE_OWNER_UID:$DYE_OWNER_GID"
    echo "  File permissions: $DYE_PERMISSIONS"
    echo "  Rift user: $RIFT_USER"
}

# Main function to handle dye-add command
handle_dye_add_command() {
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                return 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                echo "Error: Unknown option: $1"
                show_usage
                return 1
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
    
    # Process dye files
    if process_dye_files; then
        log_message "Dye file addition completed successfully"
        return 0
    else
        log_message "Dye file addition completed with errors"
        return 1
    fi
}
