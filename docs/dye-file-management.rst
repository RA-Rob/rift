Dye File Management
===================

This document describes the dye file management system integrated into the Rift toolkit.

Overview
--------

The dye file management system provides automated and manual tools for handling ``.dye`` files in the system. Dye files are processed from a source directory and deployed to multiple target directories with specific ownership and permissions.

Directory Structure
-------------------

Source Directory
~~~~~~~~~~~~~~~~

- **Path**: ``/var/abyss/dye``
- **Purpose**: Staging area for new dye files

Target Directories
~~~~~~~~~~~~~~~~~~

- **Directory 1**: ``/opt/exports/abyss-default/signatures-local/deep-core-main/``
- **Directory 2**: ``/opt/exports/abyss-default/signatures/deep-core-main/current/signatures/local/``

File Properties
~~~~~~~~~~~~~~~

- **Owner**: UID 500:500
- **Permissions**: 644
- **File Extension**: ``.dye``

User Configuration
~~~~~~~~~~~~~~~~~~

- **Default User**: ``ec2-user`` (configurable via ``RIFT_USER`` environment variable)
- **User Requirements**: Must have passwordless sudo access

Prerequisites
-------------

Sudo Access
~~~~~~~~~~~

All dye file management operations require sudo access because the target directories are owned by UID 500:500. The user executing these scripts must:

- Be a sudoer
- Have passwordless sudo configured for automated operations
- Have sudo access to the target directories

Passwordless Sudo Setup
~~~~~~~~~~~~~~~~~~~~~~~~

For automated cron operations, configure passwordless sudo for the RIFT_USER (default: ``ec2-user``) by adding to ``/etc/sudoers``:

.. code-block:: text

   ec2-user ALL=(ALL) NOPASSWD: /bin/cp, /bin/rm, /bin/chown, /bin/chmod, /usr/bin/find, /usr/bin/stat, /usr/bin/test

Or for broader access:

.. code-block:: text

   ec2-user ALL=(ALL) NOPASSWD: ALL

To use a different user, set the ``RIFT_USER`` environment variable:

.. code-block:: bash

   export RIFT_USER=myuser

Manual Commands
---------------

Adding Dye Files
~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Add all dye files from source directory (requires sudo)
   ./rift dye-add

   # Add with verbose output
   ./rift dye-add --verbose

   # Show help
   ./rift dye-add --help

The ``dye-add`` command:

- Uses sudo for all file operations
- Finds all ``.dye`` files in the source directory
- Copies them to both target directories
- Sets proper ownership (500:500) and permissions (644)
- Removes the source files after successful deployment

Removing Dye Files
~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # List all dye files in target directories (requires sudo)
   ./rift dye-remove --list

   # Remove a specific dye file (requires sudo)
   ./rift dye-remove malware.dye

   # Remove all dye files with confirmation (requires sudo)
   ./rift dye-remove --all

   # Show help
   ./rift dye-remove --help

The ``dye-remove`` command provides:

- Uses sudo for all file operations
- Listing of all dye files in target directories
- Removal of specific dye files by name
- Bulk removal of all dye files with safety confirmation

Automated Processing
--------------------

Cron Script
~~~~~~~~~~~

A standalone cron script is provided for automated processing:

**Location**: ``tools/dye-cron.sh``

.. note::
   For comprehensive cron automation documentation including installation, configuration, and troubleshooting, see :doc:`cron-automation`.

**Features**:

- Designed to run every 5 minutes
- Uses sudo for all file operations
- Prevents multiple concurrent executions using lock files
- Comprehensive logging with automatic log rotation
- System health checks
- Graceful error handling
- Requires passwordless sudo for automated operation

Cron Setup
~~~~~~~~~~

Add the following entry to the RIFT_USER's crontab (default: ec2-user):

.. code-block:: bash

   # Process dye files every 5 minutes (as ec2-user with passwordless sudo)
   */5 * * * * /usr/share/rift/dye-cron.sh >> /var/log/dye-processing.log 2>&1

Or for development/testing:

.. code-block:: bash

   # Process dye files every 5 minutes (development)
   */5 * * * * RIFT_USER=ec2-user /path/to/rift/tools/dye-cron.sh >> /var/log/dye-processing.log 2>&1

