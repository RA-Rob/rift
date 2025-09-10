Cron Automation
===============

Rift provides automated file processing capabilities through dedicated cron scripts. These scripts enable hands-free processing of dye files, input files, and output files at regular intervals.

Overview
--------

Three cron scripts are available for automated file processing:

- **dye-cron.sh**: Automated processing of dye signature files
- **input-cron.sh**: Automated processing of input files with atomic operations
- **output-cron.sh**: Automated processing of output files with atomic operations

All scripts are designed to run safely in production environments with comprehensive logging, error handling, and concurrent execution prevention.

Features
--------

Common Features
~~~~~~~~~~~~~~~

All cron scripts provide:

- **Lock-based execution**: Prevents multiple instances from running simultaneously
- **Automatic log rotation**: Rotates log files when they exceed 10MB
- **Comprehensive logging**: Detailed timestamped logging with automatic file output
- **System health checks**: Validates directories and sudo access before processing
- **Signal handling**: Graceful cleanup on script termination
- **Error recovery**: Robust error handling with detailed error reporting
- **Configuration flexibility**: Environment variable-based configuration

Dye File Cron Script
--------------------

The ``dye-cron.sh`` script automatically processes ``.dye`` files from a source directory to multiple target directories.

Script Location
~~~~~~~~~~~~~~~

- **Development**: ``tools/dye-cron.sh``
- **Installed**: ``/usr/share/rift/dye-cron.sh``

Configuration
~~~~~~~~~~~~~

The script uses the following configuration variables:

.. code-block:: bash

   # Source and target directories
   DYE_SOURCE_DIR="/var/abyss/dye"
   DYE_TARGET_DIR1="/opt/exports/abyss-default/signatures-local/deep-core-main"
   DYE_TARGET_DIR2="/opt/exports/abyss-default/signatures/deep-core-main/current/signatures/local"
   
   # File ownership and permissions
   DYE_OWNER_UID=500
   DYE_OWNER_GID=500
   DYE_PERMISSIONS=644
   
   # User configuration
   RIFT_USER="${RIFT_USER:-ec2-user}"
   
   # Logging
   LOG_FILE="/var/log/dye-processing.log"
   MAX_LOG_SIZE=10485760  # 10MB

Processing Workflow
~~~~~~~~~~~~~~~~~~~

1. **Lock Acquisition**: Prevents concurrent execution
2. **Directory Validation**: Ensures all required directories exist
3. **Sudo Verification**: Confirms passwordless sudo access
4. **File Discovery**: Finds all ``.dye`` files in source directory
5. **File Processing**: Copies files to both target directories
6. **Permission Setting**: Sets proper ownership and permissions
7. **Source Cleanup**: Removes source files after successful deployment
8. **Logging**: Records all operations with timestamps

Installation and Setup
~~~~~~~~~~~~~~~~~~~~~~

**Step 1: Copy Script to System Location**

.. code-block:: bash

   sudo cp tools/dye-cron.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/dye-cron.sh

**Step 2: Configure Passwordless Sudo**

Add the following to ``/etc/sudoers`` for the ``ec2-user`` (or your ``RIFT_USER``):

.. code-block:: bash

   # For specific commands (recommended)
   ec2-user ALL=(ALL) NOPASSWD: /bin/cp, /bin/rm, /bin/chown, /bin/chmod, /usr/bin/find, /usr/bin/stat, /usr/bin/test
   
   # Or for broader access (less secure)
   ec2-user ALL=(ALL) NOPASSWD: ALL

**Step 3: Set Up Log File**

.. code-block:: bash

   sudo touch /var/log/dye-processing.log
   sudo chown ec2-user:ec2-user /var/log/dye-processing.log
   sudo chmod 644 /var/log/dye-processing.log

**Step 4: Install Cron Job**

Switch to the appropriate user and add the cron job:

.. code-block:: bash

   # Switch to the RIFT_USER (default: ec2-user)
   sudo -u ec2-user crontab -e
   
   # Add this line to run every 5 minutes
   */5 * * * * /usr/local/bin/dye-cron.sh >> /var/log/dye-processing.log 2>&1

**Alternative Cron Frequencies:**

