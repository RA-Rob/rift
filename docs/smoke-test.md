# chasm-heartbeat

A simple Bash script and cron job to create a periodic heartbeat copy of abc.pcap as heartbeat.pcap, ensuring atomic delivery to a monitored directory to avoid race conditions.

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Cron Job Setup](#cron-job-setup)
6. [Logging](#logging)
7. [Contributing](#contributing)
8. [License](#license)

## Overview

The chasm-heartbeat script safely copies the file abc.pcap to a temporary location, then moves it atomically to the destination directory (/data/io-service/input-undersluice-99-default). This prevents race conditions where a processing job might pick up an incomplete copy.

## Prerequisites
- Linux environment with Bash shell
- Read access to the source file abc.pcap
- Write access to the destination directory (/data/io-service/input-undersluice-99-default)
- cron service installed and running

## Installation

### 1. Save the script
Create the file `/usr/local/bin/chasm-heartbeat` with the following content:

```bash
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
echo "$(date) - Moved heartbeat.pcap to $DEST_DIR" >> /var/log/chasm-heartbeat.log
```

### 2. Make it executable
```bash
chmod +x /usr/local/bin/chasm-heartbeat
```

## Configuration
- `SOURCE_FILE`: Path to the original abc.pcap file. Update this variable in the script.
- `DEST_DIR`: Destination directory where heartbeat.pcap will be placed. By default, it is /data/io-service/input-undersluice-99-default.

## Cron Job Setup

### 1. Open the crontab editor:
```bash
crontab -e
```

### 2. Add the following line to schedule the job every 5 minutes:
```
*/5 * * * * /usr/local/bin/chasm-heartbeat
```

### 3. Save and exit. The job will now run every 5 minutes.

## Logging

The script appends a timestamped entry to `/var/log/chasm-heartbeat.log` each time it runs. Adjust the log path or format by editing the final echo command in the script.

## Contributing

Contributions, issues, and feature requests are welcome! Please open an issue or submit a pull request on this repository.

## License

This project is licensed under the MIT License.
