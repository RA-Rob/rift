Input File Management
=====================

This document describes the input file management system integrated into the Rift toolkit.

Overview
--------

The input file management system provides tools for handling input files in the system. Input files are processed from a source directory and deployed to a target directory with specific ownership and permissions using atomic copy operations to prevent early access by other system processes. After successful processing, source files are moved to a processed directory to prevent reprocessing in subsequent runs.

.. warning::
   **File Expiration Policy**: Processed input files are automatically deleted after 24 hours (configurable) to save disk space. This expiration process runs with the input cron job and **permanently deletes files** from the processed directory that cannot be recovered. If you need longer retention, configure ``FILE_EXPIRATION_HOURS`` to a higher value or implement your own backup strategy.

Directory Structure
-------------------

Source Directory
~~~~~~~~~~~~~~~~

- **Path**: ``/var/abyss/input`` (configurable via ``INPUT_SOURCE_DIR`` environment variable)
- **Purpose**: Staging area for new input files

Target Directory
~~~~~~~~~~~~~~~~

- **Path**: ``/data/io-service/input-undersluice-default`` (configurable via ``INPUT_TARGET_DIR`` environment variable)
- **Purpose**: Destination directory where input files are atomically copied

Processed Directory
~~~~~~~~~~~~~~~~~~~

- **Path**: ``/var/abyss/input/processed`` (configurable via ``INPUT_PROCESSED_DIR`` environment variable)
- **Purpose**: Archive directory where successfully processed files are moved to prevent reprocessing
- **Auto-creation**: Directory is automatically created with proper ownership and permissions if it doesn't exist

File Properties
~~~~~~~~~~~~~~~

- **Owner**: UID 500:500 (configurable via ``INPUT_OWNER_UID`` and ``INPUT_OWNER_GID`` environment variables)
- **Permissions**: 644 (configurable via ``INPUT_PERMISSIONS`` environment variable)
- **File Types**: All file types (not limited to specific extensions)

User Configuration
~~~~~~~~~~~~~~~~~~

- **Default User**: ``rift`` (configurable via ``RIFT_USER`` environment variable)
- **User Requirements**: Must have passwordless sudo access

Prerequisites
-------------

Sudo Access
~~~~~~~~~~~

All input file management operations require sudo access because the target directory operations need elevated privileges. The user executing these scripts must:

- Be a sudoer
- Have passwordless sudo configured for automated operations
- Have sudo access to the target directories

Passwordless Sudo Setup
~~~~~~~~~~~~~~~~~~~~~~~~

For automated operations, configure passwordless sudo for the RIFT_USER (default: ``rift``) by adding to ``/etc/sudoers``:

.. code-block:: text

   rift ALL=(ALL) NOPASSWD: /bin/cp, /bin/mv, /bin/rm, /bin/chown, /bin/chmod, /usr/bin/find, /usr/bin/stat, /usr/bin/test

Or for broader access:

.. code-block:: text

   rift ALL=(ALL) NOPASSWD: ALL

To use a different user, set the ``RIFT_USER`` environment variable:

.. code-block:: bash

   export RIFT_USER=myuser

Manual Commands
---------------

Adding Input Files
~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Add all input files from source directory (requires sudo)
   ./rift input-add

   # Add with verbose output
   ./rift input-add --verbose

   # Show help
   ./rift input-add --help

The ``input-add`` command:

- Uses sudo for all file operations
- Finds all files in the source directory (any file type)
- Copies files atomically to prevent early access by other processes
- Sets proper ownership and permissions on copied files
- Moves successfully processed files to the processed directory
- Uses temporary files with atomic move operations for safety

Atomic Copy Process
-------------------

The input file management system ensures atomicity by:

1. **Temporary File Creation**: Files are first copied to a temporary location with a unique name (``.filename.tmp.$$``)
2. **Permission Setting**: Ownership and permissions are set on the temporary file
3. **Atomic Move**: The temporary file is moved to the final location using ``mv``, which is atomic on most filesystems
4. **Source File Archival**: After successful copy, the original source file is moved to the processed directory
5. **Cleanup**: If any step fails, temporary files are cleaned up automatically

This process prevents other system processes from accessing incomplete or improperly configured files, and ensures files are not processed multiple times.

Configuration
-------------

