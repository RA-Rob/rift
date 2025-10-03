# Rift

<div align="center">
  <img src="docs/images/Rift-Logo-50.svg" alt="Rift Logo" width="200">
</div>

[![Build RPM](https://github.com/RA-Rob/rift/actions/workflows/build-rpm.yml/badge.svg)](https://github.com/RA-Rob/rift/actions/workflows/build-rpm.yml)
[![Test Build](https://github.com/RA-Rob/rift/actions/workflows/test-build.yml/badge.svg)](https://github.com/RA-Rob/rift/actions/workflows/test-build.yml)
[![Documentation Build](https://github.com/RA-Rob/rift/actions/workflows/docs.yml/badge.svg)](https://github.com/RA-Rob/rift/actions/workflows/docs.yml)

[![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)]
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://ra-rob.github.io/rift/)

[![Python](https://img.shields.io/badge/python-3.9%2B-blue.svg)](https://www.python.org/downloads/)
[![Ansible](https://img.shields.io/badge/ansible-2.9%2B-red.svg)](https://docs.ansible.com/)

[![Issues](https://img.shields.io/github/issues/RA-Rob/rift.svg)](https://github.com/RA-Rob/rift/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Ansible-based deployment system for Rocky Linux 9 and RHEL 9 environments.

## Overview

Rift is a deployment automation system that provides a standardized way to deploy and configure systems in both bare metal and cloud environments. It includes preflight checks, system configuration, and deployment capabilities.

For detailed documentation, including installation guides, usage instructions, and API reference, visit our [documentation site](https://ra-rob.github.io/rift/).

## Features

- Interactive inventory generation for both bare metal and cloud deployments
- Preflight checks for system requirements and SSH access
- Automated deployment of Ansible playbooks
- Support for both bare metal and cloud environments
- Grafana dashboard management and deployment
- Modular command structure for easy maintenance and extension

## Project Structure

```
.
├── tools/
│   ├── rift               # Main deployment script
│   └── commands/          # Command-specific scripts
│       ├── common.sh      # Shared utility functions
│       ├── generate.sh    # Inventory generation
│       ├── verify.sh      # Inventory verification
│       ├── preflight.sh   # Preflight checks
│       ├── deploy.sh      # Deployment execution
│       └── dashboard.sh   # Dashboard management
├── inventory/             # Ansible inventory files
├── playbooks/            # Ansible playbooks
├── roles/                # Ansible roles
├── group_vars/           # Group variables
├── host_vars/            # Host variables
├── dashboards/           # Grafana dashboard definitions
├── ansible.cfg           # Ansible configuration
└── site.yml             # Main playbook
```

## Prerequisites

- Ansible 2.9 or higher
- Python 3.6 or higher
- SSH access to target systems
- Passwordless sudo access for the installation user

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/RA-Rob/rift.git
   cd rift
   ```

2. Make the main script executable:
   ```bash
   chmod +x tools/rift
   ```

## Usage

The `rift` script provides several commands for managing your deployment:

### Generate Inventory

Create a new inventory file interactively:
```bash
./tools/rift generate
```

### Verify Inventory

Check the inventory structure and deployment type:
```bash
./tools/rift verify
```

### Run Preflight Checks

Perform preflight checks and setup installation user:
```bash
./tools/rift preflight
```

### Deploy

Deploy Rift to the target environment:
```bash
./tools/rift deploy
```

### Manage Dashboards

Add Grafana dashboards to the controller node:
```bash
# Add a specific dashboard
./tools/rift dashboard add -d dashboards/sample-dashboard.json

# List existing dashboards
./tools/rift dashboard list

# Validate a dashboard file
./tools/rift dashboard validate -d dashboards/my-dashboard.json
```

### Version Information

Display the current version:
```bash
./tools/rift version
```

### Command Options

- `-t, --type`: Deployment type (baremetal|cloud) [default: baremetal]
- `-i, --inventory`: Inventory file [default: inventory/inventory.ini]
- `-v, --verbose`: Enable verbose output
- `-k, --key`: SSH public key file for installation user
- `-h, --help`: Show help message

## Development

### Adding New Commands

1. Create a new script in `tools/commands/`
2. Source the common functions: `source "$(dirname "$0")/common.sh"`
3. Add your command function
4. Update the main script to include your new command

### Testing

1. Create a test inventory file
2. Run preflight checks
3. Verify the deployment

## Variables

### Common Variables

- `install_user`: Installation user name (default: ansible)
- `install_uid`: Installation user UID (default: 1000)
- `install_gid`: Installation user GID (default: 1000)
- `deployment_type`: Deployment type (baremetal/cloud)

### Controller-specific Variables

- `controller_packages`: Additional packages for controller nodes
- `rift.controller.api_port`: Controller API port
- `rift.controller.metrics_port`: Controller metrics port

### Worker-specific Variables

- `rift.worker.controller_host`: Controller host address
- `rift.worker.controller_port`: Controller port

## Dashboards

The `dashboards/` directory contains Grafana dashboard definitions in JSON format. These dashboards can be deployed to Grafana instances running on controller nodes using the `rift dashboard` command.

### Dashboard Organization

- Place all dashboard JSON files in the `dashboards/` directory
- Dashboard files are automatically included in RPM packages
- Use descriptive names (e.g., `system-monitoring.json`, `application-metrics.json`)
- Sample dashboard provided: `dashboards/sample-dashboard.json`

### Managing Dashboards

```bash
# Add a dashboard to Grafana
rift dashboard add -d dashboards/my-dashboard.json

# List all dashboards in Grafana
rift dashboard list

# Validate a dashboard before deployment
rift dashboard validate -d dashboards/my-dashboard.json
```

## Security

- SSH key-based authentication
- Passwordless sudo for installation user
- SELinux enabled by default
- Docker security configurations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License

## Author

Rob Weiss <rob.weiss@red-alpha.com>

## Releases

Rift is distributed as RPM packages for RHEL 9 and Rocky Linux 9. There are two types of releases:

### Stable Releases
Stable releases are versioned using semantic versioning (e.g., `v1.0.0`). These releases are thoroughly tested and recommended for production use.

### Release Candidates
Release candidates (RC) are pre-release versions that are available for testing before the stable release. They are tagged with `-rc` suffix (e.g., `v1.0.0-rc1`).

### Current Release Status
The current version is 0.0.1, with release candidate v0.0.1-rc1 available for testing. This release includes:
- Fixed RPM build issues
- Corrected version command implementation
- Improved GitHub Actions workflow for RPM asset publishing

### Installing from Releases

1. Visit the [GitHub Releases](https://github.com/RA-Rob/rift/releases) page
2. Download the appropriate RPM for your distribution:
   - `rift-<version>.rhel9.rpm` for RHEL 9
   - `rift-<version>.rocky9.rpm` for Rocky Linux 9
3. Install the RPM:
   ```bash
   # For RHEL 9
   sudo dnf install rift-<version>.rhel9.rpm

   # For Rocky Linux 9
   sudo dnf install rift-<version>.rocky9.rpm
   ```

### Testing Release Candidates

To test a release candidate:

1. Go to the [GitHub Releases](https://github.com/RA-Rob/rift/releases) page
2. Look for releases marked as "Pre-release"
3. Download and test the RC version
4. Report any issues or feedback

### Building from Source

To build Rift from source:

1. Clone the repository:
   ```bash
   git clone https://github.com/RA-Rob/rift.git
   cd rift
   ```

2. Build the RPM:
   ```bash
   # Install build dependencies
   sudo dnf install rpm-build python3-pip

   # Build the RPM
   make rpm
   ```

3. Install the built RPM:
   ```bash
   sudo dnf install ~/rpmbuild/RPMS/noarch/rift-*.rpm
   ``` 