.. code-block:: bash

   # Every minute (high frequency)
   * * * * * /usr/local/bin/dye-cron.sh >> /var/log/dye-processing.log 2>&1
   
   # Every 10 minutes (moderate frequency)
   */10 * * * * /usr/local/bin/dye-cron.sh >> /var/log/dye-processing.log 2>&1
   
   # Every hour (low frequency)
   0 * * * * /usr/local/bin/dye-cron.sh >> /var/log/dye-processing.log 2>&1

Input File Cron Script
----------------------

The ``input-cron.sh`` script automatically processes input files from a source directory to a target directory using atomic copy operations.

Script Location
~~~~~~~~~~~~~~~

- **Development**: ``tools/input-cron.sh``
- **Installed**: ``/usr/share/rift/input-cron.sh``

Configuration
~~~~~~~~~~~~~

The script uses the following configuration variables (all configurable via environment variables):

.. code-block:: bash

   # Source and target directories
   INPUT_SOURCE_DIR="${INPUT_SOURCE_DIR:-/var/abyss/input}"
   INPUT_TARGET_DIR="${INPUT_TARGET_DIR:-/data/io-service/input-undersluice-default}"
   INPUT_PROCESSED_DIR="${INPUT_PROCESSED_DIR:-${INPUT_SOURCE_DIR}/processed}"
   
   # File ownership and permissions
   INPUT_OWNER_UID="${INPUT_OWNER_UID:-500}"
   INPUT_OWNER_GID="${INPUT_OWNER_GID:-500}"
   INPUT_PERMISSIONS="${INPUT_PERMISSIONS:-644}"
   
   # User configuration
   RIFT_USER="${RIFT_USER:-rift}"
   
   # Logging
   LOG_FILE="/var/log/input-processing.log"
   MAX_LOG_SIZE=10485760  # 10MB

Processing Workflow
~~~~~~~~~~~~~~~~~~~

1. **Lock Acquisition**: Prevents concurrent execution
2. **Directory Validation**: Ensures source, target, and processed directories exist
3. **Processed Directory Creation**: Auto-creates processed directory if needed
4. **Sudo Verification**: Confirms passwordless sudo access
5. **File Discovery**: Finds all files in source directory (any file type)
6. **Atomic Processing**: Uses temporary files for atomic operations
7. **Permission Setting**: Sets proper ownership and permissions
8. **Source File Archival**: Moves original files to processed directory after successful copy
9. **Logging**: Records all operations with timestamps

Key Differences from Dye Processing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Single Target**: Copies to one target directory instead of two
- **File Types**: Processes all file types, not just ``.dye`` files
- **Source Archival**: Moves source files to processed directory (dye files are deleted)
- **Reprocessing Prevention**: Processed directory prevents duplicate processing
- **Atomic Operations**: Uses temporary files and atomic moves for safety
- **Default User**: Uses ``rift`` user by default instead of ``ec2-user``

Installation and Setup
~~~~~~~~~~~~~~~~~~~~~~

**Step 1: Copy Script to System Location**

.. code-block:: bash

   sudo cp tools/input-cron.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/input-cron.sh

**Step 2: Configure Passwordless Sudo**

Add the following to ``/etc/sudoers`` for the ``ec2-user`` (or your ``RIFT_USER``):

.. code-block:: bash

   # For specific commands (recommended)
   ec2-user ALL=(ALL) NOPASSWD: /bin/cp, /bin/mv, /bin/rm, /bin/chown, /bin/chmod, /usr/bin/find, /usr/bin/stat, /usr/bin/test
   
   # Or for broader access (less secure)
   ec2-user ALL=(ALL) NOPASSWD: ALL

**Step 3: Set Up Log File**

.. code-block:: bash

   sudo touch /var/log/input-processing.log
   sudo chown ec2-user:ec2-user /var/log/input-processing.log
   sudo chmod 644 /var/log/input-processing.log

**Step 4: Install Cron Job**

Switch to the ec2-user and add the cron job:

.. code-block:: bash

   # Switch to the ec2-user
   sudo -u ec2-user crontab -e
   
   # Add this line to run every 5 minutes
   */5 * * * * /usr/local/bin/input-cron.sh >> /var/log/input-processing.log 2>&1

Output File Cron Script
------------------------

The ``output-cron.sh`` script automatically processes output files from a source directory to a target directory using atomic copy operations.

Script Location
~~~~~~~~~~~~~~~

- **Development**: ``tools/output-cron.sh``
- **Installed**: ``/usr/share/rift/output-cron.sh``

