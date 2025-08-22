#!/bin/bash

# Automated Input File Processing Script for Cron
# This script is designed to run every 5 minutes via cron to automatically
# process input files from the source directory to target directory
#
# Cron entry example (run as RIFT_USER with passwordless sudo):
# */5 * * * * /path/to/input-cron.sh >> /var/log/input-processing.log 2>&1

# Configuration variables - modify these paths as needed
INPUT_SOURCE_DIR="${INPUT_SOURCE_DIR:-/var/abyss/input}"
INPUT_TARGET_DIR="${INPUT_TARGET_DIR:-/data/io-service/input-undersluice-default}"
INPUT_OWNER_UID="${INPUT_OWNER_UID:-500}"
INPUT_OWNER_GID="${INPUT_OWNER_GID:-500}"
INPUT_PERMISSIONS="${INPUT_PERMISSIONS:-644}"
RIFT_USER="${RIFT_USER:-rift}"

# Logging configuration
LOG_FILE="/var/log/input-processing.log"
MAX_LOG_SIZE=10485760  # 10MB in bytes

# Script configuration
SCRIPT_NAME="input-cron"
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
    
    if [ ! -d "$INPUT_SOURCE_DIR" ]; then
        log_message "ERROR: Source directory does not exist: $INPUT_SOURCE_DIR"
        errors=$((errors + 1))
    fi
    
    if [ ! -d "$INPUT_TARGET_DIR" ]; then
        log_message "ERROR: Target directory does not exist: $INPUT_TARGET_DIR"
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
            return 0
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
    local found_files=false
    
    # Find all files in source directory (all file types)
    while IFS= read -r -d '' input_file; do
        found_files=true
        if [ -f "$input_file" ]; then
            local filename=$(basename "$input_file")
            log_message "Processing: $filename"
            
            # Copy to target directory with atomic operation
            if copy_input_file "$input_file" "$INPUT_TARGET_DIR"; then
                # Note: Unlike dye files, we do NOT remove the source file
                # as per the requirement "There is no need to delete the input files"
                processed=$((processed + 1))
            else
                errors=$((errors + 1))
            fi
        fi
    done < <(find "$INPUT_SOURCE_DIR" -type f -print0 2>/dev/null)
    
    if [ "$found_files" = false ]; then
        log_message "No input files found in source directory"
    else
        log_message "Processing complete. Files processed: $processed, Errors: $errors"
    fi
    
    return $errors
}

# Function to check system health
check_system_health() {
    local warnings=0
    
    # Check available disk space in target directory
    if [ -d "$INPUT_TARGET_DIR" ]; then
        local available_space=$(df -h "$INPUT_TARGET_DIR" | awk 'NR==2 {print $4}' | sed 's/[^0-9]//g')
        if [ -n "$available_space" ] && [ "$available_space" -lt 1000000 ]; then  # Less than ~1GB
            log_message "WARNING: Low disk space in $INPUT_TARGET_DIR"
            warnings=$((warnings + 1))
        fi
    fi
    
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
    
    log_message "Starting automated input file processing"
    
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
    
    # Process input files
    if process_input_files; then
        log_message "Input file processing completed successfully"
        cleanup_and_exit 0
    else
        log_message "Input file processing completed with errors"
        cleanup_and_exit 1
    fi
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
