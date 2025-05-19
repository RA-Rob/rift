# Chasm Command-Line Tool

The Chasm command-line tool provides a unified interface for managing Ansible deployments. It simplifies common tasks like inventory management, preflight checks, and deployment execution.

## Overview

The tool is organized into a modular structure:
```
tools/
├── chasm              # Main deployment script
└── commands/          # Command-specific scripts
    ├── common.sh      # Shared utility functions
    ├── generate.sh    # Inventory generation
    ├── verify.sh      # Inventory verification
    ├── preflight.sh   # Preflight checks
    └── deploy.sh      # Deployment execution
```

## Commands

### generate
Interactive inventory file generation for both bare metal and cloud deployments.

```bash
./chasm generate
```

Features:
- Prompts for deployment type (baremetal/cloud)
- Interactive host configuration
- Automatic group and variable setup
- Support for multiple worker nodes

### verify
Validates inventory structure and deployment type.

```bash
./chasm verify
```

Checks:
- Inventory file existence and format
- Deployment type compatibility
- Required group structure
- Variable definitions

### preflight
Performs system checks and prepares the installation environment.

```bash
./chasm preflight -k ~/.ssh/id_rsa.pub
```

Tasks:
- SSH key deployment
- System requirements verification
- User access validation
- Network connectivity checks

### deploy
Executes the main deployment playbook.

```bash
./chasm deploy
```

Process:
- Inventory validation
- Environment-specific configuration
- Playbook execution
- Deployment verification

## Command Options

All commands support the following options:

- `-t, --type`: Deployment type (baremetal|cloud)
  - Default: baremetal
  - Example: `./chasm deploy -t cloud`

- `-i, --inventory`: Custom inventory file
  - Default: inventory/inventory.ini
  - Example: `./chasm verify -i custom/inventory.ini`

- `-v, --verbose`: Enable verbose output
  - Example: `./chasm deploy -v`

- `-k, --key`: SSH public key file
  - Required for preflight
  - Example: `./chasm preflight -k ~/.ssh/id_rsa.pub`

- `-h, --help`: Show help message
  - Example: `./chasm --help`

## Extending the Tool

### Adding New Commands

1. Create a new script in `commands/`:
   ```bash
   #!/bin/bash
   source "$(dirname "$0")/common.sh"
   
   your_command() {
       # Command implementation
   }
   ```

2. Update `chasm` to include your command:
   ```bash
   source "$SCRIPT_DIR/commands/your_command.sh"
   
   case "$COMMAND" in
       your-command)
           your_command "$@"
           ;;
   esac
   ```

### Common Functions

The `common.sh` script provides shared functionality:

- `prompt`: Interactive user input with defaults
- `check_requirements`: Validates required files
- `set_ssh_key`: Configures SSH access

## Best Practices

1. Always use the common functions for shared tasks
2. Implement proper error handling
3. Provide clear feedback to users
4. Document new commands and options
5. Test commands in both bare metal and cloud environments

## Troubleshooting

Common issues and solutions:

1. SSH Key Issues
   - Ensure the key file exists and is readable
   - Verify key format and permissions
   - Check target system SSH configuration

2. Inventory Problems
   - Validate inventory file syntax
   - Check group and host definitions
   - Verify variable assignments

3. Deployment Failures
   - Enable verbose output for details
   - Check system requirements
   - Verify network connectivity

## Contributing

1. Follow the existing code structure
2. Add appropriate error handling
3. Include usage examples
4. Update documentation
5. Test thoroughly

## Author

Rob Weiss <rob.weiss@red-alpha.com> 