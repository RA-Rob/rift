# Rift Command-Line Tool

The Rift command-line tool provides a unified interface for managing Ansible deployments. It simplifies common tasks like inventory management, preflight checks, and deployment execution.

## Overview

The tool is organized into a modular structure:
```
tools/
├── rift               # Main deployment script
├── dye-cron.sh        # Automated dye file processing for cron
├── input-cron.sh      # Automated input file processing for cron
├── output-cron.sh     # Automated output file processing for cron
└── commands/          # Command-specific scripts
    ├── common.sh      # Shared utility functions
    ├── generate.sh    # Inventory generation
    ├── verify.sh      # Inventory verification
    ├── preflight.sh   # Preflight checks
    ├── deploy.sh      # Deployment execution
    ├── dashboard.sh   # Dashboard management
    ├── dye-add.sh     # Dye file addition
    ├── dye-remove.sh  # Dye file removal
    ├── input-add.sh   # Input file addition
    └── output-add.sh  # Output file addition
```

## Commands

### generate
Interactive inventory file generation for both bare metal and cloud deployments.

```bash
./rift generate
```

Features:
- Prompts for deployment type (baremetal/cloud)
- Interactive host configuration
- Automatic group and variable setup
- Support for multiple worker nodes

### verify
Validates inventory structure and deployment type.

```bash
./rift verify
```

Checks:
- Inventory file existence and format
- Deployment type compatibility
- Required group structure
- Variable definitions

### preflight
Performs system checks and prepares the installation environment.

```bash
./rift preflight -k ~/.ssh/id_rsa.pub
```

Tasks:
- SSH key deployment
- System requirements verification
- User access validation
- Network connectivity checks

### deploy
Executes the main deployment playbook.

```bash
./rift deploy
```

Process:
- Inventory validation
- Environment-specific configuration
- Playbook execution
- Deployment verification

### dye-add
Adds dye files from source directory to target directories.

```bash
./rift dye-add
```

Features:
- Processes all .dye files from `/var/abyss/dye`
- Copies to multiple target directories
- Sets proper ownership and permissions
- Removes source files after successful deployment

### dye-remove
Removes dye files from target directories.

```bash
./rift dye-remove --list
./rift dye-remove filename.dye
./rift dye-remove --all
```

Features:
- Lists existing dye files
- Removes specific files by name
- Bulk removal with confirmation
- Safety checks and validation

### input-add
Adds input files from source directory to target directory with atomic copying.

```bash
./rift input-add
```

Features:
- Processes all files from `/var/abyss/input`
- Atomic copying prevents early access
- Preserves source files (no deletion)
- Sets proper ownership and permissions

### output-add
Adds output files from source directory to target directory with atomic copying.

```bash
./rift output-add
```

Features:
- Processes all files from `/opt/exports/abyss-default/outputs/dataExporterinspection`
- Atomic copying prevents early access
- Moves source files to processed directory after successful copying
- Sets proper ownership and permissions

## Automated Processing

### Cron Scripts

Three cron scripts are provided for automated file processing:

#### dye-cron.sh
Automated dye file processing every 5 minutes:
```bash
*/5 * * * * /usr/local/bin/dye-cron.sh >> /var/log/dye-processing.log 2>&1
```

#### input-cron.sh
Automated input file processing every 5 minutes:
```bash
*/5 * * * * /usr/local/bin/input-cron.sh >> /var/log/input-processing.log 2>&1
```

#### output-cron.sh
Automated output file processing every 5 minutes:
```bash
*/5 * * * * /usr/local/bin/output-cron.sh >> /var/log/output-processing.log 2>&1
```

All scripts feature:
- Lock-based execution to prevent concurrent runs
- Comprehensive logging with automatic rotation
- System health checks
- Graceful error handling

## Command Options

All commands support the following options:

- `-t, --type`: Deployment type (baremetal|cloud)
  - Default: baremetal
  - Example: `./rift deploy -t cloud`

- `-i, --inventory`: Custom inventory file
  - Default: inventory/inventory.ini
  - Example: `./rift verify -i custom/inventory.ini`

- `-v, --verbose`: Enable verbose output
  - Example: `./rift deploy -v`

- `-k, --key`: SSH public key file
  - Required for preflight
  - Example: `./rift preflight -k ~/.ssh/id_rsa.pub`

- `-h, --help`: Show help message
  - Example: `./rift --help`

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

2. Update `rift` to include your command:
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