# Dashboard Management with Rift

Rift provides built-in support for managing Grafana dashboards on the controller node. The `dashboard` command allows you to add, list, and validate Grafana dashboards using JSON files.

## Prerequisites

Before using the dashboard management features, ensure that:

1. Grafana is installed and running on your controller node
2. Grafana is accessible (default: http://localhost:3000)
3. You have valid Grafana credentials (default: admin/admin)
4. Your inventory file is properly configured with the controller node

## Commands

### Add Dashboard

Add a dashboard from a JSON file to Grafana:

```bash
rift dashboard add -d <dashboard-file.json> [options]
```

#### Options:
- `-d, --dashboard`: Path to dashboard JSON file (required)
- `-u, --url`: Grafana URL (default: http://localhost:3000)
- `--user`: Grafana username (default: admin)
- `--password`: Grafana password (default: admin)

#### Examples:
```bash
# Add dashboard with default settings
rift dashboard add -d my-dashboard.json

# Add dashboard with custom Grafana URL
rift dashboard add -d dashboard.json -u http://grafana.example.com:3000

# Add dashboard with custom credentials
rift dashboard add -d dashboard.json --user myuser --password mypass
```

### List Dashboards

List all existing dashboards in Grafana:

```bash
rift dashboard list [options]
```

#### Options:
- `-u, --url`: Grafana URL (default: http://localhost:3000)
- `--user`: Grafana username (default: admin)
- `--password`: Grafana password (default: admin)

#### Example:
```bash
rift dashboard list
```

### Validate Dashboard

Validate a dashboard JSON file before importing:

```bash
rift dashboard validate -d <dashboard-file.json>
```

#### Options:
- `-d, --dashboard`: Path to dashboard JSON file (required)

#### Example:
```bash
rift dashboard validate -d my-dashboard.json
```

## Dashboard Storage

Rift includes a dedicated `dashboards/` directory for storing Grafana dashboard JSON files. This directory is:

- **Development**: Located at `./dashboards/` in your rift workspace
- **Installed**: Located at `/usr/share/rift/dashboards/` when installed via RPM
- **Purpose**: Central location for all dashboard definitions used in your deployments

### Organization

You can organize dashboards in the dashboards directory by:
- Application type (e.g., `system-monitoring.json`, `application-metrics.json`)
- Environment (subdirectories if needed)
- Purpose (infrastructure, application, security, etc.)

All JSON files in the dashboards directory are included in the rift release packages.

## Dashboard JSON Format

Dashboard JSON files should follow the Grafana dashboard export format. Rift supports both formats:

1. **Wrapped Format**: Dashboard JSON wrapped in a "dashboard" object (typical of API exports)
2. **Direct Format**: Dashboard JSON as exported directly from Grafana UI

Here's a minimal example of the wrapped format:

```json
{
  "dashboard": {
    "id": null,
    "title": "My Dashboard",
    "tags": ["monitoring"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Sample Panel",
        "type": "graph",
        "targets": [
          {
            "expr": "up",
            "format": "time_series",
            "legendFormat": "Uptime"
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 0
        }
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s",
    "schemaVersion": 16,
    "version": 1
  }
}
```

### Direct Format Example

```json
{
  "id": null,
  "title": "My Dashboard",
  "tags": ["monitoring"],
  "timezone": "browser",
  "panels": [
    {
      "id": 1,
      "title": "Sample Panel",
      "type": "graph",
      "targets": [
        {
          "expr": "up",
          "format": "time_series",
          "legendFormat": "Uptime"
        }
      ],
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      }
    }
  ],
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "refresh": "30s",
  "schemaVersion": 16,
  "version": 1
}
```

## Features

### Automatic Validation
- JSON syntax validation
- Required field checking
- Error reporting with detailed messages

### Grafana Integration
- Health check before dashboard import
- Automatic overwrite of existing dashboards
- Dashboard ID and UID tracking

### Logging
- Dashboard import logs stored in `/var/log/rift/`
- Each dashboard gets a unique log file with import details
- Includes dashboard URL for easy access

## Troubleshooting

### Common Issues

1. **Grafana not accessible**
   - Check that Grafana is running on the controller node
   - Verify the Grafana URL is correct
   - Ensure firewall rules allow access to Grafana port

2. **Authentication failures**
   - Verify Grafana username and password
   - Check if default credentials have been changed
   - Ensure the user has dashboard creation permissions

3. **Invalid JSON format**
   - Validate JSON syntax using `rift dashboard validate`
   - Check for missing required fields
   - Ensure the dashboard format is supported

4. **Permission errors**
   - Verify the user has sudo access on the controller node
   - Check file permissions on dashboard files
   - Ensure log directory exists and is writable

### Validation Tips

- Always validate dashboards before importing using `rift dashboard validate`
- Test with a simple dashboard first to verify connectivity
- Check Grafana logs for additional error details

### Debug Mode

Enable verbose output for detailed debugging:

```bash
rift dashboard add -d dashboard.json -v
```

## Log Files

Dashboard operations create log files in `/var/log/rift/`:
- Dashboard import logs: `/var/log/rift/dashboard-<uid>.log`
- Each log contains dashboard details and import results
- Logs include direct links to the imported dashboards

## Advanced Usage

### Batch Import

Import multiple dashboards at once:

```bash
# Import all dashboards from the dashboards directory
for dashboard in dashboards/*.json; do
  rift dashboard add -d "$dashboard"
done

# Import dashboards from installed location
for dashboard in /usr/share/rift/dashboards/*.json; do
  rift dashboard add -d "$dashboard"
done
```

### Custom Configuration

You can customize the dashboard import behavior by:
- Setting custom Grafana URL and credentials
- Using different inventory files for different environments
- Organizing dashboards by environment or application

### Automation

Dashboard management can be automated as part of your deployment pipeline:

1. Deploy your infrastructure: `rift deploy`
2. Add monitoring dashboards: `rift dashboard add -d monitoring.json`
3. Verify installation: `rift test`

This ensures that your monitoring dashboards are deployed alongside your infrastructure, providing immediate visibility into your system's health and performance. 