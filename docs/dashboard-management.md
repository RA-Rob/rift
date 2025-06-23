# Dashboard Management with Chasm

Chasm provides built-in support for managing Grafana dashboards on the controller node. The `dashboard` command allows you to add, list, and validate Grafana dashboards using JSON files.

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
chasm dashboard add -d <dashboard-file.json> [options]
```

#### Options:
- `-d, --dashboard`: Path to dashboard JSON file (required)
- `-u, --url`: Grafana URL (default: http://localhost:3000)
- `--user`: Grafana username (default: admin)
- `--password`: Grafana password (default: admin)

#### Examples:
```bash
# Add dashboard with default settings
chasm dashboard add -d my-dashboard.json

# Add dashboard with custom Grafana URL
chasm dashboard add -d dashboard.json -u http://grafana.example.com:3000

# Add dashboard with custom credentials
chasm dashboard add -d dashboard.json --user myuser --password mypass
```

### List Dashboards

List all existing dashboards in Grafana:

```bash
chasm dashboard list [options]
```

#### Options:
- `-u, --url`: Grafana URL (default: http://localhost:3000)
- `--user`: Grafana username (default: admin)
- `--password`: Grafana password (default: admin)

#### Example:
```bash
chasm dashboard list
```

### Validate Dashboard

Validate a dashboard JSON file before importing:

```bash
chasm dashboard validate -d <dashboard-file.json>
```

#### Options:
- `-d, --dashboard`: Path to dashboard JSON file (required)

#### Example:
```bash
chasm dashboard validate -d my-dashboard.json
```

## Dashboard Storage

Chasm includes a dedicated `dashboards/` directory for storing Grafana dashboard JSON files. This directory is:

- **Development**: Located at `./dashboards/` in your chasm workspace
- **Installed**: Located at `/usr/share/chasm/dashboards/` when installed via RPM
- **Purpose**: Central location for all dashboard definitions used in your deployments

### Organization

You can organize dashboards in the dashboards directory by:
- Application type (e.g., `system-monitoring.json`, `application-metrics.json`)
- Environment (subdirectories if needed)
- Purpose (infrastructure, application, security, etc.)

All JSON files in the dashboards directory are included in the chasm release packages.

## Dashboard JSON Format

Dashboard JSON files should follow the Grafana dashboard export format. Chasm supports both formats:

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
- Dashboard import logs stored in `/var/log/chasm/`
- Each dashboard gets a unique log file with import details
- Includes dashboard URL for easy access

## Troubleshooting

### Common Issues

1. **Grafana not accessible**
   ```
   Error: Grafana is not accessible at http://localhost:3000
   ```
   - Ensure Grafana is running on the controller node
   - Check firewall settings
   - Verify the Grafana URL

2. **Authentication failed**
   ```
   Error: HTTP 401 Unauthorized
   ```
   - Check Grafana username and password
   - Ensure the user has dashboard creation permissions

3. **Invalid JSON format**
   ```
   Error: Invalid JSON format in dashboard file
   ```
   - Validate JSON syntax using `chasm dashboard validate`
   - Check for missing commas or brackets
   - Ensure proper encoding (UTF-8)

4. **Missing required fields**
   ```
   Warning: Dashboard JSON missing recommended field: title
   ```
   - Add missing fields to your dashboard JSON
   - Use `chasm dashboard validate` to check for issues

### Log Locations

- Dashboard import logs: `/var/log/chasm/dashboard-<uid>.log`
- Ansible execution logs: Use `-v` flag for verbose output

## Examples

### Sample Dashboard

A sample dashboard JSON file is provided at `dashboards/sample-dashboard.json`. This includes:
- System load monitoring
- Memory usage graphs
- Disk usage single stat
- Network traffic graphs

To use the sample dashboard:
```bash
chasm dashboard add -d dashboards/sample-dashboard.json
```

### Batch Import

To import multiple dashboards from the dashboards directory:
```bash
# Import all dashboards from the dashboards directory
for dashboard in dashboards/*.json; do
    chasm dashboard add -d "$dashboard"
done

# Or when installed via RPM
for dashboard in /usr/share/chasm/dashboards/*.json; do
    chasm dashboard add -d "$dashboard"
done
```

## Security Considerations

- Store Grafana credentials securely
- Use environment variables for passwords in scripts
- Consider using Grafana API keys instead of user credentials
- Restrict dashboard management to authorized users only

## Integration with Chasm Deployment

The dashboard command integrates seamlessly with other Chasm commands:

1. Deploy your infrastructure: `chasm deploy`
2. Add monitoring dashboards: `chasm dashboard add -d monitoring.json`
3. Verify installation: `chasm test`

This workflow ensures your monitoring is set up consistently across deployments. 