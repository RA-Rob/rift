# Chasm

Chasm is an Ansible-based deployment management tool for Rocky Linux 9 and RHEL 9 systems. It provides a streamlined approach to deploying and managing both bare metal and cloud environments.

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

- Ansible 2.9 or later
- Python 3.6 or later
- SSH access to target systems
- Passwordless sudo access for the installation user

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/chasm.git
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
./tools/chasm preflight -k ~/.ssh/id_rsa.pub
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

## License

[Your License Here]

## Author

Rob Weiss <rob.weiss@red-alpha.com> 