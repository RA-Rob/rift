User Guide
==========

This guide provides an overview of using Rift for infrastructure deployment and management.

Getting Started
---------------

Rift is an Ansible-based automation tool that simplifies infrastructure deployment. The main ``rift`` command provides a unified interface for all operations.

Basic Usage
~~~~~~~~~~~

.. code-block:: bash

   rift [global-options] <command> [command-options]

To see all available commands:

.. code-block:: bash

   rift help

To see version information:

.. code-block:: bash

   rift version

Common Deployment Workflow
--------------------------

1. Generate Inventory
~~~~~~~~~~~~~~~~~~~~~

Start by creating an inventory file interactively:

.. code-block:: bash

   rift generate

This command will prompt you for:

- Deployment type (baremetal or cloud)
- Controller node details
- Worker node configurations
- Network settings
- Authentication parameters

2. Verify Configuration
~~~~~~~~~~~~~~~~~~~~~~~

Validate your inventory and configuration:

.. code-block:: bash

   rift verify

This checks:

- Inventory file syntax and structure
- Required group definitions
- Variable assignments
- Deployment type compatibility

3. Preflight Checks
~~~~~~~~~~~~~~~~~~~

Prepare the target environment:

.. code-block:: bash

   rift preflight -k ~/.ssh/id_rsa.pub

This performs:

- SSH key deployment to all hosts
- System requirements verification
- Network connectivity checks
- User access validation

4. Deploy Infrastructure
~~~~~~~~~~~~~~~~~~~~~~~~

Execute the main deployment:

.. code-block:: bash

   rift deploy

For cloud deployments:

.. code-block:: bash

   rift deploy -t cloud

5. Verify Installation
~~~~~~~~~~~~~~~~~~~~~~

Run post-deployment tests:

.. code-block:: bash

   rift test

This validates:

- Service availability
- Configuration correctness
- Network connectivity
- Performance baselines

Command Categories
------------------

Core Commands
~~~~~~~~~~~~~

**generate**
    Interactive inventory generation

**verify**
    Configuration validation

**preflight**
    Environment preparation

**deploy**
    Infrastructure deployment

**test**
    Installation verification

File Management Commands
~~~~~~~~~~~~~~~~~~~~~~~~

**dashboard**
    Grafana dashboard management

**dye-add**
    Add dye signature files

**dye-remove**
    Remove dye signature files

**input-add**
    Add input files with atomic copying

Utility Commands
~~~~~~~~~~~~~~~~

**version**
    Show version information

**help**
    Display help information

Configuration Options
---------------------

Global Options
~~~~~~~~~~~~~~

Most commands support these global options:

``-t, --type``
    Deployment type: ``baremetal`` (default) or ``cloud``

``-i, --inventory``
    Custom inventory file path (default: ``inventory/inventory.ini``)

``-v, --verbose``
    Enable detailed output for debugging

``-k, --key``
    SSH public key file (required for preflight)

Environment Variables
~~~~~~~~~~~~~~~~~~~~~

Customize behavior with environment variables:

.. code-block:: bash

   # File management user
   export RIFT_USER=myuser

   # Input file directories
   export INPUT_SOURCE_DIR=/custom/source
   export INPUT_TARGET_DIR=/custom/target

   # File ownership and permissions
   export INPUT_OWNER_UID=1000
   export INPUT_OWNER_GID=1000
   export INPUT_PERMISSIONS=755

Deployment Types
----------------

Bare Metal Deployment
~~~~~~~~~~~~~~~~~~~~~

For physical servers or VMs with direct access:

.. code-block:: bash

   rift generate  # Select 'baremetal' when prompted
   rift verify
   rift preflight -k ~/.ssh/id_rsa.pub
   rift deploy

Cloud Deployment
~~~~~~~~~~~~~~~~

For cloud platforms with specific networking requirements:

.. code-block:: bash

   rift generate  # Select 'cloud' when prompted
   rift verify -t cloud
   rift preflight -k ~/.ssh/id_rsa.pub -t cloud
   rift deploy -t cloud

File Management
---------------

Dashboard Management
~~~~~~~~~~~~~~~~~~~~

Manage Grafana dashboards on the controller node:

.. code-block:: bash

   # Add a dashboard
   rift dashboard add -d monitoring-dashboard.json

   # List existing dashboards
   rift dashboard list

   # Validate before importing
   rift dashboard validate -d new-dashboard.json

   # Custom Grafana settings
   rift dashboard add -d dashboard.json -u http://grafana.example.com:3000 --user admin --password secret

Dye File Processing
~~~~~~~~~~~~~~~~~~~

Manage dye signature files:

.. code-block:: bash

   # Add dye files from source directory
   rift dye-add --verbose

   # List current dye files
   rift dye-remove --list

   # Remove specific dye file
   rift dye-remove malware.dye

   # Remove all dye files (with confirmation)
   rift dye-remove --all

