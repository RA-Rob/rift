# Chasm

[![Build RPM](https://github.com/RA-Rob/chasm/actions/workflows/build-rpm.yml/badge.svg)](https://github.com/RA-Rob/chasm/actions/workflows/build-rpm.yml)

Ansible-based deployment system for Rocky Linux 9 and RHEL 9 environments.

## Overview

Chasm is a deployment automation system that provides a standardized way to deploy and configure systems in both bare metal and cloud environments. It includes preflight checks, system configuration, and deployment capabilities.

## Features

- Interactive inventory generation for both bare metal and cloud deployments
- Preflight checks for system requirements and SSH access
- Automated deployment of Ansible playbooks
- Support for both bare metal and cloud environments
- Modular command structure for easy maintenance and extension

## Project Structure

```
.
├── tools/
│   ├── chasm              # Main deployment script
│   └── commands/          # Command-specific scripts
│       ├── common.sh      # Shared utility functions
│       ├── generate.sh    # Inventory generation
│       ├── verify.sh      # Inventory verification
│       ├── preflight.sh   # Preflight checks
│       └── deploy.sh      # Deployment execution
├── inventory/             # Ansible inventory files
├── playbooks/            # Ansible playbooks
├── roles/                # Ansible roles
├── group_vars/           # Group variables
├── host_vars/            # Host variables
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
   git clone https://github.com/RA-Rob/chasm.git
   cd chasm
   ```

2. Make the main script executable:
   ```bash
   chmod +x tools/chasm
   ```

## Usage

The `chasm` script provides several commands for managing your deployment:

### Generate Inventory

Create a new inventory file interactively:
```bash
./tools/chasm generate
```

### Verify Inventory

Check the inventory structure and deployment type:
```bash
./tools/chasm verify
```

### Run Preflight Checks

Perform preflight checks and setup installation user:
```bash
./tools/chasm preflight
```

### Deploy

Deploy Chasm to the target environment:
```bash
./tools/chasm deploy
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
- `chasm.controller.api_port`: Controller API port
- `chasm.controller.metrics_port`: Controller metrics port

### Worker-specific Variables

- `chasm.worker.controller_host`: Controller host address
- `chasm.worker.controller_port`: Controller port

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

[Your License Here]

## Author

Rob Weiss <rob.weiss@red-alpha.com> 