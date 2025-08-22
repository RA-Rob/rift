Command Reference
=================

This document provides a comprehensive reference for all Rift commands and their options.

Overview
--------

Rift provides a unified command-line interface for managing Ansible deployments. The main ``rift`` script serves as the entry point for all operations.

.. code-block:: bash

   rift [global-options] <command> [command-options]

Global Options
--------------

The following options are available for most commands:

``-t, --type DEPLOYMENT_TYPE``
    Deployment type: ``baremetal`` or ``cloud`` (default: ``baremetal``)

``-i, --inventory INVENTORY_FILE``
    Path to inventory file (default: ``inventory/inventory.ini``)

``-v, --verbose``
    Enable verbose output for detailed logging

``-k, --key SSH_KEY_FILE``
    SSH public key file for installation user (required for ``preflight``)

``-h, --help``
    Show help message and exit

Core Commands
-------------

generate
~~~~~~~~

Generate an inventory file interactively for both bare metal and cloud deployments.

.. code-block:: bash

   rift generate

**Features:**

- Interactive prompts for deployment type (baremetal/cloud)
- Host configuration wizard
- Automatic group and variable setup
- Support for multiple worker nodes
- Validation of input parameters

**Example:**

.. code-block:: bash

   rift generate

verify
~~~~~~

Validate inventory structure and deployment type compatibility.

.. code-block:: bash

   rift verify [options]

**Checks:**

- Inventory file existence and format
- Deployment type compatibility
- Required group structure
- Variable definitions
- Host accessibility

**Example:**

.. code-block:: bash

   rift verify -i custom/inventory.ini

preflight
~~~~~~~~~

Perform system checks and prepare the installation environment.

.. code-block:: bash

   rift preflight -k <ssh-key-file> [options]

**Required Options:**

``-k, --key SSH_KEY_FILE``
    SSH public key file for installation user

**Tasks:**

- SSH key deployment to target hosts
- System requirements verification
- User access validation
- Network connectivity checks
- Ansible prerequisites validation

**Example:**

.. code-block:: bash

   rift preflight -k ~/.ssh/id_rsa.pub -v

deploy
~~~~~~

Execute the main deployment playbook to install Rift on target hosts.

.. code-block:: bash

   rift deploy [options]

**Process:**

- Inventory validation
- Environment-specific configuration
- Playbook execution
- Deployment verification
- Service startup validation

**Examples:**

.. code-block:: bash

   # Deploy with default settings
   rift deploy

   # Deploy to cloud environment with verbose output
   rift deploy -t cloud -v

test
~~~~

Run installation verification tests to validate the deployment.

.. code-block:: bash

   rift test [options]

**Tests:**

- Service availability checks
- Configuration validation
- Network connectivity tests
- Performance baseline tests

**Example:**

.. code-block:: bash

   rift test -v

File Management Commands
------------------------

dashboard
~~~~~~~~~

Manage Grafana dashboards on the controller node.

.. code-block:: bash

   rift dashboard <subcommand> [options]

**Subcommands:**

