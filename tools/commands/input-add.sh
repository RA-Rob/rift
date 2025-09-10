#!/bin/bash

# Input file management - Add input files to system
# This script handles adding input files from source to target directory with atomic copying

# Configuration variables - modify these paths as needed
INPUT_SOURCE_DIR="${INPUT_SOURCE_DIR:-/var/abyss/input}"
INPUT_TARGET_DIR="${INPUT_TARGET_DIR:-/data/io-service/input-undersluice-default}"
INPUT_PROCESSED_DIR="${INPUT_PROCESSED_DIR:-${INPUT_SOURCE_DIR}/processed}"
INPUT_OWNER_UID="${INPUT_OWNER_UID:-500}"
INPUT_OWNER_GID="${INPUT_OWNER_GID:-500}"
INPUT_PERMISSIONS="${INPUT_PERMISSIONS:-644}"
RIFT_USER="${RIFT_USER:-rift}"

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to ensure processed directory exists
ensure_processed_directory() {
    if [ ! -d "$INPUT_PROCESSED_DIR" ]; then
        log_message "Creating processed directory: $INPUT_PROCESSED_DIR"
        if sudo mkdir -p "$INPUT_PROCESSED_DIR" 2>/dev/null; then
            # Set ownership for the processed directory
            if sudo chown "$INPUT_OWNER_UID:$INPUT_OWNER_GID" "$INPUT_PROCESSED_DIR" 2>/dev/null; then
                log_message "Set ownership for processed directory: $INPUT_OWNER_UID:$INPUT_OWNER_GID"
            else
                log_message "WARNING: Failed to set ownership for processed directory"
            fi
            
            # Set permissions for the processed directory
            if sudo chmod 755 "$INPUT_PROCESSED_DIR" 2>/dev/null; then
                log_message "Set permissions for processed directory: 755"
            else
                log_message "WARNING: Failed to set permissions for processed directory"
            fi
        else
            log_message "ERROR: Failed to create processed directory: $INPUT_PROCESSED_DIR"
            return 1
        fi
    fi
    return 0
}

# Function to validate directories exist
validate_directories() {
    local errors=0
    
    if [ ! -d "$INPUT_SOURCE_DIR" ]; then
        log_message "ERROR: Source directory does not exist: $INPUT_SOURCE_DIR"
        errors=$((errors + 1))
    fi
    
    if [ ! -d "$INPUT_TARGET_DIR" ]; then
        log_message "ERROR: Target directory does not exist: $INPUT_TARGET_DIR"
        errors=$((errors + 1))
    fi
    
    # Ensure processed directory exists
    if ! ensure_processed_directory; then
        errors=$((errors + 1))
    fi
    
    return $errors
}

# Function to copy input file to target directory with atomic operation
copy_input_file() {
    local source_file="$1"
    local target_dir="$2"
    local filename=$(basename "$source_file")
    local target_file="$target_dir/$filename"
    local temp_file="$target_dir/.${filename}.tmp.$$"
    
    # Copy to temporary file first using sudo
    if sudo cp "$source_file" "$temp_file" 2>/dev/null; then
        log_message "Copied: $filename to temporary location"
        
        # Set ownership using sudo
        if sudo chown "$INPUT_OWNER_UID:$INPUT_OWNER_GID" "$temp_file" 2>/dev/null; then
            log_message "Set ownership: $INPUT_OWNER_UID:$INPUT_OWNER_GID for $temp_file"
        else
            log_message "WARNING: Failed to set ownership for $temp_file"
            sudo rm -f "$temp_file" 2>/dev/null
            return 1
        fi
        
        # Set permissions using sudo
        if sudo chmod "$INPUT_PERMISSIONS" "$temp_file" 2>/dev/null; then
            log_message "Set permissions: $INPUT_PERMISSIONS for $temp_file"
        else
            log_message "WARNING: Failed to set permissions for $temp_file"
            sudo rm -f "$temp_file" 2>/dev/null
            return 1
        fi
        
        # Atomic move from temp to final location
        if sudo mv "$temp_file" "$target_file" 2>/dev/null; then
            log_message "Atomically moved: $filename to $target_dir"
            
            # Move source file to processed directory after successful copy
            local processed_file="$INPUT_PROCESSED_DIR/$filename"
            if sudo mv "$source_file" "$processed_file" 2>/dev/null; then
                log_message "Moved source file to processed directory: $filename"
                return 0
            else
                log_message "WARNING: Failed to move source file to processed directory: $filename"
                # Still return success since the main copy operation succeeded
                return 0
            fi
        else
            log_message "ERROR: Failed to move $filename to final location"
            sudo rm -f "$temp_file" 2>/dev/null
            return 1
        fi
    else
        log_message "ERROR: Failed to copy $filename to temporary location"
        return 1
    fi
}

# Function to process all input files
process_input_files() {
    local processed=0
    local errors=0
    
    log_message "Starting input file processing..."
    
    # Find all files in source directory (all file types, not just specific extensions)
    while IFS= read -r -d '' input_file; do
        if [ -f "$input_file" ]; then
            local filename=$(basename "$input_file")
            log_message "Processing: $filename"
            
            # Copy to target directory with atomic operation
            if copy_input_file "$input_file" "$INPUT_TARGET_DIR"; then
                # Source file is moved to processed directory after successful copy
                processed=$((processed + 1))
            else
                errors=$((errors + 1))
            fi
        fi
    done < <(find "$INPUT_SOURCE_DIR" -type f -print0 2>/dev/null)
    
    log_message "Processing complete. Files processed: $processed, Errors: $errors"
    return $errors
}

# Function to show usage
show_usage() {
    echo "Usage: rift input-add [options]"
    echo
    echo "Add input files from $INPUT_SOURCE_DIR to target directory"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo
    echo "Configuration:"
    echo "  Source directory: $INPUT_SOURCE_DIR"
    echo "  Target directory: $INPUT_TARGET_DIR"
    echo "  File ownership: $INPUT_OWNER_UID:$INPUT_OWNER_GID"
    echo "  File permissions: $INPUT_PERMISSIONS"
    echo "  Rift user: $RIFT_USER"
    echo
    echo "Note: Files are copied atomically to prevent early access by other processes."
    echo "      Source files are moved to processed directory after successful copying."
}

# Main function to handle input-add command
handle_input_add_command() {
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
    
    # Process input files
    if process_input_files; then
        log_message "Input file addition completed successfully"
        return 0
    else
        log_message "Input file addition completed with errors"
        return 1
    fi
}
