#!/bin/bash

# Automated Output File Processing Script for Cron
# This script is designed to run every 5 minutes via cron to automatically
# process output files from the source directory to target directory
#
# Cron entry example (run as RIFT_USER with passwordless sudo):
# */5 * * * * /path/to/output-cron.sh >> /var/log/output-processing.log 2>&1

# Configuration variables - modify these paths as needed
OUTPUT_SOURCE_DIR="${OUTPUT_SOURCE_DIR:-/opt/exports/abyss-default/outputs/dataExporterinspection}"
OUTPUT_TARGET_DIR="${OUTPUT_TARGET_DIR:-/var/abyss/output}"
OUTPUT_PROCESSED_DIR="${OUTPUT_PROCESSED_DIR:-${OUTPUT_SOURCE_DIR}/processed}"
OUTPUT_OWNER_UID="${OUTPUT_OWNER_UID:-500}"
OUTPUT_OWNER_GID="${OUTPUT_OWNER_GID:-500}"
OUTPUT_PERMISSIONS="${OUTPUT_PERMISSIONS:-644}"
RIFT_USER="${RIFT_USER:-rift}"

# Logging configuration
LOG_FILE="/var/log/output-processing.log"
MAX_LOG_SIZE=10485760  # 10MB in bytes

# Script configuration
SCRIPT_NAME="output-cron"
# Use user-writable directory for lock and PID files
LOCK_DIR="${TMPDIR:-/tmp}/rift-cron"
LOCK_FILE="${LOCK_DIR}/${SCRIPT_NAME}.lock"
PID_FILE="${LOCK_DIR}/${SCRIPT_NAME}.pid"

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

# Function to ensure lock directory exists
ensure_lock_directory() {
    if [ ! -d "$LOCK_DIR" ]; then
        if mkdir -p "$LOCK_DIR" 2>/dev/null; then
            log_message "Created lock directory: $LOCK_DIR"
        else
            log_message "ERROR: Failed to create lock directory: $LOCK_DIR"
            return 1
        fi
    fi
    return 0
}

# Function to acquire lock
acquire_lock() {
    # Ensure lock directory exists first
    if ! ensure_lock_directory; then
        return 1
    fi
    
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

# Function to ensure processed directory exists
ensure_processed_directory() {
    if [ ! -d "$OUTPUT_PROCESSED_DIR" ]; then
        log_message "Creating processed directory: $OUTPUT_PROCESSED_DIR"
        if sudo mkdir -p "$OUTPUT_PROCESSED_DIR" 2>/dev/null; then
            # Set ownership for the processed directory
            if sudo chown "$OUTPUT_OWNER_UID:$OUTPUT_OWNER_GID" "$OUTPUT_PROCESSED_DIR" 2>/dev/null; then
                log_message "Set ownership for processed directory: $OUTPUT_OWNER_UID:$OUTPUT_OWNER_GID"
            else
                log_message "WARNING: Failed to set ownership for processed directory"
            fi
            
            # Set permissions for the processed directory
            if sudo chmod 755 "$OUTPUT_PROCESSED_DIR" 2>/dev/null; then
                log_message "Set permissions for processed directory: 755"
            else
                log_message "WARNING: Failed to set permissions for processed directory"
            fi
        else
            log_message "ERROR: Failed to create processed directory: $OUTPUT_PROCESSED_DIR"
            return 1
        fi
    fi
    return 0
}

# Function to validate directories exist
validate_directories() {
    local errors=0
    
    if [ ! -d "$OUTPUT_SOURCE_DIR" ]; then
        log_message "ERROR: Source directory does not exist: $OUTPUT_SOURCE_DIR"
        errors=$((errors + 1))
    fi
    
    if [ ! -d "$OUTPUT_TARGET_DIR" ]; then
        log_message "ERROR: Target directory does not exist: $OUTPUT_TARGET_DIR"
        errors=$((errors + 1))
    fi
    
    # Ensure processed directory exists
    if ! ensure_processed_directory; then
        errors=$((errors + 1))
    fi
    
    return $errors
}

# Function to copy output file to target directory with atomic operation
copy_output_file() {
    local source_file="$1"
    local target_dir="$2"
    local filename=$(basename "$source_file")
    local target_file="$target_dir/$filename"
    local temp_file="$target_dir/.${filename}.tmp.$$"
    
    # Copy to temporary file first using sudo
    if sudo cp "$source_file" "$temp_file" 2>/dev/null; then
        log_message "Copied: $filename to temporary location"
        
        # Set ownership using sudo
        if sudo chown "$OUTPUT_OWNER_UID:$OUTPUT_OWNER_GID" "$temp_file" 2>/dev/null; then
            log_message "Set ownership: $OUTPUT_OWNER_UID:$OUTPUT_OWNER_GID for $temp_file"
        else
            log_message "WARNING: Failed to set ownership for $temp_file"
            sudo rm -f "$temp_file" 2>/dev/null
            return 1
        fi
        
        # Set permissions using sudo
        if sudo chmod "$OUTPUT_PERMISSIONS" "$temp_file" 2>/dev/null; then
            log_message "Set permissions: $OUTPUT_PERMISSIONS for $temp_file"
        else
            log_message "WARNING: Failed to set permissions for $temp_file"
            sudo rm -f "$temp_file" 2>/dev/null
            return 1
        fi
        
        # Atomic move from temp to final location
        if sudo mv "$temp_file" "$target_file" 2>/dev/null; then
            log_message "Atomically moved: $filename to $target_dir"
            
            # Move source file to processed directory after successful copy
            local processed_file="$OUTPUT_PROCESSED_DIR/$filename"
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

# Function to process all output files
process_output_files() {
    local processed=0
    local errors=0
    local found_files=false
    
    # Find all files in source directory (all file types)
    while IFS= read -r -d '' output_file; do
        found_files=true
        if [ -f "$output_file" ]; then
            local filename=$(basename "$output_file")
            log_message "Processing: $filename"
            
            # Copy to target directory with atomic operation
            if copy_output_file "$output_file" "$OUTPUT_TARGET_DIR"; then
                # Source file is moved to processed directory after successful copy
                processed=$((processed + 1))
            else
                errors=$((errors + 1))
            fi
        fi
    done < <(find "$OUTPUT_SOURCE_DIR" -type f -print0 2>/dev/null)
    
    if [ "$found_files" = false ]; then
        log_message "No output files found in source directory"
    else
        log_message "Processing complete. Files processed: $processed, Errors: $errors"
    fi
    
    return $errors
}

# Function to check system health
check_system_health() {
    local warnings=0
    
    # Check available disk space in target directory
    if [ -d "$OUTPUT_TARGET_DIR" ]; then
        local available_space=$(df -h "$OUTPUT_TARGET_DIR" | awk 'NR==2 {print $4}' | sed 's/[^0-9]//g')
        if [ -n "$available_space" ] && [ "$available_space" -lt 1000000 ]; then  # Less than ~1GB
            log_message "WARNING: Low disk space in $OUTPUT_TARGET_DIR"
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
    
    log_message "Starting automated output file processing"
    
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
    
    # Process output files
    if process_output_files; then
        log_message "Output file processing completed successfully"
        cleanup_and_exit 0
    else
        log_message "Output file processing completed with errors"
        cleanup_and_exit 1
    fi
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
