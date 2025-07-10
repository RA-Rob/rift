Smoke Test
=========

The smoke test functionality in Rift provides a way to verify the basic functionality of the system through a heartbeat mechanism.

Overview
--------

The rift-heartbeat script safely copies the file abc.pcap to a temporary location, then moves it atomically to the destination directory (/data/io-service/input-undersluice-99-default). This prevents race conditions where a processing job might pick up an incomplete copy.

Prerequisites
------------

* Linux environment with Bash shell
* Read access to the source file abc.pcap
* Write access to the destination directory (/data/io-service/input-undersluice-99-default)
* cron service installed and running

Installation
-----------

1. Save the script
~~~~~~~~~~~~~~~~

Create the file ``/usr/local/bin/rift-heartbeat`` with the following content:

.. code-block:: bash

   #!/bin/bash

   # Define file paths
   SOURCE_FILE="/path/to/abc.pcap"  # Update this to the actual path
   TEMP_FILE="/tmp/heartbeat.pcap"
   DEST_DIR="/data/io-service/input-undersluice-99-default"
   DEST_FILE="$DEST_DIR/heartbeat.pcap"

   # Ensure the destination directory exists
   mkdir -p "$DEST_DIR"

   # Create a temporary copy
   cp "$SOURCE_FILE" "$TEMP_FILE"

   # Move the copy to the destination (ensuring atomicity)
   mv "$TEMP_FILE" "$DEST_FILE"

   # Log the operation (optional)
   echo "$(date) - Moved heartbeat.pcap to $DEST_DIR" >> /var/log/rift-heartbeat.log

2. Make it executable
~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   chmod +x /usr/local/bin/rift-heartbeat

Configuration
------------

* ``SOURCE_FILE``: Path to the original abc.pcap file. Update this variable in the script.
* ``DEST_DIR``: Destination directory where heartbeat.pcap will be placed. By default, it is /data/io-service/input-undersluice-99-default.

Cron Job Setup
-------------

1. Open the crontab editor:

   .. code-block:: bash

      crontab -e

2. Add the following line to schedule the job every 5 minutes:

   .. code-block:: bash

      */5 * * * * /usr/local/bin/rift-heartbeat

3. Save and exit the editor.

Usage
-----

Manual Execution
~~~~~~~~~~~~~~

You can run the heartbeat script manually:

.. code-block:: bash

   /usr/local/bin/rift-heartbeat

Automated Execution
~~~~~~~~~~~~~~~~~

The cron job will automatically run every 5 minutes. You can monitor the log file to verify operations:

.. code-block:: bash

   tail -f /var/log/rift-heartbeat.log

Troubleshooting
--------------

Common Issues
~~~~~~~~~~~~

1. **Permission denied**: Ensure the script has execute permissions and the user has write access to the destination directory.

2. **File not found**: Check that the source file path is correct and the file exists.

3. **Disk space**: Ensure there's enough disk space in the destination directory.

Log Analysis
~~~~~~~~~~~

Monitor the heartbeat log for errors:

.. code-block:: bash

   grep -i error /var/log/rift-heartbeat.log

Check system logs for cron-related issues:

.. code-block:: bash

   grep CRON /var/log/syslog 