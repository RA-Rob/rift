#!/bin/bash

# Automated Dye File Processing Script for Cron
# This script is designed to run every 5 minutes via cron to automatically
# process dye files from the source directory to target directories
#
# Cron entry example (run as RIFT_USER with passwordless sudo):
# */5 * * * * /path/to/dye-cron.sh >> /var/log/dye-processing.log 2>&1

# Configuration variables - modify these paths as needed
DYE_SOURCE_DIR="/var/abyss/dye"
DYE_TARGET_DIR1="/opt/exports/abyss-default/signatures-local/deep-core-main"
DYE_TARGET_DIR2="/opt/exports/abyss-default/signatures/deep-core-main/current/signatures/local"
DYE_OWNER_UID=500
DYE_OWNER_GID=500
DYE_PERMISSIONS=644
RIFT_USER="${RIFT_USER:-ec2-user}"

# Logging configuration
LOG_FILE="/var/log/dye-processing.log"
MAX_LOG_SIZE=10485760  # 10MB in bytes

# Script configuration
SCRIPT_NAME="dye-cron"
LOCK_FILE="/var/run/${SCRIPT_NAME}.lock"
PID_FILE="/var/run/${SCRIPT_NAME}.pid"

# Function to log messages with timestamp
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$SCRIPT_NAME] $message"
    
    # Also log to file if LOG_FILE is writable
    if [ -w "$(dirname "$LOG_FILE")" ] || [ -w "$LOG_FILE" ]; then
        echo "[$timestamp] [$SCRIPT_NAME] $message" >> "$LOG_FILE" 2>/dev/null
    fi
}

# Function to rotate log file if it gets too large
rotate_log() {
    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        local log_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || echo "0")
        if [ "$log_size" -gt "$MAX_LOG_SIZE" ]; then
            log_message "Rotating log file (size: $log_size bytes)"
            mv "$LOG_FILE" "${LOG_FILE}.old" 2>/dev/null
            touch "$LOG_FILE" 2>/dev/null
        fi
    fi
}

# Function to acquire lock
acquire_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            log_message "Another instance is already running (PID: $lock_pid). Exiting."
            return 1
        else
            log_message "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    echo $$ > "$LOCK_FILE"
    echo $$ > "$PID_FILE"
    return 0
}

# Function to release lock
release_lock() {
    rm -f "$LOCK_FILE" "$PID_FILE" 2>/dev/null
}

# Function to handle script exit
cleanup_and_exit() {
    local exit_code=${1:-0}
    log_message "Script exiting with code: $exit_code"
    release_lock
    exit $exit_code
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
    local found_files=false
    
    # Find all .dye files in source directory
    while IFS= read -r -d '' dye_file; do
        found_files=true
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
    
    if [ "$found_files" = false ]; then
        log_message "No dye files found in source directory"
    else
        log_message "Processing complete. Files processed: $processed, Errors: $errors"
    fi
    
    return $errors
}

# Function to check system health
check_system_health() {
    local warnings=0
    
    # Check available disk space in target directories
    for target_dir in "$DYE_TARGET_DIR1" "$DYE_TARGET_DIR2"; do
        if [ -d "$target_dir" ]; then
            local available_space=$(df -h "$target_dir" | awk 'NR==2 {print $4}' | sed 's/[^0-9]//g')
            if [ -n "$available_space" ] && [ "$available_space" -lt 1000000 ]; then  # Less than ~1GB
                log_message "WARNING: Low disk space in $target_dir"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    # Check if sudo is available (required for file operations)
    if ! command -v sudo &> /dev/null; then
        log_message "ERROR: sudo command not found. This script requires sudo access."
        return 1
    fi
    
    # Test sudo access (should be passwordless for cron)
    if ! sudo -n true 2>/dev/null; then
        log_message "ERROR: Passwordless sudo not configured for user $RIFT_USER. Cron jobs require passwordless sudo."
        return 1
    fi
    
    return $warnings
}

# Main execution
main() {
    # Set up signal handlers
    trap 'cleanup_and_exit 130' INT TERM
    
    # Rotate log if needed
    rotate_log
    
    log_message "Starting automated dye file processing"
    
    # Acquire lock to prevent multiple instances
    if ! acquire_lock; then
        cleanup_and_exit 1
    fi
    
    # Check system health
    check_system_health
    
    # Validate directories
    if ! validate_directories; then
        log_message "ERROR: Directory validation failed"
        cleanup_and_exit 1
    fi
    
    # Process dye files
    if process_dye_files; then
        log_message "Dye file processing completed successfully"
        cleanup_and_exit 0
    else
        log_message "Dye file processing completed with errors"
        cleanup_and_exit 1
    fi
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