Input File Processing
~~~~~~~~~~~~~~~~~~~~~

Handle input files with atomic operations:

.. code-block:: bash

   # Add input files atomically
   rift input-add --verbose

This command:

- Processes all files in the source directory
- Uses atomic copying to prevent race conditions
- Preserves source files
- Sets proper ownership and permissions

Advanced Usage
--------------

Custom Inventory Files
~~~~~~~~~~~~~~~~~~~~~~

Use custom inventory locations:

.. code-block:: bash

   rift verify -i /path/to/custom/inventory.ini
   rift deploy -i /path/to/custom/inventory.ini

Verbose Debugging
~~~~~~~~~~~~~~~~~

Enable detailed output for troubleshooting:

.. code-block:: bash

   rift deploy -v
   rift test -v
   rift dashboard add -d dashboard.json -v

Multiple Environments
~~~~~~~~~~~~~~~~~~~~~

Manage different environments with separate inventories:

.. code-block:: bash

   # Development environment
   rift deploy -i inventory/dev.ini -v

   # Staging environment
   rift deploy -i inventory/staging.ini

   # Production environment
   rift deploy -i inventory/prod.ini

Automation and Scripting
-------------------------

Batch Operations
~~~~~~~~~~~~~~~~

Automate common workflows:

.. code-block:: bash

   #!/bin/bash
   # deployment-script.sh

   echo "Starting deployment..."
   rift verify || exit 1
   rift preflight -k ~/.ssh/id_rsa.pub || exit 1
   rift deploy -v || exit 1
   rift test || exit 1

   echo "Adding monitoring dashboards..."
   for dashboard in dashboards/*.json; do
       rift dashboard add -d "$dashboard"
   done

   echo "Deployment complete!"

Cron Integration
~~~~~~~~~~~~~~~~

Automated file processing can be set up with cron jobs. See the respective file management documentation for details:

- Dashboard Management: :doc:`dashboard-management`
- Dye File Management: :doc:`dye-file-management`
- Input File Management: :doc:`input-file-management`

Troubleshooting
---------------

Common Issues
~~~~~~~~~~~~~

**"Command not found" errors**

Ensure the rift script is executable:

.. code-block:: bash

   chmod +x tools/rift

**Permission denied during file operations**

File management commands require sudo access. Configure passwordless sudo:

.. code-block:: bash

   # Add to /etc/sudoers
   myuser ALL=(ALL) NOPASSWD: ALL

**SSH connection failures**

Ensure SSH keys are properly deployed:

.. code-block:: bash

   rift preflight -k ~/.ssh/id_rsa.pub -v

**Inventory validation errors**

Check your inventory file syntax:

.. code-block:: bash

   rift verify -v

**Grafana dashboard import failures**

Verify Grafana connectivity:

.. code-block:: bash

   rift dashboard list

Debug Mode
~~~~~~~~~~

Use verbose mode for detailed debugging:

.. code-block:: bash

   rift <command> -v

Log Files
~~~~~~~~~

Check log files for detailed error information:

- Dashboard operations: ``/var/log/rift/dashboard-<uid>.log``
- Dye processing: ``/var/log/dye-processing.log``
- Input processing: ``/var/log/input-processing.log``

Getting Help
~~~~~~~~~~~~

For command-specific help:

.. code-block:: bash

   rift help
   rift dashboard --help
   rift dye-remove --help

Best Practices
--------------

1. **Always verify before deploying**

   .. code-block:: bash

      rift verify

2. **Use version control for inventory files**

   Keep your inventory and configuration files in version control.

3. **Test in staging first**

   Deploy to a staging environment before production:

   .. code-block:: bash

      rift deploy -i inventory/staging.ini

4. **Monitor deployments**

   Use verbose mode and check logs:

   .. code-block:: bash

      rift deploy -v

5. **Validate dashboards before importing**

   .. code-block:: bash

      rift dashboard validate -d new-dashboard.json

6. **Use atomic file operations**

   The ``input-add`` command uses atomic operations to prevent race conditions.

7. **Regular testing**

   Run verification tests after deployments:

   .. code-block:: bash

      rift test

Security Considerations
-----------------------

1. **SSH Key Management**

   - Use strong SSH keys
   - Rotate keys regularly
   - Limit key access to necessary users

2. **Sudo Access**

   - Configure passwordless sudo only for required commands
   - Use specific command restrictions when possible

3. **File Permissions**

   - Ensure proper ownership and permissions on sensitive files
   - Use the built-in permission management in file commands

4. **Network Security**

   - Ensure proper firewall rules
   - Use encrypted connections
   - Validate network connectivity during preflight

Next Steps
----------

- See :doc:`command-reference` for detailed command documentation
- Check :doc:`dashboard-management` for Grafana integration
- Review :doc:`vm-management` for VM-specific operations
- Read :doc:`troubleshooting` for common issues and solutions