For a different user:

.. code-block:: bash

   # Process dye files every 5 minutes (as custom user)
   */5 * * * * RIFT_USER=myuser /path/to/rift/tools/dye-cron.sh >> /var/log/dye-processing.log 2>&1

Log Files
~~~~~~~~~

- **Main Log**: ``/var/log/dye-processing.log``
- **Log Rotation**: Automatic when file exceeds 10MB
- **Lock Files**: ``/var/run/dye-cron.lock`` and ``/var/run/dye-cron.pid``

Configuration
-------------

All directory paths and file properties are configurable via variables at the top of each script:

dye-add.sh and dye-cron.sh Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   DYE_SOURCE_DIR="/var/abyss/dye"
   DYE_TARGET_DIR1="/opt/exports/abyss-default/signatures-local/deep-core-main"
   DYE_TARGET_DIR2="/opt/exports/abyss-default/signatures/deep-core-main/current/signatures/local"
   DYE_OWNER_UID=500
   DYE_OWNER_GID=500
   DYE_PERMISSIONS=644
   RIFT_USER="${RIFT_USER:-ec2-user}"

dye-remove.sh Variables
~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   DYE_TARGET_DIR1="/opt/exports/abyss-default/signatures-local/deep-core-main"
   DYE_TARGET_DIR2="/opt/exports/abyss-default/signatures/deep-core-main/current/signatures/local"
   RIFT_USER="${RIFT_USER:-ec2-user}"

Environment Variables
~~~~~~~~~~~~~~~~~~~~~

- **RIFT_USER**: Override the default user (ec2-user) by setting this environment variable

Security Considerations
-----------------------

- All scripts require sudo access for file operations in target directories
- Target directories are owned by UID 500:500, requiring elevated privileges
- Passwordless sudo must be configured for automated cron operations
- Lock files prevent concurrent execution of the cron script
- All file operations include error checking and logging
- Consider limiting sudo access to specific commands if security is a concern

Troubleshooting
---------------

Common Issues
~~~~~~~~~~~~~

1. **Permission Denied**: Ensure sudo access is properly configured and user is in sudoers
2. **Sudo Password Prompts**: Configure passwordless sudo for automated operations
3. **Ownership Changes Fail**: Verify sudo permissions for chown/chmod commands
4. **Lock File Issues**: Remove stale lock files in ``/var/run/`` if script won't start
5. **Directory Not Found**: Verify all configured directory paths exist and are accessible via sudo
6. **Cron Job Fails**: Ensure passwordless sudo is configured and test manually first

Logging
~~~~~~~

Check the log file for detailed information:

.. code-block:: bash

   tail -f /var/log/dye-processing.log

Manual Testing
~~~~~~~~~~~~~~

Test the cron script manually (user must have passwordless sudo):

.. code-block:: bash

   /path/to/rift/tools/dye-cron.sh

Test sudo access for the RIFT_USER:

.. code-block:: bash

   # Test current user
   sudo -n true && echo "Passwordless sudo works" || echo "Passwordless sudo not configured"

   # Test with specific user
   RIFT_USER=ec2-user sudo -n true && echo "Passwordless sudo works for ec2-user" || echo "Passwordless sudo not configured for ec2-user"

Integration with Rift
----------------------

The dye file management commands are fully integrated into the main Rift script:

.. code-block:: bash

   # Show all available commands (includes dye-add and dye-remove)
   ./rift help

   # Use dye commands through main rift script (as default user ec2-user)
   ./rift dye-add
   ./rift dye-remove --list

   # Use dye commands with custom user
   RIFT_USER=myuser ./rift dye-add
   RIFT_USER=myuser ./rift dye-remove --list

File Workflow
-------------

1. **Staging**: Dye files are placed in ``/var/abyss/dye``
2. **Processing**: Cron job (every 5 minutes) or manual command processes files
3. **Deployment**: Files are copied to both target directories
4. **Cleanup**: Source files are removed after successful deployment
5. **Logging**: All operations are logged with timestamps

This system ensures reliable, automated processing of dye files with comprehensive logging and error handling.