All configuration can be customized using environment variables:

.. code-block:: bash

   # Source directory for input files
   export INPUT_SOURCE_DIR="/custom/source/path"

   # Target directory for input files  
   export INPUT_TARGET_DIR="/custom/target/path"

   # Processed directory for archived files (defaults to ${INPUT_SOURCE_DIR}/processed)
   export INPUT_PROCESSED_DIR="/custom/processed/path"

   # File ownership (UID:GID)
   export INPUT_OWNER_UID=1000
   export INPUT_OWNER_GID=1000

   # File permissions (octal)
   export INPUT_PERMISSIONS=755

   # File expiration (hours) - for processed files cleanup
   export FILE_EXPIRATION_HOURS=48  # Keep processed files for 48 hours instead of default 24

   # User running the script
   export RIFT_USER=myuser

Differences from Dye File Management
------------------------------------

The input file management system differs from dye file management in several key ways:

1. **Source Archival**: Input files are moved to a processed directory after copying (dye files are deleted)
2. **Single Target**: Input files are copied to one target directory, not multiple
3. **File Types**: Accepts all file types, not just ``.dye`` files
4. **Atomic Operations**: Uses temporary files and atomic moves for enhanced safety
5. **Default User**: Uses ``rift`` user by default instead of ``ec2-user``
6. **Reprocessing Prevention**: Processed directory prevents files from being processed multiple times

Automated Processing (Cron)
----------------------------

For automated input file processing, use the ``input-cron.sh`` script:

.. note::
   For comprehensive cron automation documentation including installation, configuration, and troubleshooting, see :doc:`cron-automation`.

Cron Script Features
~~~~~~~~~~~~~~~~~~~~

- **Lock-based execution**: Prevents multiple instances from running simultaneously
- **Log rotation**: Automatically rotates log files when they exceed 10MB
- **System health checks**: Validates sudo access and disk space
- **File expiration cleanup**: Automatically deletes processed files older than configured threshold (default 24 hours)
- **Comprehensive logging**: Detailed logging with timestamps to ``/var/log/input-processing.log``
- **Signal handling**: Graceful cleanup on script termination

Cron Setup
~~~~~~~~~~

1. **Copy the cron script to a system location**:

   .. code-block:: bash

      sudo cp tools/input-cron.sh /usr/local/bin/
      sudo chmod +x /usr/local/bin/input-cron.sh

2. **Set up log file with proper permissions**:

   .. code-block:: bash

      sudo touch /var/log/input-processing.log
      sudo chown ec2-user:ec2-user /var/log/input-processing.log

3. **Add cron job for the ec2-user**:

   .. code-block:: bash

      # Switch to ec2-user and edit crontab
      sudo -u ec2-user crontab -e
      
      # Add this line to run every 5 minutes
      */5 * * * * /usr/local/bin/input-cron.sh >> /var/log/input-processing.log 2>&1

Alternative Cron Frequencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Every minute
   * * * * * /usr/local/bin/input-cron.sh >> /var/log/input-processing.log 2>&1

   # Every 10 minutes  
   */10 * * * * /usr/local/bin/input-cron.sh >> /var/log/input-processing.log 2>&1

   # Every hour
   0 * * * * /usr/local/bin/input-cron.sh >> /var/log/input-processing.log 2>&1

Monitoring Cron Jobs
~~~~~~~~~~~~~~~~~~~~~

1. **Check if cron job is running**:

   .. code-block:: bash

      sudo -u ec2-user crontab -l

2. **Monitor log file**:

   .. code-block:: bash

      tail -f /var/log/input-processing.log

3. **Check for running instances**:

   .. code-block:: bash

      ps aux | grep input-cron
      cat ${TMPDIR:-/tmp}/rift-cron/input-cron.pid 2>/dev/null

4. **View recent processing activity**:

   .. code-block:: bash

      grep "$(date '+%Y-%m-%d')" /var/log/input-processing.log

Error Handling
--------------

The system provides comprehensive error handling:

- Directory validation before processing
- Sudo access verification
- Individual file operation error tracking
- Cleanup of temporary files on failure
- Detailed logging with timestamps
- Summary reporting of processed files and errors
- Lock file management to prevent concurrent execution
- Automatic log rotation to prevent disk space issues