Configuration
~~~~~~~~~~~~~

The script uses the following configuration variables (all configurable via environment variables):

.. code-block:: bash

   # Source and target directories
   OUTPUT_SOURCE_DIR="${OUTPUT_SOURCE_DIR:-/opt/exports/abyss-default/outputs/dataExporterinspection}"
   OUTPUT_TARGET_DIR="${OUTPUT_TARGET_DIR:-/var/abyss/output}"
   OUTPUT_PROCESSED_DIR="${OUTPUT_PROCESSED_DIR:-${OUTPUT_SOURCE_DIR}/processed}"
   
   # File ownership and permissions
   OUTPUT_OWNER_UID="${OUTPUT_OWNER_UID:-500}"
   OUTPUT_OWNER_GID="${OUTPUT_OWNER_GID:-500}"
   OUTPUT_PERMISSIONS="${OUTPUT_PERMISSIONS:-644}"
   
   # User configuration
   RIFT_USER="${RIFT_USER:-rift}"
   
   # File expiration configuration (IMPORTANT)
   FILE_EXPIRATION_HOURS="${FILE_EXPIRATION_HOURS:-24}"
   
   # Logging
   LOG_FILE="/var/log/output-processing.log"
   MAX_LOG_SIZE=10485760  # 10MB

.. warning::
   **File Expiration Policy**: The output cron script automatically deletes files older than 24 hours (configurable via ``FILE_EXPIRATION_HOURS``) from:
   
   - ``/var/abyss/output`` (target directory)
   - ``/var/abyss/input/processed`` (processed input files)
   
   This is done to save disk space. Files are **permanently deleted** and cannot be recovered. If you need to retain files longer than 24 hours, set ``FILE_EXPIRATION_HOURS`` to a higher value or back up important files before they expire.

Processing Workflow
~~~~~~~~~~~~~~~~~~~

1. **Lock Acquisition**: Prevents concurrent execution
2. **Directory Validation**: Ensures source, target, and processed directories exist
3. **Processed Directory Creation**: Auto-creates processed directory if needed
4. **Sudo Verification**: Confirms passwordless sudo access
5. **File Discovery**: Finds all files in source directory (any file type)
6. **Atomic Processing**: Uses temporary files for atomic operations
7. **Permission Setting**: Sets proper ownership and permissions
8. **Source File Archival**: Moves original files to processed directory after successful copy
9. **File Expiration Cleanup**: Deletes files older than configured threshold (default 24 hours) from target and processed directories
10. **Logging**: Records all operations with timestamps

Key Features
~~~~~~~~~~~~

- **Single Target**: Copies to one target directory
- **File Types**: Processes all file types, not just specific extensions
- **Source Archival**: Moves source files to processed directory to prevent reprocessing
- **Atomic Operations**: Uses temporary files and atomic moves for safety
- **Default User**: Uses ``rift`` user by default
- **System Output**: Handles system-generated output files for downstream consumption

Installation and Setup
~~~~~~~~~~~~~~~~~~~~~~

**Step 1: Copy Script to System Location**

.. code-block:: bash

   sudo cp tools/output-cron.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/output-cron.sh

**Step 2: Configure Passwordless Sudo**

Add the following to ``/etc/sudoers`` for the ``rift`` user (or your ``RIFT_USER``):

.. code-block:: bash

   # For specific commands (recommended)
   rift ALL=(ALL) NOPASSWD: /bin/cp, /bin/mv, /bin/rm, /bin/chown, /bin/chmod, /usr/bin/find, /usr/bin/stat, /usr/bin/test
   
   # Or for broader access (less secure)
   rift ALL=(ALL) NOPASSWD: ALL

**Step 3: Set Up Log File**

.. code-block:: bash

   sudo touch /var/log/output-processing.log
   sudo chown rift:rift /var/log/output-processing.log
   sudo chmod 644 /var/log/output-processing.log

**Step 4: Install Cron Job**

Switch to the rift user and add the cron job:

.. code-block:: bash

   # Switch to the rift user
   sudo -u rift crontab -e
   
   # Add this line to run every 5 minutes
   */5 * * * * /usr/local/bin/output-cron.sh >> /var/log/output-processing.log 2>&1

Custom Configuration
--------------------

Environment Variable Override
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All scripts support environment variable customization:

**Dye Cron Script:**