``add``
    Add a dashboard from JSON file

    .. code-block:: bash

       rift dashboard add -d <dashboard-file.json> [options]

    **Options:**
    
    - ``-d, --dashboard``: Path to dashboard JSON file (required)
    - ``-u, --url``: Grafana URL (default: http://localhost:3000)
    - ``--user``: Grafana username (default: admin)
    - ``--password``: Grafana password (default: admin)

``list``
    List all existing dashboards

    .. code-block:: bash

       rift dashboard list [options]

``validate``
    Validate dashboard JSON file

    .. code-block:: bash

       rift dashboard validate -d <dashboard-file.json>

**Examples:**

.. code-block:: bash

   # Add dashboard with default settings
   rift dashboard add -d monitoring.json

   # List all dashboards
   rift dashboard list

   # Validate dashboard before import
   rift dashboard validate -d new-dashboard.json

dye-add
~~~~~~~

Add dye files from source directory to target directories.

.. code-block:: bash

   rift dye-add [options]

**Options:**

``--verbose``
    Enable verbose output

**Process:**

- Scans ``/var/abyss/dye`` for ``.dye`` files
- Copies to multiple target directories
- Sets proper ownership (UID 500:500) and permissions (644)
- Removes source files after successful deployment
- Requires sudo access

**Example:**

.. code-block:: bash

   rift dye-add --verbose

dye-remove
~~~~~~~~~~

Remove dye files from target directories.

.. code-block:: bash

   rift dye-remove [options] [filename]

**Options:**

``--list``
    List all dye files in target directories

``--all``
    Remove all dye files with confirmation prompt

**Examples:**

.. code-block:: bash

   # List all dye files
   rift dye-remove --list

   # Remove specific file
   rift dye-remove malware.dye

   # Remove all files with confirmation
   rift dye-remove --all

input-add
~~~~~~~~~

Add input files from source to target directory using atomic copy operations.

.. code-block:: bash

   rift input-add [options]

**Options:**

``--verbose``
    Enable verbose output

**Process:**

- Scans ``/var/abyss/input`` for all file types
- Uses atomic copying to prevent early access
- Sets proper ownership and permissions
- Preserves source files (no deletion)
- Requires sudo access

**Example:**

.. code-block:: bash

   rift input-add --verbose

Utility Commands
----------------

version
~~~~~~~

Show version information for Rift and its dependencies.

.. code-block:: bash

   rift version

**Output includes:**

- Rift version and release
- Ansible version
- Python version

**Example:**

.. code-block:: bash

   rift version

help
~~~~

Show help message with all available commands and options.

.. code-block:: bash

   rift help

VM Management Commands (Standalone)
------------------------------------

The following VM management commands are available as standalone scripts but are not yet integrated into the main ``rift`` command:

vm-create
~~~~~~~~~

Create VMs on specified platforms.

.. code-block:: bash

   ./tools/commands/vm-create.sh [options] <platform>

**Platforms:**

- ``kvm``: Create VMs on KVM host
- ``aws``: Create VMs on AWS
- ``azure``: Create VMs on Azure

**Options:**

- ``-n, --count``: Number of VMs to create (default: 1)
- ``-s, --size``: VM size/type (default: standard)
- ``-r, --region``: Region for cloud platforms (default: us-east-1)

vm-cleanup
~~~~~~~~~~

Clean up VMs and associated resources.

.. code-block:: bash

   ./tools/commands/vm-cleanup.sh [options] <platform>

**Options:**

- ``-f, --force``: Force cleanup without confirmation
- ``-a, --all``: Clean up all resources including networks and storage

vm-test
~~~~~~~

Test VM connectivity and configuration.

.. code-block:: bash

   ./tools/commands/vm-test.sh [options]

**Options:**

- ``-i, --inventory``: Inventory file for testing (default: inventory/inventory.ini)
- ``-t, --timeout``: Connection timeout in seconds (default: 30)

Environment Variables
---------------------

The following environment variables can be used to customize Rift behavior:

``RIFT_USER``
    Override the default user for file operations (default varies by command)

``INPUT_SOURCE_DIR``
    Source directory for input files (default: ``/var/abyss/input``)

``INPUT_TARGET_DIR``
    Target directory for input files (default: ``/data/io-service/input-undersluice-default``)

``INPUT_OWNER_UID`` / ``INPUT_OWNER_GID``
    File ownership for input files (default: 500:500)

``INPUT_PERMISSIONS``
    File permissions for input files (default: 644)

Exit Codes
----------

Rift commands use the following exit codes:

- ``0``: Success
- ``1``: General error
- ``2``: Invalid command or arguments
- ``3``: Missing requirements or dependencies
- ``4``: Permission denied or authentication failure
- ``5``: Network or connectivity error

Examples
--------

Common Workflow
~~~~~~~~~~~~~~~

.. code-block:: bash

   # 1. Generate inventory interactively
   rift generate

   # 2. Verify the generated inventory
   rift verify

   # 3. Run preflight checks
   rift preflight -k ~/.ssh/id_rsa.pub

   # 4. Deploy to target environment
   rift deploy -v

   # 5. Run verification tests
   rift test

   # 6. Add monitoring dashboards
   rift dashboard add -d monitoring.json

Cloud Deployment
~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Generate cloud-specific inventory
   rift generate

   # Deploy to cloud environment
   rift deploy -t cloud -v

   # Verify cloud deployment
   rift test -v

File Management
~~~~~~~~~~~~~~~

.. code-block:: bash

   # Process dye files
   rift dye-add --verbose

   # List current dye files
   rift dye-remove --list

   # Add input files atomically
   rift input-add --verbose

.. note::
   For automated file processing using cron jobs, see :doc:`cron-automation`.

Troubleshooting
---------------

Common Issues
~~~~~~~~~~~~~

**Command not found**
    Ensure the ``rift`` script is executable and in your PATH

**Permission denied**
    File management commands require sudo access - ensure passwordless sudo is configured

**Inventory validation failed**
    Run ``rift verify`` to identify inventory issues

**SSH connection failed**
    Verify SSH keys are properly deployed using ``rift preflight``

**Grafana dashboard import failed**
    Check Grafana connectivity and credentials using ``rift dashboard list``

Debug Mode
~~~~~~~~~~

Enable verbose output for detailed debugging:

.. code-block:: bash

   rift <command> -v

Log Files
~~~~~~~~~

Command operations create log files in various locations:

- Dashboard operations: ``/var/log/rift/dashboard-<uid>.log``
- Dye file processing: ``/var/log/dye-processing.log``
- Input file processing: ``/var/log/input-processing.log``
