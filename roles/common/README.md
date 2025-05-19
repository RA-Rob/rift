# Common Role

This role provides common system configuration and setup for all hosts in the Chasm deployment.

## Description

The common role handles basic system configuration that is required for all hosts, regardless of their role (controller or worker). It ensures consistent system state and security settings across the deployment.

## Tasks

### Main Tasks

1. **System Configuration**
   - Sets up system hostname
   - Configures timezone
   - Updates system packages
   - Installs common utilities

2. **Security Configuration**
   - Configures SSH settings
   - Sets up firewall rules
   - Configures SELinux
   - Sets up system limits

3. **User Management**
   - Creates system users
   - Sets up user permissions
   - Configures sudo access

## Variables

### Required Variables

- `install_user`: Username for installation
- `install_uid`: UID for installation user
- `install_gid`: GID for installation user

### Optional Variables

- `timezone`: System timezone (default: UTC)
- `common_packages`: List of packages to install
- `system_limits`: System resource limits

## Dependencies

- None

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: common
      vars:
        install_user: ansible
        install_uid: 1000
        install_gid: 1000
```

## License

[Your License Here] 