.. code-block:: bash

   # Custom user
   export RIFT_USER=myuser
   
   # Then install cron job as that user
   sudo -u myuser crontab -e

**Input Cron Script:**

.. code-block:: bash

   # Custom directories
   export INPUT_SOURCE_DIR=/custom/source
   export INPUT_TARGET_DIR=/custom/target
   
   # Custom ownership
   export INPUT_OWNER_UID=1000
   export INPUT_OWNER_GID=1000
   
   # Custom permissions
   export INPUT_PERMISSIONS=755
   
   # Custom user
   export RIFT_USER=myuser

**Output Cron Script:**

.. code-block:: bash

   # Custom directories
   export OUTPUT_SOURCE_DIR=/custom/source
   export OUTPUT_TARGET_DIR=/custom/target
   
   # Custom ownership
   export OUTPUT_OWNER_UID=1000
   export OUTPUT_OWNER_GID=1000
   
   # Custom permissions
   export OUTPUT_PERMISSIONS=755
   
   # Custom file expiration (hours)
   export FILE_EXPIRATION_HOURS=48  # Keep files for 48 hours instead of default 24
   
   # Custom user
   export RIFT_USER=myuser

To use custom environment variables in cron, add them to the crontab:

.. code-block:: bash

   # Edit crontab
   sudo -u ec2-user crontab -e
   
   # Add environment variables at the top
   INPUT_SOURCE_DIR=/custom/source
   INPUT_TARGET_DIR=/custom/target
   FILE_EXPIRATION_HOURS=48
   RIFT_USER=myuser
   
   # Then add the cron jobs
   */5 * * * * /usr/local/bin/input-cron.sh >> /var/log/input-processing.log 2>&1
   */5 * * * * /usr/local/bin/output-cron.sh >> /var/log/output-processing.log 2>&1

Monitoring and Management
-------------------------

Checking Cron Job Status
~~~~~~~~~~~~~~~~~~~~~~~~~

**View Current Cron Jobs:**

.. code-block:: bash

   # For dye processing (ec2-user)
   sudo -u ec2-user crontab -l
   
   # For input processing (ec2-user)
   sudo -u ec2-user crontab -l

**Check Running Processes:**

.. code-block:: bash

   # Check for running cron scripts
   ps aux | grep -E "(dye-cron|input-cron|output-cron)"
   
   # Check PID files
   cat ${TMPDIR:-/tmp}/rift-cron/dye-cron.pid 2>/dev/null
   cat ${TMPDIR:-/tmp}/rift-cron/input-cron.pid 2>/dev/null
   cat ${TMPDIR:-/tmp}/rift-cron/output-cron.pid 2>/dev/null

**Check Lock Files:**

