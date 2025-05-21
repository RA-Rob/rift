#!/bin/bash

# Version management script for Chasm
# Usage:
#   ./version.sh get          # Get current version
#   ./version.sh set 1.0.0    # Set version
#   ./version.sh bump patch   # Bump patch version
#   ./version.sh bump minor   # Bump minor version
#   ./version.sh bump major   # Bump major version

set -e

VERSION_FILE="../VERSION"
SPEC_FILE="../chasm.spec"

# Get current version
get_version() {
    cat "$VERSION_FILE"
}

# Set version in all relevant files
set_version() {
    local version=$1
    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"

    # Update VERSION file
    echo "$version" > "$VERSION_FILE"

    # Update spec file
    sed -i "s/^Version:.*/Version:        ${version}/" "$SPEC_FILE"

    # Update git tag
    git tag -a "v${version}" -m "Release v${version}"
}

# Bump version
bump_version() {
    local type=$1
    local current_version
    local major minor patch
    local new_version

    current_version=$(get_version)
    IFS='.' read -r major minor patch <<< "$current_version"

    case $type in
        "major")
            new_version="$((major + 1)).0.0"
            ;;
        "minor")
            new_version="${major}.$((minor + 1)).0"
            ;;
        "patch")
            new_version="${major}.${minor}.$((patch + 1))"
            ;;
        *)
            echo "Invalid version type. Use: major, minor, or patch"
            exit 1
            ;;
    esac

    set_version "$new_version"
}

# Main script logic
case "$1" in
    "get")
        get_version
        ;;
    "set")
        if [ -z "$2" ]; then
            echo "Error: Version number required"
            exit 1
        fi
        set_version "$2"
        ;;
    "bump")
        if [ -z "$2" ]; then
            echo "Error: Version type required (major, minor, patch)"
            exit 1
        fi
        bump_version "$2"
        ;;
    *)
        echo "Usage: $0 {get|set|bump} [version|type]"
        exit 1
        ;;
esac 