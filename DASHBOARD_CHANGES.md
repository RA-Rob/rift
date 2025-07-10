# Dashboard Directory Implementation Summary

This document summarizes the changes made to create a dedicated `dashboards/` directory for Grafana dashboard management in Rift.

## Changes Made

### 1. Directory Structure
- **Renamed**: `examples/` → `dashboards/`
- **Purpose**: Dedicated location for all Grafana dashboard JSON files
- **Contents**: All dashboard definitions are now centralized in this directory

### 2. RPM Package Updates (`rift.spec`)
- Updated directory creation from `examples` to `dashboards`
- Enhanced file installation to include all JSON files in the dashboards directory
- Changed from single file installation to wildcard installation:
  ```bash
  # Old: install -m 644 examples/sample-dashboard.json
  # New: cp dashboards/*.json %{buildroot}%{_datadir}/rift/dashboards/
  ```

### 3. Documentation Updates

#### Main README (`README.md`)
- Added dashboards directory to project structure
- Added dashboard management to features list
- Added new "Dashboards" section with:
  - Dashboard organization guidelines
  - Management commands
  - Usage examples
- Updated usage examples to include dashboard commands

#### Dashboard Management Guide (`docs/dashboard-management.md`)
- Updated all examples to reference `dashboards/` directory
- Added comprehensive "Dashboard Storage" section
- Enhanced JSON format documentation to support both formats:
  - **Wrapped Format**: Dashboard wrapped in "dashboard" object
  - **Direct Format**: Direct dashboard export from Grafana UI
- Updated batch import examples for both development and installed environments

### 4. Command Logic Updates (`tools/commands/dashboard.sh`)

#### Enhanced Validation
- Added support for both dashboard formats (wrapped and direct)
- Improved format detection with clear feedback
- Better error messages and warnings

#### Improved Import Logic
- Enhanced dashboard import to handle both JSON formats automatically
- Added format detection in Ansible playbook
- Better error handling and logging

### 5. File Locations

#### Development Environment
- Dashboard files: `./dashboards/`
- Sample dashboard: `dashboards/sample-dashboard.json`

#### Installed Environment (RPM)
- Dashboard files: `/usr/share/rift/dashboards/`
- Log files: `/var/log/rift/dashboard-*.log`

## Usage Examples

### Basic Dashboard Management
```bash
# Validate a dashboard
rift dashboard validate -d dashboards/my-dashboard.json

# Add a dashboard
rift dashboard add -d dashboards/system-monitoring.json

# List existing dashboards
rift dashboard list

# Add with custom Grafana URL
rift dashboard add -d dashboards/app-metrics.json -u http://grafana.example.com:3000
```

### Batch Import
```bash
# Development environment
for dashboard in dashboards/*.json; do
    rift dashboard add -d "$dashboard"
done

# Installed environment
for dashboard in /usr/share/rift/dashboards/*.json; do
    rift dashboard add -d "$dashboard"
done
```

## Benefits

1. **Centralized Management**: All dashboard definitions in one location
2. **Automatic Packaging**: Dashboards included in RPM releases
3. **Flexible Formats**: Support for both Grafana export formats
4. **Better Organization**: Clear separation from other project files
5. **Enhanced Documentation**: Comprehensive usage examples and guides

## Files Updated

1. **rift.spec**: RPM packaging updates
2. **README.md**: Project documentation
3. **docs/dashboard-management.md**: Dashboard usage guide
4. **tools/commands/dashboard.sh**: Enhanced command implementation
5. **dashboards/**: New directory structure

This implementation provides a robust foundation for managing Grafana dashboards as part of the Rift deployment workflow. 