.. code-block:: bash

   # Check for active locks
   ls -la ${TMPDIR:-/tmp}/rift-cron/*-cron.lock 2>/dev/null

Log Monitoring
~~~~~~~~~~~~~~

**Monitor Real-time Processing:**

.. code-block:: bash

   # Dye file processing
   tail -f /var/log/dye-processing.log
   
   # Input file processing
   tail -f /var/log/input-processing.log

**View Recent Activity:**

.. code-block:: bash

   # Today's dye processing activity
   grep "$(date '+%Y-%m-%d')" /var/log/dye-processing.log
   
   # Today's input processing activity
   grep "$(date '+%Y-%m-%d')" /var/log/input-processing.log

**Check Log File Sizes:**

.. code-block:: bash

   ls -lh /var/log/*-processing.log*

Manual Testing
~~~~~~~~~~~~~~

Test the cron scripts manually before installing them:

.. code-block:: bash

   # Test dye cron script
   /usr/local/bin/dye-cron.sh
   
   # Test input cron script
   /usr/local/bin/input-cron.sh
   
   # Test with custom environment
   RIFT_USER=testuser /usr/local/bin/input-cron.sh

Troubleshooting
---------------

Common Issues
~~~~~~~~~~~~~

**Cron Job Not Running**

1. **Check crontab installation:**

   .. code-block:: bash

      sudo -u ec2-user crontab -l  # or -u rift

2. **Verify script permissions:**

   .. code-block:: bash

      ls -la /usr/local/bin/*-cron.sh

3. **Check system cron service:**

   .. code-block:: bash

      sudo systemctl status crond

**Permission Denied Errors**

1. **Verify passwordless sudo:**

   .. code-block:: bash

      sudo -u ec2-user sudo -n true && echo "OK" || echo "FAILED"

2. **Check sudoers configuration:**

   .. code-block:: bash

      sudo visudo -c  # Check syntax
      sudo grep ec2-user /etc/sudoers

3. **Test manual execution:**

   .. code-block:: bash

      sudo -u ec2-user /usr/local/bin/dye-cron.sh

**Lock File Issues**

Lock files are now stored in a user-writable directory (``${TMPDIR:-/tmp}/rift-cron/``) to avoid permission issues. The scripts automatically create this directory if it doesn't exist.

1. **Remove stale locks:**

   .. code-block:: bash

      rm -f ${TMPDIR:-/tmp}/rift-cron/*-cron.lock ${TMPDIR:-/tmp}/rift-cron/*-cron.pid

2. **Check for zombie processes:**

   .. code-block:: bash

      ps aux | grep -E "(dye-cron|input-cron|output-cron)" | grep -v grep

**Directory Not Found Errors**

1. **Create missing directories:**

   .. code-block:: bash

      sudo mkdir -p /var/abyss/dye
      sudo mkdir -p /var/abyss/input
      sudo mkdir -p /var/abyss/output

2. **Check directory permissions:**

   .. code-block:: bash

      ls -la /var/abyss/

**Log File Issues**

1. **Check log directory permissions:**

   .. code-block:: bash

      ls -la /var/log/ | grep processing

2. **Create log files manually:**

   .. code-block:: bash

      sudo touch /var/log/dye-processing.log
      sudo chown ec2-user:ec2-user /var/log/dye-processing.log

Debug Mode
~~~~~~~~~~

Both scripts provide detailed logging. To increase verbosity, check the log files:

.. code-block:: bash

   # Watch logs in real-time
   tail -f /var/log/dye-processing.log
   tail -f /var/log/input-processing.log

Performance Monitoring
~~~~~~~~~~~~~~~~~~~~~~

**Monitor Processing Statistics:**

.. code-block:: bash

   # Count processed files today
   grep "$(date '+%Y-%m-%d')" /var/log/dye-processing.log | grep "Processing file" | wc -l
   
   # Check average processing time
   grep "Processing completed" /var/log/dye-processing.log | tail -10

**Monitor System Resources:**

.. code-block:: bash

   # Check disk space
   df -h /var/log/
   df -h /var/abyss/
   
   # Check system load during processing
   top -p $(pgrep -f "cron.sh")

Security Considerations
-----------------------

Sudo Configuration
~~~~~~~~~~~~~~~~~~

- **Minimal Privileges**: Use specific command restrictions instead of ``NOPASSWD: ALL``
- **User Isolation**: Use dedicated users for different cron scripts
- **Regular Audits**: Review sudoers configuration regularly

File Permissions
~~~~~~~~~~~~~~~~

- **Log Files**: Ensure log files are not world-readable if they contain sensitive information
- **Script Files**: Ensure cron scripts are not writable by unauthorized users
- **Lock Files**: Verify lock files are created with proper permissions in user-writable directory

Network Security
~~~~~~~~~~~~~~~~

- **File Transfer**: If processing files from network sources, ensure secure transfer protocols
- **Access Control**: Implement proper access controls on source and target directories

Best Practices
--------------

1. **Start with Manual Testing**

   Always test cron scripts manually before installing them in cron.

2. **Use Appropriate Frequencies**

   - High-volume environments: Every 1-5 minutes
   - Normal environments: Every 5-15 minutes
   - Low-volume environments: Every 30-60 minutes

3. **Monitor Log Files**

   Set up log monitoring and alerting for error conditions.

4. **Regular Maintenance**

   - Review log files regularly
   - Clean up old log files
   - Monitor disk space usage

5. **Environment Consistency**

   Use the same environment variables and configurations across development and production.

6. **Backup Considerations**

   - Consider backing up source directories before processing
   - Implement file retention policies for processed files

Integration with Rift Commands
-------------------------------

The cron scripts complement the manual Rift commands:

- **Manual processing**: Use ``rift dye-add`` and ``rift input-add`` for immediate processing
- **Automated processing**: Use cron scripts for continuous, hands-free operation
- **Monitoring**: Use both manual commands and log files for status checking

See :doc:`dye-file-management` and :doc:`input-file-management` for manual command documentation.
